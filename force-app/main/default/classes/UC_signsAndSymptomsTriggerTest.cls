/**
 * @File Name          : UC_signsAndSymptomsTriggerTest.cls
 * @Description        : Provides test class coverage for Signs and Symptoms Trigger
 * @Author             : Chase Oden (Deloitte)
 * @Group              : UAC_test
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/8/2021   Chase Oden (Deloitte)     Initial Implementation.
 **/
@isTest public with sharing class UC_signsAndSymptomsTriggerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STRING_ASSERT_SAS_COUNT = 'The Sign and Symptoms count does not match as expected.';

  /**
   * @description Sets up test data.
   */
  @TestSetup static void setupTestData() {
    // Instantiate related UC profile
    Contact objUCContact =
        new UAC_TestContactBuilder()
            // Set record type to UAC
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
            // Set required fields
            .setANumber(STR_A_NUM_UAC)
            // Build object, then insert
            .buildAndSave();

    // Instantiate related health evaluation
    UAC_HealthEvaluation__c objHealthEval =
        new UAC_testHealthEvaluationBuilder()
        // Set record type to Inital Medical Exam
        .setRecordTypeDeveloperName(System.Label.UAC_healthEvaluationRecordTypeApiNameIME)
        // Set required fields
        .setUAC(objUCContact.Id)
        // Build object, then insert
        .buildAndSave();

    UAC_signsAndSymptoms__c objSignsAndSymptoms =
        new UAC_testSignAndSymptomsBuilder()
            // NOTE: No record types exist for Signs and Symptoms,
            //       so we shouldn't need to setRecordTypeDeveloperName
            // Set required fields 
            .setHealthEvaluation(objHealthEval.id)
            .setUAC(objUCContact.id)
            // Build object, then insert
            .buildAndSave();
  }
  
  /**
   * @description Tests positive case for creating UAC_signsAndSymptoms__c record.
   */
  @isTest static void insertShouldSucceed() {
    // Get contact obj
    Contact objUCContact = [
      // clang-format off
      SELECT
        Id,
        UAC_A__c
      FROM
        Contact
      WHERE
        UAC_a__c = :STR_A_NUM_UAC
      LIMIT 1
      // clang-format on
      ];

    // Get health eval obj
    UAC_HealthEvaluation__c objHealthEval = [
      // clang-format off
      SELECT
        Id,
        UAC_associatedUAC__c
      FROM
        UAC_HealthEvaluation__c
      WHERE
        UAC_associatedUAC__r.UAC_a__c = :STR_A_NUM_UAC
      LIMIT 1
      // clang-format on
      ];

    Integer intSignsAndSymptomsRecordCount = [
                // clang-format off
                SELECT
                  count()
                FROM
                  UAC_signsAndSymptoms__c
                // clang-format on
                ];
    // Begin test actions
    Test.startTest();
    // Build and insert a new Signs and Symptoms record
    UAC_signsAndSymptoms__c objNewSignsAndSymptoms =
        new UAC_testSignAndSymptomsBuilder()
            // NOTE: No record types exist for Signs and Symptoms,
            //       so we shouldn't need to setRecordTypeDeveloperName
            // Set required fields 
            .setHealthEvaluation(objHealthEval.id)
            .setUAC(objUCContact.id)
            // Build object, then insert
            .buildAndSave();
    Test.stopTest();
    // Assert changes in object result in expected behavior
    Integer intNewSignsAndSymptomsRecordCount = [
                // clang-format off
                SELECT
                  count()
                FROM
                  UAC_signsAndSymptoms__c
                // clang-format on
                ];
    System.assertEquals(
        intSignsAndSymptomsRecordCount + 1,
        intNewSignsAndSymptomsRecordCount,
        STRING_ASSERT_SAS_COUNT
    );
  }
  
  /**
   * @description Tests positive case for updating UAC_signsAndSymptoms__c record.
   */
  @isTest static void updateShouldSucceed() {
    // Get object
    UAC_signsAndSymptoms__c objSignsAndSymptoms = getSignsAndSymptoms();

    // Begin test actions
    Test.startTest();
    // Change location of pain to Neck
    objSignsAndSymptoms.UAC_locationofPain__c = 'Neck';
    update objSignsAndSymptoms;
    Test.stopTest();
    // Assert changes in object result in expected behavior
    System.assertEquals('Neck', objSignsAndSymptoms.UAC_locationofPain__c, 'Could not update value of UAC_locationofPain__c');
  }
  
  /**
   * @description Tests positive case for deleting UAC_signsAndSymptoms__c records.
   */
  @isTest static void deleteShouldSucceed() {
    // Initialize object
    UAC_signsAndSymptoms__c objSignsAndSymptoms = getSignsAndSymptoms();

    Integer intSignsAndSymptomsRecordCount = [
                // clang-format off
                SELECT
                  count()
                FROM
                  UAC_signsAndSymptoms__c
                // clang-format on
              ];

    // Begin test actions
    Test.startTest();
    // Delete all UAC_signsAndSymptoms__C records
    delete[SELECT Id FROM UAC_signsAndSymptoms__c];
    Test.stopTest();
    // Assert changes in object result in expected behavior
    Integer intNewSignsAndSymptomsRecordCount = [
                // clang-format off
                SELECT
                  count()
                FROM
                  UAC_signsAndSymptoms__c
                // clang-format on
                ];
    System.assert(
        intSignsAndSymptomsRecordCount > intNewSignsAndSymptomsRecordCount,
        STRING_ASSERT_SAS_COUNT
    );
  }

  /**
   * @description Queries UAC_signsAndSymptoms__c for test data insertion and assertions.
   * @return UAC_signsAndSymptoms__c
   */
  private static UAC_signsAndSymptoms__c getSignsAndSymptoms() {
    return [
      // clang-format off
        SELECT
          Id,
          Name
        FROM
          UAC_signsAndSymptoms__c
        LIMIT 1
      // clang-format on
      ];
  }
}