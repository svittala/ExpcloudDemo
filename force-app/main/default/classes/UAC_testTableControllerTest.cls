/**
 * @File Name         : UAC_testTableControllerTest.cls
 * @Description       : Test class for UAC_testTableControllerTest
 * @Group             : UAC_testTableController
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 08-07-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-06-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   03-22-2020   Abhisek Pati (Deloitte)    ORRUAC-5563 Added Risk Lab Records
 * 1.2   09-28-2020   Abhisek Pati (Deloitte)    Adding negative test coverage
 **/
@isTest public class UAC_testTableControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_TEST_CLASS_NAME = UAC_testTableControllerTest.class.getName();

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
   * @description Method to test all functionalities of UAC_testTableController
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   */
  @isTest static void testRiskBasedTestTableController() {
    UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
    List<String> lstFieldsToQuery =
        new List<String>{'UAC_diseaseConditionTested__c', 'UAC_test__c'};
    Test.startTest();
    List<UAC_test__c> lstTest = UAC_testTableController.getTestList(
        objIME.Id, Label.UAC_testRecTypeRiskBasedLabTest, lstFieldsToQuery);
    System.assert(!lstTest.isEmpty(), 'Failed to get Test list');
    lstTest[0].UAC_diseaseConditionTested__c = Label.UAC_testPicklistLead;
    lstTest[0].UAC_dateRead__c = system.today() + 1;
    UAC_genericResponse objResponse =
        UAC_testTableController.upsertTestList(JSON.serialize(lstTest));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to update Test list');
    UAC_testTableController.deleteTestList(JSON.serialize(lstTest));
    System.assertEquals(true, objResponse.isSuccess, 'Failed to delete Test list');
    lstTest = UAC_testTableController.getTestList(
        objIME.Id, Label.UAC_testRecTypeRiskBasedLabTest, lstFieldsToQuery);
    Test.stopTest();
    System.assertEquals(
        0, lstTest.size(), 'Test method: testRiskBasedTestTableController() failed.');
  }

   
  /**
   * @description Method to test negative functionalities of UAC_testTableController
   * @author Abhisek Pati (Deloitte) | 09-28-2021
   */
  @isTest static void testRiskBasedTestTableControllerNegative() {
    Test.startTest();
    UAC_genericResponse objResponse =
    UAC_testTableController.upsertTestList(null);
    UAC_testTableController.deleteTestList(null);
    Test.stopTest();
    List<UAC_errorLog__c> errRec= [Select Id,UAC_errorOrigin__c from UAC_errorLog__c];
    System.AssertNotEquals(errRec[0], null);
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