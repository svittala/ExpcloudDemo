trigger UAC_apprehendedRelationship on UAC_apprehendedRelationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_apprehendedRelationshipHandler());
}