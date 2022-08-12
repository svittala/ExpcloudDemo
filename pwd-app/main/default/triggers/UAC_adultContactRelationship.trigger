/**
*@name          UAC_adultContactRelationship 
*@author        Priyanka Bolla (Deloitte)
*@date          05/7/2020
*@description   Single trigger for handling all UAC_adultContactRelationship  transactions
*@Class         UAC_Trig
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Priyanka Bolla(Deloitte)    05/7/2020   Initial Implementation.

**/
trigger UAC_adultContactRelationship on UAC_adultContactRelationship__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
UAC_TriggerDispatcher.Run(new UAC_adultContactRelationshipHandler());
}