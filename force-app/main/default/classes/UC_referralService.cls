public
without sharing class UC_referralService {
  public
  static boolean boolFirstTriggerRun = true;
  private
  static Map<Id, Contact> mapContactsToUpdate;
  private
  static final Map<String, Schema.RecordTypeInfo> mapRecordTypesByDeveloperName =
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
  private
  static final Id UACReferralRecordTypeId =
      mapRecordTypesByDeveloperName.get(Label.UAC_referralRecordTypeName).getRecordTypeId();
  private
  static final String strPlacementRequestedStatus = Label.UAC_placementRequestedContactStatus;
  private
  static final String strPlacementNotAcceptedStatus = Label.UAC_placementNotAcceptedContactStatus;
  private
  static final String strNewPendingStatus = Label.UAC_newPendingContactStatus;
  private
  static final String strProcessedPendingStatus = Label.UAC_processedPendingContactStatus;
  private
  static final String strPlacementDesignatedStatus = Label.UAC_placementDesignatedContactStatus;
  private
  static final String strPlacementMatchUnderReviewStatus =
      Label.UAC_placementMatchUnderReviewStatus;
  private
  static final String strReferralCancelledStatus = Label.UAC_CaseReferralCancelledStatus;
  private
  static final String strAdmittedStatus = Label.UAC_admittedContactStatus;
  private
  static final String strInTransferStatus = Label.UAC_inTransferContactStatus;
  private
  static final String strErrorMessage = Label.UAC_duplicatePendingReferralErrorMessage;
  private
  static final String strSupervisorApprovalRequestedError =
      Label.UAC_supervisorApprovalRequestedErrorMessage;
  private
  static final String strSupervisorApprovedError = Label.UAC_supervisorApprovedErrorMessage;
  private
  static final String strSupervisorApprovalRequestedStatus =
      Label.UAC_supervisorApprovalRequestedStatus;
  private
  static final String strSupervisorApprovedStatus = Label.UAC_supervisorApprovedStatus;
  private
  static final String STR_ERROR_NO_PROGRAM =
      'You cannot designate a Referral without a Program selected.';
  private
  static final String strErrorDesignationReversal =
      'You can only change the designation for the most recent referral and for UCs who are still in "Placement Designated" status.';

  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will construct a map of newly inserted Cases and
   * call methods to check for duplicates pendind referrals and process
   * returning referrals
   * @param        List of newly inserted Cases
   * @return
   */
  public
  static void processReferralsBeforeInsert(List<Case> lstNewCases) {
    mapContactsToUpdate = new Map<Id, Contact>();
    List<Case> lstOfCasesToProcess = new List<Case>();
    List<Case> lstOfMatchedCases = new List<Case>();
    List<Case> lstOfCasesForNewborn = new List<Case>();
    Map<String, List<Case>> mapOfCasesByANumber = new Map<String, List<Case>>();

    // Construct map of newly inserted Cases by A#
    for (Case objCase : lstNewCases) {
      lstOfCasesToProcess.add(objCase);
      List<Case> lstCase = new List<Case>();
      if (mapOfCasesByANumber.containsKey(objCase.UAC_aNum__c)) {
        lstCase = mapOfCasesByANumber.get(objCase.UAC_aNum__c);
      }
      lstCase.add(objCase);
      mapOfCasesByANumber.put(objCase.UAC_aNum__c, lstCase);
      if (objCase.UAC_aNum__c.containsIgnoreCase('A') || objCase.UAC_aNum__c.containsIgnoreCase('B')
          || objCase.UAC_aNum__c.containsIgnoreCase('C')) {
        objCase.UAC_referralDateTime__c = null;
        objCase.UAC_apprehensionDatetime__c = null;
        lstOfCasesForNewborn.add(objCase);
      }
    }

    if (!lstOfCasesToProcess.isEmpty()) {
      lstOfMatchedCases = getMatchedCasesByANumber(lstOfCasesToProcess);
      if (!lstOfMatchedCases.isEmpty()) {
        rejectDuplicatePendingReferrals(lstOfMatchedCases, mapOfCasesByANumber);
        processReturningUACReferrals(lstOfMatchedCases, mapOfCasesByANumber);
      }
      if (!lstOfCasesForNewborn.isEmpty()) {
        setReferralDateForNewborn(lstOfCasesForNewborn);
      }
    }
  }

  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will construct a map of newly inserted Cases and
   * call methods to check for duplicates pendind referrals and process
   * returning referrals
   * @param        List of newly inserted Cases
   * @return
   */
  public
  static void processReferralsAfterInsert(Map<Id, Case> mapNewCases) {
    createInitialHealthInformation(mapNewCases);  // CONSIDER FOR ASYNC
    processNewUACReferrals(mapNewCases);
    UAC_CaseTriggerHelper.syncContactStatusWithCaseStatusReferral(
        mapNewCases.values(), mapContactsToUpdate, true);  // CONSIDER FOR ASYNC
  }

  /**
   * @description ORRUAC-1061 - generic method to handle Referral update
   *methods.
   * @author James Qian (Deloitte) 6/18/20
   * @param Map<Id, Case> mapNewCases
   * @param Map<Id, Case> mapOldCases
   * @return void
   **/
  public
  static void processReferralsBeforeUpdate(Map<Id, Case> mapNewCases, Map<Id, Case> mapOldCases) {
    mapContactsToUpdate = new Map<Id, Contact>();
    // Instantiate Collections for Passing to Methods
    List<Case> lstOfCasetoUpdateFields = new List<Case>();
    List<Id> lstOfProgramAccountId = new List<Id>();
    Map<Id, string> mapOfRelatedProgramIdtoType = new Map<id, string>();
    Map<Id, Case> mapOfReProcessedReferrals = new Map<Id, Case>();
    List<Case> lstOfPlacementNotAccepted = new List<Case>();
    List<Case> lstOfAcceptPlacement = new List<Case>();
    List<Case> lstCasesForAutoBed = new List<Case>();
    List<Case> lstCasesForSupervisorApproval = new List<Case>();
    List<Case> lstCasesForSupervisorApproved = new List<Case>();
    List<Case> lstOfCaseForRelatedUACCheck = new List<Case>();
    List<Contact> lstOfRelatedUACtoUpdate = new List<Contact>();
    Set<String> setAccountIds = new Set<String>();
    Set<String> setCaseIds = new Set<String>();
    Set<Id> setOfUACs = new Set<Id>();
    Set<Id> setParentIds = new Set<Id>();
    Set<Id> setOfUACsForRelatedUACCheck = new Set<Id>();

    // Loop through Cases, filter, and add to Collections
    for (Case objCase : mapNewCases.values()) {
      Case objOldCase = mapOldCases.get(objCase.Id);
      if (objCase.RecordTypeId != UACReferralRecordTypeId) {
        continue;
      }
      if (objCase.UAC_programFacility__c != objOldCase.UAC_programFacility__c
          && objCase.Status == 'Processed Pending' && objCase.UAC_programFacility__c != null) {
        lstOfProgramAccountId.add(objCase.UAC_programFacility__c);
        lstOfCasetoUpdateFields.add(objCase);
      }
      if (objCase.UAC_programFacility__c != objOldCase.UAC_programFacility__c
          && objCase.UAC_programFacility__c != null) {
        lstOfCaseForRelatedUACCheck.add(objCase);
        setOfUACsForRelatedUACCheck.add(objCase.ContactId);
      }
      if (objCase.Status == strProcessedPendingStatus
          && objOldCase.Status == strPlacementDesignatedStatus) {
        mapOfReProcessedReferrals.put(objCase.ContactId, objCase);
      }
    }

    /**
     * @description OORRUAC-65- Method to Update the Case fields
     *record
     * @author Chaitanya Nandamuri (Deloitte) | 06/01/2020
     * @param
     * @return void
     **/
    updateFieldsforStandardPlacements(lstOfProgramAccountId, lstOfCasetoUpdateFields);
    for (Case objCase : mapNewCases.values()) {
      Case objOldCase = mapOldCases.get(objCase.Id);
      if (objCase.RecordTypeId != UACReferralRecordTypeId || objCase.Status == objOldCase.Status) {
        continue;
      }
      if (objCase.Status == strPlacementNotAcceptedStatus
          && objCase.UAC_requiresPlacementRequest__c) {
        lstOfPlacementNotAccepted.add(objCase);
      } else if (objCase.Status == strPlacementDesignatedStatus) {
        if (objCase.UAC_programFacility__c == null) {
          objCase.addError(STR_ERROR_NO_PROGRAM);
          continue;
        }
        if (objCase.UAC_requiresPlacementRequest__c == false) {
          objCase.UAC_placementDesignationDateTime__c = Datetime.now();
          if (objCase.UAC_tech1stplacementDesignationDateTime__c == null) {
            objCase.UAC_tech1stplacementDesignationDateTime__c =
                objCase.UAC_placementDesignationDateTime__c;
          }
        }
        if (objOldCase.Status == strPlacementRequestedStatus
            || objCase.UAC_requiresPlacementRequest__c) {
          lstOfAcceptPlacement.add(objCase);
        }
      } else if (objCase.Status == 'Processed Pending'
          && objOldCase.Status == strPlacementMatchUnderReviewStatus
          && objCase.UAC_programFacility__c != null
          && objCase.UAC_requiresPlacementRequest__c == false) {
        // issam-2502
        objCase.UAC_programFacility__c = null;
        objCase.UAC_programType__c = '';
      }
      if (objCase.Status == strPlacementDesignatedStatus
          || objCase.Status == strPlacementRequestedStatus
          || objCase.Status == strPlacementNotAcceptedStatus
          || objOldCase.Status == strPlacementDesignatedStatus) {
        lstCasesForAutoBed.add(objCase);
      }
      setOfUACs.add(objCase.ContactId);
      setParentIds.add(objCase.Id);

      // Check for Cases with status changed to Supervisor Approval Requested and validate
      if (objCase.Status == strSupervisorApprovalRequestedStatus) {
        setCaseIds.add(objCase.Id);
        lstCasesForSupervisorApproval.add(objCase);
      }

      // Check for Cases with status changed to Supervisor Approved and validate
      if (objCase.Status == strSupervisorApprovedStatus) {
        lstCasesForSupervisorApproved.add(objCase);
      }
    }

    if (!lstCasesForSupervisorApproval.isEmpty()) {
      validateSupervisorApprovalRequestedStatus(lstCasesForSupervisorApproval, setCaseIds);
    }
    if (!lstCasesForSupervisorApproved.isEmpty()) {
      validateSupervisorApprovedStatus(lstCasesForSupervisorApproved);
    }
    if (boolFirstTriggerRun) {
      boolFirstTriggerRun = false;
      UAC_assetService newService = new UAC_assetService();
      // DML update on Asset (Chains to Account), also calls addError on Case
      newService.handleReferralAssetUpdates(lstCasesForAutoBed, mapOldCases);
    }
    if (!lstOfPlacementNotAccepted.isEmpty()) {
      doNotAcceptPlacements(lstOfPlacementNotAccepted);
    }
    if (!lstOfAcceptPlacement.isEmpty()) {
      AcceptPlacements(lstOfAcceptPlacement);
    }
    if (!lstOfCaseForRelatedUACCheck.isEmpty()) {
      // DML update on Case (Rare scenario)
      populateRelatedUACsPlacedTogether(lstOfCaseForRelatedUACCheck, setOfUACsForRelatedUACCheck);
    }
    if (!mapOfReProcessedReferrals.isEmpty()) {
      referralReProcessedClearProgram(mapOfReProcessedReferrals.values());
    }
  }

  /**
   * @description ORRUAC-1061 - generic method to handle Referral update
   *methods.
   * @author James Qian (Deloitte) 6/18/20
   * @param Map<Id, Case> mapNewCases
   * @param Map<Id, Case> mapOldCases
   * @return void
   **/
  public
  static void processReferralsAfterUpdate(Map<Id, Case> mapNewCases, Map<Id, Case> mapOldCases) {
    // Instantiate Collections for Passing to Methods
    List<Case> lstCasesForDesignationEmail = new List<Case>();
    List<Case> lstCasesForEmailAndSharing = new List<Case>();
    List<Case> lstCasesForUACStatusChange = new List<Case>();
    List<Case> lstCasesForATMDelete = new List<Case>();
    List<Case> lstCasesForCancellation = new List<Case>();
    List<Case> lstCasesForDesignationReversal = new List<Case>();
    Set<String> setAccountIdsForATMDelete = new Set<String>();
    Set<String> setAccountIdsForATM = new Set<String>();
    Set<Id> setOfUACs = new Set<Id>();
    Set<Id> setParentIds = new Set<Id>();
    Set<Id> setReferralsForCheckingAdmissionUpdates = new Set<Id>();
    Set<Id> setOfReferralsForReProcessing = new Set<Id>();
    Set<Id> setOfProfilesForReprocessing = new Set<Id>();

    // Loop through Cases, filter, and add to Collections
    for (Case objCase : mapNewCases.values()) {
      Case objOldCase = mapOldCases.get(objCase.Id);
      if (objCase.Status == objOldCase.Status) {
        continue;
      }
      setOfUACs.add(objCase.ContactId);
      setParentIds.add(objCase.Id);
      if (objCase.Status == strPlacementNotAcceptedStatus) {
        lstCasesForATMDelete.add(objCase);
        setAccountIdsForATMDelete.add(objCase.UAC_programFacility__c);
      } else if (objCase.Status == strPlacementDesignatedStatus) {
        // REFACTOR
        contact recCon = new contact();
        recCon.Id = objCase.ContactId;
        recCon.UAC_program__c = objCase.UAC_programFacility__c;
        recCon.UAC_programType__c = objCase.UAC_programType__c;
        mapContactsToUpdate.put(recCon.Id, recCon);
        lstCasesForDesignationEmail.add(objCase);
        setReferralsForCheckingAdmissionUpdates.add(objCase.Id);
      } else if (objCase.Status == strPlacementRequestedStatus) {
        lstCasesForEmailAndSharing.add(objCase);
        setAccountIdsForATM.add(objCase.UAC_programFacility__c);
      } else if (objCase.Status == 'Referral Cancelled') {
        lstCasesForCancellation.add(objCase);
      }
      if (objCase.Status == strProcessedPendingStatus
          && objOldCase.Status == strPlacementDesignatedStatus) {
        setOfReferralsForReProcessing.add(objCase.Id);
        setOfProfilesForReprocessing.add(objCase.ContactId);
      } else if (objCase.Status == strNewPendingStatus
          || objCase.Status == strProcessedPendingStatus
          || objCase.Status == strReferralCancelledStatus
          || objCase.Status == strPlacementDesignatedStatus) {
        lstCasesForUACStatusChange.add(objCase);
      }
      if (objCase.Status != objOldCase.Status
          && objOldCase.Status == strPlacementDesignatedStatus) {
        lstCasesForDesignationReversal.add(objCase);
      }
    }

    if (!lstCasesForATMDelete.isEmpty()) {
      // DML Delete on AccountTeamMember, DML delete on CaseTeamMember
      CaseTeamRemovalForPlacementNotAccepted(
          lstCasesForATMDelete, setAccountIdsForATMDelete, setOfUACs, setParentIds);
    }

    if (!lstCasesForDesignationEmail.isEmpty()) {

      createGroupEmailRecords(lstCasesForDesignationEmail);  // DML insert on Group Email
      UC_newAdmissionEntry asyncAdEntry = new UC_newAdmissionEntry(lstCasesForDesignationEmail,
          mapNewCases);  // New Async process to create Ad Entries per ORRUAC-5560
      Id jobID = System.enqueueJob(asyncAdEntry);
      // UAC_CaseTriggerHelper.newAdmissionEntry(lstCasesForDesignationEmail, mapNewCases); // DML
      // insert on Case (Admission), DML insert on Case Team
      updateContactProgramUAC(lstCasesForDesignationEmail);  ////ORRUAC-2020
      if (!System.isFuture()) {
        updateAdmissionEntryPrograms(setReferralsForCheckingAdmissionUpdates);
      }
    }
    if (!lstCasesForCancellation.isEmpty()) {
      processCancelledReferrals(lstCasesForCancellation);
    }

    if (!lstCasesForEmailAndSharing.isEmpty()) {
      // DML insert on Group Email
      createGroupEmailRecordsForPlacementRequested(lstCasesForEmailAndSharing, setAccountIdsForATM);
      // DML insert on AccountTeamMember, DML insert on CaseTeamMember
      CaseTeamforPlacementRequested(lstCasesForEmailAndSharing, setAccountIdsForATM, setOfUACs);
    }
    if (!lstCasesForDesignationReversal.isEmpty()) {
      referralNotDesignated(lstCasesForDesignationReversal, setOfUACs);
    }

    if (!lstCasesForUACStatusChange.isEmpty()) {
      // Does DML update on Contact
      UAC_CaseTriggerHelper.syncContactStatusWithCaseStatusReferral(
          lstCasesForUACStatusChange, mapContactsToUpdate, false);
    }
    if (!setOfReferralsForReProcessing.isEmpty()) {
      referralReProcessedHelper(setOfReferralsForReProcessing, setOfProfilesForReprocessing);
    }
  }

  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will iterate through the list of existing matched
   *Cases and find the matched newly inserted Case(s) to reject it if status
   *of the existing Case is New Pending, Processed Pending, or Placement
   *Designated
   * @param        lstOfExistingMatchedCases: List of existing matched Case;
   *mapOfNewCasesByANumber: map of newly inserted Cases
   * @return       Void
   */
  public
  static void rejectDuplicatePendingReferrals(
      List<Case> lstOfExistingMatchedCases, Map<String, List<Case>> mapOfNewCasesByANumber) {
    if (lstOfExistingMatchedCases.isEmpty()) {
      return;
    }
    for (Case objMatchedCase : lstOfExistingMatchedCases) {
      if ((objMatchedCase.Contact.UAC_status__c == strNewPendingStatus
              || objMatchedCase.Contact.UAC_status__c == strProcessedPendingStatus
              || objMatchedCase.Contact.UAC_status__c == strPlacementDesignatedStatus)
          && mapOfNewCasesByANumber.containsKey(objMatchedCase.UAC_aNum__c)) {
        for (Case objMapCase : mapOfNewCasesByANumber.get(objMatchedCase.UAC_aNum__c)) {
          UAC_errorLog.platformEventErrorLog(strErrorMessage,
              String.valueOf(objMatchedCase.Id),
              'Rejected duplicate pending referral',
              'UAC_CaseTriggerHelper.rejectDuplicatePendingReferrals');
          objMapCase.addError(strErrorMessage);
        }
      }
    }
  }
  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will iterate through the map of existing matched
   *Cases, if the contact status is not one of the following: New Pending,
   *Processed Pending, Placement Designated, Admitted, or In transfer. Then
   *the method will update the following fields on the associated contact:
   *Previous Referral DateTime(s), Previous Case ID(s), and Returning UAC?
   *Where Previous Referral DateTime(s), Previous Case ID(s) are a
   *consolidated string of the values for the fields Referral DateTime and
   *Case ID found on the existing list of Case records for that A# upto 255
   *characters.
   * @param        lstOfExistingMatchedCases: List of existing matched Case;
   *mapOfNewCasesByANumber: map of newly inserted Cases
   * @return       Void
   */
  public
  static void processReturningUACReferrals(
      List<Case> lstOfExistingMatchedCases, Map<String, List<Case>> mapOfNewCasesByANumber) {
    Map<String, List<Case>> mapOfExistingCasesByANumber = new Map<String, List<Case>>();
    List<Contact> lstContactsToUpdate = new List<Contact>();

    // Construct map of existing Case records by A#
    for (Case objCase : lstOfExistingMatchedCases) {
      List<Case> lstCase = new List<Case>();
      if (mapOfExistingCasesByANumber.containsKey(objCase.UAC_aNum__c)) {
        lstCase = mapOfExistingCasesByANumber.get(objCase.UAC_aNum__c);
      }
      lstCase.add(objCase);
      mapOfExistingCasesByANumber.put(objCase.UAC_aNum__c, lstCase);
    }

    for (String strANumber : mapOfExistingCasesByANumber.keySet()) {
      String strPreviousReferralDateTimes = '';
      String strPreviousCaseIDs = '';
      String strPreviousProgram = '';

      String strContactStatus =
          mapOfExistingCasesByANumber.get(strANumber)[0].Contact.UAC_status__c;
      if (strContactStatus != strNewPendingStatus && strContactStatus != strProcessedPendingStatus
          && strContactStatus != strPlacementDesignatedStatus
          && strContactStatus != strAdmittedStatus && strContactStatus != strInTransferStatus) {
        Contact objMatchedContact = new Contact();
        objMatchedContact.Id = mapOfExistingCasesByANumber.get(strANumber)[0].ContactId;

        for (Case objMapMatchedCase : mapOfExistingCasesByANumber.get(strANumber)) {
          strPreviousReferralDateTimes = strPreviousReferralDateTimes
              + String.valueOf(objMapMatchedCase.UAC_referralDateTime__c) + ';';
          strPreviousCaseIDs = strPreviousCaseIDs + objMapMatchedCase.CaseNumber + ';';
        }

        objMatchedContact.UAC_previousReferralDateTime__c = strPreviousReferralDateTimes.left(255);
        objMatchedContact.UAC_previousCaseID__c = strPreviousCaseIDs.left(255);
        objMatchedContact.UAC_previousProgramPlacement__c =
            String.isBlank(strPreviousProgram) ? 'None ' : strPreviousProgram.left(255);
        objMatchedContact.UAC_returningUAC__c = 'Yes';
        mapContactsToUpdate.put(objMatchedContact.Id, objMatchedContact);
      } else {
        for (Case objMapMatchedCase : mapOfNewCasesByANumber.get(strANumber)) {
          UAC_errorLog.platformEventErrorLog(
              strErrorMessage, String.valueOf(mapOfExistingCasesByANumber.get(strANumber)[0].Id),'', 'UAC_CaseTriggerHelper.processReturningUACReferrals');
          objMapMatchedCase.addError(strErrorMessage);
        }
      }
    }
  }
  /**
   * @author       James Qian (Deloitte)
   * @description  Sets referral date to ContactDOB if the A# contains A, B,
   * or C.
   * @param        List of newly inserted Cases
   * @return       Void
   */
  private
  static void setReferralDateForNewborn(List<Case> listReferrals) {
    Map<Id, Date> mapContactIdToBirthdate = new Map<Id, Date>();
    for (Case CaseCurrent : listReferrals) {
      mapContactIdToBirthdate.put(CaseCurrent.ContactId, null);
    }
    for (Contact contactCurrent :
        [SELECT Id, Birthdate FROM Contact WHERE Id IN:mapContactIdToBirthdate.keyset()]) {
      mapContactIdToBirthdate.put(contactCurrent.Id, contactCurrent.Birthdate);
    }
    for (Case CaseCurrent : listReferrals) {
      if (mapContactIdToBirthdate.get(CaseCurrent.ContactId) != null) {
        Date dateDob = mapContactIdToBirthdate.get(CaseCurrent.ContactId);
        CaseCurrent.UAC_referralDateTime__c =
            Datetime.newInstance(dateDob.year(), dateDob.month(), dateDob.day());
      }
    }
  }
  /**
   * @description ORRUAC-39: Capture Initial Health Information
   * @author Abhisek Pati (Deloitte) | 6/17/2020
   * @param mapNewCases Trigger.NewMap
   * @return void
   **/

  public
  static void createInitialHealthInformation(Map<Id, Case> mapNewCases) {
    if (mapNewCases.isEmpty()) {
      return;
    }
    String strNo = 'No';
    Id idRecordType =
        Schema.SObjectType.UAC_referralRelatedRecord__c.getRecordTypeInfosByDeveloperName()
            .get('UAC_initialHealthInformation')
            .getRecordTypeId();
    List<UAC_referralRelatedRecord__c> listIHIToInsert = new List<UAC_referralRelatedRecord__c>();

    for (Case CaseCurrent : mapNewCases.values()) {
      listIHIToInsert.add(new UAC_referralRelatedRecord__c(UAC_referral__c = CaseCurrent.Id, RecordTypeId = idRecordType
          /*,UAC_medicalHealthConcerns__c = strNo,
          UAC_exposuretoInfectiousDiseaseNew__c = strNo,
          UAC_mentalConcerns__c = strNo,
          UAC_dentalHealthConcernsRR__c = strNo,
          UAC_prescribedMedicationNew__c = strNo,
          UAC_clearedforAirTravelRR__c = strNo,
          UAC_clearedforGroundTravelRR__c = strNo*/));
    }
    if (!listIHIToInsert.isEmpty()) {
      insert listIHIToInsert;
    }
  }
  /** @description ORRUAC-1620-Updates to UAC Profile after insert
   * @author Issam Awwad (Deloitte) 7/28/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void processNewUACReferrals(Map<Id, Case> mapNewCases) {
    List<Contact> lstProfilesToUpdate = new List<Contact>();
    for (Case objCase : mapNewCases.values()) {
      Contact objProfile = getContactFromMapToUpdate(objCase.ContactId);
      objProfile.UAC_inORRCare__c = 'Yes';
      mapContactsToUpdate.put(objProfile.Id, objProfile);
    }
  }
  /** @description ORRUAC-1620-Updates to UAC Profile after update. Previously called
   * processUpdatedUACReferrals
   * @author Issam Awwad (Deloitte) 7/28/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void processCancelledReferrals(List<Case> lstCancelledReferrals) {
    for (Case objCase : lstCancelledReferrals) {
      Contact objProfile = getContactFromMapToUpdate(objCase.ContactId);
      objProfile.UAC_inORRCare__c = 'No';
      mapContactsToUpdate.put(objProfile.Id, objProfile);
    }
  }
  /**
   * @description OORRUAC-65- Method to Update the Case fields
   *record
   * @author Chaitanya Nandamuri (Deloitte) | 06/01/2020
   * @param
   * @return void
   **/
  private
  static void updateFieldsforStandardPlacements(
      List<Id> lstOfProgramAccountId, List<Case> lstOfCasetoUpdateFields) {
    Map<Id, string> mapOfRelatedProgramIdtoType = new Map<id, string>();
    if (!lstOfProgramAccountId.isEmpty()) {
      for (account objAcc : [select id, Type from account where id In:lstOfProgramAccountId]) {
        mapOfRelatedProgramIdtoType.put(objAcc.id, objAcc.Type);
      }
    }
    if (!lstOfCasetoUpdateFields.isEmpty()) {
      for (Case recCase : lstOfCasetoUpdateFields) {
        recCase.UAC_programType__c =
            mapOfRelatedProgramIdtoType.get(recCase.UAC_programFacility__c);
        if (recCase.UAC_requiresPlacementRequest__c) {
          recCase.Status = strPlacementRequestedStatus;
          recCase.UAC_PlacementRequestedDateTime__c = Datetime.now();
        } else {
          recCase.Status = strPlacementMatchUnderReviewStatus;
        }
      }
    }
  }
  /**
   * @description ORRUAC-2728 - populate UAC_relatedUACsPlacedTogether__c field on entry
   * @author Issam Awwad (Deloitte) 10/7/20
   * @param List<Case> lstOfCasetoUpdateFields, Set<Id> setOfUACsForRelatedUACCheck
   * @return void
   **/
  public
  static void populateRelatedUACsPlacedTogether(
      List<Case> lstOfCasetoUpdateFields, Set<Id> setOfUACsForRelatedUACCheck) {
    List<Contact> lstOfUACs =
        [SELECT Id, UAC_relatedToOtherUAC__c FROM Contact WHERE Id IN:setOfUACsForRelatedUACCheck];
    Set<Id> setOfRelatedUACs = new Set<Id>();
    Map<String, List<Case>> mapOfUACToRelatedUACs = new Map<String, List<Case>>();
    Map<Id, String> mapOfRelatedUACsToUAC = new Map<Id, String>();
    Map<Id, Contact> mapOfUACs = new Map<Id, Contact>();
    Map<Id, Case> mapCasesInTriggerNew = new Map<Id, Case>();
    List<Case> lstOfRelatedCasesToUpdate = new List<Case>();

    for (Case objCase : lstOfCasetoUpdateFields) {
      mapCasesInTriggerNew.put(objCase.ContactId, objCase);
    }
    for (Contact objContact : lstOfUACs) {
      mapOfUACs.put(objContact.Id, objContact);
    }
    List<UAC_apprehendedRelationship__c> lstOfRelatedUACs = [
      SELECT Id,
      Name,
      UAC_uacLookup__c,
      UAC_relatedUAC__c FROM UAC_apprehendedRelationship__c WHERE UAC_uacLookup__c
      IN:setOfUACsForRelatedUACCheck AND RecordType.DeveloperName
       =:Label.UAC_apprehendedUACRecordType
    ];
    for (UAC_apprehendedRelationship__c objRelationship : lstOfRelatedUACs) {
      if (String.isBlank(objRelationship.UAC_relatedUAC__c)) {
        lstOfCasetoUpdateFields[0].addError(Label.UAC_missingRelatedLookup1 + ' '
            + objRelationship.Name + ' ' + Label.UAC_missingRelatedLookup2);
      }
      setOfRelatedUACs.add(objRelationship.UAC_relatedUAC__c);
      mapOfRelatedUACsToUAC.put(
          objRelationship.UAC_relatedUAC__c, objRelationship.UAC_uacLookup__c);
    }
    List<Case> lstOfRelatedUACsProfile = [
      SELECT Id,
      UAC_programFacility__c,
      UAC_relatedUACsPlacedTogetherHelper__c,
      ContactId FROM Case WHERE ContactId IN:setOfRelatedUACs AND recordType.DeveloperName
                                           =:Label.UAC_referralRecordTypeName
    ];
    for (Case objCase : lstOfRelatedUACsProfile) {
      List<Case> lstOfContactsTemp = new List<Case>();
      String strUACId = mapOfRelatedUACsToUAC.get(objCase.ContactId);
      if (mapOfUACToRelatedUACs.containsKey(strUACId)) {
        lstOfContactsTemp = mapOfUACToRelatedUACs.get(strUACId);
        lstOfContactsTemp.add(objCase);
        mapOfUACToRelatedUACs.put(strUACId, lstOfContactsTemp);
      } else {
        lstOfContactsTemp.add(objCase);
        mapOfUACToRelatedUACs.put(strUACId, lstOfContactsTemp);
      }
    }
    for (Case objCase : lstOfCasetoUpdateFields) {
      if (mapOfUACs.get(objCase.ContactId).UAC_relatedToOtherUAC__c == 'Yes'
          && mapOfUACToRelatedUACs.containsKey(objCase.ContactId)) {
        objCase.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
        for (Case objRelatedCase : mapOfUACToRelatedUACs.get(objCase.ContactId)) {
          if (mapCasesInTriggerNew.containsKey(objRelatedCase.ContactId)) {
            Case objExistingCase = mapCasesInTriggerNew.get(objRelatedCase.ContactId);
            if (objExistingCase.UAC_programFacility__c == objCase.UAC_programFacility__c) {
              objCase.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
            } else {
              objCase.UAC_relatedUACsPlacedTogetherHelper__c = 'No';
            }
          } else {
            if (objRelatedCase.UAC_programFacility__c == objCase.UAC_programFacility__c) {
              objCase.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
              objRelatedCase.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
            } else {
              objCase.UAC_relatedUACsPlacedTogetherHelper__c = 'No';
              objRelatedCase.UAC_relatedUACsPlacedTogetherHelper__c = 'No';
            }
            if (!setOfUACsForRelatedUACCheck.contains(objRelatedCase.ContactId)) {
              lstOfRelatedCasesToUpdate.add(objRelatedCase);
            }
          }
        }
      } else {
        objCase.UAC_relatedUACsPlacedTogetherHelper__c = '';
      }
    }

    if (!lstOfRelatedCasesToUpdate.isEmpty()) {
      try {
        update lstOfRelatedCasesToUpdate;
      } catch (DMLException e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
        // throw new UAC_errorLog.CustomException('Error updating related uac Cases ');
      }
    }
  }
  /**
   * @description ORRUAC-2502 - Create Case Team member for receiving program on placement requested
   * @author Issam Awwad (Deloitte) | 09/21/2020
   * @param List<Case> CaseList, Set<String> setAccountIdsForATM
   * @
   **/
  private
  static void CaseTeamforPlacementRequested(
      List<Case> admissionEntry, Set<String> setAccountIdsForATM, Set<Id> setOfUACs) {
    CaseTeamRole objCaseManagerTeamRole =
        [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'Case Manager'];
    CaseTeamRole objLeadCaseManagerTeamRole =
        [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'Lead Case Manager'];
    Map<Id, List<AccountTeamMember>> mapOfAccountToATM = new Map<Id, List<AccountTeamMember>>();
    List<CaseTeamMember> LstCaseTeamMember = new List<CaseTeamMember>();
    List<AccountTeamMember> lstAccountTeamMembers = new List<AccountTeamMember>();
    List<Contact> lstOfUACs = [SELECT Id, AccountId FROM Contact WHERE Id IN:setOfUACs];
    Map<Id, Id> mapOfUACToAccount = new Map<Id, Id>();

    List<AccountTeamMember> lstATM =
        [SELECT Id, TeamMemberRole, AccountId, UserId FROM AccountTeamMember where AccountId
          in:setAccountIdsForATM AND(TeamMemberRole = 'Lead Case Manager' OR TeamMemberRole =
                                         'Case Manager') ORDER BY TeamMemberRole ASC];
    for (Contact objUAC : lstOfUACs) {
      mapOfUACToAccount.put(objUAC.Id, objUAC.AccountId);
    }

    for (AccountTeamMember objATM : lstATM) {
      List<AccountTeamMember> lstTempATM = new List<AccountTeamMember>();
      if (mapOfAccountToATM.containsKey(objATM.AccountId)) {
        lstTempATM = mapOfAccountToATM.get(objATM.AccountId);
        lstTempATM.add(objATM);
        mapOfAccountToATM.put(objATM.AccountId, lstTempATM);
      } else {
        lstTempATM.add(objATM);
        mapOfAccountToATM.put(objATM.AccountId, lstTempATM);
      }
    }

    for (Case currentCase : admissionEntry) {
      if (mapOfAccountToATM.containsKey(currentCase.UAC_programFacility__c)) {
        for (AccountTeamMember currentATM :
            mapOfAccountToATM.get(currentCase.UAC_programFacility__c)) {
          CaseTeamMember CTM = new CaseTeamMember();
          if (currentATM.TeamMemberRole == 'Lead Case Manager') {
            CTM.ParentId = currentCase.id;
            CTM.MemberId = currentATM.UserId;
            CTM.TeamRoleId = objLeadCaseManagerTeamRole.Id;
            LstCaseTeamMember.add(CTM);
            AccountTeamMember objATM = new AccountTeamMember();
            objATM.AccountId = mapOfUACToAccount.get(currentCase.ContactId);
            objATM.UserId = currentATM.UserId;
            objATM.TeamMemberRole = objLeadCaseManagerTeamRole.Name;
            objATM.AccountAccessLevel = 'Read';
            objATM.CaseAccessLevel = 'Edit';
            objATM.ContactAccessLevel = 'Read';
            lstAccountTeamMembers.add(objATM);
          } else {
            CTM.ParentId = currentCase.id;
            CTM.MemberId = currentATM.UserId;
            CTM.TeamRoleId = objCaseManagerTeamRole.Id;
            LstCaseTeamMember.add(CTM);
            AccountTeamMember objATM = new AccountTeamMember();
            objATM.AccountId = mapOfUACToAccount.get(currentCase.ContactId);
            objATM.UserId = currentATM.UserId;
            objATM.TeamMemberRole = objCaseManagerTeamRole.Name;
            objATM.AccountAccessLevel = 'Read';
            objATM.CaseAccessLevel = 'Edit';
            objATM.ContactAccessLevel = 'Read';
            lstAccountTeamMembers.add(objATM);
          }
        }
      }
    }
    if (!LstCaseTeamMember.isEmpty() && !lstAccountTeamMembers.isEmpty()) {
      try {
        insert LstCaseTeamMember;
        insert lstAccountTeamMembers;
      } catch (Exception e) {
        UAC_errorLog.logError(
            e.getMessage(), '', 'Inserting Case Team Members Error', e.getStackTraceString());
      }
    }
  }
  /**
   * @description ORRUAC-2502 - Remove Case Team member on placement not accepted
   * @author Issam Awwad (Deloitte) | 09/21/2020
   * @param List<Case> CaseList, Set<String> setAccountIdsForATM
   * @
   **/
  private
  static void CaseTeamRemovalForPlacementNotAccepted(List<Case> admissionEntry,
      Set<String> setAccountIdsForATM,
      Set<Id> setOfUACs,
      Set<Id> setParentIds) {
    List<Contact> lstOfUACs = [SELECT Id, AccountId FROM Contact WHERE Id IN:setOfUACs];
    CaseTeamRole objCaseTeamRole = [SELECT Id FROM CaseTeamRole WHERE Name = 'Read Only'];
    Set<Id> setOfMemberIds = new Set<Id>();
    Set<Id> setOfAccountIds = new Set<Id>();

    for (Contact objContact : lstOfUACs) {
      setOfAccountIds.add(objContact.AccountId);
    }

    List<AccountTeamMember> lstATM =
        [SELECT Id, TeamMemberRole, AccountId, UserId FROM AccountTeamMember where AccountId
          in:setAccountIdsForATM AND(TeamMemberRole = 'Lead Case Manager' OR TeamMemberRole =
                                         'Case Manager') ORDER BY TeamMemberRole ASC];

    for (AccountTeamMember objATM : lstATM) {
      setOfMemberIds.add(objATM.UserId);
    }

    List<CaseTeamMember> LstCaseTeamMember =
        [SELECT id FROM CaseTeamMember WHERE MemberId IN:setOfMemberIds AND ParentId
                                                      IN:setParentIds];
    List<AccountTeamMember> lstAccountTeamMemberToDelete =
        [SELECT id FROM AccountTeamMember WHERE UserId IN:setOfMemberIds AND AccountId
                                                       IN:setOfAccountIds];
    if (!LstCaseTeamMember.isEmpty() && !lstAccountTeamMemberToDelete.isEmpty()) {
      try {
        delete LstCaseTeamMember;
        delete lstAccountTeamMemberToDelete;
      } catch (Exception e) {
        UAC_errorLog.logError(
            e.getMessage(), '', 'Deleting Case Team Members Error', e.getStackTraceString());
      }
    }
  }
  /**
   * @description ORRUAC-80- Method to validate fields are populated for
   *supervisor approval requested record
   * @author Issam Awwad (Deloitte) | 06/26/2020
   * @param lstCasesForSupervisorApproval: Cases with status change to
   *supervisor approval requested
   * @param setCaseIds: Case ids for Cases with status change to supervisor
   *approval requested
   * @return void
   **/
  private
  static void validateSupervisorApprovalRequestedStatus(
      List<Case> lstCasesForSupervisorApproval, Set<String> setCaseIds) {
    Set<Id> setMatchedCaseIds = new Set<Id>();
    for (UAC_referralRelatedRecord__c objReferralRelated : [
           Select id,
           UAC_referral__c from UAC_referralRelatedRecord__c where UAC_referral__c
           IN:setCaseIds AND RecordType.DeveloperName
            =:Label.UAC_referralRelatedRecordTypeIPC
         ]) {
      setMatchedCaseIds.add(objReferralRelated.UAC_referral__c);
    }
    for (Case objCase : lstCasesForSupervisorApproval) {
      if ((!setMatchedCaseIds.contains(objCase.Id))
          || objCase.UAC_RequiresPlacementChecklist__c == false
          || objCase.UAC_ffsSupervisor__c == null) {
        objCase.addError(strSupervisorApprovalRequestedError);
      }
      objCase.UAC_specialPlacementInitiatedDateTime__c = System.now();
    }
  }
  /**
   * @description ORRUAC-82- Method to validate fields are populated for
   *supervisor approved record
   * @author Issam Awwad (Deloitte) | 06/29/2020
   * @param lstCasesForSupervisorApproval: Cases with status change to
   *supervisor approval requested
   * @return void
   **/
  private
  static void validateSupervisorApprovedStatus(List<Case> lstCasesForSupervisorApproved) {
    Id IntakeTeamProfile = [select id from Profile where name = 'Intakes Team' limit 1].id;

    for (Case objCase : lstCasesForSupervisorApproved) {
      if (Userinfo.getProfileId() == IntakeTeamProfile && objCase.UAC_RequiresPlacementChecklist__c
          && (String.isBlank(objCase.UAC_specialPlacementNotes__c)
              || String.isBlank(objCase.UAC_finalPlacementDetermination__c))) {
        objCase.addError(strSupervisorApprovedError);
      }
      objCase.UAC_specialPlacementDecisionDateTime__c = System.now();
    }
  }
  /**
   * @description OORRUAC-67- Method to Update the Case fields
   *record
   * @author Chaitanya Nandamuri (Deloitte) | 06/01/2020
   * @param
   * @return void
   **/
  public
  static void doNotAcceptPlacements(List<Case> lstCase) {
    for (Case objCase : lstCase) {
      if (String.isBlank(objCase.UAC_NotAcceptedReason__c)) {
        objCase.UAC_NotAcceptedReason__c.adderror(
            'Please select at least one reason under Not Accepted Reason for not accepting placement');
      } else {
        objCase.UAC_programFacility__c = null;
        objCase.UAC_programType__c = null;
        objCase.UAC_placementDecisionDateTime__c = Datetime.now();
      }
    }
  }
  /**
   * @description OORRUAC-68- Method to Placement Designated UAC
   *record
   * @author Chaitanya Nandamuri (Deloitte) | 06/03/2020
   * @param
   * @return void
   **/
  public
  static void AcceptPlacements(List<Case> lstofCase) {
    Id IntakeTeamProfile = [select id from Profile where name = 'Intakes Team' limit 1].id;
    for (Case objCase : lstofCase) {
      objCase.UAC_placementDecisionDateTime__c = Datetime.now();
      objCase.UAC_placementDesignationDateTime__c = Datetime.now();
      if (Userinfo.getProfileId() == IntakeTeamProfile
          && String.isBlank(objCase.UAC_placementNotes__c)) {
        objCase.UAC_placementNotes__c.adderror(
            'Please enter in notes under Placement Notes for placement decision.');
      }
    }
  }
  /**
   * @description ORRUAC-86 - Placement Designated Email
   * @author James Qian (Deloitte) | 06/18/2020
   * @param List<Case> CaseList
   * @return void
   **/
  private
  static void createGroupEmailRecords(List<Case> CaseList) {
    Map<Id, List<Case>> mapProgramToListCases = new Map<Id, List<Case>>();
    for (Case CaseCurrent : CaseList) {
      List<Case> listCases;
      if (mapProgramToListCases.containsKey(CaseCurrent.UAC_programFacility__c)) {
        listCases = mapProgramToListCases.get(CaseCurrent.UAC_programFacility__c);
      } else {
        listCases = new List<Case>();
      }
      listCases.add(CaseCurrent);
      mapProgramToListCases.put(CaseCurrent.UAC_programFacility__c, listCases);
    }
    if (!mapProgramToListCases.isEmpty()) {
      Map<Id, Account> mapIdToAccountDetails =
          queryParentAccountsForReferralPlacements(mapProgramToListCases.keyset());
      List<UAC_groupEmail__c> groupEmailsToInsert = new List<UAC_groupEmail__c>();
      for (Id programId : mapProgramToListCases.keyset()) {
        String emailBody = constructEmailBodyForPlacement(
            mapIdToAccountDetails.get(programId), mapProgramToListCases.get(programId));
        UAC_groupEmail__c emailNew = new UAC_groupEmail__c(UAC_body__c = emailBody,
            UAC_recipient1__c = Label.UAC_intakesTransportationEmail1,
            UAC_recipient2__c = Label.UAC_intakesTransportationEmail2,
            UAC_subject__c = Label.UAC_referralEmailSubject,
            UAC_type__c = 'Referral',
            UAC_from__c = 'Intakes Team');
        if (String.isNotBlank(
                mapIdToAccountDetails.get(programId).UAC_IntakesPrimaryContactEmail__c)) {
          emailNew.UAC_recipient3__c =
              mapIdToAccountDetails.get(programId).UAC_IntakesPrimaryContactEmail__c;
        }
        if (String.isNotBlank(
                mapIdToAccountDetails.get(programId).UAC_intakesSecondaryContactUserEmail__c)) {
          emailNew.UAC_recipient4__c =
              mapIdToAccountDetails.get(programId).UAC_intakesSecondaryContactUserEmail__c;
        }
        groupEmailsToInsert.add(emailNew);
      }
      insert groupEmailsToInsert;
    }
  }

  /**
   * @description ORRUAC-86 - Constructs email body for Placement Designation
   * @author James Qian (Deloitte) | 06/18/2020
   * @param Account accountProgram
   * @param List<Case> listCases
   * @return String
   **/
  private
  static String constructEmailBodyForPlacement(Account accountProgram, List<Case> listCases) {
    String emailBody = Label.UAC_referralEmailHeader1 + accountProgram.Name + ' '
        + accountProgram.Type + Label.UAC_referralEmailHeader2
        + accountProgram.UAC_IntakesPrimaryContact__c;
    if (String.isNotBlank(accountProgram.UAC_IntakesPrimaryContactPhone__c)) {
      emailBody += ', ' + accountProgram.UAC_IntakesPrimaryContactPhone__c;
    }
    emailBody += Label.UAC_emailBodyAddress + accountProgram.ShippingStreet + '<br>'
        + accountProgram.ShippingCity + ', ' + accountProgram.ShippingState + ' '
        + accountProgram.ShippingPostalCode + '<br>';
    emailBody +=
        Label.UAC_emailBodyUACDropOffInfo + ' ' + accountProgram.UAC_uacDropOffInformation__c;
    emailBody += Label.UAC_referralEmailHeader3;
    for (Case CaseCurrent : listCases) {
      emailBody += Label.UAC_referralEmailPreRow;
      emailBody += generateEmailTableCell(CaseCurrent.UAC_aNum__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_firstName__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_lastName__c);
      emailBody += generateEmailTableCell(String.valueOf(CaseCurrent.UAC_dateOfBirth__c));
      emailBody += generateEmailTableCell(CaseCurrent.UAC_gender__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_countryOfBirth__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_referringSector__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_transportationNotes__c);
      emailBody += Label.UAC_referralEmailPostRow;
    }
    emailBody += Label.UAC_referralEmailFooter;
    return emailBody;
  }

  /**
   * @description ORRUAC-86 - Constructs table cell for individual field value
   * @author James Qian (Deloitte) | 06/18/2020
   * @param String content
   * @return String
   **/
  private
  static String generateEmailTableCell(String content) {
    return Label.UAC_referralEmailPreCellTitle + content + Label.UAC_referralEmailPreCell + content
        + Label.UAC_referralEmailPostCell;
  }

  /**
   * @description ORRUAC-86 - Queries parent Accounts to get details for email
   *merge fields.
   * @author James Qian (Deloitte) | 06/18/2020
   * @param Set<Id> setAccountIds
   * @return Map<Id, Account>
   **/
  private
  static Map<Id, Account> queryParentAccountsForReferralPlacements(Set<Id> setAccountIds) {
    return new Map<Id, Account>([SELECT Id,
      Name,
      UAC_IntakesPrimaryContact__c,
      UAC_IntakesPrimaryContactPhone__c,
      UAC_IntakesPrimaryContactEmail__c,
      UAC_intakesSecondaryContactUserEmail__c,
      Type,
      ShippingStreet,
      ShippingCity,
      ShippingState,
      ShippingPostalCode,
      UAC_uacDropOffInformation__c FROM Account WHERE Id IN:setAccountIds]);
  }
  /**
   * @description ORRUAC-2502 - Placement Requested Email
   * @author Issam Awwad (Deloitte) | 09/21/2020
   * @param List<Case> CaseList
   * @return void
   **/
  private
  static void createGroupEmailRecordsForPlacementRequested(
      List<Case> CaseList, Set<String> setAccountIdsForATM) {
    Map<Id, List<Case>> mapProgramToListCases = new Map<Id, List<Case>>();
    for (Case CaseCurrent : CaseList) {
      List<Case> listCases;
      if (mapProgramToListCases.containsKey(CaseCurrent.UAC_programFacility__c)) {
        listCases = mapProgramToListCases.get(CaseCurrent.UAC_programFacility__c);
      } else {
        listCases = new List<Case>();
      }
      listCases.add(CaseCurrent);
      mapProgramToListCases.put(CaseCurrent.UAC_programFacility__c, listCases);
    }
    List<Account> lstAccount = [select id,
      UAC_IntakesPrimaryContactEmail__c,
      UAC_intakesSecondaryContactUserEmail__c from Account where id in:setAccountIdsForATM];

    if (!mapProgramToListCases.isEmpty()) {
      Map<Id, Account> mapIdToAccountDetails =
          queryParentAccountsForReferralPlacements(mapProgramToListCases.keyset());
      List<UAC_groupEmail__c> groupEmailsToInsert = new List<UAC_groupEmail__c>();
      for (Account objAccount : lstAccount) {
        for (Case objCase : mapProgramToListCases.get(objAccount.Id)) {
          if (objAccount.UAC_IntakesPrimaryContactEmail__c != null
              && objAccount.UAC_intakesSecondaryContactUserEmail__c != null) {
            UAC_groupEmail__c emailNew = new UAC_groupEmail__c();
            String emailBody = constructEmailBodyForPlacementRequest(
                mapIdToAccountDetails.get(objAccount.Id), mapProgramToListCases.get(objAccount.Id));
            groupEmailsToInsert.add(new UAC_groupEmail__c(UAC_body__c = emailBody,
                UAC_recipient1__c = objAccount.UAC_IntakesPrimaryContactEmail__c,
                UAC_recipient2__c = objAccount.UAC_intakesSecondaryContactUserEmail__c,
                UAC_subject__c = Label.UAC_referralPlacementEmailSubject,
                UAC_type__c = 'Referral',
                UAC_from__c = 'Intakes Team'));
          }
        }
      }
      if (!groupEmailsToInsert.isEmpty()) {
        insert groupEmailsToInsert;
      }
    }
  }
  /**
   * @description ORRUAC-2502 - Constructs email body for Placement Requested
   * @author Issam Awwad (Deloitte) | 09/21/2020
   * @param Account accountProgram
   * @param List<Case> listCases
   * @return String
   **/
  private
  static String constructEmailBodyForPlacementRequest(
      Account accountProgram, List<Case> listCases) {
    String emailBody = Label.UAC_referralPlacementEmailHeader + accountProgram.Name
        + Label.UAC_referralEmailHeader2 + accountProgram.UAC_IntakesPrimaryContact__c;
    if (String.isNotBlank(accountProgram.UAC_IntakesPrimaryContactPhone__c)) {
      emailBody += ', ' + accountProgram.UAC_IntakesPrimaryContactPhone__c;
    }
    emailBody += Label.UAC_referralEmailHeader3;
    for (Case CaseCurrent : listCases) {
      emailBody += Label.UAC_referralEmailPreRow;
      emailBody += generateEmailTableCell(CaseCurrent.UAC_aNum__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_firstName__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_lastName__c);
      emailBody += generateEmailTableCell(String.valueOf(CaseCurrent.UAC_dateOfBirth__c));
      emailBody += generateEmailTableCell(CaseCurrent.UAC_gender__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_countryOfBirth__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_referringSector__c);
      emailBody += generateEmailTableCell(CaseCurrent.UAC_transportationNotes__c);
      emailBody += Label.UAC_referralEmailPostRow;
    }
    emailBody += Label.UAC_referralEmailFooter;
    return emailBody;
  }
  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will query and return list of any Cases with
   * matching A#.
   * @param        List of newly inserted Cases
   * @return       List of existing Cases that matched with the A#
   */
  public
  static List<Case> getMatchedCasesByANumber(List<Case> lstCases) {
    List<Case> lstOfExistingMatchedCases = new List<Case>();
    set<String> setOfANumbers = new set<String>();

    for (Case objCase : lstCases) {
      setOfANumbers.add(objCase.UAC_aNum__c);
    }

    lstOfExistingMatchedCases = [SELECT Id,
      UAC_aNum__c,
      UAC_referralDateTime__c,
      CaseNumber,
      ContactId,
      Contact.UAC_status__c,
      Contact.UAC_previousReferralDateTime__c,
      Contact.UAC_previousCaseID__c,
      Contact.UAC_returningUAC__c FROM Case WHERE UAC_aNum__c
      IN:setOfANumbers ORDER BY CreatedDate DESC];

    return lstOfExistingMatchedCases;
  }
  /**
   * @description ORRUAC-2020- Method to Update the contact's current program when status
   *is changed to Placement Designated
   * @author Sarang Padhye (Deloitte) | 08/18/2020
   * @param
   * @return void
   **/
  public
  static void updateContactProgramUAC(List<Case> lstCasesForDesignationEmail) {
    if (!lstCasesForDesignationEmail.isEmpty()) {
      for (Case objCase : lstCasesForDesignationEmail) {
        Contact newContact = getContactFromMapToUpdate(objCase.ContactId);
        newContact.UAC_program__c = objCase.UAC_programFacility__c;
        // Below lines added as part of ORRUAC-2563
        newContact.UAC_admittedDateTime__C = null;
        newContact.UAC_dateTimeOfDischarge__C = null;
        newContact.UAC_techUACReferralId__c = objCase.id;
        // Originally part of ORRUAC-3165: autoPopulateLegalFieldsOnUACContact
        if (objCase.UAC_separatedFromParentsLegalGuardian__c == 'Yes') {
          newContact.UAC_separatedFromParentLegalGuardian__c = true;
        } else {
          newContact.UAC_separatedFromParentLegalGuardian__c = false;
        }
        if (objCase.UAC_currentMPP__c == 'Yes') {
          newContact.UAC_mppCase__c = true;
        } else {
          newContact.UAC_mppCase__c = false;
        }
        // Add to collection for update
        mapContactsToUpdate.put(newContact.Id, newContact);
      }
    }
  }

  /*
   * @description Returns contact from mapContactsToUpdate for DML
   * @author James Qian (Deloitte) | 3/17/2021
   * @param Id contactId
   * @return Contact
   **/
  private
  static Contact getContactFromMapToUpdate(Id contactId) {
    Contact contactToReturn;
    if (mapContactsToUpdate.containsKey(contactId)) {
      contactToReturn = mapContactsToUpdate.get(contactId);
    } else {
      contactToReturn = new Contact(Id = contactId);
    }
    return contactToReturn;
  }

  /*
   * @description Updates child admission entries to set correct program
   * @author James Qian (Deloitte) | 3/17/2021
   * @param Set<Id> setReferralIds
   * @return
   **/
  @future public static void updateAdmissionEntryPrograms(Set<Id> setReferralIds) {
    if (setReferralIds.isEmpty()) {
      return;
    }
    Map<Id, Case> mapAdmissionsToUpdate = new Map<Id, Case>();
    List<Case> listAdmissionCase = [
      SELECT Id,
      ParentId,
      UAC_programFacility__c,
      UAC_programType__c,
      Parent.UAC_programFacility__c,
      Parent.UAC_programType__c FROM Case WHERE ParentId
      IN:setReferralIds AND RecordType.DeveloperName
       =:Label.UAC_caseRecordTypeAdmission
    ];
    for (Case currentAdmission : listAdmissionCase) {
      if (currentAdmission.UAC_programFacility__c
          != currentAdmission.Parent.UAC_programFacility__c) {
        currentAdmission.UAC_programFacility__c = currentAdmission.Parent.UAC_programFacility__c;
        currentAdmission.UAC_programType__c = currentAdmission.Parent.UAC_programType__c;
        currentAdmission.UAC_placementDesignationDateTime__c = System.now();
        mapAdmissionsToUpdate.put(currentAdmission.Id, currentAdmission);
      }
    }
    if (mapAdmissionsToUpdate.isEmpty()) {
      return;
    }
    try {
      // Remove access for old program
      delete [SELECT Id FROM CaseTeamMember WHERE ParentId IN:mapAdmissionsToUpdate.keyset()];
      // Update program
      update mapAdmissionsToUpdate.values();
      // Add access for new program
      UAC_caseTriggerHelper.CaseTeamForAdmissionInsert(mapAdmissionsToUpdate.values());
    } catch (DMLException e) {
      UAC_errorLog.platformEventErrorLog(
          e.getMessage(),'', 'updateAdmissionEntryPrograms Process', e.getStackTraceString());
    }
  }

  /*
   * @description Handles contact updates when case is no longer designated
   * @author James Qian (Deloitte) | 3/17/2021
   * @param List<Case> listCasesToProcess
   * @param Set<Id> setUACIds
   * @return
   **/
  public
  static void referralNotDesignated(List<Case> listCasesToProcess, Set<Id> setUACIds) {
    if (listCasesToProcess.isEmpty()) {
      return;
    }
    Map<Id, Contact> mapContactsQueried = new Map<Id, Contact>(
        [SELECT Id, UAC_status__c, UAC_program__c, UAC_techUACReferralId__c FROM Contact WHERE Id
          IN:setUACIds]);
    Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
    for (Case currentCase : listCasesToProcess) {
      if (currentCase.ContactId == null || !mapContactsQueried.containsKey(currentCase.ContactId)) {
        continue;
      }
      Contact contactParent = mapContactsQueried.get(currentCase.ContactId);
      if (contactParent.UAC_techUACReferralId__c != currentCase.Id
          || contactParent.UAC_status__c != strPlacementDesignatedStatus) {
        currentCase.addError(strErrorDesignationReversal);
      }
      mapContactsToUpdate.put(currentCase.ContactId,
          new Contact(Id = currentCase.ContactId,
              UAC_program__c = null,
              UAC_programType__c = null,
              UAC_status__c = 'Processed Pending'));
    }
    if (!mapContactsToUpdate.isEmpty()) {
      try {
        update mapContactsToUpdate.values();
      } catch (DMLException e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'referralNotDesignated Process', e.getStackTraceString());
      }
    }
  }
  /*
   * @description Updates Concurrent Sponsor Applications on Profile
   * @author Issam Awwad (Deloitte) | 9/15/2021
   * @param Set<Id> setProfileIds
   * @return
   **/
  @future public static void updateConcurrentSponsorApplications(Set<Id> setProfileIds) {
    List<Contact> lstOfAdultContactsToUpdate = new List<Contact>();
    Map<Id, Contact> mapOfContacts = new Map<Id, Contact>(
        [SELECT Id, UC_concurrentSponsorApplications__c FROM Contact WHERE Id IN:setProfileIds]);
    List<Case> lstOfSponsorApplications = [
      SELECT Id,
      Status,
      UAC_sponsor__c FROM Case WHERE UAC_sponsor__c IN:setProfileIds AND Status
                                                     =:Label.UAC_caseActiveStatusList
    ];
    Map<Contact, List<Case>> mapOfContactToSponsorApplications = new Map<Contact, List<Case>>();
    for (Case objSponsorApp : lstOfSponsorApplications) {
      List<Case> lstCasesTemp = new List<Case>();
      Contact objContactTemp = mapOfContacts.get(objSponsorApp.UAC_sponsor__c);
      if (mapOfContactToSponsorApplications.containsKey(objContactTemp)) {
        lstCasesTemp = mapOfContactToSponsorApplications.get(objContactTemp);
        lstCasesTemp.add(objSponsorApp);
        mapOfContactToSponsorApplications.put(objContactTemp, lstCasesTemp);

      } else {
        lstCasesTemp.add(objSponsorApp);
        mapOfContactToSponsorApplications.put(objContactTemp, lstCasesTemp);
      }
    }
    for (Contact objContact : mapOfContactToSponsorApplications.keySet()) {
      List<Case> lstCasesTemp = mapOfContactToSponsorApplications.get(objContact);
      if (lstCasesTemp.size() >= 2) {
        objContact.UC_concurrentSponsorApplications__c = True;
        lstOfAdultContactsToUpdate.add(objContact);
      } else {
        if (objContact.UC_concurrentSponsorApplications__c) {
          objContact.UC_concurrentSponsorApplications__c = False;
          lstOfAdultContactsToUpdate.add(objContact);
        }
      }
    }
    if (!lstOfAdultContactsToUpdate.isEmpty()) {
      try {
        update lstOfAdultContactsToUpdate;
      } catch (DMLException e) {
        system.debug('Exception ' + e.getMessage());
        UAC_errorLog.platformEventErrorLog(e.getMessage(),'',
            'UC_referralService : updateConcurrentSponsorApplications',
            e.getStackTraceString());
      }
    }
  }
  /*
   * @description Handles when a referral flips back to processed pending from placement designated
   * @author Awwad (Deloitte) | 9/21/2021
   * @param List<Case> listCasesToProcess
   * @param Set<Id> setUACIds
   * @return
   **/
  public
  static void referralReProcessedClearProgram(List<Case> listCasesToProcess) {
    Set<Id> setOfReferrals = new Set<Id>();
    for (Case objCase : listCasesToProcess) {
      setOfReferrals.add(objCase.Id);
      objCase.UAC_programFacility__c = null;
      objCase.UAC_programType__c = null;
      objCase.UAC_placementDesignationDateTime__c = null;
    }
  }
  /*
   * @description Clears profile's program fields when referral flips back to processed pending from
   *placement designated
   * @author Awwad (Deloitte) | 9/21/2021
   * @param Set<Id> setUACIds
   * @return
   **/
  public
  static void referralReProcessedClearProfile(Set<Id> setUACIds) {
    List<Contact> lstOfContacts =
        [SELECT Id, UAC_status__c, UAC_program__c, UAC_programType__c FROM Contact WHERE Id
          IN:setUACIds];
    List<Contact> lstOfContactsToUpdate = new List<Contact>();
    for (Contact objContact : lstOfContacts) {
      objContact.UAC_program__c = null;
      objContact.UAC_programType__c = null;
      objContact.UAC_status__c = 'Processed Pending';
      lstOfContactsToUpdate.add(objContact);
    }
    if (!lstOfContactsToUpdate.isEmpty()) {
      try {
        update lstOfContactsToUpdate;
      } catch (DMLException e) {
        UAC_errorLog.platformEventErrorLog(e.getMessage(),'',
            'error updating contacts for referral reprocessing',
            e.getStackTraceString());
      }
    }
  }
  /*
   * @description Updates Concurrent Sponsor Applications on Profile
   * @author Issam Awwad (Deloitte) | 9/15/2021
   * @param Set<Id> setProfileIds
   * @return
   **/
  @future public static void referralReProcessedHelper(
      Set<Id> setOfReferrals, Set<Id> setOfProfiles) {
    List<Case> lstOfReferralsForReProcessing =
        [SELECT Id, Status, ContactId FROM Case WHERE Id IN:setOfReferrals];

    referralReProcessedClearProfile(setOfProfiles);
    List<Case> lstOfAdmissions = [
      SELECT Id,
      UAC_programFacility__c,
      UAC_programType__c,
      UAC_placementDesignationDateTime__c,
      ContactId,
      CreatedDate FROM Case WHERE ContactId IN:setOfProfiles AND RecordType.DeveloperName
                                             =:Label.UAC_caseRecordTypeAdmission
    ];
    Map<Id, Case> mapOfContactToAdmission = new Map<Id, Case>();
    if (!lstOfAdmissions.isEmpty()) {
      for (Case objAdmission : lstOfAdmissions) {
        objAdmission.UAC_programFacility__c = null;
        objAdmission.UAC_programType__c = null;
        objAdmission.UAC_placementDesignationDateTime__c = null;
        if (mapOfContactToAdmission.containsKey(objAdmission.ContactId)) {
          if (mapOfContactToAdmission.get(objAdmission.ContactId).CreatedDate
              < objAdmission.CreatedDate) {
            mapOfContactToAdmission.put(objAdmission.ContactId, objAdmission);
          }
        } else {
          mapOfContactToAdmission.put(objAdmission.ContactId, objAdmission);
        }
      }
      System.debug('mapOfContactToAdmission: ' + mapOfContactToAdmission);
      if (!mapOfContactToAdmission.isEmpty()) {
        try {
          update mapOfContactToAdmission.values();
        } catch (DMLException e) {
          UAC_errorLog.platformEventErrorLog(e.getMessage(),'',
              'Admission clearing for Re Processing referrals Process',
              e.getStackTraceString());
        }
      }
    }
  }
}