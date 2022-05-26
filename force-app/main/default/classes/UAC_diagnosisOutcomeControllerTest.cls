/**
 * @File Name         : UAC_diagnosisOutcomeControllerTest.cls
 * @Description       : Test class for UAC_diagnosisOutcomeController
 * @Group             : UAC_diagnosisOutcomeController
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 09-01-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-01-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   02-22-2021   Abhisek Pati (Deloitte)    Added Test Coverage
 **/
@isTest public with sharing class UAC_diagnosisOutcomeControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_TEST_CLASS_NAME = UAC_diagnosisOutcomeControllerTest.class.getName();
  private
  static final String STR_HEALTH_ASSESSMENT_RECORD_TYPE_DEV_NAME = 'UAC_healthAssessment';

  /**
   * @description Method to setup test data
   * @author Sachet Khanal (Deloitte) | 09-01-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
  }

  /**
   * @description Method to test updating Diagnosis Outcome record.
   * @author Sachet Khanal (Deloitte) | 09-01-2020
   **/
  @isTest static void updateDiagnosisOutcomeShouldUpdateOutcome() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_Diagnosis__c objDiagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);
    UAC_healthEvaluation__c objHealthAssessment =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(STR_HEALTH_ASSESSMENT_RECORD_TYPE_DEV_NAME)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    UAC_diagnosisOutcome__c objOutcome =
        new UAC_diagnosisOutcome__c(UAC_associatedDiagnosis__c = objDiagnosis.Id,
            UAC_associatedHealthEvaluation__c = objHealthAssessment.Id,
            UAC_outcomeOfEvaluation__c = Label.UAC_diagnosisOutcomeRuledOutReplace);
    UAC_Diagnosis__c objNewDiagnosis = new UAC_testDiagnosisBuilder().build();
    objNewDiagnosis.UAC_associatedUAC__c = objUACContact.Id;
    objNewDiagnosis.UAC_associatedHealthEvaluation__c = objHealthAssessment.Id;
    String strOutcome = JSON.serialize(objOutcome);
    String strAssociatedDiagnosis = JSON.serialize(objDiagnosis);
    String strNewDiagnosis = JSON.serialize(objNewDiagnosis);
    Test.startTest();
    UAC_genericResponse objResponse = UAC_diagnosisOutcomeController.updateDiagnosisOutcome(
        strOutcome, strAssociatedDiagnosis, null);
    Test.stopTest();
    System.assert(objResponse.isSuccess,
        'Test method: updateDiagnosisOutcomeShouldUpdateOutcome() failed.' + objResponse.error);
  }
  
    /**
   * @description Method to test updating Diagnosis Outcome record.
   * @author Anupreeta Chakraborty (Deloitte) | 11-04-2020
   **/
  @isTest static void updateDiagnosisOutcomeShouldUpdateOutcomeWithDiagnosis() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_Diagnosis__c objDiagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);
    UAC_healthEvaluation__c objHealthAssessment =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(STR_HEALTH_ASSESSMENT_RECORD_TYPE_DEV_NAME)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    UAC_diagnosisOutcome__c objOutcome =
        new UAC_diagnosisOutcome__c(UAC_associatedDiagnosis__c = objDiagnosis.Id,
            UAC_associatedHealthEvaluation__c = objHealthAssessment.Id,
            UAC_outcomeOfEvaluation__c = Label.UAC_diagnosisOutcomeRuledOutReplace);
    UAC_Diagnosis__c objNewDiagnosis = new UAC_testDiagnosisBuilder().build();
    objNewDiagnosis.UAC_associatedUAC__c = objUACContact.Id;
    objNewDiagnosis.UAC_associatedHealthEvaluation__c = objHealthAssessment.Id;
    String strOutcome = JSON.serialize(objOutcome);
    String strAssociatedDiagnosis = JSON.serialize(objDiagnosis);
    String strNewDiagnosis = JSON.serialize(objNewDiagnosis);
    Test.startTest();
    UAC_genericResponse objResponse = UAC_diagnosisOutcomeController.updateDiagnosisOutcome(
        strOutcome, strAssociatedDiagnosis, strNewDiagnosis);
    Test.stopTest();
    System.assert(objResponse.isSuccess,
        'Test method: updateDiagnosisOutcomeShouldUpdateOutcome() failed.' + objResponse.error);
  }  
  
    /**
   * @description Method to test updating Diagnosis Outcome record.
   * @author Anupreeta Chakraborty (Deloitte) | 11-04-2020
   **/
  @isTest static void updateNewDiagnosisNegativeScenario() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_Diagnosis__c objDiagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);
    UAC_healthEvaluation__c objHealthAssessment =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(STR_HEALTH_ASSESSMENT_RECORD_TYPE_DEV_NAME)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    UAC_diagnosisOutcome__c objOutcome =
        new UAC_diagnosisOutcome__c(UAC_associatedDiagnosis__c = objDiagnosis.Id,
            UAC_associatedHealthEvaluation__c = objHealthAssessment.Id,
            UAC_outcomeOfEvaluation__c = Label.UAC_diagnosisOutcomeRuledOutReplace);
    UAC_Diagnosis__c objNewDiagnosis = new UAC_testDiagnosisBuilder().build();
    objNewDiagnosis.UAC_associatedUAC__c = objUACContact.Id;
    objNewDiagnosis.UAC_associatedHealthEvaluation__c = objHealthAssessment.Id;
    objNewDiagnosis.UAC_WDCondition__c = 'Testing123';
    String strOutcome = JSON.serialize(objOutcome);
    String strAssociatedDiagnosis = JSON.serialize(objDiagnosis);
    String strNewDiagnosis = JSON.serialize(objNewDiagnosis);
    Test.startTest();
    UAC_genericResponse objResponse = UAC_diagnosisOutcomeController.updateDiagnosisOutcome(
        strOutcome, strAssociatedDiagnosis, strNewDiagnosis);
    Test.stopTest();
    System.assert(!objResponse.isSuccess,
        '' + 'Test method: updateDiagnosisOutcomeShouldUpdateOutcome() failed.');
  }  
  
      /**
   * @description Method to test updating Diagnosis Outcome record.
   * @author Anupreeta Chakraborty (Deloitte) | 11-04-2020
   **/
  @isTest static void updateAssociatedDiagnosisNegativeScenario() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_Diagnosis__c objDiagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);
    UAC_healthEvaluation__c objHealthAssessment =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(STR_HEALTH_ASSESSMENT_RECORD_TYPE_DEV_NAME)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    objDiagnosis.UAC_WDCondition__c = 'Testing123'; 
    UAC_diagnosisOutcome__c objOutcome =
        new UAC_diagnosisOutcome__c(UAC_associatedDiagnosis__c = objDiagnosis.Id,
            UAC_associatedHealthEvaluation__c = objHealthAssessment.Id,
            UAC_outcomeOfEvaluation__c = Label.UAC_diagnosisOutcomeRuledOutReplace);
    UAC_Diagnosis__c objNewDiagnosis = new UAC_testDiagnosisBuilder().build();
    objNewDiagnosis.UAC_associatedUAC__c = objUACContact.Id;
    objNewDiagnosis.UAC_associatedHealthEvaluation__c = objHealthAssessment.Id;
    String strOutcome = JSON.serialize(objOutcome);
    String strAssociatedDiagnosis = JSON.serialize(objDiagnosis);
    String strNewDiagnosis = JSON.serialize(objNewDiagnosis);
    Test.startTest();
    UAC_genericResponse objResponse = UAC_diagnosisOutcomeController.updateDiagnosisOutcome(
        strOutcome, strAssociatedDiagnosis, strNewDiagnosis);
    Test.stopTest();
    System.assert(!objResponse.isSuccess,
        '' + 'Test method: updateDiagnosisOutcomeShouldUpdateOutcome() failed.');
  }

    /**
   * @description Method to test updating Diagnosis Outcome record.
   * @author Abhisek Pati (Deloitte) | 02-22-2021
   **/
  @isTest static void updateAssociatedDiagnosisNegativeScenario2() {
    Test.startTest();
    UAC_genericResponse objResponse = UAC_diagnosisOutcomeController.updateDiagnosisOutcome(
        'Testing', 'Testing', 'Testing');
    Test.stopTest();
    System.assertEquals(false,
        objResponse.isSuccess, 'Test method: updateDiagnosisOutcomeShouldUpdateOutcome() success.');
  }  
  

}