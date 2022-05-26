/**
 * @File Name         : UAC_flowUpdateIMETest
 * @Description       : Test class for UAC_flowUpdateIME class
 * @Group             : UAC_flowUpdateIME
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 11-19-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-14-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   11-18-2020   Abhisek Pati (Deloitte)    ORRUAC-4230 Added test coverage
 * 1.2   11-30-2020   Abhisek Pati (Deloitte)    ORRUAC-4378 Added test coverage
 * 1.3   03-22-2020   Abhisek Pati (Deloitte)    ORRUAC-5563 Added Risk Lab Records
 **/
@isTest public class UAC_flowUpdateIMETest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_TEST_CLASS_NAME = UAC_flowUpdateIMETest.class.getName();

  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
  }

  @isTest static void updateIMEShouldUpdateIMERecord() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage, 'Test method: updateIMEShouldUpdateIMERecord() failed.');
  }

  /**
   * @description Test Method to validate update of PsychosocialRiskSection.
   * * @author Karthi Subrmanian (Deloitte) | 07-17-2020
   * @param N/A
   * @return N/A
   **/
  @isTest static void testUpdateIMEPsychosocialRiskSection() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for PsychosocialRiskSection
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objIME.UAC_feelsEmptyHopelessSadNumb__c = null;
    objIME.UAC_feelsWorriedAnxiousNervous__c = null;
    objIME.UAC_extremeMoodSwings__c = null;
    objIME.UAC_feelsEmptyHopelessSadNumb__c = null;
    objIME.UAC_injectionDrugs__c = false;
    objIME.UAC_historyofSubstanceUse__c = 'No, with No Obvious Signs/Symptoms Present';
    objIME.UAC_conSexActORRCustSpecifyWhoWhenWhere__c = 'Test';
    objIME.UAC_consexActInORRCustody__c = true;
    objIME.UAC_consensualSexualActivity__c = true;
    objIME.UAC_sexualActivityOralVaginalAnal__c = 'Yes';
    objIME.UAC_victimofPhysicalAbuse__c = 'No, with No Obvious Signs/Symptoms Present';
    objIME.UAC_mentalHealthConcernsPast3Months__c = 'No, but Obvious Signs/Symptoms Present';
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMEPsychosocialRisk;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEPsychosocialRiskSection() failed.');
  }

  /**
   * @description Test Method to validate update of PsychosocialRiskSection.
   * * @author Karthi Subrmanian (Deloitte) | 07-17-2020
   * @param N/A
   * @return N/A
   **/
  @isTest static void testUpdateIMEPsychosocialRiskSectionNegativeScenario() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for PsychosocialRiskSection
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objIME.UAC_feelsEmptyHopelessSadNumb__c = null;
    objIME.UAC_feelsWorriedAnxiousNervous__c = null;
    objIME.UAC_extremeMoodSwings__c = null;
    objIME.UAC_feelsEmptyHopelessSadNumb__c = null;
    objIME.UAC_injectionDrugs__c = false;
    objIME.UAC_historyofSubstanceUse__c = 'No, with No Obvious Signs/Symptoms Present';
    objIME.UAC_conSexActORRCustSpecifyWhoWhenWhere__c = 'Test';
    objIME.UAC_consexActInORRCustody__c = true;
    objIME.UAC_consensualSexualActivity__c = true;
    objIME.UAC_monthsSinceLastConsensualSex__c =
        'If Date is Unknown, Number of Months Since Last Nonconsensual Sexual Encounter';
    objIME.UAC_sexualActivityOralVaginalAnal__c = 'Yes';
    objIME.UAC_victimofPhysicalAbuse__c = 'No, with No Obvious Signs/Symptoms Present';
    objIME.UAC_mentalHealthConcernsPast3Months__c = 'No, but Obvious Signs/Symptoms Present';
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMEPsychosocialRisk;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertNotEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEPsychosocialRiskSectionNegativeScenario() failed.');
  }
  /**
   * @description Test Method to validate update of LabTest
   * * @author Manoj Bhagwat (EM) | 07-29-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMELabTestSection() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    UAC_testLabTestBuilder tb = new UAC_testLabTestBuilder();
    tb.setHealthEvaluation(objIME.Id);
    tb.setUAC(objIME.UAC_associatedUAC__c);
    List<UAC_test__c> laptests = tb.buildAndSave();
    // update values with sample data for General Information Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage, 'Test method: testUpdateIMELabTestSection() failed.');
  }
  /**
   * @description Test Method to validate update of GeneralInformationSection.
   * * @author Anupreeta Chakraborty (Deloitte) | 07-20-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEGeneralInformationSection() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for General Information Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_generalInformationSectionName;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEGeneralInformationSection() failed.');
  }

  /**
   * @description Test Method to validate update of
   *ReviewofSystem&PhysicalInformationSection.
   * * @author Anupreeta Chakraborty (Deloitte) | 07-20-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEReviewofSystemandPhysicalInformationSection() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for Review of System & Physical
    // Information Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objIME.UAC_signsSymptomsObservedReported__c = Label.UAC_No;
    UAC_physicalExam__c objPhysicalExam = new UAC_physicalExam__c();
    objPhysicalExam.UAC_associatedHealthEvaluation__c = objIME.id;
    objPhysicalExam.UAC_associatedUAC__c = objUACContact.id;
    objPhysicalExam.UAC_physicalSystem__c = 'General Appearance';
    insert objPhysicalExam;
    List<UAC_physicalExam__c> lstPhysicalExam = [Select Id,
      UAC_status__c,
      name from UAC_physicalExam__c where UAC_associatedHealthEvaluation__c =:objIME.Id];
    lstPhysicalExam[0].UAC_status__c = 'Normal';
    Update lstPhysicalExam;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_reviewOfSystem_PhysicalSectionName;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEReviewofSystemandPhysicalInformationSection() failed.');
  }

  /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * * @author Ranjith Kumar (Deloitte) | 07-28-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMETBLabTesting() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for TB Lab Testing
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
    Test.startTest();
    /////
    objIME.UAC_ageAtAdmission__c = 16.0;
    Update objIME;
    List<UAC_test__c> uacTestRecs = new List<UAC_test__c>{
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id)};
    Insert uacTestRecs;
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    // Delete uacTestRecs;
    uacTestRecs[0].UAC_result__c = 'Negative (Not Reactive, Not Detected)';
    update uacTestRecs;
    List<UAC_test__c> uacTestRecs2 = new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
        Label.UAC_testRecTypeImagingStudy, 'Normal', objIME.Id, objUACContact.Id)};
    Insert uacTestRecs2;
    UAC_flowUpdateIME.Response objResponse2 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Delete uacTestRecs;
    Delete uacTestRecs2;
    UAC_flowUpdateIME.Response objResponse3 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    ////
    objIME.UAC_ageAtAdmission__c = 1.0;
    Update objIME;
    List<UAC_test__c> uacTestRecs3 = new List<UAC_test__c>{
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreeningUnder2YearsAge,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id)};
    Insert uacTestRecs3;
    UAC_flowUpdateIME.Response objResponse4 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Delete uacTestRecs3;
    List<UAC_test__c> uacTestRecs4 = new List<UAC_test__c>{
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeBacteriologicalResults,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id)};
    Insert uacTestRecs4;
    UAC_flowUpdateIME.Response objResponse5 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Delete uacTestRecs4;
    ///
    List<UAC_test__c> uacTestRecs5 = new List<UAC_test__c>{
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreeningUnder2YearsAge,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeBacteriologicalResults,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id)};
    Insert uacTestRecs5;
    UAC_flowUpdateIME.Response objResponse6 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    /** Above 2 years Test Data */
    objIME.UAC_ageAtAdmission__c = 3.0;
    Update objIME;
    List<UAC_test__c> uacTestRecs6 = new List<UAC_test__c>{
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreeningUnder2YearsAge,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeImagingStudy,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeBacteriologicalResults,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id)};
    Insert uacTestRecs6;
    UAC_flowUpdateIME.Response objResponse7 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    /** Above 15Yrs Test Data */

    objIME.UAC_ageAtAdmission__c = 16.0;
    Update objIME;
    List<UAC_test__c> uacTestRecs7 = new List<UAC_test__c>{
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeTBScreeningUnder2YearsAge,
            Label.UAC_resultPicklistPositive,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeImagingStudy,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id),
        UAC_testLabTestBuilder.uacTbTestRecord(Label.UAC_testRecTypeBacteriologicalResults,
            Label.UAC_testPicklistPending,
            objIME.Id,
            objUACContact.Id)};
    Insert uacTestRecs7;
    UAC_flowUpdateIME.Response objResponse8 =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage, 'Test method: testUpdateIMETBLabTesting() failed.');
  }

  /**
   * @description Test Method to validate update of Diagnosis and Plan section.
   * * @author Anupreeta Chakraborty (Deloitte) | 08-11-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEDiagnosisAndPlanSection() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for Diagnosis and Plan Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objIME.UAC_diagnosesMedsReferrals__c = Label.UAC_Yes;
    objIME.UAC_immunizationsAdministered__c = Label.UAC_Yes;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_imeSectionDiagnosisAndPlan;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEDiagnosisAndPlanSection() failed.');
  }

  /**
   * @description Test Method to validate update of Diagnosis and Plan section.
   * * @author Anupreeta Chakraborty (Deloitte) | 08-11-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEDiagnosisAndPlanSectionValidateRelatedDiagnosis() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // Create Diagnosis associated with IME with status working.
    UAC_Diagnosis__c objDiagnosis1 = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);
    objDiagnosis1.UAC_associatedHealthEvaluation__c = objIME.id;
    update objDiagnosis1;
    // update values with sample data for Diagnosis and Plan Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_imeSectionDiagnosisAndPlan;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEDiagnosisAndPlanSection() failed.');
  }

  /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Karthi Subramanian (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEContactTracingStatusCheckNotStarted() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for Contact tracing Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_IMESectionContactTracing;
    // Create and associate exposure event
    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    exposoureEvent.UAC_associatedHealthEvaluation__c = objIME.id;
    exposoureEvent.UAC_PHIStatus__c = Label.UAC_PHIStatusNotStarted;
    insert exposoureEvent;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEContactTracingStatusCheckNotStarted() failed.');
  }

  /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Karthi Subramanian (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEContactTracingStatusCheckInProgress() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for Contact tracing Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_IMESectionContactTracing;
    // Create and associate exposure event
    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    exposoureEvent.UAC_associatedHealthEvaluation__c = objIME.id;
    exposoureEvent.UAC_PHIStatus__c = Label.UAC_contactTracingStatusInProgress;
    insert exposoureEvent;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEContactTracingStatusCheckInProgress() failed.');
  }

  /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Karthi Subramanian (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEContactTracingStatusCheckComplete() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for Contact tracing Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_IMESectionContactTracing;
    // Create and associate exposure event
    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    exposoureEvent.UAC_associatedHealthEvaluation__c = objIME.id;
    exposoureEvent.UAC_PHIStatus__c = Label.UAC_contactTracingStatusComplete;
    insert exposoureEvent;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEContactTracingStatusCheckComplete() failed.');
  }

  /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Karthi Subramanian (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMEContactTracingStatusCheckNotApplicable() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    // update values with sample data for Contact tracing Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_IMESectionContactTracing;
    // No exposure event associated with IME
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMEContactTracingStatusCheckNotApplicable() failed.');
  }

  /**
   * @description Test Method to validate update of LabTest
   * * @author Anupreeta Chakraborty (Deloitte) | 11-19-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMELabTestSectionWithValidResults() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    UAC_test__c objRiskTest = new UAC_test__c();
    objRiskTest.UAC_diseaseConditionTested__c = Label.UAC_testPicklistSyphilis;
    objRiskTest.UAC_associatedHealthEvaluation__c = objIME.id;
    objRiskTest.UAC_associatedUAC__c = objUACContact.id;
    objRiskTest.UAC_test__c= 'NAAT/PCR';
    objRiskTest.UAC_result__c = 'Pending';
    objRiskTest.UAC_specimenSource__c = 'Blood/Serum';
    objRiskTest.RecordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c');    
    insert objRiskTest;

    // Fetch All the Risk based test records
    List<UAC_test__c> labtests = [select id,
      UAC_result__c from UAC_test__c where recordtype.developername =
          'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c =:objIME.Id];
    // Update status of Risk based tests to 'Not Done'
    for (UAC_test__c objTest : labtests) {
      objTest.UAC_result__c = 'Not Done';
      lstUpdateTest.add(objTest);
    }
    update lstUpdateTest;

    // update values with sample data for Lab test Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse =
        UAC_flowUpdateIME.updateIME(new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: testUpdateIMELabTestSectionWithValidResults() failed.');
  }
  
    /**
   * @description Test Method to validate update of LabTest
   * * @author Anupreeta Chakraborty (Deloitte) | 11-25-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMELabTestSectionWithConfPending() {
    Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
        .get('UAC_confirmatoryLabTest').getRecordTypeId();
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
    STR_A_NUM_UAC, new Set<String>{'Id'});
    List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    UAC_test__c objRiskTest = new UAC_test__c();
    objRiskTest.UAC_diseaseConditionTested__c = Label.UAC_testPicklistSyphilis;
    objRiskTest.UAC_associatedHealthEvaluation__c = objIME.id;
    objRiskTest.UAC_associatedUAC__c = objUACContact.id;
    objRiskTest.UAC_test__c= 'NAAT/PCR';
    objRiskTest.UAC_result__c = 'Pending';
    objRiskTest.UAC_specimenSource__c = 'Blood/Serum';
    objRiskTest.RecordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c');    
    insert objRiskTest;
    //Fetch All the Risk based test records
    List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objIME.Id];
    //Update result of Risk based tests to 'Not Done' and Hep B to positive.
    for(UAC_test__c objTest : labtests){
    if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB){
    objTest.UAC_result__c = Label.UAC_testPicklistPositive;
    objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
    }   
    else {
    objTest.UAC_result__c = 'Not Done';
    }
    lstUpdateTest.add(objTest);
    }
    update lstUpdateTest;
    
    //Create Conf lab test records
    UAC_test__c uacTest = new UAC_test__c(UAC_test__c = 'HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)',
                                              UAC_result__c='Pending',
                                              RecordTypeId= recordTypeId,
                                              UAC_associatedHealthEvaluation__c= objIME.Id,
                                              UAC_diseaseConditionTested__c='HIV',
                                              UAC_associatedUAC__c = objIME.UAC_associatedUAC__c,
                                              UAC_testType__c='QuantiFERON',
                                              UAC_specimenSource__c='Blood/Serum',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        insert uacTest;    
    
    // update values with sample data for Lab test Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse = UAC_flowUpdateIME.updateIME(
        new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
     System.assertEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSectionWithConfPending() failed.');
  }
  
    /**
   * @description Test Method to validate update of LabTest
   * * @author Anupreeta Chakraborty (Deloitte) | 11-25-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateIMELabTestSectionWithHepBPositive() {
    Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
        .get('UAC_confirmatoryLabTest').getRecordTypeId();
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
    STR_A_NUM_UAC, new Set<String>{'Id'});
    List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    UAC_test__c objRiskTest = new UAC_test__c();
    objRiskTest.UAC_diseaseConditionTested__c = Label.UAC_testPicklistSyphilis;
    objRiskTest.UAC_associatedHealthEvaluation__c = objIME.id;
    objRiskTest.UAC_associatedUAC__c = objUACContact.id;
    objRiskTest.UAC_test__c= 'NAAT/PCR';
    objRiskTest.UAC_result__c = 'Pending';
    objRiskTest.UAC_specimenSource__c = 'Blood/Serum';
    objRiskTest.RecordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c');    
    insert objRiskTest;

    //Fetch All the Risk based test records
    List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objIME.Id];
    //Update result of Risk based tests to 'Not Done' and Hep B to positive.
    for(UAC_test__c objTest : labtests){
    if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB){
    objTest.UAC_result__c = Label.UAC_testPicklistPositive;
    objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
    }   
    else {
    objTest.UAC_result__c = 'Not Done';
    }
    lstUpdateTest.add(objTest);
    }
    update lstUpdateTest;
    
    //Create Conf lab test records
    UAC_test__c uacTest = new UAC_test__c(UAC_test__c = 'HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)',
                                              UAC_result__c='Indeterminate',
                                              RecordTypeId= recordTypeId,
                                              UAC_associatedHealthEvaluation__c= objIME.Id,
                                              UAC_diseaseConditionTested__c='HIV',
                                              UAC_associatedUAC__c = objIME.UAC_associatedUAC__c,
                                              UAC_testType__c='QuantiFERON',
                                              UAC_specimenSource__c='Blood/Serum',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        insert uacTest;    
    
    // update values with sample data for Lab test Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse = UAC_flowUpdateIME.updateIME(
        new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
     System.assertEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSectionWithHepBPositive() failed.');
  }
  
    /**
   * @description Test Method to validate update of LabTest
   * * @author Anupreeta Chakraborty (Deloitte) | 11-25-2020
   * @param N/A
   * @return N/A
   **/  
  
    @isTest static void testUpdateIMELabTestSectionWithHepCPositive() {
    Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
        .get('UAC_confirmatoryLabTest').getRecordTypeId();
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
    STR_A_NUM_UAC, new Set<String>{'Id'});
    List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    
    UAC_test__c objRiskTest = new UAC_test__c();
    objRiskTest.UAC_diseaseConditionTested__c = Label.UAC_testPicklistSyphilis;
    objRiskTest.UAC_associatedHealthEvaluation__c = objIME.id;
    objRiskTest.UAC_associatedUAC__c = objUACContact.id;
    objRiskTest.UAC_test__c= 'NAAT/PCR';
    objRiskTest.UAC_result__c = 'Pending';
    objRiskTest.UAC_specimenSource__c = 'Blood/Serum';
    objRiskTest.RecordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c');    
    insert objRiskTest;
    //Fetch All the Risk based test records
    List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objIME.Id];
    //Update result of Risk based tests to 'Not Done' and Hep C to positive.
    for(UAC_test__c objTest : labtests){
    if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisC){
    objTest.UAC_result__c = Label.UAC_testPicklistPositive;
    objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
    }   
    else {
    objTest.UAC_result__c = 'Not Done';
    }
    lstUpdateTest.add(objTest);
    }
    update lstUpdateTest;
    
    //Create Conf lab test records
    UAC_test__c uacTest = new UAC_test__c(UAC_test__c = 'HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)',
                                              UAC_result__c='Indeterminate',
                                              RecordTypeId= recordTypeId,
                                              UAC_associatedHealthEvaluation__c= objIME.Id,
                                              UAC_diseaseConditionTested__c='HIV',
                                              UAC_associatedUAC__c = objIME.UAC_associatedUAC__c,
                                              UAC_testType__c='QuantiFERON',
                                              UAC_specimenSource__c='Blood/Serum',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        insert uacTest;    
    
    // update values with sample data for Lab test Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse = UAC_flowUpdateIME.updateIME(
        new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
     System.assertEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSectionWithHepCPositive() failed.');
  }
  
    /**
   * @description Test Method to validate update of LabTest
   * * @author Anupreeta Chakraborty (Deloitte) | 11-25-2020
   * @param N/A
   * @return N/A
   **/  
  
    @isTest static void testUpdateIMELabTestSectionWithSyphillisPositive() {
    Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
        .get('UAC_confirmatoryLabTest').getRecordTypeId();
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
    STR_A_NUM_UAC, new Set<String>{'Id'});
    List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    UAC_test__c objRiskTest = new UAC_test__c();
    objRiskTest.UAC_diseaseConditionTested__c = Label.UAC_testPicklistSyphilis;
    objRiskTest.UAC_associatedHealthEvaluation__c = objIME.id;
    objRiskTest.UAC_associatedUAC__c = objUACContact.id;
    objRiskTest.UAC_test__c= 'NAAT/PCR';
    objRiskTest.UAC_result__c = 'Pending';
    objRiskTest.UAC_specimenSource__c = 'Blood/Serum';
    objRiskTest.RecordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c');    
    insert objRiskTest;

    //Fetch All the Risk based test records
    List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objIME.Id];
    //Update result of Risk based tests to 'Not Done' and Hep C to positive.
    for(UAC_test__c objTest : labtests){
    if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistSyphilis){
    objTest.UAC_result__c = Label.UAC_testPicklistPositive;
    objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
    }   
    else {
    objTest.UAC_result__c = 'Not Done';
    }
    lstUpdateTest.add(objTest);
    }
    update lstUpdateTest;
    
    //Create Conf lab test records
    UAC_test__c uacTest = new UAC_test__c(UAC_test__c = 'HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)',
                                              UAC_result__c='Indeterminate',
                                              RecordTypeId= recordTypeId,
                                              UAC_associatedHealthEvaluation__c= objIME.Id,
                                              UAC_diseaseConditionTested__c='HIV',
                                              UAC_associatedUAC__c = objIME.UAC_associatedUAC__c,
                                              UAC_testType__c='QuantiFERON',
                                              UAC_specimenSource__c='Blood/Serum',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        insert uacTest;    
    
    // update values with sample data for Lab test Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse = UAC_flowUpdateIME.updateIME(
        new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
     System.assertEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSectionWithHepCPositive() failed.');
  }  
  
      /**
   * @description Test Method to validate update of LabTest
   * * @author Anupreeta Chakraborty (Deloitte) | 11-25-2020
   * @param N/A
   * @return N/A
   **/  
  
    @isTest static void testUpdateIMELabTestSectionWithHIVPositive() {
    Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
        .get('UAC_confirmatoryLabTest').getRecordTypeId();
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
    STR_A_NUM_UAC, new Set<String>{'Id'});
    List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    UAC_test__c objRiskTest = new UAC_test__c();
    objRiskTest.UAC_diseaseConditionTested__c = Label.UAC_testPicklistSyphilis;
    objRiskTest.UAC_associatedHealthEvaluation__c = objIME.id;
    objRiskTest.UAC_associatedUAC__c = objUACContact.id;
    objRiskTest.UAC_test__c= 'NAAT/PCR';
    objRiskTest.UAC_result__c = 'Pending';
    objRiskTest.UAC_specimenSource__c = 'Blood/Serum';
    objRiskTest.RecordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c');    
    insert objRiskTest;

    //Fetch All the Risk based test records
    List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objIME.Id];
    //Update result of Risk based tests to 'Not Done' and Hep C to positive.
    for(UAC_test__c objTest : labtests){
    if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHIV){
    objTest.UAC_result__c = Label.UAC_testPicklistPositive;
    objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
    }   
    else {
    objTest.UAC_result__c = 'Not Done';
    }
    lstUpdateTest.add(objTest);
    }
    update lstUpdateTest;
    
    //Create Conf lab test records
    UAC_test__c uacTest = new UAC_test__c(UAC_test__c = Label.UAC_testHepatitisBSurfaceAntibody,
                                              UAC_result__c='Indeterminate',
                                              RecordTypeId= recordTypeId,
                                              UAC_associatedHealthEvaluation__c= objIME.Id,
                                              UAC_diseaseConditionTested__c = Label.UAC_testPicklistHepatitisB,
                                              UAC_associatedUAC__c = objIME.UAC_associatedUAC__c,
                                              UAC_specimenSource__c='Blood/Serum',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        insert uacTest;    
    
    // update values with sample data for Lab test Section
    objIME.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIME.Request objRequest = new UAC_flowUpdateIME.Request();
    objRequest.objRecord = objIME;
    objRequest.strSectionName = Label.UAC_sectionIMELabTest;
    Test.startTest();
    UAC_flowUpdateIME.Response objResponse = UAC_flowUpdateIME.updateIME(
        new List<UAC_flowUpdateIME.Request>{objRequest})[0];
    Test.stopTest();
     System.assertEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSectionWithHIVPositive() failed.');
  }    
}