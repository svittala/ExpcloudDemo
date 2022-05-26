/**
 * @File Name          : UAC_contentDocumentHelperTest.cls
 * @Description        :
 * @Author             : Piyush(Deloitte)
 * @Group              :
 * @Modification Log   :
 * Ver       Date       Author      	  Modification
 * 1.0    7/22/2020   Piyush(Deloitte)   Initial Version
 **/

@isTest(seeAllData = false) 
public class UAC_contentDocumentHelperTest {

  private static final String STR_ADULT_CONTACT_A_NUMBER = '987654321';
  private static final String STR_UAC_CONTACT_A_NUMBER = '123456789'; 
  private static Contact objUACContact;
  private static Contact objAdultContact;  

  public
  final static Id ID_RECORD_TYPE_HSPRSDOC =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('UAC_hsPrsDocumentsRecType')
          .getRecordTypeId();

  /**
   * @author      Piyush
   * @description  Test delete of content document
   * @param        N/A
   * @return       N/A
   */
  @isTest static void deleteContentVersion() {
    Id idHSPRSDocRecType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('UAC_hsPrsDocumentsRecType').getRecordTypeId();
    objAdultContact =
        new UAC_testContactBuilder()
            .setANumber(STR_ADULT_CONTACT_A_NUMBER)
            .setLastName(STR_ADULT_CONTACT_A_NUMBER)
            .setEmail(STR_ADULT_CONTACT_A_NUMBER + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .build();
            
    objUACContact = new UAC_testContactBuilder()
            .setANumber(STR_UAC_CONTACT_A_NUMBER)
            .setLastName(STR_UAC_CONTACT_A_NUMBER)
            .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
            .build();

    List<Contact> listContactsToInsert = new List<Contact>{objUACContact, objAdultContact};                
    insert listContactsToInsert;

    Case objReleaseRequestCase = new UAC_testCaseBuilder().setUAC(objUACContact.Id).build();
    objReleaseRequestCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.UAC_caseRecordTypeReleaseRequest).getRecordTypeId();
    objReleaseRequestCase.status = 'CM Initiated';
    objReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_cfsName__c  = userinfo.getuserid();
    objReleaseRequestCase.UAC_ffsName__c  = userinfo.getuserid();
    objReleaseRequestCase.UAC_leadCaseManager__c  = userinfo.getuserid();
    objReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_remandForFurtherInformation__c = 'Yes';
    objReleaseRequestCase.UAC_orrComment__c = 'Test1';      
    insert objReleaseRequestCase;

    Case objHSPRSCase = new UAC_testCaseBuilder().setStatus('HS/PRS Referral Initiation').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
                        .setUAC(objUACContact.id).build();

    objHSPRSCase.UAC_hsPrsQueue__c = 'PRS';
    objHSPRSCase.Type = 'PRS -Only';
    objHSPRSCase.UAC_techHsPrsClosedDateTime__c = System.now().addDays(-120);
    insert objHSPRSCase; 
    
    objHSPRSCase.Status = 'Closed';
    objHSPRSCase.UAC_hsPrsReasonForClosure__c = 'UC Ran Away';
    update objHSPRSCase;

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'testuploadfile';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = idHSPRSDocRecType;
    tempContentVersion.UAC_documentType__c = 'Addendum';
    insert tempContentVersion;

    ContentVersion objContentVersion = [SELECT Id,ContentDocumentId,Title,RecordType.DeveloperName,UAC_documentType__c FROM ContentVersion 
                                        WHERE Id =:tempContentVersion.Id limit 1];
    ContentDocument objContentDoc = [Select Id from ContentDocument where id =:objContentVersion.ContentDocumentId limit 1];
    ContentDocumentLink objcdl = new ContentDocumentLink();
    objcdl.LinkedEntityId = objHSPRSCase.Id;
    objcdl.ContentDocumentId = objContentDoc.Id;
    insert objcdl;
    //ContentDocumentLink objConDocLnk = [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId =:objContentDoc.Id];
    System.debug('@@ associated case is' +objcdl.LinkedEntityId);
    //objConDocLnk.LinkedEntityId = objHSPRSCase.Id;
    //update objConDocLnk;


    Test.startTest();
    delete objContentDoc;
    List<ContentDocument> lstConDoc = [Select Id from ContentDocument where id =:objContentVersion.ContentDocumentId];
    System.assertequals(0,lstConDoc.size());
    Test.stopTest();
  }

  /**
   * @author       James Qian (Deloitte)
   * @description  Test delete of content document profile picture
   * @param        N/A
   * @return       N/A
   */
  @isTest static void deleteContentDocumentForProfilePicture() {
    Id idHSPRSDocRecType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                               .get('UAC_hsPrsDocumentsRecType')
                               .getRecordTypeId();
    objUACContact = new UAC_testContactBuilder()
                        .setANumber(STR_UAC_CONTACT_A_NUMBER)
                        .setLastName(STR_UAC_CONTACT_A_NUMBER)
                        .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                        .buildAndSave();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'testuploadfile';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = idHSPRSDocRecType;
    tempContentVersion.UAC_documentType__c = 'Addendum';
    insert tempContentVersion;

    ContentVersion objContentVersion = [SELECT Id,
      ContentDocumentId,
      Title,
      RecordType.DeveloperName,
      UAC_documentType__c FROM ContentVersion WHERE Id =:tempContentVersion.Id limit 1];
    ContentDocumentLink objcdl = new ContentDocumentLink();
    objcdl.LinkedEntityId = objUACContact.Id;
    objcdl.ContentDocumentId = objContentVersion.ContentDocumentId;
    insert objcdl;
    update new Contact(Id = objUACContact.Id, UAC_jsonFileMap__c = tempContentVersion.Id);
    Test.startTest();
    delete new ContentDocument(Id = objContentVersion.ContentDocumentId);
    Test.stopTest();
    Contact contactForAssertion =
        [SELECT Id, UAC_jsonFileMap__c from Contact where id =:objUACContact.Id];
    System.assertequals(null, contactForAssertion.UAC_jsonFileMap__c);
  }
}