/**
*@name          UAC_contentVersion Trigger 
*@author        Piyush(Deloitte)
*@date          07/21/2020
*@description   Single trigger for handling all Content Document transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Piyush(Deloitte)         07/21/2020   Initial Implementation.
James Qian (Deloitte)    11/09/2020   Removing insert/update events to prevent cross reference ID issues
**/
trigger UAC_ContentDocumentTrigger on ContentDocument (before delete,after delete) {
    UAC_TriggerDispatcher.Run(new UAC_contentDocumentTriggerHandler());
}