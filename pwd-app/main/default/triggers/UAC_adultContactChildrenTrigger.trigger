/**
*@name          UAC_adultContactChildrenTrigger
*@author        Issam Awwad (Deloitte)
*@date          02/1/2021
*@description   Single trigger for handling all Adult Contact Children transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)    02/1/2021   Initial Implementation.
**/
trigger UAC_adultContactChildrenTrigger on UAC_adultContactsChildren__c(before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_adultContactChildrenTriggerHandler());
}