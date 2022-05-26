/**
 * @File Name         : UAC_flowUpdateReferralAssessment.cls
 * @Description       : Class used to update Assessment records from flows.
 * @Group             : UAC_flowUpdateReferralAssessment
 * @Test Class        : UAC_flowUpdateReferralAssessmenttest
 * @Author            : Manoj Sharma (Deloitte)
 * @Last Modified By  : Manoj Sharma (Deloitte)
 * @Last Modified On  : 07-15-2020
 * Modifications Log
 **/
public without sharing class UAC_flowUpdateReferralAssessment {

    @InvocableMethod(label = 'Update ReferralAssessment') public static List<Response> updateReferralAssessment(
    List<Request> lstRequest) {
    Request objRequest = lstRequest[0];
	System.debug('objRequest:'+objRequest);
   
    // Clean up fields values
    objRequest.objRecord =  (UAC_referralAssessment__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);
    System.debug('objRequest.objRecord.UAC_outsideSpace__c:'+String.valueOf(objRequest.objRecord.UAC_outsideSpace__c));
        
    String strOutsideSpaceMulti = String.valueOf(objRequest.objRecord.UAC_outsideSpace__c);
    if(!String.isBlank(strOutsideSpaceMulti)){
    	strOutsideSpaceMulti = strOutsideSpaceMulti.replace('[', '');
        strOutsideSpaceMulti = strOutsideSpaceMulti.replace(']', '');  
        objRequest.objRecord.UAC_outsideSpace__c = strOutsideSpaceMulti;          
    }    
    // Perform update DML
    List<String> lstErrorMessage = new List<String>();
    List<UAC_referralAssessment__c> lstAssessmentUpdate = new List<UAC_referralAssessment__c>();
    lstAssessmentUpdate.add(objRequest.objRecord);
    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, lstAssessmentUpdate, false);
    UAC_referralAssessment__c assessmentQueried;
    Set<String> removedFields;
    if(securityDecision.getRemovedFields().containsKey('UAC_referralAssessment__c')) {
        removedFields = securityDecision.getRemovedFields().get('UAC_referralAssessment__c');
    }
    System.debug('removedFields:'+removedFields);
    if(removedFields != null) {
        Id idAssessment = objRequest.objRecord.Id;
        String queryBase = 'SELECT Id,';
        String queryMiddle = String.join(new List<String>(removedFields),',');
        String queryEnd = ' FROM UAC_referralAssessment__c WHERE Id = :idAssessment';
        assessmentQueried = Database.query(queryBase + queryMiddle + queryEnd);
        system.debug('---assessmentQueried'+queryBase + queryMiddle + queryEnd );
        Map<String, Schema.sObjectField> assessmentFieldLabelMap =
        Schema.SObjectType.UAC_referralAssessment__c.fields.getMap();
        for(String strField : removedFields) {
            system.debug('---assessmentQueriedField'+String.valueOf(assessmentQueried.get(strField)));
            system.debug('---objRequestField'+String.valueOf(objRequest.objRecord.get(strField)));
            if((objRequest.objRecord.get(strField) != '') &&
            String.valueOf(assessmentQueried.get(strField)) != String.valueOf(objRequest.objRecord.get(strField))) {

            lstErrorMessage.add('You cannot edit the field: ' + assessmentFieldLabelMap.get(strField)
            .getDescribe()
            .getLabel());
            }
        }
    }
     System.debug('lstErrorMessage:'+lstErrorMessage);
    if(lstErrorMessage.isEmpty()) {
        try{
			if(!securityDecision.getRecords().isEmpty()) 
            update securityDecision.getRecords();
        }catch(DmlException e){
            
            lstErrorMessage.add(e.getDMLMessage(0));
            system.debug('Error:' +lstErrorMessage);
        }

    }

    // Prepare and return response
    Response objResponse = new Response();
    objResponse.objRecord = objRequest.objRecord;
    objResponse.errorMessage =
    (lstErrorMessage.isEmpty()) ? null : String.join(lstErrorMessage, '\n');
     System.debug('objResponse:'+objResponse);
    return new List<Response>{objResponse};
  }

  public
  without sharing class Request {
    @InvocableVariable(required = true) public UAC_referralAssessment__c objRecord;
    @InvocableVariable public String strSectionName;
  }

  public without sharing class Response {
    @InvocableVariable public UAC_referralAssessment__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}