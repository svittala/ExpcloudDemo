/**
 * @File Name         : UAC_riskBasedTestTableControllerTest.cls
 * @Description       : Test class for UAC_riskBasedTestTableController
 * @Group             : UAC_riskBasedTestTableController
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 08-02-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-02-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   03-22-2020   Abhisek Pati (Deloitte)    ORRUAC-5563 Added Risk Lab Records
 **/
@isTest public class UAC_riskBasedTestTableControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_TEST_CLASS_NAME = UAC_riskBasedTestTableControllerTest.class.getName();

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
    UAC_testLabTestBuilder tb = new UAC_testLabTestBuilder();
    tb.setHealthEvaluation(objIME.Id);
    tb.setUAC(objIME.UAC_associatedUAC__c);
    List<UAC_test__c> laptests = tb.buildAndSave();
  }

  /**
   * @description Method to test all functionalities of UAC_riskBasedTestTableController
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   */
  @isTest static void testRiskBasedTestTableController() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_test__c> lstTest = UAC_riskBasedTestTableController.getTestList(objIME.Id);
    System.assert(!lstTest.isEmpty(), 'Failed to get Test list');
    lstTest[0].UAC_diseaseConditionTested__c = Label.UAC_testPicklistLead;
    UAC_genericResponse objResponse =
        UAC_riskBasedTestTableController.upsertTestList(JSON.serialize(lstTest));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to update Test list');
    UAC_riskBasedTestTableController.deleteTestList(JSON.serialize(lstTest));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to delete Test list');
    lstTest = UAC_riskBasedTestTableController.getTestList(objIME.Id);
    Test.stopTest();
    System.assertEquals(
        0, lstTest.size(), 'Test method: testRiskBasedTestTableController() failed.');
  }
  
   /**
   * @description Method to test all functionalities of UAC_riskBasedTestTableController
   * @author Sachet Khanal (Deloitte) | 11-05-2020
   */
  @isTest static void testRiskBasedUpsertTestNegativeScenario() {
    Test.startTest();
    UAC_genericResponse objResponse =
        UAC_riskBasedTestTableController.upsertTestList('Testing');
    System.assertEquals(false, objResponse.isSuccess, 'Updated Test list');
    Test.stopTest();
  }
    
    /**
   * @description Method to test negative functionalities of UAC_riskBasedTestTableController
   * @author Anupreeta Chakraborty (Deloitte) | 11-04-2020
   */
  @isTest static void testRiskBasedTestTableControllerNegativeScenario() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_test__c> lstTest = UAC_riskBasedTestTableController.getTestList(objIME.Id);
    System.assert(!lstTest.isEmpty(), 'Failed to get Test list');
    lstTest[0].UAC_diseaseConditionTested__c = 'Testing';
    UAC_genericResponse objResponse =
        UAC_riskBasedTestTableController.upsertTestList(JSON.serialize(lstTest));
    System.assertEquals(true, objResponse.isSuccess, 'failed to update Test list');	
    Test.stopTest();
  }
  
    /**
   * @description Method to test negative functionalities of UAC_riskBasedTestTableController
   * @author Anupreeta Chakraborty (Deloitte) | 11-05-2020
   */
  @isTest static void testRiskBasedDeleteTestNegativeScenario() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    Test.startTest();
    List<UAC_test__c> lstTest = UAC_riskBasedTestTableController.getTestList(objIME.Id);
    System.assert(!lstTest.isEmpty(), 'Failed to get Test list');
    lstTest[0].UAC_diseaseConditionTested__c = Label.UAC_testPicklistLead;
    UAC_genericResponse objResponse =
        UAC_riskBasedTestTableController.upsertTestList(JSON.serialize(lstTest));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to update Test list');
        UAC_genericResponse objDeleteResponse =
    UAC_riskBasedTestTableController.deleteTestList('Testing');
    System.assertEquals(false, objDeleteResponse.isSuccess, 'Deleted Test list');
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