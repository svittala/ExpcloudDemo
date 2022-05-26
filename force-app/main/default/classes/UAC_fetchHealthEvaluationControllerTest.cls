/**
 * @File Name          : UAC_fetchHealthEvaluationControllerTest.cls
 * @Description        : Test class for UAC_fetchHealthEvaluationController
 * @Author             : Vijayakumar Pethanan (Deloitte)
 * @Group              : UAC_exposureEventTable
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/11/2020   Vijayakumar Pethanan (Deloitte)     Initial Version
 **/
@isTest private with sharing class UAC_fetchHealthEvaluationControllerTest {

  @isTest static void testMethodgetExposureContacts() {
    UAC_TestContactBuilder contactBuilder = new UAC_TestContactBuilder();
    Contact cont = contactBuilder.buildAndSave();

    UAC_exposureEvent__c exposoureEvent = new UAC_exposureEvent__c();
    insert exposoureEvent;

    UAC_healthEvaluation__c healthEvaluation = new UAC_healthEvaluation__c();
    healthEvaluation.UAC_dateofLastExposure__c = Date.today();
    healthEvaluation.UAC_associatedUAC__c = cont.id;
    healthEvaluation.UAC_exposureEvent__c = exposoureEvent.id;
    insert healthEvaluation;
    List<UAC_healthEvaluation__c> objFieldInfo =
        UAC_fetchHealthEvaluationController.getExposureContacts(exposoureEvent.id);
    System.assert(objFieldInfo.isEmpty() == false, 'Test method: getExposureContacts() failed.');

    System.assertEquals(Date.today(),
        objFieldInfo[0].UAC_dateofLastExposure__c,
        'Test method: healthEvaluation.UAC_dateofLastExposure__c ');
  }
}