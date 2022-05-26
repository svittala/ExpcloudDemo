/**
 * @File Name          : UC_immunizationHelperTest.cls
 * @Description        : Test class for UC_immunizationHelper,UC_immunizationHandler
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Nithin Malla (Deloitte)
 * @Last Modified On   : 07/07/2021
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    07/07/2021   	Nithin Malla (Deloitte)        Initial Version
 **/
@isTest(seeAllData = false) public class UC_immunizationHelperTest {
    
    private
    static final String STR_A_NUM_UAC = '123456';
    
    /**
     * @description Method to setup test data
     * @author Nithin Malla (Deloitte) | 07/07/2021
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
     * @description Method to test create functionalities of UAC_immunizationTableController
     * @author Nithin Malla (Deloitte) | 07/07/2021
     */
    @isTest static void testCreateImmunization() {
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
        insert objImmuneTest;
        Test.stopTest();
        
        system.assertEquals('DTaP', objImmuneTest.UAC_vaccine__c);
      }
    
    /**
     * @description Method to test Update functionalities of UAC_immunizationTableController
     * @author Nithin Malla (Deloitte) | 07/07/2021
     */
    @isTest static void testUpdateImmunization() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;  
        UAC_immunization__c objImmuneTest = new UAC_immunization__c(
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_vaccine__c='DTaP',
          UAC_dateAdministered__c = system.today());
        List<UAC_immunization__c> lstImmune = new List<UAC_immunization__c>();
        insert objImmuneTest;    
        
        Test.startTest();
        objImmuneTest.UAC_vaccine__c = 'DTap-IPV';
        update objImmuneTest;
        Test.stopTest();
        system.assertEquals('DTap-IPV', objImmuneTest.UAC_vaccine__c);
      }
    
    /**
     * @description Method to test Delete functionalities of UAC_immunizationTableController
     * @author Nithin Malla (Deloitte) | 07/07/2021
     */
    @isTest static void testDeleteImmunization() {
        UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
        String idUAC=objIME.UAC_associatedUAC__c;
        String idHealthEval=objIME.Id;  
        UAC_immunization__c objImmuneTest = new UAC_immunization__c(
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_vaccine__c='DTaP',
          UAC_dateAdministered__c = system.today());
        List<UAC_immunization__c> lstImmune = new List<UAC_immunization__c>();
        insert objImmuneTest;    
        
        Test.startTest();
        delete objImmuneTest;
        Test.stopTest();
        
        List<UAC_immunization__c> expImmunization = [Select id from UAC_immunization__c where id=:objImmuneTest.Id];
        system.assert(expImmunization.size()==0);
      }
    
    /**
     * @description Method to get IME record by UAC A Number
     * @author Nithin Malla (Deloitte) | 07/07/2021
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

}