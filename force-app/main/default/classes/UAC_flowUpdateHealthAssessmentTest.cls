/**
 * @File Name         : UAC_flowUpdateHealthAssessmentTest
 * @Description       : Test class for UAC_flowUpdateHealthAssessment class
 * @Group             : UAC_flowUpdateHealthAssessment
 * @Author            : Anupreeta Chakraborty (Deloitte)
 * @Last Modified By  : Anupreeta Chakraborty (Deloitte)
 * @Last Modified On  : 08-17-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-18-2020   Anupreeta Chakraborty (Deloitte)   Initial Version
 * 1.1   08-25-2020   Abhisek Pati (Deloitte)            Added TB Lab Testing Code ORRUAC-1152
 * 1.2   09-01-2020   Abhisek Pati (Deloitte)            Added Status Integration ORRUAC-1965
 * 1.3   02-22-2021   Abhisek Pati (Deloitte)            Added Code Coverage
 **/
@isTest public class UAC_flowUpdateHealthAssessmentTest {
    private
      static final String STR_A_NUM_UAC = '123456';
    private
      static final String STR_TEST_CLASS_NAME =
          UAC_flowUpdateHealthAssessmentTest.class.getName();
    
      @TestSetup static void setupData() {
        Contact objUACContact =
            new UAC_testContactBuilder()
                .setANumber(STR_A_NUM_UAC)
                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                .buildAndSave();
      }
      
      /**
       * @description Test Method to validate update of GeneralInformationSection.
       * * @author Anupreeta Chakraborty (Deloitte) | 08-17-2020
       * @param N/A
       * @return N/A
       **/
    
