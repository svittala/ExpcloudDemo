/**
*@name          UAC_healthEvaluationTrigger
*@author        Anupreeta Chakraborty (Deloitte)
*@date          07/14/2020
*@description   Single trigger for handling all Health Evaluation transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Anupreeta Chakraborty (Deloitte)    07/14/2020   Initial Implementation.
**/
trigger UAC_healthEvaluationTrigger on UAC_healthEvaluation__c(before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_healthEvaluationTriggerHandler());
}