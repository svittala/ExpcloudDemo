/**
 * @File Name          : UAC_createPublicHealthEvaluationTest.cls
 * @Description        : Test class for UAC_createPublicHealthEvaluation
 * @Author             : Vijayakumar Pethanan (Deloitte)
 * @Group              : UAC_exposureEventTable
 * @Last Modified By   : Abhisek Pati (Deloitte)

 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/14/2020   Vijayakumar Pethanan (Deloitte)     Initial Version
 * 1.1    7/20/2021   Abhisek Pati (Deloitte)          ORRUAC-6049 Added error handling test code.
 **/

@IsTest private with sharing class UAC_createPublicHealthEvaluationTest {

  /**
   * @description Method to create test data
   */
  @TestSetup static void setupData() {
    UAC_TestContactBuilder contactBuilder = new UAC_TestContactBuilder();
    Contact cont = contactBuilder.buildAndSave();
    cont.Birthdate = Date.today().addmonths(-104);
    update cont;
  }

  /* @isTest static void testMethodCreatePHIException() {
     contact cont = [select id from contact];
     cont.Birthdate =  null;
     update cont;
     UAC_exposureEvent__c  exposoureEvent = new UAC_exposureEvent__c();
         exposoureEvent.UAC_diseaseCondition__c = 'TB, Active Disease';
         insert exposoureEvent;
         boolean isSuccess = UAC_createPublicHealthEvaluation.createPHI(exposoureEvent.id,new
   List<Id>{cont.id}); System.assert(isSuccess == false,'Creation Public health investigation
   failed');

   }*/

  @isTest static void testMethodCreateTBHealthEvent() {

    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'TB, Active Disease';
    insert exposoureEvent;

    contact cont = [select id from contact];

    UAC_genericResponse objResponse =
        UAC_createPublicHealthEvaluation.createPHI(exposoureEvent.id, new List<Id>{cont.id});
    System.assert(objResponse.isSuccess, 'Creation Public health investigation failed');

    List<UAC_healthEvaluation__c> healthList =
        [select UAC_diseaseCondition__c from UAC_healthEvaluation__c where UAC_exposureEvent__c
            =:exposoureEvent.id];

    // System.assert(healthList.isEmpty() == false,'P');
    System.assertEquals(exposoureEvent.UAC_diseaseCondition__c,
        healthList[0].UAC_diseaseCondition__c,
        ' Test method: Validate PHI information in TB case ');
  }

  @isTest static void testMethodCreateNONTBHealthEvent() {

    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    exposoureEvent.UAC_diseaseCondition__c = 'Mumps';
    insert exposoureEvent;

    contact cont = [select id from contact];

    UAC_genericResponse objResponse =
        UAC_createPublicHealthEvaluation.createPHI(exposoureEvent.id, new List<Id>{cont.id});
    System.assert(objResponse.isSuccess, 'Creation Public health investigation failed');

    List<UAC_healthEvaluation__c> healthList =
        [select UAC_diseaseCondition__c from UAC_healthEvaluation__c where UAC_exposureEvent__c
            =:exposoureEvent.id];

    // System.assert(healthList.isEmpty() == false,'P');
    System.assertEquals(exposoureEvent.UAC_diseaseCondition__c,
        healthList[0].UAC_diseaseCondition__c,
        'Test method: Validate PHI information ');
  }
}