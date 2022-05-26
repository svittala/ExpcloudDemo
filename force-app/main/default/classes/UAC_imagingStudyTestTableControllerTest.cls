/**
 * @File Name         : UAC_imagingStudyTestTableControllerTest.cls
 * @Description       : Test class for UAC_imagingStudyTestTableController
 * @Group             : UAC_imagingStudyTestTableControllerTest
 * @Author            : Ranjith kumar (AI-Vets)
 * @Last Modified By  : Ranjith kumar (AI-Vets)
 * @Last Modified On  : 08-10-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-05-2020   Ranjith kumar (AI-Vets)   Initial Version
 **/
@isTest public class UAC_imagingStudyTestTableControllerTest {
    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String STR_TEST_CLASS_NAME = UAC_imagingStudyTestTableControllerTest.class.getName();
  
    /**
     * @description Method to setup test data
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     **/
    @TestSetup static void setupData() {
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
      UAC_healthEvaluation__c objIME =
          new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
      UAC_test__c objImagingStudyTest = new UAC_testImagingStudyTestBuilder().setUAC(objUACContact.Id).setHealthEval(objIME.Id).buildAndSave();
    }
  
    /**
     * @description Method to test update functionalities of UAC_imagingStudyTestTableController
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     */
    @isTest static void testUpdImagingStudyTestTableController() {
      UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
      Test.startTest();
      List<UAC_test__c> lstImagingStudyTest = UAC_imagingStudyTestTableController.getTestList(objIME.Id);
      System.assert(!lstImagingStudyTest.isEmpty(), 'Failed to get Test list');
      UAC_genericResponse objResponse =
      UAC_imagingStudyTestTableController.upsertTestList(JSON.serialize(lstImagingStudyTest));
      System.assertEquals(true, objResponse.isSuccess, 'Failed to Update Imaging Study Test record');
      Test.stopTest();
    }

    /**
     * @description Method to test create functionalities of UAC_imagingStudyTestTableController
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     */
    @isTest static void testCreateImagingStudyTestTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;
        Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                                                        .get(Label.UAC_testRecTypeImagingStudy)
                                                         .getRecordTypeId();        
        Test.startTest();
        UAC_test__c objImagingStudyTest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='MRI',
          UAC_diseaseConditionTested__c = 'Tuberculosis',   
          UAC_result__c='Pending');
        List<UAC_test__c> lstImagingStudyTest = new List<UAC_test__c>();
        lstImagingStudyTest.add(objImagingStudyTest);
        UAC_genericResponse objResponse =
        UAC_imagingStudyTestTableController.upsertTestList(JSON.serialize(lstImagingStudyTest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create Imaging Study Test record');
        System.assertNotEquals(null, objResponse.data.get('errorMap'), 'Failed to Create Imaging Study Test record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_imagingStudyTestTableController
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     */
    @isTest static void testDeleteImagingStudyTestTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;
        Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                                                        .get(Label.UAC_testRecTypeImagingStudy)
                                                         .getRecordTypeId();        
        Test.startTest();
        UAC_test__c objImagingStudyTest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='MRI',
          UAC_diseaseConditionTested__c = 'Tuberculosis',   
          UAC_result__c='Pending');
        List<UAC_test__c> lstImagingStudyTest= new List<UAC_test__c>();
        lstImagingStudyTest.add(objImagingStudyTest);
        UAC_genericResponse objResponse =
        UAC_imagingStudyTestTableController.upsertTestList(JSON.serialize(lstImagingStudyTest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create ImagingStudy Test record');
        List<UAC_test__c> lstImagingStudyTestForDel = getImagingStudyTestRecord(idUAC,idHealthEval);
        UAC_genericResponse objDelResponse =
        UAC_imagingStudyTestTableController.deleteTestList(JSON.serialize(lstImagingStudyTestForDel));
        System.assertEquals(true, objDelResponse.isSuccess, 'Failed to Delete Imaging Study Test record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_imagingStudyTestTableController
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     */
    @isTest static void testDeleteImagingStudyTestTableControllerNegativeCase() {
        Test.startTest();
        UAC_genericResponse objDelResponse =
        UAC_imagingStudyTestTableController.deleteTestList(JSON.serialize(null));
        System.assertEquals(false, objDelResponse.isSuccess, 'Failed to Update ImagingStudy Test record');
        System.assertNotEquals(null, objDelResponse.error, 'Failed to update ImagingStudy Test record');
        Test.stopTest();
      }      

    /**
     * @description Method to test Exception case of UAC_imagingStudyTestTableController
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     */
    @isTest static void testUpdImagingStudyTestTableControllerNegativeCase() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();
        List<UAC_test__c> lstImagingStudyTest = UAC_imagingStudyTestTableController.getTestList(objIME.Id);
        System.assert(!lstImagingStudyTest.isEmpty(), 'Failed to get Test list');
        //lstImagingStudyTest[0].UAC_status__c='Abnormal';
        UAC_genericResponse objResponse =
        UAC_imagingStudyTestTableController.upsertTestList(JSON.serialize(null));
        Test.stopTest();
        System.assertEquals(false, objResponse.isSuccess, 'Failed to Update Imaging Study Test record');
        System.assertNotEquals(null, objResponse.error, 'Failed to update Imaging Study Test record');
      }
  
    /**
     * @description Method to get IME record by UAC A Number
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
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
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
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
     * @author Ranjith kumar (AI-Vets) | 08-05-2020
     * @param strANumber String value for UAC A Number
     * @return UAC_test__c
     */
    public
    static List<UAC_test__c> getImagingStudyTestRecord(String strUACId,String strHealEvalId ) {
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