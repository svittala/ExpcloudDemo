/**
* @File Name          : UAC_sirNotificationTriggerHelper.cls
* @Description        : Helper method for UAC_sirNotificationTriggerHandler
* @Author             : Vaibhav Kudesia (Deloitte)
* @Group              : UAC_triggerHelper
* @Test Class         : UAC_sirNotificationTriggerHelperTest
* @Modification Log   :
*
* Ver       Date            Author                      Modification
* 1.0    7/31/2020    Vaibhav Kudesia (Deloitte)     Initial Implementation.
**/

public
without sharing class UAC_sirNotificationTriggerHelper {

  /**
   * @description updates concatenated email field on SIR in case of SIR Notification Insert, Update and Delete.
   * @author Vaibhav Kudesia (Deloitte) | 7/31/2020
   * @param newItems List of Sir Notification to process
   * 		IsDelete check if the Trigger context is Delete
   * @return void
   **/    
public
    static void updateSIREmailNotification(List<SObject> newItems , Boolean IsDelete){
 		Map<Id,String> mapSIR = new Map<Id,String>();
        List<UAC_sir__c> lstSIR = new List<UAC_sir__c>();
        for(UAC_sirNotification__c objSN : (List <UAC_sirNotification__c>)newItems){  
            if(String.isNotBlank(objSN.UAC_email__c)){
                string tempemail = '';
                if(mapSIR.keyset().contains(objSN.UAC_sir__c)){
                	tempemail = mapSIR.get(objSN.UAC_sir__c);
                }
         		mapSIR.put(objSN.UAC_sir__c,objSN.UAC_email__c+';'+tempemail); 
            }
        }
        if(mapSIR.keyset().size() > 0){
            for(UAC_sir__c objSIR : [Select Id, UAC_notificationEmailSet__c from UAC_sir__c where Id =: mapSIR.keyset()]){
                String strOldEmailSet = objSIR.UAC_notificationEmailSet__c;
                UAC_sir__c objSIRToUpdate = new UAC_sir__c(Id = objSIR.Id);
                for(String strNewEmail : mapSIR.get(objSIR.Id).split(';')){
                    if(!IsDelete){
                        if(objSIR.UAC_notificationEmailSet__c != null && !objSIR.UAC_notificationEmailSet__c.contains(strNewEmail)){
                            objSIR.UAC_notificationEmailSet__c = strNewEmail + ';' + objSIR.UAC_notificationEmailSet__c ;                            
                        }
                        if(objSIR.UAC_notificationEmailSet__c == null){
                            objSIR.UAC_notificationEmailSet__c = strNewEmail + ';';
                        }
                    }
                    else if(objSIR.UAC_notificationEmailSet__c != null && objSIR.UAC_notificationEmailSet__c.contains(strNewEmail) && IsDelete){ 
                        objSIR.UAC_notificationEmailSet__c = objSIR.UAC_notificationEmailSet__c.remove(strNewEmail + ';') ;                        
                    }
                }
                if (strOldEmailSet == objSIR.UAC_notificationEmailSet__c) {
                  continue;
                }
                objSIRToUpdate.UAC_notificationEmailSet__c = objSIR.UAC_notificationEmailSet__c ;
                lstSIR.add(objSIRToUpdate);
            }
        }
        if(!lstSIR.isEmpty()){
            update lstSIR ;
        }
    }
    

  /**
   * @description updates concatenated email field on SIR in case of SIR Notification Insert, Update and Delete.
   * @author Sai Gattoju (Deloitte) | 8/3/2020
   * @param oldRecs List of Sir Notification to process
   * @return void
   **/ 
public 
    static void verifyDeletionofSirNotifications(List<SObject> oldRecs){
       for(UAC_sirNotification__c objSirNo : (List <UAC_sirNotification__c>)oldRecs){  
            if(objSirNo.UAC_autoPopulated__c == true){
         		objSirNo.addError(Label.UAC_deleteNotificationMessages);            
            }
        }
        
    }
}