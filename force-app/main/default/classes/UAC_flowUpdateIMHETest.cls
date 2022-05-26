/**
 * @File Name         : UAC_flowUpdateIMHETest
 * @Description       : Test class for UAC_flowUpdateIME class
 * @Group             : UAC_flowUpdateIMHE
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 11-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-29-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   10-01-2020   Abhisek Pati (Deloitte)    Added Test class for Suicidal Homicidal Risk Assessment
 * 1.2   11-03-2020   Karthi Subramanian (Deloitte)    use of setRecordTypeDeveloperName method of test builder

 **/
@isTest public class UAC_flowUpdateIMHETest {

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

  @isTest static void updateIHMEShouldUpdateIMHERecord() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIMHE =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameInitialMental)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    objIMHE.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIMHE.Request objRequest = new UAC_flowUpdateIMHE.Request();
    objRequest.objRecord = objIMHE;
    objRequest.strSectionName = Label.UAC_imheSectionMentalStatusEvaluation;
    Test.startTest();
    UAC_flowUpdateIMHE.Response objResponse =
        UAC_flowUpdateIMHE.updateIMHE(new List<UAC_flowUpdateIMHE.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage, 'Test method:updateIMEShouldUpdateIMERecord() failed.');
  }

    /**
   * @description Test Method to validate update of testUpdateIMHESubstanceUseHistory.
   * * @author Karthi Subrmanian (Deloitte) | 10-01-2020
   * @param N/A
   * @return N/A
   **/
  @isTest static void testUpdateIMHESubstanceUseHistory() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
        UAC_healthEvaluation__c objIMHE =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameInitialMental)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    objIMHE.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    // update values with sample data for SubstanceUseHistory
    objIMHE.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objIMHE.UAC_substanceUseHistoryCollectedInIME__c = 'Yes';
    objIMHE.UAC_heroin__c=null;
    objIMHE.UAC_cocaine__c=null;
    objIMHE.UAC_OtherOpiatesOxycodoneMorphineetc__c=null;
    objIMHE.UAC_otherStimulantsMethRitalinetc__c=null;
    objIMHE.UAC_alcohol__c=null;
    objIMHE.UAC_injectionDrugs__c=null;
    objIMHE.UAC_tobaccoNicotine__c=null;
    objIMHE.UAC_marijuana__c=false;
    UAC_flowUpdateIMHE.Request objRequest = new UAC_flowUpdateIMHE.Request();
    objRequest.objRecord = objIMHE;
    objRequest.strSectionName = Label.UAC_imheSectionSubstanceUseHistory;
    Test.startTest();
    UAC_flowUpdateIMHE.Response objResponse = UAC_flowUpdateIMHE.updateIMHE(
        new List<UAC_flowUpdateIMHE.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateIMHESubstanceUseHistory() failed.');
  }
   
   /**
   * @description Test Method to validate update of testUpdateIMHESuicidalHomicidalRiskAssessment.
   * * @author Abhisek Pati (Deloitte) | 10-01-2020
   * @param N/A
   * @return N/A
   **/
  @isTest static void testUpdateIMHESuicidalHomicidalRiskAssessment() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objIMHE =
        new UAC_testHealthEvaluationBuilder()
            .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameInitialMental)
            .setUAC(objUACContact.Id)
            .buildAndSave();
    objIMHE.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateIMHE.Request objRequest = new UAC_flowUpdateIMHE.Request();
    objRequest.objRecord = objIMHE;
    objRequest.strSectionName = Label.UAC_imheSectionSuicidalHomicidalRiskAssessment;
    Test.startTest();
    UAC_flowUpdateIMHE.Response objResponse =
        UAC_flowUpdateIMHE.updateIMHE(new List<UAC_flowUpdateIMHE.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage, 'Test method:testUpdateIMHESuicidalHomicidalRiskAssessment() failed.');
  }
}