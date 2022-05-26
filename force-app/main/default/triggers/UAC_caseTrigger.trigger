/**
*@name          UAC_caseTrigger 
*@author        Issam Awwad (Deloitte)
*@date          05/11/2020
*@description   Single trigger for handling all Case transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)    05/11/2020   Initial Implementation.
**/
trigger UAC_caseTrigger on Case (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_caseTriggerHandler());
}