/**
 * @File Name          : UAC_healthEvaluationTriggerHelperTest.cls
 * @Description        : Helper method for UAC_healthEvaluationTriggerHandler
 * @Author             : Anupreeta Chakraborty (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 07-31-2020
 * @Modification Log   :
 *
 * Ver       Date            Author                   Modification
 * 1.0  07-14-2020  Anupreeta Chakraborty (Deloitte)  Initial Implementation.
 * 1.1  07-31-2020  Sachet Khanal (Deloitte)          ORRUAC-1436 Test auto-generate related record
 * 1.2  10-21-2020  Abhisek Pati (Deloitte)           ORRUAC-3049 Added Test method to create Health Task
 * 1.3  03-22-2020  Abhisek Pati(Deloitte)            ORRUAC-5563 Added text coverage for Async process
 **/

@isTest(seeAllData = false) public class UAC_healthEvaluationTriggerHelperTest {

  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String strYes = Label.UAC_Yes;
  private
  static Contact objUACContact;
  private
  static UAC_HealthEvaluation__c objIME;
  public
  static final String strIMERecordType = System.label.UAC_IMERectype;


  /**
   * @description ORRUAC-949: Method to test field update of Health Evaluation(IME) record
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @return void
   **/
  @isTest static void populateIMEFieldstest() {
    {
      Test.startTest();
      Contact objUACContactAC =
          new UAC_testContactBuilder()
              .setANumber(STR_A_NUM_UAC)
              .setEmail(STR_A_NUM_UAC + '@example.invalid')
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
              .buildAndSave();
      objIME = new UAC_testHealthEvaluationBuilder()
                   .setUAC(objUACContactAC.Id)
                   .setRecordTypeDeveloperName(strIMERecordType)
                   .buildAndSave();
      objIME.UAC_cityTown__c = 'Test';
      update objIME;
      UAC_HealthEvaluation__c objIMEonUpdate =
          [select id, UAC_programNameattheTimeofExam__c from UAC_HealthEvaluation__c where Id
            =:objIME.id LIMIT 1];
      System.assertEquals(objIMEonUpdate.UAC_programNameattheTimeofExam__c, null);
      Test.stopTest();
    }
  }

  /**
   * @description ORRUAC-949: Method to test the deletion and undeletion of Health Evaluation record
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @return void
   **/
  @isTest static void deleteandUndeleteIME() {
    Test.startTest();
    Contact objUACContactAC = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
    UAC_healthEvaluation__c objIMEDeleteUndelete = new UAC_testHealthEvaluationBuilder()
                 .setUAC(objUACContactAC.Id)
                 .setRecordTypeDeveloperName(strIMERecordType)
                 .buildAndSave();

    UAC_HealthEvaluation__c objIMEBeforeDelete =
        [select id from UAC_HealthEvaluation__c where Id =:objIMEDeleteUndelete.id LIMIT 1];

    // Delete Physical Exam records before deleting IME - Health Eval records
    List<UAC_physicalExam__c> lstPhysicalExam = [Select Id,
      name from UAC_physicalExam__c where UAC_associatedHealthEvaluation__c =:objIMEDeleteUndelete.Id];
    delete lstPhysicalExam;
    
    // Delete related test records
    List<UAC_test__c> lstTest = [Select Id,
      name from UAC_test__c where UAC_associatedHealthEvaluation__c =:objIMEDeleteUndelete.Id];
    delete lstTest;

    // delete diagnosis record
    delete objIMEDeleteUndelete;

    // undelete diagnosis record
    undelete objIMEDeleteUndelete;
    System.assertNotEquals(objIMEDeleteUndelete, null);

    Test.stopTest();
  }

