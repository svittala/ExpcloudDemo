/**
*@name          UAC_TestTrigger
*@author        Ram (Creative Sys)
*@date          11/24/2020
*@description   Single trigger for handling all UAC Medical Test (UAC_Test__c) transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ram Josyer (Creative Sys)      11/24/2020   Initial Implementation.
**/
trigger UAC_TestTrigger on UAC_Test__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_TestTriggerHandler());   
}