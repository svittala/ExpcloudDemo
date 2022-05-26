/**
 * @File Name         : UAC_flowUpdateOONSiteVisitTest
 * @Description       : Test class for UAC_flowUpdateOONSiteVisit class
 * @Group             : UAC_flowUpdateOONSiteVisit
 * @Author            : Karthi Subramanian (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 11-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-27-2020   Karthi Subramanian (Deloitte)   Initial Version
 * 1.1   11-03-2020   Karthi Subramanian (Deloitte)   use of setRecordTypeDeveloperName method of test builder
 **/
@isTest public class UAC_flowUpdateOONSiteVisitTest {

    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String STR_TEST_CLASS_NAME = UAC_flowUpdateOONSiteVisitTest.class.getName();
  
    @TestSetup static void setupData() {
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .buildAndSave();
    }

    /**
     * @description Test Method to validate update of testUpdateOONSiteVisit.
     * * @author Karthi Subrmanian (Deloitte) | 10-27-2020
     * @param N/A
     * @return N/A
    **/
    @isTest static void testUpdateOONSiteVisit() {
      Contact objUACContact =
          UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});

      UAC_healthEvaluation__c objMHSR =
          new UAC_testHealthEvaluationBuilder()
              .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameMentalHealthServiceReport)
              .setUAC(objUACContact.Id)
              .setServiceCategory(Label.UAC_serviceCatPicklistOONStay)
              .buildMentalHealthServiceReport();          
      
      UAC_healthEvaluation__c objOONSiteVisit =
          new UAC_testHealthEvaluationBuilder()
              .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameOONSiteVisit)
              .setUAC(objUACContact.Id)
              .setAssociatedHealthEval(objMHSR.Id)              
              .buildOONSiteVisit();
      objOONSiteVisit.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
      UAC_flowUpdateOONSiteVisit.Request objRequest = new UAC_flowUpdateOONSiteVisit.Request();
      objRequest.objRecord = objOONSiteVisit;
      objRequest.strSectionName = Label.UAC_OONSiteVisit;
      Test.startTest();
      UAC_flowUpdateOONSiteVisit.Response objResponse =
      UAC_flowUpdateOONSiteVisit.updateOONSiteVisit(new List<UAC_flowUpdateOONSiteVisit.Request>{objRequest})[0];
      Test.stopTest();
      System.assertEquals(
          null, objResponse.errorMessage, 'Test method:testUpdateOONSiteVisit() failed.');
    }
    
    /**
     * @description Test Method to validate update of testUpdateOONSiteVisitNegativeScenario.
     * * @author Karthi Subrmanian (Deloitte) | 10-27-2020
     * @param N/A
     * @return N/A
    **/
    @isTest static void testUpdateOONSiteVisitNegativeScenario() {
        Contact objUACContact =
            UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
        UAC_healthEvaluation__c objMHSR =
            new UAC_testHealthEvaluationBuilder()
                .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameMentalHealthServiceReport)
                .setUAC(objUACContact.Id)
                .setServiceCategory(Label.UAC_serviceCatPicklistOONStay)
                .buildMentalHealthServiceReport();          
        
        UAC_healthEvaluation__c objOONSiteVisit =
            new UAC_testHealthEvaluationBuilder()
                .setRecordTypeDeveloperName(Label.UAC_healthEvaluationRecordTypeApiNameOONSiteVisit)
                .setUAC(objUACContact.Id)
                .setAssociatedHealthEval(objMHSR.Id)              
                .buildOONSiteVisit();
        objOONSiteVisit.UAC_nameOfHealthcareProvider__c = STR_TEST_CLASS_NAME;
        objOONSiteVisit.UAC_associatedUAC__c = null;                
        UAC_flowUpdateOONSiteVisit.Request objRequest = new UAC_flowUpdateOONSiteVisit.Request();
        objRequest.objRecord = objOONSiteVisit;
        objRequest.strSectionName =Label.UAC_OONSiteVisit;
        Test.startTest();
        UAC_flowUpdateOONSiteVisit.Response objResponse =
        UAC_flowUpdateOONSiteVisit.updateOONSiteVisit(new List<UAC_flowUpdateOONSiteVisit.Request>{objRequest})[0];
        Test.stopTest();
        System.assertNotEquals(
            null, objResponse.errorMessage, 'Test method:testUpdateOONSiteVisitNegativeScenario() failed.');
      }
}