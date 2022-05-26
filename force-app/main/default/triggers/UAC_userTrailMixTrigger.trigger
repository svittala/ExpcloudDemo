/**
 * @File Name          : UAC_userTrailMixTrigger.trigger
 * @Description        : Trigger class of trailheadapp__User_Trailmix__c Object
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_trigger
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    2/09/2021   Nithin Malla (Deloitte)     Initial Implementation.
 **/
trigger UAC_userTrailMixTrigger on trailheadapp__User_Trailmix__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    UAC_TriggerDispatcher.Run(new UAC_userTrailMixTriggerHandler());
}