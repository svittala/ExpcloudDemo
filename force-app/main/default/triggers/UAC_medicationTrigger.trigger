/**
*@name          UAC_diagnosisTrigger 
*@author        Omer Syed (Mutatio Inc)
*@date          06/20/2020
*@description   Single trigger for handling all Medication transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Omer Syed		(Mutatio Inc)    06/20/2020   Initial Implementation.
**/

trigger UAC_medicationTrigger on UAC_medication__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_medicationTriggerHandler());
}