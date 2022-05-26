/**
 * @File Name         : UAC_imagingStudyTestTableController.cls
 * @Description       : Controller for uacImagingStudyTBTable LWC
 * @Group             : UAC_imagingStudyTestTable
 * @Test Class        : UAC_imagingStudyTestTableControllerTest
 * @Author            : Ranjith kumar (AI-Vets)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 08-11-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-05-2020   Ranjith kumar (AI-Vets)   Initial Version
 **/
public
with sharing class UAC_imagingStudyTestTableController {

  /**
   * @description Method to get Test records related to health evaluation
   * @author Ranjith kumar (AI-Vets) | 08-05-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_test__c>
   **/
  @AuraEnabled public static List<UAC_test__c> getTestList(String healthEvaluationId) {
    return [
      SELECT Id,
      Name,
      UAC_specifyOtherTest__c,
      UAC_diseaseConditionTested__c,
      UAC_test__c,
      UAC_result__c,
      UAC_datePerformed__c,
      UAC_radiographicClassification__c,
      createdDate FROM UAC_test__c WHERE UAC_associatedHealthEvaluation__c
      =:healthEvaluationId AND RecordType.DeveloperName
      =:Label.UAC_testRecTypeImagingStudy ORDER BY createdDate asc
    ];
  }

  /**
   * @description Method to upsert list of Test records
   * @author Ranjith kumar (AI-Vets) | 08-05-2020
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
      Set<Id> setTestIds = new Set<Id>();
      Integer intRowIndex = 0;
      for (Database.UpsertResult objUpsertResult : Database.upsert(lstRecord, false)) {
        if (!objUpsertResult.isSuccess()) {
          mapErrors.put(intRowIndex, new List<String>());
          for (Database.Error objError : objUpsertResult.getErrors()) {
            mapErrors.get(intRowIndex).add(objError.getMessage());
          }
        } else {
          mapSuccess.put(intRowIndex, lstRecord[intRowIndex]);
          setTestIds.add(lstRecord[intRowIndex].Id);
        }
        intRowIndex++;
      }
      // clang-format off
	  if(setTestIds.size()>0){
		  Map<Id, UAC_test__c> mapTest = new Map<Id, UAC_test__c>([
			SELECT
			  Id, Name, UAC_specifyOtherTest__c, UAC_diseaseConditionTested__c, UAC_test__c,
			  UAC_result__c, UAC_datePerformed__c, UAC_radiographicClassification__c, CreatedDate
			FROM UAC_test__c
			WHERE
			  Id In:setTestIds
		  ]);
		  // clang-format on
		  for (Integer index : mapSuccess.keySet()) {
			mapSuccess.put(index, mapTest.get(mapSuccess.get(index).Id));
		  }
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
   * @author Ranjith kumar (AI-Vets) | 08-05-2020
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