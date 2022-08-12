/**
*@name          UAC_referralAssessmentTrigger 
*@author        Rahul Roy (Deloitte)
*@date          08/04/2020
*@description   Single trigger for handling all Referral Assessment transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Rahul Roy (Deloitte)    08/04/2020   Initial Implementation.
**/
trigger UAC_referralAssessmentTrigger on UAC_referralAssessment__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_referralAssessmentTriggerHandler());
   
}