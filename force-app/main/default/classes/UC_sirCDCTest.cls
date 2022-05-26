/**
 * @File Name          : UC_sirCDCTest.cls
 * @Description        : Test Method  for UC_sirCDC
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UC_sirCDCTest
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    08/24/2021    Nithin Malla (Deloitte)      Initial Implementation.
 **/
@isTest(seeAllData = false) public class UC_sirCDCTest {
    
    private
    static final String STRING_FIELD_TYPE = 'Secure';
    private
    static final String STR_ACCNT_STATUS = 'Draft';
  
    
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
        tempEvent.UAC_eventType__c = 'UC Level Event';
        tempEvent.UAC_eventStartDateTime__c = system.now();
        tempEvent.UAC_synopsisofEvent__c = 'test';
        tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
        tempEvent.UAC_status__c = 'Complete';
        tempEvent.UAC_dateTimeReportedToCareProvider__c = system.now();
        tempEvent.UAC_locationofEvent__c = 'Foster Home';
        insert tempEvent;
    }
  
    @isTest
    public static void test_NoOFSIRUpdates() {
        Contact tempContact = [Select id,UC_no_of_SIRs__c from Contact limit 1];
        System.assertEquals(null, tempContact.UC_no_of_SIRs__c, 'Unexpected No. of SIRs found');
        UAC_Event__c tempEvent = [Select id from UAC_Event__c limit 1];
        
        Test.startTest();
        Test.enableChangeDataCapture();
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
        Test.getEventBus().deliver();
        Test.stopTest();
        
        tempContact = [Select id,UC_no_of_SIRs__c from Contact where id=:tempContact.Id];
        System.assertEquals(1, tempContact.UC_no_of_SIRs__c, 'The change event trigger did not update the No. of SIRs found');       
    }
}