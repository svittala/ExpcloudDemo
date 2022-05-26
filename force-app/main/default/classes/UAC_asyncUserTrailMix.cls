/**
* @File Name          : UAC_asyncUserTrailMix.cls
* @Description        : This class is used for Queueable User TrailMix Updates.
* @Author             : Nithin Malla (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Nithin Malla (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	2/9/2021	   Nithin Malla (Deloitte)  	Initial version.
* 2.0    	2/22/2021	   Nithin Malla (Deloitte)  	Added Without Sharing.
**/
public 
without sharing class UAC_asyncUserTrailMix implements Queueable {
    
    Set<Id> trailMixUserIds;
    Set<Id> userTrailMixIdSet;
    Map<Id,Id> trailMixWithUserIDMap;
    
    /**
   * @description handling status updates
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param trailMixCompletedUserIds, userTrailMixSet, trailMixIDWithUserIDMap
   * @return Constructor
   **/
    public UAC_asyncUserTrailMix(Set<Id> trailMixCompletedUserIds, Set<Id> userTrailMixSet, Map<Id,Id> trailMixIDWithUserIDMap){
        this.trailMixUserIds = trailMixCompletedUserIds;
        this.userTrailMixIdSet = userTrailMixSet;
        this.trailMixWithUserIDMap = trailMixIDWithUserIDMap;
    }
    
    /**
   * @description handling TrailMix Updates
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param QueueableContext
   * @return void
   **/    
    public void execute(QueueableContext context) {
        UAC_userTrailMixService.handleStatusUpdateOnTrailMix(trailMixUserIds, userTrailMixIdSet, trailMixWithUserIDMap);
    }    
}