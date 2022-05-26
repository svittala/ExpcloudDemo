trigger UC_individualsInvolvedinIncidentTrigger on UAC_individualsInvolvedinIncident__c (before insert, after insert, before update, after update, before delete, after delete) {
  UAC_TriggerDispatcher.Run(new UC_individualsinIncidentTriggerHandler());
}