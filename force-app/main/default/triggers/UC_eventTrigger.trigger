/**
*@name          UC_eventTrigger
*@author        Nithin Malla
*@date          07/12/2021
*@description   Single trigger for handling all event transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Nithin Malla (Deloitte)    		07/12/2021 		Initial Implementation.
**/
trigger UC_eventTrigger on UAC_Event__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
     UAC_TriggerDispatcher.Run(new UC_eventHandler());
}