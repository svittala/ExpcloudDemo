/**
 * @File Name          : UAC_diagnosisTriggerHelperTest.cls
 * @Description        : Helper method for UAC_diagnosisTriggerHandler
 * @Author             : Anupreeta Chakraborty (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 10-13-2020
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    06-22-2020   Anupreeta Chakraborty (Deloitte)  Initial Implementation.
 * 1.1    09-19-2020   Vijayakumar Pethanan (Deloitte)   #2257,#1794 story test.
 * 1.2    09-25-2020   Sachet Khanal (Deloitte)          Adding bypass settings test
 **/
@isTest(seeAllData = false) public class UAC_diagnosisTriggerHelperTest {

  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static Contact objUACContact;
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static UAC_Diagnosis__c objDiagnosis;
  private
  static Account objProgram;

  /**
   * @description Method to create test data
   * @author Sachet Khanal (Deloitte) | 09-21-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .build();

    insert objUACContact;
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .buildAndSave();
  }

  /**
   * @description ORRUAC-949: Method to test the deletion and undeletion of Diagnosis record
   * @author Anupreeta Chakraborty (Deloitte) | 06/22/2020
   * @return void
   **/
  @isTest static void deleteandUndeleteDiagnosis() {
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
    Test.startTest();
    objDiagnosis = new UAC_testDiagnosisBuilder()
                       .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                       .setAssociatedHealthEval(objHealthEval.Id)
                       .buildAndSave();

    // delete medication record
    UAC_diagnosis__c objDiagnosisBeforeDelete = [select id,
      (select id from medications__r) from UAC_Diagnosis__c where Id =:objDiagnosis.id LIMIT 1];
    if (objDiagnosisBeforeDelete.medications__r != null)
      delete objDiagnosisBeforeDelete.medications__r;

    // delete diagnosis record
    delete objDiagnosis;

    // undelete diagnosis record
    undelete objDiagnosis;
    System.assertNotEquals(objDiagnosis, null);

    Test.stopTest();
  }


  /**
  * @description ORRUAC-2257: Create Exposure Event for Diagnosis
      Current status = Label.UAC_statusFinal
      Potentially Exposed UAC = 'Yes'
      Condition in
      'Acute Hepatitis A',
      'COVID-19',
      'Measles',
      'Mumps',
      'Pertussis',
      'Rubella',
      'Varicella (Chickenpox)',
      'Viral Hemorrhagic Fever'
  * @author Vijayakumar Pethanan (Deloitte) | 09/19/2020
  * @return void
  **/
  @isTest static void createExposureEvent() {
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
    Test.startTest();
    UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                     .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                     .setAssociatedHealthEval(objHealthEval.Id)
                                     .build();
    diagnosis.UAC_status__c = Label.UAC_statusFinal;
    diagnosis.UAC_potentiallyExposedUAC__c = Label.UAC_Yes;
    diagnosis.UAC_WDCategory__c = 'Potentially Reportable Infectious Disease';
    diagnosis.UAC_WDCondition__c = 'Rubella';
    diagnosis.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c = Label.UAC_No;
    insert diagnosis;
    Test.stopTest();
    UAC_exposureEvent__c exposureEvent =
        [SELECT id, UAC_diseaseCondition__c FROM UAC_exposureEvent__c];

    System.assertEquals(diagnosis.UAC_WDCondition__c,
        exposureEvent.UAC_diseaseCondition__c,
        'Exposure event condition doesn\'t match disease condition');
  }

  /**
  * @description ORRUAC-2257: Create Exposure Event for Diagnosis
      Current status = Label.UAC_statusFinal
      Potentially Exposed UAC = 'Yes'
      Condition =    Sepsis/Meningitis'
      Condition type in
      'Hemophilus Influenzae Type b (Hib)',
      'Neisseria Meningitidis',
      'Streptococcus Pneumoniae'
  * @author Vijayakumar Pethanan (Deloitte) | 09/19/2020
  * @return void
  **/
  @isTest static void createExposureEventSepsis() {
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
    Test.startTest();
    UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                     .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                     .setAssociatedHealthEval(objHealthEval.Id)
                                     .build();
    diagnosis.UAC_status__c = Label.UAC_statusFinal;
    diagnosis.UAC_potentiallyExposedUAC__c = Label.UAC_Yes;
    diagnosis.UAC_WDCondition__c = 'Sepsis/Meningitis';
    diagnosis.UAC_WDConditionType__c = 'Neisseria Meningitidis';
    diagnosis.UAC_WDCategory__c = 'Potentially Reportable Infectious Disease';
    diagnosis.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c = Label.UAC_No;
    insert diagnosis;
    Test.stopTest();
    UAC_exposureEvent__c exposureEvent =
        [SELECT id, UAC_diseaseCondition__c FROM UAC_exposureEvent__c];

    System.assertEquals(diagnosis.UAC_WDCondition__c,
        exposureEvent.UAC_diseaseCondition__c,
        'Exposure event condition doesn\'t match disease condition');
  }
  /**
  * @description ORRUAC-2257: Create Exposure Event for Diagonsis
      Current status = Label.UAC_statusFinal
      Potentially Exposed UAC = 'Yes'
      Condition =   'TB, Active Disease'
      Condition type in
       'Lab-confirmed Pulmonary TB',
       'Clinically Diagnosed Pulmonary TB'
  * @author Vijayakumar Pethanan (Deloitte) | 09/19/2020
  * @return void
  **/
  @isTest static void createExposureEventTBActiveDisease() {
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
    Test.startTest();
    UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                     .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                     .setAssociatedHealthEval(objHealthEval.Id)
                                     .build();
    diagnosis.UAC_status__c = Label.UAC_statusFinal;
    diagnosis.UAC_potentiallyExposedUAC__c = Label.UAC_Yes;
    diagnosis.UAC_WDCondition__c = 'TB, Active Disease';
    diagnosis.UAC_WDConditionType__c = 'Clinically Diagnosed Pulmonary TB';
    diagnosis.UAC_WDCategory__c = 'Potentially Reportable Infectious Disease';
    diagnosis.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c = Label.UAC_No;
    insert diagnosis;
    Test.stopTest();
    UAC_exposureEvent__c exposureEvent =
        [SELECT id, UAC_diseaseCondition__c FROM UAC_exposureEvent__c];

    System.assertEquals(diagnosis.UAC_WDCondition__c,
        exposureEvent.UAC_diseaseCondition__c,
        'Exposure event condition doesn\'t match disease condition');
  }