      @isTest static void testUpdateHAGeneralInformationSection() {
        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
            STR_A_NUM_UAC, new Set<String>{'Id'});
        UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                             .setUAC(objUACContact.Id)
                                             .buildAndSave();
        // update values with sample data for General Information Section
        objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
        UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
        objRequest.objRecord = objHA;
        objRequest.strSectionName = Label.UAC_generalInformationSectionNameHA;
        Test.startTest();
        UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
            new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
        Test.stopTest();
        System.assertEquals(
            null, objResponse.errorMessage,
            'Test method: testUpdateHAGeneralInformationSection() failed.');
      }
      /**
       * @description Test Method to validate update of
       *ReviewofSystem&PhysicalInformationSection.
       * * @author Karthi Subramanian (Deloitte) | 08-19-2020
       * @param N/A
       * @return N/A
      **/
    
      @isTest static void
      testUpdateHAReviewofSystemandPhysicalInformationSection() {
        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
            STR_A_NUM_UAC, new Set<String>{'Id'});
        UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                             .setUAC(objUACContact.Id)
                                             .buildAndSave();
        // update values with sample data for Review of System & Physical
        // Information Section
        objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
        objHA.UAC_signsSymptomsObservedReported__c=Label.UAC_No;
        objHA.UAC_physicalExamPerformedbyHCP__c = Label.UAC_No;
        UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
        objRequest.objRecord = objHA;
        objRequest.strSectionName = Label.UAC_reviewOfSystem_PhysicalSectionName;
        Test.startTest();
        UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
            new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
        Test.stopTest();
        System.assertEquals(
            null, objResponse.errorMessage,
            'Test method: testUpdateHAReviewofSystemandPhysicalInformationSection() failed.');
      }
      
        /**
       * @description Test Method to validate update of History and Physical Assessment Section.
       * * @author Anupreeta Chakraborty (Deloitte) | 08-19-2020
       * @param N/A
       * @return N/A
       **/
    
      @isTest static void testUpdateHAHistoryandPhysicalAssmntSection() {
        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
            STR_A_NUM_UAC, new Set<String>{'Id'});
        UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                             .setUAC(objUACContact.Id)
                                             .buildAndSave();
        // update values with sample data for General Information Section
        objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
        UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
        objRequest.objRecord = objHA;
        objRequest.strSectionName = Label.UAC_sectionHAHistoryAndPhysicalAssessment;
        Test.startTest();
        UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
            new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
        Test.stopTest();
        System.assertEquals(
            null, objResponse.errorMessage,
            'Test method: testUpdateHAHistoryandPhysicalAssmntSection() failed.');
      }
        
    /**
   * @description Test Method to validate update of RiskBased Lab Test
   * * @author Ranjith Kumar (AI-Vets) | 08-23-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHARiskBasedLabTestSectionOptionNo() {
  //Get Risk based lab test recordtype Id
  Id RiskbasedRecordTypeId = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName().get(Label.UAC_testRecTypeRiskBasedLabTest).getRecordTypeId();

    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    UAC_testLabTestBuilder tb = new UAC_testLabTestBuilder();
    tb.setHealthEvaluation(objHA.Id);
    tb.setUAC(objHA.UAC_associatedUAC__c);
    List<UAC_test__c> labtests = tb.buildAndSave();
    labtests[0].RecordTypeId = RiskbasedRecordTypeId;
    update labtests;
    
    // update values with sample data for Risk Based PRID Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
    UAC_flowUpdateHealthAssessment.Request objRequestNegative =
        new UAC_flowUpdateHealthAssessment.Request();
    objRequestNegative.objRecord = objHA;
    objRequestNegative.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponseNegative =
        UAC_flowUpdateHealthAssessment.updateHA(
            new List<UAC_flowUpdateHealthAssessment.Request>{objRequestNegative})[0];
    objHA.UAC_RiskBasedLabsPerformed__c = Label.UAC_No;
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertNotEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSection() failed.');
  }

    /**
   * @description Test Method to validate update of PRID Lab Test
   * * @author Anupreeta Chakraborty (AI-Vets) | 08-27-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHAPRIDLabTestSectionOptionNo() {
  //Get PRID lab test recordtype Id
  Id PRIDRecordTypeId = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName().get(Label.UAC_testRecTypePRIDLabTest).getRecordTypeId();

    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    UAC_testLabTestBuilder tb = new UAC_testLabTestBuilder();
    tb.setHealthEvaluation(objHA.Id);
    tb.setUAC(objHA.UAC_associatedUAC__c);
    List<UAC_test__c> labtests = tb.buildAndSave();
    labtests[0].RecordTypeId = PRIDRecordTypeId;
    update labtests;
    
    // update values with sample data for Risk Based PRID Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_PRIDLabTestsPerformed__c = Label.UAC_No;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(null, objResponse.errorMessage,
                        'Test method: testUpdateIMELabTestSection() failed.');
  }
  
    /**
   * @description Test Method to validate update of PRID Lab Test
   * * @author Anupreeta Chakraborty (AI-Vets) | 08-27-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHAPRIDLabTestSectionOptionYes() {
  //Get PRID lab test recordtype Id

    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();                                                                       
    LIst<UAC_test__c> lstTest = [select id from UAC_test__c where UAC_associatedHealthEvaluation__c =: objHA.Id];
    delete lstTest;
    // update values with sample data for Risk Based PRID Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_PRIDLabTestsPerformed__c = Label.UAC_Yes;
    
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHAPRIDLabTestSectionOptionYes() failed.');
  }  
      /**
   * @description Test Method to validate update of Risk Based Lab Test
   * * @author Anupreeta Chakraborty (AI-Vets) | 08-27-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHARiskBasedLabTestSectionOptionYes() {
  //Get PRID lab test recordtype Id

    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();                                                                       
    LIst<UAC_test__c> lstTest = [select id from UAC_test__c where UAC_associatedHealthEvaluation__c =: objHA.Id];
    delete lstTest;
    // update values with sample data for Risk Based PRID Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_RiskBasedLabsPerformed__c = Label.UAC_Yes;
    
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertNotEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHARiskBasedLabTestSectionOptionYes() failed.');
  } 

  /**
   * @description Test Method to validate update of RiskBased Lab Test
   * @author Abhisek Pati (Deloitte) | 09-01-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHARiskBasedLabTest() {
    //Get Risk based lab test recordtype Id
      Id RiskbasedRecordTypeId = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName().get(Label.UAC_testRecTypeRiskBasedLabTest).getRecordTypeId();
  
      Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
          STR_A_NUM_UAC, new Set<String>{'Id'});
      UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                           .setUAC(objUACContact.Id)
                                           .buildAndSave();
      
      UAC_test__c testRecord = new UAC_test__c(UAC_associatedHealthEvaluation__c = objHA.Id,
          UAC_associatedUAC__c= objUACContact.Id,
          UAC_diseaseConditionTested__c = 'Acute/Chronic Hepatitis B',
          RecordTypeId = RiskbasedRecordTypeId,
          UAC_result__c = 'Negative (Not Reactive, Not Detected)',
          UAC_specimenCollectionDate__c=System.today()-5,
          UAC_specimenSource__c= 'Blood/Serum',
          UAC_test__c = 'Surface Antigen');
      Insert testRecord;
      
      // update values with sample data for Risk Based PRID Section
      objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
      objHA.UAC_RiskBasedLabsPerformed__c = Label.UAC_Yes;
      UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
      objRequest.objRecord = objHA;
      objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
      Test.startTest();
      UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
          new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
      Test.stopTest();
      System.assertEquals(null, objResponse.errorMessage,
                          'Test method: testUpdateIMELabTestSection() failed.');
    }
	  
       /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Abhisek Pati (Deloitte) | 08-25-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSection() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_wereAnyTBLabTestsPerformed__c = 'No';
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
    List<UAC_test__c> uacTestRecsTST =
          new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
              Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
              Label.UAC_resultPicklistPositive, objHA.Id, objUACContact.Id)};
    Insert uacTestRecsTST;
    List<UAC_test__c> uacTestRecsIGRA =
          new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
              Label.UAC_testRecTypeTBScreeningUnder2YearsAge,
              Label.UAC_resultPicklistPositive, objHA.Id, objUACContact.Id)};
    Insert uacTestRecsIGRA;
    List<UAC_test__c> uacTestRecsImaging =
          new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
              Label.UAC_testRecTypeImagingStudy,
              'Normal', objHA.Id, objUACContact.Id)};
    Insert uacTestRecsImaging;
    List<UAC_test__c> uacTestRecsBact =
          new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
              Label.UAC_testRecTypeBacteriologicalResults,
              Label.UAC_resultPicklistPositive, objHA.Id, objUACContact.Id)};
    Insert uacTestRecsBact;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertNotEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSection() failed.');
  }
    
     /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Abhisek Pati (Deloitte) | 08-25-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSectionNegativeScenario() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_wereAnyTBLabTestsPerformed__c = 'Yes';
    objHA.UAC_healthDepartmentSpecialistDecision__c = Label.UAC_healthEvaluationHealthDeptDecisionWorkUpNeeded;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
      List<UAC_test__c> uacTestRecsTST =
          new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
              Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
              Label.UAC_resultPicklistPositive, objHA.Id, objUACContact.Id)};
    Insert uacTestRecsTST;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSection() failed.');
  }
  
      /**
   * @description Test Method to validate update of Diagnosis and Plan Section.
   * * @author Anupreeta Chakraborty (Deloitte) | 08-24-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHADiagnosisandPlanSection() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Diagnosis and Plan Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionDiagnosisAndPlan;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHADiagnosisandPlanSection() failed.');
  }
  
       /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Anupreeta Chakaborty (Deloitte) | 08-31-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSectionOtherNegativeScenario() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_wereAnyTBLabTestsPerformed__c = Label.UAC_Yes;
    objHA.UAC_healthDepartmentSpecialistDecision__c = Label.UAC_healthEvaluationHealthDeptDecisionWorkUpNeeded;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
    //Delete all tests associated with the health Evaluation
    List<UAC_test__c> lstTest = [select id from UAC_test__c where UAC_associatedHealthEvaluation__c =: objHA.Id];
    delete lstTest;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSectionOtherNegativeScenario() failed.');
  }  
 
      /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Anupreeta Chakaborty (Deloitte) | 08-31-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSectionOtherNegativeScenarioTST() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_PPDTSTTest__c = Label.UAC_Yes;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
    //Delete all tests associated with the health Evaluation
    List<UAC_test__c> lstTest = [select id from UAC_test__c where UAC_associatedHealthEvaluation__c =: objHA.Id];
    delete lstTest;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSectionOtherNegativeScenarioTST() failed.');
  }  
  
        /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Anupreeta Chakaborty (Deloitte) | 08-31-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSectionOtherNegativeScenarioIGRA() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_IGRATBTest__c = Label.UAC_Yes;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
    //Delete all tests associated with the health Evaluation
    List<UAC_test__c> lstTest = [select id from UAC_test__c where UAC_associatedHealthEvaluation__c =: objHA.Id];
    delete lstTest;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSectionOtherNegativeScenarioIGRA() failed.');
  } 
  
          /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Anupreeta Chakaborty (Deloitte) | 08-31-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSectionOtherNegativeScenarioImagingStudy() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_ImagingStudyTBTest__c = Label.UAC_Yes;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
    //Delete all tests associated with the health Evaluation
    List<UAC_test__c> lstTest = [select id from UAC_test__c where UAC_associatedHealthEvaluation__c =: objHA.Id];
    delete lstTest;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSectionOtherNegativeScenarioImagingStudy() failed.');
  }   
  
          /**
   * @description Test Method to validate update of TB Lab Testing Section.
   * @author Anupreeta Chakaborty (Deloitte) | 08-31-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHATBLabTestingSectionNegativeScenarioStatusPending() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for TB Lab Testing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_wereAnyTBLabTestsPerformed__c = Label.UAC_Yes;    
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_tbLabTesting;
      List<UAC_test__c> uacTestRecsTST =
          new List<UAC_test__c>{UAC_testLabTestBuilder.uacTbTestRecord(
              Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder,
              Label.UAC_Pending, objHA.Id, objUACContact.Id)};
    Insert uacTestRecsTST;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHATBLabTestingSectionNegativeScenarioStatusPending() failed.');
  }  
  
     /**
   * @description Test Method to validate update of Diagnosis and Plan section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-13-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHADiagnosisAndPlanSectionStatusCheck() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Diagnosis and Plan Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_diagnosesMedsReferrals__c = Label.UAC_Yes;
    objHA.UAC_immunizationsAdministered__c = Label.UAC_Yes;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionDiagnosisAndPlan;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHADiagnosisAndPlanSectionStatusCheck() failed.');
  } 
 
     /**
   * @description Test Method to validate update of Diagnosis and Plan section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHADiagnosisAndPlanSectionStatusCheckWrkngDiagnosis() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Diagnosis and Plan Section
    //Create diagnosis
    UAC_Diagnosis__c objDiagnosis =  new UAC_testDiagnosisBuilder().buildAndSave(objUACContact); 
    objDiagnosis.UAC_status__c = Label.UAC_diagnosisStatusWorking;
    objDiagnosis.UAC_associatedHealthEvaluation__c = objHA.id;
    update objDiagnosis;
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_diagnosesMedsReferrals__c = Label.UAC_Yes;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionDiagnosisAndPlan;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHADiagnosisAndPlanSectionStatusCheckWrkngDiagnosis() failed.');
  }  
  
       /**
   * @description Test Method to validate update of Diagnosis and Plan section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHADiagnosisAndPlanSectionStatusCheckDiagnosisOutcome() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    //Create another Health Assessment
    UAC_healthEvaluation__c objHA2 = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Diagnosis and Plan Section
    //Create diagnosis associated with second health assessment. No diagnosis outcome created.
    UAC_Diagnosis__c objDiagnosis =  new UAC_testDiagnosisBuilder().buildAndSave(objUACContact); 
    objDiagnosis.UAC_associatedHealthEvaluation__c = objHA2.id;
    update objDiagnosis;
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    objHA.UAC_diagnosesMedsReferrals__c = Label.UAC_Yes;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionDiagnosisAndPlan;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHADiagnosisAndPlanSectionStatusCheckWrkngDiagnosis() failed.');
  }  
  
  
   /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHAContactTracingStatusCheckNotStarted() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Contact tracing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionContactTracing;
    //Create and associate exposure event
    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    exposoureEvent.UAC_associatedHealthEvaluation__c = objHA.id;
    exposoureEvent.UAC_PHIStatus__c = Label.UAC_PHIStatusNotStarted;
    insert exposoureEvent;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHAContactTracingStatusCheckNotStarted() failed.');
  }   

   /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHAContactTracingStatusCheckInProgress() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Contact tracing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionContactTracing;
    //Create and associate exposure event
    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    exposoureEvent.UAC_associatedHealthEvaluation__c = objHA.id;
    exposoureEvent.UAC_PHIStatus__c = Label.UAC_contactTracingStatusInProgress;
    insert exposoureEvent;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHAContactTracingStatusCheckInProgress() failed.');
  }     
  
     /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHAContactTracingStatusCheckComplete() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Contact tracing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionContactTracing;
    //Create and associate exposure event
    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    exposoureEvent.UAC_associatedHealthEvaluation__c = objHA.id;
    exposoureEvent.UAC_PHIStatus__c = Label.UAC_contactTracingStatusComplete;
    insert exposoureEvent;
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHAContactTracingStatusCheckComplete() failed.');
  }
  
       /**
   * @description Test Method to validate update of Contact tracing section.
   * * @author Anupreeta Chakraborty (Deloitte) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateHAContactTracingStatusCheckNotApplicable() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Contact tracing Section
    objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
    objRequest.objRecord = objHA;
    objRequest.strSectionName = Label.UAC_HASectionContactTracing;
    //No exposure event associated
    Test.startTest();
    UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
        new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateHAContactTracingStatusCheckNotApplicable() failed.');
  }  
  
  /**
       * @description Test Method to validate update of LabTest
       * * @author Abhisek Pati (Deloitte) | 02-22-2021
       * @param N/A
       * @return N/A
       **/  
      
      @isTest static void testUpdateHALabTestSectionWithHepCPositive() {
        Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
            .get('UAC_confirmatoryLabTest').getRecordTypeId();
        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
        List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
        UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                             .setUAC(objUACContact.Id)
                                             .buildAndSave();
    
        //Fetch All the Risk based test records
        List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objHA.Id];
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
                                                  UAC_result__c='Pending',
                                                  RecordTypeId= recordTypeId,
                                                  UAC_associatedHealthEvaluation__c= objHA.Id,
                                                  UAC_diseaseConditionTested__c='HIV',
                                                  UAC_associatedUAC__c = objHA.UAC_associatedUAC__c,
                                                  UAC_testType__c='QuantiFERON',
                                                  UAC_specimenSource__c='Blood/Serum',
                                                  UAC_specimenCollectionDate__c = System.today()-10
                                                 );
            insert uacTest;      
        
        // update values with sample data for Lab test Section
        objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
        UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
        objRequest.objRecord = objHA;
        objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
        Test.startTest();
        UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
            new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
        Test.stopTest();
         System.assertEquals(null, objResponse.errorMessage,
                            'Test method: testUpdateHALabTestSectionWithHepCPositive() failed.');
      }
      
            /**
       * @description Test Method to validate update of LabTest
       * * @author Abhisek Pati (Deloitte) | 02-22-2021
       * @param N/A
       * @return N/A
       **/  
      
        @isTest static void testUpdateHAELabTestSectionValidConfTests() {
        Id recordTypeId = Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
            .get('UAC_confirmatoryLabTest').getRecordTypeId();
        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
        List<UAC_test__c> lstUpdateTest = new List<UAC_test__c>();
        UAC_healthEvaluation__c objHA = new UAC_testHealthEvaluationBuilder()
                                             .setUAC(objUACContact.Id)
                                             .buildAndSave();
    
        //Fetch All the Risk based test records
        List<UAC_test__c> labtests = [select id, UAC_diseaseConditionTested__c, UAC_result__c, UAC_specimenCollectionDate__c from UAC_test__c where recordtype.developername = 'UAC_riskBasedLabTest' and UAC_associatedHealthEvaluation__c = : objHA.Id];
        //Update result of Risk based tests to 'Not Done' and Hep C to positive.
        for(UAC_test__c objTest : labtests){
        if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHIV){
        objTest.UAC_result__c = Label.UAC_testPicklistPositive;
        objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
        }  
        else if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistSyphilis){
        objTest.UAC_result__c = Label.UAC_testPicklistPositive;
        objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
        } 
        else if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisC){
        objTest.UAC_result__c = Label.UAC_testPicklistPositive;
        objTest.UAC_specimenCollectionDate__c = SYSTEM.TODAY();
        } 
        else if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB){
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
        List<UAC_test__c> lstConfLabTest = new List<UAC_test__c>{new UAC_test__c(UAC_test__c = 'HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)',
                                                  UAC_result__c= Label.UAC_testPicklistPositive,
                                                  RecordTypeId= recordTypeId,
                                                  UAC_associatedHealthEvaluation__c= objHA.Id,
                                                  UAC_diseaseConditionTested__c='HIV',
                                                  UAC_associatedUAC__c = objHA.UAC_associatedUAC__c,
                                                  UAC_testType__c='QuantiFERON',
                                                  UAC_specimenSource__c='Blood/Serum',
                                                  UAC_specimenCollectionDate__c = System.today()-10
                                                 ),
                                                 new UAC_test__c(UAC_test__c = Label.UAC_testPicklistHCVRNA,
                                                  UAC_result__c= Label.UAC_testPicklistPositive,
                                                  RecordTypeId= recordTypeId,
                                                  UAC_associatedHealthEvaluation__c= objHA.Id,
                                                  UAC_diseaseConditionTested__c= Label.UAC_testPicklistHepatitisC,
                                                  UAC_associatedUAC__c = objHA.UAC_associatedUAC__c,
                                                  UAC_specimenSource__c='Blood/Serum',
                                                  UAC_specimenCollectionDate__c = System.today()-10
                                                 ),
                                                 new UAC_test__c(UAC_test__c = Label.UAC_testPicklistNonTreponemal,
                                                  UAC_result__c= Label.UAC_testPicklistPositive,
                                                  RecordTypeId= recordTypeId,
                                                  UAC_associatedHealthEvaluation__c= objHA.Id,
                                                  UAC_diseaseConditionTested__c= Label.UAC_testPicklistSyphilis,
                                                  UAC_associatedUAC__c = objHA.UAC_associatedUAC__c,
                                                  UAC_specimenSource__c='Blood/Serum',
                                                  UAC_specimenCollectionDate__c = System.today()-10
                                                 ),
                                                  new UAC_test__c(UAC_test__c = Label.UAC_testPicklistCoreAntiBody,
                                                  UAC_result__c= Label.UAC_testPicklistPositive,
                                                  RecordTypeId= recordTypeId,
                                                  UAC_associatedHealthEvaluation__c= objHA.Id,
                                                  UAC_diseaseConditionTested__c= Label.UAC_testPicklistHepatitisB,
                                                  UAC_associatedUAC__c = objHA.UAC_associatedUAC__c,
                                                  UAC_specimenSource__c='Blood/Serum',
                                                  UAC_specimenCollectionDate__c = System.today()-10
                                                 ),
                                                  new UAC_test__c(UAC_test__c = Label.UAC_testPicklistSurfaceAntiBody,
                                                  UAC_result__c= Label.UAC_testPicklistPositive,
                                                  RecordTypeId= recordTypeId,
                                                  UAC_associatedHealthEvaluation__c= objHA.Id,
                                                  UAC_diseaseConditionTested__c= Label.UAC_testPicklistHepatitisB,
                                                  UAC_associatedUAC__c = objHA.UAC_associatedUAC__c,
                                                  UAC_specimenSource__c='Blood/Serum',
                                                  UAC_specimenCollectionDate__c = System.today()-10
                                                  )
                                                 };
            insert lstConfLabTest;    
        
        // update values with sample data for Lab test Section
        objHA.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
        UAC_flowUpdateHealthAssessment.Request objRequest = new UAC_flowUpdateHealthAssessment.Request();
        objRequest.objRecord = objHA;
        objRequest.strSectionName = Label.UAC_RiskBasedPRIDLabTestingHA;
        Test.startTest();
        UAC_flowUpdateHealthAssessment.Response objResponse = UAC_flowUpdateHealthAssessment.updateHA(
            new List<UAC_flowUpdateHealthAssessment.Request>{objRequest})[0];
        Test.stopTest();
         System.assertEquals(null, objResponse.errorMessage,
                            'Test method: testUpdateHALabTestSectionValidConfTests() failed.');
      }  
}