trigger UAC_assetTrigger on Asset(
    before insert, after insert, before update, after update, before delete, after delete) {
  UAC_TriggerDispatcher.Run(new UAC_assetTriggerHandler());
}