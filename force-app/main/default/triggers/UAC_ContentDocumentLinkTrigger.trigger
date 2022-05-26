/**
*@name          UAC_ContentDocumentLinkTrigger Trigger 
*@author        Ankur(Deloitte)
*@date          08/23/2020
*@description   Single trigger for handling all Content Document link transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Piyush(Deloitte)    07/21/2020   Initial Implementation.
**/
trigger UAC_ContentDocumentLinkTrigger on ContentDocumentLink (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_contentDocumentLinkTriggerHandler());
}