/**
 * @File Name         : UAC_physicalExamTableController.cls
 * @Description       : Controller class for uacPhysicalExamTable LWC
 * @Group             : UAC_physicalExamTableController
 * @Test Class        : UAC_physicalExamTableController
 * @Author            : Karthi Subramanian (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 08-04-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-27-2020   Karthi Subramanian (Deloitte)   Initial Version
 * 1.1   08-04-2020  Karthi Subramanian (Deloitte)   Adding Order by Clause
 * 1.3   08-26-2020   Abhisek Pati (Deloitte)         Added Methods to upsert and delete for ORRUAC-1960
 **/
public
with sharing class UAC_physicalExamTableController {

  /**
   * @description Method to get Physical Exam records related to health evaluation
   * @author Karthi Subramanian (Deloitte) | 07-27-2020
   * @param healthEvaluationId Id of Health Evaluation record
   * @return List<UAC_physicalExam__c>
   **/
  @AuraEnabled public static List<UAC_physicalExam__c> getPhysicalExamList(String healthEvaluationId) {
    // clang-format off
    return [
      SELECT
        Id,Name,UAC_otherSystemExamined__c,UAC_physicalSystem__c,UAC_specify__c,UAC_status__c        
      FROM
        UAC_physicalExam__c
      WHERE
        UAC_associatedHealthEvaluation__c=:healthEvaluationId
      ORDER BY UAC_order__c ASC
    ];
    // clang-format on
  }

  /**
   * @description Method to update list of Physical Exam records
   * @author Karthi Subramanian (Deloitte) | 07-27-2020
   * @param strRecordList List of Physical Exam records to update in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse updatePhysicalExamList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_physicalExam__c> lstRecord =
          (List<UAC_physicalExam__c>) JSON.deserialize(strRecordList, List<UAC_physicalExam__c>.class);
      Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
      Map<Integer, UAC_physicalExam__c> mapSuccess = new Map<Integer, UAC_physicalExam__c>();
      Integer intRowIndex = 0;
      for (Database.SaveResult objUpdateResult : Database.update(lstRecord, false)) {
        if (!objUpdateResult.isSuccess()) {
          mapErrors.put(intRowIndex, new List<String>());
          for (Database.Error objError : objUpdateResult.getErrors()) {
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
          ex.getMessage(), null, 'Saving Physical Exam records', ex.getStackTraceString());
    }
    return objResponse;
  }

  /**
   * @description Method to upsert list of Physical Exam records
   * @author Abhisek Pati (Deloitte) | 08-26-2020
   * @param strRecordList List of Physical Exam records to upsert in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse upsertPhysicalExamList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_physicalExam__c> lstRecord = (List<UAC_physicalExam__c>) JSON.deserialize(
          strRecordList, List<UAC_physicalExam__c>.class);
      Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
      Map<Integer, UAC_physicalExam__c> mapSuccess = new Map<Integer, UAC_physicalExam__c>();
      Integer intRowIndex = 0;
      // ToValidate duplicate records
      Set<String> setPhysicalSystem = new Set<String>();
      Boolean isDuplicateExists = false;
      for (UAC_physicalExam__c uacPhyExam : lstRecord) {
        if (uacPhyExam.UAC_physicalSystem__c != null && uacPhyExam.UAC_physicalSystem__c != 'Other'
            && setPhysicalSystem.Contains(uacPhyExam.UAC_physicalSystem__c)) {
          isDuplicateExists = true;
        }
        setPhysicalSystem.add(uacPhyExam.UAC_physicalSystem__c);
      }
      if (!isDuplicateExists) {
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
      } else {
        objResponse.isSuccess = false;
        objResponse.error = Label.UAC_HAPhysicalExamDuplicateError;
      }
    } catch (Exception ex) {
      objResponse.error = ex.getMessage();
      UAC_errorLog.platformEventErrorLog(
          ex.getMessage(), null, 'Saving Physical Exam records', ex.getStackTraceString());
    }
    return objResponse;
  }

  /**
   * @description Method to delete list of Physical Exam records
   * @author Abhisek Pati (Deloitte) | 08-26-2020
   * @param strRecordList List of Physical Exam records in JSON string format
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse deletePhysicalExamList(String strRecordList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      List<UAC_physicalExam__c> lstRecord = (List<UAC_physicalExam__c>) JSON.deserialize(
          strRecordList, List<UAC_physicalExam__c>.class);
      Map<Id, List<String>> mapErrors = new Map<Id, List<String>>();
      Map<Id, UAC_physicalExam__c> mapSuccess = new Map<Id, UAC_physicalExam__c>();
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
          ex.getMessage(), null, 'Deleting Physical Exam records', ex.getStackTraceString());
    }
    return objResponse;
  }
}