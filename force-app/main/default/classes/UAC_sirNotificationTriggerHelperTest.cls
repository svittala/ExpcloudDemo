/**
 * @File Name          : UAC_sirNotificationTriggerHelperTest.cls
 * @Description        : Test class for UAC_sirNotificationTriggerHelper Apex Class
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    7/12/2020   Vaibhav Kudesia (Deloitte)    Initial Implementation.
 * 2.0    11/5/2020   Nithin Malla (Deloitte)     	Code Scan fixes.
 **/

@isTest
public class UAC_sirNotificationTriggerHelperTest {
     
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
          
          UAC_appSettingsService.setAppSettings();
      
          Contact tempContact = new contact();
          tempContact.lastName = 'Test Last Name';
          tempContact.FirstName = 'Test First Name';
          tempContact.UAC_program__c = tempUACAccount.Id;
          insert tempContact;

          UAC_Event__c tempEvent = new UAC_Event__c();
          tempEvent.UAC_programID__c = tempUACAccount.id;
          tempEvent.UAC_eventType__c ='UC Level Event';
          tempEvent.UAC_eventStartDateTime__c = system.now();
          tempEvent.UAC_synopsisofEvent__c = 'test';
          tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
          tempEvent.UAC_status__c ='Complete';
          tempEvent.UAC_dateTimeReportedToCareProvider__c =system.now();
          tempEvent.UAC_locationofEvent__c ='Foster Home';
          insert tempEvent;          
          
          Id ID_RECORD_TYPE_StandardSIR = Schema.SObjectType.UAC_sir__c.getRecordTypeInfosByDeveloperName().get('UAC_standardSIR').getRecordTypeId();
      
          UAC_sir__c tempSir = new UAC_sir__c();
          tempSir.UAC_uaclookup__c = tempContact.id;
          tempSir.UAC_eventID__c= tempEvent.id;
          tempSir.UAC_status__c = 'Draft';
          tempSir.UAC_wastheUACorAnyoneElseInjured__c ='No';
          tempSir.UAC_reportedToStateLicensing__c ='No';
          tempSir.UAC_reportedtoLawEnforcement__c ='No';
          tempSir.UAC_iConfirmThatIHaveCompletedAll__c = true;
          tempSir.UAC_abuseorNeglect__c = 'Physical Abuse';
          tempSir.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
          tempSir.UAC_incidentatOtherCareProvFacility__c = 'No';
          tempSIR.UAC_howWasThisUACInvolved__c = 'Victim';
          tempSir.RecordTypeId = ID_RECORD_TYPE_StandardSIR ;
          tempSIR.UAC_AgencyName_StateLicensing__c = 'Test Agency';
          tempSIR.UAC_ContactName_StateLicensing__c = 'Test Contact Name';
          tempSIR.UAC_contactMethod_StateLicensing__c = 'Phone';
          tempSIR.UAC_phone_StateLicensing__c = '1231231231';
            insert tempSir;
    }
    /*  @author      Vaibhav Kudesia (Deloitte)
        @description  Test method to populate email on SIR when new sir notification is created is creaed
        @param        N/A
        @return       N/A
    */ 
    @isTest
    public static void mainTest() {
		
      String orgId = UserInfo.getOrganizationId();
      String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
      Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
      string uniqueName = orgId + dateString + randomInt;
      
      User u = new user();
        u.LastName = 'Test Code';
        u.email = uniqueName + '@test' + orgId + '.org';
        u.Username = uniqueName + '@test' + '.org' + orgId;          
        u.Alias = 'Tcode';        
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = [select id from profile   where name = 'Case Manager'].id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;      
        
       UAC_sir__c tempsir = [select id from UAC_sir__C where UAC_status__c = 'Draft' limit 1];
        
       UAC_sirNotification__c sirNotificationOne = new UAC_sirNotification__c();
       sirNotificationOne.UAC_sir__c = tempsir.id;
       sirNotificationOne.UAC_user__c = u.id;
        
       Test.startTest();
        
       insert sirNotificationOne;
       sirNotificationOne.UAC_type__c = 'External Agency';
       sirNotificationOne.UAC_title__c = 'DOJ/FBI';
       update sirNotificationOne;
       delete sirNotificationOne;
        
       Test.stopTest();

       UAC_sirNotification__c[] sirNotificationList =[Select id from UAC_sirNotification__c where id=:sirNotificationOne.Id];
       system.assert(sirNotificationList.size()==0);
    }
    /*  @author      Vaibhav Kudesia (Deloitte)
        @description  Test method to populate email on SIR when new sir notification is created is creaed
        @param        N/A
        @return       N/A
    */ 
    @isTest
    public static void systemgeneratedSNTest() {
		
      String orgId = UserInfo.getOrganizationId();
      String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
      Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
      string uniqueName = orgId + dateString + randomInt;
      
      User u = new user();
        u.LastName = 'Test Code';
        u.email = uniqueName + '@test' + orgId + '.org';
        u.Username = uniqueName + '@test' + '.org' + orgId;          
        u.Alias = 'Tcode';        
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = [select id from profile   where name = 'Case Manager'].id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u; 
           
       AccountTeamMember tempUACAccountTeam = new AccountTeamMember();
       tempUACAccountTeam.AccountId = [select id from Account where Name ='Test UAC Family Account' limit 1].id ;
       tempUACAccountTeam.TeamMemberRole = 'Project Officer';
       tempUACAccountTeam.UserId = u.id;
       insert tempUACAccountTeam;
       system.debug('##'+ [Select Id,LastName,AccountId,UAC_program__c from Contact ]);         
       Test.startTest();        
       UAC_sir__c tempsircheck = [select id, UAC_notificationEmailSet__c from UAC_sir__C where UAC_status__c = 'Draft' limit 1];        
       update tempsircheck;  
       
       system.assert(true);
       Test.stopTest();
    }
}