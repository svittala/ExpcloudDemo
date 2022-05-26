/**
 * @File Name          : UAC_userTrailMixTriggerHelper.cls
 * @Description        : Handles all User TrailMix trigger logic
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver      Date          	Author      		    			Modification
 * 1.0    	2/9/2021   		Nithin Malla (Deloitte)     		Initial Implementation.
 **/
public 
with sharing class UAC_userTrailMixTriggerHelper {
    
    /**
   * @description handling status updates
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param newItems
   * @return void
   **/
    public static void updateCompletedTrailMixToARF(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
        Map<Id, trailheadapp__User_Trailmix__c> mapuserBadgeNewCasted = (Map<Id, trailheadapp__User_Trailmix__c>) newItems;
        Map<Id, trailheadapp__User_Trailmix__c> mapuserBadgeOldCasted = (Map<Id, trailheadapp__User_Trailmix__c>) oldItems;
        Map<Id,Id> trailMixWithUserIDMap = new Map<Id, Id>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> userTrailMixIdSet = new Set<Id>();
      
        // Populate collections
        for (trailheadapp__User_Trailmix__c userTrailMix : mapuserBadgeNewCasted.values()) {
            
            if(userTrailMix.trailheadapp__Status__c==Label.UAC_statusCompleted && 
               userTrailMix.trailheadapp__Status__c!=mapuserBadgeOldCasted.get(userTrailMix.Id).trailheadapp__Status__c){
                   userIdSet.add(userTrailMix.trailheadapp__User__c);
                   userTrailMixIdSet.add(userTrailMix.trailheadapp__Trailmix__c);
                   trailMixWithUserIDMap.put(userTrailMix.trailheadapp__Trailmix__c, userTrailMix.trailheadapp__User__c);
               }          
        }
        
        if(!userIdSet.isEmpty()){
            UAC_asyncUserTrailMix handleStatusUpdates = new UAC_asyncUserTrailMix(userIdSet, userTrailMixIdSet, trailMixWithUserIDMap);
            system.enqueueJob(handleStatusUpdates);
        }
    }
}