/**
 * @File Name         : UAC_flowUpdateActiveTBPHITest
 * @Description       : Test class for UAC_flowUpdateActiveTBPHI class
 * @Group             : UAC_flowUpdateActiveTBPHI
 * @Author            : Ranjith kumar (AI-Vets)
 * @Last Modified By  : Ranjith kumar (AI-Vets)
 * @Last Modified On  : 09-16-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-15-2020   Ranjith kumar (AI-Vets)   Initial Version
 * 1.1   09-28-2021   Abhisek Pati (Deloitte)   Added code coverage for negative case
 **/
@isTest public class UAC_flowUpdateActiveTBPHITest {
private
  static final String STR_A_NUM_UAC = '123456';
private
  static final String STR_TEST_CLASS_NAME =
      UAC_flowUpdateActiveTBPHITest.class.getName();

  @TestSetup static void setupData() {
    Contact objUACContact =
        new UAC_testContactBuilder()
            .setANumber(STR_A_NUM_UAC)
            .setEmail(STR_A_NUM_UAC + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
            .buildAndSave();
  }
  
  /**
   * @description Test Method to validate update of ExposureInformationSection.
   * * @author Ranjith kumar (AI-Vets) | 09-15-2020
   * @param N/A
   * @return N/A
   **/

  @isTest static void testUpdateActiveTBPHIExposureInformationSection() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objActiveTBPHI = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Exposure Information Section
    objActiveTBPHI.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateActiveTBPHI.Request objRequest = new UAC_flowUpdateActiveTBPHI.Request();
    objRequest.objRecord = objActiveTBPHI;
    objRequest.strSectionName = Label.UAC_ExposureInformation;
    Test.startTest();
    UAC_flowUpdateActiveTBPHI.Response objResponse = UAC_flowUpdateActiveTBPHI.updateActiveTBPHI(
        new List<UAC_flowUpdateActiveTBPHI.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateActiveTBPHIExposureInformationSection() failed.');
  }

      /**
   * @description Method to test negative functionalities of ExposureInformationSection
   * @author Abhisek Pati (Deloitte) | 09-28-2021
   */
  @isTest static void testUpdateActiveTBPHIExposureInformationSectionNegative() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
   STR_A_NUM_UAC, new Set<String>{'Id'});
UAC_healthEvaluation__c objActiveTBPHI = new UAC_testHealthEvaluationBuilder()
                                    .setUAC(objUACContact.Id)
                                    .buildAndSave();
// update values with sample data for Exposure Information Section
objActiveTBPHI.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
objActiveTBPHI.UAC_diseaseCondition__c = 'TB, Active Disease';
objActiveTBPHI.UAC_diseaseConditionType__c = 'Other';
UAC_flowUpdateActiveTBPHI.Request objRequest = new UAC_flowUpdateActiveTBPHI.Request();
objRequest.objRecord = objActiveTBPHI;
objRequest.strSectionName = Label.UAC_ExposureInformation;
Test.startTest();
UAC_flowUpdateActiveTBPHI.Response objResponse = UAC_flowUpdateActiveTBPHI.updateActiveTBPHI(
   new List<UAC_flowUpdateActiveTBPHI.Request>{objRequest})[0];
Test.stopTest();
System.assertNotEquals(
   null, objResponse.errorMessage,
   'Test method: testUpdateActiveTBPHIExposureInformationSection() failed.');
} 
 
  
  
}