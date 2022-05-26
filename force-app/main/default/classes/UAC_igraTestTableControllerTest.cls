/**
 * @File Name         : UAC_igraTestTableControllerTest.cls
 * @Description       : Test class for UAC_igraTestTableController
 * @Group             : UAC_igraTestTableControllerTest
 * @Author            : Karthi Subramanian (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 08-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-23-2020   Karthi Subramanian (Deloitte)   Initial Version
 **/
@isTest public class UAC_igraTestTableControllerTest {
    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String STR_TEST_CLASS_NAME = UAC_igraTestTableControllerTest.class.getName();
  
    /**
     * @description Method to setup test data
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     **/
    @TestSetup static void setupData() {
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
      UAC_healthEvaluation__c objIME =
          new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
      UAC_test__c objIGRATest = new UAC_testIGRATestBuilder().setUAC(objUACContact.Id).setHealthEval(objIME.Id).buildAndSave();
    }
  
    /**
     * @description Method to test update functionalities of UAC_igraTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     */
    @isTest static void testUpdIGRATestTableController() {
      UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
      Test.startTest();
      List<UAC_test__c> lstIGRATest = UAC_igraTestTableController.getTestList(objIME.Id);
      System.assert(!lstIGRATest.isEmpty(), 'Failed to get Test list');
      UAC_genericResponse objResponse =
      UAC_igraTestTableController.upsertTestList(JSON.serialize(lstIGRATest));
      System.assertEquals(true, objResponse.isSuccess, 'Failed to Update IGRA Test record');
      Test.stopTest();
    }

    /**
     * @description Method to test create functionalities of UAC_igraTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     */
    @isTest static void testCreateIGRATestTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;
        Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                                                        .get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder)
                                                         .getRecordTypeId();        
        Test.startTest();
        UAC_test__c objIGRATest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='TB Blood Test (Interferon-Gamma Release Assay [IGRA])',
          UAC_diseaseConditionTested__c	= 'Tuberculosis',	
          UAC_result__c='Indeterminate',
          UAC_testType__c='QuantiFERON');
        List<UAC_test__c> lstIGRATest = new List<UAC_test__c>();
        lstIGRATest.add(objIGRATest);
        UAC_genericResponse objResponse =
        UAC_igraTestTableController.upsertTestList(JSON.serialize(lstIGRATest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create IGRA Test record');
        System.assertNotEquals(null, objResponse.data.get('errorMap'), 'Failed to Create IGRA Test record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_igraTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     */
    @isTest static void testDeleteIGRATestTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;
        Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                                                        .get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder)
                                                         .getRecordTypeId();        
        Test.startTest();
        UAC_test__c objIGRATest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='TB Blood Test (Interferon-Gamma Release Assay [IGRA])',
          UAC_diseaseConditionTested__c	= 'Tuberculosis',	
          UAC_result__c='Indeterminate',
          UAC_testType__c='QuantiFERON',
          UAC_specimenCollectionDate__c=system.today());
        List<UAC_test__c> lstIGRATest= new List<UAC_test__c>();
        lstIGRATest.add(objIGRATest);
        UAC_genericResponse objResponse =
        UAC_igraTestTableController.upsertTestList(JSON.serialize(lstIGRATest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create IGRA Test record');
        List<UAC_test__c> lstIGRATestForDel = getIGRATestRecord(idUAC,idHealthEval);
        UAC_genericResponse objDelResponse =
        UAC_igraTestTableController.deleteTestList(JSON.serialize(lstIGRATestForDel));
        System.assertEquals(true, objDelResponse.isSuccess, 'Failed to Delete IGRA Test record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_igraTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     */
    @isTest static void testDeleteIGRATestTableControllerNegativeCase() {
        Test.startTest();
        UAC_genericResponse objDelResponse =
        UAC_igraTestTableController.deleteTestList(JSON.serialize(null));
        System.assertEquals(false, objDelResponse.isSuccess, 'Failed to Update IGRA Test record');
        System.assertNotEquals(null, objDelResponse.error, 'Failed to update IGRA Test record');
        Test.stopTest();
      }      

    /**
     * @description Method to test Exception case of UAC_igraTestTableController
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     */
    @isTest static void testUpdIGRATestTableControllerNegativeCase() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();
        List<UAC_test__c> lstIGRATest = UAC_igraTestTableController.getTestList(objIME.Id);
        System.assert(!lstIGRATest.isEmpty(), 'Failed to get Test list');
        //lstIGRATest[0].UAC_status__c='Abnormal';
        UAC_genericResponse objResponse =
        UAC_igraTestTableController.upsertTestList(JSON.serialize(null));
        Test.stopTest();
        System.assertEquals(false, objResponse.isSuccess, 'Failed to Update IGRA Test record');
        System.assertNotEquals(null, objResponse.error, 'Failed to update IGRA Test record');
      }
  
    /**
     * @description Method to get IME record by UAC A Number
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
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
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
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
     * @author Karthi Subramanian (Deloitte) | 08-03-2020
     * @param strANumber String value for UAC A Number
     * @return UAC_test__c
     */
    public
    static List<UAC_test__c> getIGRATestRecord(String strUACId,String strHealEvalId ) {
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