/**
 * @File Name          : UAC_userProfileTrailmixAssignmentTest.cls
 * @Description        : Test class for UAC_asyncUserProfileTrailmixAssignment Apex Class
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver    Date           	Author                 			Modification
 * 1.0    2/12/2021   		Nithin Malla (Deloitte)     	Initial Implementation.
 **/
@isTest
public class UAC_userProfileTrailmixAssignmentTest {
    
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
        tempUACARF.User_Profile__c ='Lead Case manager' ;
        tempUACARF.User_Email__c = 'test@tests.com';
        insert tempUACARF;   
        
        trailheadapp__Trailmix__c tempTrailMix = new trailheadapp__Trailmix__c();
        tempTrailMix.trailheadapp__Created_By_Profile__c='/testMix1' ;
        tempTrailMix.trailheadapp__External_Id__c='testMix1';
        tempTrailMix.trailheadapp__Slug__c='testMix1';
        tempTrailMix.trailheadapp__URL__c='testMix1';
        insert tempTrailMix;
        insert new Profile_trailmix_mapping__c(Profiles__c='Lead Case manager',Trailmix__c=tempTrailMix.Id);
    }
    
    /*  @author       Nithin Malla (Deloitte)
        @description  Test method to Assing TrailMix based on User Profile
        @param        N/A
        @return       N/A
    */ 
    @isTest static void userTrailMixProfileAssignment_Success() {
                                                              
        UAC_AccountRequestForm__c tempUACARF = [Select id,User_map__c from UAC_AccountRequestForm__c Limit 1];
        
        Test.startTest();
            UAC_asyncUserProfileTrailmixAssignment handleStatusUpdates = new UAC_asyncUserProfileTrailmixAssignment(new set<id>{tempUACARF.Id});
            system.enqueueJob(handleStatusUpdates);
        Test.stopTest();
        
        trailheadapp__Trailmix_Assignment__c trailMixAss = [Select id,trailheadapp__User__c from trailheadapp__Trailmix_Assignment__c where
                                                           trailheadapp__User__c=:tempUACARF.User_map__c];
        system.assertEquals(tempUACARF.User_map__c, trailMixAss.trailheadapp__User__c);
    }

}