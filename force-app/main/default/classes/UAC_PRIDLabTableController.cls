/**
 * @File Name         : UAC_PRIDLabTableController.cls
 * @Description       : Controller for uacPRIDLabTestTable LWC
 * @Group             : UAC_PRIDLabTestTable
 * @Test Class        : UAC_PRIDLabTestTableControllerTest
 * @Author            : Anupreeta Chakraborty (Deloitte)
 * @Last Modified By  : Anupreeta Chakraborty (Deloitte)
 * @Last Modified On  : 08-04-2020
 * Modifications Log
 * Ver   Date         Author                            Modification
 * 1.0   08-4-2020   Anupreeta Chakraborty (Deloitte)   Initial Version
 **/
public
with sharing class UAC_PRIDLabTableController {

  /**
   * @description Method to get PRID lab Test records related to health evaluation
   * @author Anupreeta Chakraborty (Deloitte) | 08-04-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_test__c>
   **/
  @AuraEnabled public static List<UAC_test__c> getTestList(String healthEvaluationId) {
    // clang-format off
    return [
      SELECT
        Id, Name, UAC_diseaseConditionTested__c, UAC_specifyOtherDiseaseConditionTested__c, UAC_test__c, UAC_specifyOtherTest__c, UAC_result__c,
        UAC_specimenSource__c, UAC_specifyOtherSpecimenSource__c, UAC_specimenCollectionDate__c, UAC_systemGenerated__c
      FROM
        UAC_test__c
      WHERE
        UAC_associatedHealthEvaluation__c=:healthEvaluationId
        AND RecordType.DeveloperName = :Label.UAC_testRecTypePRIDLabTest
      ORDER BY UAC_order__c ASC
    ];
    // clang-format on
  }

  /**
   * @description Method to upsert list of Test records
   * @author Anupreeta Chakraborty (Deloitte) | 08-04-2020
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
   * @author Anupreeta Chakraborty (Deloitte) | 08-04-2020
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