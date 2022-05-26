/**
 * @File Name         : UAC_flowUpdateNonTBPHI.cls
 * @Description       : Class used to update Non-TB Disease Public Health Investigation(Health Evaluation) records from Non TB Disease PHI flows.
 * @Group             : UAC_flowUpdateNonTBPHI
 * @Test Class        : UAC_flowUpdateNonTBPHITest
 * @Author            : Ranjith Gatike (AI-Vets)
 * @Last Modified By  : Ranjith Gatike (AI-Vets)
 * @Last Modified On  : 09-16-2020
 * Modifications Log
 * Ver  Date        Author                                Modification
 * 1.0  09-14-2020  Ranjith Gatike (AI-Vets)      Initial Version
 **/
public
with sharing class UAC_flowUpdateNonTBPHI {

  @InvocableMethod(label = 'Update Non TB PHI') public static List<Response> updateNonTBPHI(
    List<Request> lstRequest) {
    Request objRequest = lstRequest[0];

    // Clean up fields values
    objRequest.objRecord =
        (UAC_healthEvaluation__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);

     
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
   * @author Ranjith Gatike (AI-Vets) | 09-14-2020
   * @Group             : UAC_flowUpdateNonTBPHI
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
   * @author Ranjith Gatike (AI-Vets) | 09-14-2020
   * @Group             : UAC_flowUpdateNonTBPHI
   **/
  public 
  inherited sharing class Response {
    @InvocableVariable public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}