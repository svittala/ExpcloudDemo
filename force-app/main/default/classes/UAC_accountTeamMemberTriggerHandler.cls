/**
 * @File Name          : UAC_accountTeamMemberTriggerHandler.cls
 * @Description        : Handles all AccountTeamMember trigger traffic
 * @Author             : Chaitanya Nandamuri (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author      		       		Modification
 * 1.0    9/8/2020   	Chaitanya Nandamuri(Deloitte)     	Initial Implementation.
 * 2.0    10/13/2020   	Vaibhav Kudesia (Deloitte)     		Added updatePreMonitoringEmailNotification
 *to after events.
   2.1    11/03/2020     Sudeep Chintala(Deloitte)	 		Adding bypass logic
 **/
public
without sharing class UAC_accountTeamMemberTriggerHandler implements UAC_ITriggerHandler {
      /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
     public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAccountteammemberTrigger__c;
  }
  /**
   * @description Method to handle before insert trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param newItems List of new records
   * @return void
   **/
  public
  void beforeInsert(List<AccountTeamMember> newItems) {
    if (!UAC_accountTeamMemberTriggerHelper.boolIsFirstRun) {
      return;
    }
    UAC_accountTeamMemberTriggerHelper.boolIsFirstRun = false;
    UAC_accountTeamMemberTriggerHelper.addMembersToFamilyGroupTeam(newItems);
    UAC_accountTeamMemberTriggerHelper.assignLTFCPermissionSet(newItems);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
      UAC_accountTeamMemberTriggerHelper.updatePreMonitoringEmailNotification(newItems.values());   
      UAC_accountTeamMemberTriggerHelper.insertAccountSharesForOrg(newItems);   
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      UAC_accountTeamMemberTriggerHelper.updatePreMonitoringEmailNotification(newItems.values());
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UAC_accountTeamMemberTriggerHelper.deleteAccountSharesForOrg(oldItems);
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
      UAC_accountTeamMemberTriggerHelper.updatePreMonitoringEmailNotification(oldItems.values());
      UAC_accountTeamMemberTriggerHelper.deleteSIRShareRecs(oldItems.values());
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Chaitanya Nandamuri (Deloitte) | 9/8/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}