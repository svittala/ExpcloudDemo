/**
* @File Name          : UAC_uacMonitoringTriggerHelper.cls
* @Description        : Helper method for UAC_uacMonitoringTriggerHandler
* @Author             : Vaibhav Kudesia (Deloitte)
* @Group              : UAC_triggerHelper
* @Modification Log   :
*
* Ver       Date            Author                      Modification
* 1.0    10/14/2020    Vaibhav Kudesia (Deloitte)     Initial Implementation.
**/

public
without sharing class UAC_uacMonitoringTriggerHelper {

  /**
   * @description updates concatenated email field on Monitoring visit in case of  UAC monitor Insert, Update and Delete.
   * @author Vaibhav Kudesia (Deloitte) | 10/14/2020
   * @param newItems List of  UAC monitor to process
   * 		IsDelete check if the Trigger context is Delete
   * @return void
   **/    
public
    static void updateMONEmailNotification(List<SObject> newItems , Boolean IsDelete){
 		Map<Id,Set<String>> mapMonitorV = new Map<Id,Set<String>>();
        List<UAC_monitoring__c> lstMonitoringV = new List<UAC_monitoring__c>();
        for(UAC_monitor__c objMon : (List <UAC_monitor__c>)newItems){  
            if(String.isNotBlank(objMon.UAC_uacMonitorName__c)){
                Set<String> tempemail = new Set<String>();
                if(mapMonitorV.keyset().contains(objMon.UAC_monitoring__c)){
                	tempemail.addall(mapMonitorV.get(objMon.UAC_monitoring__c));
                }
                tempemail.add(objMon.UAC_uacMonitorName__c);
         		mapMonitorV.put(objMon.UAC_monitoring__c,tempemail); 
            }
        }
        if(mapMonitorV.keyset().size() > 0){
            for(UAC_monitoring__c objMON : [Select Id, UAC_monitoringEmailSetForUACMonitorNames__c from UAC_monitoring__c where Id =: mapMonitorV.keyset()]){
                UAC_monitoring__c objMONToUpdate = new UAC_monitoring__c(Id = objMON.Id);
                set<String> tempname = new set<String>();
                if(objMON.UAC_monitoringEmailSetForUACMonitorNames__c!=null){
                	tempname.addall(objMON.UAC_monitoringEmailSetForUACMonitorNames__c.split(','));
                }
                	if(!IsDelete){                        
                       tempname.addall(mapMonitorV.get(objMon.Id));  
                    }
                    else if(IsDelete){   
                       tempname.removeall(mapMonitorV.get(objMon.Id));                        
                    }
                                
                objMONToUpdate.UAC_monitoringEmailSetForUACMonitorNames__c = String.join(new List<String>(tempname),',') ;
                lstMonitoringV.add(objMONToUpdate);
            }        
        }
        if(!lstMonitoringV.isEmpty()){
            update lstMonitoringV ;
        }
    }
}