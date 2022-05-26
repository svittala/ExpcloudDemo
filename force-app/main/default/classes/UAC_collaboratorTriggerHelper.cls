/**
 * @File Name          : UAC_collaborator TriggerHandler.cls
 * @Description        : Handles all Collaborator trigger traffic
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UAC_triggerHandler
 * @date               : 10/08/2020
 * @Test Class         : UAC_collaboratorTriggerTest

* Ver       Date            Author                   		Modification
* 1.0    	10/08/2020   	Vaibhav Kudesia (Deloitte)   	Initial Version
* 2.0    	10/28/2020   	Nithin Malla (Deloitte)   		Adding With Sharing keyword.
* 3.0    	11/05/2020   	Nithin Malla (Deloitte)   		Code Scan fixes.
**/

public with sharing class UAC_collaboratorTriggerHelper {
	
    public static final Id monitoringCollaboratorRecordtypeId =
      Schema.SObjectType.UAC_collaborators__c.getRecordTypeInfosByDeveloperName().get(Label.UAC_monitoringCollaboratorRecordtype).getRecordTypeId();
    
    /*@author       Vaibhav Kudesia (Deloitte)
      @description  check if User is From Program Team
      @param        List<UAC_collaborators__c>
      @return       void
   */
	public static void checkifUserFromProgramTeam(List<UAC_collaborators__c> newItems) {
        list<Id> lstUserID = new list<Id>();
        map<Id,Id> mapMonitoringProgram = new map<Id,Id>();
        map<Id,List<AccountTeamMember>> mapMonitoringProgramTeam = new map<Id,List<AccountTeamMember>>();
        for(UAC_collaborators__c objColl : newItems){            
            if(objColl.recordtypeId == monitoringCollaboratorRecordtypeId){
               lstUserID.add(objColl.UAC_user__c);   
               mapMonitoringProgram.put(objColl.UAC_monitoring__c,null);
            }            
        }
        for(UAC_monitoring__c objMon : [Select Id, UAC_program__c from UAC_monitoring__c where id=: mapMonitoringProgram.keySet()]){
            mapMonitoringProgram.put(objMon.Id, objMon.UAC_program__c);           
        }
        for(Account objAcc : [Select Id, (Select Id, UserId from AccountTeammembers limit 500) from Account where Id =: mapMonitoringProgram.values()]){
            mapMonitoringProgramTeam.put(objAcc.Id, objAcc.AccountTeammembers);
        }
        for(UAC_collaborators__c objColl : newItems){ 
            Boolean boolUserFoundinTeam = false;
            if(!mapMonitoringProgram.keyset().IsEmpty() && objColl.UAC_monitoring__c != null){
                for(AccountTeammember objTeamMember : mapMonitoringProgramTeam.get(mapMonitoringProgram.get(objColl.UAC_monitoring__c))){
                    if(objColl.UAC_user__c ==  objTeamMember.UserId) {
                       boolUserFoundinTeam = true; 
                    }                
                }
                if(!boolUserFoundinTeam){
                    objColl.adderror(label.UAC_errorMessageforMonitorCollaborator);
                }
        	}
        }
    }
}