global class LightningMFILoginFormController {

    @AuraEnabled
    public static String Serverlogin(String useremail, String startUrl) 
    {
        List<Auth.VerificationMethod> methods = new List<Auth.verificationMethod>();
        // Add verification methods
        //methods.add(Auth.VerificationMethod.Password);
        methods.add(Auth.VerificationMethod.EMAIL);  
        system.debug('able to call thiswith value:'+useremail);   
        Profile p = [select id from profile where name = 'External' Limit 1];
                
        List<user> users = [select name, username, id, email from User where email=:useremail and isActive=true and profileId=:p.Id];
        if(users == null || users.isEmpty() == true)
        {
        	system.debug('Can\'t find a user:'+useremail);   
            return 'error cannot find user';
        }
            
            
        if(users.size() > 1)
        {
        	System.debug( 'Can\'t find a unique user');
            return 'error not unique user';
        }
              
        Id uid = users[0].id;     
        
        try{
            system.debug('going to passwordless login');
            ApexPages.PageReference lgn = Site.passwordLessLogin(uid, methods, startUrl);
            aura.redirect(lgn);
            return 'success';
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }   
}