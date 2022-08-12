global without sharing class MFISignupController {
   
    public String startURL  {get; set;}
    public String siteURL  {get; set;}
    
    public Boolean IsDiscovery {get; set;}
    public Boolean IsOTPChallenged {get; set;} 
    public Boolean IsBack {get; set;}
    
    public string phone {get; set;}
    public string email {get; set;}
    public string firstname {get; set;}
    public string lastname {get; set;}
    public string password {get; set;}
    public Boolean IsInit {get; set;}
    public Boolean IsVerify {get; set;}
    public Boolean showInitException {get; set;}

    public List<Auth.VerificationMethod> methods;
    
    
    public String expid {get; set;}
    
    public String label;
    public String error {get; set;}
    
    public Component.Apex.OutputPanel outPanel; 
    
    global MFISignupController()
    {   
        expid = ApexPages.currentPage().getParameters().get('expid');
        
        startURL = ApexPages.currentPage().getParameters().get('startURL');
        if (startURL == null) startURL = '/';
       
        invokeDiscovery();
        
        // Add verification methods
        methods = new List<Auth.verificationMethod>();
        methods.add(Auth.VerificationMethod.SMS);
        
        
    }
    
    global String getEncodedSiteUrl() {
        return EncodingUtil.urlEncode(siteURL, 'UTF-8');
    }
    
    global String getEncodedStartUrl() {
        return EncodingUtil.urlEncode(startURL, 'UTF-8');
    }
    
    global void invokeDiscovery() {
        IsDiscovery = true; 
        IsOTPChallenged = false;
        IsBack = false;
        label= 'Sign Up..';
    }
      
    
    
    global PageReference signup() {
        
        Integer len = 10;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        password = key.substring(0,len);
        
        // TODO: assign the Is Single Sign-On Enabled user perm to the user
        
        // Empty input
        if(firstname == null || firstname == '')
        {
            error = 'First name is required';
            return null;
        }
        
        if(lastname == null || lastname == '')
        {
            error = 'Last name is required';
            return null;
        }
        
        if(email == null || email == '')
        {
            error = 'Email is required';
            return null;
        }
            
        if(password == null || password == '')
        {
            error = 'Password is required';
            return null;
        }
           
       /* List<User> users = [select id from User where Email=:email ];
        if(users != null && users.isEmpty() == false)
        {
            error = 'User already exists';
            return null;
        }
        */
        // Create a new user
        Profile p = [SELECT Id FROM profile WHERE name='External'];
        string accountid;
        Account[] a = [SELECT Id FROM account WHERE name='Customers'];        
        if (a.size() > 0)
              accountid =a[0].id;  
        else {
            error ='Account for Customers does not exist';
            return null;
        }
        Contact[] c = [SELECT id FROM Contact where accountid =:accountid and email =:email];
        if (c.size()> 0) {
            error='Contact for this email exists in Customers Account';
            return null;
        }
        
        User u = new User();
        string uniquename =   'external-'+generateRandomString(3)+email;
        u.username = uniquename;
        u.email = email;
        u.lastName = lastname;
        u.firstName = firstname;
        u.CommunityNickname = u.username;
        u.profileid = p.id; 
        // do 
        try {
           /* this does not work
           Network MyCommunity = new Network();
           string networkId = MyCommunity.getNetworkId();
           
          NetworkMember membership = [SELECT networkID FROM NetworkMember 
                                                    WHERE memberID = :u.id];
          if (membership != null) {
            string networkid = membership.id;  
            string emailtempid='00Xr0000000VNrL';
            System.UserManagement.sendAsyncEmailConfirmation(u.id, 
                emailtempid,networkid, '/s');}
            }                                         
            catch (Exception ex){
            error = ex.getMessage();
            return null;
        }*/
        try {
           String userId = Site.createExternalUser(u, accountid, password);
        }
        catch (Site.ExternalUserCreateException ex)
        {
            error = ex.getMessage();
            return null;
        }
        /*
        registerUserEmail();
        System.debug('after calling registeremail:'+error);
        verifyUserEmail(); 
        System.debug('after calling regiverifyUser:'+error);
        return site.login(u.username, password, startURL);
        */
        String id = System.UserManagement.initSelfRegistration​(Auth.VerificationMethod.EMAIL, user);
        string code;
        Auth.VerificationResult res = System.UserManagement.verifySelfRegistration​(Auth.VerificationMethod.EMAIL, id, code, null);
        if(res.success == true){
            //redirect
             return res.redirect;
            }
        return null;
    }
    catch ( Exception ex){
        error = ex.getMessage();
        return null;
    }
} 
    ////
    String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    void registerUserEmail ()
    {
        try {
            error='';
            // We're updating the email and phone number before verifying. Roll back  
           //  the change in the verify API if it is unsuccessful.
            error = System.UserManagement.initRegisterVerificationMethod(Auth.VerificationMethod.EMAIL);
            if(error!= null && error!=''){
                isInit = false;
                showInitException = true;
            } else {
                 isInit = false;
                 isVerify = true;
            }
        } catch (Exception e) {
            error = e.getMessage();
            isInit = false;
            showInitException = true;
        }
    }

 void verifyUserEmail() 
 {
    // Take the user’s input for the code sent to their phone number
    string code;
    error = System.UserManagement.verifyRegisterVerificationMethod(code, Auth.VerificationMethod.EMAIL);
    if(error != null && error !=''){
    showInitException = true;
    } else {
            //Success    
    }
}
 void registerUserSMS() {
    try {
        error='';
        String userId = UserInfo.getUserId();
        User u = [Select MobilePhone, Id from User Where Id=:userId];
         string  mobilePhone  = u.MobilePhone;
       // mobilePhone = UserManagement.formatPhoneNumber('+1', mobilePhone); 
       if (mobilePhone != null && mobilePhone != '') {
       u.MobilePhone = mobilePhone;
       update u;
        // We're updating the email and phone number before verifying. Roll back  
       //  the change in the verify API if it is unsuccessful.
        error = System.UserManagement.initRegisterVerificationMethod(Auth.VerificationMethod.SMS);
        if(error!= null && error!=''){
            isInit = false;
            showInitException = true;
        } else {
             isInit = false;
             isVerify = true;
        }
    }
    } catch (Exception e) {
        error = e.getMessage();
        isInit = false;
        showInitException = true;
    }
}

 void verifyUserSMS() {
// Take the user’s input for the code sent to their phone number
string code;
error = System.UserManagement.verifyRegisterVerificationMethod(code, Auth.VerificationMethod.SMS);
if(error != null && error !=''){
showInitException = true;
} else {
        //Success    
}
}    

////
    public Component.Apex.OutputPanel getTheLabelPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        
        Component.Apex.outputLabel outputLabel = new Component.Apex.outputLabel();
        outputLabel.styleClass = 'style';
        outputLabel.value = label;
        outputLabel.id = 'labelPanel';
                
        outPanel.childComponents.add( outputLabel );
     
        return outPanel;
    }
    
    public Component.Apex.OutputPanel getTheFooterPanel() {
        Component.Apex.OutputPanel outPanel = new Component.Apex.OutputPanel();
        Component.Apex.commandLink cmdLink = new Component.Apex.commandLink();
        
        cmdLink.value = 'Back';
        cmdLink.styleClass = 'footer';
        
        cmdLink.expressions.action = '{!invokeDiscovery}';
        
        outPanel.childComponents.add( cmdLink );
      
        return outPanel;
    }
}