  /**
   * @description Method to test auto-generate related record logic for IME insert
   * @author Sachet Khanal (Deloitte) | 07-31-2020
   **/
  @isTest static void createIMEShouldAutoGenerateRelatedRecords() {
    Contact objUACContactAC = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
    Test.startTest();
    objIME = new UAC_testHealthEvaluationBuilder()
                 .setUAC(objUACContactAC.Id)
                 .setRecordTypeDeveloperName(strIMERecordType)
                 .buildAndSave();
    UAC_asyncIMERiskBasedRecordCreation handleIMERiskBasedRecord =
    new UAC_asyncIMERiskBasedRecordCreation(new Set<Id>{objIME.Id});
    handleIMERiskBasedRecord.execute(null);
    Test.stopTest();
    // clang-format off
    Integer intRiskBasedTestRecordCount = [
      SELECT
        count()
      FROM
        UAC_test__c
      WHERE
        RecordType.DeveloperName = :Label.UAC_testRecTypeRiskBasedLabTest
        AND UAC_associatedHealthEvaluation__c=:objIME.Id
    ];
    // clang-format on
    System.assert(intRiskBasedTestRecordCount > 0,
        'Test method: createIMEShouldAutoGenerateRelatedRecords() failed.');
    // clang-format off
    Integer intPhysicalExamRecordCount = [
      SELECT
        count()
      FROM
      UAC_physicalExam__c
      WHERE
      UAC_associatedHealthEvaluation__c=:objIME.Id
    ];
    // clang-format on
    System.assert(intPhysicalExamRecordCount > 0,
        'Test method: createIMEShouldAutoGenerateRelatedRecords() failed.');       
  }
  
    /**
   * @description ORRUAC-949: Method to test update of 'Mental Health Evaluation Status' field to In progress
   * @author Anupreeta Chakraborty (Deloitte) | 9/30/2020
   * @return void
   **/
  @isTest static void updateMentalHealthEvaluationStatusInProgress() {
    {
      UAC_HealthEvaluation__c objMental;
      String strInitialMentalRecordType = Label.UAC_healthEvaluationRecordTypeApiNameInitialMental;
      Test.startTest();
      Contact objUACContactAC =
          new UAC_testContactBuilder()
              .setANumber(STR_A_NUM_UAC)
              .setEmail(STR_A_NUM_UAC + '@example.invalid')
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
              .buildAndSave();
      objMental = new UAC_testHealthEvaluationBuilder()
                   .setUAC(objUACContactAC.Id)
                   .setRecordTypeDeveloperName(strInitialMentalRecordType)
                   .buildAndSave();
      objMental.UAC_mentalStatusEvaluationStatus__c = Label.UAC_statusInProgress;
      
      update objMental;
      UAC_HealthEvaluation__c objMentalonUpdate =
          [select id, UAC_mentalHealthEvaluationStatus__c from UAC_HealthEvaluation__c where Id
            =:objMental.id LIMIT 1];
      System.assertEquals(objMentalonUpdate.UAC_mentalHealthEvaluationStatus__c, Label.UAC_statusInProgress);
      Test.stopTest();
    }
  }
  
