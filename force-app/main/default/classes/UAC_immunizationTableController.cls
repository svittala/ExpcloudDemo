/**
 * @File Name         : UAC_immunizationTableController.cls
 * @Description       : Controller for uacImmunizationsTable LWC
 * @Group             : uacImmunizationsTable
 * @Test Class        : UAC_immunizationTableControllerTest
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  : 
 * @Last Modified On  : 
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-12-2020   Abhisek Pati (Deloitte)   Initial Version
 **/
public
with sharing class UAC_immunizationTableController {

  /**
   * @description Method to get Immunization records related to health evaluation
   * @author Abhisek Pati (Deloitte) | 08-12-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_immunization__c>
   **/
  @AuraEnabled public static List<UAC_immunization__c> getImmunizationList(String healthEvaluationId) {
    return [
      SELECT
        Id, Name, UAC_vaccine__c, UAC_specifyOtherVaccine__c, UAC_status__c,UAC_dateAdministered__c,UAC_reasonNotAdministered__c,
        UAC_otherReasonNotAdministered__c, UAC_expectedShortageDuration__c
      FROM
        UAC_immunization__c
      WHERE
        UAC_associatedHealthEvaluation__c=:healthEvaluationId
      ORDER BY
      createdDate asc  
    ];
  }

  /**
   * @description Method to upsert list of Immunization records
   * @author Abhisek Pati (Deloitte) | 08-12-2020
   * @param strRecordList List of Test records to upsert in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse upsertImmunizationList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_immunization__c> lstRecord =
          (List<UAC_immunization__c>) JSON.deserialize(strRecordList, List<UAC_immunization__c>.class);
      Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
      Map<Integer, UAC_immunization__c> mapSuccess = new Map<Integer, UAC_immunization__c>();
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
          ex.getMessage(), null, 'Saving Immunization records', ex.getStackTraceString());
    }
    return objResponse;
  }

  /**
   * @description Method to delete list of Immunization records
   * @author Abhisek Pati (Deloitte) | 08-12-2020
   * @param strRecordList List of Test records in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse deleteImmunizationList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_immunization__c> lstRecord =
          (List<UAC_immunization__c>) JSON.deserialize(strRecordList, List<UAC_immunization__c>.class);
      Map<Id, List<String>> mapErrors = new Map<Id, List<String>>();
      Map<Id, UAC_immunization__c> mapSuccess = new Map<Id, UAC_immunization__c>();
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
          ex.getMessage(), null, 'Deleting Immunization records', ex.getStackTraceString());
    }
    return objResponse;
  }
}