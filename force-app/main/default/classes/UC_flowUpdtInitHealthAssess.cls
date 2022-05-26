/**
 * @File Name         : UC_flowUpdtInitHealthAssess.cls
 * @Description       : Class used to update Initial Health Assessment records from flows. ORRUAC-3201
 * @Group             : UC_flowUpdtInitHealthAssess
 * @Test Class        : UC_flowUpdtInitHealthAssesstest
 * @Author            : Piyush(Deloitte)
 * @Last Modified On  : 02-09-2021
 * Modifications Log
 **/
public without sharing class UC_flowUpdtInitHealthAssess {
    @InvocableMethod(label = 'Update InitialHealthAssessment') 
    public static List<Response> updateIniHealthAssessment(List<Request> lstRequest){
        Request objRequest = lstRequest[0];
        System.debug('objRequest:'+objRequest);
    
        // Clean up fields values
        objRequest.objRecord =  (UAC_referralRelatedRecord__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);            
        String strOutsideSpaceMulti = String.valueOf(objRequest.objRecord.UAC_typeOfMedicalConcern__c);
        if(!String.isBlank(strOutsideSpaceMulti)){
            strOutsideSpaceMulti = strOutsideSpaceMulti.replace('[', '');
            strOutsideSpaceMulti = strOutsideSpaceMulti.replace(']', '');  
            objRequest.objRecord.UAC_typeOfMedicalConcern__c = strOutsideSpaceMulti;          
        }

        // Perform update DML
        List<String> lstErrorMessage = new List<String>();
        List<UAC_referralRelatedRecord__c> lstAssessmentUpdate = new List<UAC_referralRelatedRecord__c>();
        lstAssessmentUpdate.add(objRequest.objRecord);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, lstAssessmentUpdate, false);
        UAC_referralRelatedRecord__c assessmentQueried;
        Set<String> removedFields;
        if(securityDecision.getRemovedFields().containsKey('UAC_referralRelatedRecord__c')){
            removedFields = securityDecision.getRemovedFields().get('UAC_referralRelatedRecord__c');
        }
        System.debug('removedFields:'+removedFields);
        if(removedFields != null) {
            Id idAssessment = objRequest.objRecord.Id;
            String queryBase = 'SELECT Id,';
            String queryMiddle = String.join(new List<String>(removedFields),',');
            String queryEnd = ' FROM UAC_referralRelatedRecord__c WHERE Id = :idAssessment';
            assessmentQueried = Database.query(queryBase + queryMiddle + queryEnd);
            Map<String, Schema.sObjectField> assessmentFieldLabelMap = Schema.SObjectType.UAC_referralRelatedRecord__c.fields.getMap();
            for(String strField : removedFields) {
                if((objRequest.objRecord.get(strField) != '') && String.valueOf(assessmentQueried.get(strField)) != String.valueOf(objRequest.objRecord.get(strField))){
                    lstErrorMessage.add('You cannot edit the field: ' + assessmentFieldLabelMap.get(strField).getDescribe().getLabel());
                }
            }
        }
        System.debug('lstErrorMessage:'+lstErrorMessage);
        if(lstErrorMessage.isEmpty()) {
            try{
                System.debug('securitydecision :' +securityDecision.getRecords());
                if(!securityDecision.getRecords().isEmpty()){
                    update securityDecision.getRecords();
                }
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

    public without sharing class Request{
        @InvocableVariable(required = true) public UAC_referralRelatedRecord__c objRecord;
        @InvocableVariable public String strSectionName;
    }

    public without sharing class Response {
        @InvocableVariable public UAC_referralRelatedRecord__c objRecord;
        @InvocableVariable public String errorMessage;
    }    

}