/**
 * @File Name          : UAC_contactChangeEventTrigger
 * @Description        : Asynchrnous Trigger on Contact Change Event
 *
 * @Author             : Sarang Padhye (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    8/20/2020   Sarang Padhye (Deloitte)     Initial Version- ORRUAC-2020
 **/
trigger UAC_contactChangeEventTrigger on ContactChangeEvent(after insert) {
  List<ContactChangeEvent> changes = Trigger.new;
  List<ContactChangeEvent> lstUpdateEvent = new List<ContactChangeEvent>();

  for (ContactChangeEvent change : changes) {
    EventBus.ChangeEventHeader header = change.ChangeEventHeader;
    system.debug('header ' + header);
    system.debug('change ' + change.UAC_program__c);
    system.debug('change ' + change.AccountId);
    // Check events with update
    if (header.changeType == 'UPDATE') {
      lstUpdateEvent.add(change);
    }
  }

  // Call Helper
  if (!lstUpdateEvent.isEmpty())
    UAC_contactChangeEventHelper.handleUpdateChangeEvent(lstUpdateEvent);
}