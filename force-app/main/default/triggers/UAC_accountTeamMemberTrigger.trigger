/**
 * @File Name          : UAC_accountTeamMemberTrigger.trigger
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_trigger
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/8/2020   Chaitanya Nandamuri (Deloitte)     Initial Implementation.
 **/
trigger UAC_accountTeamMemberTrigger on AccountTeamMember(before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete) {
  UAC_TriggerDispatcher.Run(new UAC_accountTeamMemberTriggerHandler());
}