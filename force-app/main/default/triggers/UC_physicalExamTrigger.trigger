/**
*@name          UC_physicalExamTrigger
*@author        Abhisek Pati
*@date          07/15/2021
*@description   Single trigger for handling all physical exam transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Abhisek Pati (Deloitte)         07/15/2021      Initial Implementation.
**/
trigger UC_physicalExamTrigger on UAC_physicalExam__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
     UAC_TriggerDispatcher.Run(new UC_physicalExamHandler());
}