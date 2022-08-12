public without sharing class MFIController 
{
    String startUrl;
    String description = 'description';
    String userId = UserInfo.getUserId(); 
    public String email {get; set;}
    public String phone {get; set;}
    
    public MFIController()
    {
        startURL = System.currentPageReference().getParameters().get('startURL');
        
        if (startURL == null) startURL = '/';
        
        email = getEmail();
        phone = getPhone();
    }
    
    public boolean getIsAuthenticatorVerified()
    {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasSalesforceAuthenticator FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasSalesforceAuthenticator) 
            return true;
            
        return false;
    }
    
    public boolean getIsU2FVerified()
    {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasU2F FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasU2F) 
            return true;
            
        return false;
    }
    
    public boolean getIsTOTPVerified()
    {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasTOTP FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasTOTP) 
            return true;
            
        return false;
    }
    
    public boolean getIsPhoneVerified()
    {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasUserVerifiedMobileNumber FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasUserVerifiedMobileNumber) 
            return true;
            
        return false;
    }
    
    public boolean getIsEmailVerified()
    {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasUserVerifiedEmailAddress FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasUserVerifiedEmailAddress) 
            return true;   
       
        return false;
    }
    
    public String getEmail()
    {
        User u = [select email from User where id=:userId LIMIT 1];
        
        return u.email;    
    }
    
    public String getPhone()
    {
        User u = [select mobilephone from User where id=:userId LIMIT 1];
        if(u.mobilephone == null)
            return '';
        return u.mobilephone;    
    }
    
    public PageReference registerTOTP() {
        PageReference pr =  System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.TOTP, startUrl);
        pr.setRedirect(true);
        return pr;
    }
    
    public void disconnectTOTP() {
        System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.TOTP);
    }
    
    public void checkTOTP() {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasTOTP FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasTOTP) {
            System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.TOTP, startUrl);
        } else {
            System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.TOTP);
        }
    }
    
    public PageReference registerToopher() {
        return System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR, startUrl);
    }
    
    public void disconnectToopher() {
        System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);
    }
    
    public void checkToopher() {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasSalesforceAuthenticator FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasSalesforceAuthenticator) {
            System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR, startUrl);
        } else {
            System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.SALESFORCE_AUTHENTICATOR);
        }
    }
    
    public PageReference registerU2F() {
        return System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.U2F, startUrl);
    }
    
    public void disconnectU2F() {
        System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.U2F);
    }
    
    public void checkU2F() {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasU2F FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasU2F) {
            System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.U2F, startUrl);
        } else {
            System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.U2F);
        }
    }
    
    public PageReference registerSMS() {
        return System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.SMS, startUrl);
    }
    
    public void disconnectSMS() {
        System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.SMS);
    }    
    
    public void disconnectEmail() {
        System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.EMAIL);
    }
    
    public PageReference registerEmail() {
        return System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.EMAIL, startURL);
    }
    
    public void checkSMS() {
        List<TwoFactorMethodsInfo> methods = [SELECT Id, HasVerifiedMobileNumber FROM TwoFactorMethodsInfo WHERE userid=:userId]; 
        if (methods[0].HasVerifiedMobileNumber) {
            System.UserManagement.registerVerificationMethod(Auth.VerificationMethod.SMS, startUrl);
        } else {
            System.UserManagement.deregisterVerificationMethod(userId, Auth.VerificationMethod.SMS);
        }
    }    
}