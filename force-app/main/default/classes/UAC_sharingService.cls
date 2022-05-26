/**
 * @File Name          : UAC_sharingService.cls
 * @Description        : Batch Service Class
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              :
 * @Test Class         : UAC_sharingRecalculateBatchTest
 * @Last Modified By   : Sarang Padhye (Deloitte)
 * @Last Modified On   : 8/30/2020,
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    8/28/2020   Sarang Padhye (Deloitte)        Initial Implementation.
 */
public
without sharing class UAC_sharingService {

  public
  Map<String, List<AccountTeamMember>> mapProgramToAtm {
    get;
    set;
  }

  public
  Map<String, List<CaseTeamMember>> mapContactToCtm {
    get;
    set;
  }

  public
  List<Case> lstBatchScope {
    get;
    set;
  }

  /**
   * @description ORRUAC-1850 - Method saves the the batch scope and calls appropriate methods
   * to process DN cases
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstBatchScope Case record to process
   * @return void
   **/
  public
  UAC_sharingService(List<case> lstBatchScope) {
    this.lstBatchScope = lstBatchScope;
    populateProgramAtmMap(lstBatchScope);
    populateContactToCtmMap(lstBatchScope);
    revokeAccess(lstBatchScope, mapProgramToAtm, mapContactToCtm);
  }

  /**
   * @description ORRUAC-1850 - Method populates map of Programs to AccountTeamMember
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstBatchScope Case record to process
   * @return void
   **/
  public
  void populateProgramAtmMap(List<case> lstBatchScope) {
    set<Id> setAllAccountIds = new set<Id>();
    try {
      if (!lstBatchScope.isEmpty() || lstBatchScope != null) {
        for (case c : lstBatchScope) {
          // Family Group
          if (c.Contact.AccountID != null) {
            setAllAccountIds.add(c.Contact.AccountId);

            // Profile's UAC program
            if (c.Contact.UAC_program__c != null) {
              setAllAccountIds.add(c.Contact.UAC_program__c);
            }
            // Program Discharged from
            if (c.UAC_currentProgram__c != null) {
              setAllAccountIds.add(c.UAC_currentProgram__c);
            }
          }
        }
        // Query Account Team Members
        Map<Id, AccountTeamMember> mapAccountTeamMems = new Map<Id, AccountTeamMember>(
            [select id, AccountId, UserId, User.Name from AccountTeamMember where AccountId
              =:setAllAccountIds]);
        // Create Map
        mapProgramToAtm = new Map<String, List<AccountTeamMember>>();
        if (mapAccountTeamMems != null || !mapAccountTeamMems.isEmpty()) {
          for (Id aT : mapAccountTeamMems.keySet()) {
            if (mapProgramToAtm.containsKey(mapAccountTeamMems.get(aT).AccountId)) {
              List<AccountTeamMember> accTeamMem =
                  mapProgramToAtm.get(mapAccountTeamMems.get(aT).AccountId);
              accTeamMem.add(mapAccountTeamMems.get(aT));
              mapProgramToAtm.put(mapAccountTeamMems.get(aT).AccountId, accTeamMem);
            } else {
              mapProgramToAtm.put(mapAccountTeamMems.get(aT).AccountId,
                  new List<AccountTeamMember>{mapAccountTeamMems.get(aT)});
            }
          }
        }
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'populateProgramAtmMap:Error Populating Map',
          e.getStackTraceString());
    }
  }
  /**
   * @description ORRUAC-1850 - Method populates map of Contact to CaseTeamMember
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstBatchScope Case record to process
   * @return void
   **/
  public
  void populateContactToCtmMap(List<case> lstBatchScope) {

    set<id> contactIds = new set<id>();
    try {
      if (lstBatchScope != null || !lstBatchScope.isEmpty()) {
        for (Case c : lstBatchScope) {
          if (c.ContactId != null) {
            contactIds.add(c.ContactId);
          }
        }
        // Query case team members
        Map<Id, CaseTeamMember> mapCaseTeamMems = new Map<id, CaseTeamMember>([select id,
          Parent.ContactId,
          MemberId,
          Member.Name from CaseTeamMember where Parent.ContactId =:contactIds]);
        // Create Map
        mapContactToCtm = new Map<String, List<CaseTeamMember>>();
        if (mapCaseTeamMems != null || !mapCaseTeamMems.isEmpty()) {
          for (Id cT : mapCaseTeamMems.keySet()) {
            if (mapContactToCtm.containsKey(mapCaseTeamMems.get(cT).Parent.ContactId)) {
              List<CaseTeamMember> caseTeamMems =
                  mapContactToCtm.get(mapCaseTeamMems.get(cT).Parent.ContactId);
              caseTeamMems.add(mapCaseTeamMems.get(cT));
              mapContactToCtm.put(mapCaseTeamMems.get(cT).Parent.ContactId, caseTeamMems);
            } else {
              mapContactToCtm.put(mapCaseTeamMems.get(cT).Parent.ContactId,
                  new List<CaseTeamMember>{mapCaseTeamMems.get(cT)});
            }
          }
        }
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'populateContactToCtmMap:Error Populating Map',
          e.getStackTraceString());
    }
  }
  /**
   * @description ORRUAC-1850 - Method finds and deletes AccountTeamMembers and CaseTeamMembers
   * related to the UAC
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstNewCases Case record to check
   * @param mapProgramToAtm Program to AccountTeamMember Map
   * @param mapContactToCtm Contact to CaseTeamMember Map
   * @return void
   **/
  public
  void revokeAccess(List<case> lstBatchScope,
      Map<String, List<AccountTeamMember>> mapProgramToAtm,
      Map<String, List<CaseTeamMember>> mapContactToCtm) {
    List<AccountTeamMember> lstAccTeamToBeDeleted = new List<AccountTeamMember>();
    List<CaseTeamMember> lstCaseTeamToBeDeleted = new List<CaseTeamMember>();
    try {
      if (lstBatchScope != null || !lstBatchScope.isEmpty()) {
        for (case c : lstBatchScope) {
          if (mapProgramToAtm.containsKey(c.UAC_currentProgram__c)) {
            List<AccountTeamMember> lstUACProgramAtm = new List<AccountTeamMember>();
            // get list of Discharged Program Account Team members
            List<AccountTeamMember> listDischargedProgAtm =
                mapProgramToAtm.get(c.UAC_currentProgram__c);

            if (mapProgramToAtm.containsKey(c.Contact.UAC_program__c)) {
              lstUACProgramAtm = mapProgramToAtm.get(c.Contact.UAC_program__c);
            }

            if (mapProgramToAtm.containsKey(c.Contact.AccountId)) {
              List<AccountTeamMember> lstUACFamGroupAtm = mapProgramToAtm.get(c.Contact.AccountId);

              lstAccTeamToBeDeleted =
                  UAC_sharingServiceHelper.findATmDeleteCandidates(listDischargedProgAtm,
                      lstUACFamGroupAtm,
                      lstUACProgramAtm,
                      lstAccTeamToBeDeleted);
            }

            if (mapContactToCtm.containsKey(c.ContactId)) {
              List<CaseTeamMember> lstCtm = mapContactToCtm.get(c.ContactId);

              lstCaseTeamToBeDeleted = UAC_sharingServiceHelper.findCtmDeleteCandidates(
                  listDischargedProgAtm, lstCtm, lstUACProgramAtm, lstCaseTeamToBeDeleted);
            }
          }
        }
      }
      if (!lstAccTeamToBeDeleted.isEmpty()) {
        UAC_sharingServiceHelper.deleteAccountTeamMems(lstAccTeamToBeDeleted);
      }
      if (!lstCaseTeamToBeDeleted.isEmpty()) {
        UAC_sharingServiceHelper.deleteCaseTeamMems(lstCaseTeamToBeDeleted);
      }
      if (!lstBatchScope.isEmpty()) {
        UAC_sharingServiceHelper.updateSharingRecalculated(lstBatchScope);
      }
    } catch (Exception e) {
      UAC_errorLog.logError(
          e.getMessage(), '', 'revokeAccess:Error revoking access', e.getStackTraceString());
    }
  }
}