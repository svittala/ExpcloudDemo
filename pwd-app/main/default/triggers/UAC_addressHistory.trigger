/**
*___________________________________________________
* @Name:    UAC_addressHistory
* @Author:  Ankur Aggarwal
* @Created  May 6,2020
* @Used_By: Global
*___________________________________________________
* @Description: Single trigger for handling all UAC_addressHistory transactions
* All projects should use this trigger. Each project, should have its
* own, separate, section to run project specific logic. 
* @Changes:
* MM-DD-YYY. Explanation of the change.
**/
trigger UAC_addressHistory on UAC_addressHistory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_addressHistoryHandler());
}