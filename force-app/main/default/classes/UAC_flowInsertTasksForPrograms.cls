/**
 * @File Name          : UAC_flowInsertTasksForPrograms.cls
 * @Description        : Main class for transfer program selection
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_case
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0     8/4/2020   James Qian (Deloitte)     Initial Implementation.
 * 2.0     9/10/1010  Sarang Padhye(Deloitte)   ORRUAC - 2328
 **/
public
without sharing class UAC_flowInsertTasksForPrograms {

  public
  static final string strVolagQueueName = Label.UAC_volagQueueName;

  public
  static final string strSubStatusNAValue = Label.UAC_contactTracingStatusNotApplicable;

  public
  static final string strSubStatusTransRevPending = Label.UAC_transferReviewPendingTaskStatus;

  public
  static final string strCaseCoordinatorName = Label.UAC_accountTeamRoleNameCC;

  /**
   * @description Invocable method to create Tasks and read only team members
   * @author James Qian (Deloitte) | 08/04/2020
   * @param List<Request>
   * @return List<Response>
   **/
  @InvocableMethod(label = 'Create Tasks') public static List<Response> insertTasksForPrograms(
      List<Request> listInputRequest) {
    Response objResponse = new Response();
    objResponse.strErrorMessage = null;
    Boolean bisCurrentUserCC = false;
    Boolean bisVolagUser = false;
    if (listInputRequest[0].listAccountIds == null
        || listInputRequest[0].listAccountIds.isEmpty()) {
      objResponse.strErrorMessage = Label.UAC_transferReferralErrorMessage;
      return new List<Response>{objResponse};
    }
    Map<Id, Account> mapAccounts = getAccountMap(listInputRequest[0].listAccountIds);
    if (mapAccounts.values().isEmpty()) {
      return new List<Response>{objResponse};
    }
    set<id> setLCMAccIds = new set<id>();
    set<id> setVolagParentAccIds = new set<id>();
    set<id> setGranteeAccountIds = new set<id>();
    bisCurrentUserCC = isCC();
    bisVolagUser = isVolagUser();
    for (Id acc : mapAccounts.keyset()) {
      // Create Tasks for Referral Round 1
      if (bisCurrentUserCC) {
        if (isVolagProgram(mapAccounts.get(acc))) {
          // Create Tasks for volag Parents
          setGranteeAccountIds.add(acc);
        } else {
          // Create Tasks for LCM
          setLCMAccIds.add(acc);
        }
      } else if (bisVolagUser) {
        // Create Tasks for Referral Round 2
        setLCMAccIds.add(acc);
      }
    }
    String strVolagQueueId = getVolagQueueId();
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameRead][0].Id;
    Id idParentUAC =
        [SELECT ContactId FROM Case WHERE Id =:listInputRequest[0].idTransferRequest][0].ContactId;
    Id idTaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                              .get(Label.UAC_taskRecordTypeTransfer)
                              .getRecordTypeId();

    // Create Volag Tasks
    if (setGranteeAccountIds != null) {
      createVolagTasks(
          setGranteeAccountIds, listInputRequest, strVolagQueueId, idParentUAC, idTaskRecordType);
    }

    Map<Id, Id> mapAccountToLCM = getAccountTeamMemberMap(setLCMAccIds);
    if (mapAccountToLCM.values().isEmpty()) {
      return new List<Response>{objResponse};
    }
    // Create LCM tasks
    createLCMTasks(mapAccountToLCM,
        listInputRequest,
        bisVolagUser,
        idCaseTeamRole,
        idParentUAC,
        idTaskRecordType);

    return new List<Response>{objResponse};
  }
  /**
   * @description Method to create and assign tasks to LCM at recieving Programs
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @param Map<Id, Id> mapAccountToLCM
   * @param List<Request> listInputRequest
   * @param boolean bisVolagUser
   * @param Id idCaseTeamRole
   * @param Id idParentUAC
   * @param Id idTaskRecordType
   * @return void
   **/
  private
  static void createLCMTasks(Map<Id, Id> mapAccountToLCM,
      List<Request> listInputRequest,
      boolean bisVolagUser,
      Id idCaseTeamRole,
      Id idParentUAC,
      Id idTaskRecordType) {

    Boolean existingATMFound = false;
    List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
    List<AccountTeamMember> listAccountTeamMembers = new List<AccountTeamMember>();

    Id idFamilyGroup = [SELECT AccountId FROM Contact WHERE Id =:idParentUAC].AccountId;
    List<AccountTeamMember> listCurrentAccountTeamMembers = [SELECT AccountId,
      AccountAccessLevel,
      CaseAccessLevel,
      ContactAccessLevel,
      UserId from AccountTeamMember WHERE AccountId =:idFamilyGroup];

    List<Task> listTasks = new List<Task>();
    String subStatus = null;
    Map<Id, List<Id>> mapAccountToSecondaryTeamMembers =
        getSecondaryAccountTeamMemberMap(mapAccountToLCM.keyset());
    for (Id idAccount : mapAccountToLCM.keyset()) {
      if (String.isNotBlank(mapAccountToLCM.get(idAccount))) {
        // set substatus only if Volag User
        if (bisVolagUser) {
          subStatus = strSubStatusTransRevPending;
        }
        listTasks.add(createTask(listInputRequest[0].idTransferRequest,
            mapAccountToLCM.get(idAccount),
            idTaskRecordType,
            idAccount,
            idParentUAC,
            subStatus));
        for (AccountTeamMember objATM : listCurrentAccountTeamMembers) {
          if (objATM.UserId == mapAccountToLCM.get(idAccount)) {
            if (objATM.AccountAccessLevel == 'Edit' || objATM.CaseAccessLevel == 'Edit'
                || objATM.ContactAccessLevel == 'Edit') {
              existingATMFound = true;
            }
          }
        }

        if (!existingATMFound) {
          listAccountTeamMembers.add(new AccountTeamMember(UserId = mapAccountToLCM.get(idAccount),
              AccountId = idFamilyGroup,
              TeamMemberRole = 'Temporary',
              AccountAccessLevel = 'Read',
              CaseAccessLevel = 'Read',
              ContactAccessLevel = 'Read'));
        }

        listCaseTeamMembers.add(createCaseTeamMember(
            listInputRequest[0].idTransferRequest, mapAccountToLCM.get(idAccount), idCaseTeamRole));

        if (mapAccountToSecondaryTeamMembers.containsKey(idAccount)) {
          for (Id idUser : mapAccountToSecondaryTeamMembers.get(idAccount)) {
            listCaseTeamMembers.add(createCaseTeamMember(
                listInputRequest[0].idTransferRequest, idUser, idCaseTeamRole));
          }
        }
      }
    }

    if (!listTasks.isEmpty()) {
      insert listTasks;
    }
    if (!listCaseTeamMembers.isEmpty()) {
      Database.insert(listCaseTeamMembers, false);
    }
    if (!listAccountTeamMembers.isEmpty()) {
      insert listAccountTeamMembers;
    }
  }
  /**
   * @description Method to create and assign tasks to Volag Team
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @param set<id> setVolagParentAccIds
   * @param List<Request> listInputRequest
   * @param Id idParentUAC
   * @param Id idTaskRecordType
   * @return void
   **/
  private
  static void createVolagTasks(set<id> setVolagParentAccIds,
      List<Request> listInputRequest,
      string strVolagQueueId,
      Id idParentUAC,
      Id idTaskRecordType) {
    List<Task> listTasks = new List<Task>();

    for (Id idAccount : setVolagParentAccIds) {
      listTasks.add(createTask(listInputRequest[0].idTransferRequest,
          strVolagQueueId,
          idTaskRecordType,
          idAccount,
          idParentUAC,
          strSubStatusNAValue));
    }
    if (!listTasks.isEmpty()) {
      insert listTasks;
    }
  }

  /**
   * @description Utility method to create Tasks
   * @author James Qian (Deloitte) | 08/04/2020
   * @param idCase
   * @param idUser
   * @param idRecordType
   * @param idProgram
   * @param idUAC
   * @return Task
   **/
  private
  static Task createTask(
      Id idCase, Id idUser, Id idRecordType, Id idProgram, Id idUAC, String subStatus) {
    return new Task(RecordTypeId = idRecordType,
        OwnerId = idUser,
        WhatId = idCase,
        UAC_program__c = idProgram,
        Subject = Label.UAC_transferReferralTaskSubject,
        Description = Label.UAC_transferReferralTaskBody,
        ActivityDate = System.Today().addDays(3),
        UAC_subStatus__c = subStatus,
        WhoId = idUAC);
  }

  /**
   * @description Utility method to create Case Team Members
   * @author James Qian (Deloitte) | 08/04/2020
   * @param idCase
   * @param idUser
   * @param idRole
   * @return CaseTeamMember
   **/
  private
  static CaseTeamMember createCaseTeamMember(Id idCase, Id idUser, Id idRole) {
    return new CaseTeamMember(MemberId = idUser, ParentId = idCase, TeamRoleId = idRole);
  }

  /**
   * @description Utility method to query Account Team Members of type Lead Case Manager
   * @author James Qian (Deloitte) | 08/04/2020
   * @param listAccountIds
   * @return Map<Id, Id>
   **/
  private
  static Map<Id, Id> getAccountTeamMemberMap(Set<Id> listAccountIds) {
    Map<Id, Id> mapAccountToLCM = new Map<Id, Id>();
    for (AccountTeamMember atmCurrent : [
           SELECT UserId,
           AccountId FROM AccountTeamMember WHERE AccountId IN:listAccountIds AND TeamMemberRole
                                                             =:Label.UAC_accountTeamRoleLCM
         ]) {
      mapAccountToLCM.put(atmCurrent.AccountId, atmCurrent.UserId);
    }
    return mapAccountToLCM;
  }

  /**
   * @description Utility method to query Account Team Members of type Lead Clinician and Program
   *Director
   * @author James Qian (Deloitte) | 09/21/2020
   * @param listAccountIds
   * @return Map<Id, List<Id>>
   **/
  private
  static Map<Id, List<Id>> getSecondaryAccountTeamMemberMap(Set<Id> listAccountIds) {
    Map<Id, List<Id>> mapAccountToSecondaryTeamMembers = new Map<Id, List<Id>>();
    List<String> listSecondaryRoles =
        new List<String>{Label.UAC_accountTeamRoleLC, Label.UAC_accountTeamRolePD};
    for (AccountTeamMember atmCurrent : [
           SELECT UserId,
           AccountId FROM AccountTeamMember WHERE AccountId IN:listAccountIds AND TeamMemberRole
                                                            IN:listSecondaryRoles
         ]) {
      List<Id> listIds;
      if (mapAccountToSecondaryTeamMembers.containsKey(atmCurrent.AccountId)) {
        listIds = mapAccountToSecondaryTeamMembers.get(atmCurrent.AccountId);
      } else {
        listIds = new List<Id>();
      }
      listIds.add(atmCurrent.UserId);
      mapAccountToSecondaryTeamMembers.put(atmCurrent.AccountId, listIds);
    }
    return mapAccountToSecondaryTeamMembers;
  }

  /**
   * @description Inner class to store requests
   * @author James Qian (Deloitte) | 08/04/2020
   **/
  public
  without sharing class Request {
    @InvocableVariable(required = true) public List<Id> listAccountIds;
    @InvocableVariable public Id idTransferRequest;
  }

  /**
   * @description Inner class to store responses
   * @author James Qian (Deloitte) | 08/04/2020
   **/
  public without sharing class Response {
    @InvocableVariable public String strErrorMessage;
  }

  /**
   * @description Aura Enabled method to query Accounts that match search criteria.
   * @author James Qian (Deloitte) | 08/04/2020
   * @param searchKey
   * @return List<Account>
   **/
  @AuraEnabled public static List<Account>
  queryAccounts(String searchKey) {
    String strWildCard = '%' + String.escapeSingleQuotes(searchKey) + '%';
    return [
      SELECT Id,
      Name,
      Type,
      UAC_stopPlacementTransfer__c,
      UAC_volagGrantee__c,
      UAC_searchTags__c,
      UAC_city__c,
      UAC_state__c,
      UAC_bedCountAvailableMale__c,
      UAC_bedCountAvailableFemale__c,
      UAC_minimumAge__c,
      UAC_maximumAge__c FROM Account WHERE RecordType.DeveloperName =
          'UAC_program' AND UAC_programStatus__c
          != 'Inactive' AND(UAC_searchTags__c LIKE
                            : strWildCard OR Name LIKE
                            : strWildCard)
    ];
  }

  /**
   * @description Method to check if the current user is a Volag user
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @return Boolean
   **/
  private
  static boolean isVolagUser() {
    List<PermissionSetAssignment> lstPermSetAssigned =
        [select PermissionSetId, PermissionSet.Name from PermissionSetAssignment where AssigneeId
          =:UserInfo.getUserId()and PermissionSet.name = 'UAC_volagUser'];
    return lstPermSetAssigned.size() > 0;
  }
  /**
   * @description Method to check if the current user is a Case Coordinator
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @return Boolean
   **/
  private
  static boolean isCC() {
    List<User> lstPermSetAssigned =
        [select id, UserRole.name from User where id =:UserInfo.getUserId()];
    return lstPermSetAssigned[0].UserRole.name == strCaseCoordinatorName;
  }
  /**
   * @description Method to get QueueId
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @return String
   **/
  private
  static String getVolagQueueId() {
    return
        [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:strVolagQueueName limit 1].id;
  }
  /**
   * @description Method to get Map of all searched accounts
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @param List<Id> listAccountIds
   * @return Map<Id,Account>
   **/
  private
  static Map<Id, Account> getAccountMap(List<Id> listAccountIds) {
    set<id> setAccountIds = new set<Id>();
    if (listAccountIds == null || listAccountIds.isEmpty()) return null;
    for (Id accId : listAccountIds) {
      setAccountIds.add(accId);
    }

    return new Map<ID, Account>(
        [SELECT Id, Name, Type, UAC_volagGrantee__c, ParentId FROM Account where id
          =:setAccountIds]);
  }
  /**
   * @description Method to check if the account is a Volag Program
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @param Account currentAccount
   * @return Boolean
   **/
  private
  static Boolean isVolagProgram(Account currentAccount) {
    return currentAccount.UAC_volagGrantee__c == 'Yes';
  }
}