/**
 * @File Name          : UAC_fileApexDataTest.cls
 * @Description        : Test class for UAC_fileApexData
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_docGenExternalApexData
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/26/2020, 2:16:41 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/26/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_fileApexDataTest {

  private
  final static String STR_CLASS_NAME = UAC_fileApexData.class.getName();
  private
  static final String STR_ADULT_CONTACT_A_NUMBER = '987654321';
  private
  static final String STR_ASSOCIATED_CONTACT_A_NUMBER = '987654322';
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_FILE_APEX_DATA_OBJECT_NAME = 'UAC_fileApexData';

  @TestSetup static void setupData() {
    // Create an UAC contact
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .build();
    // Create an Adult Contact
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setANumber(STR_ADULT_CONTACT_A_NUMBER)
            .setEmail(STR_ADULT_CONTACT_A_NUMBER + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .build();
    // Create an Adult Contact for Associated Contact
    Contact objAssociatedAdultContact =
        new UAC_testContactBuilder()
            .setANumber(STR_ASSOCIATED_CONTACT_A_NUMBER)
            .setEmail(STR_ASSOCIATED_CONTACT_A_NUMBER + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .build();
    insert new List<Contact>{objUACContact, objAdultContact, objAssociatedAdultContact};
    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c(UAC_adultContact__c = objAdultContact.Id,
            UAC_relationshipType__c = 'Primary Sponsor',
            UAC_relationshipToUAC__c = 'Father',
            UAC_uacLookup__c = objUACContact.Id);
    insert objAdultContactRelationship;
    Case objSponsorApp =
        new UAC_testCaseBuilder()
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .setRelationshipToUAC(objAdultContactRelationship.Id)
            .setUAC(objUACContact.Id)
            .setSponsor(objAdultContact.Id)
            .buildAndSave();
    UAC_associatedContact__c objAssociatedContact = new UAC_associatedContact__c();
    objAssociatedContact.UAC_contact__c = objAssociatedAdultContact.Id;
    objAssociatedContact.UAC_case__c = objSponsorApp.Id;
    objAssociatedContact.UAC_alternateAdultCaregiver__c = true;
    objAssociatedContact.UAC_relationshipToSponsor__c = 'Brother';
    insert objAssociatedContact;
    ContentVersion objSponsorFile = new ContentVersion();
    objSponsorFile.FirstPublishLocationId = objSponsorApp.Id;
    objSponsorFile.UAC_individual__c = objAssociatedAdultContact.Id;
    objSponsorFile.Title = STR_CLASS_NAME;
    objSponsorFile.PathOnClient = STR_CLASS_NAME + '.txt';
    objSponsorFile.VersionData = Blob.valueOf(STR_CLASS_NAME);
    objSponsorFile.RecordTypeId =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(Label.UAC_contentVersionRecordTypeApiNameOther)
            .getRecordTypeId();
    objSponsorFile.UAC_documentType__c = Label.UAC_contentVersionDocumentTypeOther;
    ContentVersion objAssociatedContactFile = objSponsorFile.clone();
    objAssociatedContactFile.UAC_individual__c = objAssociatedAdultContact.Id;
    insert new List<ContentVersion>{objSponsorFile, objAssociatedContactFile};
  }

  @isTest static void apexDataQueryShouldReturnFiles() {
    Case objSponsorApp =
        [SELECT Id FROM Case WHERE UAC_sponsor__r.UAC_a__c =:STR_ADULT_CONTACT_A_NUMBER LIMIT 1];
    UAC_fileApexData objFileApexData = new UAC_fileApexData();
    Test.startTest();
    Set<String> setGlobalDescribe = objFileApexData.getGlobalDescribe();
    System.assertEquals(1, setGlobalDescribe.size());

    System.assert(objFileApexData.getChildRelationships(STR_FILE_APEX_DATA_OBJECT_NAME).isEmpty());

    List<Loop.ExternalData.DataObject> lstDataObject =
        objFileApexData.describeObjects(new List<String>(setGlobalDescribe));
    System.assertEquals(1, lstDataObject.size());
    for (Loop.ExternalData.DataObject objDataObject : lstDataObject) {
      System.assert(!objDataObject.fields.isEmpty());
    }

    Loop.ExternalData.QueryRequestInfo objRequestInfo = new Loop.ExternalData.QueryRequestInfo();
    objRequestInfo.RecordId = objSponsorApp.Id;

    Loop.ExternalData.Relationship objRelationship = new Loop.ExternalData.Relationship();
    objRelationship.Name = STR_FILE_APEX_DATA_OBJECT_NAME;

    objRequestInfo.Relationships = new List<Loop.ExternalData.Relationship>{objRelationship};

    Loop.ExternalData.QueryResultSet objQueryResultSet = objFileApexData.query(objRequestInfo);
    System.assertEquals(1, objQueryResultSet.results.size());

    for (Loop.ExternalData.QueryResult objQueryResult : objQueryResultSet.results) {
      System.debug(objQueryResult.rows);
      System.assertEquals(2, objQueryResult.rows.size());
    }
    Test.stopTest();
  }
}