/**
 * @File Name         : UAC_physicalExamTableControllerTest.cls
 * @Description       : Test class for UAC_physicalExamTableController
 * @Group             : UAC_physicalExamTableController
 * @Author            : Karthi Subramanian (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 07-27-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-27-2020   Karthi Subramanian (Deloitte)   Initial Version
 * 1.2   08-26-2020   Abhisek Pati (Deloitte)         Added Methods to upsert and delete for
 *                                                    ORRUAC-1960
 **/
@isTest public class UAC_physicalExamTableControllerTest {
    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String STR_TEST_CLASS_NAME = UAC_physicalExamTableControllerTest.class.getName();
  
    /**
     * @description Method to setup test data
     * @author Karthi Subramanian (Deloitte) | 07-27-2020
     **/
    @TestSetup static void setupData() {
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
      UAC_healthEvaluation__c objIME =
          new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    }
  
    /**
     * @description Method to test all functionalities of UAC_physicalExamTableController
     * @author Karthi Subramanian (Deloitte) | 07-27-2020
     */
    @isTest static void testPhysicalExamTableController() {
      UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
      Test.startTest();
      List<UAC_physicalExam__c> lstPhysicalExam = UAC_physicalExamTableController.getPhysicalExamList(objIME.Id);
      System.assertEquals(12, lstPhysicalExam.size(), 'Failed to get Physical Exam list');
      lstPhysicalExam[0].UAC_status__c='Abnormal';
      UAC_genericResponse objResponse =
      UAC_physicalExamTableController.updatePhysicalExamList(JSON.serialize(lstPhysicalExam));
      UAC_genericResponse objResponseUpsert =
      UAC_physicalExamTableController.upsertPhysicalExamList(JSON.serialize(lstPhysicalExam));
      System.assertEquals(true, objResponse.isSuccess, 'Failed to update Physical Exam list list');
      Test.stopTest();
      System.assertEquals(12, lstPhysicalExam.size(), 'Test method: testPhysicalExamTableController() failed.');
      System.assertEquals(true, objResponseUpsert.isSuccess, 'Failed to upsert Physical Exam list list');
    }


    /**
     * @description Method to test Exception case of UAC_physicalExamTableController
     * @author Karthi Subramanian (Deloitte) | 07-27-2020
     */
    @isTest static void testPhysicalExamTableControllerNegativeCase() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();
        List<UAC_physicalExam__c> lstPhysicalExam = UAC_physicalExamTableController.getPhysicalExamList(objIME.Id);
        System.assertEquals(12, lstPhysicalExam.size(), 'Failed to get Physical Exam list');
        UAC_genericResponse objResponse =
        UAC_physicalExamTableController.updatePhysicalExamList(JSON.serialize(null));
        UAC_genericResponse objResponseUpsert =
        UAC_physicalExamTableController.upsertPhysicalExamList(JSON.serialize(null));
        Test.stopTest();
        System.assertEquals(false, objResponse.isSuccess, 'Failed to update Physical Exam list list');
        System.assertEquals(false, objResponseUpsert.isSuccess, 'Failed to upsert Physical Exam list list');
        System.assertNotEquals(null, objResponse.error, 'Failed to update Physical Exam list list');
      }

      /**
     * @description Method to test Delete functionalities of UAC_physicalExamTableController
     * @author Abhisek Pati (Deloitte) | 08-26-2020
     */
    @isTest static void testDeletePhysicalExamTableController() {
      UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
      String idUAC=objIME.UAC_associatedUAC__c;
      String idHealthEval=objIME.Id; 
      Test.startTest();
      List<UAC_physicalExam__c> lstPhysicalExam = UAC_physicalExamTableController.getPhysicalExamList(objIME.Id);
      System.assertEquals(12, lstPhysicalExam.size(), 'Failed to get Physical Exam list');
      lstPhysicalExam[0].UAC_status__c='Abnormal';
      UAC_genericResponse objResponse =
      UAC_physicalExamTableController.upsertPhysicalExamList(JSON.serialize(lstPhysicalExam));
      System.assertEquals(true, objResponse.isSuccess, 'Failed to Create Physical Exam record');
      List<UAC_physicalExam__c> lstPhysicalExamForDel = getPhysicalExamRecord(idUAC,idHealthEval);
      UAC_genericResponse objDelResponse =
      UAC_physicalExamTableController.deletePhysicalExamList(JSON.serialize(lstPhysicalExamForDel));
      System.assertEquals(true, objDelResponse.isSuccess, 'Failed to Delete Physical Exam record');
      Test.stopTest();
    }

  /**
   * @description Method to test Delete functionalities of UAC_physicalExamTableController
   * @author Abhisek Pati (Deloitte) | 08-26-2020
   */
  @isTest static void testDeletePhysicalExamTableControllerNegativeCase() {
      Test.startTest();
      UAC_genericResponse objDelResponse =
      UAC_physicalExamTableController.deletePhysicalExamList(JSON.serialize(null));
      System.assertEquals(false, objDelResponse.isSuccess, 'Failed to Update Physical Exam record');
      System.assertNotEquals(null, objDelResponse.error, 'Failed to update Physical Exam record');
      Test.stopTest();
    }
  
    /**
     * @description Method to get IME record by UAC A Number
     * @author Karthi Subramanian (Deloitte) | 07-27-2020
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
     * @description Method to get HA record by UAC A Number
     * @author Abhisek Pati (Deloitte) | 08-26-2020
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
     * @author Abhisek Pati (Deloitte) | 08-26-2020
     * @param strANumber String value for UAC A Number
     * @return UAC_test__c
     */
    public
    static List<UAC_physicalExam__c> getPhysicalExamRecord(String strUACId,String strHealEvalId ) {
      // clang-format off
      return [
        SELECT
        Id,UAC_associatedUAC__c,UAC_associatedHealthEvaluation__c
        FROM
        UAC_physicalExam__c
        WHERE
        UAC_associatedUAC__c= :strUACId AND
        UAC_associatedHealthEvaluation__c=: strHealEvalId
        LIMIT 1
      ];
      // clang-format on
    }    
  }