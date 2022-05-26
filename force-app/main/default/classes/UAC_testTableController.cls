/**
 * @File Name         : UAC_testTableController.cls
 * @Description       : Controller for following LWC: uacBacteriologicalTable
 * @Group             : UAC_testTable
 * @Test Class        : UAC_testTableController
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 08-04-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-04-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
with sharing class UAC_testTableController {

  /**
   * @description Method to get Test records related to health evaluation
   * @author Sachet Khanal (Deloitte) | 08-04-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_test__c>
   **/
  @AuraEnabled public static List<UAC_test__c> getTestList(
      String healthEvaluationId, String strRecordTypeName, List<String> lstFieldsToQuery) {
    Set<String> setFieldsToQuery = new Set<String>();
    for (String strFieldName : lstFieldsToQuery) {
      strFieldName = String.escapeSingleQuotes(strFieldName).trim();
      setFieldsToQuery.add(strFieldName);
    }
    setFieldsToQuery.add('Id');
    setFieldsToQuery.add('UAC_systemGenerated__c');

    String strQuery = 'SELECT ' + String.join(new List<String>(setFieldsToQuery), ',');
    strQuery += ' FROM UAC_test__c';
    strQuery += ' WHERE UAC_associatedHealthEvaluation__c = :healthEvaluationId';
    strQuery += ' AND RecordType.DeveloperName = :strRecordTypeName';

    return Database.query(strQuery);
  }

  /**
   * @description Method to upsert list of Test records
   * @author Sachet Khanal (Deloitte) | 08-04-2020
   * @param strRecordList List of Test records to upsert in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse upsertTestList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_test__c> lstRecord =
          (List<UAC_test__c>) JSON.deserialize(strRecordList, List<UAC_test__c>.class);
      Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
      Map<Integer, UAC_test__c> mapSuccess = new Map<Integer, UAC_test__c>();
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
          ex.getMessage(), null, 'Saving test records', ex.getStackTraceString());
    }
    return objResponse;
  }

  /**
   * @description Method to delete list of Test records
   * @author Sachet Khanal (Deloitte) | 08-04-2020
   * @param strRecordList List of Test records in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse deleteTestList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_test__c> lstRecord =
          (List<UAC_test__c>) JSON.deserialize(strRecordList, List<UAC_test__c>.class);
      Map<Id, List<String>> mapErrors = new Map<Id, List<String>>();
      Map<Id, UAC_test__c> mapSuccess = new Map<Id, UAC_test__c>();
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
          ex.getMessage(), null, 'Deleting test records', ex.getStackTraceString());
    }
    return objResponse;
  }
}