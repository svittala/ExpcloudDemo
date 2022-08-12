/**
*@name          UAC_contentVersion Trigger 
*@author        Priyanka Bolla (Deloitte)
*@date          06/23/2020
*@description   Single trigger for handling all Content version transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Priyanka Bolla (Deloitte)    06/23/2020   Initial Implementation.
**/
trigger UAC_contentVersionTrigger on ContentVersion (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
	UAC_TriggerDispatcher.Run(new UAC_contentVersionTriggerHandler());
}