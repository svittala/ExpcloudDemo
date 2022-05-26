/**
* @File Name          : UAC_monitoringApprovalNotification.cls
* @Description        : Test class for validating Approved Notification.
* @Author             : Nithin Malla (Deloitte)
* @Group              : UAC_TestBuilder
* @Last Modified By   : Nithin Malla (Deloitte)
* @Last Modified On   : 10-15-2020
* @Modification Log   :
* Ver  		Date        			Author                                	Modification
* 1.0  		10-15-2020  			Nithin Malla (Deloitte)      			Initial Version
 **/
@isTest(seeAllData = false) public class UAC_monitoringApprovalNotificationTest {
    
    
    private
        static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    
    private
        static Account objProgram;
    
    private
        static UAC_monitoring__c objMonv;
    
    /**
    * @description Method to setup data used in test instance.
    * @author Nithin Malla (Deloitte) | 10/15/2020
    * @return void
    **/
    @TestSetup static void setupData() {
        // Create a Program Account
        objProgram = new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STR_PROGRAM_TYPE)
            .build();
        
        objProgram.UAC_bedCountAvailableMale__c = 5;
        objProgram.UAC_bedCountAvailableFemale__c = 6;
        objProgram.UAC_withinORRNetwork__c = 'Yes';
        
        insert objProgram;
        
        UAC_monitoringSchedule__c objMS = new UAC_monitoringSchedule__c();
        objMS.UAC_fiscalYear__c = '2026';
        insert objMS;
        
        objMonv = new UAC_monitoring__c();
        objMonv.UAC_program__c = objProgram.Id ;
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
        UAC_monitor__c objMon = new UAC_monitor__c();        
        objMon.UAC_uacMonitor__c = u.id;
        objMon.UAC_monitoring__c = objMonv.Id;
        insert objMon;
    }
    }
    /**
   * @descriptionORRUAC-2642: Method to test monitroing approved notification
   * @author Nithin Malla (Deloitte) | 10/15/2020
   * @return void
   **/
    @isTest static void monitoringApprovedNotification() {
        user u =[Select Id,title from User where LastName ='Test Code'];
         System.runAs(u){
        test.startTest();
        objMonv = [Select Id,uac_status__c from UAC_monitoring__c limit 1];
        objMonv.uac_status__c = 'Scheduled (Program Not Notified)';
        update objMonv;
        test.stopTest();
        
        objMonv = [Select Id,uac_status__c from UAC_monitoring__c where id=:objMonv.Id];
        system.assertEquals('Scheduled (Program Not Notified)', objMonv.uac_status__c);
    }
    }
}