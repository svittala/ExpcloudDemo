/**
*@name          UAC_taskTrigger
*@author        Issam Awwad (Deloitte)
*@date          08/05/2020
*@description   Single trigger for handling all Task transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)    08/05/2020   Initial Implementation.
**/
trigger UAC_taskTrigger on Task (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_taskTriggerHandler());
   
}