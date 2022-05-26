@isTest public class UAC_pathloginSSOTest {
    @TestSetup static void setupData() {
        UAC_loginSSOUrls__c cst = new UAC_loginSSOUrls__c();
        cst.Name = 'testUrl';
        cst.UAC_orgEnvironment__c = 'testOrg';
        cst.UAC_pathLoginInternalURL__c = 'test Int Url';
        cst.UAC_pathLoginExternalURL__c = 'test Ext Url';
        cst.UC_pathLoginCommunityURL__c = 'test comm Url';
        insert cst;
    }
    @isTest static void testgetRedirectionUrls(){
        Test.startTest();
        UAC_loginSSOUrls__c cstSSO = UAC_pathloginSSO.getRedirectionUrls();
        Test.stopTest();
        System.assert(cstSSO != null);
    }
    
}