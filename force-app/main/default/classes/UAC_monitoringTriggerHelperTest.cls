/**
 * @File Name          : UAC_monitoringTriggerHelperTest.cls
 * @Description        : Test class for UAC_monitoringTriggerHelper Apex Class
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver    Date           	Author                 			Modification
 * 1.0    10/12/2020   		Vaibhav Kudesia (Deloitte)     	Initial Implementation.
 * 2.0    11/05/2020   		Nithin Malla (Deloitte)     	Code Review fixes.
 **/

@isTest
public class UAC_monitoringTriggerHelperTest {
    
    /**
   * @author      Vaibhav Kudesia (Deloitte)
   * @description  setup method for the required data
   * @param        N/A
   * @return       N/A
   */  
    @testSetup static void setupMethod() {
       		String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
                   	
        	Account tempUACAccount = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();

            tempUACAccount.UAC_bedCountAvailableMale__c = 5;
            tempUACAccount.UAC_bedCountAvailableFemale__c = 6;
            tempUACAccount.UAC_withinORRNetwork__c = 'Yes';
            tempUACAccount.Name ='Test UAC Family Account' ;
            insert tempUACAccount;
                
            AccountTeamMember ATM = new AccountTeamMember();
    		ATM.AccountId = tempUACAccount.Id;
    		ATM.TeamMemberRole = 'Federal Field Specialist';
    		ATM.UserId = UserInfo.getUserId();
    		insert ATM;               
    }
	/*  @author      Vaibhav Kudesia (Deloitte)
        @description  Test method to populate email on Monitoring visit is created
        @param        N/A
        @return       N/A
    */ 
    @isTest
    public static void mainTest() {
        
        UAC_monitoringSchedule__c objMS = new UAC_monitoringSchedule__c();
        objMS.UAC_fiscalYear__c = '2026';
        insert objMS;
        
        test.startTest();        
        UAC_monitoring__c objMonv = new UAC_monitoring__c();
        objMonv.UAC_program__c = [Select Id from Account where Name = 'Test UAC Family Account' limit 1].Id ;
        objMonv.UAC_monitoringSchedule__c = objMS.Id;
        objMonv.uac_status__c = 'Draft';
        insert objMonv;        
        test.stopTest();
        
        UAC_monitoring__c objMonv1 =[Select id,UAC_status__c from UAC_monitoring__c where id=:objMonv.Id];
        system.assertEquals('Draft', objMonv1.UAC_status__c);
    }
    /*  @author      Vaibhav Kudesia (Deloitte)
        @description  Test method to populate email on Monitoring visit in case of  UAC monitor is created
        @param        N/A
        @return       N/A
    */ 
    @isTest
    public static void UACMonitoringTest() {
        
        UAC_monitoringSchedule__c objMS = new UAC_monitoringSchedule__c();
        objMS.UAC_fiscalYear__c = '2026';
        insert objMS;
        
        UAC_monitoring__c objMonv = new UAC_monitoring__c();
        objMonv.UAC_program__c = [Select Id from Account where Name = 'Test UAC Family Account' limit 1].Id ;
        objMonv.UAC_monitoringSchedule__c = objMS.Id;
        objMonv.uac_status__c = 'Draft';
        insert objMonv; 
        
    String orgId = UserInfo.getOrganizationId();
    String dateString =
    String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    string uniqueName = orgId + dateString + randomInt;
    
    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;

    u.Alias = 'Tcode';
    u.Title ='UC Monitor - Travel POC';
    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;
        System.runAs(u){
        test.startTest();        
        UAC_monitor__c objMon = new UAC_monitor__c();        
        objMon.UAC_uacMonitor__c = u.id;
        objMon.UAC_monitoring__c = objMonv.Id;
        objMon.UAC_type__c = 'Lead UC Monitor';
        insert objMon;
        objMon.UAC_type__c = 'Shadowing UC Monitor';
        update objMon;
        delete objMon;
        test.stopTest();
        
        UAC_monitor__c[] objMonv1 =[Select id from UAC_monitor__c where id=:objMon.Id];
        system.assert(objMonv1.size()==0);
    }
    }
}