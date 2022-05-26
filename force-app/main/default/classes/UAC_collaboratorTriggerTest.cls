/**
 * @File Name          : UAC_collaboratorTriggerTest.cls
 * @Description        : To cover UAC_collaboratorTrigger,UAC_collaboratorTriggerHandler
 * @Author             : Priyanka Bolla (Deloitte)
 * @Group              :
 
 * Ver       Date            Author                   Modification
 * 1.0    7/16/2020   Priyanka Bolla (Deloitte)       Initial Version
 * 2.0    11/5/2020   Nithin Malla (Deloitte)     	  Code Scan fixes.
 * 3.0    7/16/2021   Nithin Malla (Deloitte)     	  Exclusion Logic updates.
 **/

@isTest(seeAllData = false) public with sharing class UAC_collaboratorTriggerTest {

  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final String STR_ACCNT_STATUS = 'Draft';
    
  /**
   * @author      Priyanka
   * @description  setup method for the required data
   * @param        N/A
   * @return       N/A
   */    
      @testSetup static void setupMethod() {
       
          Account objProgram =
              new UAC_testAccountBuilder()
              // Set record type to Program
              .setRecordTypeDeveloperName(System.Label.UAC_accountRecordTypeAPINameProgram)
              // Set required fields 
              .setStatus(STR_ACCNT_STATUS)
              .setType(STRING_FIELD_TYPE)
              // Build object, but don't insert
              .build();
          objProgram.UC_activeInPath__c = true;
          insert objProgram;
       
            Contact tempContact = new contact();
            tempContact.lastName = 'Test Last Name';
            tempContact.FirstName = 'Test First Name';
            insert tempContact;
          
            UAC_Event__c tempEvent = new UAC_Event__c();
            tempEvent.UAC_programID__c = objProgram.id;
            tempEvent.UAC_eventType__c ='UC Level Event';
            tempEvent.UAC_eventStartDateTime__c = system.now();
            tempEvent.UAC_synopsisofEvent__c = 'test';
            tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
            tempEvent.UAC_status__c ='Complete';
            tempEvent.UAC_dateTimeReportedToCareProvider__c =system.now();
            tempEvent.UAC_locationofEvent__c ='Foster Home';
            insert tempEvent;
          
          
            UAC_sir__c tempSir = new UAC_sir__c();
            tempSir.UAC_uaclookup__c = tempContact.id;
            tempSir.UAC_eventID__c= tempEvent.id;
            tempSir.UAC_status__c = 'Draft';
            tempSir.UAC_staffResponseandIntervention__c = 'testt';
            tempSir.UAC_wastheUACorAnyoneElseInjured__c ='No';
            tempSir.UAC_reportedToStateLicensing__c ='No';
            tempSir.UAC_descriptionOfIncident__c ='At Program';
            tempSir.UAC_reportedtoLawEnforcement__c ='No';
            tempSir.UAC_abuseorNeglect__c = 'Physical Abuse';
            tempSir.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
            tempSir.UAC_incidentatOtherCareProvFacility__c = 'No';
            tempSIR.UAC_howWasThisUACInvolved__c = 'Victim';
            tempSIR.UAC_AgencyName_StateLicensing__c = 'Test Agency';
            tempSIR.UAC_ContactName_StateLicensing__c = 'Test Contact Name';
            tempSIR.UAC_contactMethod_StateLicensing__c = 'Phone';
            tempSIR.UAC_phone_StateLicensing__c = '1231231231';
            insert tempSir;
            
             }
 /**
   * @author      Priyanka
   * @description  method to insert and delete collaborator
   * @param        N/A
   * @return       N/A
   */      
  @isTest static void testInsertCollaborator() {
      
      String orgId = UserInfo.getOrganizationId();
      String dateString = 
      String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
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

    UAC_sir__c tempsir = [select id from UAC_sir__C where UAC_status__c = 'Draft'];
    UAC_collaborators__c tempCollaborator = new UAC_collaborators__c();
    tempCollaborator.UAC_sir__c = tempsir.Id;
    tempCollaborator.UAC_user__C = u.ID;
   
    insert tempCollaborator;
    
     UAC_collaborators__c tempSecondCollaborator = [SELECT Id FROM UAC_collaborators__c WHERE UAC_sir__c =: tempsir.Id ];
     
     delete tempSecondCollaborator;
    
     UAC_collaborators__c[] objCollaborators =[Select id from UAC_collaborators__c where id=:tempSecondCollaborator.Id];
     system.assert(objCollaborators.size()==0);
  }

}