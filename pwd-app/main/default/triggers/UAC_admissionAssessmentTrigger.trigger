trigger UAC_admissionAssessmentTrigger on UAC_admissionAssessment__c (before insert, after insert, before update, after update, before delete, after delete) {
	UAC_TriggerDispatcher.Run(new UAC_admissionAssessmentTriggerHandler());
}