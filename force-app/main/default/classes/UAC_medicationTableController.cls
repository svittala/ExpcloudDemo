/**
 * @File Name         : UAC_medicationTableController.cls
 * @Description       : Controller for uacPHIMedicationTable LWC
 * @Group             : uacPHIMedicationTable
 * @Test Class        : UAC_medicationTableControllerTest
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  :
 * @Last Modified On  :
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-17-2020   Abhisek Pati (Deloitte)   Initial Version
 **/
public
with sharing class UAC_medicationTableController {

  /**
   * @description Method to get Medication records related to health evaluation
   * @author Abhisek Pati (Deloitte) | 09-17-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_medication__c>
   **/
  @AuraEnabled public static List<UAC_medication__c> getMedicationList(String healthEvaluationId) {
    return [SELECT Id,
      Name,
      UAC_reasonForMedication__c,
      UAC_dateStarted__c,
      UAC_dateDiscontinued__c,
      UAC_direction__c,
      UAC_dose__c,
      UAC_psychotropic__c,
      UAC_dischargedWithMedication__c FROM UAC_medication__c WHERE UAC_associatedHealthEvaluation__c
      =:healthEvaluationId ORDER BY createdDate asc];
  }
  /**
   * @description Method to get Medication records related to health evaluation displayed on inital
   *intakes assessment
   * @author Issam Awwad (Deloitte) | 01-22-2021
   * @param assessmentRecordId Id of Initial Intakes Assessment
   * @return List<UAC_medication__c>
   **/
  @AuraEnabled public static List<UAC_medication__c> getMedicationListForAssessment(
      String assessmentRecordId) {
    return [SELECT Id,
      Name,
      UAC_reasonForMedication__c,
      UAC_dateStarted__c,
      UAC_dateDiscontinued__c,
      UAC_direction__c,
      UAC_dose__c,
      UAC_psychotropic__c,
      UAC_dischargedWithMedication__c,
      UAC_enteredfromInitialIntakesAssessment__c FROM UAC_medication__c WHERE
          UAC_admissionAssessment__c
      =:assessmentRecordId AND UAC_enteredfromInitialIntakesAssessment__c =
            true ORDER BY createdDate asc];
  }

  /**
   * @description Method to upsert list of Medication records
   * @author Abhisek Pati (Deloitte) | 09-17-2020
   * @param strRecordList List of Medication records to upsert in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse upsertMedicationList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_medication__c> lstRecord =
          (List<UAC_medication__c>) JSON.deserialize(strRecordList, List<UAC_medication__c>.class);
      Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
      Map<Integer, UAC_medication__c> mapSuccess = new Map<Integer, UAC_medication__c>();
      Integer intRowIndex = 0;
      for (Database.UpsertResult objUpsertResult : Database.upsert(lstRecord, false)) {
        if (!objUpsertResult.isSuccess()) {
          mapErrors.put(intRowIndex, new List<String>());
          for (Database.Error objError : objUpsertResult.getErrors()) {
            mapErrors.get(intRowIndex).add(objError.getMessage());
          }
        } else {
          mapSuccess.put(intRowIndex, lstRecord[intRowIndex]);
        }
        intRowIndex++;
      }
      objResponse.isSuccess = true;
      objResponse.data.put('errorMap', mapErrors);
      objResponse.data.put('successMap', mapSuccess);
    } catch (Exception ex) {
      objResponse.error = ex.getMessage();
      UAC_errorLog.platformEventErrorLog(
          ex.getMessage(), null, 'Saving Medication records', ex.getStackTraceString());
    }
    return objResponse;
  }

  /**
   * @description Method to delete list of Medication records
   * @author Abhisek Pati (Deloitte) | 09-17-2020
   * @param strRecordList List of Medication records in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse deleteMedicationList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_medication__c> lstRecord =
          (List<UAC_medication__c>) JSON.deserialize(strRecordList, List<UAC_medication__c>.class);
      Map<Id, List<String>> mapErrors = new Map<Id, List<String>>();
      Map<Id, UAC_medication__c> mapSuccess = new Map<Id, UAC_medication__c>();
      Integer intRowIndex = 0;
      for (Database.DeleteResult objDeleteResult : Database.delete(lstRecord, false)) {
        if (!objDeleteResult.isSuccess()) {
          mapErrors.put(lstRecord[intRowIndex].Id, new List<String>());
          for (Database.Error objError : objDeleteResult.getErrors()) {
            mapErrors.get(lstRecord[intRowIndex].Id).add(objError.getMessage());
          }
        } else {
          mapSuccess.put(lstRecord[intRowIndex].Id, lstRecord[intRowIndex]);
        }
        intRowIndex++;
      }
      objResponse.isSuccess = true;
      objResponse.data.put('errorMap', mapErrors);
      objResponse.data.put('successMap', mapSuccess);
    } catch (Exception ex) {
      objResponse.error = ex.getMessage();
      UAC_errorLog.platformEventErrorLog(
          ex.getMessage(), null, 'Deleting Medication records', ex.getStackTraceString());
    }
    return objResponse;
  }
  /**
   * @description Method to get the Health Evaluation record
   * @author Sarang Padhye (Deloitte) | 10-06-2020
   * @param admissionAssesmentId
   * @return
   **/
  @AuraEnabled public static UAC_admissionAssessment__c getAdmissionAssesment(
      String admissionAssesmentId) {
    return
        [select id, UAC_healthEvaluationIme__c, UAC_uac__c from UAC_admissionAssessment__c where id
          =:admissionAssesmentId];
  }
}