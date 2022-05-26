/**
 * @File Name         : UAC_flowUpdateIMHE.cls
 * @Description       : Used to update Initial Mental Health Evaluation record from IMHE flows.
 * @Group             : UAC_flowUpdateIMHE
 * @Test Class        : UAC_flowUpdateIMHETest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 10-01-2020
 * Modifications Log
 * Ver  Date        Author                        Modification
 * 1.0  09-29-2020  Sachet Khanal (Deloitte)      Initial Version
 * 1.1  10-01-2020  Abhisek Pati (Deloitte)       ORRUAC-2830 Added Status update for Suicidal Risk
 **/
public
with sharing class UAC_flowUpdateIMHE {

  @InvocableMethod(label = 'Update IMHE') public static List<Response> updateIMHE(
      List<Request> lstRequest) {
    Request objRequest = lstRequest[0];

    // Clean up fields values
    objRequest.objRecord =
        (UAC_healthEvaluation__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);

    if (objRequest.strSectionName == Label.UAC_imheSectionMentalStatusEvaluation) {
      objRequest.objRecord.UAC_mentalStatusEvaluationStatus__c = Label.UAC_statusComplete;
    }
    if (objRequest.strSectionName == Label.UAC_imheSectionSubstanceUseHistory) {
      objRequest.objRecord =
          (UAC_healthEvaluation__c) validateSubstanceUseHistory(objRequest.objRecord);
      objRequest.objRecord.UAC_substanceUseHistoryStatus__c = Label.UAC_substanceUseHistoryStatus;
    }
    if (objRequest.strSectionName == Label.UAC_imheSectionSuicidalHomicidalRiskAssessment) {
      objRequest.objRecord.UAC_suicidalHomicidalRiskStatus__c = Label.UAC_statusComplete;
    }

    // Perform update DML
    List<String> lstErrorMessage = new List<String>();
    Database.SaveResult objSaveResult = Database.update(objRequest.objRecord, false);
    if (!objSaveResult.isSuccess()) {
      for (Database.Error objError : objSaveResult.getErrors()) {
        lstErrorMessage.add(objError.getMessage());
      }
    }

    // Prepare and return response
    Response objResponse = new Response();
    objResponse.objRecord = objRequest.objRecord;
    objResponse.errorMessage =
        (lstErrorMessage.isEmpty()) ? null : String.join(lstErrorMessage, '\n');
    return new List<Response>{objResponse};
  }

  /**
   * @description Method to clean value types for Flow variables and conditional logic for
   *Substance Use History section. Used to clean values from Flow.
   * @author Karthi Subrmanian (Deloitte) | 09-30-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static sObject validateSubstanceUseHistory(SObject objSObject) {

    // Adding default value for Checkbox datatype to false; Flow variable will be defaulted to null
    // if not displayed on screen
    for (String strFieldName : objSObject.getPopulatedFieldsAsMap().keySet()) {
      if (objSObject.getSObjectType()
              .getDescribe()
              .fields.getMap()
              .get(strFieldName)
              .getDescribe()
              .getType()
          == Schema.DisplayType.BOOLEAN) {
        if (objSObject.get(strFieldName) == null) {
          objSObject.put(strFieldName, Boolean.valueOf('false'));
        } else {
          objSObject.put(strFieldName, Boolean.valueOf(objSObject.get(strFieldName)));
        }
      }
    }
    return objSObject;
  }


  /**
   * @description Request class to hold request data
   * Each @InvocableVariable defined in this class is an input variable you can populate when
   *calling this from  Flow
   * @author Sachet Khanal (Deloitte) | 07-15-2020
   * @Group             : UAC_flowUpdateIME
   **/
  public
  inherited sharing class Request {
    @InvocableVariable(required = true) public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String strSectionName;
  }

  /**
   * @description Response class to hold response data
   * Each @InvocableVariable defined in this class is an output variable and you can populate use it
   *in  Flow
   * @author Sachet Khanal (Deloitte) | 07-15-2020
   * @Group             : UAC_flowUpdateIME
   **/
  public 
  inherited sharing class Response {
    @InvocableVariable public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}