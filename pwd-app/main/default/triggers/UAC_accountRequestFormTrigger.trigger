/**
*@name          UAC_accountRequestFormTrigger
*@author        Sudeep Chintala (Deloitte)
*@date          11/19/2020
*@description   Single trigger for handling all account request form transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Sudeep Chintala (Deloitte)      11/19/2020   Initial Implementation.
**/
trigger UAC_accountRequestFormTrigger on UAC_AccountRequestForm__c (before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_AccountRequestFormTriggerHandler());
}