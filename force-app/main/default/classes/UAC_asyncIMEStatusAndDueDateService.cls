/**
* @File Name          : UAC_asyncIMEStatusAndDueDateService.cls
* @Description        : This class is used to update IME status and Due date on profile (UC).
* @Author             : Abhisek Pati (Deloitte)
* @Group              : 
* @Test Class         : UAC_healthEvaluationTriggerHelperTest.cls
* @Last Modified By   : Abhisek Pati (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	9/15/2021	   Abhisek Pati (Deloitte)  	Initial version.
**/
public
without sharing class UAC_asyncIMEStatusAndDueDateService {
        
    /**
   * @description handling update IME status and Due date on profile
   * @author Abhisek Pati (Deloitte) | 9/15/2021
   * @param ContactIdSet
   * @return boolean
   **/  
    Public Static boolean updateIMEStatusAndDueDate(Set<Id> setContactIds){ 
        boolean isSuccess = false;
        List<Contact> lstContacttoUpdate = new List<Contact>();
        Map<Id, UAC_HealthEvaluation__c> mapContacttoIME = new Map<Id, UAC_HealthEvaluation__c>();
        
        try{
            for (UAC_HealthEvaluation__c ObjIME : [Select id, UAC_healthEvaluationStatus__c,UAC_dueDate__c,UAC_associatedUAC__c,
                                                   UAC_associatedUAC__r.UAC_IMEStatus__c,UAC_associatedUAC__r.UAC_IMEDueDate__c from UAC_HealthEvaluation__c 
                 								   where UAC_associatedUAC__c in :setContactIds 
                                                   and recordtype.name = :Label.UAC_healthEvaluationRecordTypeIME order by createddate desc]) {
                     if(!mapContacttoIME.containskey(ObjIME.UAC_associatedUAC__c)){
          				mapContacttoIME.put(ObjIME.UAC_associatedUAC__c, ObjIME);
                         if(ObjIME.UAC_associatedUAC__r.UAC_IMEStatus__c != ObjIME.UAC_healthEvaluationStatus__c){
                             Contact tempContact = new contact();
                             tempContact.id = ObjIME.UAC_associatedUAC__c;
                             tempContact.UAC_IMEStatus__c = ObjIME.UAC_healthEvaluationStatus__c;
                             tempContact.UAC_IMEDueDate__c = ObjIME.UAC_dueDate__c;
                             lstContacttoUpdate.add(tempContact);
                         }
                     }
           }     		
            if(!lstContacttoUpdate.isEmpty())
            	update lstContacttoUpdate;
            	isSuccess = true;
            
        } catch (Exception ex) {
            UAC_errorLog.logError(ex.getMessage(),
            null,
            'Updating Contact records',
            lstContacttoUpdate.toString() + ex.getStackTraceString());
      }
        return isSuccess;
    }

}