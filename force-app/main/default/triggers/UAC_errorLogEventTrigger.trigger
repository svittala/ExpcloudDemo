/**
*@name          UAC_errorLogEventTrigger
*@author        Issam Awwad (Deloitte)
*@date          05/13/2020
*@description   Error Log Platform Event trigger to create an Error log
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)    05/13/2020   Initial Implementation.
**/
trigger UAC_errorLogEventTrigger on UAC_errorLogEvent__e(after insert) {
  Id idInternalRecordType = Schema.SObjectType.UAC_errorLog__c.getRecordTypeInfosByDeveloperName()
                                .get(Label.UAC_errorLogInternalRecordType)
                                .getRecordTypeId();
  List<UAC_errorLog__c> lstErrorLogs = new List<UAC_errorLog__c>();

  for (UAC_errorLogEvent__e objEvent : Trigger.New) {
    UAC_errorLog__c objErrorLog = new UAC_errorLog__c();
    objErrorLog.UAC_errorMessage__c = objEvent.UAC_errorMessage__c;
    objErrorLog.UAC_relatedRecordID__c = objEvent.UAC_relatedRecordID__c;
    objErrorLog.UAC_errorOrigin__c = objEvent.UAC_errorOrigin__c;
    objErrorLog.UAC_stackTrace__c = objEvent.UAC_stackTrace__c;
    objErrorLog.RecordTypeId = idInternalRecordType;
    lstErrorLogs.add(objErrorLog);
  }

  if (!lstErrorLogs.isEmpty()) {
    insert lstErrorLogs;
  }
}