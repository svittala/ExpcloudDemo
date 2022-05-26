/**
* @File Name          : UC_asyncQueueORRAuthUserUpdate.cls
* @Description        : This class is used for Queueable User ORR Auth Flag Update.
* @Author             : Karthi Subramanian (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Karthi Subramanian (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/18/2021	   Karthi Subramanian (Deloitte)  	Initial version.
**/
public 
without sharing class UC_asyncQueueORRAuthUserUpdate implements Queueable {
    
    Set<Id> setUserId;
    
    /**
   * @description handling status updates
   * @author Karthi Subramanian (Deloitte) | 3/18/2021
   * @param setUserId, userTrailMixSet, trailMixIDWithUserIDMap
   * @return Constructor
   **/
    public UC_asyncQueueORRAuthUserUpdate(Set<Id> setUserId){
        this.setUserId = setUserId;
    }
    
    /**
   * @description handling TrailMix Updates
   * @author Karthi Subramanian (Deloitte) | 3/18/2021
   * @param QueueableContext
   * @return void
   **/    
    public void execute(QueueableContext context) {
        UC_userUpdateService.updateUserORRFlag(setUserId);
    }    
}