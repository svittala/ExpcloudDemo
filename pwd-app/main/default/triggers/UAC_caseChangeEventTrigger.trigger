/**
 * @File Name         : UAC_caseChangeEventTrigger.trigger
 * @Description       : Trigger for CaseChangeEvent
 * @Group             : UAC_caseChangeEventTrigger
 * @Test Class        : UAC_caseChangeEventTriggerHelperTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-28-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-28-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
trigger UAC_caseChangeEventTrigger on CaseChangeEvent(after insert) {
  UAC_TriggerDispatcher.Run(new UAC_caseChangeEventTriggerHandler());
}