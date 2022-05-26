/**
 * @File Name          : UAC_accountTrigger.trigger
 * @Description        : Provides test class coverage for Contact Trigger
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_trigger
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/2/2020   James Qian (Deloitte)     Initial Implementation.
 **/
trigger UAC_accountTrigger on Account(before insert, after insert, before update, after update) {
  UAC_TriggerDispatcher.Run(new UAC_accountTriggerHandler());
}