/**
 * @File Name          : UC_allergyHandlerTest.cls
 * @Description        : Test class for Allergy Trigger , Handler 
 * @Author             : Piyush(Deloitte)
 * @Last Modified On   : 07/08/2021
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    07/08/2021   	Piyush (Deloitte)        Initial Version
 **/
@isTest(seeAllData = false)
public class UC_allergyHandlerTest {
    private static final String STR_A_NUM_UAC = '123456';
    /**
     * @description Method to setup test data
     * @author Piyush (Deloitte) | 07/08/2021
     **/
    @TestSetup static void setupData() {
        Contact objUACContact = new UAC_testContactBuilder().setANumber(STR_A_NUM_UAC).setEmail(STR_A_NUM_UAC + '@example.invalid')
                                    .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                    .buildAndSave();
        UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
        //UAC_immunization__c objImmunization = new UAC_testImmunizationBuilder().setUAC(objUACContact.Id).setHealthEval(objIME.Id).buildAndSave();
      }
      
      /**
       * @description Method to test record insert
       * @author Piyush (Deloitte) | 07/08/2021
       */
      @isTest static void testCreateAllergy() {
          UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
          String idUAC = objIME.UAC_associatedUAC__c;
          String idHealthEval = objIME.Id;      
          Test.startTest();
          UAC_allergy__c objAlgyTest = new UAC_allergy__c(UAC_associatedUAC__c = idUAC, UAC_associatedHealthEvaluation__c = idHealthEval, UAC_allergyType__c='Food',
                                                          UAC_allergen__c = 'Nuts', UAC_reaction__c = 'Rashes');
          insert objAlgyTest;
          Test.stopTest();
          system.assertEquals('Food', objAlgyTest.UAC_allergyType__c);
        }
      
      /**
       * @description Method to test Update functionalities of UAC_immunizationTableController
       * @author Piyush (Deloitte) | 07/08/2021
       */
      @isTest static void testUpdateAllergy() {
          UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
          String idUAC = objIME.UAC_associatedUAC__c;
          String idHealthEval = objIME.Id;  
          UAC_allergy__c objAlgyTest = new UAC_allergy__c(UAC_associatedUAC__c = idUAC, UAC_associatedHealthEvaluation__c = idHealthEval, UAC_allergyType__c='Food',
                                                          UAC_allergen__c = 'Nuts', UAC_reaction__c = 'Rashes');
          insert objAlgyTest;    
          
          Test.startTest();
          objAlgyTest.UAC_reaction__c = 'Fever';
          update objAlgyTest;
          Test.stopTest();
          system.assertEquals('Fever', objAlgyTest.UAC_reaction__c);
        }
      
      /**
       * @description Method to test Delete functionalities of UAC_immunizationTableController
       * @author Piyush (Deloitte) | 07/08/2021
       */
      @isTest static void testDeleteAllergy() {
          UAC_healthEvaluation__c objIME = getUACByUACANumber(STR_A_NUM_UAC);
          String idUAC = objIME.UAC_associatedUAC__c;
          String idHealthEval = objIME.Id;  
          UAC_allergy__c objAlgyTest = new UAC_allergy__c(UAC_associatedUAC__c = idUAC, UAC_associatedHealthEvaluation__c = idHealthEval, UAC_allergyType__c='Food',
                                                          UAC_allergen__c = 'Nuts', UAC_reaction__c = 'Rashes');
          insert objAlgyTest;  
          
          Test.startTest();
          delete objAlgyTest;
          Test.stopTest();
          
          List<UAC_allergy__c> lstAllgyRecs = [Select id from UAC_allergy__c where id =:objAlgyTest.Id];
          system.assert(lstAllgyRecs.size()==0);
        }
      
      /**
       * @description Method to get IME record by UAC A Number
       * @author Piyush (Deloitte) | 07/08/2021
       * @param strANumber String value for UAC A Number
       * @return UAC_healthEvaluation__c
       */
      public
      static UAC_healthEvaluation__c getUACByUACANumber(String strANumber) {
        return [SELECT Id,UAC_associatedUAC__c FROM UAC_healthEvaluation__c WHERE UAC_associatedUAC__r.UAC_a__c = :strANumber LIMIT 1];
      }    
}