/**
 * @Description        : Test class for UC_objectNameFromRecordIdUtility class
 * @Author             : Satish(Deloitte) 
 * @userStory          : Data Integration Audit Framework
 * @Modification Log   : 10-29-2021 draft
 **/

@isTest(seeAllData = false)
public class UC_objectNameFromRecordIdUtilityTest {
    private static final String STR_A_NUM_UAC = '123456';
    @TestSetup static void setupData() {
        Contact objContact = new Contact(FirstName ='TestFirstName',
        LastName = 'TestLastName',
        Email = 'Testemail@test.com',
        Phone = '1111111111');

        Insert objContact;
    }
    
    @isTest static void testGetMethod() {
        String conId = [SELECT Id FROM Contact Limit 1].Id;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/checkobjectAPIname/'+conId;       
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String objectName = UC_objectNameFromRecordIdUtility.objectNameFromIdinURL();
        System.assertEquals('Contact', objectName);
        Test.stopTest();
    }
    @isTest static void testPostMethod() {
        String conId = [SELECT Id FROM Contact Limit 1].Id;
        UC_objectNameFromRecordIdUtility.objectIdDetails objectIdReq = new UC_objectNameFromRecordIdUtility.objectIdDetails();
        objectIdReq.IdStr = conId;
        String JsonMsg=JSON.serialize(objectIdReq);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JsonMsg);
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/checkobjectAPIname/';       
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String objectName = UC_objectNameFromRecordIdUtility.objectNameFromIdPost();
        System.assertEquals('Contact', objectName);
        Test.stopTest();
    }
    
    @isTest static void testInvalidIds() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/checkobjectAPIname/'+'invalidid';       
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String objectName = UC_objectNameFromRecordIdUtility.objectNameFromIdinURL();
        System.assertEquals('invalid id', objectName);
        Test.stopTest();
    }
    
    @isTest static void testInvalidIdPost() {
        UC_objectNameFromRecordIdUtility.objectIdDetails objectIdReq = new UC_objectNameFromRecordIdUtility.objectIdDetails();
        objectIdReq.IdStr = 'invalidid';
        String JsonMsg=JSON.serialize(objectIdReq);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JsonMsg);
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/checkobjectAPIname/';       
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        String objectName = UC_objectNameFromRecordIdUtility.objectNameFromIdPost();
        System.assertEquals('invalid id', objectName);
        Test.stopTest();
    }
}