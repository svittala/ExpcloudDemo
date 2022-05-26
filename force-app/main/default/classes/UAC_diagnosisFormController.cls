/**
 * @File Name         : UAC_diagnosisFormController.cls
 * @Description       : Controller class for uacDiagnosisForm LWC
 * @Group             : UAC_diagnosisForm
 * @Test Class        : UAC_diagnosisFormControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-15-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-11-2020   Sachet Khanal (Deloitte)   Initial Version (ORRUAC-2190)
 **/
public
with sharing class UAC_diagnosisFormController {

  /**
   * @description Method to upsert diagnosis and replacement diagnosis (optional) records.
   * @author Sachet Khanal (Deloitte) | 09-11-2020
   * @param diagnosis JSON string value for  diagnosis record
   * @param replacementDiagnosis JSON string value for replacement diagnosis record (if applicable)
   * @return UAC_genericResponse
   **/
  @AuraEnabled public static UAC_genericResponse saveDiagnosis(
      String diagnosis, String replacementDiagnosis) {
    UAC_genericResponse response = new UAC_genericResponse();
    Savepoint objSavePoint = Database.setSavePoint();
    try {
      UAC_diagnosis__c objDiagnosis =
          (UAC_diagnosis__c) JSON.deserialize(diagnosis, UAC_diagnosis__c.class);
      Database.UpsertResult objUpsertResult = Database.upsert(objDiagnosis, false);
      List<String> lstError = new List<String>();
      if (!objUpsertResult.isSuccess()) {
        for (Database.Error objError : objUpsertResult.getErrors()) {
          lstError.add(objError.getMessage());
        }
      }
      if (String.isNotBlank(replacementDiagnosis)) {
        UAC_diagnosis__c objReplacementDiagnosis =
            (UAC_diagnosis__c) JSON.deserialize(replacementDiagnosis, UAC_diagnosis__c.class);
        if (objReplacementDiagnosis != null) {
          objUpsertResult = Database.upsert(objReplacementDiagnosis, false);
        }
        if (!objUpsertResult.isSuccess()) {
          for (Database.Error objError : objUpsertResult.getErrors()) {
            lstError.add('(Replacement Diagnosis) ' + objError.getMessage());
          }
        }
      }
      if (!lstError.isEmpty()) {
        Database.rollback(objSavePoint);
        response.error = String.join(lstError, '<br/>');
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