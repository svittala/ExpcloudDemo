/**
 * @File Name          : UAC_associatedContactTrigger.trigger
 * @Description        : Trigger class of UAC_associatedContact__c Object
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_trigger
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/7/2020   Karthi Subramanian (Deloitte)     Initial Implementation.
 **/
trigger UAC_associatedContactTrigger on UAC_associatedContact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_associatedContactTriggerHandler());
}