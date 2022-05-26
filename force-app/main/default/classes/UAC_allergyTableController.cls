/**
 * @File Name         : UAC_allergyTableController.cls
 * @Description       : Controller class for uacAllergyTable LWC
 * @Group             : UAC_allergyTableController
 * @Test Class        : UAC_allergyTableControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 07-23-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-22-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
with sharing class UAC_allergyTableController {

  /**
   * @description Method to get Allergy records related to health evaluation
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_allergy__c>
   **/
  @AuraEnabled public static List<UAC_allergy__c> getAllergyList(String healthEvaluationId) {
    // clang-format off
    return [
      SELECT
        Id, Name,UAC_allergen__c, UAC_allergyType__c, UAC_reaction__c
      FROM
        UAC_allergy__c
      WHERE
        UAC_associatedHealthEvaluation__c=:healthEvaluationId
    ];
    // clang-format on
  }

  /**
   * @description Method to upsert list of Allergy records
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param strRecordList List of Allergy records to upsert in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse upsertAllergyList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_allergy__c> lstRecord =
          (List<UAC_allergy__c>) JSON.deserialize(strRecordList, List<UAC_allergy__c>.class);
      Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
      Map<Integer, UAC_allergy__c> mapSuccess = new Map<Integer, UAC_allergy__c>();
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
          ex.getMessage(), null, 'Saving allergy records', ex.getStackTraceString());
    }
    return objResponse;
  }

  /**
   * @description Method to delete list of Allergy records
   * @author Sachet Khanal (Deloitte) | 07-23-2020
   * @param strRecordList List of Allergy records in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse deleteAllergyList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_allergy__c> lstRecord =
          (List<UAC_allergy__c>) JSON.deserialize(strRecordList, List<UAC_allergy__c>.class);
      Map<Id, List<String>> mapErrors = new Map<Id, List<String>>();
      Map<Id, UAC_allergy__c> mapSuccess = new Map<Id, UAC_allergy__c>();
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
          ex.getMessage(), null, 'Deleting allergy records', ex.getStackTraceString());
    }
    return objResponse;
  }
}