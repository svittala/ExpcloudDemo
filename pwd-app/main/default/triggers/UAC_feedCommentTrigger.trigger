/**
*@name          UAC_feedItemTrigger
*@author        James Qian (Deloitte)
*@date          09/29/2020
*@description   Single trigger for handling all FeedComment transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
James Qian (Deloitte)            09/29/2020    Initial Implementation.
**/
trigger UAC_feedCommentTrigger on FeedComment(
    before insert, after insert, before update, after update, before delete, after delete) {
  UAC_TriggerDispatcher.Run(new UAC_feedCommentTriggerHandler());
}