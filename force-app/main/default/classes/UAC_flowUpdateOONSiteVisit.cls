/**
 * @File Name         : UAC_flowUpdateOONSiteVisit.cls
 * @Description       : Class used to update OON Site Visit (Health Evaluation) records from OON Site Visit flows.
 * @Group             : UAC_flowUpdateOONSiteVisit
 * @Test Class        : UAC_flowUpdateOONSiteVisitTest
 * @Author            : Karthi Subramanian (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 10-26-2020
 * Modifications Log
 * Ver  Date        Author                                Modification
 * 1.0  10-26-2020  Karthi Subramanian (Deloitte)              Initial Version
 **/
public
with sharing class UAC_flowUpdateOONSiteVisit {

  @InvocableMethod(label = 'Update OONSiteVisit') public static List<Response> updateOONSiteVisit(
    List<Request> lstRequest) {
    Request objRequest = lstRequest[0];

    // Clean up fields values
    objRequest.objRecord =
        (UAC_healthEvaluation__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);

    if (objRequest.strSectionName == Label.UAC_OONSiteVisit) {
          objRequest.objRecord.UAC_mentalHealthEvaluationStatus__c = Label.UAC_statusComplete;
          if(objRequest.objRecord.UAC_dateCompleted__c==null)
              objRequest.objRecord.UAC_dateCompleted__c = System.today();
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
   * @description Request class to hold request data
   * Each @InvocableVariable defined in this class is an input variable you can populate when
   *calling this from Flow
   * @author Karthi Subramanian (Deloitte) | 10-26-2020
   * @Group             : UAC_flowUpdateOONSiteVisit
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
   * @author Karthi Subramanian (Deloitte) | 10-26-2020
   * @Group             : UAC_flowUpdateOONSiteVisit
   **/
  public
  inherited sharing  class Response {
    @InvocableVariable public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}