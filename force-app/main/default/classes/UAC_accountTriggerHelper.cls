/**
 * @File Name          : UAC_accountTriggerHelper.cls
 * @Description        : Handles all Account trigger logic
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/2/2020   James Qian (Deloitte)     Initial Implementation.
 * 1.1    8/28/2020  Rahul Roy (Deloitte)      ORRUAC-2060 Task Creation for Subcontractor
 **/
public
without sharing class UAC_accountTriggerHelper {
  public
  static final String strContactRecordTypeNameSubcontractors =
      Label.UAC_contactRecordTypeNameSubcontractors;
  public
  static final String strnotificationRecordtypeTask = Label.UAC_notificationRecordtypeTask;
  public
  static final String strTaskSubjectSubcontractorApproval =
      Label.UAC_taskSubjectSubcontractorApproval;
  public
  static final string strNotStartedSatus = 'Not Started';
  public
  static final string strHighPriority = 'High';
  public
  static final String STRING_ACCEPTABLE = 'UAC_acceptablePlacements__c';
  public
  static final String STRING_ID = 'Id';
  public
  static final String STRING_PROGRAM_RECORD_TYPE = Label.UAC_accountRecordTypeAPINameProgram;
  public
  static final String STRING_FAMILY_GROUP_RECORD_TYPE = Label.UAC_accountRecordTypeFamilyGroup;
  public
  static final Id idFamilyGroupRecordType =
      Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
          .get(STRING_FAMILY_GROUP_RECORD_TYPE)
          .getRecordTypeId();
  public
  static final String STRING_RECORD_TYPE = 'RecordTypeId';
  public
  static final String STRING_TAG_FEMALE = 'Female';
  public
  static final String STRING_TAG_MALE = 'Male';
  public
  static final String STRING_TAG_BEDS = ' Beds Available';
  public
  static final Set<String> SET_FIELD_TAG = new Set<String>{'Type',
      'ShippingState',
      'UAC_acceptablePlacements__c',
      'UAC_bedCountAvailableFemale__c',
      'UAC_bedCountAvailableMale__c'};

  /**
   * @description Filters trigger data for insert logic on search tag
   * @author James Qian (Deloitte) | 6/2/2020
   * @param listAccounts List of Accounts from Trigger New
   * @return void
   **/
  public
  static void handleInsertSearchTag(List<Account> listAccounts) {
    List<Account> listPrograms = new List<Account>();
    Id idProgramRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                 .get(STRING_PROGRAM_RECORD_TYPE)
                                 .getRecordTypeId();
    for (Account accountCurrent : listAccounts) {
      if (accountCurrent.RecordTypeId == idProgramRecordType) {
        listPrograms.add(accountCurrent);
      }
    }
    if (!listPrograms.isEmpty()) {
      handleSearchTagUpdates(listPrograms);
    }
  }

  /**
   * @description Filters trigger data for update logic on search tag
   * @author James Qian (Deloitte) | 6/2/2020
   * @param newItems Map of ID to Account from Trigger context variable
   * @param oldItems Map of ID to Account from Trigger context variable
   * @return void
   **/
  public
  static void handleUpdateSearchTag(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    List<Account> listPrograms = new List<Account>();
    Id idProgramRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                 .get(STRING_PROGRAM_RECORD_TYPE)
                                 .getRecordTypeId();
    for (SObject accountCurrent : newItems.values()) {
      if (accountCurrent.get(STRING_RECORD_TYPE) != idProgramRecordType) {
        continue;
      }
      for (String strField : SET_FIELD_TAG) {
        if (accountCurrent.get(strField)
            != oldItems.get((Id) accountCurrent.get(STRING_ID)).get(strField)) {
          listPrograms.add((Account) accountCurrent);
          break;
        }
      }
    }
    if (!listPrograms.isEmpty()) {
      handleSearchTagUpdates(listPrograms);
    }
  }

  /**
   * @description Adds search tags on each Account passed to this method.
   * @author James Qian (Deloitte) | 6/2/2020
   * @param listAccounts List of Accounts to process
   * @return void
   **/
  public
  static void handleSearchTagUpdates(List<Account> listAccounts) {
    for (Account accountCurrent : listAccounts) {
      List<String> listSearchTags = new List<String>();
      if (String.isNotBlank(accountCurrent.Type)) {
        listSearchTags.add(accountCurrent.Type);
      }
      if (String.isNotBlank(accountCurrent.ShippingState)) {
        listSearchTags.add(accountCurrent.ShippingState);
      }
      if (String.isNotBlank(accountCurrent.UAC_acceptablePlacements__c)) {
        listSearchTags.addAll(accountCurrent.UAC_acceptablePlacements__c.split(';'));
      }
      if (accountCurrent.UAC_bedCountAvailableFemale__c != null
          && accountCurrent.UAC_bedCountAvailableFemale__c > 0) {
        listSearchTags.add(STRING_TAG_FEMALE + STRING_TAG_BEDS);
      }
      if (accountCurrent.UAC_bedCountAvailableMale__c != null
          && accountCurrent.UAC_bedCountAvailableMale__c > 0) {
        listSearchTags.add(STRING_TAG_MALE + STRING_TAG_BEDS);
      }
      if (!listSearchTags.isEmpty()) {
        accountCurrent.UAC_searchTags__c = String.join(listSearchTags, ', ');
      }
    }
  }

  /**
   * @description ORRUAC-1011 - Rename Account with Auto Number
   * @author James Qian (Deloitte) 9/8/2020
   * @param Map<Id, sObject> newItems
   * @return None
   **/
  public
  static void setFamilyGroupName(Map<Id, sObject> newItems) {
    Map<Id, Account> mapNewAccounts = (Map<Id, Account>) newItems;
    List<Account> lstFamilyGroupsToUpdate = new List<Account>();
    // idFamilyGroupRecordType
    for (Account accountCurrent : mapNewAccounts.values()) {
      if (accountCurrent.RecordTypeId == idFamilyGroupRecordType
          && String.isNotBlank(accountCurrent.UAC_familyName__c)) {
        String strNewName = 'RG-' + accountCurrent.UAC_accountAutoNumber__c;
        lstFamilyGroupsToUpdate.add(new Account(Id = accountCurrent.Id, Name = strNewName));
      }
    }
    if (!lstFamilyGroupsToUpdate.isEmpty()) {
      try {
        update lstFamilyGroupsToUpdate;
      } catch (Exception e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Account Trigger', e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Account Update Failed ' + e.getMessage());
      }
    }
  }

  /** @description ORRUAC-2060- Create task for Subcontractor Account Creation
   * @author Rahul Roy (Deloitte) 8/27/2020
   * @param Map of new and old Case record
   * @return None
   **/

  public
  static void subcontractorAccountTaskCreation(
      Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Map<Id, Account> mapNewAccounts = (Map<Id, Account>) newItems;
    Map<Id, Account> mapOldAccounts = (Map<Id, Account>) oldItems;
    Id idSubcontractorRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                    .get(strContactRecordTypeNameSubcontractors)
                                    .getRecordTypeId();
    Id idNotificationType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                .get(strnotificationRecordtypeTask)
                                .getRecordTypeId();
    list<ID> lstId = new list<ID>();
    Map<Id, User> mapUser = New Map<Id, User>();
    for (Account objNewAccount : mapNewAccounts.values()) {
      Account objOldAccount = mapOldAccounts.get(objNewAccount.Id);
      if (objNewAccount.recordtypeid == idSubcontractorRecType
          && objNewAccount.UAC_techSubcontractorApproved__c
              != objOldAccount.UAC_techSubcontractorApproved__c
          && objNewAccount.UAC_techSubcontractorApproved__c == 'Pending') {
        lstId.add(objNewAccount.OwnerId);
      }
    }

    if (!lstId.isEmpty()) {
      mapUser = New Map<Id, User>([SELECT Id, managerId FROM User WHERE Id IN:lstId]);
    }

    list<task> lstTask = new list<task>();
    for (Account objNewAccount : mapNewAccounts.values()) {
      Account objOldAccount = mapOldAccounts.get(objNewAccount.Id);
      if (objNewAccount.recordtypeid == idSubcontractorRecType
          && objNewAccount.UAC_techSubcontractorApproved__c
              != objOldAccount.UAC_techSubcontractorApproved__c
          && objNewAccount.UAC_techSubcontractorApproved__c == 'Pending'
          && mapUser.containskey(objNewAccount.OwnerId)
          && mapUser.get(objNewAccount.OwnerId).managerId != null) {
        Task objTask = new Task();
        objTask.recordtypeid = idNotificationType;
        objTask.Subject = strTaskSubjectSubcontractorApproval;
        objTask.whatid = objNewAccount.id;
        objTask.OwnerId =
            mapUser.get(objNewAccount.OwnerId).managerId;  // Accounts Profile's Manager
        objTask.Status = strNotStartedSatus;
        objTask.Priority = strHighPriority;
        lstTask.add(objTask);
      }
    }

    if (!lstTask.isEmpty()) {
      insert lstTask;
    }
  }
}