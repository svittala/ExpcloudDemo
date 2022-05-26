/**
 * @File Name         : UAC_diagnosisTrigger.trigger
 * @Description       : Single trigger for handling all Diagnosis transactions
 * @Group             : UAC_diagnosisTrigger
 * @Test Class        : UAC_diagnosisTriggerHelper
 * @Author            : Anupreeta Chakraborty (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-07-2020
 * Modifications Log
 * Ver   Date         Author                            Modification
 * 1.0   06-19-2020   Anupreeta Chakraborty (Deloitte)  Initial Version
 * 1.1   09-25-2020   Sachet Khanal (Deloitte)          Adding bypass trigger logic
 **/
trigger UAC_diagnosisTrigger on UAC_diagnosis__c(before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {
  UAC_TriggerDispatcher.Run(new UAC_diagnosisTriggerHandler());
}