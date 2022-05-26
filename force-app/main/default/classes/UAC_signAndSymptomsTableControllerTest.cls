/**
 * @File Name         : UAC_signAndSymptomsTableControllerTest.cls
 * @Description       : Test class for UAC_signAndSymptomsTableController
 * @Group             : UAC_signAndSymptomsTableControllerTest
 * @Author            : Ranjith kumar(AI_Vets)
 * @Last Modified By  : Ranjith kumar(AI_Vets)
 * @Last Modified On  : 08-04-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-03-2020   Ranjith kumar(AI_Vets)   Initial Version
 * 1.1   02-22-2021   Abhisek Pati (Deloitte)  Added Code Coverage.
 **/
@isTest public with sharing class UAC_signAndSymptomsTableControllerTest {
    private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_TEST_CLASS_NAME = UAC_signAndSymptomsTableControllerTest.class.getName();

  /**
   * @description Method to setup test data
   * @author Ranjith kumar(AI_Vets) | 08-03-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    UAC_signsAndSymptoms__c objSignsAndSymptoms = new UAC_testSignAndSymptomsBuilder()
                                    .setUAC(objUACContact.Id)
                                    .setHealthEvaluation(objIME.Id)
                                    .buildAndSave();
  }
    /**
   * @description Method to test all functionalities of UAC_signAndSymptomsTableController
   * @author Ranjith kumar(AI_Vets) | 08-03-2020
   */
  @isTest static void testSignAndSymptomsTableController() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_signsAndSymptoms__c> lstSignsAndSymptoms = UAC_signAndSymptomsTableController.getSignAndSymptomsList(objIME.Id);
    System.assertEquals(1, lstSignsAndSymptoms.size(), 'Failed to get Sign And Symptoms list');
    lstSignsAndSymptoms[0].UAC_signSymptom__c = 'Red Eyes';
    UAC_genericResponse objResponse =
        UAC_signAndSymptomsTableController.upsertSignAndSymptomsList(JSON.serialize(lstSignsAndSymptoms));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to update Sign And Symptoms list');
    UAC_signAndSymptomsTableController.deleteSignAndSymptomsList(JSON.serialize(lstSignsAndSymptoms));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to delete Sign And Symptoms list');
    lstSignsAndSymptoms = UAC_signAndSymptomsTableController.getSignAndSymptomsList(objIME.Id);
      
    //Catch
    UAC_genericResponse objResponse1 =
        UAC_signAndSymptomsTableController.upsertSignAndSymptomsList('{Test}');
    Test.stopTest();
    System.assertEquals(0, lstSignsAndSymptoms.size(), 'Test method: testSignAndSymptomsTableController() failed.');
  }

  /**
   * @description Method to get IME record by UAC A Number
   * @author Ranjith kumar(AI_Vets) | 08-03-2020
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
   * @description Method to test negative delete scenario record.
   * @author Abhisek Pati (Deloitte) | 2-22-2019
   **/
  @isTest static void testSignAndSymptomsTableControllerNegative() {
    Test.startTest();
	UAC_genericResponse objResponse =
        UAC_signAndSymptomsTableController.deleteSignAndSymptomsList('Testing');
    Test.stopTest();
    System.assertEquals(false,
        objResponse.isSuccess, 'Test method: testSignAndSymptomsTableControllerNegative() success.');
  }
}