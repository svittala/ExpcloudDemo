global without sharing class MFILoginController {
  
    global String input {get; set;}
    global String password {get; set;}
    global String providedCode {get; set;}
    global String registrationId;
    global boolean isLoggedOn {get; set;}
    
    public String startURL  {get; set;}
    public String siteURL  {get; set;}
    
    public Boolean IsDiscovery {get; set;}
    public Boolean IsPasswordChallenged {get; set;} 
    public Boolean IsBack {get; set;}
    public Boolean IsChooser {get; set;}
    public Boolean IsEmail {get; set;}
    public Boolean IsInit {get; set;}
    public Boolean IsVerify {get; set;}
    public Boolean IsVerified {get; set;}
    public Boolean showInitException {get; set;}
    public Boolean IsVerifyChallenge {get; set;}
    
    public String challengeResponse {get; set;}

    public List<Auth.VerificationMethod> methods;
    
    public String username {get; set;}
    public Id userid;
    List <user> users =null; 

    public User dummyUser {get; set;} 
    public String expid {get; set;}
    
    public String label;
    public String error {get; set;}
    public String smsChallengeId;
    public String emailChallengeId;
    public String challengeInfo;
    public String pinInfo;
    public String challengeQuestion {get;set;}
    public String expectedChallengeResponse;
    Map<String, String> challengeReqResp;

    Auth.VerificationResult res;
    
    public Component.Apex.OutputPanel outPanel; 
    
    global MFILoginController()
    {
        startURL = System.currentPageReference().getParameters().get('startURL');
        
        if (startURL == null) startURL = '/'; 
        
        // Add verification methods
        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.EMAIL);
        methods.add(Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);
       
        invokeDiscovery();
        
        expid = ApexPages.currentPage().getParameters().get('expid');
        
        String userId = UserInfo.getUserId();
        User u = [Select MobilePhone, Id, userName from User Where Id=:userId];
		if (u != null) username = u.userName;
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
    
    global PageReference invokeDiscovery() {
        IsDiscovery = true; 
        IsPasswordChallenged = false;
        IsBack = false;
        IsChooser = false;
        IsEmail = false;
        label= 'Enter Email or Phone no';
        
        input = '';
        System.debug('Userid:' + UserInfo.getUserId());
        if (UserInfo.getUserId() == '005BZ000000h2YvYAI') 
        {

            IsVerifyChallenge = true;
            IsEmail = false;
            isDiscovery = false;



        }
        User currentUser = [select  Challenge_Info__c 
        from User where id =:UserInfo.getUserId() ]; 

        challengeInfo = currentUser.challenge_info__c;
        parseChallengeInfo(currentUser.challenge_info__c);

        return null;
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


		login();
        if (userid == null) {
            error = 'Unable to find ' + input;
            return null;
        }
        /*
        if (true) {
            IsVerifyChallenge = true;
            return null;
        }
        */
        IsDiscovery = false; 
        IsPasswordChallenged = false;
        IsBack = false;
        IsChooser = false;
        IsEmail = true;        
        system.debug('Invoking login with email');
        label= 'Enter code';  
        error = null;
        user userrec = null;
        dummyUser = new User();
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
            id emailTemplateid = '00XBZ000000MJBc'; //'00Xr0000000VNrO';
            system.debug('got networkid as:'+networkid);
            
            System.debug('Sending Async Email Confirmation:' + system.UserManagement.sendAsyncEmailConfirmation(userId, emailTemplateId, networkId, startUrl)) ;
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
    global PageReference verifyEmailOTP(){
        if (providedCode != null) {
            String relativeURL;
            if (challengeInfo == null) relativeURL = 's/pinsetup';
            else {
                relativeURL = 's/pinverify';
            }
            res = System.UserManagement.verifyPasswordlessLogin(userid,Auth.VerificationMethod.EMAIL, emailChallengeId, providedCode, startURL + relativeURL);
                if (res.success) {
                    system.debug('email is success');
                    // error = 'User ' + UserInfo.getName() + ' logged in successfully.';
                    if (challengeInfo != null) {
                        IsVerifyChallenge = true;
                        IsEmail = false;
                        //return null;
                    }

                    return res.redirect;
                 } else {
                    error = res.message;
                    return null;
                 }
        } 
        else 
            return null;        
    }
    global PageReference verifyChallenge(){
        //challengeResponse = dummyUser.Challenge_Info__c;
        if ((challengeResponse != null) && (challengeResponse == expectedChallengeResponse)){
            //User currentUser = [select id, LastVerifiedSessionId__c from User where id = :UserInfo.getUserId()];
            //currentUser.LastChallengeVerifiedTime__c = '' + Datetime.now().getTime();
            //update currentUser;
            //isVerified = true;
            //PageReference p =  new PageReference('https://ssoit-acf-orr.cs234.force.com/identity/s/');
            return new Pagereference(Site.getBaseSecureUrl() + '/s/pinsetup');


            //return Auth.SessionManagement.finishLoginFlow();
            /*
              if ((res != null) && (res.success)) {
                    system.debug('email is success');
                    error = 'User ' + UserInfo.getName() + ' logged in successfully.';
                    isLoggedOn = true;
                    return res.redirect;
                 } else {
                    error = 'Challenge not verified';
                    return null;
                 }
            */
        } 
        
        error = 'Challenge not verified';
        return null;        
    }
    global PageReference invokeAuthenticator()
    {
    
        error = 'invoke Authenticator';
        system.debug('Invoking Authenticator');
        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);
        methods.add(Auth.VerificationMethod.TOTP);

        //String authChallengeId = System.UserManagement.initPasswordlessLogin(userid, Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);

        //res = System.UserManagement.verifyPasswordlessLogin(userid,Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR, authChallengeId, providedCode, startURL);
        String relativeURL;
        if (pinInfo == null) relativeURL = 's/pinsetup';
        else {
            relativeURL = 's/pinverify';
        }    
        return Site.passwordlessLogin(userid, methods, '/identity/' + relativeURL);
        //if (res.success) IsVerifyChallenge = true;
        //return null;
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
    global PageReference registerUser() {
        /*
        users = [select name, username, id, email,mobilephone,LanguageLocaleKey,ProfileId,CommunityNickname,LastName,FirstName,Alias from User where Email=:input and isactive=true and UserType != 'Standard' ];
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
        isDiscovery = false;
        isEmail = true;
		*/
        //System.debug(System.UserManagement.initRegisterVerificationMethod(Auth.VerificationMethod.EMAIL));
		User user = [select id, MobilePhone from User where Email = :input and UserType != 'Standard']; 
		id networkid = Network.getNetworkId();
        id emailTemplateid = '00XBZ000000MJBc'; //'00Xr0000000VNrO';
        system.debug('got networkid as:'+networkid);
            
        System.debug('Sending Async Email Confirmation:' + system.UserManagement.sendAsyncEmailConfirmation(user.Id, 
                                                                                                            emailTemplateId, 
                                                                                                            networkId, 'https://ssoit-acf-orr.cs234.force.com/identity/s/pwless')) ;
        error = 'Sent Async Verification eamil to ' + input;
		return null;        
    }
    global PageReference verifyRegistration() {
        error = System.UserManagement.verifyRegisterVerificationMethod(providedCode, Auth.VerificationMethod.EMAIL);
        

		return null;        
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
        users = [select name, username, User_PIN__c, Challenge_Info__c, id, email,mobilephone,LanguageLocaleKey,ProfileId,Profile.Name,CommunityNickname,LastName,FirstName,Alias 
                 from User where Email=:input and isactive=true and UserType != 'Standard' ]; 
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
        isEmail = true;
		isDiscovery = false;
        username = users[0].username;
        userid = users[0].id;
        challengeInfo = users[0].challenge_info__c;
        pinInfo = users[0].User_PIN__c;
        parseChallengeInfo(users[0].challenge_info__c);
        
        if ( users[0].Profile.Name.contains('MFA'))
            return invokeAuthenticator();
        System.debug('using userid:'+userid+' username:'+username);
        return null; //invokeEmail(); //null; //chooser(); 
    } 
    void parseChallengeInfo(String challengeInfo) {
        List<String> challenges =  new List<String>();

        if (challengeInfo != null) {
            challenges = challengeInfo.split(';');
        
            Integer index = Math.mod(Math.round(Math.random() * 1000000), challenges.size());
            challengeQuestion = challenges[index].split(':')[0];
            if (challengeQuestion.length() < 10) {
                Challenge ch = Challenge.getChallengeById(challengeQuestion);
                if (ch != null) challengeQuestion = ch.question;
            }
            expectedChallengeResponse = challenges[index].split(':')[1];
        }
    }
    /*
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
    */
}