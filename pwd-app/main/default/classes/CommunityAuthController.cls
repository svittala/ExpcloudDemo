global without sharing class CommunityAuthController {
    global CommunityAuthController() {

    }

    @AuraEnabled
    global static string findContact(string email) {
        string returnValue;
        
        try {
            returnValue = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1].id;
        }
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return returnValue;
    }

    @AuraEnabled
    global static string findUser(string contactId) {
        string returnValue;
        try {
            returnValue = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1].id;
        }
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return returnValue;
    }

    @AuraEnabled
    global static boolean verifyEmail(string userId) {
        boolean returnValue = false;
        TwoFactorMethodsInfo tf = [SELECT id, userid, hasuserverifiedemailaddress, hasuserverifiedmobilenumber 
                                    FROM TwoFactorMethodsInfo where userid =:userid];
        
        if (!tf.hasuserverifiedemailaddress){
            id networkid = Network.getNetworkId();
            id emailTemplateid = '00X3S000000Y3eB';
            string startURL = '/s/login';
            boolean flag = system.UserManagement.sendAsyncEmailConfirmation(userId, emailTemplateId, networkId, startURL);
        }
        else {
            returnValue = true;
        }
        return returnValue;
    }

    @AuraEnabled
    global static string passwordLessLogin(Id userId){
        List<Auth.VerificationMethod> methods = new list<Auth.VerificationMethod>();
        string returnValue = null;

        system.debug('siteType = ' + Site.getSiteType());
        system.debug('siteId = ' + Site.getSiteId());
        system.debug('pathPrefix = ' + Site.getPathPrefix());
        try {
            String startUrl = 'https://ssodev-acf-orr.cs133.force.com/discovery/s/';
            methods.add(Auth.VerificationMethod.EMAIL);
            ApexPages.PageReference pageRef = Site.passwordlessLogin(userId, methods, startUrl);
            system.debug('pageRef = ' + pageRef);
            if(pageRef != null) returnValue = pageRef.getUrl();
            system.debug('returnValue = ' + returnValue);
        } 
        catch (Exception e) {
            system.debug('e.getMessagelogin + ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return returnValue;
    }
}