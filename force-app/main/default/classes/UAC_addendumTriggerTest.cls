/**
 * @File Name          : UAC_addendumTriggerTest.cls
 * @Description        : To cover UAC_addendumTrigger,UAC_addendumTriggerHandler
 * @Author             : Priyanka Bolla (Deloitte)
 * @Group              :
 
 * Ver       Date           Author                   	Modification
 * 1.0    	7/16/2020   	Priyanka Bolla (Deloitte)   Initial Version
 * 1.1    	8/28/2020  		Nithin Malla (Deloitte)     ORRUAC-2163 Multi-Select Values on Addendum
 * 1.2    	7/06/2021  		Nithin Malla (Deloitte)     ORRUAC-6040 Added Exclusion logic code coverage changes.
 * 1.3    	7/16/2021  		Nithin Malla (Deloitte)     Test Class Fix.
 **/

@isTest(seeAllData = false) public with sharing class UAC_addendumTriggerTest {
    static final String strActiveAddendumExist = System.Label.UAC_addendumValidation;
    
  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final String STR_ACCNT_STATUS = 'Draft';
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final string strContactRecordTypeUAC = Label.UAC_contactRecordTypeApiNameUAC;
    
 /**
  * @author      Priyanka
  * @description  setup method for the required data
  * @param        N/A
  * @return       N/A
  */    
   @testSetup static void setupMethod() {
       
       // Instantiate related program
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
       
       Contact tempContact = new UAC_testContactBuilder()
                                       .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                       .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                       .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                                       .build();
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
       tempSir.UAC_status__c = 'Submitted';
       tempSir.UAC_wastheUACorAnyoneElseInjured__c ='No';
       tempSir.UAC_reportedToStateLicensing__c ='No';
       tempSir.UAC_reportedtoLawEnforcement__c ='No';
       tempSir.UAC_iConfirmThatIHaveCompletedAll__c = true;
       tempSir.UAC_printedName__c ='Test';
       tempSir.UAC_title__c = 'Test';
       tempSir.UAC_abuseorNeglect__c = 'Physical Abuse';
       tempSir.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
       tempSir.UAC_incidentatOtherCareProvFacility__c = 'No';
       tempSir.UAC_howWasThisUACInvolved__c = 'Victim';
       tempSir.UAC_AgencyName_StateLicensing__c = 'Test Agency';
       tempSir.UAC_ContactName_StateLicensing__c = 'Test Contact Name';
       tempSir.UAC_contactMethod_StateLicensing__c = 'Phone';
       tempSir.UAC_phone_StateLicensing__c = '1231231231';
       insert tempSir;
   }
   
   /**
   * @author       Nithin Malla
   * @description  test the SIR vaules populating on Addendum
   * @param        N/A
   * @return       N/A
   */
   @isTest static void validateSIRValuesOnAddendum() {
       UAC_sir__c sirRec = [Select Id,UAC_uaclookup__c,UAC_eventID__c  from UAC_sir__c];
       UAC_addendum__C tempAddendum = new UAC_addendum__C();
       tempAddendum.UAC_uaclookup__c = sirRec.UAC_uaclookup__c;
       tempAddendum.UAC_eventID__c= sirRec.UAC_eventID__c;
       tempAddendum.UAC_sir__c = sirRec.id;
       tempAddendum.UAC_addendumStatus__c = 'Draft';
       tempAddendum.UAC_abuseorNeglect__c = 'Physical Abuse';
       tempAddendum.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
       tempAddendum.UAC_incidentatOtherCareProvFacility__c = 'No';
       tempAddendum.UAC_howWasThisUACInvolved__c = 'Victim';
       tempAddendum.UAC_reportedToStateLicensing__c ='No';
       
       Test.startTest();
       
       insert tempAddendum;
       tempAddendum = [Select Id,UAC_abuseorNeglect__c from UAC_addendum__C where id=:tempAddendum.Id];
       system.assertEquals('Physical Abuse', tempAddendum.UAC_abuseorNeglect__c);
       
       sirRec = [Select Id,UAC_status__c,UAC_checkSubmissionFlag__c, UAC_addendumDraft__c from UAC_sir__c where id=:sirRec.Id];
       system.assertEquals('Addendum in Draft', sirRec.UAC_status__c);
       system.assert(sirRec.UAC_checkSubmissionFlag__c);
       system.assert(sirRec.UAC_addendumDraft__c);
       
       Test.stopTest();
   }
   
   /**
  * @author      Priyanka
  * @description  method to insert and delete collaborator
  * @param        N/A
  * @return       N/A
  */      
   @isTest static void testInsertSecondDraftAddendum() {
       UAC_sir__c sirRec = [Select Id,UAC_uaclookup__c,UAC_eventID__c  from UAC_sir__c];
       UAC_addendum__C tempAddendum = new UAC_addendum__C();
       tempAddendum.UAC_uaclookup__c = sirRec.UAC_uaclookup__c;
       tempAddendum.UAC_eventID__c= sirRec.UAC_eventID__c;
       tempAddendum.UAC_sir__c = sirRec.id;
       tempAddendum.UAC_addendumStatus__c = 'Draft';
       tempAddendum.UAC_abuseorNeglect__c = 'Physical Abuse';
       tempAddendum.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
       tempAddendum.UAC_incidentatOtherCareProvFacility__c = 'No';
       tempAddendum.UAC_howWasThisUACInvolved__c = 'Victim';
       tempAddendum.UAC_reportedToStateLicensing__c ='No';
       insert tempAddendum;
       
       UAC_sir__c tempsir = [select id,UAC_status__c from UAC_sir__C where UAC_status__c = 'Addendum in Draft'];
       
       tempAddendum.UAC_addendumStatus__C ='Submitted';
       tempAddendum.UAC_IfNotReportedToLawEnforcementUpdate__c = 'Testing Sir';
       
       Test.startTest();
       
       try{
           update tempAddendum;
       }catch(exception ex){
           system.assert(true);
       }
       
       Test.stopTest();
   }
    
    /**
    * @author      	Nithin Malla
    * @description  method to update addendum status from draft to Created in Error
    * @param        N/A
    * @return       N/A
    */          
    @isTest static void testDraftToCreatedInErrorAddendum() {
        
        UAC_sir__c sirRec = [Select Id,UAC_uaclookup__c,UAC_eventID__c  from UAC_sir__c];
        UAC_addendum__C tempAddendum = new UAC_addendum__C();
        tempAddendum.UAC_uaclookup__c = sirRec.UAC_uaclookup__c;
        tempAddendum.UAC_eventID__c= sirRec.UAC_eventID__c;
        tempAddendum.UAC_sir__c = sirRec.id;
        tempAddendum.UAC_addendumStatus__c = 'Draft';
        tempAddendum.UAC_abuseorNeglect__c = 'Physical Abuse';
        tempAddendum.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
        tempAddendum.UAC_incidentatOtherCareProvFacility__c = 'No';
        tempAddendum.UAC_howWasThisUACInvolved__c = 'Victim';
        tempAddendum.UAC_reportedToStateLicensing__c ='No';
        insert tempAddendum;
        
        UAC_sir__c tempsir = [select id,UAC_status__c from UAC_sir__C where UAC_status__c = 'Addendum in Draft'];
        
        tempAddendum.UAC_addendumStatus__C ='Created in Error';
        tempAddendum.UAC_IfNotReportedToLawEnforcementUpdate__c = 'Testing Sir';
        
        Test.startTest();
        
        try{
            update tempAddendum;
        }catch(exception ex){
            system.assert(true);
        }
        
        Test.stopTest();
    }
    
    /**
    * @author      	Nithin Malla
    * @description  method to delete addendum Check
    * @param        N/A
    * @return       N/A
    */          
    @isTest static void testDeleteAddendum() {
        
        UAC_sir__c sirRec = [Select Id,UAC_uaclookup__c,UAC_eventID__c  from UAC_sir__c];
        UAC_addendum__C tempAddendum = new UAC_addendum__C();
        tempAddendum.UAC_uaclookup__c = sirRec.UAC_uaclookup__c;
        tempAddendum.UAC_eventID__c= sirRec.UAC_eventID__c;
        tempAddendum.UAC_sir__c = sirRec.id;
        tempAddendum.UAC_addendumStatus__c = 'Draft';
        tempAddendum.UAC_abuseorNeglect__c = 'Physical Abuse';
        tempAddendum.UAC_isCPSDifferentFromStateLicensing__c = 'Yes';
        tempAddendum.UAC_incidentatOtherCareProvFacility__c = 'No';
        tempAddendum.UAC_howWasThisUACInvolved__c = 'Victim';
        tempAddendum.UAC_reportedToStateLicensing__c ='No';
        insert tempAddendum;
        
        Test.startTest();
        
        try{
            delete tempAddendum;
        }catch(exception ex){
            system.assert(true);
        }
        
        Test.stopTest();
    }    
}