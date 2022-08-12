//ORRUAC-User Onboarding
trigger UAC_usertrigger on User (after insert) {
if(Trigger.isInsert && Trigger.isAfter)
{
    UAC_UserTriggerHandler.onafterInsertusers(Trigger.new);
}
}