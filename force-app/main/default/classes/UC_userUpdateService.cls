/**
* @File Name          : UC_userUpdateService.cls
* @Description        : This class is used for updating User record  Services.
* @Author             : Karthi Subramanian (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Karthi Subramanian (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/18/2021	   Karthi Subramanian (Deloitte)  	Initial version.
**/
public
without sharing class UC_userUpdateService {

   /**
   * @description Method to update Users with ORR Auth User Flag once they uploaded forms
   * @author Karthi Subramanian (Deloitte)
   * @param setUserId set of User Ids 
   * @return void
   **/
  public
  static void updateUserORRFlag(set<Id> setUserId) {
   
    Map<Id,User> mapUser = new Map<Id, User>();
    List<User> lstUserToUpd = new List<User>();
    try{
      for (User objUser : [Select Id, UAC_ORRAuthorizedUser__c from User where id IN:setUserId]) {
        mapUser.put(objUser.Id, objUser);
      }
      for (User objUser:mapUser.values()){
        if(!objUser.UAC_ORRAuthorizedUser__c){
          objUser.UAC_ORRAuthorizedUser__c=true;
          lstUserToUpd.add(objUser);
        }  
      }
      if(!lstUserToUpd.isEmpty()){
          update lstUserToUpd;
      }
  	
  	}catch(Exception e) {
     UAC_errorLog.logError(e.getMessage(), '',
     'Update ORR Auth Flag on User Records ',
     setUserId.toString() + e.getStackTraceString()); 
    }   
  }
}