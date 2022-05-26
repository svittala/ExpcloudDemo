/**
*@name          UAC_uacMonitoringTrigger
*@author        Vaibhav Kudesia (Deloitte)
*@date          10/12/2020
*@description   Single trigger for handling all UAC Monitoring transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Vaibhav Kudesia (Deloitte)      10/12/2020   Initial Implementation.
**/
trigger UAC_uacMonitorTrigger on UAC_monitor__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_uacMonitoringTriggerHandler());   
}