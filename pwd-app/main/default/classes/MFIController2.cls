global without sharing class MFIController2 {
  
    global String input {get; set;}
    global String password {get; set;}
    global String providedCode {get; set;}
       
    public String startURL  {get; set;}
    public String siteURL  {get; set;}
    
    public Boolean IsDiscovery {get; set;}
    public Boolean IsPasswordChallenged {get; set;} 
    public Boolean IsBack {get; set;}
    public Boolean IsChooser {get; set;}
    public Boolean IsEmail {get; set;}
    public Boolean IsInit {get; set;}
    public Boolean IsVerify {get; set;}
    public Boolean showInitException {get; set;}
    
    
    
    public List<Auth.VerificationMethod> methods;
    
    public String username;
    public Id userid;
    List <user> users =null; 
    public String expid {get; set;}
    
    public String label;
    public String error;
    public String smsChallengeId;
    public String emailChallengeId;
    

    
    public Component.Apex.OutputPanel outPanel; 
    
    global MFiController2()
    {
        startURL = System.currentPageReference().getParameters().get('startURL');
        
        if (startURL == null) startURL = '/'; 
        
        // Add verification methods
        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.EMAIL);
        methods.add(Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);
       
        invokeDiscovery();
        
        expid = ApexPages.currentPage().getParameters().get('expid');
    }
    
    global String getEncodedSiteUrl() {
        return EncodingUtil.urlEncode(siteURL, 'UTF-8');
    }
    
    global String getEncodedStartUrl() {
        return EncodingUtil.urlEncode(startURL, 'UTF-8');
    }
    
    global PageReference chooser() {
        IsDiscovery = false; 
        IsChooser = true;
        IsPasswordChallenged = false;
        IsBack = true;
        isEmail = false;

        label = 'Choose method:';

        return null;
    }
    
    global void invokeDiscovery() {
        IsDiscovery = true; 
        IsPasswordChallenged = false;
        IsBack = false;
        IsChooser = false;
        IsEmail = false;
        label= 'Enter Email or Phone no';
    }

    // this method uses Salesforce's default page        
