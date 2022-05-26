/**
 * @File Name          : UAC_adultContactRealtionshipHelperTest.cls
 * @Description        : Test class for UAC_adultContactRelationship.trigger,
 *UAC_adultContactRelationshipHandler.cls, UAC_adultContactRelationshipHelper.cls
 * @Author             : Priyanka Bolla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/1/2020, 5:27:23 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/12/2020   Priyanka Bolla (Deloitte)     Initial Version
 * 1.1    5/13/2020   Rahul Roy (Deloitte)          Added method to test Declined Date population
 * 1.2    5/18/2020   Sachet Khanal (Deloitte)      ORRUAC-265: Test clearing Explain Relationship
 * 1.3    6/1/2020    Sachet Khanal (Deloitte)      ORRUAC-414 Adult Contact Rel duplicate test
 **/
@isTest(seeAllData = false) public with sharing class UAC_adultContactRealtionshipHelperTest {
  // Constants defined for Class
  static final String STR_ERROR_MORE_THAN_ONE_PRIMARY_SPONSOR = Label.UAC_onePrimarySponsorError;
  static final String STR_ERROR_DUPLICATE_ADULT_CONTACT_RELATIONSHIP =
      Label.UAC_adultContactRelationshipDuplicateError;

  static final String STR_A_NUM_ADULT_CONTACT = '123456';
  static final String STR_A_NUM_ADULT_CONTACT_2 = '1234567';
  static final String STR_A_NUM_UAC = '1234';

  /* @author       Priyanka Bolla
   * @description  Creates the data required to run the test method
   * @param        N/A
   * @return       N/A
   */
  @testSetup static void setupMethod() {
    list<contact> lstContacts = new list<contact>();
    list<UAC_adultContactRelationship__c> lstAdultContRelationshp =
        new list<UAC_adultContactRelationship__c>();
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT)
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
    insert new List<Contact>{objAdultContact, objAdultContact2, objUAC};

    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Potential Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUAC.id;
    insert objAdultContactRelationship;
  }

  /**
   * @author      Priyanka
   * @description  Test insert / update resulting in 2nd primary sponsor relationship throws error
   * @param        N/A
   * @return       N/A
   */
  @isTest static void secondPrimarySponsorShouldThrowError() {
    // Query and update the 1st relationship to Primary
    UAC_adultContactRelationship__c objAdultContactRelationship = getAdultContactRelationship();
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    update objAdultContactRelationship;

    // Query UAC and 2nd adult contact for 2nd primary relationship
    Set<String> fieldsToQuery = new Set<String>{'Id'};
    Contact objUAC = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, fieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_2, fieldsToQuery);
    objAdultContactRelationship = new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUAC.id;
    Test.startTest();

    // Validate 2nd primary sponsor throws error on insert
    try {
      insert objAdultContactRelationship;
    } catch (Exception e) {
      Boolean expectedExceptionThrown =
          e.getMessage().contains(STR_ERROR_MORE_THAN_ONE_PRIMARY_SPONSOR) ? true : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }

    // Insert with 2nd relationship as Potential Sponsor
    objAdultContactRelationship.UAC_relationshipType__c = 'Potential Sponsor';
    insert objAdultContactRelationship;

    // Validate 2nd primary sponsor throws error on update
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    try {
      update objAdultContactRelationship;
    } catch (Exception e) {
      Boolean expectedExceptionThrown =
          e.getMessage().contains(STR_ERROR_MORE_THAN_ONE_PRIMARY_SPONSOR) ? true : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }
    Test.stopTest();
  }

  /**
   * @author       Rahul Roy
   * @description  test the Update of second Primary Sponsor where Type equals Declined
   * @param        N/A
   * @return       N/A
   */
  @isTest static void updatePotentialSponsorDeclined() {
    Test.startTest();
    UAC_adultContactRelationship__c adultContactRelationship = getAdultContactRelationship();
    adultContactRelationship.UAC_relationshipType__c = Label.UAC_typeDeclined;
    adultContactRelationship.UAC_declinedReason__c = 'Immigration Fears';
    adultContactRelationship.UAC_declinedReasonNotes__c = 'Declined Reason Notes';
    try {
      update adultContactRelationship;
    } catch (Exception e) {
      System.AssertNotEquals(e.getMessage(), Null);
    }
    adultContactRelationship = getAdultContactRelationship();
    Date modifiedDate = adultContactRelationship.UAC_declinedDate__c.Date();
    System.AssertEquals(modifiedDate, system.today());
    Test.stopTest();
  }

  /**
   * @description ORRUAC-265: Unit testing for clearing out Explain Relationship to UAC
   * @author Sachet Khanal (Deloitte) | 5/18/2020
   * @return void
   **/
  @isTest static void updateRelationToExplainNotRequiredShouldClearExplainRelationship() {
    // Prepare set of values requiring Explain Relationship to UAC
    Set<String> setExplainRequiredRelationship = new Set<String>{
        Label.UAC_relationshipToUACOtherDistantRelative, Label.UAC_relationshipToUACUnrelated};

    // Query an Adult Contact Relationship that does not require Explain Relationship to UAC
    // clang-format off
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      SELECT
        Id, UAC_explainRelationshipToUAC__c
      FROM
        UAC_adultContactRelationship__c
      WHERE
        UAC_relationshipToUAC__c NOT IN :setExplainRequiredRelationship
      LIMIT 1
    ];
    // clang-format on
    Test.startTest();
    // Try to set the Explain Relationship to UAC
    objAdultContactRelationship.UAC_explainRelationshipToUAC__c = 'Test';
    update objAdultContactRelationship;
    Test.stopTest();
    // Query and verify Explain Relationship to UAC is automatically cleared
    objAdultContactRelationship =
        [SELECT Id, UAC_explainRelationshipToUAC__c FROM UAC_adultContactRelationship__c WHERE Id
          =:objAdultContactRelationship.Id];
    System.assertEquals(null,
        objAdultContactRelationship.UAC_explainRelationshipToUAC__c,
        'Explain Relationship to UAC did not clear out. Test method: '
            + 'updateRelationToExplainNotRequiredShouldClearExplainRelationship() failed');
  }

  /**
   * @description ORRUAC-414: Validate duplicate adult contact relationship throws error
   * @author Sachet Khanal (Deloitte) | 5/18/2020
   * @return void
   **/
  @isTest static void duplicateAdultContactRelationshipInsertShouldThrowError() {
    UAC_adultContactRelationship__c objAdultContactRelationship = getAdultContactRelationship();
    objAdultContactRelationship = objAdultContactRelationship.clone();
    String actualErrorMessage;
    Test.startTest();
    Database.SaveResult objSaveResult = Database.insert(objAdultContactRelationship, false);
    if (!objSaveResult.isSuccess()) {
      actualErrorMessage = objSaveResult.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(STR_ERROR_DUPLICATE_ADULT_CONTACT_RELATIONSHIP,
        actualErrorMessage,
        'Test method: duplicateAdultContactRelationshipShouldThrowError() failed.');
  }

  /**
   * @description ORRUAC-414: Validate duplicate adult contact relationship throws error
   * @author Sachet Khanal (Deloitte) | 5/18/2020
   * @return void
   **/
  @isTest static void duplicateAdultContactRelationshipUpdateShouldThrowError() {
    // Create a 2nd relationship with different adult contact to later update as duplicate
    Set<String> fieldsToQuery = new Set<String>{'Id'};
    Contact objUAC = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, fieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT, fieldsToQuery);
    Contact objAdultContact2 =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_2, fieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact2.Id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Potential Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUAC.Id;
    insert objAdultContactRelationship;

    String actualErrorMessage;
    Test.startTest();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact.Id;
    Database.SaveResult objSaveResult = Database.update(objAdultContactRelationship, false);
    if (!objSaveResult.isSuccess()) {
      actualErrorMessage = objSaveResult.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(STR_ERROR_DUPLICATE_ADULT_CONTACT_RELATIONSHIP,
        actualErrorMessage,
        'Test method: duplicateAdultContactRelationshipShouldThrowError() failed.');
  }

  /**
   * @description Method to return Adult Contact Relationship record created in test instance
   * @author Sachet Khanal (Deloitte) | 6/1/2020
   * @return void
   **/
  public
  static UAC_adultContactRelationship__c getAdultContactRelationship() {
    // clang-format off
    return [
      SELECT
        Id, UAC_uacLookup__c, UAC_adultContact__c, UAC_relationshipType__c, UAC_declinedDate__c,
        UAC_relationshipToUAC__c
      FROM
        UAC_adultContactRelationship__c
      LIMIT 1
    ];
    // clang-format on
  }

   /**
   * @author       Priyanka Bolla
   * @description  test the Update ofDeclined Reason,Declined Reason Notes ,
   * @param        N/A
   * @return       N/A
   */
  @isTest static void updateDeclinedFields() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
      Contact objAdult = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT, setFieldsToQuery);
      Contact objUAC =  UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, setFieldsToQuery);  
      UAC_adultContactRelationship__c objAdultContactRelationship = [select id,UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c = :objAdult.Id and UAC_relationshipType__c = 'Potential Sponsor' and UAC_uacLookup__c = :objUAC.Id];
   
    Test.startTest();
 
    objAdultContactRelationship.UAC_declinedReason__c = null;
    objAdultContactRelationship.UAC_declinedReasonNotes__c = null;
    objAdultContactRelationship.UAC_declinedDate__c = null;
    try {
      update objAdultContactRelationship;
    } catch (Exception e) {
      System.AssertNotEquals(e.getMessage(), Null);
    }
    
    System.AssertEquals( objAdultContactRelationship.UAC_declinedDate__c, null);
    System.AssertEquals(objAdultContactRelationship.UAC_declinedReason__c, null);
    System.assertEquals(objAdultContactRelationship.UAC_declinedReasonNotes__c,null);
    Test.stopTest();
  }
}