/**
 * @File Name         : UAC_allergyTableControllerTest.cls
 * @Description       : Test class for UAC_allergyTableController
 * @Group             : UAC_allergyTableController
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 07-23-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-23-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
@isTest public class UAC_allergyTableControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_TEST_CLASS_NAME = 'Test Allergen';
  private
  static final String STR_ALLERGEN= 'Peanut';
  private
  static final String STR_ALLERGYTYPE = 'Food';
  private
  static final String STR_REACTION = 'Difficulty breathing';

  /**
   * @description Method to setup test data
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    UAC_allergy__c objAllergy = new UAC_testAllergyBuilder()
                                    .setUAC(objUACContact.Id)
                                    .setHealthEvaluation(objIME.Id)
                                    .setAllergen(STR_ALLERGEN)
        							              .setAllergyType(STR_ALLERGYTYPE)
        							              .setReaction(STR_REACTION)
                                    .buildAndSave();
  }

  /**
   * @description Method to test all functionalities of UAC_allergyTableController
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   */
  @isTest static void testAllergyTableController() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_allergy__c> lstAllergy = UAC_allergyTableController.getAllergyList(objIME.Id);
    System.assertEquals(1, lstAllergy.size(), 'Failed to get Allergy list');
    lstAllergy[0].UAC_allergen__c = STR_TEST_CLASS_NAME;
    UAC_genericResponse objResponse =
        UAC_allergyTableController.upsertAllergyList(JSON.serialize(lstAllergy));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to update Allergy list');
    UAC_allergyTableController.deleteAllergyList(JSON.serialize(lstAllergy));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to delete Allergy list');
    lstAllergy = UAC_allergyTableController.getAllergyList(objIME.Id);
    Test.stopTest();
    System.assertEquals(0, lstAllergy.size(), 'Test method: testAllergyTableController() failed.');
  }
  
      /**
   * @description Method to test negative functionalities of UAC_allergyTableController
   * @author Anupreeta Chakraborty (Deloitte) | 11-04-2020
   */
  @isTest static void testAllergyTableControllerNegativeScenario() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_allergy__c> lstAllergy = UAC_allergyTableController.getAllergyList(objIME.Id);
    System.assertEquals(1, lstAllergy.size(), 'Failed to get Allergy list');
    lstAllergy[0].UAC_allergen__c = STR_TEST_CLASS_NAME;
    lstAllergy[0].UAC_allergyType__c = 'fooding';
    UAC_genericResponse objResponse =
    UAC_allergyTableController.upsertAllergyList(JSON.serialize(lstAllergy));
    Test.stopTest();
  }
  
    /**
   * @description Method to test negative functionalities of UAC_allergyTableController
   * @author Anupreeta Chakraborty (Deloitte) | 11-04-2020
   */
  @isTest static void testAllergyTableControllerUpsertNegativeScenario() {
    Test.startTest();
    UAC_genericResponse objResponse =
    UAC_allergyTableController.upsertAllergyList('Testing');
    System.assertEquals(false, objResponse.isSuccess, 'Allergy list updated');    
    Test.stopTest();
  }  
  
  /**
   * @description Method to test negative functionalities of UAC_allergyTableController
   * @author Sachet Khanal (Deloitte) | 11-04-2020
   */
  @isTest static void testAllergyTableControllerDeleteNegativeScenario() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_allergy__c> lstAllergy = UAC_allergyTableController.getAllergyList(objIME.Id);
    System.assertEquals(1, lstAllergy.size(), 'Failed to get Allergy list');
    lstAllergy[0].UAC_allergen__c = STR_TEST_CLASS_NAME;
    UAC_genericResponse objResponse =
        UAC_allergyTableController.upsertAllergyList(JSON.serialize(lstAllergy));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to update Allergy list');
    UAC_genericResponse objDeleteResponse =    
    UAC_allergyTableController.deleteAllergyList('Testing');
    System.assertEquals(false, objDeleteResponse.isSuccess, 'Deleted Allergy list');
    Test.stopTest();
  }
    

  /**
   * @description Method to get IME record by UAC A Number
   * @author Sachet Khanal (Deloitte) | 07-23-2020
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
}