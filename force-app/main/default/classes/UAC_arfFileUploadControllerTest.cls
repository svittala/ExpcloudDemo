/**
 * @File Name         : UAC_arfFileUploadControllerTest.cls
 * @Description       : Test Class for UAC_arfFileUploadController LWC
 * @Group             : UAC_arfFileUploadController
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  : 
 * @Last Modified On  : 
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   03-01-2021   Abhisek Pati (Deloitte)   Initial Version
 * 1.1   03-16-2021   Abhisek Pati (Deloitte)   ORRUAC-5469 Added code for validate Email
 * 1.2   06-10-2021   Abhisek Pati (Deloitte)   ORRUAC-5858 Added test coverage
 **/

@isTest(seeAllData = false) public class UAC_arfFileUploadControllerTest {
    
  public
  final static Id ID_RECORD_TYPE_COMPLIANCEFORM =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('Uac_Compliance_Forms')
          .getRecordTypeId();
    /**
   * @description Test Method to upload file from Compliance Community Form
   * @author Abhisek Pati (Deloitte)
   * @return void
   **/
      @isTest static void uploadFilePositiveScenariotest() {
          UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    		objARF.First_Name__c = 'ARFUser';
		    objARF.Last_Name__c = 'SampleUser';
		    objARF.User_Email__c = 'arfacctcreation@arfuserreq.com';
		    objARF.UAC_Status__c = 'Initiate Form Completion Request';          
		    insert objARF;
            
          	ContentVersion tempContentVersion = new ContentVersion();
            tempContentVersion.Title = 'testuploadfile';
            tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
            tempContentVersion.RecordTypeId = ID_RECORD_TYPE_COMPLIANCEFORM;
            tempContentVersion.UAC_documentType__c = 'Privacy 101';
            insert tempContentVersion;

            ContentVersion objContentVersion = [SELECT Id,
            ContentDocumentId,
            Title,
            RecordType.DeveloperName,
            UAC_documentType__c FROM ContentVersion WHERE Id =:tempContentVersion.Id limit 1];
          ContentDocument objContentDoc =
              [Select Id from ContentDocument where id =:objContentVersion.ContentDocumentId limit 1];          
          	Test.startTest();
            Id responseValidate = UAC_arfFileUploadController.validateEmail(objARF.User_Email__c);
            ContentVersion tempConVer = 
                UAC_arfFileUploadController.saveFile(objARF.Id,tempContentVersion.Title,'Test','Privacy 101');
        	Test.stopTest();
            System.assertNotEquals(null, responseValidate);
            System.assertNotEquals(null, tempConVer);
              }
     
     /**
   * @description Test Method to upload file from Compliance Community Form Negative Scenario
   * @author Abhisek Pati (Deloitte)
   * @return void
   **/
      @isTest static void uploadFileNegativeScenariotest() {
          Test.startTest();
          Id responseValidate = UAC_arfFileUploadController.validateEmail(null);
          System.assertEquals(null, responseValidate);
      }
}