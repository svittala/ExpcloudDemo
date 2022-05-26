/**
 * @File Name          : UAC_taskTriggerHelper.cls
 * @Description        : Helper method for UAC_taskTriggerHandler
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_taskTriggerHelperTest
 * @Last Modified By   : Rahul Roy(Deloitte)
 * @Last Modified On   : 8/6/2020, 05:51:54 PM
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    8/5/2020   Issam Awwad (Deloitte)        Initial Implementation.
 * 2.0    8/5/2020   Issam Awwad (Deloitte)        ORRUAC-1548 updates.
 **/
public
without sharing class UAC_taskTriggerHelper {

  private
  static final String strCaseStatusHSCompletedCMReview = Label.UAC_caseStatusHSCompletedCMReview;
  private
  static final String strTaskRecordTypeHSAddendum = Label.UAC_taskRecordTypeHSAddendum;
  private
  static final String strDesignatedStatus = Label.UAC_taskTransferDesignatedStatus;
  private
  static final String strTransferWtihdrawnStatus = Label.UAC_taskTransferWtihdrawnStatus;
  private
  static final String strTransferWtihdrawnAlertMsg = Label.UAC_withdrawnTaskAlertMessage;
  private
  static final String strTransferReviewPendingStatus = Label.UAC_transferReviewPendingTaskStatus;
  private
  static final String strFFSReviewStatus = Label.UAC_ReleaseRequestStatusFFSReview;
  private
  static final String strTransferAcceptedStatus = Label.UAC_taskTransferAcceptedStatus;
  public
  static final string strVolagQueueName = Label.UAC_volagQueueName;

  /* @description - Method to process Transfer Task Records
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param map of new and old case record
   * @return void
   **/
  public
  static void processTransferTask(Map<Id, Task> mapTaskTransfer, Map<Id, Task> mapOldTasks) {
    Set<Id> setEntityIds = new Set<Id>();
    Set<Id> setTaskIdsToExclude = new Set<Id>();
    Map<String, Task> mapCaseToTask = new Map<String, Task>();
    Map<String, Task> mapCaseToAcceptedTask = new Map<String, Task>();

    for (Task objTask : mapTaskTransfer.values()) {
      if (objTask.Status != mapOldTasks.get(objTask.Id).Status
          && objTask.Status == strDesignatedStatus) {
        setTaskIdsToExclude.add(objTask.Id);
        mapCaseToTask.put(objTask.whatId, objTask);
        setEntityIds.add(objTask.UAC_program__c);
      } else if (objTask.Status != mapOldTasks.get(objTask.Id).Status
          && objTask.Status == strTransferAcceptedStatus) {
        mapCaseToAcceptedTask.put(objTask.whatId, objTask);
      }
    }
    if (!setTaskIdsToExclude.isEmpty()) {
      withdrawTransferReferrals(setEntityIds, setTaskIdsToExclude, mapCaseToTask);
    }
    if (!mapCaseToAcceptedTask.isEmpty()) {
      updateBedsForAcceptedTransfers(mapCaseToAcceptedTask);
    }
  }
  /* @description - Method to update task owners based on statuses
   * @author Sarang Padhye (Deloitte) | 9/21/2020
   * @param map of new and old case record
   * @return void
   **/
  public
  static void updateTaskOwner(Map<Id, Task> mapTaskTransfer, Map<Id, Task> mapOldTasks) {
    String strQueueid = getVolagQueueId();
    set<id> setProgramsOnTasks = new set<id>();
    set<id> setCasesOnTasks = new set<id>();

    for (Task objTask : mapTaskTransfer.values()) {
      setProgramsOnTasks.add(objTask.UAC_program__c);
      setCasesOnTasks.add(objTask.whatId);
    }

    Map<id, Case> mapCaseToAssignedCC = new Map<id, Case>(
        [select id, UAC_caseCoordinator__c from case where id in:setCasesOnTasks]);
    Map<id, Account> mapAccounts = new Map<id, Account>(
        [select id, UAC_volagGrantee__c from Account where id in:setProgramsOnTasks]);

    for (Task objTask : mapTaskTransfer.values()) {
      if (objTask.UAC_subStatus__c != mapOldTasks.get(objTask.Id).UAC_subStatus__c
          && (objTask.UAC_subStatus__c != null || objTask.UAC_subStatus__c != 'Not Applicable')
          && mapAccounts.get(objTask.UAC_program__c) != null) {

        String strCurrVolagValue = mapAccounts.get(objTask.UAC_program__c).UAC_volagGrantee__c;
        if (strCurrVolagValue != null && strCurrVolagValue.equals('Yes') && strQueueid != null) {

          objTask.OwnerId = strQueueid;
        }

      } else if (objTask.status != mapOldTasks.get(objTask.Id).status
          && (objTask.status != null || objTask.status != strTransferReviewPendingStatus
              || objTask.status != strDesignatedStatus)) {
        if (mapCaseToAssignedCC.get(objTask.whatid) != null) {
          String assignedCCOwner = mapCaseToAssignedCC.get(objTask.whatid).UAC_caseCoordinator__c;
          if (assignedCCOwner != null)
            objTask.OwnerId = mapCaseToAssignedCC.get(objTask.whatid).UAC_caseCoordinator__c;
        }
      }
    }
  }
  /* @description - Method to withdraw Transfer Task Records
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param Set<Id> setCaseIds containing list of cases to pull task records
   * @param Set<Id> setTaskIdsToExclude ids of task records to exclude
   * @return void
   **/
  public
  static void withdrawTransferReferrals(
      Set<Id> setEntityIds, Set<Id> setTaskIdsToExclude, Map<String, Task> mapCaseToTask) {
    List<Task> lstOfTasksToWithdraw = new List<Task>();
    List<Task> lstOfTasksToUpdate = new List<Task>();
    List<Case> lstOfEntriesToUpdate = new List<Case>();
    List<AccountTeamMember> lstOfATMsToDelete = new List<AccountTeamMember>();
    Set<Id> setOfUACs = new Set<Id>();
    Set<Id> setOfFamilyGroups = new Set<Id>();
    Set<Id> setOfLCMs = new Set<Id>();

    List<Case> lstOfUACSFromCase = [SELECT ContactId FROM Case WHERE Id =:mapCaseToTask.keySet()];
    for (Case objCase : lstOfUACSFromCase) {
      setOfUACs.add(objCase.ContactId);
    }
    List<Contact> lstOfFamilyGroups = [SELECT AccountId FROM Contact WHERE Id =:setOfUACs];
    for (Contact objProfile : lstOfFamilyGroups) {
      setOfFamilyGroups.add(objProfile.AccountId);
    }

    lstOfTasksToWithdraw = [
      select id,
      status,
      OwnerId from task where whatId in:mapCaseToTask.keySet() and id not
                                     in:setTaskIdsToExclude
    ];
    lstOfEntriesToUpdate = [select id,
      status,
      UAC_programFacility__c,
      UAC_programType__c,
      UAC_transferDesignationDate__c from Case where id in:mapCaseToTask.keySet()];
    Map<Id, Account> mapOfEntities =
        new Map<Id, Account>([select id, type from Account where id in:setEntityIds]);
    for (Task objTask : lstOfTasksToWithdraw) {
      setOfLCMs.add(objTask.OwnerId);
      if (objTask.Status == strTransferReviewPendingStatus) {
        objTask.Status = strTransferWtihdrawnStatus;
        lstOfTasksToUpdate.add(objTask);
      }
    }
    lstOfATMsToDelete = [SELECT Id from AccountTeamMember WHERE UserId
        IN:setOfLCMs AND AccountId
        IN:setOfFamilyGroups AND TeamMemberRole = 'Temporary'];
    if (!lstOfATMsToDelete.isEmpty()) {
      try {
        delete lstOfATMsToDelete;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '', 'Deleting ATMs', e.getStackTraceString());
      }
    }
    if (!lstOfTasksToUpdate.isEmpty()) {
      try {
        update lstOfTasksToUpdate;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '', 'Updating Tasks', e.getStackTraceString());
      }
    }
    if (!lstOfEntriesToUpdate.isEmpty()) {
      updateEntries(mapOfEntities, lstOfEntriesToUpdate, mapCaseToTask);
    }
  }

  /* @description - Method to update entries
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param Map<Id, Account> mapOfEntities
   * @param List<Case> lstOfEntriesToUpdate
   * @param Map<String, Task> mapCaseToTask map of cases to be updated to the tranfer designated
   *task
   * @return void
   **/
  public
  static void updateEntries(Map<Id, Account> mapOfEntities,
      List<Case> lstOfEntriesToUpdate,
      Map<String, Task> mapCaseToTask) {

    for (Case objEntry : lstOfEntriesToUpdate) {
      objEntry.Status = strFFSReviewStatus;
      objEntry.UAC_programFacility__c = mapCaseToTask.get(objEntry.id).UAC_program__c;
      objEntry.UAC_programType__c =
          mapOfEntities.get(mapCaseToTask.get(objEntry.id).UAC_program__c).type;
      objEntry.UAC_transferDesignationDate__c = System.now();
    }
    try {
      if (lstOfEntriesToUpdate != null && !lstOfEntriesToUpdate.isEmpty()) {
        update lstOfEntriesToUpdate;
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '', 'Updating Entries', e.getStackTraceString());
    }
  }

  /* @description - ORRUAC-1548 11.1 Method to process HS Addendum Task Records
   * @author Rahul Roy (Deloitte) | 8/5/2020
   * @param map of new and old task record
   * @return void
   **/

  public
  static void processHSAddendumTask(Map<Id, Task> mapNewTasks, Map<Id, Task> mapOldTasks) {
    list<String> lstReferralAssessment = new list<String>();
    list<Case> lstReferralCaseUpdate = new list<Case>();

    for (Task objTask : mapNewTasks.values()) {
      if (objTask.UAC_verifyAndSubmit__c == true
          && (mapOldTasks == null
              || (mapOldTasks != null
                  && objTask.UAC_verifyAndSubmit__c
                      != mapOldTasks.get(objTask.Id).UAC_verifyAndSubmit__c))) {
        objTask.UAC_dateAddendumCompleted__c = System.now();
        lstReferralAssessment.add(objTask.WhatId);
      }
    }
    if (!lstReferralAssessment.isEmpty()) {
      for (Case referralCase : [SELECT Id,
             ParentId,
             UAC_homeStudyAddendum__c,
             Status FROM Case WHERE RecordType.DeveloperName
             =:Label.UAC_caseRecordTypeHSPRSReferral AND Id IN(
                   SELECT UAC_entry__c FROM UAC_referralAssessment__c WHERE Id IN
                   : lstReferralAssessment)]) {
        Case referralCaseUpdate = new Case(Id = referralCase.ParentId);
        referralCaseUpdate.Status = strCaseStatusHSCompletedCMReview;
        referralCaseUpdate.UAC_homeStudyAddendum__c = null;
        lstReferralCaseUpdate.add(referralCaseUpdate);
      }
    }
    if (!lstReferralCaseUpdate.isEmpty()) {
      update lstReferralCaseUpdate;
    }
  }
  /* @description - Method to update beds on receiving program - Refactored for ORRUAC-5432
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param Set<Id> setCaseIds containing list of cases to pull task records
   * @return void
   **/
  public
  static void updateBedsForAcceptedTransfers(Map<String, Task> mapCaseToAcceptedTask) {
    Set<String> setOfSearchKeys = new Set<String>();
    Map<Id, String> mapCaseToSearchKey = new Map<Id, String>();
    Map<String, List<Asset>> mapSearchKeyToAssets = new Map<String, List<Asset>>();
    List<Asset> lstOfBedsToUpdate = new List<Asset>();
    List<Case> lstOfEntries =
        [Select Id, ContactId, UAC_gender__c, UAC_age__c, UC_bedTypeOverride__c from Case where id
          in:mapCaseToAcceptedTask.keySet()];

    for (Case objCase : lstOfEntries) {
      String strGender = String.isBlank(objCase.UC_bedTypeOverride__c)
          ? objCase.UAC_gender__c
          : objCase.UC_bedTypeOverride__c;
      String searchKey = String.valueOf(mapCaseToAcceptedTask.get(objCase.Id).UAC_program__c) + '.'
          + strGender + '.'
          + String.valueOf(Integer.valueOf(objCase.UAC_age__c) <= 12 ? 'Tender Age' : 'Teen') + '.'
          + 'Available';
      mapCaseToSearchKey.put(objCase.Id, searchKey);
      setOfSearchKeys.add(searchKey);
    }
    for (Asset objAsset : [SELECT Id, Status, UAC_searchKey__c from Asset where UAC_searchKey__c
           IN:setOfSearchKeys]) {
      List<Asset> lstOfAssets;
      if (mapSearchKeyToAssets.containsKey(objAsset.UAC_searchKey__c)) {
        lstOfAssets = mapSearchKeyToAssets.get(objAsset.UAC_searchKey__c);
      } else {
        lstOfAssets = new List<Asset>();
      }
      lstOfAssets.add(objAsset);
      mapSearchKeyToAssets.put(objAsset.UAC_searchKey__c, lstOfAssets);
    }
    if (mapSearchKeyToAssets.isEmpty()) {
      return;
    }
    for (Case objCase : lstOfEntries) {
      String strSearchKey = mapCaseToSearchKey.get(objCase.Id);
      List<Asset> listAssets = mapSearchKeyToAssets.get(strSearchKey);
      if (listAssets == null || listAssets.isEmpty()) {
        return;
      }
      Asset objAsset = listAssets.remove(0);
      objAsset.Status = 'On-Hold';
      objAsset.ContactId = objCase.ContactId;
      lstOfBedsToUpdate.add(objAsset);
      mapSearchKeyToAssets.put(strSearchKey, listAssets);
    }
    try {
      if (lstOfBedsToUpdate != null && !lstOfBedsToUpdate.isEmpty()) {
        update lstOfBedsToUpdate;
      }
    } catch (Exception e) {
      UAC_errorLog.logError(
          e.getMessage(), '', 'Updating transfer accepted bed fields', e.getStackTraceString());
    }
  }
  private
  static String getVolagQueueId() {
    return
        [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:strVolagQueueName limit 1].id;
  }
}