/*
    global PageReference invokeSMS()
    {
        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.SMS);
        
        error = 'invoke SMS';

        return Site.passwordlessLogin(userid, methods, startURL);
    } 
*/

    global PageReference invokePassword()
    { 

    methods = new List<Auth.verificationMethod>();
    methods.add(Auth.VerificationMethod.PASSWORD);
    
    error = 'invoke Password';
    system.debug('going to Password approach');
    return Site.passwordlessLogin(userid, methods, startURL);
    } 

    global PageReference invokeEmail()
    {

        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.Email);
        
        error = 'invoke Email';
        system.debug('going to email approach');
        return Site.passwordlessLogin(userid, methods, startURL);
    } 
    
    global PageReference login_with_email(){

        IsDiscovery = false; 
        IsPasswordChallenged = false;
        IsBack = false;
        IsChooser = false;
        IsEmail = true;

        system.debug('Invoking login with email');
        label= 'Enter code';  
        error = null;
        user userrec = null;

        userrec=users[0];
        system.debug('user rec is:'+userrec);
        // check if email is registered
        TwoFactorMethodsInfo tf = [select id, userid, hasuserverifiedemailaddress, hasuserverifiedmobilenumber from TwoFactorMethodsInfo where userid =:userid];
       /* if (!tf.hasuserverifiedemailaddress){
            string initreg;
            initreg= System.UserManagement.initRegisterVerificationMethod(Auth.VerificationMethod.EMAIL);
            system.debug('got Error registerverification:'+initreg );
            if (initreg !='') {
                if (providedCode != null) {
                     initreg = System.UserManagement.verifyRegisterVerificationMethod(providedCode,Auth.VerificationMethod.EMAIL);
                     system.debug('after verify registration' + initreg);  
                  }
            }
        } */
        // cannot use initRegisterVerificationMethod for the external users
        if (!tf.hasuserverifiedemailaddress){
            id networkid = Network.getNetworkId();
            id emailTemplateid = '00Xr0000000VNrO';
            system.debug('got networkid as:'+networkid);
            
            system.UserManagement.sendAsyncEmailConfirmation(userId, emailTemplateId, networkId, startUrl) ;
               error = 'wait for email confirmation';
            return null;
        } 
        emailChallengeId = System.UserManagement.initPasswordlessLogin(userid, Auth.VerificationMethod.EMAIL);
        if (providedCode != null) {
            Auth.VerificationResult res = System.UserManagement.verifyPasswordlessLogin(userid,Auth.VerificationMethod.EMAIL, emailChallengeId, providedCode, startURL);
                if (res.success) {
                    system.debug('email is success');
                    return res.redirect;
                 } else {
                    error = res.message;
                    return null;
                 }
             } else return null;
    }

    global PageReference invokeAuthenticator()
    {
    
        error = 'invoke Authenticator';
        system.debug('Invoking Authenticator');
        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);
        
        return Site.passwordlessLogin(userid, methods, startURL);
    } 
    

  
    global PageReference login_with_password() 
    { 
        IsDiscovery = false; 
        IsPasswordChallenged = true;
        IsBack = false;
        IsChooser = false;
        IsEmail = false;
        
        label= 'Enter Password';
        PageReference PageRef;

        System.debug('going here with user '+username+ 'userid:'+ userid);
       // User u = [select username from User where id=:userid limit 1];
        
        if(username == null || username == '')
        {
            error = 'Username is missing';
            return null;
        }
        
        // Empty input
        if(password == null || password == '')
        {
            error = 'No Password - Enter your password...';
            return null;
        }
        
        
        // Invoke phone registration post login
        String redirect_url = '/apex/RegisterMethods';
        if(startURL != '')
            redirect_url+='?startURL=' + startURL;
        
        try {
            system.debug('calling login with '+password + ' and starturl' +startURL);
            UserManagement.verifyVerificationMethod('', password , Auth.VerificationMethod.PASSWORD);
//            PageRef =  Site.login(username, password, startUrl);
        }
        catch(Exception e) {
            system.debug(e.getMessage());
            error = 'Try again: ' + username;
        }

        return PageRef;
    }
    
    global PageReference login() {
        
     //   List<User> users = null;
        System.debug('I am in the login function');
        // Empty input
        if(input == null || input == '')
        {
            error = 'Enter Email or Phone';
            return null;
        }
      /*Profile p = [select id from profile where name = 'External' Limit 1];
        if (p == null) {
            error ='External Profile does not exist';
            return null;
        }
       */
        users = [select name, username, id, email,mobilephone,LanguageLocaleKey,ProfileId,CommunityNickname,LastName,FirstName,Alias from User where Email=:input and isactive=true ];
        if(users == null || users.isEmpty() == true)
        {
            error = 'Can\'t find a user';
            return null;
        }
        if(users.size() > 1)
        {
            error = 'Can\'t find a unique user';
            //return null;
        }
        username = users[0].username;
        userid = users[0].id;
        System.debug('using userid:'+userid+' username:'+username);
        return chooser(); 
    } 
    
    public Component.Apex.OutputPanel getTheDiscoveryPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        outPanel.styleClass = 'usa-card';
        Component.Apex.InputText inputTxt = new Component.Apex.InputText();
        
        inputTxt.expressions.value = '{!input}';
        inputTxt.styleClass = 'usa-input';
        
        Component.Apex.commandLink cmdLink = new Component.Apex.commandLink();
        cmdLink.value = 'NEXT';
        cmdLink.styleClass = 'usa-button';
        cmdLink.expressions.action = '{! login }';
       // cmdLink.expressions.reRender = '{labelPanel}';
        
        Component.Apex.outputLabel errorLabel = new Component.Apex.outputLabel();
        errorLabel.styleClass = 'error';
        errorLabel.value = error;
        errorLabel.id = 'errorlabel';
        
        outPanel.childComponents.add( inputTxt );
        outPanel.childComponents.add( errorLabel );
        outPanel.childComponents.add( cmdLink );
        
        return outPanel;
    }
    
    public Component.Apex.OutputPanel getThePasswordPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        
        Component.Apex.InputSecret inputSecret = new Component.Apex.InputSecret();
        inputSecret.expressions.value = '{!password}';
        inputSecret.styleClass = 'usa-input';
        
        Component.Apex.commandLink cmdLink = new Component.Apex.commandLink();
        cmdLink.value = 'Login with Password';
        cmdLink.styleClass = 'usa-button';
        cmdLink.expressions.action = '{! login_with_password }';
        
        Component.Apex.outputLabel errorLabel = new Component.Apex.outputLabel();
        errorLabel.styleClass = 'error';
        errorLabel.value = error;
        //errorLabel.id = 'errorlabel';
        
        outPanel.childComponents.add( inputSecret );
        outPanel.childComponents.add( errorLabel );
        outPanel.childComponents.add( cmdLink );

        return outPanel;
    }

    public Component.Apex.OutputPanel getTheEmailPanel() {

        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        
        Component.Apex.InputText inputText = new Component.Apex.InputText();
        inputText.expressions.value = '{!providedCode}';
        inputText.styleClass = 'usa-input';
        Component.Apex.commandLink cmdLink = new Component.Apex.commandLink();
        cmdLink.value = 'Login with Email Code';
        cmdLink.styleClass = 'usa-button';
        cmdLink.expressions.action = '{!login_with_email}';
        
        Component.Apex.outputLabel errorLabel = new Component.Apex.outputLabel();
        errorLabel.styleClass = 'error';
        errorLabel.value = error;
        //errorLabel.id = 'errorlabel';
        
        outPanel.childComponents.add( inputText );
        outPanel.childComponents.add( errorLabel );
        outPanel.childComponents.add( cmdLink );

        return outPanel;
    }  
    
    
    public Component.Apex.OutputPanel getTheChooserPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        Component.Apex.OutputText htmlTxt = new Component.Apex.OutputText();
        Component.Apex.ActionFunction Emailfunction = new Component.Apex.ActionFunction(); 
        Component.Apex.ActionFunction Authenticatorfunction = new Component.Apex.ActionFunction();
        Component.Apex.ActionFunction Passwordfunction = new Component.Apex.ActionFunction(); 
        
        
        Emailfunction.name = 'setEmailMethod';
        Emailfunction.expressions.action = '{!login_with_email}';
        
        Authenticatorfunction.name = 'setAuthenticatorMethod';
        Authenticatorfunction.expressions.action = '{!invokeAuthenticator}';
        
         
        Passwordfunction.name = 'setPasswordMethod';
        Passwordfunction.expressions.action = '{!login_with_password}';
        
        
        htmlTxt.escape = false;
        
        htmlTxt.value = '<div class="scrollable">';
        htmlTxt.value += '<ul id="idlist">';
        htmlTxt.value += '<li><a href="#" onclick="setAuthenticatorMethod();"><img alt class="thumbnail" src="https://identitycms.herokuapp.com/DF17/phone.png"> <span>AUTHENTICATOR</span></a></li>';
        htmlTxt.value += '<li><a href="#" onclick="setEmailMethod();"><img alt class="thumbnail" src="https://identitycms.herokuapp.com/DF17/email.png"> <span>Email</span></a></li>';
        htmlTxt.value += '<li><a href="#" onclick="setPasswordMethod();"><img alt class="thumbnail" src="https://identitycms.herokuapp.com/DF17/password.png"> <span>Password</span></a></li>';
        htmlTxt.value += '</ul>';
        htmlTxt.value += '</div>';
        
        outPanel.childComponents.add( htmlTxt );
        outPanel.childComponents.add( Authenticatorfunction );
        outPanel.childComponents.add( Emailfunction );
        outPanel.childComponents.add( Passwordfunction );

        return outPanel;
    }
    
    public Component.Apex.OutputPanel getTheLabelPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        
        Component.Apex.outputLabel outputLabel = new Component.Apex.outputLabel();
        outputLabel.styleClass = 'style';
        outputLabel.value = label;
        outputLabel.id = 'labelPanel';
                
        outPanel.childComponents.add( outputLabel );
     
        return outPanel;
    }
    
    public Component.Apex.OutputPanel getTheErrorPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        
        Component.Apex.outputLabel outputLabel = new Component.Apex.outputLabel();
        outputLabel.styleClass = 'style';
        outputLabel.value = error;
        outputLabel.id = 'errorPanel';
                
        outPanel.childComponents.add( outputLabel );
       
        return outPanel;
    }
    
    public Component.Apex.OutputPanel getTheFooterPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        Component.Apex.commandLink cmdLink = new Component.Apex.commandLink();
        cmdLink.value = 'Back';
        cmdLink.styleClass = 'usa-button';
        
      
        cmdLink.expressions.action = '{!invokeDiscovery}';
        
        outPanel.childComponents.add( cmdLink );
      
        return outPanel;
    }
}