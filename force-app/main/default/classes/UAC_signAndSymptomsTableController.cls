/**
 * @File Name         : UAC_signAndSymptomsTableController.cls
 * @Description       : Controller class for uacSignAndSymptomsTable LWC
 * @Group             : UAC_signAndSymptomsTableController
 * @Author            : Ranjith kumar(AI-Vets)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 08-19-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-02-2020   Ranjith kumar(AI-Vets)   Initial Version
 **/
public with sharing class UAC_signAndSymptomsTableController {

  /**
 * @description Method to get Sign And Symptoms records related to health evaluation
 * @author Ranjith kumar (AI-Vets) | 08-02-2020
 * @param healthEvaluationId Id of Health Evaluation record
 * @return List<UAC_signsAndSymptoms__c>
 **/
  
  @AuraEnabled public static List<UAC_signsAndSymptoms__c> getSignAndSymptomsList(String healthEvaluationId) {
  
  return [
    SELECT
      Id, Name, UAC_signSymptom__c, UAC_associatedUAC__c, UAC_specifyOtherSignSymptom__c, UAC_signSymptomOnsetDate__c, UAC_onsetDateUnknown__c, UAC_locationofPain__c
    FROM
      UAC_signsAndSymptoms__c
    WHERE
      UAC_associatedHealthEvaluation__c=:healthEvaluationId
  ];
  
}


/**
 * @description Method to upsert list of Sign And Symptoms records
 * @author Ranjith kumar  | 08-02-2020
 * @param strRecordList List of Sign And Symptoms records to upsert in JSON string format
 * @return UAC_genericResponse
 **/
@AuraEnabled public static UAC_genericResponse upsertSignAndSymptomsList(String strRecordList) {
  UAC_genericResponse objResponse = new UAC_genericResponse();
  try {
    List<UAC_signsAndSymptoms__c> lstRecord =
        (List<UAC_signsAndSymptoms__c>) JSON.deserialize(strRecordList, List<UAC_signsAndSymptoms__c>.class);
    Map<Integer, List<String>> mapErrors = new Map<Integer, List<String>>();
    Map<Integer, UAC_signsAndSymptoms__c> mapSuccess = new Map<Integer, UAC_signsAndSymptoms__c>();
    Integer intRowIndex = 0;
      //ToValidate duplicate records
   Set<String> setsignSymptom = new Set<String>();
   Boolean isDuplicateExists = false;
   for(UAC_signsAndSymptoms__c uacSign : lstRecord)
   {
       if(uacSign.UAC_signSymptom__c != null && uacSign.UAC_signSymptom__c != 'Other' && setsignSymptom.Contains(uacSign.UAC_signSymptom__c))
       {
         isDuplicateExists = true;
       }
       setsignSymptom.add(uacSign.UAC_signSymptom__c);
   }
   if(!isDuplicateExists){
     
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
     }else{
          objResponse.isSuccess = false;
        objResponse.error = Label.UAC_SignSymptomDuplicateError;
      }
  } catch (Exception ex) {
    objResponse.error = ex.getMessage();
    UAC_errorLog.platformEventErrorLog(
        ex.getMessage(), null, 'Saving Sign And Symptoms records', ex.getStackTraceString());
  }
  return objResponse;
}

/**
 * @description Method to delete list of Sign And Symptoms records
 * @author Ranjith kumar (AI-Vets) | 08-02-2020
 * @param strRecordList List of Sign And Symptoms records in JSON string format
 * @return UAC_genericResponse
 **/
@AuraEnabled public static UAC_genericResponse deleteSignAndSymptomsList(String strRecordList) {
  UAC_genericResponse objResponse = new UAC_genericResponse();
  try {
    List<UAC_signsAndSymptoms__c> lstRecord =
        (List<UAC_signsAndSymptoms__c>) JSON.deserialize(strRecordList, List<UAC_signsAndSymptoms__c>.class);
    Map<Id, List<String>> mapErrors = new Map<Id, List<String>>();
    Map<Id, UAC_signsAndSymptoms__c> mapSuccess = new Map<Id, UAC_signsAndSymptoms__c>();
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
        ex.getMessage(), null, 'Deleting Sign And Symptoms records', ex.getStackTraceString());
  }
  return objResponse;
}
}