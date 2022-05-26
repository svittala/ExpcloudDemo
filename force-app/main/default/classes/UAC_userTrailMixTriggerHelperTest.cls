/**
 * @File Name          : UAC_userTrailMixTriggerHelperTest.cls
 * @Description        : Test class for UAC_userTrailMixTriggerHelper Apex Class
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver    Date           	Author                 			Modification
 * 1.0    2/12/2021   		Nithin Malla (Deloitte)     	Initial Implementation.
 **/
@isTest
public class UAC_userTrailMixTriggerHelperTest {
    
    
  	Private static final String STRING_LCM_TeamRole = 'Lead Case Manager';
    
    /**
   * @author       Nithin Malla (Deloitte)
   * @description  setup method for the required data
   * @param        N/A
   * @return       N/A
   */  
    @testSetup static void setupMethod() {
        
            User userLCM = new user();
            userLCM = UAC_TestUtility.createUser(STRING_LCM_TeamRole);
            UAC_AccountRequestForm__c tempUACARF = new UAC_AccountRequestForm__c();
            
            tempUACARF.First_Name__c = 'testFN';
            tempUACARF.Last_Name__c = 'testLN';
            tempUACARF.UAC_Status__c = 'In Progress';
            tempUACARF.User_map__c = userLCM.Id;
            tempUACARF.User_Profile__c ='Case Coordinator' ;
        	tempUACARF.User_Email__c = 'test@tests.com';
            insert tempUACARF;        
    }
    
    /**
   * @author       Nithin Malla (Deloitte)
   * @description  dataSetup method for the required data
   * @param        N/A
   * @return       N/A
   */
    Private Static void dataSetup(String nameValue, Id userId){
        trailheadapp__Trailmix__c tempTrailMix = new trailheadapp__Trailmix__c();
        tempTrailMix.trailheadapp__Created_By_Profile__c='/'+nameValue ;
        tempTrailMix.trailheadapp__External_Id__c=nameValue;
        tempTrailMix.trailheadapp__Slug__c=nameValue;
        tempTrailMix.trailheadapp__URL__c=nameValue;
        insert tempTrailMix;
        
        trailheadapp__User_Trailmix__c tempUserTrailMix = new trailheadapp__User_Trailmix__c();
        tempUserTrailMix.trailheadapp__Trailmix__c = tempTrailMix.Id;
        tempUserTrailMix.trailheadapp__User__c = userId;
        tempUserTrailMix.trailheadapp__Status__c = 'In Progress';
        insert tempUserTrailMix; 
    }
    
	/*  @author       Nithin Malla (Deloitte)
        @description  Test method to update account request form from TrailMix Completion Profile Match
        @param        N/A
        @return       N/A
    */ 
    @isTest static void userTrailMix_CompletedWithProfileMatch() {
        
        UAC_AccountRequestForm__c tempUACARF = [Select id,User_map__c,UAC_UACPath_training_Completed__c,UAC_profileMismatch__c,UAC_Status__c
                                                from UAC_AccountRequestForm__c Limit 1];
        
        dataSetup('testMix1', tempUACARF.User_map__c);
        
        trailheadapp__User_Trailmix__c tempUserTrailMix = [Select id, trailheadapp__Status__c,trailheadapp__Trailmix__c,trailheadapp__User__c 
                                                           from trailheadapp__User_Trailmix__c];
        
        Profile_trailmix_mapping__c tempProfil = new Profile_trailmix_mapping__c();
        tempProfil.Profiles__c = 'Case Coordinator';
        tempProfil.Trailmix__c = tempUserTrailMix.trailheadapp__Trailmix__c;
        insert tempProfil;
        
        tempUserTrailMix.trailheadapp__Status__c = 'Completed';
        
        Test.startTest();
        	update tempUserTrailMix;
        Test.stopTest();
        
        tempUserTrailMix = [Select id, trailheadapp__Status__c,trailheadapp__User__c from trailheadapp__User_Trailmix__c where id=:tempUserTrailMix.Id];
        system.assertEquals('Completed', tempUserTrailMix.trailheadapp__Status__c);
        
        tempUACARF = [Select id,User_map__c,UAC_UACPath_training_Completed__c,UAC_profileMismatch__c,UAC_Status__c
                      from UAC_AccountRequestForm__c where User_map__c=:tempUserTrailMix.trailheadapp__User__c];
        system.assert(tempUACARF.UAC_UACPath_training_Completed__c);
        system.assert(!tempUACARF.UAC_profileMismatch__c);
        system.assertEquals(Label.UAC_readyForProfileUpdate, tempUACARF.UAC_Status__c);
        
    }
    
