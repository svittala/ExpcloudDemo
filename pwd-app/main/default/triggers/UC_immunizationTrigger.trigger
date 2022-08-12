/**
*@name          UC_immunizationTrigger
*@author        Nithin Malla
*@date          07/07/2021
*@description   Single trigger for handling all immunization transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Nithin Malla (Deloitte)    		07/07/2021 		Initial Implementation.
**/
trigger UC_immunizationTrigger on UAC_immunization__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
     UAC_TriggerDispatcher.Run(new UC_immunizationHandler());
}