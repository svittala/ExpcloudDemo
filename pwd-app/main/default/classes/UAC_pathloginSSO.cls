global without sharing class UAC_pathloginSSO{
    @AuraEnabled(cacheable=true)
    global static UAC_loginSSOUrls__c getRedirectionUrls(){
        List<UAC_loginSSOUrls__c> lsturlCus = UAC_loginSSOUrls__c.getAll().values();
        System.debug('returned custom settings are:' +lsturlCus[0]);
        return lsturlCus[0];
    }
}