/**
* @File Name          : UAC_userProfileTrailMixService.cls
* @Description        : This class is used for User Profile TrailMix Services.
* @Author             : Nithin Malla (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Nithin Malla (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/23/2021	   Nithin Malla (Deloitte)  	Initial version.
**/
public
without sharing class UAC_userProfileTrailMixService {
    
     /**
   * @description handling User Profile TrailMix Assignment
   * @author Nithin Malla (Deloitte) | 3/23/2021
   * @param accountReqFormIds
   * @return void
   **/   
    Public static void handleProfileTrailMixAssignment(Set<Id> accountReqFormIds){
        
        Map<Id, String> userWithAcccountReqMap = new Map<Id, String>();
        List<String> profileNameSet = label.UAC_trailMixProfileNames.split(',');
        
        for(UAC_AccountRequestForm__c accReq: [Select Id,UAC_Status__c, User_Profile__c, User_map__c 
                                               FROM UAC_AccountRequestForm__c WHERE Id IN: accountReqFormIds AND User_Profile__c IN :profileNameSet]){
            userWithAcccountReqMap.put(accReq.User_map__c, accReq.User_Profile__c);
        }
        
        if(!userWithAcccountReqMap.isEmpty())
        	handleTrailMixProfileAssignment(userWithAcccountReqMap);
    }
    
    /**
   * @description handling TrailMix with Profile Trail Mapping Assignment
   * @author Nithin Malla (Deloitte) | 3/23/2021
   * @param userWithAcccountReqMap
   * @return void
   **/   
    Private Static Void handleTrailMixProfileAssignment(Map<Id, String> userWithAcccountReqMap){
        
        Map<String, List<Id>> profilesWithTrailMixMap = new Map<String, List<Id>>();
        
        for(Profile_trailmix_mapping__c profileTrailRec: [SELECT Id, Profiles__c, Trailmix__c FROM Profile_trailmix_mapping__c 
                                                          WHERE Profiles__c In :userWithAcccountReqMap.values()]){
            if(profilesWithTrailMixMap.containsKey(profileTrailRec.Profiles__c)){
                profilesWithTrailMixMap.get(profileTrailRec.Profiles__c).add(profileTrailRec.Trailmix__c);
            } else{
                profilesWithTrailMixMap.put(profileTrailRec.Profiles__c, new List<Id>{profileTrailRec.Trailmix__c});
            }                                               
        }
        
        List<trailheadapp__Trailmix_Assignment__c> trailMixAssListToInsert = new List<trailheadapp__Trailmix_Assignment__c>();
        
        for(Id userID: userWithAcccountReqMap.keySet()){
            if(!profilesWithTrailMixMap.isEmpty()){
                for(Id trailMixRecId : profilesWithTrailMixMap.get(userWithAcccountReqMap.get(userID))){
                    trailheadapp__Trailmix_Assignment__c trailMixAss = new trailheadapp__Trailmix_Assignment__c();
                    trailMixAss.trailheadapp__Trailmix__c = trailMixRecId;
                    trailMixAss.trailheadapp__User__c = userID;
                    trailMixAssListToInsert.add(trailMixAss);
                }
            }
        }
        
        if(!trailMixAssListToInsert.isEmpty()){
            insert trailMixAssListToInsert; 
        }
    }
}