/**
 * @File Name         : UAC_caseChangeEventTriggerHelper.cls
 * @Description       : Trigger helper for UAC_caseChangeEventTriggerHandler
 * @Group             : UAC_caseChangeEventTrigger
 * @Test Class        : UAC_caseChangeEventTriggerHelperTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-29-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-28-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
inherited sharing class UAC_caseChangeEventTriggerHelper {

  public
  static final String ROLE_MEDICAL_COORDINATOR = Label.UAC_accountTeamRoleMC;

  static final String CLASS_NAME = UAC_caseChangeEventTriggerHelper.class.getName();

  public
  static void handleEntryTeamMapping(Set<String> setCaseId) {
    Set<Id> setAccountId = new Set<Id>();
    Map<Id, Case> mapMentalHealthReferralCase = new Map<Id, Case>();
    for (Case objCase :
        // clang-format off
        [SELECT
          Id, Contact.AccountId, RecordType.DeveloperName
        FROM
          Case
        WHERE
          Id IN:setCaseId
        ]
        // clang-format on
    ) {
      if (objCase.RecordType.DeveloperName == Label.UAC_caseRecordTypeMHR) {
        mapMentalHealthReferralCase.put(objCase.Id, objCase);
        setAccountId.add(objCase.Contact.AccountId);
      }
    }
    Map<Id, List<AccountTeamMember>> mapEntityTeamMember =
        getAccountTeamMemberByAccount(setAccountId);
    handleEntryTeamMappingForMentalHealthReferral(mapEntityTeamMember, mapMentalHealthReferralCase);
  }

  public
  static void handleEntryTeamMappingForMentalHealthReferral(
      Map<Id, List<AccountTeamMember>> mapEntityTeamMember, Map<Id, Case> mapCase) {
    // Get CaseTeamRole for Medical Coordinator
    CaseTeamRole idRoleMedicalCoordinator = getCaseTeamRolesByName().get(ROLE_MEDICAL_COORDINATOR);

    // Map existing Entry Team Member
    Map<Id, List<CaseTeamMember>> mapExistingEntryTeamMember =
        getCaseTeamMembersByCase(mapCase.keySet());

    // Prepare list of new entry team members to insert
    List<CaseTeamMember> lstNewEntryTeamMember = new List<CaseTeamMember>();
    List<CaseTeamMember> lstOldEntryTeamMemberToDelete = new List<CaseTeamMember>();
    for (Case objCase : mapCase.values()) {
      lstNewEntryTeamMember.addAll(getNetNewEntryTeamMembersForRole(objCase.Id,
          idRoleMedicalCoordinator,
          mapExistingEntryTeamMember.get(objCase.Id),
          mapEntityTeamMember.get(objCase.Contact.AccountId)));
      lstOldEntryTeamMemberToDelete.addAll(
          getMismatchedEntryTeamMembersForRole(idRoleMedicalCoordinator,
              mapExistingEntryTeamMember.get(objCase.Id),
              mapEntityTeamMember.get(objCase.Contact.AccountId)));
    }

    // Insert new entry team members
    List<Database.SaveResult> lstSaveResult = Database.insert(lstNewEntryTeamMember, false);
    for (Database.SaveResult objSaveResult : lstSaveResult) {
      if (!objSaveResult.isSuccess()) {
        for (Database.Error objError : objSaveResult.getErrors()) {
          UAC_errorLog.platformEventErrorLog(objError.getMessage(),'',
              'Case Change Event Trigger : Inserting Medical Coordinator',
              CLASS_NAME + '::handleEntryTeamMappingForMentalHealthReferral()');
        }
      }
    }

    // Delete old entry team members
    List<Database.DeleteResult> lstDeleteResult =
        Database.delete(lstOldEntryTeamMemberToDelete, false);
    for (Database.DeleteResult objDeleteResult : lstDeleteResult) {
      if (!objDeleteResult.isSuccess()) {
        for (Database.Error objError : objDeleteResult.getErrors()) {
          UAC_errorLog.platformEventErrorLog(objError.getMessage(),'',
              'Case Change Event Trigger : Deleting old Medical Coordinator',
              CLASS_NAME + '::handleEntryTeamMappingForMentalHealthReferral()');
        }
      }
    }
  }

  /**
   * @description Return new list of entry team members based on entity team member that are not
   *part of existing entry team
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param idCase Id of case
   * @param objCaseTeamRole Case Team Role
   * @param lstEntryTeamMember List of existing entry team members
   * @param lstEntityTeamMember List of entity team members
   * @return List<CaseTeamMember>
   **/
  public
  static List<CaseTeamMember> getNetNewEntryTeamMembersForRole(Id idCase,
      CaseTeamRole objCaseTeamRole,
      List<CaseTeamMember> lstEntryTeamMember,
      List<AccountTeamMember> lstEntityTeamMember) {

    // Prepare set of existing entry team member Ids
    Set<Id> setExistingEntryTeamMember = new Set<Id>();
    if (lstEntryTeamMember != null) {
      for (CaseTeamMember objEntryTeamMember : lstEntryTeamMember) {
        if (objEntryTeamMember.TeamRoleId == objCaseTeamRole.Id) {
          setExistingEntryTeamMember.add(objEntryTeamMember.MemberId);
        }
      }
    }

    List<CaseTeamMember> lstNewEntryTeamMember = new List<CaseTeamMember>();
    if (lstEntityTeamMember != null) {
      for (AccountTeamMember objEntityTeamMember : lstEntityTeamMember) {
        if (objEntityTeamMember.TeamMemberRole == objCaseTeamRole.Name
            && !setExistingEntryTeamMember.contains(objEntityTeamMember.UserId)) {
          lstNewEntryTeamMember.add(new CaseTeamMember(MemberId = objEntityTeamMember.UserId,
              TeamRoleId = objCaseTeamRole.Id,
              ParentId = idCase));
        }
      }
    }
    return lstNewEntryTeamMember;
  }

  /**
   * @description Returns list of entry team members that are not part of entity team members.
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param objCaseTeamRole Case Team Role
   * @param lstEntryTeamMember List of existing entry team members
   * @param lstEntityTeamMember List of entity team members
   * @return List<CaseTeamMember>
   **/
  public
  static List<CaseTeamMember> getMismatchedEntryTeamMembersForRole(CaseTeamRole objCaseTeamRole,
      List<CaseTeamMember> lstEntryTeamMember,
      List<AccountTeamMember> lstEntityTeamMember) {

    // Prepare set of existing entry team member Ids
    Set<Id> setExistingEntityTeamMember = new Set<Id>();
    if (lstEntityTeamMember != null) {
      for (AccountTeamMember objEntityTeamMember : lstEntityTeamMember) {
        if (objEntityTeamMember.TeamMemberRole == objCaseTeamRole.Name) {
          setExistingEntityTeamMember.add(objEntityTeamMember.UserId);
        }
      }
    }

    List<CaseTeamMember> lstMismatchedEntryTeamMember = new List<CaseTeamMember>();
    if (lstEntryTeamMember != null) {
      for (CaseTeamMember objEntryTeamMember : lstEntryTeamMember) {
        if (objEntryTeamMember.TeamRoleId == objCaseTeamRole.Id
            && !setExistingEntityTeamMember.contains(objEntryTeamMember.MemberId)) {
          lstMismatchedEntryTeamMember.add(objEntryTeamMember);
        }
      }
    }
    return lstMismatchedEntryTeamMember;
  }

  /**
   * @description Method to get list of account team members mapped by account id.
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param setAccountId Set of Account Id to query Account Team Members
   * @return Map<Id, List<AccountTeamMember>>
   **/
  public
  static Map<Id, List<AccountTeamMember>> getAccountTeamMemberByAccount(Set<Id> setAccountId) {
    Map<Id, List<AccountTeamMember>> mapAccountTeamMember = new Map<Id, List<AccountTeamMember>>();
    for (AccountTeamMember objAccountTeamMember :
        // clang-format off
        [SELECT
          Id, AccountId, UserId, TeamMemberRole
        FROM
          AccountTeamMember
        WHERE
          AccountId IN :setAccountId
        ]
        // clang-format on
    ) {
      if (!mapAccountTeamMember.containsKey(objAccountTeamMember.AccountId)) {
        mapAccountTeamMember.put(objAccountTeamMember.AccountId, new List<AccountTeamMember>());
      }
      mapAccountTeamMember.get(objAccountTeamMember.AccountId).add(objAccountTeamMember);
    }
    return mapAccountTeamMember;
  }

  /**
   * @description Method to get list of case team members mapped by case id.
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param setCaseId Set of Case Id to query Case Team Members
   * @return Map<Id, List<CaseTeamMember>>
   **/
  public
  static Map<Id, List<CaseTeamMember>> getCaseTeamMembersByCase(Set<Id> setCaseId) {
    Map<Id, List<CaseTeamMember>> mapCaseTeamMember = new Map<Id, List<CaseTeamMember>>();
    for (CaseTeamMember objCaseTeamMember :
        // clang-format off
        [SELECT
          Id, ParentId, MemberId, TeamRoleId, TeamRole.Name
        FROM
          CaseTeamMember
        WHERE
          ParentId IN :setCaseId
        ]
        // clang-format on
    ) {
      if (!mapCaseTeamMember.containsKey(objCaseTeamMember.ParentId)) {
        mapCaseTeamMember.put(objCaseTeamMember.ParentId, new List<CaseTeamMember>());
      }
      mapCaseTeamMember.get(objCaseTeamMember.ParentId).add(objCaseTeamMember);
    }
    return mapCaseTeamMember;
  }

  /**
   * @description Method to return Case Team Role records mapped by role name.
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @return Map<String, CaseTeamRole>
   **/
  public
  static Map<String, CaseTeamRole> getCaseTeamRolesByName() {
    Map<String, CaseTeamRole> mapCaseTeamRole = new Map<String, CaseTeamRole>();
    for (CaseTeamRole objCaseTeamRole :
        // clang-format off
        [SELECT
          Id, Name, AccessLevel
        FROM
          CaseTeamRole
        LIMIT 5000
        ]
        // clang-format on
    ) {
      mapCaseTeamRole.put(objCaseTeamRole.Name, objCaseTeamRole);
    }
    return mapCaseTeamRole;
  }
}