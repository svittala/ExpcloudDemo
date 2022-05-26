/**
 * @File Name          : UAC_FileServicesTest.cls
 * @Description        : Test class used for testing UAC_FileServices class functionalities
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_services
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/24/2020, 9:51:53 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_fileServicesTest {

  private
  static final String STR_CLASS_NAME = UAC_fileServicesTest.class.getName();

  /**
   * @description Test Setup method to generate test data
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return void
   **/
  @TestSetup static void setupData() {
    Contact objContact = new UAC_testContactBuilder().buildAndSave();
    ContentVersion objContentVersion = new ContentVersion();
    objContentVersion.FirstPublishLocationId = objContact.Id;
    objContentVersion.Title = STR_CLASS_NAME;
    objContentVersion.PathOnClient = STR_CLASS_NAME + '.txt';
    objContentVersion.VersionData = Blob.valueOf(STR_CLASS_NAME);
    objContentVersion.RecordTypeId =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(Label.UAC_contentVersionRecordTypeApiNameOther)
            .getRecordTypeId();
    objContentVersion.UAC_documentType__c = Label.UAC_contentVersionDocumentTypeOther;
    insert objContentVersion;
  }

  /**
   * @description Method to test generation of attachments and querying different file types
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return void
   **/
  @isTest static void generateSObjectFilesShouldCreateAttachment() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_jsonFileMap__c'};
    Contact objContact = UAC_testContactBuilder.getContact(setFieldsToQuery);
    System.assertEquals(null,
        objContact.UAC_jsonFileMap__c,
        'Error: File Map not null. Test Method: generateSObjectFilesShouldCreateAttachment() failed.');
    UAC_fileWrapper objFileWrapper = new UAC_fileWrapper();
    objFileWrapper.idParent = objContact.Id;
    objFileWrapper.strFileName = 'Test.txt';
    objFileWrapper.strContentType = 'text/plain';
    objFileWrapper.strBase64Data = EncodingUtil.base64Encode(Blob.valueOf('Test'));
    Test.startTest();
    // Query full list of File Type Settings mdt
    List<UAC_fileTypeSetting__mdt> lstFileTypeSettings = UAC_FileServices.getFileTypeSettings(null);
    // Generate attachment from FileWrapper
    objFileWrapper.strFileType = lstFileTypeSettings[0].Label;
    UAC_FileServices.generateSObjectFiles(
        objContact.Id, new List<UAC_fileWrapper>{objFileWrapper}, true);
    // Get new list of files from Contact object
    List<UAC_fileWrapper> lstFileWrapper = UAC_FileServices.getFilesFromSObject(
        objContact.Id, new Set<String>{lstFileTypeSettings[0].Label});
    Test.stopTest();
    System.assert(!lstFileWrapper.isEmpty(),
        'Error: Contact object File Wrapper list is empty. Test Method: generateSObjectFilesShouldCreateAttachment() failed.');
  }

  @isTest static void getFilesFromSObjectShouldReturnRelatedFiles() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objContact = UAC_testContactBuilder.getContact(setFieldsToQuery);
    Test.startTest();
    List<ContentVersion> lstContentVersion = UAC_fileServices.getFilesFromSObject(objContact.Id, '');
    Test.stopTest();
    System.assert(!lstContentVersion.isEmpty(),
        'Test method: getFilesFromSObjectShouldReturnRelatedFiles() failed');
    System.assertEquals(STR_CLASS_NAME,
        lstContentVersion[0].UAC_originalTitle__c,
        'Test method: getFileListShouldReturnRelatedFiles() failed.');
  }

  @istest static void getContentversionlink(){
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_jsonFileMap__c'};
    Contact objContact = UAC_testContactBuilder.getContact(setFieldsToQuery);        
    ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.recordtypeid = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('UAC_legalDocument').getRecordTypeId();
    cv.uac_documenttype__c ='DHS Document (NTA)' ;     
    cv.IsMajorVersion = true;
    Insert cv;

    //Get Content Documents
    Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

    //Create ContentDocumentLink
    Test.startTest();
    ContentDocumentLink cdl = New ContentDocumentLink();
    cdl.LinkedEntityId = objContact.Id;
    cdl.ContentDocumentId = conDocId;
    cdl.shareType = 'V';
    Insert cdl;
    Test.stopTest();
    List<ContentDocumentLink> cd2 = [Select Id from ContentDocumentLink where Id =:cdl.Id];
    System.assertNotEquals(null,cd2[0].Id);
  }
  /**
   * @description Tests emptying out content links on Contact record after deletion
   * @author James Qian (Deloitte) | 9/21/2020
   * @return void
   **/
  @isTest static void deletingFileShouldEmptyContactLinks() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_jsonFileMap__c'};
    Contact objContact = UAC_testContactBuilder.getContact(setFieldsToQuery);
    UAC_fileWrapper objFileWrapper = new UAC_fileWrapper();
    objFileWrapper.idParent = objContact.Id;
    objFileWrapper.strFileName = 'Test.txt';
    objFileWrapper.strContentType = 'text/plain';
    objFileWrapper.strBase64Data = EncodingUtil.base64Encode(Blob.valueOf('Test'));
    Test.startTest();
    List<UAC_fileTypeSetting__mdt> lstFileTypeSettings = UAC_FileServices.getFileTypeSettings(null);
    objFileWrapper.strFileType = lstFileTypeSettings[0].Label;
    UAC_FileServices.generateSObjectFiles(
        objContact.Id, new List<UAC_fileWrapper>{objFileWrapper}, true);
    List<ContentDocument> listToDelete = new List<ContentDocument>();
    for (ContentDocumentLink linkCurrent :
        [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:objContact.Id]) {
      listToDelete.add(new ContentDocument(Id = linkCurrent.ContentDocumentId));
    }
    delete listToDelete;
    Test.stopTest();
    Contact objContactQueried = UAC_testContactBuilder.getContact(setFieldsToQuery);
    System.assertEquals(null, objContactQueried.UAC_jsonFileMap__c);
  }
}