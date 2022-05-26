/**
 * @File Name          : UAC_sirTriggerHelperTest.cls
 * @Description        : Test Method  for UAC_sirTrigger
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_sirTriggerHelperTest
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    10/29/2020    Sarang Padhye(Deloitte)     Initial Implementation.
 * 2.0    07/16/2021    Nithin Malla (Deloitte)     Update Test class to include exclusion logic.
 **/
@isTest(seeAllData = false) public class UAC_sirTriggerHelperTest {
    
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
   * @author       Nithin Malla
   * @description  test the SIR vaules populating on Addendum
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testFieldReset() {
    UAC_sir__c sirRec = [
      Select Id,
      UAC_uaclookup__c,
      UAC_eventID__c,
      UAC_status__c,
      UAC_howWasThisUACInvolved__c,
      UAC_isCPSDifferentFromStateLicensing__c,
      UAC_wastheUACorAnyoneElseInjured__c,
      UAC_iConfirmThatIHaveCompletedAll__c,
      UAC_reportedtoLawEnforcement__c,
      UAC_abuseorNeglect__c,
      UAC_title__c,
      UAC_printedName__c,
      UAC_fFSSIRReportingRequirements__c,
      UAC_fFSReportedTo__c from UAC_sir__c
    ];
    UAC_sir__c clonedSir = sirRec.clone();
    clonedSir.UAC_howWasThisUACInvolved__c = 'Perpetrator';
    test.StartTest();
    insert clonedSir;
    test.stopTest();
    UAC_sir__c sobjTestSir = [
      select UAC_howWasThisUACInvolved__c,
      UAC_title__c,
      UAC_printedName__c,
      UAC_iConfirmThatIHaveCompletedAll__c from UAC_sir__c where UAC_howWasThisUACInvolved__c =
          'Perpetrator' limit 1
    ];
    system.debug(sobjTestSir);
    system.assert(!sobjTestSir.UAC_iConfirmThatIHaveCompletedAll__c);
  }
}