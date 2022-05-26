/**
 * @File Name         : UAC_diagnosisOutcomeController.cls
 * @Description       : Controller class for UAC_diagnosisOutcome LWC
 * @Group             : UAC_diagnosisOutcome
 * @Test Class        : UAC_diagnosisOutcomeControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-07-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-01-2020   Sachet Khanal (Deloitte)   Initial Version (ORRUAC-1974)
 * 1.1   07-13-2020   Abhisek Pati (Deloitte)    ORRUAC-6047 Added check to avoid duplicate error.
 **/
public
with sharing class UAC_diagnosisOutcomeController {

  /**
   * @description Method to upsert Diagnosis Outcome along with diagnosis record
   * @author Sachet Khanal (Deloitte) | 09-01-2020
   * @param strOutcome JSON string for Diagnosis Outcome record
   * @param strAssociatedDiagnosis JSON string for Associated Diagnosis record to update
   * @param strNewDiagnosis JSON string for New Diagnosis record to replace associated diagnosis
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse updateDiagnosisOutcome(
      String strOutcome, String strAssociatedDiagnosis, String strNewDiagnosis) {
    UAC_genericResponse response = new UAC_genericResponse();
    Savepoint objSavePoint = Database.setSavePoint();
    try {
      List<String> lstErrorMessage = new List<String>();
      UAC_diagnosisOutcome__c objDiagnosisOutcome =
          (UAC_diagnosisOutcome__c) JSON.deserialize(strOutcome, UAC_diagnosisOutcome__c.class);
      UAC_diagnosis__c objAssociatedDiagnosis =
          (UAC_diagnosis__c) JSON.deserialize(strAssociatedDiagnosis, UAC_diagnosis__c.class);
      Database.UpsertResult objUpsertResult = Database.upsert(objDiagnosisOutcome, false);
      if (!objUpsertResult.isSuccess()) {
        for (Database.Error objError : objUpsertResult.getErrors()) {
          lstErrorMessage.add(objError.getMessage());
        }
      }
      objUpsertResult = Database.upsert(objAssociatedDiagnosis, false);
      if (!objUpsertResult.isSuccess()) {
        for (Database.Error objError : objUpsertResult.getErrors()) {
          lstErrorMessage.add(objError.getMessage());
        }
      }
      if (!String.isBlank(strNewDiagnosis) && lstErrorMessage.isEmpty()) {
        UAC_diagnosis__c objNewDiagnosis =
            (UAC_diagnosis__c) JSON.deserialize(strNewDiagnosis, UAC_diagnosis__c.class);
        Database.SaveResult objSaveResult = Database.insert(objNewDiagnosis, false);
        if (!objSaveResult.isSuccess()) {
          for (Database.Error objError : objSaveResult.getErrors()) {
            lstErrorMessage.add(objError.getMessage());
          }
        }
      }
      if (!lstErrorMessage.isEmpty()) {
        Database.rollback(objSavePoint);
        response.error = String.join(lstErrorMessage, '\n');
      } else {
        response.isSuccess = true;
      }
    } catch (Exception ex) {
      Database.rollback(objSavePoint);
      response.error = ex.getMessage();
    }
    return response;
  }
}