    /*  @author       Nithin Malla (Deloitte)
        @description  Test method to update account request form from TrailMix Completion Profile MisMatch
        @param        N/A
        @return       N/A
    */ 
    @isTest static void userTrailMix_CompletedWithProfileMisMatch() {
        UAC_AccountRequestForm__c tempUACARF = [Select id,User_map__c,UAC_UACPath_training_Completed__c,UAC_profileMismatch__c,UAC_Status__c
                                                from UAC_AccountRequestForm__c Limit 1];
        
        dataSetup('testMix1', tempUACARF.User_map__c);
        
        trailheadapp__User_Trailmix__c tempUserTrailMix = [Select id, trailheadapp__Status__c,trailheadapp__Trailmix__c,trailheadapp__User__c 
                                                           from trailheadapp__User_Trailmix__c];
        
        Profile_trailmix_mapping__c tempProfil = new Profile_trailmix_mapping__c();
        tempProfil.Profiles__c = 'FFS';
        tempProfil.Trailmix__c = tempUserTrailMix.trailheadapp__Trailmix__c;
        insert tempProfil;
        
        tempUserTrailMix.trailheadapp__Status__c = 'Completed';
        
        Test.startTest();
        	update tempUserTrailMix;
        Test.stopTest();

        tempUserTrailMix = [Select id, trailheadapp__Status__c,trailheadapp__User__c from trailheadapp__User_Trailmix__c where id=:tempUserTrailMix.Id];
        system.assertEquals('Completed', tempUserTrailMix.trailheadapp__Status__c);
        
        tempUACARF = [Select id,User_map__c,UAC_UACPath_training_Completed__c,UAC_profileMismatch__c,UAC_Status__c
                      from UAC_AccountRequestForm__c where User_map__c=:tempUserTrailMix.trailheadapp__User__c];
        system.assert(tempUACARF.UAC_profileMismatch__c);
        system.assert(tempUACARF.UAC_UACPath_training_Completed__c);
        system.assertEquals(Label.UAC_readyForProfileUpdate, tempUACARF.UAC_Status__c);        
    }
    
    /*  @author       Nithin Malla (Deloitte)
        @description  Test method to TrailMix Completion with another InProgress
        @param        N/A
        @return       N/A
    */
    @isTest static void userTrailMix_NotCompleted() {
        
        UAC_AccountRequestForm__c tempUACARF = [Select id,User_map__c,UAC_UACPath_training_Completed__c,UAC_profileMismatch__c,UAC_Status__c
                                                from UAC_AccountRequestForm__c Limit 1];
        
        dataSetup('testMix1', tempUACARF.User_map__c);
        
        trailheadapp__User_Trailmix__c tempUserTrailMix = [Select id, trailheadapp__Status__c,trailheadapp__Trailmix__c,trailheadapp__User__c 
                                                           from trailheadapp__User_Trailmix__c];        
        
        Profile_trailmix_mapping__c tempProfil = new Profile_trailmix_mapping__c();
        tempProfil.Profiles__c = 'FFS';
        tempProfil.Trailmix__c = tempUserTrailMix.trailheadapp__Trailmix__c;
        insert tempProfil;        
        
        dataSetup('testMix2', tempUACARF.User_map__c);
        tempUserTrailMix.trailheadapp__Status__c = 'Completed';
        
        Test.startTest();
        	update tempUserTrailMix;
        Test.stopTest();

        tempUserTrailMix = [Select id, trailheadapp__Status__c,trailheadapp__User__c from trailheadapp__User_Trailmix__c where id=:tempUserTrailMix.Id];
        system.assertEquals('Completed', tempUserTrailMix.trailheadapp__Status__c);
        
        tempUACARF = [Select id,User_map__c,UAC_UACPath_training_Completed__c,UAC_profileMismatch__c,UAC_Status__c
                      from UAC_AccountRequestForm__c where User_map__c=:tempUserTrailMix.trailheadapp__User__c];
        system.assert(!tempUACARF.UAC_UACPath_training_Completed__c);       
    }
}