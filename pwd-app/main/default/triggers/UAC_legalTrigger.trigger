/**
*@name          UAC_legalTrigger
*@author        Manoj Sharma
*@date          08/24/2020
*@description   Single trigger for handling all Case transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Manoj Sharma (Deloitte)    08/24/2020   Initial Implementation.
**/
trigger UAC_legalTrigger on UAC_legal__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_legalTriggerHandler());
   
}