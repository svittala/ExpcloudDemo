/**
 * @File Name         : UAC_immunizationTableControllerTest.cls
 * @Description       : Test class for UAC_immunizationTableController
 * @Group             : UAC_immunizationTableControllerTest
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  : 
 * @Last Modified On  : 
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-12-2020   Abhisek Pati (Deloitte)   Initial Version
 * 1.1   09-28-2021   Abhisek Pati (Deloitte)   Added code coverage for negative case
 **/
@isTest public class UAC_immunizationTableControllerTest {
    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String STR_TEST_CLASS_NAME = UAC_immunizationTableControllerTest.class.getName();
  
    /**
     * @description Method to setup test data
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     **/
    @TestSetup static void setupData() {
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
      UAC_healthEvaluation__c objIME =
          new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
      UAC_immunization__c objImmunization = new UAC_testImmunizationBuilder().setUAC(objUACContact.Id).setHealthEval(objIME.Id).buildAndSave();
    }
  
    /**
     * @description Method to test update functionalities of UAC_immunizationTableController
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     */
    @isTest static void testUpdImmunizationTableController() {
      UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
      Test.startTest();
      List<UAC_immunization__c> lstImmune = UAC_immunizationTableController.getImmunizationList(objIME.Id);
      System.assert(!lstImmune.isEmpty(), 'Failed to get Test list');
      UAC_genericResponse objResponse =
      UAC_immunizationTableController.upsertImmunizationList(JSON.serialize(lstImmune));
      System.assertEquals(true, objResponse.isSuccess, 'Failed to Update Immunization record');
      Test.stopTest();
    }

    /**
     * @description Method to test create functionalities of UAC_immunizationTableController
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     */
    @isTest static void testCreateImmunizationTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;      
        Test.startTest();
        UAC_immunization__c objImmuneTest = new UAC_immunization__c(
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_vaccine__c='DTaP',
          UAC_dateAdministered__c = system.today());
        List<UAC_immunization__c> lstImmune = new List<UAC_immunization__c>();
        lstImmune.add(objImmuneTest);
        UAC_genericResponse objResponse =
        UAC_immunizationTableController.upsertImmunizationList(JSON.serialize(lstImmune));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create Immunization record');
        System.assertNotEquals(null, objResponse.data.get('errorMap'), 'Failed to Create Immunization record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_immunizationTableController
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     */
    @isTest static void testDeleteImmunizationTableController() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;       
        Test.startTest();
        UAC_immunization__c objImmuneTest = new UAC_immunization__c(
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_vaccine__c='DTaP',
          UAC_dateAdministered__c = system.today() + 1);
        List<UAC_immunization__c> lstImmune= new List<UAC_immunization__c>();
        lstImmune.add(objImmuneTest);
        UAC_genericResponse objResponse =
        UAC_immunizationTableController.upsertImmunizationList(JSON.serialize(lstImmune));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to Create Immunization record');
        List<UAC_immunization__c> lstImmuneForDel = getImmuneRecord(idUAC,idHealthEval);
        UAC_genericResponse objDelResponse =
        UAC_immunizationTableController.deleteImmunizationList(JSON.serialize(lstImmuneForDel));
        System.assertEquals(true, objDelResponse.isSuccess, 'Failed to Delete Immunization record');
        Test.stopTest();
      }

    /**
     * @description Method to test Delete functionalities of UAC_immunizationTableController
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     */
    @isTest static void testDeleteImmunizationTableControllerNegativeCase() {
        Test.startTest();
        UAC_genericResponse objDelResponse =
        UAC_immunizationTableController.deleteImmunizationList(JSON.serialize(null));
        System.assertEquals(false, objDelResponse.isSuccess, 'Failed to Update Immunization record');
        System.assertNotEquals(null, objDelResponse.error, 'Failed to update Immunization record');
        Test.stopTest();
      }      

    /**
     * @description Method to test Exception case of UAC_immunizationTableController
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     */
    @isTest static void testUpdImmunizationTableControllerNegativeCase() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();
        List<UAC_immunization__c> lstImmune = UAC_immunizationTableController.getImmunizationList(objIME.Id);
        System.assert(!lstImmune.isEmpty(), 'Failed to get Immunization list');
        UAC_genericResponse objResponse =
        UAC_immunizationTableController.upsertImmunizationList(JSON.serialize(null));
        Test.stopTest();
        System.assertEquals(false, objResponse.isSuccess, 'Failed to Update Immunization record');
        System.assertNotEquals(null, objResponse.error, 'Failed to update Immunization record');
      }
  
    /**
     * @description Method to get IME record by UAC A Number
     * @author Abhisek Pati (Deloitte) | 08-12-2020
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
     * @author Abhisek Pati (Deloitte) | 08-12-2020
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
     * @author Abhisek Pati (Deloitte) | 08-12-2020
     * @param strANumber String value for UAC A Number
     * @return UAC_test__c
     */
    public
    static List<UAC_immunization__c> getImmuneRecord(String strUACId,String strHealEvalId ) {
      // clang-format off
      return [
        SELECT
        Id,UAC_associatedUAC__c,UAC_associatedHealthEvaluation__c
        FROM
        UAC_immunization__c
        WHERE
        UAC_associatedUAC__c= :strUACId AND
        UAC_associatedHealthEvaluation__c=: strHealEvalId
        LIMIT 1
      ];
      // clang-format on
    }    

  }