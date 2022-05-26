/**
 * @File Name         : UAC_tstTestTableControllerTest.cls
 * @Description       : Test class for UAC_tstTestTableController
 * @Group             : UAC_tstTestTableControllerTest
 * @Author            : Karthi Subramanian (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 08-16-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-16-2020   Karthi Subramanian (Deloitte)   Initial Version
 **/
@isTest public class UAC_tstTestTableControllerTest {
    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String STR_TEST_CLASS_NAME = UAC_tstTestTableControllerTest.class.getName();
  
    /**
     * @description Method to setup test data
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     **/
    @TestSetup static void setupData() {
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
      UAC_healthEvaluation__c objIME =
          new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
      UAC_test__c objTSTTest = new UAC_testTSTTestBuilder().setUAC(objUACContact.Id).setHealthEval(objIME.Id).buildAndSave();
    }
  
    /**
     * @description Method to test update functionalities of UAC_tstTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     */
    @isTest static void testUpdTSTTestTableController() {
      UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
      Test.startTest();
      List<UAC_test__c> lstTSTTest = UAC_tstTestTableController.getTSTList(objIME.Id);
      System.assert(!lstTSTTest.isEmpty(), 'Failed to get Test list');
      UAC_genericResponse objResponse =
      UAC_tstTestTableController.upsertTSTList(JSON.serialize(lstTSTTest));
      System.assertEquals(true, objResponse.isSuccess, 'Failed to Update TST Test record');
      Test.stopTest();
    }

    /**
     * @description Method to test create functionalities of UAC_tstTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     */
    @isTest static void testCreateTSTTestTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;
        Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                                                        .get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge)
                                                         .getRecordTypeId();        
        Test.startTest();
        UAC_test__c objTSTTest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='PPD/Tuberculin Skin Test (TST)',
          UAC_diseaseConditionTested__c	= 'Tuberculosis',	
          UAC_result__c='Pending',
          UAC_reactionInMM__c=4);
        List<UAC_test__c> lstTSTTest = new List<UAC_test__c>();
        lstTSTTest.add(objTSTTest);
        UAC_genericResponse objResponse =
        UAC_tstTestTableController.upsertTSTList(JSON.serialize(lstTSTTest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create TST Test record');
        System.assertNotEquals(null, objResponse.data.get('errorMap'), 'Failed to Create TST Test record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_tstTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     */
    @isTest static void testDeleteTSTTestTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;
        Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                                                        .get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge)
                                                         .getRecordTypeId();        
        Test.startTest();
        UAC_test__c objTSTTest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='PPD/Tuberculin Skin Test (TST)',
          UAC_diseaseConditionTested__c	= 'Tuberculosis',	
          UAC_result__c='Pending');
        List<UAC_test__c> lstTSTTest= new List<UAC_test__c>();
        lstTSTTest.add(objTSTTest);
        UAC_genericResponse objResponse =
        UAC_tstTestTableController.upsertTSTList(JSON.serialize(lstTSTTest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create TST Test record');
        List<UAC_test__c> lstTSTTestForDel = getTSTTestRecord(idUAC,idHealthEval);
        UAC_genericResponse objDelResponse =
        UAC_tstTestTableController.deleteTSTList(JSON.serialize(lstTSTTestForDel));
        System.assertEquals(true, objDelResponse.isSuccess, 'Failed to Delete TST Test record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_tstTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     */
    @isTest static void testDeleteTSTTestTableControllerNegativeCase() {
        Test.startTest();
        UAC_genericResponse objDelResponse =
        UAC_tstTestTableController.deleteTSTList(JSON.serialize(null));
        System.assertEquals(false, objDelResponse.isSuccess, 'Failed to Update TST Test record');
        System.assertNotEquals(null, objDelResponse.error, 'Failed to update TST Test record');
        Test.stopTest();
      }      

    /**
     * @description Method to test Exception case of UAC_tstTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     */
    @isTest static void testUpdTSTTestTableControllerNegativeCase() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();
        List<UAC_test__c> lstTSTTest = UAC_tstTestTableController.getTSTList(objIME.Id);
        System.assert(!lstTSTTest.isEmpty(), 'Failed to get Test list');
        //lstTSTTest[0].UAC_status__c='Abnormal';
        UAC_genericResponse objResponse =
        UAC_tstTestTableController.upsertTSTList(JSON.serialize(null));
        Test.stopTest();
        System.assertEquals(false, objResponse.isSuccess, 'Failed to Update TST Test record');
        System.assertNotEquals(null, objResponse.error, 'Failed to update TST Test record');
      }
  
    /**
     * @description Method to get IME record by UAC A Number
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
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
     * @description Method to get IME record by UAC A Number
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     * @param strANumber String value for UAC A Number
     * @return UAC_healthEvaluation__c
     */
    public
    static UAC_healthEvaluation__c getUACByUACANumber(String strANumber) {
      // clang-format off
      return [
        SELECT
        Id,UAC_associatedUAC__c
        FROM
          UAC_healthEvaluation__c
        WHERE
          UAC_associatedUAC__r.UAC_a__c = :strANumber
        LIMIT 1
      ];
      // clang-format on
    }

    /**
     * @description Method to get Test record 
     * @author Karthi Subramanian (Deloitte) | 08-16-2020
     * @param strANumber String value for UAC A Number
     * @return UAC_test__c
     */
    public
    static List<UAC_test__c> getTSTTestRecord(String strUACId,String strHealEvalId ) {
      // clang-format off
      return [
        SELECT
        Id,UAC_associatedUAC__c,UAC_associatedHealthEvaluation__c
        FROM
        UAC_test__c
        WHERE
        UAC_associatedUAC__c= :strUACId AND
        UAC_associatedHealthEvaluation__c=: strHealEvalId
        LIMIT 1
      ];
      // clang-format on
    }    

  }