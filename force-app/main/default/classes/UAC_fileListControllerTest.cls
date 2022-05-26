/**
 * @File Name          : UAC_fileListControllerTest.cls
 * @Description        : Test class for UAC_fileListController
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_fileList
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/24/2020, 9:51:04 AM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/18/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_fileListControllerTest {

  private
  static final String STR_CLASS_NAME = UAC_fileListControllerTest.class.getName();

  /**
   * @description Test Setup method to generate test data
   * @author Sachet Khanal (Deloitte) | 6/18/2020
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
	 ContentVersion objContentVersion2 = new ContentVersion();
    objContentVersion2.FirstPublishLocationId = objContact.Id;
    objContentVersion2.Title = STR_CLASS_NAME;
    objContentVersion2.PathOnClient = STR_CLASS_NAME + '.txt';
    objContentVersion2.VersionData = Blob.valueOf(STR_CLASS_NAME);
    objContentVersion2.RecordTypeId =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(Label.UAC_contentVersionRecordTypeApiNameOther)
            .getRecordTypeId();
    objContentVersion2.UAC_documentType__c = Label.UAC_contentVersionDocumentTypeOther;  
      insert objContentVersion2;
  }

  @isTest static void getFieldListShouldReturnFieldInformation() {
    Test.startTest();
    List<UAC_fileListController.UAC_fieldInfo> objFieldInfo = UAC_fileListController.getFieldList();
    Test.stopTest();
    System.assert(
        !objFieldInfo.isEmpty(), 'Test method: getFieldListShouldReturnFieldInformation() failed.');
  }

  @isTest static void getFileListShouldReturnRelatedFiles() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objContact = UAC_testContactBuilder.getContact(setFieldsToQuery);
    Test.startTest();
    List<ContentVersion> lstContentVersion = UAC_fileListController.getFileList(objContact.Id, '');
    Test.stopTest();
    System.assert(
        !lstContentVersion.isEmpty(), 'Test method: getFileListShouldReturnRelatedFiles() failed.');
    System.assertEquals(STR_CLASS_NAME,
        lstContentVersion[0].UAC_originalTitle__c,
        'Test method: getFileListShouldReturnRelatedFiles() failed.');
  }
  @isTest static void getlegalFileListShouldReturnRelatedFiles() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objContact = UAC_testContactBuilder.getContact(setFieldsToQuery);
    Test.startTest();
    List<ContentVersion> lstContentVersion = UAC_fileListController.getLegalFileList(objContact.Id, '');
    system.assertEquals(lstContentVersion.size(), 1);
    Test.stopTest();    
  }    
}