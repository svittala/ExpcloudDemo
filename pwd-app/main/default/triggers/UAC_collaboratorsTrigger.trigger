/**
*@name          UAC_collaboratorTrigger 
*@author        Priyanka Bolla (Deloitte)
*@date          07/15/2020
*@description   Single trigger for handling all Contact transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Priyanka Bolla(Deloitte)    07/15/2020   Initial Implementation.
**/
trigger UAC_collaboratorsTrigger on UAC_collaborators__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_collaboratorTriggerHandler());
}