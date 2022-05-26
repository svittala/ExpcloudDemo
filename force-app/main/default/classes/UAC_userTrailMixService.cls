/**
* @File Name          : UAC_userTrailMixService.cls
* @Description        : This class is used for User TrailMix Services.
* @Author             : Nithin Malla (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Nithin Malla (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	2/9/2021	   Nithin Malla (Deloitte)  	Initial version.
* 2.0    	2/16/2021	   Nithin Malla (Deloitte)  	Added Error Log with Id's Set on failures.
* 3.0    	2/22/2021	   Nithin Malla (Deloitte)  	Added Without Sharing.
**/
public
without sharing class UAC_userTrailMixService {
    
    /**
   * @description handling TrailMix Status Updates
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param userTrailMixIdSet, userTrailIdSet, trailMixWithUserIDMap
   * @return void
   **/   
    Public static void handleStatusUpdateOnTrailMix(Set<Id> userTrailMixIdSet, Set<Id> userTrailIdSet, Map<Id,Id> trailMixWithUserIDMap){
        
        Map<Id,List<trailheadapp__User_Trailmix__c>> userWithUserBadgeMap = new Map<Id,List<trailheadapp__User_Trailmix__c>>();
        Set<Id> trailMixID = new Set<Id>();
        List<trailheadapp__User_Trailmix__c> userTrailMixList = [SELECT Id,trailheadapp__Status__c, trailheadapp__User__c,
                                                                 trailheadapp__Trailmix__C
                                                                 FROM trailheadapp__User_Trailmix__c 
                                                                 Where trailheadapp__User__c In: userTrailMixIdSet
                                                                 And trailheadapp__Status__c != : Label.UAC_statusCompleted
                                                                 order by trailheadapp__User__c];
        
        if(!userTrailMixList.isEmpty()){
            for(trailheadapp__User_Trailmix__c userBadge: userTrailMixList){
                if(userTrailMixIdSet.contains(userBadge.trailheadapp__User__c)){
                    userTrailMixIdSet.remove(userBadge.trailheadapp__User__c);
                } else{
                    trailMixID.add(userBadge.trailheadapp__Trailmix__c);
                }           
            }
        } else {
            trailMixID.addAll(userTrailIdSet);
        }
        
        if(!trailMixID.isEmpty()){
            handleTrailMixProfile(trailMixID, userTrailMixIdSet, trailMixWithUserIDMap);            
        }
    }
    
    /**
   * @description handling TrailMix with Profile Trail Mapping
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param trailMixID, userTrailMixIdSet,  trailMixWithUserIDMap
   * @return void
   **/   
    Private Static Void handleTrailMixProfile(Set<Id> trailMixID, Set<Id> userTrailMixIdSet,  Map<Id,Id> trailMixWithUserIDMap){
        
        Map<Id,String> trailMixWithProfileMap = new Map<Id, String>();
        Map<Id,String> userWithProfileMap = new Map<Id, String>();
        
        List<Profile_trailmix_mapping__c> profileTrailMixList = [SELECT Id, Profiles__c, Trailmix__c
                                                                 FROM Profile_trailmix_mapping__c
                                                                 WHERE Trailmix__c In :trailMixID];

        for(Profile_trailmix_mapping__c profileTrailRec: profileTrailMixList){
            trailMixWithProfileMap.put(profileTrailRec.Trailmix__c, profileTrailRec.Profiles__c);
        }
        
        for(ID trailMixRecId: trailMixWithProfileMap.keySet()){
            userWithProfileMap.put(trailMixWithUserIDMap.get(trailMixRecId),trailMixWithProfileMap.get(trailMixRecId));
        }
        
        if(!userTrailMixIdSet.isEmpty()){
            updateARFRecords(userTrailMixIdSet, userWithProfileMap);                
        }
    }
    
    /**
   * @description handling Account Request Form Updates
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param userTrailMixIdSet, userWithProfileMap
   * @return void
   **/   
    Private Static Void updateARFRecords(Set<Id> userTrailMixIdSet, Map<Id,String> userWithProfileMap){
        Map<Id,UAC_AccountRequestForm__c> accReqFormList  = new Map<Id,UAC_AccountRequestForm__c>([SELECT Id,UAC_UACPath_training_Completed__c,
                                                                                                     User_map__c,User_Profile__c
                                                                                                     FROM UAC_AccountRequestForm__c 
                                                                                                     Where User_map__c In:userTrailMixIdSet]);
        if(!accReqFormList.isEmpty()){
            List<UAC_AccountRequestForm__c> accReqFormToUpdate = new List<UAC_AccountRequestForm__c>();
            
            for(UAC_AccountRequestForm__c accReqForm: accReqFormList.values()){
                UAC_AccountRequestForm__c accRec = new UAC_AccountRequestForm__c();
                accRec.Id = accReqForm.Id;
                accRec.UAC_UACPath_training_Completed__c = true;
                accRec.UAC_Status__c = Label.UAC_readyForProfileUpdate;
                accRec.UAC_profileMismatch__c = accReqForm.User_Profile__c!=userWithProfileMap.get(accReqForm.User_map__c);
                accReqFormToUpdate.add(accRec);
            }
            
            try {
                if(!accReqFormToUpdate.isEmpty()) update accReqFormToUpdate;
            } catch (Exception e) {
                UAC_errorLog.logError(e.getMessage(), '','Account Request Form Update',
                                      accReqFormList.keySet().toString() + e.getStackTraceString());  
            }
        }
    }
}