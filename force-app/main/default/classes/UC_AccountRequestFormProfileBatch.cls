/**
 * @File Name          : UC_AccountRequestFormProfileBatch.cls
 * @Description        : Change Profile and Role for the Account Request User when training is completed
 * @Author             : Ankur Aggarwal (Deloitte)
 * @Group              : UC_AccountRequestFormProfileBatch
 */
global without sharing class UC_AccountRequestFormProfileBatch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    // collect the batches of records or objects to be passed to execute
    String query = 'SELECT Id,UAC_Status__c,UC_existingUser__c,User_map__r.Profile.Name,User_map__r.Name,UAC_UACPath_training_Completed__c, User_Profile__c, UC_role__c, User_map__c FROM UAC_AccountRequestForm__c WHERE UAC_Status__c=\'Ready for Profile Update\' AND UC_existingUser__c = true AND UAC_UACPath_training_Completed__c = true  AND User_map__r.Profile.Name = \'MyTrailhead\' AND User_map__c IN (SELECT UserId FROM AccountTeamMember WHERE Account.RecordType.DeveloperName = \'UAC_program\' AND Account.UC_activeInPath__c = true) and User_map__r.isactive = true';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<UAC_AccountRequestForm__c> arfList) {
    Set<String> profileStrSet = new Set<String>();
    Set<String> roleStrSet = new Set<String>();    
    Map<String,Id> profileNameIdMap = new Map<String,Id>();
    Map<String,Id> roleNameIdMap = new Map<String,Id>();
    list<user> userUpdateList = new list<user>();

    // process each batch of records default size is 200
    for(UAC_AccountRequestForm__c objARFCurrent : arfList) {        
      profileStrSet.add(objARFCurrent.User_Profile__c);
      roleStrSet.add(objARFCurrent.UC_role__c);     
    }
    for(Profile prof: [SELECT Id,Name FROM Profile WHERE Name IN: profileStrSet]){
      profileNameIdMap.put(prof.Name,prof.Id);
    }
    for(UserRole roleVar: [SELECT Id,Name FROM UserRole WHERE Name IN: roleStrSet]){
      roleNameIdMap.put(roleVar.Name,roleVar.Id);
    }    
    for(UAC_AccountRequestForm__c objARFCurrent : arfList) {   
      User usr = new User(); 
      usr.id = objARFCurrent.User_map__c;
      boolean userChanged = false;
      if(profileNameIdMap.containsKey(objARFCurrent.User_Profile__c)){        
        usr.ProfileId = profileNameIdMap.get(objARFCurrent.User_Profile__c); 
        userChanged = true;       
      }
      if(roleNameIdMap.containsKey(objARFCurrent.UC_role__c)){
        usr.UserRoleId = roleNameIdMap.get(objARFCurrent.UC_role__c);
        userChanged = true;
      }
      if(userChanged){
        userUpdateList.add(usr);
      }    
    }
    try {
    // Update the User Record
      if(!userUpdateList.isEmpty()){        
        Update userUpdateList;
      }      
    } catch(Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
            'Error updating user profile and role',
            e.getStackTraceString());
    }
  }   
  global void finish(Database.BatchableContext BC) {
  // execute any post-processing operations like sending email
  }
}