/**
 * @File Name         : UAC_flowUpdateAssessment.cls
 * @Description       : Class used to update Assessment records from flows.
 * @Group             : UAC_flowUpdateAssessment
 * @Test Class        : UAC_flowUpdateAssessmentTest
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  : Abhisek Pati (Deloitte)
 * @Last Modified On  : 07-15-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-15-2020   Abhisek Pati (Deloitte)   Initial Version
 **/
public
without sharing class UAC_flowUpdateAssessment {

  @InvocableMethod(label = 'Update Assessment') public static List<Response> updateAssessment(
      List<Request> lstRequest) {
    Request objRequest = lstRequest[0];

    // Clean up fields values
    objRequest.objRecord =
        (UAC_admissionAssessment__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);

    String strDoYouIdentifyAsMulti = String.valueOf(objRequest.objRecord.UAC_doYouIdentifyAs__c);
    String strSexualActivityType = String.valueOf(objRequest.objRecord.UAC_sexualActivityType__c);
    if (!String.isBlank(strDoYouIdentifyAsMulti)) {
      strDoYouIdentifyAsMulti = strDoYouIdentifyAsMulti.replace('[', '');
      strDoYouIdentifyAsMulti = strDoYouIdentifyAsMulti.replace(']', '');
      objRequest.objRecord.UAC_doYouIdentifyAs__c = strDoYouIdentifyAsMulti;
    }

    if (!String.isBlank(strSexualActivityType)) {
      strSexualActivityType = strSexualActivityType.replace('[', '');
      strSexualActivityType = strSexualActivityType.replace(']', '');
      objRequest.objRecord.UAC_sexualActivityType__c = strSexualActivityType;
    }

    // Perform update DML
    List<String> lstErrorMessage = new List<String>();
    List<UAC_admissionAssessment__c> lstAssessmentUpdate = new List<UAC_admissionAssessment__c>();
    lstAssessmentUpdate.add(objRequest.objRecord);
    SObjectAccessDecision securityDecision =
        Security.stripInaccessible(AccessType.UPDATABLE, lstAssessmentUpdate, false);

    UAC_admissionAssessment__c assessmentQueried;
    Set<String> removedFields;
    if (securityDecision.getRemovedFields().containsKey('UAC_admissionAssessment__c')) {
      removedFields = securityDecision.getRemovedFields().get('UAC_admissionAssessment__c');
    }
    if (removedFields != null) {
      Id idAssessment = objRequest.objRecord.Id;

      String queryBase = 'SELECT Id,';
      String queryMiddle = String.join(new List<String>(removedFields), ',');
      String queryEnd = ' FROM UAC_admissionAssessment__c WHERE Id = :idAssessment';
      assessmentQueried = Database.query(queryBase + queryMiddle + queryEnd);
      Map<String, Schema.sObjectField> assessmentFieldLabelMap =
          Schema.SObjectType.UAC_admissionAssessment__c.fields.getMap();
      for (String strField : removedFields) {
        if ((objRequest.objRecord.get(strField) != '')
            && String.valueOf(assessmentQueried.get(strField))
                != String.valueOf(objRequest.objRecord.get(strField))) {

          lstErrorMessage.add('You cannot edit the field: '
              + assessmentFieldLabelMap.get(strField).getDescribe().getLabel());
        }
      }
    }
    if (lstErrorMessage.isEmpty()) {
      try {
        update securityDecision.getRecords();
      } catch (DmlException e) {
        lstErrorMessage.add(e.getDMLMessage(0));
        system.debug('Error:' + lstErrorMessage);
      }
    }

    // Prepare and return response
    Response objResponse = new Response();
    objResponse.objRecord = objRequest.objRecord;
    objResponse.errorMessage =
        (lstErrorMessage.isEmpty()) ? null : String.join(lstErrorMessage, '\n');
    return new List<Response>{objResponse};
  }

  public
  inherited sharing class Request {
    @InvocableVariable(required = true) public UAC_admissionAssessment__c objRecord;
    @InvocableVariable public String strSectionName;
  }

  public 
  inherited sharing class Response {
    @InvocableVariable public UAC_admissionAssessment__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}