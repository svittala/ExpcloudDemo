/**
 * @File Name         : UAC_flowUpdateNonTBPHITest
 * @Description       : Test class for UAC_flowUpdateNonTBPHI class
 * @Group             : UAC_flowUpdateNonTBPHI
 * @Author            : Ranjith kumar (AI-Vets)
 * @Last Modified By  : Ranjith kumar (AI-Vets)
 * @Last Modified On  : 09-15-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-15-2020   Ranjith kumar (AI-Vets)   Initial Version
 **/
@isTest public class UAC_flowUpdateNonTBPHITest {
private
  static final String STR_A_NUM_UAC = '123456';
private
  static final String STR_TEST_CLASS_NAME =
      UAC_flowUpdateNonTBPHITest.class.getName();

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

  @isTest static void testUpdateNonTBPHIExposureInformationSection() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(
        STR_A_NUM_UAC, new Set<String>{'Id'});
    UAC_healthEvaluation__c objNonTBPHI = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .buildAndSave();
    // update values with sample data for Exposure Information Section
    objNonTBPHI.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
    UAC_flowUpdateNonTBPHI.Request objRequest = new UAC_flowUpdateNonTBPHI.Request();
    objRequest.objRecord = objNonTBPHI;
    objRequest.strSectionName = Label.UAC_ExposureInformation;
    Test.startTest();
    UAC_flowUpdateNonTBPHI.Response objResponse = UAC_flowUpdateNonTBPHI.updateNonTBPHI(
        new List<UAC_flowUpdateNonTBPHI.Request>{objRequest})[0];
    Test.stopTest();
    System.assertEquals(
        null, objResponse.errorMessage,
        'Test method: testUpdateNonTBPHIExposureInformationSection() failed.');
  }
 
  
  
}