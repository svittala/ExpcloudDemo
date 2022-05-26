/**
 * @File Name          : UAC_apprehendedRelationshipTriggerTest.cls
 * @Description        : Provides test class coverage for Apprehended Relationship
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : James Qian (Deloitte)
 * @Last Modified On   : 5/15/2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/13/2020   James Qian (Deloitte)     Initial Implementation.
 **/
@isTest(seeAllData = false) public without sharing class UAC_apprehendedRelationshipTriggerTest {
  private
  static final String STRING_A_NUMBER_PRIMARY = '1111111111';
  private
  static final String STRING_A_NUMBER_SECONDARY = '2222222222';
  private
  static final String STRING_A_NUMBER_TERTIARY = '3333333333';
  private
  static final String STRING_MALE = 'Male';
  private
  static final String UAC_RELATIONSHIP_RECORD_TYPE = 'Apprehended UC';
  private
  static final String UAC_RELATIONSHIP_API_NAME = 'UAC_apprehendedRelationship__c';
  private
  static final String RELATIONSHIP_BROTHER = 'Brother';
  private
  static final String RELATIONSHIP_SISTER = 'Sister';
  private
  static final String RELATIONSHIP_COUSIN = 'First Cousin';
  private
  static final String ASSERT_POSITIVE_CREATE =
      'A reciprocal relationship should have been created with the proper relationship type.';
  private
  static final String ASSERT_POSITIVE_EXISTING =
      'Another relationship should have been created for the existing relationships of the related UAC.';
  private
  static final String ASSERT_POSITIVE_UPDATE =
      'A reciprocal relationship should have been updated with the proper relationship type.';
  private
  static final String ASSERT_POSITIVE_DELETE =
      'The reciprocal relationship should have been deleted.';

  /**
   * @description Test Setup method to generate test data
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @TestSetup static void setupTestData() {
    List<Contact> listUAC = new List<Contact>();
    listUAC.add(new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).build());
    listUAC.add(new UAC_TestContactBuilder()
                    .setANumber(STRING_A_NUMBER_SECONDARY)
                    .setGender(STRING_MALE)
                    .build());
    listUAC.add(new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_TERTIARY).build());
    insert listUAC;
  }

  /**
   * @description Tests for positive scenarios of linking relationships to referrals.
   * @author James Qian (Deloitte) | 10/20/2020
   * @return void
   **/
  @isTest static void relatingReferralShouldPopulateLookupFields() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());
    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(contactPrimary.id)
            .buildAndSave();

    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.startTest();
    newRelationship.UAC_entry__c = objUACReferralCase.Id;
    update newRelationship;
    Test.stopTest();
    List<UAC_apprehendedRelationship__c> listReciprocalForAssert =
        getApprehendedRelationship(contactPrimary.Id, contactSecondary.Id);
    System.assertEquals(objUACReferralCase.Id, listReciprocalForAssert[0].UAC_referral1__c);
  }

  /**
   * @description Tests for positive scenarios of reciprocal creation.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void creatingRelationshipShouldCreateReciprocal() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());
    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    Test.startTest();
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.stopTest();
    List<UAC_apprehendedRelationship__c> listReciprocalForAssert =
        getApprehendedRelationship(contactSecondary.Id, contactPrimary.Id);
    System.assertEquals(1, listReciprocalForAssert.size(), ASSERT_POSITIVE_CREATE);
    System.assertEquals(RELATIONSHIP_SISTER,
        listReciprocalForAssert[0].UAC_relationshipToUAC__c,
        ASSERT_POSITIVE_CREATE);
    System.assertEquals(true, listReciprocalForAssert[0].UAC_reciprocal__c, ASSERT_POSITIVE_CREATE);
  }

  /**
   * @description Tests for positive scenarios of tertiary relationship creation.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void creatingRelationshipShouldCreateTertiaryRelationship() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());
    Contact contactTertiary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_TERTIARY, new Set<String>());
    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    UAC_apprehendedRelationship__c existingRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactSecondary.Id, contactTertiary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.startTest();
    UAC_apprehendedRelationshipHelper.booReciprocal = false;
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.stopTest();
    List<UAC_apprehendedRelationship__c> listReciprocalForAssert =
        getApprehendedRelationship(contactPrimary.Id, contactTertiary.Id);
    System.assertEquals(1, listReciprocalForAssert.size(), ASSERT_POSITIVE_EXISTING);
  }

  /**
   * @description Tests for positive scenarios of tertiary relationship creation.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void creatingRelationshipShouldCreateTertiaryRelationshipFromCurrent() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());
    Contact contactTertiary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_TERTIARY, new Set<String>());
    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    UAC_apprehendedRelationship__c existingRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.startTest();
    UAC_apprehendedRelationshipHelper.booReciprocal = false;
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactTertiary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.stopTest();
      for(UAC_apprehendedRelationship__c apr : [SELECT UAC_uacLookup__r.UAC_A__c, UAC_relatedUAC__r.UAC_A__c, UAC_relationshipToUAC__c FROM UAC_apprehendedRelationship__c ORDER BY CreatedDate ASC]) {
          System.debug(apr);
      }
    List<UAC_apprehendedRelationship__c> listReciprocalForAssert =
        getApprehendedRelationship(contactSecondary.Id, contactTertiary.Id);
    System.assertEquals(1, listReciprocalForAssert.size(), ASSERT_POSITIVE_EXISTING);
  }

  /**
   * @description Tests for positive scenarios of updating reciprocal.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void updatingRelationshipShouldUpdateReciprocal() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());
    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.startTest();
    UAC_apprehendedRelationshipHelper.booReciprocal = false;
    newRelationship.UAC_relationshipToUAC__c = RELATIONSHIP_COUSIN;
    update newRelationship;
    Test.stopTest();
    List<UAC_apprehendedRelationship__c> listReciprocalForAssert =
        getApprehendedRelationship(contactSecondary.Id, contactPrimary.Id);
    System.assertEquals(1, listReciprocalForAssert.size(), ASSERT_POSITIVE_UPDATE);
    System.assertEquals(RELATIONSHIP_COUSIN,
        listReciprocalForAssert[0].UAC_relationshipToUAC__c,
        ASSERT_POSITIVE_UPDATE);
    System.assertEquals(true, listReciprocalForAssert[0].UAC_reciprocal__c, ASSERT_POSITIVE_UPDATE);
  }

  /**
   * @description Tests for positive scenarios of deleting reciprocal.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void deletingRelationshipShouldDeleteReciprocal() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());
    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    Test.startTest();
    UAC_apprehendedRelationshipHelper.booReciprocal = false;
    delete newRelationship;
    Test.stopTest();
    List<UAC_apprehendedRelationship__c> listReciprocalForAssert =
        getApprehendedRelationship(contactSecondary.Id, contactPrimary.Id);
    System.assertEquals(0, listReciprocalForAssert.size(), ASSERT_POSITIVE_DELETE);
  }

  /**
   * @description Query method to get Contact from A Number
   * @author James Qian (Deloitte) | 5/13/2020
   * @return List<Contact>
   **/
  private
  static List<Contact> getContact(String strANumber) {
    return [
      // clang-format off
        SELECT
          Id
        FROM
          Contact
        WHERE
          UAC_A__c = :strANumber
      // clang-format on
    ];
  }

  /**
   * @description Query method to get a specific apprehended relationship
   * @author James Qian (Deloitte) | 5/13/2020
   * @return List<UAC_apprehendedRelationship__c>
   **/
  private
  static List<UAC_apprehendedRelationship__c> getApprehendedRelationship(
      Id idPrimary, Id idSecondary) {
    return [
      // clang-format off
        SELECT
          UAC_uacLookup__c,
          UAC_relatedUAC__c,
          UAC_relationshipToUAC__c,
          UAC_reciprocal__c,
          UAC_referral1__c
        FROM
          UAC_apprehendedRelationship__c
        WHERE
          UAC_uacLookup__c = :idPrimary
        AND
          UAC_relatedUAC__c = :idSecondary
      // clang-format on
    ];
  }
}