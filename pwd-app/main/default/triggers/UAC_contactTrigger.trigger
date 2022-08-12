/**
*@name          UAC_contactTrigger 
*@author        Chaitanya Nandamuri (Deloitte)
*@date          05/13/2020
*@description   Single trigger for handling all Contact transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Chaitanya nandamuri (Deloitte)    05/13/2020   Initial Implementation.
**/
trigger UAC_contactTrigger on Contact(before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_contactTriggerHandler());
}