/**
 * @File Name          : UAC_assetTriggerTest.cls
 * @Description        : Provides test class coverage for Asset Trigger
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_test
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/9/2020   James Qian (Deloitte)     Initial Implementation.
 **/
@isTest public with sharing class UAC_assetTriggerTest {
  private
  static final String STRING_BED_ACTIVE_STATUS = 'Available';
  private
  static final String STRING_BED_INACTIVE_STATUS = 'Unavailable';
  private
  static final String STRING_BED_HOLD_STATUS = 'On-Hold';
  private
  static final String STRING_ASSERT_BED_COUNT = 'The bed count does not match as expected.';
  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final String STRING_MALE = System.Label.UAC_male;
  private
  static final String STRING_FEMALE = System.Label.UAC_female;

  /**
   * @description Sets up test data.
   */
  @TestSetup static void setupTestData() {
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setStatus('Draft')
                             .setType(STRING_FIELD_TYPE)
                             .build();
    objProgram.UAC_bedCountAvailableFemale__c = 0;
    objProgram.UAC_bedCountAvailableMale__c = 0;
    objProgram.UAC_bedCountOnHoldFemale__c = 0;
    objProgram.UAC_bedCountOnHoldMale__c = 0;
    objProgram.UAC_bedCountUnavailableFemale__c = 0;
    objProgram.UAC_bedCountUnavailableMale__c = 0;
    insert objProgram;
  }

  /**
   * @description Tests positive cases for inserting male beds and updating parent Account bed
   * count.
   */
  @isTest static void insertingBedsShouldIncreaseCountMale() {
    Account parentProgram = getAccount();
    Test.startTest();
    UAC_TestUtility.createAssets(parentProgram.Id, STRING_MALE, STRING_BED_ACTIVE_STATUS, 7, true);
    Test.stopTest();
    Account programQueried = getAccount();
    System.assertEquals(7, programQueried.UAC_bedCountAvailableMale__c, STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Tests positive cases for inserting female beds and updating parent Account bed
   * count.
   */
  @isTest static void insertingBedsShouldIncreaseCountFemale() {
    Account parentProgram = getAccount();
    Test.startTest();
    UAC_TestUtility.createAssets(
        parentProgram.Id, STRING_FEMALE, STRING_BED_ACTIVE_STATUS, 7, true);
    Test.stopTest();
    Account programQueried = getAccount();
    System.assertEquals(7, programQueried.UAC_bedCountAvailableFemale__c, STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Tests positive cases for deleting male beds and updating parent Account bed count.
   */
  @isTest static void deletingBedsShouldDecreaseCountMale() {
    Account parentProgram = getAccount();
    UAC_TestUtility.createAssets(parentProgram.Id, STRING_MALE, STRING_BED_ACTIVE_STATUS, 7, true);
    Test.startTest();
    delete[SELECT Id FROM Asset];
    Test.stopTest();
    Account programQueried = getAccount();
    System.assertEquals(0, programQueried.UAC_bedCountAvailableMale__c, STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Tests positive cases for deleting female beds and updating parent Account bed
   * count.
   */
  @isTest static void deletingBedsShouldDecreaseCountFemale() {
    Account parentProgram = getAccount();
    UAC_TestUtility.createAssets(
        parentProgram.Id, STRING_FEMALE, STRING_BED_ACTIVE_STATUS, 7, true);
    Test.startTest();
    delete[SELECT Id FROM Asset];
    Test.stopTest();
    Account programQueried = getAccount();
    System.assertEquals(0, programQueried.UAC_bedCountAvailableFemale__c, STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Tests positive cases for updating beds from active to inactive and updating parent
   * Account bed count.
   */
  @isTest static void updatingBedsShouldUpdateCounts() {
    Account parentProgram = getAccount();
    UAC_TestUtility.createAssets(parentProgram.Id, STRING_MALE, STRING_BED_ACTIVE_STATUS, 7, true);
    Test.startTest();
    Asset queriedAsset = [SELECT Id FROM Asset LIMIT 1];
    queriedAsset.Status = STRING_BED_INACTIVE_STATUS;
    update queriedAsset;
    Test.stopTest();
    Account programQueried = getAccount();
    System.assertEquals(6, programQueried.UAC_bedCountAvailableMale__c, STRING_ASSERT_BED_COUNT);
    System.assertEquals(
        1, programQueried.UAC_Bed_Count_Unavailable_Male__c, STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Tests positive cases for updating beds from on hold to inactive and updating
   * parent Account bed count.
   */
  @isTest static void updatingBedsShouldUpdateCountsOnHold() {
    Account parentProgram = getAccount();
    UAC_TestUtility.createAssets(parentProgram.Id, STRING_MALE, STRING_BED_HOLD_STATUS, 7, true);
    Test.startTest();
    Asset queriedAsset = [SELECT Id FROM Asset LIMIT 1];
    queriedAsset.Status = STRING_BED_INACTIVE_STATUS;
    update queriedAsset;
    Test.stopTest();
    Account programQueried = getAccount();
    System.assertEquals(6, programQueried.UAC_bedCountOnHoldMale__c, STRING_ASSERT_BED_COUNT);
    System.assertEquals(
        1, programQueried.UAC_Bed_Count_Unavailable_Male__c, STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Tests positive cases for setting Asset name automatically.
   */
  @isTest static void insertingBedsShouldSetName() {
    Account parentProgram = getAccount();
    Test.startTest();
    UAC_TestUtility.createAssets(parentProgram.Id, STRING_MALE, STRING_BED_ACTIVE_STATUS, 7, true);
    Test.stopTest();
    List<Asset> queriedAssets = [SELECT Id, Name FROM Asset WHERE Name LIKE 'Bed%'];
    System.assertEquals(7, queriedAssets.size(), STRING_ASSERT_BED_COUNT);
  }

  /**
   * @description Queries Account for test data insertion and assertions.
   * @return Account
   */
  private
  static Account getAccount() {
    return [
      // clang-format off
          SELECT
            Id,
            UAC_bedCountAvailableFemale__c,
            UAC_bedCountAvailableMale__c,
            UAC_bedCountOnHoldFemale__c,
            UAC_bedCountOnHoldMale__c,
            UAC_bedCountUnavailableFemale__c,
            UAC_bedCountUnavailableMale__c,
        	UAC_Bed_Count_Unavailable_Male__c,
       		UAC_Bed_Count_Unavailable_Female__c
          FROM
            Account
          LIMIT 1
      // clang-format on
    ];
  }
}