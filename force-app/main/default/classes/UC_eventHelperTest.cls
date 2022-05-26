/**
* @File Name          : UC_eventHelperTest.cls
* @Description        : Test class for UC_eventHandler
* @Author             : Nithin Malla (Deloitte)
* @Group              : UAC_triggerHelper
* @Last Modified By   : Nithin Malla (Deloitte)
* @Last Modified On   : 07/12/2021
* @Modification Log   :
* Ver       Date            Author      		       Modification
* 1.0    07/12/2021   	Nithin Malla (Deloitte)        Initial Version
**/
@isTest(seeAllData = false) public class UC_eventHelperTest {
    
    private
    static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    
    /**
    * @author      Nithin Malla (Deloitte)
    * @description  setup method for the required data
    * @param        N/A
    * @return       N/A
    */  
    @testSetup static void setupMethod() {
        
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
    }
    
    /**
     * @description Method to test create functionalities of UAC_Event__c
     * @author Nithin Malla (Deloitte) | 07/12/2021
     */ 
    @isTest
    public static void testCreateEvent() {
        
        Account tempUACAccount = [Select id from Account where Type=:STR_PROGRAM_TYPE];
        
        UAC_Event__c tempEvent = new UAC_Event__c();
        tempEvent.UAC_programID__c = tempUACAccount.id;
        tempEvent.UAC_eventType__c ='UC Level Event';
        tempEvent.UAC_eventStartDateTime__c = system.now();
        tempEvent.UAC_synopsisofEvent__c = 'test';
        tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
        tempEvent.UAC_status__c ='Complete';
        tempEvent.UAC_dateTimeReportedToCareProvider__c =system.now();
        tempEvent.UAC_locationofEvent__c ='Foster Home';
        
        
        Test.startTest();
        insert tempEvent;
        Test.stopTest();
        
        system.assertEquals('test', tempEvent.UAC_synopsisofEvent__c);
    }
    
    /**
     * @description Method to test update functionalities of UAC_Event__c
     * @author Nithin Malla (Deloitte) | 07/12/2021
     */ 
    @isTest
    public static void testUpdateEvent() {
        
        Account tempUACAccount = [Select id from Account where Type=:STR_PROGRAM_TYPE];
        
        UAC_Event__c tempEvent = new UAC_Event__c();
        tempEvent.UAC_programID__c = tempUACAccount.id;
        tempEvent.UAC_eventType__c ='UC Level Event';
        tempEvent.UAC_eventStartDateTime__c = system.now();
        tempEvent.UAC_synopsisofEvent__c = 'test';
        tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
        tempEvent.UAC_dateTimeReportedToCareProvider__c =system.now();
        tempEvent.UAC_locationofEvent__c ='Foster Home';
        
        insert tempEvent;
        
        Test.startTest();
        tempEvent.UAC_synopsisofEvent__c ='test12324';
        Update tempEvent;
        
        Test.stopTest();
        system.assertEquals('test12324', tempEvent.UAC_synopsisofEvent__c);
    }
    
    /**
     * @description Method to test Delete functionalities of UAC_Event__c
     * @author Nithin Malla (Deloitte) | 07/12/2021
     */
    @isTest static void testDeleteEvent() {
        Account tempUACAccount = [Select id from Account where Type=:STR_PROGRAM_TYPE];
        
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
        
        Test.startTest();
        delete tempEvent;
        Test.stopTest();
        
        List<UAC_Event__c> expEvent = [Select id from UAC_Event__c where id=:tempEvent.Id];
        system.assert(expEvent.size()==0);
      }
    
}