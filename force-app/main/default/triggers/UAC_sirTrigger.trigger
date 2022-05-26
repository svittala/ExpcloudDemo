/**
*@name          UAC_sirTrigger
*@author        Sarang Padhye (Deloitte)
*@date          10/29/2020
*@description   Single trigger for handling all SIR transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Sarang Padhye (Deloitte)      10/29/2020   Initial Implementation.
**/
trigger UAC_sirTrigger on UAC_sir__c(before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_sirTriggerHandler());
}