/**
*@name          UC_signAndSymptomsTrigger
*@author        Chase Oden (Deloitte)
*@date          07/07/2021
*@description   Single trigger for handling all UC Signs and Symptoms (UAC_signsAndSymptoms__c) transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Chase Oden (Deloitte)      07/07/2021   Initial Implementation.
**/
trigger UC_signsAndSymptomsTrigger on UAC_signsAndSymptoms__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
  UAC_TriggerDispatcher.Run(new UC_signsAndSymptomsTriggerHandler());   
}