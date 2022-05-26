/**
 * @File Name          : UAC_associatedContactTriggerHelperTest.cls
 * @Description        : Test class for trigger helper and handler for UAC_associatedContact__c
 *object.
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/8/2020, 6:40:41 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/8/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_associatedContactTriggerHelperTest {
  static final String STR_ERROR_DUPLICATE_ASSOCIATED_CONTACT =
      Label.UAC_associatedContactSponsorAppDuplicateError;

  static final String RELATION_TO_SPONSOR = 'Grandson';
  static final String STR_A_NUM_ADULT_CONTACT_1 = '1234561';
  static final String STR_A_NUM_ADULT_CONTACT_2 = '1234562';
  static final String STR_A_NUM_ADULT_CONTACT_SPONSOR = '123456';
  static final String STR_A_NUM_UAC = '1234';

  /**
   * @description Method to setup test data
   * @author Sachet Khanal (Deloitte) | 6/8/2020
   * @return void
   **/
  @TestSetup static void setupData() {
    Contact objSponsor =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR)
            .build();
    Contact objAdultContact1 =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT_1)
            .build();
    Contact objAdultContact2 =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT_2)
            .build();
    Contact objUAC = new UAC_testContactBuilder()
                         .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                         .setANumber(STR_A_NUM_UAC)
                         .build();
    insert new List<Contact>{objSponsor, objAdultContact1, objAdultContact2, objUAC};
    // Insert primary sponsor relationship for Sponsor Application case creation
    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objSponsor.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUAC.id;
    insert objAdultContactRelationship;
    // Insert Sponsor Application Case
    Case objSponsorApplicationCase =
        new UAC_testCaseBuilder()
            .setSponsor(objSponsor.Id)
            .setUAC(objUAC.Id)
            .setRelationshipToUAC(objAdultContactRelationship.Id)
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .buildAndSave();
    // Insert Associated Contact for one of the Adult Contact
    UAC_associatedContact__c objAssociatedContact = new UAC_associatedContact__c();
    objAssociatedContact.UAC_contact__c = objAdultContact1.Id;
    objAssociatedContact.UAC_case__c = objSponsorApplicationCase.Id;
    objAssociatedContact.UAC_alternateAdultCaregiver__c = true;
    objAssociatedContact.UAC_relationshipToSponsor__c = RELATION_TO_SPONSOR;
    insert objAssociatedContact;
  }

  /**
   * @description ORRUAC-414: Validate duplicate associated contact record insert throws error
   * @author Sachet Khanal (Deloitte) | 6/8/2020
   * @return void
   **/
  @isTest static void duplicateAssociatedContactInsertShouldThrowError() {
    UAC_associatedContact__c objAssociatedContact =
        getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    objAssociatedContact = objAssociatedContact.clone();
    String actualErrorMessage;
    Test.startTest();
    Database.SaveResult objSaveResult = Database.insert(objAssociatedContact, false);
    if (!objSaveResult.isSuccess()) {
      actualErrorMessage = objSaveResult.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(STR_ERROR_DUPLICATE_ASSOCIATED_CONTACT,
        actualErrorMessage,
        'Test method: duplicateAssociatedContactInsertShouldThrowError() failed.');
  }

  /**
   * @description ORRUAC-414: Validate duplicate associated contact update throws error
   * @author Sachet Khanal (Deloitte) | 6/8/2020
   * @return void
   **/
  @isTest static void duplicateAssociatedContactUpdateShouldThrowError() {
    // Create a 2nd relationship with different adult contact to later update as duplicate
    Set<String> fieldsToQuery = new Set<String>{'Id'};
    Contact objAdultContact1 =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_1, fieldsToQuery);
    Contact objAdultContact2 =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_2, fieldsToQuery);
    UAC_associatedContact__c objAssociatedContact =
        getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1).clone();
    objAssociatedContact.UAC_contact__c = objAdultContact2.Id;
    insert objAssociatedContact;

    String actualErrorMessage;
    Test.startTest();
    objAssociatedContact.UAC_contact__c = objAdultContact1.Id;
    Database.SaveResult objSaveResult = Database.update(objAssociatedContact, false);
    if (!objSaveResult.isSuccess()) {
      actualErrorMessage = objSaveResult.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(STR_ERROR_DUPLICATE_ASSOCIATED_CONTACT,
        actualErrorMessage,
        'Test method: duplicateAssociatedContactUpdateShouldThrowError() failed.');
  }

    /**
   * @description ORRUAC-789: Validate Results of background check and remove Case Association or Delete Background check record
   * @author Karthi Subramanian (Deloitte) | 6/9/2020
   * @return void
   **/
  @isTest static void testValidateResultsUpdateBackGroundChk() {
    UAC_associatedContact__c objAssociatedContact = getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    Id associatedContactId = objAssociatedContact.Id; 
	ID caseId =objAssociatedContact.UAC_case__c;
 	ID contactId = objAssociatedContact.UAC_contact__c;
	//Two background check records one with System Generated another one manual  
    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(contactId, caseId,false,'Appears Clear','FBI Criminal History');
    UAC_backgroundCheck__c objbackGroundChk2 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(contactId, caseId,true);
    String actualErrorMessage;
    Test.startTest();
    Database.DeleteResult objDeleteResult = Database.delete(objAssociatedContact, false);
    if (!objDeleteResult.isSuccess()) {
      actualErrorMessage = objDeleteResult.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(0,[SELECT count() FROM UAC_backgroundCheck__c where UAC_adultContact__c=:contactId and UAC_sponsorApplication__c=:caseId]);
    System.assertEquals(1,[SELECT count() FROM UAC_backgroundCheck__c where UAC_adultContact__c=:contactId]);  
  }
    
  /**
   * @description ORRUAC-789: Update AssociatedContact Flag and remove Case Association or Delete Background check record
   * @author Karthi Subramanian (Deloitte) | 6/9/2020
   * @return void
   **/
  @isTest static void testCheckHouseHoldAdultCareGiverFlagChange() {
    UAC_associatedContact__c objAssociatedContact = getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    Id associatedContactId = objAssociatedContact.Id; 
	ID caseId =objAssociatedContact.UAC_case__c;
 	ID contactId = objAssociatedContact.UAC_contact__c;
	//Two background check records one with System Generated another one manual  
    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(contactId, caseId,false,'Appears Clear','FBI Criminal History');
    UAC_backgroundCheck__c objbackGroundChk2 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(contactId, caseId,true);
    String actualErrorMessage;
    Test.startTest();
    objAssociatedContact.UAC_alternateAdultCaregiver__c=false;
    objAssociatedContact.UAC_supervisionPlanPerson__c=true; 
    Database.SaveResult objSaveResult = Database.update(objAssociatedContact, false);
    if (!objSaveResult.isSuccess()) {
      actualErrorMessage = objSaveResult.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(0,[SELECT count() FROM UAC_backgroundCheck__c where UAC_adultContact__c=:contactId and UAC_sponsorApplication__c=:caseId]);
    System.assertEquals(1,[SELECT count() FROM UAC_backgroundCheck__c where UAC_adultContact__c=:contactId]);  
  }
    
  /**
   * @description Method to get associated contact record for test instance.
   * @author Sachet Khanal (Deloitte) | 6/8/2020
   * @return UAC_associatedContact__c
   **/
  public
  static UAC_associatedContact__c getAssociatedContactByANumber(String strANumber) {
    // clang-format off
    return [
      SELECT
        Id, UAC_contact__c, UAC_case__c, UAC_alternateAdultCaregiver__c,
        UAC_relationshipToSponsor__c
      FROM
        UAC_associatedContact__c
      WHERE
        UAC_contact__r.UAC_a__c =: strANumber
      LIMIT 1
    ];
    // clang-format on
  }
}