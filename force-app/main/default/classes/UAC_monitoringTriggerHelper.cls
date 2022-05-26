/**
 * @File Name          : UAC_uacMonitorTriggerHandler.cls
 * @Description        : Handles all SIR Notification trigger traffic
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
*  1.0      10/12/2020   Vaibhav Kudesia (Deloitte)    Initial Implementation.
 **/
public without sharing class UAC_monitoringTriggerHelper {
    
      Static set<id> setErroradded = new set<id>();
      Static final String strUACMonitorValidation = System.Label.UAC_statusUpdatesUACMonitorValidation;
   /**
   * @description updates concatenated email field on Monitoring Visit in case of UAC Monitor Insert, Update and Delete.
   * @author Vaibhav Kudesia (Deloitte) | 10/12/2020
   * @param newItems List of UAC Monitor to process
   *        IsDelete check if the Trigger context is Delete
   * @return void
   **/    
public
    static void updatePreMonitoringEmailNotification(List<UAC_monitoring__c> newItems , Boolean IsProgramInitiated,Map<Id, SObject> newItemsmap, Map<Id, SObject> oldItemsmap){
        Map<Id,String> mapProgramEmailSet = new Map<Id,String>();        
        Map<Id,Id> mapMontoringProgram = new Map<Id,Id>();
        List<String> lstPreMonitorTeamRoles = Label.UAC_preMonitoringRoleList.split(';');
        List<UAC_monitoring__c> lstMonitor = new List<UAC_monitoring__c>();
        for(UAC_monitoring__c objMon : (List <UAC_monitoring__c>)newItems){  
            mapMontoringProgram.put(objMon.Id,objMon.UAC_program__c);
        }
        for(AccountTeamMember objATM : [Select id, UserId, User.email,AccountId,TeamMemberRole from AccountTeamMember where AccountId =: mapMontoringProgram.values()]){
            if(lstPreMonitorTeamRoles.contains(objATM.TeamMemberRole)){
            	string tempemail = '';
                if(mapProgramEmailSet.keyset().contains(objATM.AccountId)){
                    tempemail = mapProgramEmailSet.get(objATM.AccountId);
                }
                mapProgramEmailSet.put(objATM.AccountId,objATM.User.email+';'+tempemail); 
            }
        }
        if(mapProgramEmailSet.keyset().size() > 0){
            for(UAC_monitoring__c objMonitor : (List <UAC_monitoring__c>)newItems){             
                if(objMonitor.UAC_program__c != null){
            	objMonitor.UAC_preMonitoringEmailSet__c = mapProgramEmailSet.get(objMonitor.UAC_program__c);
                lstMonitor.add(objMonitor);
       			}                
            }        
        } 
        if(IsProgramInitiated && !lstMonitor.IsEmpty() ){
            List<Database.SaveResult> lstSaveResult = Database.update(lstMonitor,false);
            // Inspect save result 
            for (Database.SaveResult objSaveResult : lstSaveResult) {
                if (!objSaveResult.isSuccess()) {
                    for(Database.Error objError : objSaveResult.getErrors()) { 
                        UAC_errorLog.platformEventErrorLog(objError.getMessage(),'', 'UAC_monitoringTriggerHelper/updatePreMonitoringEmailNotification','');  
                      }
                  }
              }            
        }
        else if(!IsProgramInitiated && newItemsmap != null && oldItemsmap != null){
            uacMonitorValidation(newItemsmap,oldItemsmap);
        }
    }
     /**
   * @description updates concatenated email field on Monitoring Visit in case of UAC Monitor Insert, Update and Delete.
   * @author Priyanka Bolla (Deloitte) | 10/15/2020
   * @param newItems List of UAC Monitoring Records
   * @return void
   **/    
    public
    static void uacMonitorValidation(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
     string username = userInfo.getName();  
        
     string userId =userInfo.getUserId();
      
     User u = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title
                FROM User
                WHERE id = :UserInfo.getUserId()];
    for(UAC_monitoring__c objMon :(List<UAC_monitoring__c>)newItems.values()){  
        if((u.title != null && u.title == Label.UAC_monitorTitle &&((objMon.UAC_monitoringEmailSetForUACMonitorNames__c!=null &&!objMon.UAC_monitoringEmailSetForUACMonitorNames__c.contains(username))|| objMon.UAC_monitoringEmailSetForUACMonitorNames__c == null ) && ((UAC_monitoring__c)newItems.get(ObjMon.Id)).UAC_status__c !=((UAC_monitoring__c)oldItems.get(ObjMon.Id)).UAC_status__c) || !Label.UAC_monitoringSupervisorTitles.contains(u.title)) {
             setErroradded.add(objMon.id);
                objMon.addError(strUACMonitorValidation);
            }
            
        }

    }
}