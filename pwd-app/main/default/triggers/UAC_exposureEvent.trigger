/**
*___________________________________________________
* @Name:    UAC_exposureEvent__c
* @Author:  Satish
* @Created  July 4,2021
* @Used_By: Global
*___________________________________________________
* @Description: Single trigger for handling all UAC_exposureEvent transactions
* All projects should use this trigger. Each project, should have its
* own, separate, section to run project specific logic. 
* @Changes:
* MM-DD-YYY. Explanation of the change.
**/

trigger UAC_exposureEvent on UAC_exposureEvent__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
     UAC_TriggerDispatcher.Run(new UAC_exposureEventTriggerHandler());
}