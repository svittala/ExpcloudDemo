/**
 * @File Name          : UAC_backGroundChkTrigger.trigger
 * @Description        : Trigger class of UAC_backgroundCheck__c Object
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_trigger
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/7/2020   Karthi Subramanian (Deloitte)     Initial Implementation.
 **/
trigger UAC_backGroundChkTrigger on UAC_backgroundCheck__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_backGroundChkTriggerHandler());
}