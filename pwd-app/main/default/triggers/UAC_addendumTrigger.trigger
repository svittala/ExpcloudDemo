/**
*@name          UAC_addendumTrigger 
*@author        Priyanka Bolla (Deloitte)
*@date          08/05/2020
*@description   Single trigger for handling all Contact transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Priyanka Bolla(Deloitte)    08/05/2020   Initial Implementation.
**/
trigger UAC_addendumTrigger on UAC_addendum__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_addendumTriggerHandler());
}