/**
 * @File Name          : UAC_testSIRBuilder.cls
 * @Description        : Builder class for creating Test SIR and SIR notification Records for unit test.
 * @Author             : Vaibhav Kudesia
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Vaibhav Kudesia (Deloitte)
 * @Last Modified On   : 08-31-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    8/31/2020     Vaibhav Kudesia (Deloitte)    Initial Version
 * 1.1    7/30/2021     Chase Oden (Deloitte)         Changing UAC_criminalHistory__c default field to "Charges/Convictions"
 **/

@isTest public with sharing class UAC_testSIRBuilder {
	
   private static Id ID_RECORD_TYPE_StandardSIR = Schema.SObjectType.UAC_sir__c.getRecordTypeInfosByDeveloperName().get('UAC_standardSIR').getRecordTypeId();
    
   /**
   * @description Method to build a new Contact object
   * @author Vaibhav Kudesia (Deloitte) | 8/31/2020
   * @return UAC_sir__c
   **/
  public static
  UAC_sir__c buildStandardSIR() {
    UAC_sir__c tempSir = new UAC_sir__c();
            //tempSir.UAC_uaclookup__c = objUACContact.id;
            //tempSir.UAC_eventID__c= tempEvent.id;
            //tempSir.UAC_status__c = 'Submitted';
            tempSir.UAC_category__c = 'Criminal history';
            tempSir.UAC_wastheUACorAnyoneElseInjured__c ='No';
            tempSir.UAC_reportedToStateLicensing__c ='Yes';
            tempSir.UAC_criminalHistory__c ='Charges/Convictions';
            tempSir.UAC_reportedtoLawEnforcement__c ='No';
       		tempSir.UAC_iConfirmThatIHaveCompletedAll__c = true;
        	tempSir.RecordTypeId = ID_RECORD_TYPE_StandardSIR ;
    return tempSir;
  }
   /**
   * @description Method to build a new Contact object
   * @author Vaibhav Kudesia (Deloitte) | 8/31/2020
   * @return UAC_sir__c
   **/
  public static
  UAC_Event__c buildanEvent() {
    UAC_Event__c tempEvent = new UAC_Event__c();
            //tempEvent.UAC_programID__c = tempAccount.id;
            tempEvent.UAC_eventType__c ='UC Level Event';
            tempEvent.UAC_eventStartDateTime__c = system.now();
            tempEvent.UAC_synopsisofEvent__c = 'test';
            tempEvent.UAC_eventOccurredInORRCare__c = 'Yes';
            tempEvent.UAC_status__c ='Complete';
            tempEvent.UAC_dateTimeReportedToCareProvider__c =system.now();
            tempEvent.UAC_locationofEvent__c ='Foster Home';
    return tempEvent;
  }

      
}