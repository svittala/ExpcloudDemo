/**
 * @File Name         : UAC_medicationTableControllerTest.cls
 * @Description       : Test class for UAC_medicationTableController
 * @Group             : UAC_medicationTableControllerTest
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  :
 * @Last Modified On  :
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-18-2020   Abhisek Pati (Deloitte)   Initial Version
 **/
@isTest public class UAC_medicationTableControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static final String STR_TEST_CLASS_NAME = UAC_medicationTableControllerTest.class.getName();

  /**
   * @description Method to setup test data
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    UAC_Diagnosis__c Diagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);
    UAC_medication__c objMedication =
        new UAC_testMedicationBuilder().buildAndSave(objUACContact, Diagnosis, null);
    objMedication.UAC_associatedHealthEvaluation__c = objIME.Id;
    Update objMedication;

    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 1, true);

    Case objUACReferralCase = new UAC_testCaseBuilder()
                                  .setStatus('Processed Pending')
                                  .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                                  .setUAC(objUACContact.id)
                                  .buildAndSave();
    objUACReferralCase.UAC_programFacility__c = objProgram.Id;
    update objUACReferralCase;
  }

  /**
   * @description Method to test update functionalities of UAC_medicationTableController
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   */
  @isTest static void testUpdMedicationTableController() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_medication__c> lstmedication =
        UAC_medicationTableController.getMedicationList(objIME.Id);
    System.assert(!lstmedication.isEmpty(), 'Failed to get Medication list');
    UAC_genericResponse objResponse =
        UAC_medicationTableController.upsertMedicationList(JSON.serialize(lstmedication));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to Update Medication record');
    Test.stopTest();
  }

  /**
   * @description Method to test create functionalities of UAC_medicationTableController
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   */
  @isTest static void testCreateMedicationTableController() {
    UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
    String idUAC = objIME.UAC_associatedUAC__c;
    String idHealthEval = objIME.Id;
    Contact objuac = [SELECT Id FROM Contact Limit 1];
    UAC_Diagnosis__c diagnosis = [SELECT Id FROM UAC_diagnosis__c Limit 1];
    Test.startTest();
    UAC_medication__c objMedication =
        new UAC_testMedicationBuilder().buildAndSave(objUAC, Diagnosis, null);
    List<UAC_medication__c> lstmedication = new List<UAC_medication__c>();
    lstmedication.add(objMedication);
    UAC_genericResponse objResponse =
        UAC_medicationTableController.upsertMedicationList(JSON.serialize(lstmedication));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to Create Medication record');
    System.assertNotEquals(
        null, objResponse.data.get('errorMap'), 'Failed to Create Medication record');
    Test.stopTest();
  }

  /**
   * @description Method to test Delete functionalities of UAC_medicationTableController
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   */
  @isTest static void testDeleteMedicationTableController() {
    UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
    String idUAC = objIME.UAC_associatedUAC__c;
    String idHealthEval = objIME.Id;
    Contact objuac = [SELECT Id FROM Contact Limit 1];
    UAC_Diagnosis__c diagnosis = [SELECT Id FROM UAC_diagnosis__c Limit 1];
    Test.startTest();
    UAC_medication__c objMedication =
        new UAC_testMedicationBuilder().buildAndSave(objUAC, Diagnosis, null);
    List<UAC_medication__c> lstmedication = new List<UAC_medication__c>();
    lstmedication.add(objMedication);
    UAC_genericResponse objResponse =
        UAC_medicationTableController.upsertMedicationList(JSON.serialize(lstmedication));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to Create Medication record');
    List<UAC_medication__c> lstMedicationForDel = getMedicationRecord(idUAC, idHealthEval);
    UAC_genericResponse objDelResponse =
        UAC_medicationTableController.deleteMedicationList(JSON.serialize(lstMedicationForDel));
    System.assertEquals(true, objDelResponse.isSuccess, 'Failed to Delete Medication record');
    Test.stopTest();
  }

  /**
   * @description Method to test Delete functionalities of UAC_medicationTableController
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   */
  @isTest static void testDeleteMedicationTableControllerNegativeCase() {
    Test.startTest();
    UAC_genericResponse objDelResponse =
        UAC_medicationTableController.deleteMedicationList(JSON.serialize(null));
    System.assertEquals(false, objDelResponse.isSuccess, 'Failed to Update Medication record');
    System.assertNotEquals(null, objDelResponse.error, 'Failed to update Medication record');
    Test.stopTest();
  }

  /**
   * @description Method to test Exception case of UAC_medicationTableController
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   */
  @isTest static void testUpdMedicationTableControllerNegativeCase() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_medication__c> lstmedication =
        UAC_medicationTableController.getMedicationList(objIME.Id);
    System.assert(!lstmedication.isEmpty(), 'Failed to get Medication list');
    UAC_genericResponse objResponse =
        UAC_medicationTableController.upsertMedicationList(JSON.serialize(null));
    Test.stopTest();
    System.assertEquals(false, objResponse.isSuccess, 'Failed to Update Medication record');
    System.assertNotEquals(null, objResponse.error, 'Failed to update Medication record');
  }

  /**
   * @description Method to test Exception case of UAC_medicationTableController
   * @author Sarang (Deloitte) | 10-07-2020
   */
  @isTest static void testGetAdmissionAssesmentRecord() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(idUAC)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .buildAndSave();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    UAC_admissionAssessment__c assessmentQueried =
        UAC_medicationTableController.getAdmissionAssesment(assessmentNew.id);
    Test.stopTest();
    System.assertEquals(objIME.Id, assessmentQueried.UAC_healthEvaluationIme__c);
  }
  /**
   * @description Method to get medications for admission assessment
   * @author Issam Awwad (Deloitte) | 1-22-2021
   */
  @isTest static void testGetMedicationForAdmissionAssesmentRecord() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(idUAC)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .buildAndSave();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    Contact objuac = [SELECT Id FROM Contact Limit 1];
    UAC_Diagnosis__c diagnosis = [SELECT Id FROM UAC_diagnosis__c Limit 1];
    UAC_medication__c objMedication =
        new UAC_testMedicationBuilder().buildAndSave(objUAC, Diagnosis, null);
    objMedication.UAC_enteredfromInitialIntakesAssessment__c = true;
    objMedication.UAC_admissionAssessment__c = assessmentNew.Id;
    update objMedication;
    List<UAC_medication__c> lstmedication =
        UAC_medicationTableController.getMedicationListForAssessment(assessmentNew.id);
    Test.stopTest();
    System.assertEquals(1, lstmedication.size());
  }
  /**
   * @description Method to get IME record by UAC A Number
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   * @param strANumber String value for UAC A Number
   * @return UAC_healthEvaluation__c
   */
  public
  static UAC_healthEvaluation__c getIMEByUACANumber(String strANumber) {
    // clang-format off
      return [
        SELECT
          Id
        FROM
          UAC_healthEvaluation__c
        WHERE
          UAC_associatedUAC__r.UAC_a__c = :strANumber
        LIMIT 1
      ];
    // clang-format on
  }
  /**
   * @description Method to get IME record by UAC A Number
   * @author Abhisek Pati (Deloitte) | 08-12-2020
   * @param strANumber String value for UAC A Number
   * @return UAC_healthEvaluation__c
   */
  public
  static UAC_healthEvaluation__c getUACByUACANumber(String strANumber) {
    // clang-format off
      return [
        SELECT
        Id,UAC_associatedUAC__c
        FROM
          UAC_healthEvaluation__c
        WHERE
          UAC_associatedUAC__r.UAC_a__c = :strANumber
        LIMIT 1
      ];
    // clang-format on
  }

  /**
   * @description Method to get Medication record
   * @author Abhisek Pati (Deloitte) | 09-18-2020
   * @param strANumber String value for UAC A Number
   * @return UAC_medication__c
   */
  public
  static List<UAC_medication__c> getMedicationRecord(String strUACId, String strHealEvalId) {
    // clang-format off
      return [
        SELECT
        Id,UAC_associatedUAC__c,UAC_associatedHealthEvaluation__c
        FROM
        UAC_medication__c
        WHERE
        UAC_associatedUAC__c= :strUACId AND
        UAC_associatedHealthEvaluation__c=: strHealEvalId
        LIMIT 1
      ];
    // clang-format on
  }
}