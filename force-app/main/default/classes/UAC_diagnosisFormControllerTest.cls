/**
 * @File Name         : UAC_diagnosisFormControllerTest.cls
 * @Description       : Test class for UAC_diagnosisFormController
 * @Group             : UAC_diagnosisForm
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-15-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-15-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
@isTest private class UAC_diagnosisFormControllerTest {

  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String INVALID_STATUS = 'Test1234';

  /**
   * @description Method to setup test data.
   * @author Sachet Khanal (Deloitte) | 09-15-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    UAC_healthEvaluation__c objHealthEval =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
  }

  @isTest static void saveDiagnosisShouldSaveDiagnosisRecord() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluation();
    UAC_Diagnosis__c objDiagnosis = new UAC_testDiagnosisBuilder()
                                        .setAssociatedUAC(objUACContact.Id)
                                        .setAssociatedHealthEval(objHealthEval.Id)
                                        .buildAndSave();
    UAC_Diagnosis__c objReplacementDiagnosis = new UAC_testDiagnosisBuilder()
                                                   .setAssociatedUAC(objUACContact.Id)
                                                   .setAssociatedHealthEval(objHealthEval.Id)
                                                   .build();
    objReplacementDiagnosis.UAC_parentDiagnosis__c = objDiagnosis.Id;
    String strStatus = objDiagnosis.UAC_status__c;
    String strReplacementStatus = objReplacementDiagnosis.UAC_status__c;
    objDiagnosis.UAC_status__c = INVALID_STATUS;
    objReplacementDiagnosis.UAC_status__c = INVALID_STATUS;
    UAC_genericResponse response = UAC_diagnosisFormController.saveDiagnosis(
        JSON.serialize(objDiagnosis), JSON.serialize(objReplacementDiagnosis));
    System.assert(
        !response.isSuccess, 'Test method: saveDiagnosisShouldSaveDiagnosisRecord() failed.');
    objDiagnosis.UAC_status__c = strStatus;
    objReplacementDiagnosis.UAC_status__c = strReplacementStatus;
    Test.startTest();
    response = UAC_diagnosisFormController.saveDiagnosis(
        JSON.serialize(objDiagnosis), JSON.serialize(objReplacementDiagnosis));
    Test.stopTest();
    System.assert(
        response.isSuccess, 'Test method: saveDiagnosisShouldSaveDiagnosisRecord() failed.');
  }

  static UAC_healthEvaluation__c getHealthEvaluation() {
    // clang-format off
    return [
      SELECT
        Id
      FROM
        UAC_healthEvaluation__c
      WHERE
        UAC_associatedUAC__r.UAC_a__c = :STR_A_NUM_UAC
      LIMIT 1
    ];
    // clang-format on
  }
}