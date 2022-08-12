/**
*@name          UC_monitoringScheduleTrigger
*@author        Chase Oden (Deloitte)
*@date          07/26/2021
*@description   Single trigger for handling all UC Monitoring Schedule transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Chase Oden (Deloitte)      07/26/2021   Initial Implementation.
**/
trigger UC_monitoringScheduleTrigger on UAC_monitoringSchedule__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UC_monitoringScheduleTriggerHandler());   
}