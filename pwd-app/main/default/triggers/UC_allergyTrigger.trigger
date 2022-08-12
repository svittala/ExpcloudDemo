trigger UC_allergyTrigger on UAC_allergy__c (before insert, after insert, before update, after update, before delete, after delete) {
    UAC_TriggerDispatcher.Run(new UC_allergyTriggerHandler());
}