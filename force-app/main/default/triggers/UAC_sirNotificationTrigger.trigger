/**
*@name          UAC_sirNotificationTrigger
*@author        Vaibhav Kudesia (Deloitte)
*@date          07/31/2020
*@description   Single trigger for handling all SIR Notification transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Vaibhav Kudesia (Deloitte)      07/31/2020   Initial Implementation.
**/
trigger UAC_sirNotificationTrigger on UAC_sirNotification__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_sirNotificationTriggerHandler());
   
}