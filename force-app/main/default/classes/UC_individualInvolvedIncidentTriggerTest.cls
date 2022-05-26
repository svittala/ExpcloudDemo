/**
 * @File Name          : UC_individualInvolvedIncidentTriggerTest.cls
 * @Description        : Handles all Individuals Involved in Incident trigger traffic
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UC_individualInvolvedIncidentTriggerTest
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/22/2021   Vaibhav Kudesia (Deloitte)    Initial Implementation.
 **/
@isTest(seeAllData = false) public class UC_individualInvolvedIncidentTriggerTest {
    @testSetup static void setupMethod() {
    Account tempAccount = new Account();
    tempAccount.Name = 'Test Account';
    tempAccount.UC_activeInPath__c = True;
    insert tempAccount;
        
	String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    Account tempUACAccount =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STR_PROGRAM_TYPE)
            .build();
    tempUACAccount.UAC_bedCountAvailableMale__c = 5;
    tempUACAccount.UAC_bedCountAvailableFemale__c = 6;
    tempUACAccount.UAC_withinORRNetwork__c = 'Yes';
    tempUACAccount.Name = 'Test UAC Family Account';
    tempUACAccount.UC_activeInPath__c = True;
    insert tempUACAccount;
        
    Contact tempContact = new contact();
    tempContact.lastName = 'Test Last Name';
    tempContact.FirstName = 'Test First Name';
    tempContact.UAC_program__c = tempUACAccount.Id; 
    insert tempContact;
    
    Contact tempAdultContact = new contact();
    tempAdultContact.lastName = 'Test Last Name Adult';
    tempAdultContact.FirstName = 'Test First Name Adult';
    tempAdultContact.UAC_program__c = tempUACAccount.Id;
    insert tempAdultContact;  

    UAC_Event__c tempEvent = new UAC_Event__c();
    tempEvent.UAC_programID__c = tempAccount.id;
    tempEvent.UAC_eventType__c = 'UC Level Event';
    tempEvent.UAC_eventStartDateTime__c = system.now();
    //tempEvent.UAC_synopsisofEvent__c = 'test';
    tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
    tempEvent.UAC_status__c = 'Complete';
    tempEvent.UAC_dateTimeReportedToCareProvider__c = system.now();
    tempEvent.UAC_locationofEvent__c = 'Foster Home';
    insert tempEvent;

    UAC_sir__c tempSir = new UAC_sir__c();
    tempSir.UAC_uaclookup__c = tempContact.id;
    tempSir.UAC_eventID__c = tempEvent.id;
    tempSir.UAC_status__c = 'Draft';
    tempSir.UAC_wastheUACorAnyoneElseInjured__c = 'No';
    tempSir.UAC_reportedtoLawEnforcement__c = 'No';
    tempSIR.UAC_iConfirmThatIHaveCompletedAll__c = true;
    tempSir.UAC_abuseorNeglect__c = 'Physical Abuse';
    tempSir.UAC_title__c = 'test Title';
    tempSir.UAC_printedName__c = 'test Printed Name';
    tempSir.UAC_fFSSIRReportingRequirements__c = true;
    tempSir.UAC_fFSReportedTo__c = 'Consulate';
    tempSir.UAC_fFSReportedSIRDate__c = Date.Today();
    tempSir.UAC_sirSubmisisonDateTime__c = Date.Today();
    tempSir.UAC_isCPSDifferentFromStateLicensing__c = 'No';
    tempSir.UAC_howWasThisUACInvolved__c = 'Victim';
    insert tempSir;
  }
 /**
   * @author       Vaibhav Kudesia
   * @description  test the Incident Involved in Incident creation
   * @param        N/A
   * @return       N/A
   */
    @isTest static void testIndividualsInvolvedinIncident() {
          
        UAC_sir__c sirRec = [Select Id, UAC_uaclookup__c, UAC_eventID__c, UAC_eventID__r.UAC_programID__r.UC_activeInPath__c, UAC_uaclookup__r.UAC_program__c, UAC_eventID__r.UAC_programID__c,UAC_uaclookup__r.UAC_program__r.UC_activeInPath__c from UAC_sir__c];  
        Account ObjProgram = [select id, UC_activeInPath__c, UAC_Closure_Date__c, UAC_Closure_Date_Reason__c from Account where Id =: sirRec.UAC_eventID__r.UAC_programID__c limit 1];
        ObjProgram.UAC_Closure_Date__c = Date.today();
        ObjProgram.UAC_Closure_Date_Reason__c = 'For Testing Reasons';
        ObjProgram.UC_activeInPath__c = True;
        update ObjProgram ;
        UAC_individualsInvolvedinIncident__c objIII = new UAC_individualsInvolvedinIncident__c();
        objIII.UAC_profileName__c = [Select Id from Contact where FirstName = 'Test First Name Adult' limit 1].id;
        objIII.UAC_sir__c = sirRec.Id;        
        objIII.UAC_role__c = 'Witness' ;
        objIII.UAC_type__c = 'Non-Staff Adult';
        test.StartTest();
    	insert objIII;
        objIII.UAC_role__c = 'Reporter';
        update objIII;
        delete objIII;
    	test.stopTest();
    }
}