      /**
   * @description ORRUAC-949: Method to test update of 'Mental Health Evaluation Status' field to complete
   * @author Anupreeta Chakraborty (Deloitte) | 9/30/2020
   * @return void
   **/
  @isTest static void updateMentalHealthEvaluationStatusComplete() {
    {
      UAC_HealthEvaluation__c objMental;
      String strInitialMentalRecordType = Label.UAC_healthEvaluationRecordTypeApiNameInitialMental;
      Test.startTest();
      Contact objUACContactAC =
          new UAC_testContactBuilder()
              .setANumber(STR_A_NUM_UAC)
              .setEmail(STR_A_NUM_UAC + '@example.invalid')
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
              .buildAndSave();
      objMental = new UAC_testHealthEvaluationBuilder()
                   .setUAC(objUACContactAC.Id)
                   .setRecordTypeDeveloperName(strInitialMentalRecordType)
                   .buildAndSave();
      objMental.UAC_mentalStatusEvaluationStatus__c = Label.UAC_statusComplete;
      objMental.UAC_suicidalHomicidalRiskStatus__c = Label.UAC_statusComplete;
      objMental.UAC_substanceUseHistoryStatus__c = Label.UAC_statusComplete;
      objMental.UAC_evaluationSummaryStatus__c = Label.UAC_statusComplete;
      update objMental;
      UAC_HealthEvaluation__c objMentalonUpdate =
          [select id, UAC_mentalHealthEvaluationStatus__c from UAC_HealthEvaluation__c where Id
            =:objMental.id LIMIT 1];
      System.assertEquals(objMentalonUpdate.UAC_mentalHealthEvaluationStatus__c, Label.UAC_statusComplete);
      Test.stopTest();
    }
  }
     /**
   * @description ORRUAC-2832: Method to test update of 'EvaluationSummaryStatus' field to complete
   * @author Ranjith (AI-Vets) | 10/02/2020
   * @return void
   **/
    @isTest static void updateEvaluationSummaryStatusComplete() {
    {
      UAC_HealthEvaluation__c objMental;
      String strInitialMentalRecordType = Label.UAC_healthEvaluationRecordTypeApiNameInitialMental;
      Test.startTest();
      Contact objUACContactAC =
          new UAC_testContactBuilder()
              .setANumber(STR_A_NUM_UAC)
              .setEmail(STR_A_NUM_UAC + '@example.invalid')
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
              .buildAndSave();
      objMental = new UAC_testHealthEvaluationBuilder()
                   .setUAC(objUACContactAC.Id)
                   .setRecordTypeDeveloperName(strInitialMentalRecordType)
                   .buildAndSave();
        
      User Clinicianuser = UAC_TestUtility.createUser('Clinician');  
      objMental.UAC_dueDate__c = System.today();
      objMental.UAC_nameofClinician__c = Clinicianuser.Id;
      objMental.UAC_recommendation__c = 'Test';
      objMental.UAC_dateCompleted__c = system.today();
      update objMental;
      UAC_HealthEvaluation__c objMentalonUpdate =
          [select id, UAC_evaluationSummaryStatus__c from UAC_HealthEvaluation__c where Id
            =:objMental.id LIMIT 1];
      System.assertEquals(objMentalonUpdate.UAC_evaluationSummaryStatus__c, Label.UAC_statusComplete);
      Test.stopTest();
    }
  }
         /**
   * @description ORRUAC-2832: Method to test update of 'EvaluationSummaryStatus' field to complete
   * @author Anupreeta Chakraborty (Deloitte) | 10/05/2020
   * @return void
   **/
    @isTest static void updateCertificationDateTime() {
    {
      UAC_HealthEvaluation__c objClinicalContact;
      String strClinicalContactRecordType = Label.UAC_healthEvaluationRecordTypeApiNameClinicalContact;
      Test.startTest();
      Contact objUACContactAC =
          new UAC_testContactBuilder()
              .setANumber(STR_A_NUM_UAC)
              .setEmail(STR_A_NUM_UAC + '@example.invalid')
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
              .buildAndSave();
      objClinicalContact = new UAC_testHealthEvaluationBuilder()
                   .setUAC(objUACContactAC.Id)
                   .setRecordTypeDeveloperName(strClinicalContactRecordType)
                   .buildAndSave();
        
      User Clinicianuser = UAC_TestUtility.createUser('Clinician');  
      objClinicalContact.UAC_dueDate__c = System.today();
      objClinicalContact.UAC_nameofClinician__c = Clinicianuser.Id;
      objClinicalContact.UAC_recommendation__c = 'Test';
      objClinicalContact.UAC_dateCompleted__c = system.today();
      objClinicalContact.UAC_certificationConfirmation__c = true;
      objClinicalContact.UAC_staffName__c = Clinicianuser.Id;
      objClinicalContact.UAC_staffTitle__c = 'Mr.';
      update objClinicalContact;
      UAC_HealthEvaluation__c objClinicalConUpdate =
          [select id, UAC_certificationDateTime__c from UAC_HealthEvaluation__c where Id
            =:objClinicalContact.id LIMIT 1];
      System.assertNotEquals(objClinicalConUpdate.UAC_certificationDateTime__c, null);
      Test.stopTest();
    }
  }

  /**
   * @description ORRUAC-3049: Method to test create Health Task when "UAC Needs to See
   *Pediatrician?" = Yes
   * @author Abhisek Pati (Deloitte) | 10-21-2020
   * @return void
   **/
  @isTest static void createHealthTaskTest() {
    {
      UAC_HealthEvaluation__c objMental;
      String strMentalHealthServiceReportRecordType =
          Label.UAC_healthEvaluationRecordTypeApiNameMentalHealthServiceReport;
      Contact objUACContactAC =
          new UAC_testContactBuilder()
              .setANumber(STR_A_NUM_UAC)
              .setEmail(STR_A_NUM_UAC + '@example.invalid')
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
              .buildAndSave();
      objMental = new UAC_testHealthEvaluationBuilder()
                      .setUAC(objUACContactAC.Id)
                      .setRecordTypeDeveloperName(strMentalHealthServiceReportRecordType)
                      .buildAndSave();
      Test.startTest();
      objMental.UAC_needstoSeePediatrician__c = 'Yes';
      update objMental;
      Task objHealthTask =
          [select id from Task where UAC_associatedHealthEvaluation__c =:objMental.id LIMIT 1];
      System.assertNotEquals(objHealthTask.Id, null);
      Test.stopTest();
    }
  }
}