  /**
   * @description ORRUAC-1794: Create  task from diagnosis
   * @author Vijayakumar Pethanan (Deloitte) | 09/19/2020
   * @return void
   **/
  @isTest static void createTaskFromDiagnosis() {
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
    Test.startTest();
    UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                     .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                     .setAssociatedHealthEval(objHealthEval.Id)
                                     .build();
    diagnosis.UAC_status__c = Label.UAC_statusFinal;
    diagnosis.UAC_potentiallyExposedUAC__c = Label.UAC_NO;
    diagnosis.UAC_WDCondition__c = 'TB, Active Disease';
    diagnosis.UAC_WDConditionType__c = 'Clinically Diagnosed Pulmonary TB';
    diagnosis.UAC_WDCategory__c = 'Potentially Reportable Infectious Disease';
    diagnosis.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c = Label.UAC_No;
    // Follow up Task
    diagnosis.UAC_wdFollowUpVisitRequired__c = Label.UAC_Yes;
    diagnosis.UAC_wdFollowUpVisitDate__c = Date.today().addDays(60);
    // Specialist Referal
    diagnosis.UAC_wdReferralToSpecialistRequired__c = Label.UAC_Yes;
    diagnosis.UAC_wdSpecialistType__c = 'Dermatologist';
    diagnosis.UAC_specialistVisitEstimatedDueDate__c = Date.today().addDays(60);

    // Isolation/Qurantine Task creation
    diagnosis.UAC_wdIsIsolationQuarantineRequired__c = Label.UAC_Yes;
    diagnosis.UAC_wdIsolationQuarantineStartDate__c = Date.today();
    diagnosis.UAC_wdIsolationQuarantineEndDate__c = Date.today().addDays(60);

    // Delayed Discharge Task creation
    diagnosis.UAC_wdWillDischargeNeedtobeDelayed__c = Label.UAC_Yes;
    diagnosis.UAC_delayedDischargeEstimatedEndDate__c = Date.today().addDays(60);

    insert diagnosis;
    Test.stopTest();
    List<UAC_exposureEvent__c> exposureEvent =
        [SELECT id, UAC_diseaseCondition__c FROM UAC_exposureEvent__c];
    List<Task> taskList = [select id, subject from task];
    System.assert(exposureEvent.isEmpty(), 'Test exposure event is empty ');
    System.assert(taskList.isEmpty() == false, 'Test task is created');
    System.assertEquals(4, taskList.size(), 'Task size doesn\'t match');
  }

  /**
   * @description Test bypass of create exposure event when bypass settings is enabled.
   * @author Sachet Khanal (Deloitte) | 09-25-2020
   * @return void
   **/
  @isTest static void bypassShouldNotCreateExposureEvent() {
    // Enabled Diagnosis Trigger Bypass
    UAC_bypassSettings__c objBypassSettings = UAC_bypassSettings__c.getInstance();
    objBypassSettings.UAC_bypassDiagnosisTrigger__c = true;
    upsert objBypassSettings;
    UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
    Test.startTest();
    UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                     .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                     .setAssociatedHealthEval(objHealthEval.Id)
                                     .build();
    diagnosis.UAC_status__c = Label.UAC_statusFinal;
    diagnosis.UAC_potentiallyExposedUAC__c = Label.UAC_Yes;
    diagnosis.UAC_WDCategory__c = 'Potentially Reportable Infectious Disease';
    diagnosis.UAC_WDCondition__c = 'Rubella';
    diagnosis.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c = Label.UAC_No;
    insert diagnosis;
    Test.stopTest();
    List<UAC_exposureEvent__c> lstExposureEvent =
        [SELECT id, UAC_diseaseCondition__c FROM UAC_exposureEvent__c];

    System.assert(lstExposureEvent.isEmpty(), 'Exposure event created with bypass settings on.');
  }

  /**
   * @description Method to get HealthEvaluation record created by test instance
   * @author Sachet Khanal (Deloitte) | 09-21-2020
   * @param strANumber A Number of UAC
   * @return UAC_healthEvaluation__c
   **/
  public
  static UAC_healthEvaluation__c getHealthEvaluationByANumber(String strANumber) {
    // clang-format off
    return [
      SELECT
        Id, Name, UAC_associatedUAC__c
      FROM
        UAC_healthEvaluation__c
      WHERE
        UAC_associatedUAC__r.UAC_a__c = :strANumber
      LIMIT 1
    ];
    // clang-format on
  }
}