/**
* @File Name          : UAC_asyncUserProfileTrailmixAssignment.cls
* @Description        : This class is used for Queueable User Profile Trailmix Assignment.
* @Author             : Nithin Malla (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Nithin Malla (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/22/2021	   Nithin Malla (Deloitte)  	Initial version.
**/
public 
without sharing class UAC_asyncUserProfileTrailmixAssignment implements Queueable {
    
    Set<Id> accountReqIds;
    
    /**
   * @description Constructor for 
   * @author Nithin Malla (Deloitte) | 3/22/2021
   * @param accountReqFormIds
   * @return Constructor
   **/
    public UAC_asyncUserProfileTrailmixAssignment(Set<Id> accountReqFormIds){
        this.accountReqIds = accountReqFormIds;
    }
    
    /**
   * @description handling TrailMix Updates
   * @author Nithin Malla (Deloitte) | 3/22/2021
   * @param QueueableContext
   * @return void
   **/    
    public void execute(QueueableContext context) {
        try{
            UAC_userProfileTrailMixService.handleProfileTrailMixAssignment(accountReqIds);
        } catch (Exception ex) {
            UAC_errorLog.logError(ex.getMessage(), null, 'User Profile Trailmix Assignment Creation', accountReqIds.toString() +ex.getStackTraceString());
        }
    }    
}