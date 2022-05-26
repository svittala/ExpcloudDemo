// clang-format off
/**
 * @File Name          : UAC_caseTriggerHelper.cls
 * @Description        : Helper method for UAC_caseTriggerHandler
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_caseTriggerHelperTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/3/2020, 12:48:25 PM
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    5/11/2020   Issam Awwad (Deloitte)        Initial Implementation.
 * 1.1    5/14/2020   Sachet Khanal (Deloitte)      ORRUAC-362 - Update Contact Active Sponsor App
 *                                                  flag
 * 1.2    5/15/2020   Piyush Pranav                 ORRUAC-23 - Update custom UAC lookup  references
 *                                                  (UAC_contact__r) to Contact with standard
 *                                                  Contact look up
 * 1.3    5/20/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-508 - Big Fix to populate Previous
 *                                                  Program field with 'None' value when it's blank.
 * 1.3    5/27/2020   Ankur Aggarwal(Deloitte)      ORRUAC-189 - restrict duplicate pending release
 *                                                  request
 * 1.4    6/1/2020    Chaitanya Nandamuri(Deloitte) ORRUAC -65 - Updating some field on referral
 *                                                  Case and related UAC for Standard Placement.
 * 1.5    6/2/2020    Ankur Aggarwal(Deloitte)      ORRUAC-905 updated Case Consultation Process for
 *                                                  ORRUAC-905 - Starts
 * 1.6    6/1/2020    Rahul Roy (Deloitte)          ORRUAC-324 - Updates Case owner and Case status on insert/update
 * 1.7    6/3/2020    Sachet Khanal (Deloitte)      ORRUAC-125 - Populate FRP Date Sent to Sponsor
 * 1.8    6/4/2020    Rahul Roy (Deloitte)          ORRUAC-317 - Updates Case owner and status from queue
 * 1.10   6/6/2020    Manoj Sharma (Deloitte)       ORRUAC-321 - Updates status to ORRInitiated
 * 1.11   6/6/2020    Manoj Sharma (Deloitte)       ORRUAC-309 -  Auto Populate Sponsor related Fields
 * 1.12   6/6/2020    Manoj Sharma (Deloitte)       ORRUAC-405 -  Auto Populate Sponsor related Fields
 * 1.13   6/6/2020    Karthi Subramanian (Deloitte) ORRUAC-435 - Populate Application Completion Date
 * 1.14   6/8/2020    Rahul Roy (Deloitte)          ORRUAC-191 -  Creates Task on Request Completion
 * 1.15   6/8/2020    Rahul Roy (Deloitte)          ORRUAC-401 -  Updates Final date on ORR Completed
 * 1.16   6/9/2020    Ankur Aggarwal (deloitte)     ORRUAC-480 -  Method restricts creating a discharge notification has an inactive discharge notification
 * 1.16   6/18/2020   James Qian (Deloitte)         ORRUAC-86 -  Mass Referral Placement Email and refactoring
 * 1.16   6/22/2020   Rahul Roy(Deloitte)           ORRUAC-187 - Set Program Facility
 *                                                  ORRUAC-187 - Changes on Release Request
 * 1.17   6/24/2020   Abhisek Pati(Deloitte)        ORRUAC-39 - Create Initial Health Information Record
 * 1.18	  6/26/2020   Issam Awwad(Deloitte)         ORRUAC-80 - Request Special Placement (with FFS Supervisor Approval)
 * 1.19   7/8/2020    Chaitanya Nandamuri(Deloitte)ORRUAC-1251-Process to create Admission Entry Case Record
 * 1.20   7/14/2020   Rahul Roy(Deloitte)           ORRUAC-866 - Auto generate HSPRS Referral
 * 1.21   7/15/2020   Manoj Sharma(Deloitte)        ORRUAC-872- Update the Case Owner to Queue
 * 1.22   7/17/2020   Rahul Roy(Deloitte)           ORRUAC-869- Status Update on HSPRS Referral
 * 1.23   7/17/2020   Chaitany Nandamuri(Deloitte)  ORRUAC-204- Creating a CaseTeamMember for AdmissionEntry
 * 1.24   7/21/2020   Abhisek Pati (Deloitte)       ORRUAC-206- Updating Admitted date and contact 
 *                                                  fields for AdmissionEntry
 * 1.25   7/30/2020   Ankur Aggarwal (Deloitte)     Adding ReleaseRequestAlertMedicalStaff to send email
 * 1.26	  7/30/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-254 - Duplicate Check on TransferRequest, AutoPopulation on Insert and Update.
 * 1.27   8/06/2020   Abhisek Pati (Deloitte)       ORRUAC-285- Autopopulate LCM and CC for Transfer Request
 * 1.28	  8/6/2020    James Qian (Deloitte)         ORRUAC-1094 - Syncing Case Status with Contact Status
 * 1.29	  8/17/2020   Chaitanya nandamuri(Deloitte) ORRUAC-1849 Create Admission Case for Approved Transfer Cases
 * 1.30   8/20/2020   Chaitanya nandamuri(Deloitte) ORRUAC-1846 Create Influx Transfer for LNO rec Approved Admissions.
 * 1.31   8/24/2020   James Qian(Deloitte)          ORRUAC-1848 Restructuring record type checks
 * 1.32   8/27/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-1845 LNOApproved after Effects.
 * 1.33   8/28/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-1843 Influx POC approves Transfer Request.
 * 1.34   8/28/2020   James Qian (Deloitte)         ORRUAC-1848 Adding Case team member to influx manifest
 * 1.35   8/28/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-1844 Review and Refer UAC for Transfer (Influx)
 * 1.36   8/31/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-2102 Bypass Influx Transfer Process
 * 1.38   9/14/2020 	Vaibhav Kudesia(Deloitte)	ORRUAC-438 - Create Background check records for Sponsor Contact
 * 1.37   9/15/2020   Abhisek Pati (Deloitte)       ORRUAC-1325 Autopopulate Admitted date, age and Discharge Date from Case to UAC.
 * 1.38   9/21/2020   Chaitany Nandamuri(Deloitte)  ORRUAC-2308 update In ORR Care (picklist) on related UAC when Admission (Entry) Status changes to "Admitted".
 * 1.39   10/09/2020   Manoj Sharma (Deloitte)      ORRUAC-2969  Custom History Tracking
 * 1.40   10/28/2020  Rahul Roy (Deloitte)          ORRUAC-1935  Update ORR Decision on Sponsor Application
 * 1.41   10/30/2020  Rahul Roy (Deloitte)          ORRUAC-3165  Auto populate Legal fields on UAC Contact
 * 1.42   11/02/2020  Rahul Roy (Deloitte)          ORRUAC-1222  Auto populate Previous Sponsor Applications fields on Adult Contact
 * 1.43   11/11/2020  Satish Kota(Kvortex)          ORRUAC-4129 Updating Discharge Notification Completed field on Contact 
 * 1.44   11/18/2020  Rahul Roy (Deloitte)          ORRUAC-4255 Updated logic on DNF creation as per the gap
 * 1.45   02/24/2021  Nithin Malla (Deloitte)       ORRUAC-168  Updating Adult Contact Relationship for Status Updates for FFS Users.
 * 1.46   02/24/2021  Satish Kota(Deloitte)         ORRUAC-5323 Added If condition for Admitted Date and Discharged Date fields on Contact
 * 1.47   03/17/2021  James Qian (Deloitte)         ORRUAC-5432 Refactored asset/bed logic
 **/
// clang-format on
public
without sharing class UAC_caseTriggerHelper {
  public
  static final String strTypeOfDischargeTransfer = Label.UAC_typeOfDischargeTransfer;
  public
  static final String strSponsorApplicationStatusFFSDecisionDoNotProceed =
      Label.UAC_sponsorApplicationStatusFFSDecisionDoNotProceed;
  public
  static final String strHomeStudyAddNo = Label.UAC_No;
  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypesById =
      Schema.SObjectType.Case.getRecordTypeInfosById();
  private
  static final Map<String, Schema.RecordTypeInfo> mapRecordTypesByDeveloperName =
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
  public
  static final String strCustomPermissionDCW = Label.UAC_CustomPermissionDCW;
  public
  static final String strHomeStudyAddYes = Label.UAC_Yes;
  public
  static final String strCaseRecTypeSWB = Label.UAC_caseRecordTypeSWB;
  public
  static final String strCustomPermissionSupervisor = Label.UAC_CustomPermissionSupervisor;
  public
  static final String strHSPRSReferralCommentRequired = Label.UAC_hsprsReferralCommentRequired;
  public
  static final String strInTransferCaseStatusFFSRev = Label.UAC_ReleaseRequestStatusFFSReview;
  public
  static final String strOther = Label.UAC_other;
  public
  static final String strCaseStatusCancelled = Label.UAC_caseStatusCancelled;
  public
  static final String strHSPRSReferralExists = Label.UAC_hsprsReferralExists;
  public
  static final String strHSPRSClosedStatus = Label.UAC_hsPrsStatusClosed;
  public
  static final String strCaseTypeHomeStudyDiscretionary = Label.UAC_caseTypeHomeStudyDiscretionary;
  public
  static final String strCaseTypeHomeStudyORRMandated = Label.UAC_caseTypeHomeStudyORRMandated;
  public
  static final String strCaseTypeHomeStudyTVPRA = Label.UAC_caseTypeHomeStudyTVPRA;
  public
  static final String strCaseTypePRSAfterDiscretionary = Label.UAC_caseTypePRSAfterDiscretionary;
  public
  static final String strCaseTypePRSAfterORRMandated = Label.UAC_caseTypePRSAfterORRMandated;
  public
  static final String strCaseTypePRSTVPRA = Label.UAC_caseTypePRSTVPRA;
  public
  static final String strCaseTypePRSOnly = Label.UAC_caseTypePRSOnly;
  public
  static final String strCustomPermissionHSPRSProvider = Label.UAC_CustomPermissionHSPRSProvider;
  public
  static final String strCustomPermissionPO = Label.UAC_CustomPermissionPO;
  public
  static final String strCaseStatusActive = Label.UAC_caseStatusActive;
  public
  static final String strCaseStatusHSPRSReferralInitiation =
      Label.UAC_caseStatusHSPRSReferralInitiation;
  public
  static final String strPending = Label.UAC_pending;
  public
  static final String strCreateHSPRSReferral = Label.UAC_createHSPRSReferral;
  public
  static final String strDnfTODRIS = Label.UAC_dnfTypeOfDischargeReunifiedIndSp;
  public
  static final String strDnfTODRSP = Label.UAC_dnfTypeOfDischargeReunifiedSepPar;
  public
  static final String strDnfTODCORS = Label.UAC_dnfTODCORS;
  public
  static final String strApproveWithPostReleaseServicesAfterDiscretionary =
      Label.UAC_approveWithPostReleaseServicesAfterDiscretionary;
  public
  static final String strApproveWithPostReleaseServicesAfterORRMandated =
      Label.UAC_approveWithPostReleaseServicesAfterORRMandated;
  public
  static final String strApproveWithPostReleaseServicesTVPRA =
      Label.UAC_approveWithPostReleaseServicesTVPRA;
  public
  static final String strConductHomeStudyDiscretionary = Label.UAC_conductHomeStudyDiscretionary;
  public
  static final String strConductHomeStudyORRMandated = Label.UAC_conductHomeStudyORRMandated;
  public
  static final String strConductHomeStudyTVPRA = Label.UAC_conductHomeStudyTVPRA;
  public
  static final String strCaseStatusHSRequested = Label.UAC_caseStatusHSRequested;
  public
  static final String strCaseStatusHSCompletedFFSReview = Label.UAC_caseStatusHSCompletedFFSReview;
  public
  static final String strDenyRelease = Label.UAC_denyRelease;
  public
  static final String strCaseRecordTypeHSPRSReferral = Label.UAC_caseRecordTypeHSPRSReferral;
  public
  static boolean boolFirstTriggerRun = true;
  public
  static final String strCaseTeamRoleNameCM = Label.UAC_caseTeamRoleNameCM;
  public
  static final String strCaseTeamRoleNameLCM = Label.UAC_caseTeamRoleNameLCM;
  public
  static final String strCaseTeamRoleNameCC = Label.UAC_caseTeamRoleNameCC;
  public
  static final String strCaseTeamRoleNameFFS = Label.UAC_caseTeamRoleNameFFS;
  public
  static final String strCaseTeamRoleNameFFSS = Label.UAC_caseTeamRoleNameFFSS;
  public
  static final String strCaseTeamRoleNameCFS = Label.UAC_caseTeamRoleNameCFS;
  public
  static final String strCaseTeamRoleNameDOC = Label.UAC_caseTeamRoleNameDOC;
  public
  static final String strDischargedError = Label.UAC_dischargedError;
  public
  static final String strCaseStatusDischargeCompleted = Label.UAC_caseStatusDischargeCompleted;
  public
  static final String strCustomPermissionCFS = Label.UAC_CustomPermissionCFS;
  public
  static final String strCaseRecordTypeApiNameSponsorApplication =
      Label.UAC_caseRecordTypeApiNameSponsorApplication;
  public
  static final String strCaseStatusCaseConsultationProcess =
      Label.UAC_caseStatusCaseConsultationProcess;
  public
  static final String strApproveWithPostReleaseOnlyServices =
      Label.UAC_approveWithPostReleaseOnlyServices;
  public
  static final String strCaseStatusCompleted = Label.UAC_caseStatusCompleted;
  public
  static final String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
  public
  static final String strCourtOrderedReleaseYes = Label.UAC_courtOrderedReleaseYes;
  public
  static final String strCaseRecordTypeDischargeNotification =
      Label.UAC_caseRecordTypeDischargeNotification;
  public
  static final String strTypeOfReleaseReleasetoProgram = Label.UAC_typeOfReleaseReleasetoProgram;
  public
  static final String strTypeOfReleaseReleasetoSponsor = Label.UAC_typeOfReleaseReleasetoSponsor;
  public
  static final String strRelationshipTypePrimarySponso = Label.UAC_relationshipTypePrimarySponsor;
  public
  static final String strCustomPermissionFFSS = Label.UAC_CustomPermissionFFSS;
  public
  static final String strCustomPermissionFFS = Label.UAC_CustomPermissionFFS;
  public
  static final String strReleaseRequestStatusORRInitiated =
      Label.UAC_ReleaseRequestStatusORRInitiated;
  public
  static final String strReleaseRequestStatusCCReview = Label.UAC_ReleaseRequestStatusCCReview;
  public
  static final String strReleaseRequestStatusFFSReview = Label.UAC_ReleaseRequestStatusFFSReview;
  public
  static final String strCustomPermissionLeadCaseManager =
      Label.UAC_CustomPermissionLeadCaseManager;
  public
  static final String strCustomPermissionCaseManager = Label.UAC_CustomPermissionCaseManager;
  public
  static final String strCustomPermissionCC = Label.UAC_CustomPermissionCC;
  public
  static final String strCustomPermissionDOC = Label.UAC_CustomPermissionDOC;
  public
  static final String strCustomPermissionSCC = Label.UAC_CustomPermissionSCC;
  public
  static final String strCustomPermissionPD = Label.UAC_CustomPermissionPD;
  public
  static final String strReleaseRequestStatusInactive = Label.UAC_ReleaseRequestStatusInactive;
  public
  static final String strCaseStatusDnfGen = Label.UAC_caseStatusDnfGen;
  public
  static final String strAdmittedStatus = Label.UAC_admittedContactStatus;
  public
  static final String strInTransferStatus = Label.UAC_inTransferContactStatus;
  // added by ankur ORRUAC-189 - restrict duplicate pending release request -
  // Starts
  public
  static final string strcaseRecordTypeReleaseRequest = Label.UAC_caseRecordTypeReleaseRequest;
  public
  static final string strReleaseRequestExist = Label.uac_ReleaseRequestExist;
  public
  static final Id UACReferralRecordTypeId =
      mapRecordTypesByDeveloperName.get(Label.UAC_referralRecordTypeName).getRecordTypeId();
  // added by ankur ORRUAC-320 & ORRUAC-398 - create task when release request
  // move to CC Review or FFS Review - starts  public
  public
  static final String strNotificationRecordtypeTask = Label.UAC_notificationRecordtypeTask;
  public
  static final String strTransferRemandedORR = Label.UAC_transferRemandedORRDecision;
  public
  static final String strTransferApprovedORR = Label.UAC_orrDecisionTransferApproved;
  public
  static final String strManualReviewCompletedStatus = Label.UAC_ManualReviewCompletedStatus;
  public
  static final string strCCReviewSatus = 'CC Review';
  public
  static final string strFFSReviewSatus = 'FFS Review';
  public
  static final string strNotStartedSatus = 'Not Started';
  public
  static final string strHighPriority = 'High';
  public
  static final string strDischrTypeRunFac = 'Runaway from Facility';
  public
  static final string strDischrTypeRunField = 'Runaway on Field Trip';
  public
  static final string strDischrTypeDNF = 'Transfer';
  static final string strCaseAdmissionInitial = 'Initial Placement';
  static final String Tier_2_Helpdesk_Queue = Label.UAC_Tier2_Helpdesk_Queue;
  /**
   * @description ORRUAC-480 - Method restricts creating a discharge
   *notification has an inactive discharge notification
   * @author Ankur Aggarwal (Deloitte) | 06/09/2020
   * @param lstNewCases Case record to check
   * @return void
   **/
  public
  static final set<string> lstInactiveStatusDischarge =
      new set<string>{'Discharge-(Initiated)', 'Discharge-(On-Hold)', 'Discharge-(In-Transit)'};
  public
  static final set<string> lstStatusHSPRSReferral =
      new set<string>{'Pending', 'Active', 'HS/PRS Referral Initiation'};
  public
  static final string strcaseRecordTypeDischarge = Label.UAC_caseRecordTypeDischarge;
  public
  static final string strDischargeExist = Label.uac_dischargeExist;
  public
  static final string strcaseRecordTypeAdmission = Label.UAC_caseRecordTypeAdmission;
  public
  static final string strPendingAdmissionStatus = 'Pending Admission';
  public
  static final string strQueueName = 'Care Provider';
  public
  static final String strCaseRecordTypeTransferRequest = Label.UAC_caseTransferRequest;
  public
  static final String strTransferApprovedORRDecision = Label.UAC_transferApprovedORRDecision;
  public
  static final String strPendingMedicalClearanceStatus = 'Pending Medical Clearance';
  public
  static final String strAccepted = 'Accepted';
  public
  static final String strRelationSibling = 'Sibling';
  public
  static final String strLeadCaseManager = 'Lead Case Manager';
  public
  static final String strInfluxPOC = 'Influx POC';
  public
  static final String strCM = 'Case Manager';
  public
  static final String strListViewName = 'Influx Transfer Eligible UCs';
  public
  static final String strNotAccepted = 'Not Accepted';
  public
  static final String uacPathCustomNotification = 'UAC_uacPathNotification';
  public
  static final String strKeyUserId = '+UserId';
  public
  static final String strKeyEmail = '+Email';
  public
  static final String strListViewInfluxTransferAcceptedUACs = 'Influx Transfer Accepted UCs';
  public
  static final String strListViewFFSInfluxTransferRequests =
      Label.UAC_FFSInfluxTransferRequestListView;
  public
  static final String strUACstatusTransferPending = 'Pending Transfer';
  public
  static final String strLNOTeamRoleonProgram = 'LNO';
  public
  static final String strPOCRecommendationReferred = 'Referred';
  public
  static final String strListViewInfluxTransferReferredUACsDevName =
      'Influx Transfer Referred UACs';
  public
  static final String strListViewInfluxTransferNOTReferredUACsDevName =
      'Influx Transfer Not Referred UACs';
  public
  static final String strCaseAdmissionInfluxProgramPoc =
      Label.UAC_CaseRecordTypeAdmission + '_InfluxProgramPOC';
  public
  static final String strCaseTransferMatchEligible = 'Eligible';
  public
  static final String strInfluxPOCRecommendationBypassed = 'Bypassed';
  public
  static Id TransferRequestRecordTypeId =
      mapRecordTypesByDeveloperName.get(Label.UAC_caseTransferRequest).getRecordTypeId();
  public
  static Id InfluxTransferRequestTypeId =
      mapRecordTypesByDeveloperName.get(Label.UAC_TransferRequestInflux).getRecordTypeId();
  public
  static Id helpdeskRecordTypeId =
      mapRecordTypesByDeveloperName.get(Label.UC_helpdeskTicket).getRecordTypeId();
  public
  static final String strReadOnlyCaseTeamMemRoleName =
      Label.UAC_readOnlyCtmRoleName;  // ORRUAC - 2416
  private
  static final String strErrorDesignationReversal =
      'You can only change the designation for the most recent referral and for UCs who are still in "Placement Designated" status.';

  // Added by Ankur Aggarwal(Deloitte) for ORRUAC-2524
  public
  static void HSPRSReferralAccepted(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    list<Contactshare> lstContactShare = new list<ContactShare>();
    list<accountshare> lstAccountShare = new list<AccountShare>();
    list<AccountTeamMember> lstAccountteammember = new list<AccountTeamMember>();
    list<id> lstContactid = new list<id>();

    map<id, contact> mapContact = new map<id, contact>();

    for (Case objCase : (list<Case>) mapNewCases.values()) {

      if (objcase.contactid != null) lstContactid.add(objcase.contactid);
    }
    if (lstContactid != null && lstContactid.size() > 0)
      mapContact = new map<id, contact>(
          [select id, accountid, uac_program__c from contact where id in:lstContactid]);

    for (Case objCase : (list<Case>) mapNewCases.values()) {
      if (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)
          && objCase.status == 'Active'
          && ((case) mapOldCases.get(objCase.id)).status == 'Pending') {
        Contactshare ojContactShare = new Contactshare();
        ojContactShare.contactid = objCase.UAC_sponsor__c;
        ojContactShare.ContactAccessLevel = 'Edit';
        ojContactShare.RowCause = 'Manual';
        ojContactShare.UserOrGroupId = UserInfo.getUserId();
        lstContactShare.add(ojContactShare);

        Contact objContact = mapContact.get(objcase.contactid);
        if (objCase.UAC_programFacility__c != null) {  // Added for ORRUAC-4572
          Accountshare ojAccountshare = new Accountshare();
          ojAccountshare.AccountId = objCase.UAC_programFacility__c;
          ojAccountshare.AccountAccessLevel = 'Read';
          ojAccountshare.CaseAccessLevel = 'None';
          ojAccountshare.ContactAccessLevel = 'None';
          ojAccountshare.OpportunityAccessLevel = 'None';
          ojAccountshare.RowCause = 'Manual';
          ojAccountshare.UserOrGroupId = UserInfo.getUserId();
          lstAccountShare.add(ojAccountshare);
        }

        AccountTeamMember acctTM = new AccountTeamMember();
        acctTM.AccountId = objContact.Accountid;
        acctTM.userId = UserInfo.getUserId();
        acctTM.AccountAccessLevel = 'Read';
        acctTM.CaseAccessLevel = 'Read';
        acctTM.ContactAccessLevel = 'Read';
        acctTM.TeamMemberRole = 'HS/PRS Primary Providers';

        lstAccountteammember.add(acctTM);
      }
    }
    if (!lstContactShare.isEmpty()) insert lstContactShare;
    if (!lstAccountShare.isEmpty()) insert lstAccountShare;
    if (!lstAccountteammember.isEmpty()) insert lstAccountteammember;
  }

  // Added by Ankur Aggarwal - ORRUAC-2563 - Start
  public
  static final String strCompletedStatus = Label.UAC_caseStatusCompleted;

  /* @description ORRUAC-2563
   * @param map of new and old Case record
   * @return Boolean
   **/
  public
  static void updateAdmitted(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    list<contact> lstContactUpdate = new list<contact>();
    for (Case objCase : (list<Case>) mapNewCases.values()) {
      Contact objContact = new Contact();
      if (objCase.Status == strAdmittedStatus
          && objCase.Status != ((Case) mapOldCases.get(ObjContact.id)).Status) {
        objContact.id = objCase.Contactid;
        objContact.UAC_admittedDateTime__C = system.now();
        lstContactUpdate.add(objContact);
      }
    }
    update lstContactUpdate;
  }
  /* @description ORRUAC-2563
   * @param map of new and old Case record
   * @return Boolean
   **/
  public
  static void updateTransferCompleted(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    list<contact> lstContactUpdate = new list<contact>();
    for (Case objCase : (list<Case>) mapNewCases.values()) {
      Contact objContact = new Contact();
      if (objCase.Status == strCompletedStatus
          && objCase.Status != ((Case) mapOldCases.get(ObjContact.id)).Status) {
        objContact.id = objCase.Contactid;
        objContact.UAC_dateTimeOfDischarge__C = system.now();
        lstContactUpdate.add(objContact);
      }
    }
    update lstContactUpdate;
  }
  // Added by Ankur Aggarwal - ORRUAC-2563 - Ends
  public
  static void restrictMultiplePendingDischarge(List<Case> lstNewCases) {
    Id idDischargeType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeDischarge).getRecordTypeId();
    Map<id, list<case>> mapDischargeByUAC = new map<id, list<case>>();

    for (Case NewCase : lstNewCases) {
      if (idDischargeType == NewCase.recordtypeid) {
        list<case> lstCases = new list<case>();
        if (mapDischargeByUAC.containsKey(NewCase.Contactid)) {
          lstCases = mapDischargeByUAC.get(NewCase.Contactid);
        }
        lstCases.add(NewCase);
        mapDischargeByUAC.put(NewCase.Contactid, lstCases);
      }
    }

    map<id, contact> mapContactExistingPendingCase = new map<id, contact>([select id,
      (select id from cases where status in
          : lstInactiveStatusDischarge and recordtypeid =
              : idDischargeType) from Contact where id in:mapDischargeByUAC.keyset()]);

    for (Id idContact : mapDischargeByUAC.keyset()) {
      Contact objContactExistingPendingCase = mapContactExistingPendingCase.get(idContact);
      if (objContactExistingPendingCase != null && objContactExistingPendingCase.cases != null
          && objContactExistingPendingCase.cases.size() > 0) {
        list<case> lstCases = mapDischargeByUAC.get(idContact);
        for (Case objnewCase : lstCases) {
          objnewCase.adderror(strDischargeExist);
        }
      }
    }
  }
  // added by ankur ORRUAC-320 & ORRUAC-398 - create task when release request
  // move to CC Review or FFS Review - ends updated Case Consultation Process
  // for ORRUAC-905 - Starts
  // added 4 new HS status - AC 16 ORRUAC-1217
  public
  static final set<string> lstInactiveStatusReleaseRequest = new set<string>{'CM Initiated',
      'CM to Provide Further Information',
      'CC Review',
      'FFS Review',
      'Case Consultation Process',
      'ORR Initiated',
      'HS Requested',
      'HS Completed -CM Review',
      'HS Completed - CC Review',
      'HS Completed - FFS Review'};
  public
  static final string strCMtoProvideInfo = Label.UAC_caseStatusCMtoProvideInfo;
  public
  static final string strSponsorAppCompletionStatus =
      Label.UAC_sponsorAppCompletionStatus;  // ORRUAC - 435
  // added by ankur ORRUAC-320 & ORRUAC-398 - create task when release request
  // move to CC Review or FFS Review - starts
  /**
   * @description ORRUAC-320 & ORRUAC-398 - create task when release request
   *move to CC Review or FFS Review
   * @author Ankur Aggarwal (Deloitte) | 6/4/2020
   * @param Map<Id, SObject> newItems
   * @param Map<Id, SObject> oldItems
   * @return void
   **/
  public
  static void ReleaseRequestTaskCreation(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Id idReleaseRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();

    Id idNotificationType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                .get(strnotificationRecordtypeTask)
                                .getRecordTypeId();

    list<task> lstTask = new list<task>();
    UAC_BusinessDaysUtility utilBusinessInstance = new UAC_BusinessDaysUtility();
    Datetime dateNextBusinessDatetime = utilBusinessInstance.addDays(system.today(), 1);
    Date dateNextBusinessDate = dateNextBusinessDatetime.dateGmt();
    system.debug(dateNextBusinessDate);
    for (Case objOldCase : (list<case>) oldItems.values()) {
      Case objNewCase = (case) newItems.get(objOldCase.Id);
      if (objNewCase.recordtypeid == idReleaseRecType && objNewCase.status != objOldCase.status) {
        if (objNewCase.status == strCCReviewSatus && objNewCase.UAC_caseCoordinator__c != null) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject = 'Release Request pending review ' + objNewCase.CaseNumber;
          objTask.whatid = objNewCase.id;
          // This is the default...
          objTask.OwnerId = objNewCase.UAC_caseCoordinator__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }
        if (objNewCase.status == strFFSReviewSatus && objNewCase.UAC_ffsName__c != null) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject = 'Release Request pending review ' + objNewCase.CaseNumber;
          // This is the default...
          objTask.whatid = objNewCase.id;
          objTask.OwnerId = objNewCase.UAC_ffsName__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }
        // ORRUAC - 191 starts
        if (objNewCase.status == strCaseStatusCompleted
            && objNewCase.UAC_orrDecision__c == strApproveWithPostReleaseOnlyServices) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject =
              'Please make a PRS Referral ' + objNewCase.CaseNumber + ' within 24 hours';
          objTask.whatid = objNewCase.id;
          objTask.OwnerId = objNewCase.UAC_caseManager__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }
        // ORRUAC - 866 starts
        if ((objNewCase.status == strCaseStatusDnfGen
                || objNewCase.status == strCaseStatusHSRequested)
            && objOldCase.Status == strFFSReviewSatus && objNewCase.UAC_caseManager__c != null
            && (objNewCase.UAC_orrDecision__c == strApproveWithPostReleaseOnlyServices
                || objNewCase.UAC_orrDecision__c == strConductHomeStudyTVPRA
                || objNewCase.UAC_orrDecision__c == strConductHomeStudyORRMandated
                || objNewCase.UAC_orrDecision__c == strConductHomeStudyDiscretionary)
            && (FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject = strCreateHSPRSReferral + ' ' + objNewCase.CaseNumber;
          objTask.whatid = objNewCase.id;
          objTask.OwnerId = objNewCase.UAC_caseManager__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }

        if ((objNewCase.status == strCaseStatusDnfGen
                || objNewCase.status == strCaseStatusHSRequested)
            && objOldCase.Status == strFFSReviewSatus && objNewCase.UAC_leadCaseManager__c != null
            && (objNewCase.UAC_orrDecision__c == strApproveWithPostReleaseOnlyServices
                || objNewCase.UAC_orrDecision__c == strConductHomeStudyTVPRA
                || objNewCase.UAC_orrDecision__c == strConductHomeStudyORRMandated
                || objNewCase.UAC_orrDecision__c == strConductHomeStudyDiscretionary)
            && (FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject = strCreateHSPRSReferral + ' ' + objNewCase.CaseNumber;
          objTask.whatid = objNewCase.id;
          objTask.OwnerId = objNewCase.UAC_leadCaseManager__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }

        if (objNewCase.status == strCaseStatusDnfGen
            && objOldCase.Status == strCaseStatusHSCompletedFFSReview
            && objNewCase.UAC_caseManager__c != null
            && (objNewCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesAfterORRMandated
                || objNewCase.UAC_orrDecisionHS__c
                    == strApproveWithPostReleaseServicesAfterDiscretionary
                || objNewCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesTVPRA)
            && (FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject = strCreateHSPRSReferral + ' ' + objNewCase.CaseNumber;
          objTask.whatid = objNewCase.id;
          objTask.OwnerId = objNewCase.UAC_caseManager__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }

        if (objNewCase.status == strCaseStatusDnfGen
            && objOldCase.Status == strCaseStatusHSCompletedFFSReview
            && objNewCase.UAC_leadCaseManager__c != null
            && (objNewCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesAfterORRMandated
                || objNewCase.UAC_orrDecisionHS__c
                    == strApproveWithPostReleaseServicesAfterDiscretionary
                || objNewCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesTVPRA)
            && (FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationType;
          objTask.Subject = strCreateHSPRSReferral + ' ' + objNewCase.CaseNumber;
          objTask.whatid = objNewCase.id;
          objTask.OwnerId = objNewCase.UAC_leadCaseManager__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dateNextBusinessDate;
          lstTask.add(objTask);
        }
      }
    }
    if (lstTask != null && lstTask.size() > 0) insert lstTask;
  }
  // added by ankur ORRUAC-320 & ORRUAC-398 - create task when release request move to CC Review or
  // FFS Review - ends
  // added by ankur ORRUAC-189 - restrict duplicate pending release request - ends
  /**
   * @description ORRUAC-189 - Method returns true if UAC already has an inactive Release Request
   * @author Ankur Aggarwal (Deloitte) | 5/27/2020
   * @param lstNewCases Case record to check
   * @return void
   **/
  public
  static void restrictMultiplePendingReleaseRequest(List<Case> lstNewCases) {
    Id idReleaseRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    Map<id, list<case>> mapReleaseRequestByUAC = new map<id, list<case>>();

    for (Case NewCase : lstNewCases) {
      if (idReleaseRecType == NewCase.recordtypeid) {
        list<case> lstCases = new list<case>();
        if (mapReleaseRequestByUAC.containsKey(NewCase.Contactid)) {
          lstCases = mapReleaseRequestByUAC.get(NewCase.Contactid);
        }
        lstCases.add(NewCase);
        mapReleaseRequestByUAC.put(NewCase.Contactid, lstCases);
      }
    }
    system.debug(mapReleaseRequestByUAC);
    map<id, contact> mapContactExistingPendingCase = new map<id, contact>([select id,
      (select id from cases where status in
          : lstInactiveStatusReleaseRequest and recordtypeid =
              : idReleaseRecType) from Contact where id in:mapReleaseRequestByUAC.keyset()]);
    system.debug(mapContactExistingPendingCase);
    for (Id idContact : mapReleaseRequestByUAC.keyset()) {
      Contact objContactExistingPendingCase = mapContactExistingPendingCase.get(idContact);
      if (objContactExistingPendingCase != null && objContactExistingPendingCase.cases != null
          && objContactExistingPendingCase.cases.size() > 0) {
        list<case> lstCases = mapReleaseRequestByUAC.get(idContact);
        for (Case objnewCase : lstCases) {
          objnewCase.adderror(strReleaseRequestExist);
        }
      }
    }
  }
  /**
   * @description ORRUAC-362 - Method returns true if Case record is an active
   *Sponsor Application
   * @author Sachet Khanal (Deloitte) | 5/14/2020
   * @param objCase Case record to check
   * @return Boolean
   **/
  public
  static Boolean isActiveSponsorApplication(Case objCase) {
    return (UAC_caseUtilities.getActiveStatuses().contains(objCase.Status)
        && objCase.RecordTypeId
            == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
                Label.UAC_caseRecordTypeApiNameSponsorApplication));
  }

  /**
   * @description ORRUAC-362 - Method to update active sponsor application
   *flag on Contact
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @param setContactIds Set of contact Ids to re-evaluate active sponsor
   *application flag
   * @return void
   **/
  public
  static void updateContactActiveSponsorApplication(Set<Id> setContactIds) {
    try {
      // Initialize map for Contact update to set Active Sponsor Application
      // flag to false.
      Map<Id, Contact> mapContactToUpdate = new Map<Id, Contact>();
      for (Id idContact : setContactIds) {
        mapContactToUpdate.put(
            idContact, new Contact(Id = idContact, UAC_activeSponsorApplication__c = false));
      }
      // clang-format off
     for(AggregateResult objAggregateResult : [
       SELECT
       UAC_sponsor__c, count(Id) totalActiveSponsorCases
       FROM
         Case
       WHERE
         Status IN:UAC_caseUtilities.getActiveStatuses()
         AND UAC_sponsor__c IN:mapContactToUpdate.keySet()
       GROUP BY UAC_sponsor__c
     ])
      // clang-format on
      {
        Integer intActiveSponsorCaseCount =
            (Integer) objAggregateResult.get('totalActiveSponsorCases');
        // Update contact in update map to set Active Sponsor Application flag
        mapContactToUpdate.get((Id) objAggregateResult.get('UAC_sponsor__c'))
            .UAC_activeSponsorApplication__c = (intActiveSponsorCaseCount > 0);
      }
      update mapContactToUpdate.values();
    } catch (Exception objException) {
      UAC_errorLog.logError(objException.getMessage(), '',
          'Updating Contact Active Sponsor Application',
          objException.getStackTraceString());
    }
  }

  /**
   * @description ORRUAC-55 - Method to Auto Populate A# , First Name , Last
   *Name from Contact UAC record
   * @author Chaitany Nandamuri (Deloitte) | 5/15/2020
   * @param
   * @return void
   **/
  public
  static void populateValuesFromContact(List<Case> lstCases) {
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    List<id> lstOfcontactIdOnCases = new List<Id>();
    Map<id, contact> mapOfContactIdtoRecord = new Map<id, contact>();

    for (Case objCase : lstCases) {
      lstOfcontactIdOnCases.add(objCase.ContactId);
    }

    for (contact objCon :
        [select id, UAC_A__c, FirstName, LastName, AccountId, UAC_program__c from contact where Id
          In:lstOfcontactIdOnCases]) {
      mapOfContactIdtoRecord.put(objCon.id, objCon);
    }

    if (!mapOfContactIdtoRecord.isEmpty()) {
      for (Case newCase : lstCases) {
        newCase.UAC_aNum__c = mapOfContactIdtoRecord.get(newCase.ContactId).UAC_A__c;
        newCase.UAC_firstName__c = mapOfContactIdtoRecord.get(newCase.ContactId).FirstName;
        newCase.UAC_lastName__c = mapOfContactIdtoRecord.get(newCase.ContactId).LastName;
        if (newCase.recordTypeId == idDNFRecType
            && mapOfContactIdtoRecord.get(newCase.ContactId).UAC_program__c != null) {
          if (newCase.UAC_typeOfDischarge__c != 'Transfer') {
            newCase.UAC_programFacility__c =
                mapOfContactIdtoRecord.get(newCase.ContactId).UAC_program__c;
          }
        }
      }
    }
  }

  /**
   * @description ORRUAC-4682- Method to Update the contact's current program when status
   * of and Admitted case generated from Transfer Case is changed to Admitted
   * @author Sarang Padhye (Deloitte) | 08/18/2020
   * @param
   * @return void
   **/
  public
  static void updateContactProgramAdmittedCase(
      Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    Id transferRequestRecTypeId = mapRecordTypesByDeveloperName
                                      .get(strCaseRecordTypeTransferRequest)
                                      .getRecordTypeId();
    List<Contact> lstContactList = new List<Contact>();
    for (Case objCase : (list<case>) mapNewCases.values()) {
      Case objOld = (case) mapOldCases.get(objCase.id);
      if ((objCase.status != objOld.status) && (objCase.status == strAdmittedStatus)
          && (objCase.type == Label.UAC_caseTypeRegularTransfer
              || objCase.type == Label.UAC_caseTypeInfluxTransfer)
          && (objCase.UAC_currentProgramOnContact__c != objCase.UAC_programFacility__c)) {
        Contact newContact = new Contact();
        newContact.Id = objCase.ContactId;
        newContact.UAC_program__c = objCase.UAC_programFacility__c;
        lstContactList.add(newContact);
      }
    }
    if (!lstContactList.isEmpty()) {
      try {
        update lstContactList;
      } catch (DMLException e) {
        system.debug('Exception ' + e.getMessage());
        UAC_errorLog.platformEventErrorLog(e.getMessage(),'',
            'UAC_caseTriggerHelper : updateContactProgramAdmittedCase',
            e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Profile Update Failed: ' + e.getMessage());
      }
    }
  }

  /**
   * @description ORRUAC-2020- Method to Update the contact's current program when status
   *UAC is Discharged
   * @author Sarang Padhye (Deloitte) | 08/18/2020
   * updated for ORRUAC-2091 AC5 Piyush - 8/27/2020
   * updated for ORRUAC-4682 - 12/17/2020
   * @param
   * @return void
   **/
  public
  static void updateContactProgramDNF(Map<Id, Case> mapNewCases, Map<Id, Case> mapOldCases) {
    // Iterate over new Cases ,Check status change to Discharge (Completed) & set current program on
    // contact to null
    List<Contact> lstContactList = new List<Contact>();
    List<Id> lstContactId = new List<Id>();
    List<Case> lstReferalCaseUpdate = New List<Case>();
    for (Case objCase : mapNewCases.values()) {
      Case objOld = mapOldCases.get(objCase.id);
      if (objCase.status != objOld.status
          && (objCase.status == label.UAC_CaseStatusDischargeCompleted)
          && ((objCase.UAC_currentProgram__c != null
                  && objCase.UAC_currentProgram__c == objCase.UAC_currentProgramOnContact__c)
              || objCase.UAC_currentProgram__c == null)) {
        Contact newContact = new Contact();
        newContact.Id = objCase.ContactId;
        newContact.UAC_program__c = null;
        newContact.UAC_dateTimeOfDischarge__c = System.Now();  // updated for ORRUAC-2091 AC5
        lstContactList.add(newContact);
        if (objCase.UAC_typeOfDischarge__c
            != label.UAC_typeOfDischargeTransfer)  // Add by  Manoj ORRUAC-2930
          lstContactId.add(objCase.ContactId);     // Add by  Manoj ORRUAC-2930
      }
    }  // Add by  Manoj ORRUAC-2930
    if (!lstContactId.isEmpty()) {
      for (Contact objContact : [Select UAC_techUACReferralId__c from Contact where Id
               in:lstContactId and UAC_techUACReferralId__c != null]) {
        Case objReferralCase = New Case(
            Id = objContact.UAC_techUACReferralId__c, UAC_dateTimeOfDischarge__c = System.Now());
        lstReferalCaseUpdate.add(objReferralCase);
      }
    }  // Add by  Manoj ORRUAC-2930
    if (!lstContactList.isEmpty()) {
      try {
        update lstContactList;
        if (!lstReferalCaseUpdate.isEmpty()) {
          update lstReferalCaseUpdate;
        }
      } catch (DMLException e) {
        system.debug('Exception ' + e.getMessage());
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Profile Update Failed: ' + e.getMessage());
      }
    }
  }

  /* @description ORRUAC-2091 AC1 - Auto populate Rel Req Legal Section on insert
   * @author Piyush 8/27/2020
   * @param list of new Case records
   * @return None
   **/
  public
  static void setRelReqLegalSection(List<Case> lstNewCases) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    List<id> lstUacId = new List<Id>();
    Map<id, contact> mapConIdToRec = new Map<Id, Contact>();
    Map<id, Contract> mapConIdToSerRec = new Map<Id, Contract>();
    Map<id, UAC_legal__c> mapConIdToLegalRec = new Map<Id, UAC_legal__c>();

    for (Case objCase : lstNewCases) {
      if (objCase.ContactId != null) {
        lstUacId.add(objCase.ContactId);
      }
    }
    for (Contact objCon : [select Id,
           UAC_isUACaMaterialWitness__c,
           UAC_finalOrderofRemoval__c,
           UAC_mppCase__c,
           UAC_separatedFromParentLegalGuardian__c from Contact where Id in:lstUacId]) {
      mapConIdToRec.put(objCon.id, objCon);
    }
    for (Contract objCtr : [select Id,
           UAC_profile__c,
           UAC_outcomeOfOTIPSubmission__c,
           UAC_currentStatus__c from Contract where UAC_profile__c in:lstUacId]) {
      if (objCtr.UAC_profile__c != null) {
        mapConIdToSerRec.put(objCtr.UAC_profile__c, objCtr);
      }
    }
    for (UAC_legal__c objLegal : [select Id,
           UAC_uacProfile__c,
           UAC_attorneyOfRecordFormUploaded__c,
           UAC_status__c from UAC_legal__c where UAC_uacProfile__c in:lstUacId]) {
      if (objLegal.UAC_uacProfile__c != null) {
        mapConIdToLegalRec.put(objLegal.UAC_uacProfile__c, objLegal);
      }
    }
    if (!mapConIdToRec.isEmpty()) {
      for (Case newCase : lstNewCases) {
        if (newCase.recordTypeId == idRelReqRecType
            && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
          if (mapConIdToRec.get(newCase.ContactId).UAC_isUACaMaterialWitness__c == true) {
            newCase.UAC_isTheUacAMaterialWitness__c = 'Yes';
          } else {
            newCase.UAC_isTheUacAMaterialWitness__c = 'No';
          }
          if (mapConIdToRec.get(newCase.ContactId).UAC_finalOrderofRemoval__c == true) {
            newCase.UAC_isThereARemovalOrderForUac__c = 'Yes';
          } else {
            newCase.UAC_isThereARemovalOrderForUac__c = 'No';
          }
          if (mapConIdToRec.get(newCase.ContactId).UAC_mppCase__c == true) {
            newCase.UAC_isThisAMppCase__c = 'Yes';
          } else {
            newCase.UAC_isThisAMppCase__c = 'No';
          }
          if (mapConIdToRec.get(newCase.ContactId).UAC_separatedFromParentLegalGuardian__c
              == true) {
            newCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
          } else {
            newCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
          if (!mapConIdToSerRec.IsEmpty()) {
            newCase.UAC_referralToOTIP__c =
                mapConIdToSerRec.get(newCase.ContactId).UAC_currentStatus__c;
            newCase.UAC_outcomeOfReferral__c =
                mapConIdToSerRec.get(newCase.ContactId).UAC_outcomeOfOTIPSubmission__c;
          }
          if (!mapConIdToLegalRec.IsEmpty()) {
            if (mapConIdToLegalRec.get(newCase.ContactId).UAC_status__c == 'Current'
                && mapConIdToLegalRec.get(newCase.ContactId).UAC_attorneyOfRecordFormUploaded__c
                    == true) {
              newCase.UAC_isThereAttorneyOfRecord__c = 'Yes';
            } else {
              newCase.UAC_isThereAttorneyOfRecord__c = 'No';
            }
          }
        }
      }
    }
  }

  /**
   * @description ORRUAC-1094: Syncs Contact Status with Case Status for Referral
   * @author James Qian (Deloitte) | 08/06/2020
   * @param List<Case> listCase
   * @return void
   **/
  public
  static void syncContactStatusWithCaseStatusReferral(
      List<Case> listCase, Map<Id, Contact> mapContact, Boolean boolInsert) {
    Map<String, List<Case>> mapOpenSiblingCases = queryOpenSiblingCases(listCase);
    List<String> listCaseRecordTypesNonReferral =
        new List<String>{Label.UAC_caseRecordTypeReleaseRequest,
            Label.UAC_caseRecordTypeDischargeNotification,
            Label.UAC_caseRecordTypeAdmission,
            Label.UAC_caseTransferRequest};
    if (mapContact == null || mapContact.isEmpty()) {
      updateContactsForStatusSync(listCase[0],
          getContactsToUpdateForStatusSync(
              listCase, listCaseRecordTypesNonReferral, mapOpenSiblingCases));
    } else {
      // If contact updates are happening in previous method include in DML
      for (Contact currentContact : getContactsToUpdateForStatusSync(
               listCase, listCaseRecordTypesNonReferral, mapOpenSiblingCases, boolInsert)
                                        .values()) {
        if (mapContact.containsKey(currentContact.Id)) {
          Contact contactFromMap = mapContact.get(currentContact.Id);
          contactFromMap.UAC_status__c = currentContact.UAC_status__c;
          mapContact.put(currentContact.Id, contactFromMap);
        } else {
          mapContact.put(currentContact.Id, currentContact);
        }
      }
      updateContactsForStatusSync(listCase[0], mapContact);
    }
  }

  /**
   * @description ORRUAC-1094: Syncs Contact Status with Case Status for Transfer
   * @author James Qian (Deloitte) | 08/06/2020
   * @param List<Case> listCase
   * @return void
   **/
  public
  static void syncContactStatusWithCaseStatusTransfer(List<Case> listCase) {
    Map<String, List<Case>> mapOpenSiblingCases = queryOpenSiblingCases(listCase);
    List<String> listCaseRecordTypesNonTransfer =
        new List<String>{Label.UAC_caseRecordTypeReleaseRequest,
            Label.UAC_caseRecordTypeDischargeNotification,
            Label.UAC_caseRecordTypeAdmission,
            Label.UAC_referralRecordTypeName};
    updateContactsForStatusSync(listCase[0],
        getContactsToUpdateForStatusSync(
            listCase, listCaseRecordTypesNonTransfer, mapOpenSiblingCases));
  }

  /**
   * @description ORRUAC-1094: Syncs Contact Status with Case Status for Admission
   * @author James Qian (Deloitte) | 08/06/2020
   * @param List<Case> listCase
   * @return void
   **/
  public
  static void syncContactStatusWithCaseStatusAdmission(List<Case> listCase) {
    Map<String, List<Case>> mapOpenSiblingCases = queryOpenSiblingCases(listCase);
    List<String> listCaseRecordTypesNonAdmission =
        new List<String>{Label.UAC_caseRecordTypeReleaseRequest,
            Label.UAC_caseRecordTypeDischargeNotification,
            Label.UAC_caseTransferRequest,
            Label.UAC_referralRecordTypeName};
    updateContactsForStatusSync(listCase[0],
        getContactsToUpdateForStatusSync(
            listCase, listCaseRecordTypesNonAdmission, mapOpenSiblingCases));
  }

  /**
   * @description ORRUAC-1094: Returns a list of Contacts to update status for
   * @author James Qian (Deloitte) | 08/06/2020
   * @param List<Case> listCase
   * @param List<String> listRecordTypesToProcess
   * @param Map<String, List<Case>> mapOpenSiblingCases
   * @return Map<Id, Contact>
   **/
  private
  static Map<Id, Contact> getContactsToUpdateForStatusSync(List<Case> listCase,
      List<String> listRecordTypesToProcess,
      Map<String, List<Case>> mapOpenSiblingCases) {
    return getContactsToUpdateForStatusSync(
        listCase, listRecordTypesToProcess, mapOpenSiblingCases, false);
  }

  /**
   * @description ORRUAC-1094: Returns a list of Contacts to update status for
   * @author James Qian (Deloitte) | 08/06/2020
   * @param List<Case> listCase
   * @param List<String> listRecordTypesToProcess
   * @param Map<String, List<Case>> mapOpenSiblingCases
   * @return Map<Id, Contact>
   **/
  private
  static Map<Id, Contact> getContactsToUpdateForStatusSync(List<Case> listCase,
      List<String> listRecordTypesToProcess,
      Map<String, List<Case>> mapOpenSiblingCases,
      Boolean boolInsert) {
    Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
    for (Case caseCurrent : listCase) {
      for (String strCaseRecordType : listRecordTypesToProcess) {
        String strKey = caseCurrent.ContactId + '.' + strCaseRecordType;
        if (!mapOpenSiblingCases.containsKey(strKey) || mapOpenSiblingCases.get(strKey) == null
            || mapOpenSiblingCases.get(strKey).isEmpty()) {
          String strCaseStatus = caseCurrent.Status;
          if (mapRecordTypesById.get(caseCurrent.RecordTypeId).getDeveloperName()
              == Label.UAC_caseTransferRequest) {
            strCaseStatus = Label.UAC_inTransferContactStatus;
          } else if (boolInsert) {
            strCaseStatus = Label.UAC_newPendingContactStatus;
          }
          mapContactsToUpdate.put(caseCurrent.ContactId,
              new Contact(Id = caseCurrent.ContactId, UAC_status__c = strCaseStatus));
        }
      }
    }
    return mapContactsToUpdate;
  }

  /**
   * @description ORRUAC-1094: Updates Contacts and performs error handling
   * @author James Qian (Deloitte) | 08/06/2020
   * @param Case caseForErrors
   * @param Map<Id, Contact> mapContactsToUpdate
   * @return void
   **/
  private
  static void updateContactsForStatusSync(
      Case caseForErrors, Map<Id, Contact> mapContactsToUpdate) {
    if (!mapContactsToUpdate.isEmpty()) {
      try {
        update mapContactsToUpdate.values();
      } catch (DMLException e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
        caseForErrors.addError('Profile Update Failed: ' + e.getMessage());
      }
    }
  }

  /**
   * @description ORRUAC-1251 - Create New Admission Entry when Referral Case is Placement
   * Designated. Refactored for 5432 to avoid duplicate admission creation.
   *Chaitanya Nadamuri  (Deloitte) | 8/17/2020 -ORRUAC-1849 - Admission Case for
    Transfer/Influx/UAC referral and Setting Type on Amdssion based on Parent case
   * @author Chaitanya Nandamuri (Deloitte) | 07/06/2020
   * @param List<Case> caseList
   * @
   **/
  private
  static void newAdmissionEntry(list<Case> caseList, Map<id, case> CaseMap) {
    if (caseList.isEmpty()) {
      return;
    }
    Set<Id> setReferralIds = new Set<Id>();
    for (Case currentCase : caseList) {
      setReferralIds.add(currentCase.Id);
    }
    map<id, case> MapParentIdToAdmissionEntry = new Map<Id, Case>();
    List<case> LstCaseTeamforAdmissionInsert = new List<case>();
    Map<Id, Id> mapContactIdToReferral = getMostRecentReferral(caseList);

    Id queueId =
        [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:strQueueName limit 1].id;
    Set<Id> setReferralsIdsWithChildren = new Set<Id>();
    for (Case currentAdmission : [
           SELECT Id,
           ParentId FROM Case WHERE ParentId IN:setReferralIds AND RecordType.DeveloperName
                                              =:Label.UAC_caseRecordTypeAdmission
         ]) {
      setReferralsIdsWithChildren.add(currentAdmission.ParentId);
    }
    for (Case caseCurrent : caseList) {
      if (setReferralsIdsWithChildren.contains(caseCurrent.Id)) {
        continue;
      }
      Case admissionEntry = new Case();
      admissionEntry.ParentId = caseCurrent.Id;
      admissionEntry.RecordTypeId =
          mapRecordTypesByDeveloperName.get(strcaseRecordTypeAdmission).getRecordTypeId();
      admissionEntry.Status = strPendingAdmissionStatus;
      admissionEntry.ContactId = caseCurrent.ContactId;
      admissionEntry.OwnerId = queueId;
      admissionEntry.UAC_programFacility__c = caseCurrent.UAC_programFacility__c;
      admissionEntry.UAC_programType__c = caseCurrent.UAC_programType__c;
      if (caseCurrent.RecordTypeId == UACReferralRecordTypeId) {
        admissionEntry.Type = Label.UAC_caseTypeInitialPlacement;
        admissionEntry.UAC_referral__c = caseCurrent.Id;
      } else if (caseCurrent.RecordTypeId == TransferRequestRecordTypeId) {
        admissionEntry.Type = Label.UAC_caseTypeRegularTransfer;
        if (String.isNotBlank(admissionEntry.ContactId)
            && mapContactIdToReferral.containsKey(admissionEntry.ContactId)
            && mapContactIdToReferral.get(admissionEntry.ContactId) != null) {
          admissionEntry.UAC_referral__c = mapContactIdToReferral.get(admissionEntry.ContactId);
        }
      } else if (caseCurrent.RecordTypeId == InfluxTransferRequestTypeId) {
        admissionEntry.Type = label.UAC_caseTypeInfluxTransfer;
        if (String.isNotBlank(admissionEntry.ContactId)
            && mapContactIdToReferral.containsKey(admissionEntry.ContactId)
            && mapContactIdToReferral.get(admissionEntry.ContactId) != null) {
          admissionEntry.UAC_referral__c = mapContactIdToReferral.get(admissionEntry.ContactId);
        }
      }
      // Map of ParentId (Referral Case Id) as Key , AdmissionEntry Record as value.
      MapParentIdToAdmissionEntry.put(caseCurrent.id, admissionEntry);
    }

    if (!MapParentIdToAdmissionEntry.Isempty()) {

      Database.insert(MapParentIdToAdmissionEntry.values(), false);
      // loop over referral Case Id to get the Admission Record Id
      for (Id ParentCase : MapParentIdToAdmissionEntry.keyset()) {
        // If admission Id equals to null ? Admission Case Creation Failed : Admission created
        if (MapParentIdToAdmissionEntry.get(ParentCase).id == null) {
          CaseMap.get(ParentCase).addError('Admission Entry Creation Failed');
        } else {
          // Creating a List of successfully Inserted Admission entry
          LstCaseTeamforAdmissionInsert.add(MapParentIdToAdmissionEntry.get(ParentCase));
        }
      }
    }

    if (!LstCaseTeamforAdmissionInsert.isEmpty()) {
      try {
        // Method to create CaseTeamMember
        CaseTeamforAdmissionInsert(LstCaseTeamforAdmissionInsert);
      } catch (Exception e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
      }
    }
  }

  /**
   * @description Returns most recent Referral ID map
   * @author James Qian (Deloitte) 11/16/2020
   * @param List<Case> lstCase
   * @return Map<Id, Id>
   **/
  public
  static Map<Id, Id> getMostRecentReferral(List<Case> lstCase) {
    Map<Id, Id> mapContactToReferral = new Map<Id, Id>();
    for (Case caseCurrent : lstCase) {
      if (String.isNotBlank(caseCurrent.ContactId)) {
        mapContactToReferral.put(caseCurrent.ContactId, null);
      }
    }
    if (mapContactToReferral.isEmpty()) {
      return mapContactToReferral;
    }
    for (Case objReferral : [
           SELECT Id,
           ContactId FROM Case WHERE RecordType.DeveloperName
            =:Label.UAC_referralRecordTypeName AND ContactId
           IN:mapContactToReferral.keyset() ORDER BY CreatedDate ASC
         ]) {
      mapContactToReferral.put(objReferral.ContactId, objReferral.Id);
    }
    return mapContactToReferral;
  }

  /**
   * @description ORRUAC-204 - Create Case Team member for Lead Case Manager and
   *Lead Clinician.
   * @author Chaitanya Nandamuri (Deloitte) | 07/17/2020
   * @param List<Case> caseList
   * @
   **/

  public
  static void CaseTeamforAdmissionInsert(List<case> admissionEntry) {
    List<id> LstProgramFacility = new List<Id>();
    List<CaseTeamMember> LstCaseTeamMember = new List<CaseTeamMember>();
    Map<String, id> mapRoleCaseTeamRole = new Map<String, id>();
    Map<id, List<AccountTeamMember>> MapAccountIdToAccountTeamMember =
        new Map<id, List<AccountTeamMember>>();

    // Map of Case TeamRole Name to TeamRole Id
    for (CaseTeamRole objCaseTeamRole : [SELECT Id, Name FROM CaseTeamRole]) {
      mapRoleCaseTeamRole.put(objCaseTeamRole.Name, objCaseTeamRole.Id);
    }

    for (Case currentEntry : admissionEntry) {
      LstProgramFacility.add(currentEntry.UAC_programFacility__c);
    }

    for (AccountTeamMember ATM :
        [SELECT Id, UserId, TeamMemberRole, AccountId from AccountTeamMember where AccountId
          In:LstProgramFacility
          and TeamMemberRole IN('Lead Case Manager', 'Lead Clinician', 'Program Support Staff')]) {
      if (MapAccountIdToAccountTeamMember.containsKey(ATM.AccountId)) {
        list<AccountTeamMember> ATMrecord = MapAccountIdToAccountTeamMember.get(ATM.AccountId);
        ATMrecord.add(ATM);
        MapAccountIdToAccountTeamMember.put(ATM.AccountId, ATMrecord);
      } else {
        MapAccountIdToAccountTeamMember.put(ATM.AccountId, new list<AccountTeamMember>{ATM});
      }
    }

    if (MapAccountIdToAccountTeamMember.isEmpty()) {
      return;
    }

    for (Case currentCase : admissionEntry) {
      for (AccountTeamMember currentATM :
          MapAccountIdToAccountTeamMember.get(currentCase.UAC_programFacility__c)) {
        // If there are no ATM to a Program of AdmissionEntry, then skip to next
        // iteration
        if (currentATM == null) {
          continue;
        }
        CaseTeamMember CTM = new CaseTeamMember();
        CTM.ParentId = currentCase.id;
        CTM.MemberId = currentATM.UserId;
        CTM.TeamRoleId = mapRoleCaseTeamRole.get(currentATM.TeamMemberRole);
        LstCaseTeamMember.add(CTM);
      }
    }

    if (!LstCaseTeamMember.isEmpty()) {
      insert LstCaseTeamMember;
    }
  }

  /**
   * @description ORRUAC-254 - Dupilcate check for TransferRequest Case.
   * @author Chaitanya Nandamuri (Deloitte) | 07/29/2020
   * @param List<Case> caseList
   * @
   **/
  public
  static void duplicateCheckTransferRequest(List<case> transferRequest) {
    Map<String, List<case>> mapCaseExistingTransferReq =
        queryExistingTransferRequest(transferRequest, strRelationSibling);
    for (Case newTransferReq : transferRequest) {
      if (String.isBlank(newTransferReq.ParentId)) {
        newTransferReq.addError(Label.UC_lookupCheckTR);
        continue;
      }
      if (mapCaseExistingTransferReq.containsKey(
              newTransferReq.parentId + '.' + newTransferReq.RecordTypeId)) {
        newTransferReq.addError(Label.UC_dupCheckTR);
      }
    }
  }

  /**
   * @description ORRUAC-254 - AutoPopulate UAC Health fields from health tab.
   * @author Chaitanya Nandamuri (Deloitte) | 07/30/2020
   * @param List<Case> caseList
   * @
   **/
  private
  static void populateHealthFieldsOnTransferRequest(List<case> newtransferRequest,
      Map<Id, UAC_healthEvaluation__c> mapContactIdToHealth,
      Map<Id, Case> ParentCaseId) {

    if (mapContactIdToHealth.isEmpty()) {
      return;
    }

    for (UAC_healthEvaluation__c queriedEvaluation : [
           SELECT Id,
           UAC_associatedUAC__c,
           UAC_measuredHeightInches__c,
           UAC_weightPounds__c FROM UAC_healthEvaluation__c WHERE UAC_associatedUAC__c
           IN:mapContactIdToHealth.Keyset() AND RecordType.DeveloperName
            =:Label.UAC_healthEvaluationRecordTypeApiNameIME ORDER BY CreatedDate ASC
         ]) {

      mapContactIdToHealth.put(queriedEvaluation.UAC_associatedUAC__c, queriedEvaluation);
    }

    for (case ParentCase :
        [select id, UAC_programFacility__c from Case where Id In:ParentCaseId.keyset()]) {
      ParentCaseId.put(ParentCase.Id, ParentCase);
    }

    for (Case newTransfer : newtransferRequest) {

      newTransfer.UAC_currentProgram__c =
          ParentCaseId.get(newTransfer.ParentId).UAC_programFacility__c;
      if (newTransfer.UAC_caseManagerRecommendation__c != null) {
        newTransfer.UAC_caseManagerRecommendationDate__c = system.now();
      }

      if (mapContactIdToHealth.get(newTransfer.ContactId) == null) {
        continue;
      }
      newTransfer.UAC_heightFtInches__c =
          mapContactIdToHealth.get(newTransfer.ContactId).UAC_measuredHeightInches__c;
      newTransfer.UAC_weightPounds__c =
          mapContactIdToHealth.get(newTransfer.ContactId).UAC_weightPounds__c;
    }
  }

  /**
   * @description ORRUAC-254 - Sets fields on Transfer Request insert
   * @author James Qian (Deloitte) | 10/22/2020
   * @param List<Case> CaseList
   * @
   **/
  public
  static void setFieldsOnTransferRequestInsert(List<Case> transferRequest) {
    Map<Id, Case> mapParentCase = new Map<Id, Case>();
    Map<Id, UAC_healthEvaluation__c> mapContactIdtoUACHealth =
        new Map<Id, UAC_healthEvaluation__c>();
    Map<Id, Case> mapParentCaseIdtoRecord = new Map<Id, Case>();
    for (Case newTransferReq : transferRequest) {
      if (String.isBlank(newTransferReq.ParentId)) {
        continue;
      }
      mapParentCase.put(newTransferReq.ParentId, null);
      mapContactIdtoUACHealth.put(newTransferReq.ContactId, null);
      mapParentCaseIdtoRecord.put(newTransferReq.ParentId, null);
    }
    if (mapParentCase.isEmpty()) {
      return;
    }
    for (Case caseCurrent :
        [SELECT Id, UAC_admittedDateTime__c FROM Case WHERE Id IN:mapParentCase.keyset()]) {
      mapParentCase.put(caseCurrent.Id, caseCurrent);
    }
    for (Case newTransferReq : transferRequest) {
      if (String.isBlank(newTransferReq.ParentId)) {
        continue;
      }
      if (mapParentCase.containsKey(newTransferReq.ParentId)) {
        newTransferReq.UAC_admittedDateTime__c =
            mapParentCase.get(newTransferReq.ParentId).UAC_admittedDateTime__c;
      }
    }
    populateHealthFieldsOnTransferRequest(
        transferRequest, mapContactIdtoUACHealth, mapParentCaseIdtoRecord);
  }

  /**
   * @description ORRUAC-254 - Update date fields on Transfer Request Case.
   * @author Chaitanya Nandamuri (Deloitte) | 07/30/2020
   * Chaitanya Nandamuri (Deloitte) | 08/18/2020 - ORRUAC-1849
   * @author Chaitanya N (Deloitte) | 8/28/2020 ORRUAC-1843
   * @param List<Case> caseList
   * @
   **/
  public
  static void updateTransferRequestFields(
      Map<Id, case> newtransferRequest, Map<Id, case> oldTransferRequest) {
    List<case> lstTransferApprovedcases = new List<Case>();
    List<Case> lstInfluxORRApproved = new List<Case>();
    List<Case> lstInfluxORRNotApproved = new List<case>();
    Map<Id, contact> mapUacToUpdateStatusToTransferPending = new Map<Id, contact>();

    for (Case newTransfer : newtransferRequest.values()) {
      Case oldTransferCase = oldTransferRequest.get(newTransfer.Id);

      if (newTransfer.UAC_caseCoordinatorRecommendation__c
          != oldTransferCase.UAC_caseCoordinatorRecommendation__c) {
        newTransfer.UAC_caseCoordinatorRecommendationDate__c = system.now();
      }
      if (newTransfer.UAC_caseManagerRecommendation__c
          != oldTransferCase.UAC_caseManagerRecommendation__c) {
        newTransfer.UAC_caseManagerRecommendationDate__c = system.now();
      }
      if (newTransfer.UAC_orrDecision__c != oldTransferCase.UAC_orrDecision__c) {
        newTransfer.UAC_orrFinalDecisionDate__c = system.now();
        if (newTransfer.UAC_orrDecision__c == strTransferApprovedORRDecision) {
          lstTransferApprovedcases.add(newTransfer);
          if (newTransfer.RecordTypeId == InfluxTransferRequestTypeId) {
            lstInfluxORRApproved.add(newTransfer);
            mapUacToUpdateStatusToTransferPending.put(newTransfer.ContactId, null);
          }
        } else {
          if (newTransfer.RecordTypeId == InfluxTransferRequestTypeId) {
            lstInfluxORRNotApproved.add(newTransfer);
          }
        }
      }
    }
    newAdmissionEntry(lstTransferApprovedcases, newtransferRequest);
    updateStatusOnUAC(mapUacToUpdateStatusToTransferPending);
    createGroupEmailRecordsforLNODecision(
        lstInfluxORRApproved, strTransferApprovedORRDecision, Label.UAC_TransferRequestInflux);
    createGroupEmailRecordsforLNODecision(
        lstInfluxORRNotApproved, '', Label.UAC_TransferRequestInflux);
  }
  /**
   * @description ORRUAC-1843 -  update Status to Transfer Pending on related UAC (Profile) record
   *when Transfer Request Influx record has been approved.
   * @author Chaitanya Nandamuri (Deloitte) | 08/28/2020
   * @param Map<Id, contact> ContactId
   * @
   **/
  private
  static void updateStatusOnUAC(Map<Id, Contact> mapOfUAC) {
    if (mapOfUAC.keyset().isempty()) {
      return;
    }
    for (contact UAC : [select id, UAC_status__c from contact where Id In:mapOfUAC.keySet()]) {
      UAC.UAC_status__c = strUACstatusTransferPending;
      mapOfUAC.put(UAC.Id, UAC);
    }
    update mapOfUAC.values();
  }

  /**
   * @description ORRUAC-1094 - Status mapping from Transfer Case to UAC
   * @author James Qian (Deloitte) | 08/06/2020
   * @param Map<Id, Case> newtransferRequest
   * @param Map<Id, Case> oldTransferRequest
   **/
  public
  static void checkTransferRequestsForParentUACStatusUpdate(
      Map<Id, Case> newtransferRequest, Map<Id, Case> oldTransferRequest) {
    List<Case> listCaseForContactStatusSync = new List<Case>();
    for (Case newTransfer : newtransferRequest.values()) {
      Case oldTransferCase = oldTransferRequest.get(newTransfer.Id);
      if (newTransfer.Status == Label.UAC_caseStatusCompleted
          && newTransfer.Status != oldTransferCase.Status
          && newTransfer.UAC_orrDecision__c == Label.UAC_orrDecisionTransferApproved) {
        listCaseForContactStatusSync.add(newTransfer);
      }
    }
    if (!listCaseForContactStatusSync.isEmpty()) {
      syncContactStatusWithCaseStatusTransfer(listCaseForContactStatusSync);
    }
  }

  /**
   * @description ORRUAC-254 - Query Existing TransferRequest Records.
   * @author Chaitanya Nandamuri (Deloitte) | 07/29/2020
   * @author Chaitanya Nandamuri (Deloitte) | 08/20/2020- ORRUAC-1846 Adding type Parameter, so it
   *  can query Existing Sibling/Child based on Type String
   * @param List<Case> caseList
   * @
   **/
  private
  static Map<String, List<case>> queryExistingTransferRequest(
      List<case> transferRequest, String Type) {
    Set<Id> setParentCases = new Set<Id>();

    Map<String, List<case>> existingTransferRequestCase = new Map<String, List<case>>();

    for (Case transferReq : transferRequest) {
      setParentCases.add(Type == strRelationSibling ? transferReq.ParentId : transferReq.Id);
    }

    for (Case siblingTransferCase :
        [select id, RecordTypeId, parentId from Case where parentId In:setParentCases]) {
      string strKey = siblingTransferCase.parentId + '.' + siblingTransferCase.RecordTypeId;
      list<case> TRequest = new List<case>();
      if (existingTransferRequestCase.containskey(strKey)) {
        TRequest = existingTransferRequestCase.get(strKey);
      }
      TRequest.add(siblingTransferCase);
      existingTransferRequestCase.put(strKey, TRequest);
    }

    return existingTransferRequestCase;
  }

  /**
   * @description ORRUAC-1094: Query open sibling cases
   * @author James Qian (Deloitte) | 08/06/2020
   * @param Set<ID> setParentContactIds
   * @
   **/
  private
  static Map<String, List<case>> queryOpenSiblingCases(List<Case> listCases) {
    Set<Id> setParentContacts = new Set<Id>();
    Map<String, List<Case>> mapOpenSiblings = new Map<String, List<Case>>();
    for (Case caseCurrent : listCases) {
      if (String.isNotBlank(caseCurrent.ContactId)) {
        setParentContacts.add(caseCurrent.ContactId);
      }
    }
    if (setParentContacts.isEmpty()) {
      return mapOpenSiblings;
    }
    List<String> listCaseRecordTypes = new List<String>{Label.UAC_caseRecordTypeReleaseRequest,
        Label.UAC_caseRecordTypeDischargeNotification,
        Label.UAC_caseRecordTypeAdmission,
        Label.UAC_caseTransferRequest,
        Label.UAC_referralRecordTypeName};
    for (Case caseOpenSibling : [
           SELECT Id,
           RecordType.DeveloperName,
           ContactId FROM Case WHERE ContactId
           IN:setParentContacts AND IsClosed = false AND RecordType.DeveloperName
           IN:listCaseRecordTypes
         ]) {
      String strKey = caseOpenSibling.ContactId + '.' + caseOpenSibling.RecordType.DeveloperName;
      List<Case> listCaseOpenSiblings = new List<Case>();
      if (mapOpenSiblings.containskey(strKey)) {
        listCaseOpenSiblings = mapOpenSiblings.get(strKey);
      }
      listCaseOpenSiblings.add(caseOpenSibling);
      mapOpenSiblings.put(strKey, listCaseOpenSiblings);
    }
    return mapOpenSiblings;
  }

  /* @description ORRUAC-324 - Method updates Case owner and Case status on
   *insert
   * @author Rahul Roy (Deloitte) | 6/1/2020
   * @param lstNewCases Case record to check
   * @return Boolean
   **/
  /* /* Not in use ORRUAC-4116
 public
 static void updateCaseOwner(List<Case> lstNewCases) {
   for (Case newCase : lstNewCases) {
     if (newCase.UAC_pendingInformation__c == 'Yes') {
       // newCase.Status = strCMtoProvideInfo;
       newCase.OwnerId = newCase.UAC_caseManager__c;
     }
     if (newCase.UAC_remandForFurtherInformation__c == 'Yes') {
       // newCase.Status = strCMtoProvideInfo;
       newCase.OwnerId = newCase.UAC_caseManager__c;
     }
   }
 }
 */
  /* @description ORRUAC-324 - Method updates Case owner and Case status on
   *update
   * @author Rahul Roy (Deloitte) | 6/1/2020
   * @param map of new and old Case record
   * @return Boolean
   **/
  /* Not in use ORRUAC-4116
 public
 static void updateCaseOwnerOnUpdate(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
   List<Case> lstCase = new List<Case>();
   Map<Id, Case> mapOldCaseObj = (Map<Id, Case>) mapOldCases;
   Map<Id, Case> mapNewCaseObj = (Map<Id, Case>) mapNewCases;
   for (Case objCase : mapNewCaseObj.values()) {
     if (objCase.UAC_pendingInformation__c
         != mapOldCaseObj.get(objCase.Id).UAC_pendingInformation__c) {
       lstCase.add(objCase);
     }
     if (objCase.UAC_remandForFurtherInformation__c
         != mapOldCaseObj.get(objCase.Id).UAC_remandForFurtherInformation__c) {
       lstCase.add(objCase);
     }
   }
   updateCaseOwner(lstCase);
 }*/
  /* @description ORRUAC-436 - Method checks if the Sponsor application is
   *closed as Sponsor Withdrew and update Adult Contact Relationship
   * @author Vaibhav Kudesia (Deloitte) 6/9/2020
   * @param map of new and old Case record map
   * @return None
   **/
  public
  static void upsdatesponsorrelation(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    list<UAC_adultContactRelationship__c> objAdultConRel =
        new list<UAC_adultContactRelationship__c>();
    String ProfileName =
        [SELECT Id, Name FROM Profile WHERE Id =:userinfo.getProfileId() LIMIT 1].Name;
    for (Case objCase : (list<Case>) newItems.values()) {
      if (objCase.RecordTypeId
              == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
                  Label.UAC_caseRecordTypeApiNameSponsorApplication)
          && objCase.Status == Label.UAC_caseStatusSponsorWithdrew && objCase.isclosed == true) {
        objAdultConRel.add(
            new UAC_adultContactRelationship__c(Id = objCase.UAC_relationshipToUAC__c,
                UAC_relationshipType__c = Label.UAC_relationshipTypePreviousSponsor));
      }
      if (objCase.RecordTypeId
              == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
                  Label.UAC_caseRecordTypeApiNameSponsorApplication)
          && ((Case) oldItems.get(objCase.Id)).Status == Label.UAC_caseStatusSponsorWithdrew) {
        objCase.addError(Label.UAC_sponsorCaseAlreadyClosed);
      }

      // Nithin: ORRUAC-168 FFS Status Update Change on Adult Contact Relationship
      if (objCase.RecordTypeId
              == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
                  Label.UAC_caseRecordTypeApiNameSponsorApplication)
          && objCase.Status == Label.UAC_sponsorApplicationStatusFFSDecisionDoNotProceed
          && ((Case) oldItems.get(objCase.Id)).Status != objCase.Status
          && (ProfileName == Label.UAC_profileFFS
              || ProfileName == Label.UAC_profileFFSSupervisor)) {
        objAdultConRel.add(
            new UAC_adultContactRelationship__c(Id = objCase.UAC_relationshipToUAC__c,
                UAC_relationshipType__c = Label.UAC_relationshipTypePreviousSponsor));
      } else if (objCase.RecordTypeId
              == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
                  Label.UAC_caseRecordTypeApiNameSponsorApplication)
          && ((Case) oldItems.get(objCase.Id)).Status
              == Label.UAC_sponsorApplicationStatusFFSDecisionDoNotProceed
          && objCase.Status == Label.UAC_caseActiveStatusList
          && (ProfileName == Label.UAC_profileFFS
              || ProfileName == Label.UAC_profileFFSSupervisor)) {
        objAdultConRel.add(
            new UAC_adultContactRelationship__c(Id = objCase.UAC_relationshipToUAC__c,
                UAC_relationshipType__c = Label.UAC_relationshipTypePrimarySponsor));
      }
    }
    if (objAdultConRel.size() > 0) {
      update objAdultConRel;
    }
  }

  /* @description ORRUAC-387 - Method checks if there are Active application for
   *linked Sponsor Adult Contact Relationship
   * @author Vaibhav Kudesia (Deloitte) 6/1/2020
   * @param map of new Case record
   * @return None
   **/
  public
  static void checkPreviousApplications(List<Case> lstNewCases) {
    Map<Id, Case> lstSponsorRelCase = new Map<Id, Case>();
    List<Id> lstAdultContactRelationshipId = New List<Id>();
    for (Case objCase : lstNewCases) {
      if (objCase.RecordTypeId
          == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
              Label.UAC_caseRecordTypeApiNameSponsorApplication)) {
        lstSponsorRelCase.put(objCase.UAC_relationshipToUAC__c, objCase);
        lstAdultContactRelationshipId.add(objCase.UAC_relationshipToUAC__c);
      }
    }
    for (Case objCase : [
           Select Id,
           Status,
           UAC_relationshipToUAC__c from Case where UAC_relationshipToUAC__c
           =:lstSponsorRelCase.keySet() AND isClosed = False AND Recordtype.developername
           =:Label.UAC_caseRecordTypeApiNameSponsorApplication
         ]) {
      lstSponsorRelCase.get(objCase.UAC_relationshipToUAC__c).addError(Label.UAC_activeCaseExists);
    }
    // Manoj: ORRUAC-1020 Code Start  herer
    if (!lstAdultContactRelationshipId.IsEmpty()) {
      Map<Id, UAC_adultContactRelationship__c> MapAdultContactRelationship =
          New Map<Id, UAC_adultContactRelationship__c>([Select Id,
            UAC_dateAssignedAsPrimarySponsor__c from UAC_adultContactRelationship__c where Id
            in:lstAdultContactRelationshipId]);
      for (Case objCase : lstNewCases) {
        if (objCase.RecordTypeId
                == UAC_CaseUtilities.getRecordTypeIdByDeveloperName(
                    Label.UAC_CaseRecordTypeApiNameSponsorApplication)
            && MapAdultContactRelationship.Containskey(objCase.UAC_relationshipToUAC__c)) {
          if (MapAdultContactRelationship.get(objCase.UAC_relationshipToUAC__c)
                  .UAC_dateAssignedAsPrimarySponsor__c
              != null) {
            objCase.UAC_initialSponsorAssessmentDueDate__c =
                MapAdultContactRelationship.get(objCase.UAC_relationshipToUAC__c)
                    .UAC_dateAssignedAsPrimarySponsor__c
                + 5;
          }
        }
      }
    }
    // Manoj: ORRUAC-1020 Code ends  herer
  }

  /**
   * @description ORRUAC-125: Auto-populate FRP Date Sent to Sponsor when FRP
   *Deliver Method is set.
   * @author Sachet Khanal (Deloitte) | 6/3/2020
   * @param lstNewCase List of new Case records
   * @param mapOldCase Map of old Case records
   * @return void
   **/
  public
  static void populateFRPDateSentToSponsor(List<Case> lstNewCase, Map<Id, Case> mapOldCase) {
    for (Case objNewCase : lstNewCase) {
      Case objOldCase = (mapOldCase != null) ? mapOldCase.get(objNewCase.Id) : null;
      if (objNewCase.UAC_frpDeliveryMethod__c != null
          && (objOldCase == null
              || objOldCase.UAC_frpDeliveryMethod__c != objNewCase.UAC_frpDeliveryMethod__c)) {
        objNewCase.UAC_frpDateSentToSponsor__c = Date.today();
      }
    }
  }
  /* @description ORRUAC-319 - Method updates CM/CC Recommendation Date after
   *Submission o
   * @author Manoj Sharma (Deloitte) 6/2/2020
   * update ORRUAC-1944 - added AC2, AC3 - Piyush Pranav 8/22/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void updateCMCCRecommendationDate(
      Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    List<Case> lstCase = new List<Case>();
    Map<Id, Case> mapOldCaseObj = (Map<Id, Case>) mapOldCases;
    Map<Id, Case> mapNewCaseObj = (Map<Id, Case>) mapNewCases;
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    for (Case objCase : mapNewCaseObj.values()) {
      Case objOldCase = (mapOldCaseObj != null) ? mapOldCaseObj.get(objCase.Id) : null;

      // ORRUAC 1944 AC 2, AC 3 Start
      if (objCase.recordTypeId == idRelReqRecType) {
        if (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
            || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)) {
          if ((objCase.UAC_caseManagerRecommendation__c == Label.UAC_approveStraightRelease
                  || objCase.UAC_caseManagerRecommendation__c == strDenyRelease
                  || objCase.UAC_caseManagerRecommendation__c
                      == strApproveWithPostReleaseOnlyServices
                  || objCase.UAC_caseManagerRecommendation__c == strConductHomeStudyTVPRA
                  || objCase.UAC_caseManagerRecommendation__c == strConductHomeStudyORRMandated
                  || objCase.UAC_caseManagerRecommendation__c == strConductHomeStudyDiscretionary)
              && objOldCase.Status != objCase.Status
              && objOldCase.Status == Label.UAC_ReleaseRequestStatusCMInitiated
              && objCase.Status == strReleaseRequestStatusCCReview) {
            objCase.UAC_caseManagerRecommendationDate__c = System.Now();
          }
          if ((objCase.UAC_caseManagerRecommendationHS__c
                      == strApproveWithPostReleaseServicesAfterORRMandated
                  || objCase.UAC_caseManagerRecommendationHS__c
                      == strApproveWithPostReleaseServicesAfterDiscretionary
                  || objCase.UAC_caseManagerRecommendationHS__c
                      == strApproveWithPostReleaseServicesTVPRA
                  || objCase.UAC_caseManagerRecommendationHS__c == strDenyRelease)
              && objOldCase.Status != objCase.Status
              && objOldCase.Status == Label.UAC_caseStatusHSCompletedCMReview
              && objCase.Status == label.UAC_caseStatusHSCompletedCCReview) {
            objCase.UAC_rrCaseManagerRecommendationDateHs__c = System.Now();
          }
        }
        if (FeatureManagement.checkPermission(strCustomPermissionCC)) {
          if ((objCase.UAC_caseCoordinatorRecommendation__c == Label.UAC_approveStraightRelease
                  || objCase.UAC_caseCoordinatorRecommendation__c == strDenyRelease
                  || objCase.UAC_caseCoordinatorRecommendation__c
                      == strApproveWithPostReleaseOnlyServices
                  || objCase.UAC_caseCoordinatorRecommendation__c == strConductHomeStudyTVPRA
                  || objCase.UAC_caseCoordinatorRecommendation__c == strConductHomeStudyORRMandated
                  || objCase.UAC_caseCoordinatorRecommendation__c
                      == strConductHomeStudyDiscretionary)
              && objOldCase.Status != objCase.Status
              && objOldCase.Status == strReleaseRequestStatusCCReview
              && objCase.Status == strReleaseRequestStatusFFSReview) {
            objCase.UAC_caseCoordinatorRecommendationDate__c = System.Now();
          }
          if ((objCase.UAC_caseCoordinatorRecommendationHS__c
                      == strApproveWithPostReleaseServicesAfterORRMandated
                  || objCase.UAC_caseCoordinatorRecommendationHS__c
                      == strApproveWithPostReleaseServicesAfterDiscretionary
                  || objCase.UAC_caseCoordinatorRecommendationHS__c
                      == strApproveWithPostReleaseServicesTVPRA
                  || objCase.UAC_caseCoordinatorRecommendationHS__c == strDenyRelease)
              && objOldCase.Status != objCase.Status
              && objOldCase.Status == Label.UAC_caseStatusHSCompletedCCReview
              && objCase.Status == Label.UAC_caseStatusHSCompletedFFSReview) {
            objCase.UAC_rrCaseCoordinatorRecomDtHs__c = System.Now();
          }
        }
      }
      // ORRUAC 1944 AC 2, AC 3 End

      if (objCase.recordTypeId == idRelReqRecType
          && objCase.Status != mapOldCaseObj.get(objCase.Id).Status
          && objCase.UAC_caseManagerRecommendationHS__c != ''
          && objCase.UAC_caseManagerRecommendationHS__c != null
          && objCase.UAC_caseManagerRecommendation__c != 'Conduct Home Study-TVPRA'
          && objCase.UAC_caseManagerRecommendation__c != 'Conduct Home Study-ORR Mandated'
          && objCase.UAC_caseManagerRecommendation__c != 'Conduct Home Study-Discretionary'
          && objCase.Status == strReleaseRequestStatusCCReview
          && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager))) {
        objCase.UAC_caseManagerRecommendationDate__c = System.Now();
      }
      if (objCase.recordTypeId == idRelReqRecType
          && objCase.Status != mapOldCaseObj.get(objCase.Id).Status
          && objCase.Status == strReleaseRequestStatusFFSReview
          && objCase.UAC_caseCoordinatorRecommendationHS__c != ''
          && objCase.UAC_caseCoordinatorRecommendationHS__c != null
          && objCase.UAC_caseCoordinatorRecommendation__c != 'Conduct Home Study-TVPRA'
          && objCase.UAC_caseCoordinatorRecommendation__c != 'Conduct Home Study-ORR Mandated'
          && objCase.UAC_caseCoordinatorRecommendation__c != 'Conduct Home Study-Discretionary'
          && (FeatureManagement.checkPermission(strCustomPermissionCC)
              || FeatureManagement.checkPermission(strCustomPermissionDOC)
              || FeatureManagement.checkPermission(strCustomPermissionSCC))) {
        objCase.UAC_caseCoordinatorRecommendationDate__c = System.Now();
      }
    }
  }

  /* @description ORRUAC-321 - Method updates Status to ORR Initiated
   * @author Manoj Sharma (Deloitte) 6/2/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void setStausToORRInitiated(List<Case> lstNewCasess) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    for (Case objCase : lstNewCasess) {
      if (objCase.recordTypeId == idRelReqRecType
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        objCase.status = strReleaseRequestStatusORRInitiated;
      }
    }
  }

  /* @description ORRUAC-309 -  Auto Populate Sponsor related Fields
   * @author Manoj Sharma (Deloitte) 6/6/2020
   * @param List of new and old Case record
   * @return None
   **/
  public
  static void setSponsor(List<Case> lstNewCasess, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    Set<Id> setContactIds = new set<Id>();

    Map<Id, UAC_adultContactRelationship__c> mapContactPrimarySponsor =
        new Map<Id, UAC_adultContactRelationship__c>();
    Map<Id, Id> mapUACContact = new Map<Id, Id>();
    for (Case objCase : lstNewCasess) {
      Case objOldCase = (mapOldCase != null) ? mapOldCase.get(objCase.Id) : null;
      if (objCase.recordTypeId == idRelReqRecType
              && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
              && objCase.ContactId != null
          || (objOldCase != null
              && objOldCase.UAC_typeOfRelease__c != objCase.UAC_typeOfRelease__c)) {
        setContactIds.add(objCase.ContactId);
      }

      if (objCase.recordTypeId == idRelReqRecType
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoProgram
          && objCase.ContactId != null && objOldCase != null
          && objOldCase.UAC_typeOfRelease__c != objCase.UAC_typeOfRelease__c) {
        objCase.UAC_sponsor__c = null;
      }
    }
    List<Id> lstContactIds = new List<Id>(setContactIds);
    for (UAC_adultContactRelationship__c objadultContactRelationship : [
           SELECT Id,
           UAC_adultContact__c,
           UAC_uacLookup__c FROM UAC_adultContactRelationship__c WHERE UAC_uacLookup__c
           in:lstContactIds AND UAC_relationshipType__c
            =:strRelationshipTypePrimarySponso limit 200
         ]) {
      mapContactPrimarySponsor.put(
          objadultContactRelationship.UAC_uacLookup__c, objadultContactRelationship);
      mapUACContact.put(objadultContactRelationship.UAC_adultContact__c,
          objadultContactRelationship.UAC_uacLookup__c);
    }
    // 187 start
    Map<id, Case> mapOfContactIdtoRecord = new Map<id, Case>();

    for (Case objCaseUpdate : [
           SELECT id,
           ContactId,
           Status,
           UAC_finalSponsorAssessmentDateCompleted__c,
           recordtype.Name,
           createddate,
           UAC_sponsor__c FROM Case WHERE UAC_sponsor__c
           in:mapUACContact.keyset() AND recordtype.DeveloperName
            =:strCaseRecordTypeApiNameSponsorApplication AND status =
                  'Open' ORDER BY createddate DESC LIMIT 1
         ]) {
      mapOfContactIdtoRecord.put(objCaseUpdate.UAC_sponsor__c, objCaseUpdate);
    }
    for (Case objCase : lstNewCasess) {
      if (objCase.recordTypeId == idRelReqRecType
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
          && objCase.ContactId != null && mapContactPrimarySponsor.containsKey(objCase.ContactId)) {
        objCase.UAC_sponsor__c =
            mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c;
        objCase.UAC_relationshipToUAC__c = mapContactPrimarySponsor.get(objCase.ContactId).Id;
        if (mapOfContactIdtoRecord.containsKey(
                mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)) {
          objCase.UAC_finalSponsorAssessmentDateCompleted__c =
              mapOfContactIdtoRecord
                  .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                  .UAC_finalSponsorAssessmentDateCompleted__c;
          objCase.UAC_sponsorApplicationStatus__c =
              mapOfContactIdtoRecord
                  .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                  .Status;
        }
      }
    }
  }
  /** @description ORRUAC-405 -  Auto Populate Sponsor related Fields
   * @author Manoj Sharma (Deloitte) 6/6/2020
   * @param Map of new and old Case record
   * @return None
   * revision : AC6 ORRUAC-1217 to include Deny Release in conditions
   **/
  public
  static void createDNF(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();

    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    List<Case> lstDNFCaseInser = new List<Case>();
    Set<Id> setSponserId = new Set<Id>();
    Set<Id> setContacts = new Set<Id>();
    Set<Id> setPrograms = new Set<Id>();
    List<Contact> lstSponsers = new List<Contact>();
    List<Contact> lstContacts = new List<Contact>();
    List<Account> lstPrograms = new List<Account>();
    List<UAC_adultContactRelationship__c> lstRelationship =
        new List<UAC_adultContactRelationship__c>();
    Map<id, map<id, UAC_adultContactRelationship__c>> mapSponsorContactRelationship =
        new Map<id, map<id, UAC_adultContactRelationship__c>>();

    for (Case obC : mapNewCasess.values()) {
      if (obC.recordTypeId == idRelReqRecType && obC.ContactId != null) {
        setContacts.add(obC.ContactId);
      }
      if (obC.recordTypeId == idRelReqRecType
          && obC.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor) {
        if (obC.UAC_sponsor__c != null) {
          setSponserId.add(obC.UAC_sponsor__c);
        }
      } else if (obC.recordTypeId == idRelReqRecType
          && obC.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoProgram) {
        if (obC.UAC_dischargeProgramName__c != null) {
          setPrograms.add(obC.UAC_dischargeProgramName__c);
        }
      }
    }
    lstSponsers = [Select Id,
      Name,
      MailingStreet,
      MailingCity,
      MailingPostalCode,
      MailingState,
      Phone from Contact where Id in:setSponserId];
    lstContacts = [Select Id,
      UAC_program__r.Name,
      UAC_A__c,
      UAC_grantedVoluntaryDepartureDate__c,
      UAC_mppCase__c,
      UAC_separatedFromParentLegalGuardian__c from Contact where id in:setContacts];
    lstPrograms = [Select Id,
      Name,
      ShippingStreet,
      ShippingPostalCode,
      ShippingCity,
      ShippingState,
      Phone from Account where Id in:setPrograms];
    lstRelationship = [
      select id,
      UAC_adultContact__c,
      UAC_uacLookup__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      in:setSponserId and UAC_uacLookup__c
      in:setContacts
    ];

    // Added by ankur for AC6.1 ORRUAC-1561
    for (UAC_adultContactRelationship__c objRelationship : lstRelationship) {
      map<id, UAC_adultContactRelationship__c> mapContactRelationship =
          new map<id, UAC_adultContactRelationship__c>();
      if (mapSponsorContactRelationship.containskey(objRelationship.UAC_adultContact__c))
        mapContactRelationship =
            mapSponsorContactRelationship.get(objRelationship.UAC_adultContact__c);
      if (!mapContactRelationship.containskey(objRelationship.UAC_uacLookup__c))
        mapContactRelationship.put(objRelationship.UAC_uacLookup__c, objRelationship);
      mapSponsorContactRelationship.put(
          objRelationship.UAC_adultContact__c, mapContactRelationship);
    }
    system.debug(mapSponsorContactRelationship);
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      /*
     if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusCompleted
         && objCase.UAC_orrDecision__c == strORRDecisionDenyRelease
         && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
         && objCase.UAC_courtOrderedRelease__c != objOldCase.UAC_courtOrderedRelease__c
         && objCase.UAC_courtOrderedRelease__c == strCourtOrderedReleaseYes
         && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
             || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
       Case objDNFCase = new Case();
       objDNFCase.recordTypeId = idDNFRecType;
       objDNFCase.ParentId = objCase.Id;
       lstDNFCaseInser.add(objDNFCase);
     }*/
      // 403 - Start
      // AC 4  of ORRUAC-403
      if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusDnfGen
          && objOldCase.Status != objCase.Status
          && objOldCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
          && objOldCase.UAC_sponsor__c != null
          && objOldCase.UAC_orrDecision__c == strORRDecisionDenyRelease
          && objCase.UAC_courtOrderedRelease__c == strCourtOrderedReleaseYes
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c =
            objCase.UAC_orrFinalDecisionDate__c;  // ORRUAC-1335-AC1
        for (Contact con : lstSponsers) {
          if (con.Id == objCase.UAC_sponsor__c) {
            objDNFCase.UAC_dischargeAddress__c = con.MailingStreet;
            objDNFCase.UAC_dischargeCity__c = con.MailingCity;
            objDNFCase.UAC_dischargeState__c = stateMap(con.MailingState);
            objDNFCase.UAC_dischargeZipCode__c = con.MailingPostalCode;
            objDNFCase.UAC_dischargePhone__c = con.Phone;
          }
        }
        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objDNFCase.UAC_programFacility__c = con.UAC_program__c;
            objDNFCase.UAC_aNum__c = con.UAC_A__c;
            // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
            objDNFCase.UAC_grantedVoluntaryDepartureDate__c =
                con.UAC_grantedVoluntaryDepartureDate__c;

            if (con.UAC_mppCase__c == true)
              objDNFCase.UAC_isThisAMppCase__c = 'Yes';
            else
              objDNFCase.UAC_isThisAMppCase__c = 'No';
            if (con.UAC_separatedFromParentLegalGuardian__c == true)
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
            else
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
        }
        if (mapSponsorContactRelationship.containskey(objCase.UAC_sponsor__c)) {
          map<id, UAC_adultContactRelationship__c> mapContactRelationship =
              mapSponsorContactRelationship.get(objCase.UAC_sponsor__c);
          if (mapContactRelationship.containskey(objCase.ContactId)) {
            objDNFCase.UAC_relationshipToUAC__c = mapContactRelationship.get(objCase.ContactId).id;
          }
        }
        lstDNFCaseInser.add(objDNFCase);
      }  ////AC 2  of ORRUAC-403
      else if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusDnfGen
          && objOldCase.Status != objCase.Status
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
          && objCase.UAC_sponsor__c != null
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c =
            objCase.UAC_orrFinalDecisionDate__c;  // ORRUAC-1335-AC1
        for (Contact con : lstSponsers) {
          if (con.Id == objCase.UAC_sponsor__c) {
            objDNFCase.UAC_dischargeAddress__c = con.MailingStreet;
            objDNFCase.UAC_dischargeCity__c = con.MailingCity;
            objDNFCase.UAC_dischargeState__c = stateMap(con.MailingState);
            objDNFCase.UAC_dischargeZipCode__c = con.MailingPostalCode;
            objDNFCase.UAC_dischargePhone__c = con.Phone;
          }
        }
        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objDNFCase.UAC_programFacility__c = con.UAC_program__c;
            objDNFCase.UAC_aNum__c = con.UAC_A__c;
            // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
            objDNFCase.UAC_grantedVoluntaryDepartureDate__c =
                con.UAC_grantedVoluntaryDepartureDate__c;

            if (con.UAC_mppCase__c == true)
              objDNFCase.UAC_isThisAMppCase__c = 'Yes';
            else
              objDNFCase.UAC_isThisAMppCase__c = 'No';
            if (con.UAC_separatedFromParentLegalGuardian__c == true)
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
            else
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
        }
        if (mapSponsorContactRelationship.containskey(objCase.UAC_sponsor__c)) {
          map<id, UAC_adultContactRelationship__c> mapContactRelationship =
              mapSponsorContactRelationship.get(objCase.UAC_sponsor__c);
          if (mapContactRelationship.containskey(objCase.ContactId)) {
            objDNFCase.UAC_relationshipToUAC__c = mapContactRelationship.get(objCase.ContactId).id;
          }
        }
        lstDNFCaseInser.add(objDNFCase);
      }  // AC 3  of ORRUAC-403-- AC6 ORRUAC-1217 to include Deny Release in conditions
      else if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusDnfGen
          && objOldCase.Status != objCase.Status
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoProgram
          && (objCase.UAC_orrDecision__c == 'Approve Straight Release'
              || objCase.UAC_orrDecision__c == 'Approve with Post-Release Only Services'
              || objCase.UAC_orrDecision__c == strORRDecisionDenyRelease)
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_dischargeProgramName__c = objCase.UAC_dischargeProgramName__c;
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c =
            objCase.UAC_orrFinalDecisionDate__c;  // ORRUAC-1335-AC1
        for (Account ac : lstPrograms) {
          if (ac.Id == objCase.UAC_dischargeProgramName__c) {
            objDNFCase.UAC_dischargeAddress__c = ac.ShippingStreet;
            objDNFCase.UAC_dischargeCity__c = ac.ShippingCity;
            objDNFCase.UAC_dischargeState__c = stateMap(ac.ShippingState);
            objDNFCase.UAC_dischargeZipCode__c = ac.ShippingPostalCode;
            objDNFCase.UAC_dischargePhone__c = ac.Phone;
          }
        }
        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objDNFCase.UAC_programFacility__c = con.UAC_program__c;
            objDNFCase.UAC_aNum__c = con.UAC_A__c;
            // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
            objDNFCase.UAC_grantedVoluntaryDepartureDate__c =
                con.UAC_grantedVoluntaryDepartureDate__c;

            if (con.UAC_mppCase__c == true)
              objDNFCase.UAC_isThisAMppCase__c = 'Yes';
            else
              objDNFCase.UAC_isThisAMppCase__c = 'No';
            if (con.UAC_separatedFromParentLegalGuardian__c == true)
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
            else
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
        }
        lstDNFCaseInser.add(objDNFCase);
      }  // AC 11  of ORRUAC-1432
      else if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusDnfGen
          && objOldCase.Status != objCase.Status
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
          && (objCase.UAC_orrDecisionHS__c
                  == 'Approve with Post-Release Services-After ORR Mandated'
              || objCase.UAC_orrDecisionHS__c
                  == 'Approve with Post-Release Services-After Discretionary'
              || objCase.UAC_orrDecisionHS__c == 'Approve with Post-Release Services-TVPRA')
          && objCase.UAC_dischargeProgramName__c != null
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c =
            objCase.UAC_orrFinalDecisionDate__c;  // ORRUAC-1335-AC1
        for (Contact con : lstSponsers) {
          if (con.Id == objCase.UAC_sponsor__c) {
            objDNFCase.UAC_dischargeAddress__c = con.MailingStreet;
            objDNFCase.UAC_dischargeCity__c = con.MailingCity;
            objDNFCase.UAC_dischargeState__c = stateMap(con.MailingState);
            objDNFCase.UAC_dischargeZipCode__c = con.MailingPostalCode;
            objDNFCase.UAC_dischargePhone__c = con.Phone;
          }
        }
        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objDNFCase.UAC_programFacility__c = con.UAC_program__c;
            objDNFCase.UAC_aNum__c = con.UAC_A__c;
            // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
            objDNFCase.UAC_grantedVoluntaryDepartureDate__c =
                con.UAC_grantedVoluntaryDepartureDate__c;

            if (con.UAC_mppCase__c == true)
              objDNFCase.UAC_isThisAMppCase__c = 'Yes';
            else
              objDNFCase.UAC_isThisAMppCase__c = 'No';
            if (con.UAC_separatedFromParentLegalGuardian__c == true)
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
            else
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
        }
        if (mapSponsorContactRelationship.containskey(objCase.UAC_sponsor__c)) {
          map<id, UAC_adultContactRelationship__c> mapContactRelationship =
              mapSponsorContactRelationship.get(objCase.UAC_sponsor__c);
          if (mapContactRelationship.containskey(objCase.ContactId)) {
            objDNFCase.UAC_relationshipToUAC__c = mapContactRelationship.get(objCase.ContactId).id;
          }
        }
        lstDNFCaseInser.add(objDNFCase);
      }  ////AC 2  of ORRUAC-403
      else if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusDnfGen
          && objOldCase.Status != objCase.Status
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
          && objCase.UAC_sponsor__c != null
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c =
            objCase.UAC_orrFinalDecisionDate__c;  // ORRUAC-1335-AC1
        for (Contact con : lstSponsers) {
          if (con.Id == objCase.UAC_sponsor__c) {
            objDNFCase.UAC_dischargeAddress__c = con.MailingStreet;
            objDNFCase.UAC_dischargeCity__c = con.MailingCity;
            objDNFCase.UAC_dischargeState__c = stateMap(con.MailingState);
            objDNFCase.UAC_dischargeZipCode__c = con.MailingPostalCode;
            objDNFCase.UAC_dischargePhone__c = con.Phone;
          }
        }
        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objDNFCase.UAC_programFacility__c = con.UAC_program__c;
            objDNFCase.UAC_aNum__c = con.UAC_A__c;
            // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
            objDNFCase.UAC_grantedVoluntaryDepartureDate__c =
                con.UAC_grantedVoluntaryDepartureDate__c;

            if (con.UAC_mppCase__c == true)
              objDNFCase.UAC_isThisAMppCase__c = 'Yes';
            else
              objDNFCase.UAC_isThisAMppCase__c = 'No';
            if (con.UAC_separatedFromParentLegalGuardian__c == true)
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
            else
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
        }
        if (mapSponsorContactRelationship.containskey(objCase.UAC_sponsor__c)) {
          map<id, UAC_adultContactRelationship__c> mapContactRelationship =
              mapSponsorContactRelationship.get(objCase.UAC_sponsor__c);
          if (mapContactRelationship.containskey(objCase.ContactId)) {
            objDNFCase.UAC_relationshipToUAC__c = mapContactRelationship.get(objCase.ContactId).id;
          }
        }
        lstDNFCaseInser.add(objDNFCase);
      }  // AC 3  of ORRUAC-1561 Added by Ankur
      else if (objCase.recordTypeId == idRelReqRecType && objCase.Status == strCaseStatusDnfGen
          && objOldCase.UAC_courtOrderedRelease__c != objCase.UAC_courtOrderedRelease__c
          && objCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
          && (objCase.UAC_orrDecision__c == 'Conduct Home Study-ORR Mandated'
              || objCase.UAC_orrDecision__c == 'Conduct Home Study-Discretionary'
              || objCase.UAC_orrDecision__c == 'Conduct Home Study-TVPRA')
          && objCase.UAC_orrDecisionHS__c == 'Deny Release'
          && objCase.UAC_courtOrderedRelease__c == 'Yes'
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c = objCase.UAC_orrFinalDecisionDate__c;
        for (Contact con : lstSponsers) {
          if (con.Id == objCase.UAC_sponsor__c) {
            objDNFCase.UAC_dischargeAddress__c = con.MailingStreet;
            objDNFCase.UAC_dischargeCity__c = con.MailingCity;
            objDNFCase.UAC_dischargeState__c = stateMap(con.MailingState);
            objDNFCase.UAC_dischargeZipCode__c = con.MailingPostalCode;
            objDNFCase.UAC_dischargePhone__c = con.Phone;
          }
        }
        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objDNFCase.UAC_programFacility__c = con.UAC_program__c;
            objDNFCase.UAC_aNum__c = con.UAC_A__c;
            // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
            objDNFCase.UAC_grantedVoluntaryDepartureDate__c =
                con.UAC_grantedVoluntaryDepartureDate__c;

            if (con.UAC_mppCase__c == true)
              objDNFCase.UAC_isThisAMppCase__c = 'Yes';
            else
              objDNFCase.UAC_isThisAMppCase__c = 'No';
            if (con.UAC_separatedFromParentLegalGuardian__c == true)
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
            else
              objDNFCase.UAC_parentalLegalGuardianSeparation__c = 'No';
          }
        }
        lstDNFCaseInser.add(objDNFCase);
      }  // end- AC 3  of ORRUAC-1561 Added by Ankur
    }
    system.debug('lstDNFCaseInser size:' + lstDNFCaseInser.size());
    insert lstDNFCaseInser;
  }

  /* @description Internal method for State API mapping
   * @author Piyush(deloitte) 6/22
   * @param String name of State
   * @return String String State API
   **/
  public
  static String stateMap(String fullstate) {
    String abbr;
    if (fullstate == 'Alabama') abbr = 'AL';
    if (fullstate == 'Alaska') abbr = 'AK';
    if (fullstate == 'Arizona') abbr = 'AZ';
    if (fullstate == 'Arkansas') abbr = 'AR';
    if (fullstate == 'California') abbr = 'CA';
    if (fullstate == 'Colorado') abbr = 'CO';
    if (fullstate == 'Connecticut') abbr = 'CT';
    if (fullstate == 'Delaware') abbr = 'DE';
    if (fullstate == 'Florida') abbr = 'FL';
    if (fullstate == 'Georgia') abbr = 'GA';
    if (fullstate == 'Hawaii') abbr = 'HI';
    if (fullstate == 'Idaho') abbr = 'ID';
    if (fullstate == 'Illinois') abbr = 'IL';
    if (fullstate == 'Indiana') abbr = 'IN';
    if (fullstate == 'Iowa') abbr = 'IA';
    if (fullstate == 'Kansas') abbr = 'KS';
    if (fullstate == 'Kentucky') abbr = 'KY';
    if (fullstate == 'Louisiana') abbr = 'LA';
    if (fullstate == 'Maine') abbr = 'ME';
    if (fullstate == 'Maryland') abbr = 'MD';
    if (fullstate == 'Massachusetts') abbr = 'MA';
    if (fullstate == 'Michigan') abbr = 'MI';
    if (fullstate == 'Minnesota') abbr = 'MN';
    if (fullstate == 'Mississippi') abbr = 'MS';
    if (fullstate == 'Missouri') abbr = 'MO';
    if (fullstate == 'Montana') abbr = 'MT';
    if (fullstate == 'Nebraska') abbr = 'NE';
    if (fullstate == 'Nevada') abbr = 'NV';
    if (fullstate == 'New Hampshire') abbr = 'NH';
    if (fullstate == 'New Jersey') abbr = 'NJ';
    if (fullstate == 'New Mexico') abbr = 'NM';
    if (fullstate == 'New York') abbr = 'NY';
    if (fullstate == 'North Carolina') abbr = 'NC';
    if (fullstate == 'North Dakota') abbr = 'ND';
    if (fullstate == 'Ohio') abbr = 'OH';
    if (fullstate == 'Oklahoma') abbr = 'OK';
    if (fullstate == 'Oregon') abbr = 'OR';
    if (fullstate == 'Pennsylvania') abbr = 'PA';
    if (fullstate == 'Rhode Island') abbr = 'RI';
    if (fullstate == 'South Carolina') abbr = 'SC';
    if (fullstate == 'South Dakota') abbr = 'SD';
    if (fullstate == 'Tennessee') abbr = 'TN';
    if (fullstate == 'Texas') abbr = 'TX';
    if (fullstate == 'Utah') abbr = 'UT';
    if (fullstate == 'Vermont') abbr = 'VT';
    if (fullstate == 'Virginia') abbr = 'VA';
    if (fullstate == 'Washington') abbr = 'WA';
    if (fullstate == 'West Virginia') abbr = 'WV';
    if (fullstate == 'Wisconsin') abbr = 'WI';
    if (fullstate == 'Wyoming') abbr = 'WY';
    return abbr;
  }

  /**
   * @description ORRUAC-435: Auto-populate Application Completion Date when
   *Sponsor Application Case Status is Complete.
   * @author Karthi Subramanian (Deloitte) | 6/4/2020
   * @param lstNewCase List of new Case records
   * @param mapOldCase Map of old Case records
   * @return void
   **/
  public
  static void populateAppCompletionDate(List<Case> lstNewCase, Map<Id, Case> mapOldCase) {
    for (Case objNewCase : lstNewCase) {
      Case objOldCase = (mapOldCase != null) ? mapOldCase.get(objNewCase.Id) : null;
      if (objNewCase.RecordTypeId
          == UAC_caseUtilities.getRecordTypeIdByDeveloperName(
              Label.UAC_caseRecordTypeApiNameSponsorApplication)) {
        if (objNewCase.Status != null && objOldCase != null
            && (objOldCase.Status != objNewCase.Status
                && objNewCase.Status == strSponsorAppCompletionStatus)) {
          objNewCase.UAC_applCompletionDate__c = Date.today();
        }
        if ((objNewCase.Status != null)
            && (objOldCase == null && objNewCase.Status == strSponsorAppCompletionStatus)) {
          objNewCase.UAC_applCompletionDate__c = Date.today();
        }
      }
    }
  }

  /* @description ORRUAC-401 - Method updates Final date on ORR Completed Status
   * @author Rahul Roy (Deloitte) 6/8/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void setDateOnORRDecisionSubmission(
      Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    Map<Id, Case> mapOldCaseObj = (Map<Id, Case>) mapOldCases;
    Map<Id, Case> mapNewCaseObj = (Map<Id, Case>) mapNewCases;
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    for (Case objCase : mapNewCaseObj.values()) {
      if (objCase.recordTypeId == idRelReqRecType
          && objCase.Status != mapOldCaseObj.get(objCase.Id).Status
          && (objCase.Status == strCaseStatusCompleted || objCase.Status == strCaseStatusDnfGen)
          && (objCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesAfterORRMandated
              || objCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesTVPRA
              || objCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesAfterDiscretionary
              || objCase.UAC_orrDecisionHS__c == strDenyRelease
              || objCase.UAC_orrDecision__c == strORRDecisionDenyRelease
              || objCase.UAC_orrDecision__c == strApproveWithPostReleaseOnlyServices
              || objCase.UAC_orrDecision__c == Label.UAC_approveStraightRelease)
          && (FeatureManagement.checkPermission(strCustomPermissionFFS)
              || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
        objCase.UAC_orrFinalDecisionDate__c = System.now();
      }
    }
  }

  /**
   * @description ORRUAC-1099: Automatic DOC, CFS, FFS supervisor update. Refactored for
   *ORRUAC-5562.
   * @author Piyush (Deloitte) | 6/16/2020
   * @param newItems Trigger.NewMap
   * @param oldItems Trigger.olMap
   * @return void
   **/
  public
  static void updateDocCfsFfs(Map<Id, Case> newCastItems, Map<Id, Case> oldCastItems) {
    System.debug('@@ inside updateDocCfsFfs trigger');
    Map<Id, Id> mapProgramToCFS = new Map<Id, Id>();
    Map<Id, Id> mapCCToDOC = new Map<Id, Id>();
    Map<Id, Id> mapFFSToSupervisor = new Map<Id, Id>();

    for (UAC_assignmentMapping__c objMapping : [
           Select Id,
           UAC_facilityName__c,
           UAC_mappingCC__c,
           UAC_mappingcfs__c,
           UAC_mappingDOC__c,
           UAC_mappingFFS__c,
           UAC_mappingFFSSupervisor__c from UAC_assignmentMapping__c
         ]) {
      mapProgramToCFS.put(objMapping.UAC_facilityName__c, objMapping.UAC_mappingcfs__c);
      mapCCToDOC.put(objMapping.UAC_mappingCC__c, objMapping.UAC_mappingDOC__c);
      mapFFSToSupervisor.put(objMapping.UAC_mappingFFS__c, objMapping.UAC_mappingFFSSupervisor__c);
    }

    for (Case obCase : newCastItems.values()) {
      if (FeatureManagement.checkPermission(strCustomPermissionFFSS)
          || FeatureManagement.checkPermission(strCustomPermissionFFS)
          || FeatureManagement.checkPermission(strCustomPermissionCaseManager)
          || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)) {
        System.debug('@@ inside logged in as CM');
        System.debug('@@ program facility' + obCase.UAC_programFacility__c);
        if (obCase.UAC_programFacility__c != null
            && mapProgramToCFS.containsKey(obCase.UAC_programFacility__c)) {
          obCase.UAC_cfsName__c = mapProgramToCFS.get(obCase.UAC_programFacility__c);
        }
        if (obCase.UAC_caseCoordinator__c != null
            && mapCCToDOC.containsKey(obCase.UAC_caseCoordinator__c)) {
          obCase.UAC_directOperationsCoordinator__c = mapCCToDOC.get(obCase.UAC_caseCoordinator__c);
        }
      }
      if (FeatureManagement.checkPermission(strCustomPermissionCC)
          || FeatureManagement.checkPermission(strCustomPermissionDOC)
          || FeatureManagement.checkPermission(strCustomPermissionFFS)
          || FeatureManagement.checkPermission(strCustomPermissionCaseManager)) {
        if (obCase.UAC_ffsName__c != null
            && mapFFSToSupervisor.containsKey(obCase.UAC_ffsName__c)) {
          obCase.UAC_ffsSupervisor__c = mapFFSToSupervisor.get(obCase.UAC_ffsName__c);
        }
      }
    }
  }

  /* @description ORRUAC-187 - Method populates Program Facility
   * @author Rahul Roy (Deloitte) 6/17/2020
   * @param list of new Case records
   * @return None
   **/
  public
  static void setProgramFacility(List<Case> lstNewCases) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    List<id> lstOfcontactIdOnCases = new List<Id>();
    Map<id, contact> mapOfContactIdtoRecord = new Map<id, contact>();

    for (Case objCase : lstNewCases) {
      lstOfcontactIdOnCases.add(objCase.ContactId);
    }

    for (contact objCon :
        [select id, UAC_A__c, FirstName, LastName, AccountId, UAC_program__c from contact where Id
          In:lstOfcontactIdOnCases]) {
      mapOfContactIdtoRecord.put(objCon.id, objCon);
    }

    if (!mapOfContactIdtoRecord.isEmpty()) {
      for (Case newCase : lstNewCases) {
        if (newCase.recordTypeId == idRelReqRecType
            && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS))) {
          newCase.UAC_programFacility__c =
              mapOfContactIdtoRecord.get(newCase.ContactId).UAC_program__c;
        }
      }
    }
  }

  /* @description ORRUAC-187 - Changes to Release Request
   * @author Rahul Roy (Deloitte) 6/19/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void changesToReleaseRequest(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    Map<Id, Case> mapNewCaseCasted = (Map<Id, Case>) mapNewCases;

    Map<id, case> mapOfParentIdToCase = new Map<id, case>();

    for (Case objCase : [
           SELECT id,
           ContactId,
           Status,
           ParentId,
           recordtype.DeveloperName,
           createddate FROM Case WHERE ParentId
           in:mapNewCaseCasted.keyset() AND RecordType.DeveloperName
            =:strCaseRecordTypeDischargeNotification
         ]) {
      mapOfParentIdToCase.put(objCase.ParentId, objCase);
    }

    if (!mapOfParentIdToCase.isEmpty()) {
      for (Case newCase : mapNewCaseCasted.values()) {
        if (newCase.recordTypeId == idRelReqRecType && mapOfParentIdToCase.containsKey(newCase.Id)
            && mapOfParentIdToCase.get(newCase.Id).Status == strCaseStatusDischargeCompleted
            && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionFFSS)
                || FeatureManagement.checkPermission(strCustomPermissionCC)
                || FeatureManagement.checkPermission(strCustomPermissionDOC)
                || FeatureManagement.checkPermission(strCustomPermissionSCC)
                || FeatureManagement.checkPermission(strCustomPermissionCFS))) {
          newCase.addError(strDischargedError);
        }
      }
    }
  }
  /** @description ORRUAC-403 & 1301 - update Status to DNF Generated
   * @author Manoj Sharma (Deloitte) 6/24/2020
   * updated for ORRUAC-2091 AC3 Piyush - 08272020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void updateStatusDNFGenerated(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idRelReqRecType && objOldCase.Status == strCaseStatusCompleted
          && objOldCase.UAC_courtOrderedRelease__c != objCase.UAC_courtOrderedRelease__c
          && objCase.UAC_courtOrderedRelease__c == strCourtOrderedReleaseYes
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        if ((objOldCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
                && objOldCase.UAC_sponsor__c != null)
            || (objOldCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoProgram
                   && objOldCase.UAC_dischargeProgramName__c != null)
                && objOldCase.UAC_orrDecision__c == strORRDecisionDenyRelease) {
          objCase.status = strCaseStatusDnfGen;
        }
        // ORRUAC-2091 AC3 - Start
        else if (objOldCase.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor
            && objOldCase.UAC_orrDecisionHS__c == strORRDecisionDenyRelease
            && (objOldCase.UAC_orrDecision__c == strConductHomeStudyORRMandated
                || objOldCase.UAC_orrDecision__c == strConductHomeStudyTVPRA
                || objOldCase.UAC_orrDecision__c == strConductHomeStudyDiscretionary)) {
          objCase.status = strCaseStatusDnfGen;
        }
        // ORRUAC-2091 AC3 End
      }
    }
  }

  /* @description ORRUAC-617 AC-11 AC10 AC 14
   * Added AC 8 AC 14 for US-1430
   * @author Piyush (Deloitte) 6/25/2020
   * @param map of new and old Case record
   * @author Satish Kota (Kvortex) 11/11/2020
   * User Story :: ORRUAC-4129
   * Added Logic to Update Disccharge Notification Complete fiels on Contact
   * @author Satish Kota (Deloitte) 03/02/2021 ORRUAC-5323
   * User Story :: ORRUAC-5323
   * Added If condition when updating Admitted date of contact
   * @return None
   **/
  public
  static void DNFTaskCreation(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();

    Id idNotificationType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                .get(strnotificationRecordtypeTask)
                                .getRecordTypeId();

    list<task> lstTask = new list<task>();
    Set<Id> setParentIds = new Set<Id>();
    Set<Id> setContacts = new Set<Id>();
    List<Case> lstParent = new List<Case>();
    List<Contact> lstUACContactToUpdate = new List<Contact>();
    List<Contact> lstUACContact = new List<Contact>();
    Map<Id, Case> mapParent = new Map<Id, Case>();
    Map<Id, Contact> mapContact = new Map<Id, Contact>();
    UAC_BusinessDaysUtility utilBusinessInstance = new UAC_BusinessDaysUtility();
    Datetime dtNxtBussDttime = utilBusinessInstance.addDays(system.today(), 30);
    Date dtNxtBussDt = dtNxtBussDttime.dateGmt();
    system.debug('@@ business date after 30 days ' + dtNxtBussDt);

    // Gather the list of Parent Ids & Contact Ids for DNF
    for (Case obC : mapNewCase.values()) {
      if (obC.recordTypeId == idDNFRecType) {
        if (obC.ParentId != null) {
          setParentIds.add(obC.ParentId);
        }
        if (obC.ContactId != null) {
          setContacts.add(obC.ContactId);
        }
      }
    }

    // Array of Parent Cases with CM, LCM information
    lstParent =
        [Select Id, UAC_caseManager__c, UAC_leadCaseManager__c from Case where id in:setParentIds];
    for (Case cse : lstParent) {
      mapParent.put(cse.Id, cse);
    }

    lstUACContact =
        [Select Id, UAC_status__c, UAC_dischargeDateforMostRecentORRStay__c from Contact where Id
          in:setContacts];
    for (Contact con : lstUACContact) {
      mapContact.put(con.Id, con);
    }

    for (Case objCase : mapNewCase.values()) {
      Case objOld = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idDNFRecType && objCase.Status != objOld.Status
          && objCase.Status == strCaseStatusDischargeCompleted) {
        // AC 8 US-1430 start
        if (objCase.ContactId != null) {
          if (objCase.UAC_typeOfDischarge__c == strDischrTypeDNF) {
            Contact conToUpdate = mapContact.get(objCase.ContactId);
            conToUpdate.UAC_status__c = strInTransferStatus;
            conToUpdate.UAC_dischargeNotificationCompleted__c = true;  // US:: ORRUAC-4129
            lstUACContactToUpdate.add(conToUpdate);
          }       // AC 8 US-1430 End
          else {  // AC 14 US-617 start
            Contact conToUpdate = mapContact.get(objCase.ContactId);
            conToUpdate.UAC_status__c = 'Discharged';
            if (objCase.UAC_typeOfDischarge__c != strDischrTypeDNF) {
              conToUpdate.UAC_dischargeDateforMostRecentORRStay__c =
                  objCase.UAC_dateTimeOfDischarge__c.date();
            }
            lstUACContactToUpdate.add(conToUpdate);
          }  // AC 14 US-617 End
        }
        // AC 14 US-1430 AC 11 617 Start
        if (objCase.ParentId != null
            && (objCase.UAC_typeOfDischarge__c == strDnfTODRIS
                || objCase.UAC_typeOfDischarge__c == strDnfTODRSP
                || objCase.UAC_typeOfDischarge__c == strDnfTODCORS)) {
          Task objTask = new Task();
          Task objTaskLcm = new Task();

          objTask.recordtypeid = idNotificationType;
          objTask.Subject = 'Please complete the Safety and Well-Being Follow-up Call Report '
              + objCase.CaseNumber;
          objTask.whatid = objCase.id;
          objTask.OwnerId = mapParent.get(objCase.ParentId).UAC_caseManager__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority;
          objTask.Activitydate = dtNxtBussDt;

          objTaskLcm.recordtypeid = idNotificationType;
          objTaskLcm.Subject = 'Please complete the Safety and Well-Being Follow-up Call Report '
              + objCase.CaseNumber;
          objTaskLcm.whatid = objCase.id;
          objTaskLcm.OwnerId = mapParent.get(objCase.ParentId).UAC_leadCaseManager__c;
          objTaskLcm.Status = strNotStartedSatus;
          objTaskLcm.Priority = strHighPriority;
          objTaskLcm.Activitydate = dtNxtBussDt;

          lstTask.add(objTask);
          lstTask.add(objTaskLcm);
        }  // AC 14 US-1430 AC 11 617 End
      }
    }
    if (!lstTask.isEmpty()) {
      try {
        insert lstTask;
      } catch (DMLException e) {
        UAC_errorLog.logError(
            e.getMessage(), '', 'Case Trigger Task Creation', e.getStackTraceString());
      }
    }
    if (!lstUACContactToUpdate.isEmpty()) {
      try {
        System.debug('@@ contact to udpate' + lstUACContactToUpdate);
        update lstUACContactToUpdate;
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Case Trigger UAC Contact Discharge status update',
            e.getStackTraceString());
      }
    }
  }

  /** @description ORRUAC-617 AC1,AC3,AC10 on update
   * @author Piyush(Deloitte) 6/26/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void saveDNFVal(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    Set<Id> setPrograms = new Set<Id>();
    List<Account> lstPrograms = new List<Account>();

    for (Case obC : mapNewCase.values()) {
      if (obC.recordTypeId == idDNFRecType && obC.UAC_dischargeProgramName__c != null) {
        setPrograms.add(obC.UAC_dischargeProgramName__c);
      }
    }

    lstPrograms = [Select Id,
      Name,
      ShippingStreet,
      ShippingPostalCode,
      ShippingCity,
      ShippingState,
      Phone from Account where Id in:setPrograms];

    for (Case objCase : mapNewCase.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idDNFRecType && objCase.UAC_dischargeProgramName__c != null) {
        for (Account ac : lstPrograms) {
          if (ac.Id == objCase.UAC_dischargeProgramName__c) {
            objCase.UAC_dischargeAddress__c = ac.ShippingStreet;
            objCase.UAC_dischargeCity__c = ac.ShippingCity;
            objCase.UAC_dischargeState__c = stateMap(ac.ShippingState);
            objCase.UAC_dischargeZipCode__c = ac.ShippingPostalCode;
            objCase.UAC_dischargePhone__c = ac.Phone;
          }
        }
      }
      // AC 10 start
      if (objCase.recordTypeId == idDNFRecType && objCase.Status == strCaseStatusDischargeCompleted
          && objCase.Status != objOldCase.Status) {
        objCase.UAC_dateTimeOfDischarge__c = System.now();
      }
      // AC 10 End
    }

    for (Case objCase : mapNewCase.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.UAC_dnfRunawayTime__c != null
          && objCase.UAC_dnfRunawayTime__c.addDays(1) > System.now()) {
        objCase.UAC_typeOfDischarge__c.addError(
            'Please wait 24 hours before saving the Discharge Notification');
      } else {
        if (objCase.recordTypeId == idDNFRecType
            && objOldCase.UAC_typeOfDischarge__c != objCase.UAC_typeOfDischarge__c
            && (objCase.UAC_typeOfDischarge__c == strDischrTypeRunFac
                || objCase.UAC_typeOfDischarge__c == strDischrTypeRunField)) {
          objCase.UAC_dnfRunawayTime__c = System.now();
        }
      }
    }
  }

  /** @description ORRUAC-617 AC1,AC3 on insert
   * @author Piyush(Deloitte) 6/26/2020
   * @param Trigger.new Cases
   * @return None
   **/
  public
  static void setDNFVal(List<Case> lstNewCase) {
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    Set<Id> setPrograms = new Set<Id>();
    List<Account> lstPrograms = new List<Account>();
    Set<Id> setContact = new Set<Id>();
    Map<String, Case> mapContactCaseAdmission = new Map<String, Case>();
    Map<Id, Id> mapContactIdToProgramId = new Map<Id, Id>();

    Map<Id, Contact> mapContactIdContact = new Map<Id, contact>();

    for (Case obC : lstNewCase) {
      if (obC.UAC_dischargeProgramName__c != null) {
        setPrograms.add(obC.UAC_dischargeProgramName__c);
      }
      setContact.add(obC.ContactId);
    }

    if (!setPrograms.isEmpty()) {
      lstPrograms = [Select Id,
        Name,
        ShippingStreet,
        ShippingPostalCode,
        ShippingCity,
        ShippingState,
        Phone from Account where Id in:setPrograms];
    }
    // ORRUAC-2294
    if (!setContact.isEmpty()) {
      for (Contact contactCurrent : [SELECT Id,
             UAC_program__c,
             UAC_grantedVoluntaryDepartureDate__c,
             UAC_mppCase__c,
             UAC_techUACReferralId__c,
             UAC_separatedFromParentLegalGuardian__c FROM Contact WHERE Id IN:setContact]) {
        mapContactIdToProgramId.put(contactCurrent.Id, contactCurrent.UAC_program__c);
        mapContactIdContact.put(contactCurrent.Id, contactCurrent);
      }
    }

    // ORRUAC-1217 AC1
    for (Case objAdmission : [Select Id,
           ContactId,
           UAC_programFacility__c,
           UAC_admittedDateTime__c from Case where RecordType.DeveloperName =
               'UAC_Admission' and ContactId in:setContact]) {
      mapContactCaseAdmission.put(
          objAdmission.ContactId + '-' + objAdmission.UAC_programFacility__c, objAdmission);
    }

    for (Case objCase : lstNewCase) {
      if (objCase.UAC_dischargeProgramName__c != null) {
        for (Account ac : lstPrograms) {
          if (ac.Id == objCase.UAC_dischargeProgramName__c) {
            objCase.UAC_dischargeAddress__c = ac.ShippingStreet;
            objCase.UAC_dischargeCity__c = ac.ShippingCity;
            objCase.UAC_dischargeState__c = stateMap(ac.ShippingState);
            objCase.UAC_dischargeZipCode__c = ac.ShippingPostalCode;
            objCase.UAC_dischargePhone__c = ac.Phone;
          }
        }
      }
      // ORRUAC-1217 AC1
      if (mapContactCaseAdmission.containsKey(
              objCase.ContactId + '-' + objCase.UAC_programFacility__c)) {
        objCase.UAC_admittedDateTime__c =
            mapContactCaseAdmission.get(objCase.ContactId + '-' + objCase.UAC_programFacility__c)
                .UAC_admittedDateTime__c;
        // Added by Ankur Aggarwal ( deloitte) for ORRUAC-1988
        if (mapContactIdContact.containskey(objCase.ContactId)) {
          Contact CurrentContact = mapContactIdContact.get(objCase.ContactId);
          objCase.UAC_grantedVoluntaryDepartureDate__c =
              CurrentContact.UAC_grantedVoluntaryDepartureDate__c;
          // Added for ORRUAC-4573
          objCase.UAC_referral__c = CurrentContact.UAC_techUACReferralId__c;
          if (CurrentContact.UAC_mppCase__c == true)
            objCase.UAC_isThisAMppCase__c = 'Yes';
          else
            objCase.UAC_isThisAMppCase__c = 'No';
          if (CurrentContact.UAC_separatedFromParentLegalGuardian__c == true)
            objCase.UAC_parentalLegalGuardianSeparation__c = 'Yes';
          else
            objCase.UAC_parentalLegalGuardianSeparation__c = 'No';
        }
      }
      // ORRUAC-2294
      if (mapContactIdToProgramId.containsKey(objCase.ContactId)
          && String.isNotBlank(mapContactIdToProgramId.get(objCase.ContactId))) {
        objCase.UAC_currentProgram__c = mapContactIdToProgramId.get(objCase.ContactId);
      }
    }

    for (Case objCase : lstNewCase) {
      if (objCase.UAC_dnfRunawayTime__c != null
          && objCase.UAC_dnfRunawayTime__c.addDays(1) > System.now()) {
        objCase.UAC_typeOfDischarge__c.addError(
            'Please wait 24 hours before saving the Discharge Notification');
      } else {
        if (objCase.recordTypeId == idDNFRecType
            && (objCase.UAC_typeOfDischarge__c == strDischrTypeRunFac
                || objCase.UAC_typeOfDischarge__c == strDischrTypeRunField)) {
          objCase.UAC_dnfRunawayTime__c = System.now();
        }
      }
    }
  }

  /** @description ORRUAC-187 - update Pending Info and Remand Info
   * @author Rahul Roy (Deloitte) 6/25/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void updatePendingInfoAndRemandInfoToNull(
      Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idRelReqRecType && objCase.Status != objOldCase.Status
          && objCase.Status == strReleaseRequestStatusCCReview
          && objOldCase.Status == strCMtoProvideInfo
          && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager))) {
        objCase.UAC_pendingInformation__c = Null;
      }
      if (objCase.recordTypeId == idRelReqRecType && objCase.Status != objOldCase.Status
          && objCase.Status == strReleaseRequestStatusFFSReview
          && objOldCase.Status == strCMtoProvideInfo
          && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager))) {
        objCase.UAC_remandForFurtherInformation__c = Null;
      }
    }
  }

  /** @description ORRUAC-1179 - Set Case Team
   * @author Manoj Sharma (Deloitte) 6/24/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void updateCaseTeam(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    Id idHSPRSRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeHSPRSReferral).getRecordTypeId();
    Map<String, CaseTeamRole> mapRoleCaseTeamRole = new Map<String, CaseTeamRole>();
    Map<String, CaseTeamMember> mapMemIdTRIdCaseTeam = new Map<String, CaseTeamMember>();
    map<String, String> mapDuplicateCheck = New Map<String, String>();
    // List<CaseTeamMember> lstCaseTeamRoleDelete = new List<CaseTeamMember>();
    List<Id> lstCaseTeamRoleDeleteIds = new List<Id>();
    List<CaseTeamMember> lstCaseTeamMemberInsert = New List<CaseTeamMember>();
    for (CaseTeamRole objCaseTeamRole :
        [SELECT Id, Name, PreferencesVisibleInCSP FROM CaseTeamRole]) {
      mapRoleCaseTeamRole.put(objCaseTeamRole.Name, objCaseTeamRole);
    }
    for (CaseTeamMember objCaseTeamMember :
        [SELECT Id, MemberId, ParentId, TeamRoleId FROM CaseTeamMember where ParentId
          =:mapNewCasess.keyset()]) {
      mapMemIdTRIdCaseTeam.put(objCaseTeamMember.MemberId + '-' + objCaseTeamMember.ParentId + '-'
              + objCaseTeamMember.TeamRoleId,
          objCaseTeamMember);
      mapDuplicateCheck.put(objCaseTeamMember.MemberId, objCaseTeamMember.MemberId);
    }

    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = (mapOldCase != null) ? mapOldCase.get(objCase.Id) : null;
      if (objCase.recordTypeId == idRelReqRecType || objCase.recordTypeId == idDNFRecType
          || objCase.recordTypeId == idHSPRSRecType) {  // added || objCase.recordTypeId ==
                                                        // idHSPRSRecType for ORRUAC-3577
        // For Case Manager
        if (objCase.UAC_caseManager__c != null
            && (objOldCase == null || objCase.UAC_caseManager__c != objOldCase.UAC_caseManager__c)
            && mapRoleCaseTeamRole.containsKey(strCaseTeamRoleNameCM)) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_caseManager__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameCM).Id;

          if (!mapDuplicateCheck.containsKey(objCase.UAC_caseManager__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_caseManager__c, objCase.UAC_caseManager__c);
            if (objOldCase != null
                && mapDuplicateCheck.containsKey(objOldCase.UAC_caseManager__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_caseManager__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_caseManager__c + '-' + objCase.Id
                  + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCM).Id)) {
            // lstCaseTeamRoleDelete.add(mapMemIdTRIdCaseTeam.get(objOldCase.UAC_CaseManager__c +
            // '-'
            //    + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCM).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_CaseManager__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCM).Id)
                    .Id);
          }
        }
        // For Lead Case Manager
        if (objCase.UAC_leadCaseManager__c != null
            && (objOldCase == null
                || objCase.UAC_leadCaseManager__c != objOldCase.UAC_leadCaseManager__c)
            && mapRoleCaseTeamRole.containsKey(strCaseTeamRoleNameLCM)) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_leadCaseManager__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameLCM).Id;

          if (!mapDuplicateCheck.containsKey(objCase.UAC_leadCaseManager__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_leadCaseManager__c, objCase.UAC_leadCaseManager__c);
            if (objOldCase != null
                && mapDuplicateCheck.containsKey(objOldCase.UAC_leadCaseManager__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_leadCaseManager__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_leadCaseManager__c + '-'
                  + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameLCM).Id)) {
            // lstCaseTeamRoleDelete.add(mapMemIdTRIdCaseTeam.get(objOldCase.UAC_leadCaseManager__c
            //     + '-' + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameLCM).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_leadCaseManager__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameLCM).Id)
                    .Id);
          }
        }
        // for Case Coordinator
        if (objCase.UAC_caseCoordinator__c != null
            && (objOldCase == null
                || objCase.UAC_caseCoordinator__c != objOldCase.UAC_caseCoordinator__c)
            && mapRoleCaseTeamRole.containsKey(strCaseTeamRoleNameCC)) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_caseCoordinator__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameCC).Id;
          if (!mapDuplicateCheck.containsKey(objCase.UAC_caseCoordinator__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_caseCoordinator__c, objCase.UAC_caseCoordinator__c);
            if (objOldCase != null
                && mapDuplicateCheck.containsKey(objOldCase.UAC_caseCoordinator__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_caseCoordinator__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_caseCoordinator__c + '-'
                  + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCC).Id)) {
            // lstCaseTeamRoleDelete.add(mapMemIdTRIdCaseTeam.get(objOldCase.UAC_CaseCoordinator__c
            //     + '-' + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCC).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_CaseCoordinator__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCC).Id)
                    .Id);
          }
        }
        // for Direct Operations Coordinator
        if (objCase.UAC_directOperationsCoordinator__c != null
            && (objOldCase == null
                || objCase.UAC_directOperationsCoordinator__c
                    != objOldCase.UAC_directOperationsCoordinator__c)
            && mapRoleCaseTeamRole.containsKey('Direct Operations Coordinator')) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_directOperationsCoordinator__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameDOC).Id;
          if (!mapDuplicateCheck.containsKey(objCase.UAC_directOperationsCoordinator__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_directOperationsCoordinator__c,
                objCase.UAC_directOperationsCoordinator__c);
            if (objOldCase != null
                && mapDuplicateCheck.containsKey(objOldCase.UAC_directOperationsCoordinator__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_directOperationsCoordinator__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_directOperationsCoordinator__c
                  + '-' + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameDOC).Id)) {
            // lstCaseTeamRoleDelete.add(
            //   mapMemIdTRIdCaseTeam.get(objOldCase.UAC_directOperationsCoordinator__c + '-'
            //      + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameDOC).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_directOperationsCoordinator__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameDOC).Id)
                    .Id);
          }
        }
        // for UAC_cfsName__c
        if (objCase.UAC_cfsName__c != null
            && (objOldCase == null || objCase.UAC_cfsName__c != objOldCase.UAC_cfsName__c)
            && mapRoleCaseTeamRole.containsKey(strCaseTeamRoleNameCFS)) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_cfsName__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameCFS).Id;
          if (!mapDuplicateCheck.containsKey(objCase.UAC_cfsName__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_cfsName__c, objCase.UAC_cfsName__c);
            if (objOldCase != null && mapDuplicateCheck.containsKey(objOldCase.UAC_cfsName__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_cfsName__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_cfsName__c + '-' + objCase.Id + '-'
                  + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCFS).Id)) {
            // lstCaseTeamRoleDelete.add(mapMemIdTRIdCaseTeam.get(objOldCase.UAC_cfsName__c + '-'
            //    + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCFS).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_cfsName__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameCFS).Id)
                    .Id);
          }
        }
        // for Federal Field Specialist
        if (objCase.UAC_ffsName__c != null
            && (objOldCase == null || objCase.UAC_ffsName__c != objOldCase.UAC_ffsName__c)
            && mapRoleCaseTeamRole.containsKey(strCaseTeamRoleNameFFS)) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_ffsName__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFS).Id;
          if (!mapDuplicateCheck.containsKey(objCase.UAC_ffsName__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_ffsName__c, objCase.UAC_ffsName__c);
            if (objOldCase != null && mapDuplicateCheck.containsKey(objOldCase.UAC_ffsName__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_ffsName__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_ffsName__c + '-' + objCase.Id + '-'
                  + mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFS).Id)) {
            // lstCaseTeamRoleDelete.add(mapMemIdTRIdCaseTeam.get(objOldCase.UAC_ffsName__c + '-'
            //    + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFS).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_ffsName__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFS).Id)
                    .Id);
          }
        }
        // for Federal Field Specialist Supervisor
        if (objCase.UAC_ffsSupervisor__c != null
            && (objOldCase == null
                || objCase.UAC_ffsSupervisor__c != objOldCase.UAC_ffsSupervisor__c)
            && mapRoleCaseTeamRole.containsKey(strCaseTeamRoleNameFFSS)) {
          CaseTeamMember objCaseTeamMember = new CaseTeamMember();
          objCaseTeamMember.MemberId = objCase.UAC_ffsSupervisor__c;
          objCaseTeamMember.ParentId = objCase.Id;
          objCaseTeamMember.TeamRoleId = mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFSS).Id;
          if (!mapDuplicateCheck.containsKey(objCase.UAC_ffsSupervisor__c)) {
            lstCaseTeamMemberInsert.add(objCaseTeamMember);
            mapDuplicateCheck.put(objCase.UAC_ffsSupervisor__c, objCase.UAC_ffsSupervisor__c);
            if (objOldCase != null
                && mapDuplicateCheck.containsKey(objOldCase.UAC_ffsSupervisor__c)) {
              mapDuplicateCheck.remove(objOldCase.UAC_ffsSupervisor__c);
            }
          }
          if (objOldCase != null
              && mapMemIdTRIdCaseTeam.containsKey(objOldCase.UAC_ffsSupervisor__c + '-' + objCase.Id
                  + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFSS).Id)) {
            // lstCaseTeamRoleDelete.add(mapMemIdTRIdCaseTeam.get(objOldCase.UAC_ffsSupervisor__c +
            // '-'
            //    + objCase.Id + '-' + mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFSS).Id));
            lstCaseTeamRoleDeleteIds.add(
                mapMemIdTRIdCaseTeam
                    .get(objOldCase.UAC_ffsSupervisor__c + '-' + objCase.Id + '-'
                        + mapRoleCaseTeamRole.get(strCaseTeamRoleNameFFSS).Id)
                    .Id);
          }
        }
      }
    }
    try {

      if (!lstCaseTeamMemberInsert.IsEmpty()) {
        insert lstCaseTeamMemberInsert;
      }
      if (!lstCaseTeamRoleDeleteIds.isEmpty()) {
        deleteCaseTeam(lstCaseTeamRoleDeleteIds);
      }
    } catch (DmlException e) {
      // mapNewCasess.values()[0].addError(e.getDmlMessage(0));
      UAC_errorLog.logError(
          e.getMessage(), '', 'Update Case Team on Release Request', e.getDmlMessage(0));
    }
  }
  /**
   * @description ORRUAC-3571- Method to delete Case team in future
   * @author Manoj Sharma (Deloitte) | 11/3/2020
   * @param lstDeleteCaseTeamIds: Ids of Case Team Member
   * @return void
   **/
  @future public static void deleteCaseTeam(List<Id> lstDeleteCaseTeamIds) {
    List<CaseTeamMember> lstCaseTeamRoleDelete = new List<CaseTeamMember>();
    for (Id IdCaseTeam : lstDeleteCaseTeamIds) {
      CaseTeamMember objCaseTeamMember = New CaseTeamMember(Id = IdCaseTeam);
      lstCaseTeamRoleDelete.add(objCaseTeamMember);
    }
    try {
      if (!lstCaseTeamRoleDelete.isEmpty()) {
        Delete lstCaseTeamRoleDelete;
      }
    } catch (DmlException e) {
      UAC_errorLog.logError(
          e.getMessage(), '', 'Update Case Team on Release Request', e.getDmlMessage(0));
    }
  }

  /** @description ORRUAC-872 update HS/PRS Referral Case Owner to Queue
   * @author Manoj Sharma (Deloitte) 7/14/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void updateOwnertoQueueHS(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idHSPRSReferralRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeHSPRSReferral).getRecordTypeId();
    Map<String, Group> mapNameGroup = new Map<String, Group>();
    for (Group objGroup : [
           SELECT DeveloperName,
           Id,
           Name,
           Type FROM Group Where DeveloperName in('UAC_PRS', 'UAC_PRSTVPRA', 'UAC_HS')and Type =
               'Queue' limit 5
         ]) {
      mapNameGroup.put(objGroup.Name, objGroup);
    }
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idHSPRSReferralRecType
          && (objCase.status != objOldCase.Status
              || objCase.UAC_hsPrsQueue__c != objOldCase.UAC_hsPrsQueue__c)
          && objCase.status == strPending && objCase.UAC_hsPrsQueue__c != null
          && mapNameGroup.containsKey(objCase.UAC_hsPrsQueue__c)
          && (FeatureManagement.checkPermission(strCustomPermissionFFS)
              || FeatureManagement.checkPermission(strCustomPermissionCC)
              || FeatureManagement.checkPermission(strCustomPermissionCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionPO))) {
        objCase.OwnerId = mapNameGroup.get(objCase.UAC_hsPrsQueue__c).id;
      }
    }
  }

  /** @description ORRUAC-866 -  Auto generate HSPRS Referral
   * @author Rahul Roy (Deloitte) 7/14/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void createHSPRSReferral(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();

    Id idHSPRSRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeHSPRSReferral).getRecordTypeId();
    List<Case> lstHSPRSCaseInsert = new List<Case>();
    Set<Id> setSponserId = new Set<Id>();
    Set<Id> setContacts = new Set<Id>();
    Set<Id> setPrograms = new Set<Id>();
    List<Contact> lstSponsers = new List<Contact>();
    List<Contact> lstContacts = new List<Contact>();
    List<Account> lstPrograms = new List<Account>();
    for (Case obC : mapNewCasess.values()) {
      if (obC.recordTypeId == idRelReqRecType && obC.ContactId != null) {
        setContacts.add(obC.ContactId);
      }
      if (obC.recordTypeId == idRelReqRecType
          && obC.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoSponsor) {
        if (obC.UAC_sponsor__c != null) {
          setSponserId.add(obC.UAC_sponsor__c);
        }
      } else if (obC.recordTypeId == idRelReqRecType
          && obC.UAC_typeOfRelease__c == strTypeOfReleaseReleasetoProgram) {
        if (obC.UAC_dischargeProgramName__c != null) {
          setPrograms.add(obC.UAC_dischargeProgramName__c);
        }
      }
    }
    lstSponsers = [Select Id,
      Name,
      MailingStreet,
      MailingCity,
      MailingPostalCode,
      MailingState,
      Phone from Contact where Id in:setSponserId];
    lstContacts = [Select Id, UAC_program__r.Name, UAC_A__c from Contact where id in:setContacts];
    lstPrograms = [Select Id,
      Name,
      ShippingStreet,
      ShippingPostalCode,
      ShippingCity,
      ShippingState,
      Phone from Account where Id in:setPrograms];
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idRelReqRecType
          && (objCase.Status == strCaseStatusDnfGen || objCase.Status == strCaseStatusHSRequested)
          && objOldCase.Status != objCase.Status
          && (objCase.UAC_homeStudyAddendum__c == null
              || objCase.UAC_homeStudyAddendum__c == strHomeStudyAddNo)
          && (objCase.UAC_orrDecision__c == strApproveWithPostReleaseOnlyServices
              || objCase.UAC_orrDecision__c == strConductHomeStudyTVPRA
              || objCase.UAC_orrDecision__c == strConductHomeStudyORRMandated
              || objCase.UAC_orrDecision__c == strConductHomeStudyDiscretionary
              || objCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesAfterORRMandated
              || objCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesAfterDiscretionary
              || objCase.UAC_orrDecisionHS__c == strApproveWithPostReleaseServicesTVPRA)
          && (FeatureManagement.checkPermission(strCustomPermissionFFSS)
              || FeatureManagement.checkPermission(strCustomPermissionFFS))) {
        Case objHSPRSCase = new Case();
        objHSPRSCase.Status = strCaseStatusHSPRSReferralInitiation;
        objHSPRSCase.recordTypeId = idHSPRSRecType;
        objHSPRSCase.ParentId = objCase.Id;
        objHSPRSCase.ContactId = objCase.ContactId;
        objHSPRSCase.UAC_caseManager__c = objCase.UAC_caseManager__c;
        objHSPRSCase.UAC_leadCaseManager__c = objCase.UAC_leadCaseManager__c;
        objHSPRSCase.UAC_sponsor__c = objCase.UAC_sponsor__c;
        objHSPRSCase.UAC_relationshipToUAC__c = objCase.UAC_relationshipToUAC__c;

        for (Contact con : lstSponsers) {
          if (con.Id == objCase.UAC_sponsor__c) {
            objHSPRSCase.UAC_dischargeAddress__c = con.MailingStreet;
            objHSPRSCase.UAC_dischargeCity__c = con.MailingCity;
            objHSPRSCase.UAC_dischargeState__c = stateMap(con.MailingState);
            objHSPRSCase.UAC_dischargeZipCode__c = con.MailingPostalCode;
          }
        }

        for (Contact con : lstContacts) {
          if (con.Id == objCase.ContactId) {
            objHSPRSCase.UAC_programFacility__c = con.UAC_program__c;
            objHSPRSCase.UAC_aNum__c = con.UAC_A__c;
          }
        }
        lstHSPRSCaseInsert.add(objHSPRSCase);
      }
    }
    try {
      insert lstHSPRSCaseInsert;
    } catch (DmlException e) {
      mapNewCasess.values()[0].addError(e.getDmlMessage(0));
    }
  }

  /** @description ORRUAC-869 status update on HSPRS Referral
   * @author Rahul Roy (Deloitte) 7/15/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void statusUpdatesHSPRSReferral(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idHSPRSReferralRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeHSPRSReferral).getRecordTypeId();
    List<Case> updateCaseReleaseRequest = new List<Case>();
    List<Contact> updateConTechHsPrs = new List<Contact>();
    UAC_BusinessDaysUtility utilBusinessInstance = new UAC_BusinessDaysUtility();
    Datetime dtNxtBussDttime10 = utilBusinessInstance.addDays(system.today(), 10);
    Date dtNxtBussDt10 = dtNxtBussDttime10.dateGmt();
    Date dtNxtBussDt90 = system.today().addDays(90);
    List<String> lstContactId = New List<String>();
    List<Id> lstSponsorId = New List<Id>();
    List<String> lstUserId = New List<String>();
    List<String> lstCustomPermission =
        New List<String>{strCustomPermissionSupervisor, strCustomPermissionDCW};
    Set<Id> permissionSetIds = new Set<Id>();
    Map<Id, User> MapUser = New Map<Id, User>();
    // ORRUAC-869 AC4
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      // ORRUAC-1431 AC 10 Start
      if (objCase.recordTypeId == idHSPRSReferralRecType && objCase.Status == strHSPRSClosedStatus
          && objCase.Status != objOldCase.Status) {
        objCase.UAC_techHsPrsClosedDateTime__c = System.now();
      }  // ORRUAC-1431 AC 10 End
      if (objCase.recordTypeId == idHSPRSReferralRecType && objCase.OwnerId != objOldCase.OwnerId
          && objCase.OwnerId.getSObjectType().getDescribe().getName() != 'Group'
          && (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider))) {
        lstContactId.add(objCase.ContactId);
        lstSponsorId.add(objCase.UAC_sponsor__c);
      }
      // ORRUAC-1362 AC 3 Start
      if (objCase.recordTypeId == idHSPRSReferralRecType && objCase.OwnerId != objOldCase.OwnerId
          && objCase.OwnerId.getSObjectType().getDescribe().getName() != 'Group') {
        lstUserId.add(objCase.OwnerId);
      }
      // ORRUAC-1362 AC 3 End
    }
    // ORRUAC-1686 AC 9 Start
    if (!lstSponsorId.isEmpty()) {
      List<Case> lstCaseError = [
        Select Id,
        UAC_sponsor__c,
        ContactId,
        OwnerId from Case where UAC_sponsor__c
        in:lstSponsorId and recordtype.developername = 'UAC_hSPrsReferral' and OwnerId
        !=:UserInfo.getUserId()and Status
         =:strCaseStatusActive
      ];
      if (lstCaseError.size() > 0) {
        mapNewCasess.values()[0].addError(Label.UAC_ErrorMessageForHSPRSProviderstoAcceptReferrals);
      }
    }
    // ORRUAC-1686 AC 9 End
    if (!lstUserId.isEmpty()) {
      for (SetupEntityAccess access :
          [SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId IN(
              SELECT Id FROM CustomPermission WHERE DeveloperName in
              : lstCustomPermission)]) {

        permissionSetIds.add(access.ParentId);
      }

      MapUser = New Map<Id, User>([SELECT Username FROM User WHERE Id IN(
          SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN
          : permissionSetIds and AssigneeId =
              : lstUserId)]);
    }
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idHSPRSReferralRecType && objCase.OwnerId != objOldCase.OwnerId
          && objCase.OwnerId.getSObjectType().getDescribe().getName() != 'Group'
          && (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider))) {
        objCase.Status = strCaseStatusActive;
        objCase.UAC_hSPRSPrimaryProviderName__c = objCase.OwnerId;
        if (objCase.ParentId != null) {
          Case updateCaseRR = new Case(id = objcase.ParentId);
          updateCaseRR.UAC_hSPRSPrimaryProviderName__c = objCase.OwnerId;
          updateCaseReleaseRequest.add(updateCaseRR);
        }
        // ORRUAC-1686 AC 4 Start
        if (objCase.ContactId != null) {
          Contact objCnt = new Contact(id = objCase.ContactId);
          objCnt.UAC_techHsPrsProvider__c = objCase.OwnerId;
          updateConTechHsPrs.add(objCnt);
        }
        // ORRUAC-1686 AC 4 End
        if (objCase.Type == strCaseTypeHomeStudyTVPRA
            || objCase.Type == strCaseTypeHomeStudyORRMandated
            || objCase.Type == strCaseTypeHomeStudyDiscretionary) {
          objCase.UAC_hsPrsAcceptanceDateHS__c = system.today();
          objCase.UAC_hsPrsExpectedClosureDateHS__c = dtNxtBussDt10;
        } else if (objCase.Type == strCaseTypePRSOnly
            || objCase.Type == strCaseTypePRSAfterORRMandated
            || objCase.Type == strCaseTypePRSAfterDiscretionary) {
          objCase.UAC_hsPrsAcceptanceDateHS__c = system.today();
          objCase.UAC_hsPRSEndDate__c = dtNxtBussDt90;
        } else if (objCase.Type == strCaseTypePRSTVPRA) {
          objCase.UAC_hsPrsAcceptanceDateHS__c = system.today();
          objCase.UAC_hsPRSEndDate__c = objCase.UAC_dob__c.addYears(18);
        }
        if (MapUser.containsKey(objCase.OwnerId)) {
          objCase.adderror(label.UAC_errorMessageforsubcontractor);
        }
      }
    }
    if (!updateCaseReleaseRequest.isEmpty()) {
      update updateCaseReleaseRequest;
    }
    if (!updateConTechHsPrs.IsEmpty()) {
      update updateConTechHsPrs;
    }
  }

  /** @description ORRUAC-869 prevent duplicate on HSPRS Referral
   * @author Rahul Roy (Deloitte) 7/16/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void preventduplicateHSPRSReferral(List<Case> lstNewCases) {
    Id idHSPRSReferralRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeHSPRSReferral).getRecordTypeId();
    Map<id, list<case>> mapHSPRSReferralByUAC = new map<id, list<case>>();

    for (Case NewCase : lstNewCases) {
      if (idHSPRSReferralRecType == NewCase.recordtypeid) {
        list<case> lstCases = new list<case>();
        if (mapHSPRSReferralByUAC.containsKey(NewCase.Contactid)) {
          lstCases = mapHSPRSReferralByUAC.get(NewCase.Contactid);
        }
        lstCases.add(NewCase);
        mapHSPRSReferralByUAC.put(NewCase.Contactid, lstCases);
      }
    }

    map<id, contact> mapContactExistingPendingCase = new map<id, contact>([select id,
      (select id from cases where status in
          : lstStatusHSPRSReferral and recordtypeid =
              : idHSPRSReferralRecType) from Contact where id in:mapHSPRSReferralByUAC.keyset()]);

    for (Case objnewCase : lstNewCases) {
      if (mapContactExistingPendingCase.containsKey(objnewCase.contactId)
          && mapContactExistingPendingCase.get(objnewCase.contactId).Cases.size() > 0) {
        objnewCase.adderror(strHSPRSReferralExists);
      }
    }
  }

  /** @description ORRUAC-1432-  Mark ReleaseRequest HS Completed - CM review
   * @author Ankur Aggarwal (Deloitte) 7/21/2020
   * updated ORRUAC-1944 AC5 Piyush 8/22/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void markRRHSComplete(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idHSPRSReferralRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeHSPRSReferral).getRecordTypeId();
    list<id> lstIdParentCase = new list<id>();

    for (Case objCase : mapNewCasess.values()) {
      if (objCase.parentid != null) lstIdParentCase.add(objCase.parentid);
    }

    map<id, case> mapobjParentCase = new map<id, case>(
        [select id, status, UAC_hsPrsOutcomeOfHomeStudy__c from Case where id in:lstIdParentCase]);
    list<Case> lstRelReqHmStdy = new list<Case>();
    list<case> lstParentRRCases = new list<case>();

    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objCase.Status != objOldCase.Status && objCase.status == 'Closed'
          && objCase.parentid != null) {  // check for null pointer
        Case objParentCase = mapobjParentCase.get(objCase.parentId);
        if (objParentCase.status == 'HS Requested') {
          objParentCase.status = 'HS Completed -CM Review';
          lstParentRRCases.add(objParentCase);
        }
      }
      // ORRUAC-1944 AC5 Start
      if (objCase.ParentId != null
          && objCase.UAC_hsPrsOutcomeOfHomeStudy__c != objOldCase.UAC_hsPrsOutcomeOfHomeStudy__c
          && objCase.UAC_hsPrsOutcomeOfHomeStudy__c != null
          && FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)) {
        Case objParRelReq = mapobjParentCase.get(objCase.parentId);
        objParRelReq.UAC_hsPrsOutcomeOfHomeStudy__c = objCase.UAC_hsPrsOutcomeOfHomeStudy__c;
        lstRelReqHmStdy.add(objParRelReq);
      }
      // ORRUAC-1944 AC5 End
    }
    update lstParentRRCases;
    // ORRUAC-1944 AC5 DML Start
    if (!lstRelReqHmStdy.IsEmpty()) {
      update lstRelReqHmStdy;
    }
    // ORRUAC-1944 AC5 DML End
  }

  /* @description ORRUAC-206 - Admit UAC to Program
   * @author Abhisek Pati (Deloitte) 7/21/2020
   * @param map of new and old Case record
   * @author Satish Kota (Deloitte) 03/02/2021 ORRUAC-5323
   * User Story :: ORRUAC-5323
   * Added If condition when updating Admitted date of contact
   * @return None
   **/
  public
  static void setContactAdmittedDate(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    Map<Id, Case> mapOldCaseObj = (Map<Id, Case>) mapOldCases;
    Map<Id, Case> mapNewCaseObj = (Map<Id, Case>) mapNewCases;
    Id idAdmissionRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeAdmission).getRecordTypeId();
    List<Case> lstOfCases = new List<Case>();
    Map<id, contact> mapOfContactIdtoRecord = new Map<id, contact>();
    List<Contact> lstContacttoUpdate = new List<Contact>();

    for (Case objCase : mapNewCaseObj.values()) {
      if (objCase.recordTypeId == idAdmissionRecType
          && (objCase.Status != mapOldCaseObj.get(objCase.Id).Status
              || objCase.UAC_dateTimeOfDischarge__c
                  != mapOldCaseObj.get(objCase.Id).UAC_dateTimeOfDischarge__c)) {
        mapOfContactIdtoRecord.put(objCase.ContactId, null);
        lstOfCases.add(objCase);
      }
    }
    if (lstOfCases.isEmpty()) {
      return;
    }
    for (contact objCon : [SELECT Id,
           UAC_mostRecentAdmittedDateTime__c,
           UAC_initialORRAdmissionDateTime__c,
           UAC_admissionDateforMostRecentORRStay__c,
           UAC_admissionAgeforMostRecentORRStay__c,
           UAC_cumulativeLOC__c FROM contact WHERE Id IN:mapOfContactIdtoRecord.keySet()]) {
      mapOfContactIdtoRecord.put(objCon.id, objCon);
    }
    if (mapOfContactIdtoRecord.isEmpty()) {
      return;
    }
    for (Case objCase : lstOfCases) {
      if (!mapOfContactIdtoRecord.containsKey(objCase.ContactId)) {
        continue;
      }
      Contact objContact = mapOfContactIdtoRecord.get(objCase.ContactId);
      if (mapOldCaseObj.get(objCase.Id).Status == strPendingAdmissionStatus
          && objCase.Status == strAdmittedStatus) {
        objContact.UAC_mostRecentAdmittedDateTime__c = objCase.UAC_admittedDateTime__c;
        objContact.UAC_inORRCare__c = 'Yes';
        if (objCase.type == strCaseAdmissionInitial) {
          objContact.UAC_admissionDateforMostRecentORRStay__c =
              objCase.UAC_admittedDateTime__c.date();
        }
        objContact.UAC_admissionAgeforMostRecentORRStay__c = Integer.valueOf(objCase.UAC_age__c);
        if (objContact.UAC_initialORRAdmissionDateTime__c == null) {
          objContact.UAC_initialORRAdmissionDateTime__c = objCase.UAC_admittedDateTime__c;
        }
      } else if (objCase.UAC_dateTimeOfDischarge__c != null
          && mapOldCaseObj.get(objCase.Id).UAC_dateTimeOfDischarge__c == null) {
        objContact.UAC_cumulativeLOC__c = objContact.UAC_cumulativeLOC__c + objCase.UAC_LOS__c;
        objContact.UAC_mostRecentAdmittedDateTime__c = null;
      }
      lstContacttoUpdate.add(objContact);
    }

    if (!lstContacttoUpdate.isEmpty()) {
      try {
        update lstContacttoUpdate;
      } catch (DMLException e) {
        system.debug('Exception ' + e.getMessage());
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Updating related UC failed: ' + e.getMessage());
      }
    }
  }

  /* @description ORRUAC-206 - Admit UAC to Program
   * @author Abhisek Pati (Deloitte) 7/21/2020
   * @author Chaitanya N (Deloitte) 8/20/2020 ORRUAC-1846 Accepcted LNO Recommendations
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void setCaseAdmittedDate(Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    Map<Id, Case> mapOldCaseObj = (Map<Id, Case>) mapOldCases;
    Map<Id, Case> mapNewCaseObj = (Map<Id, Case>) mapNewCases;
    set<Id> InfluxProgram = new set<Id>();
    List<Case> lstLNONotAcceptedCase = new List<Case>();
    List<Case> lstLNORecAcceptedCase = new List<Case>();
    List<Case> LstInfluxPOCRecReferred = new List<Case>();
    List<Case> LstInfluxPOCRecNotReferred = new List<Case>();
    Map<Id, String> mapParentManifestStatus = new Map<Id, String>();
    Id idAdmissionRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeAdmission).getRecordTypeId();
    for (Case objCase : mapNewCaseObj.values()) {
      if (objCase.recordTypeId == idAdmissionRecType
          && objCase.Status != mapOldCaseObj.get(objCase.Id).Status
          && objCase.Status == strAdmittedStatus) {
        objCase.UAC_admittedDateTime__c = System.now();
      }
      if (objCase.UAC_transferMatch__c != mapOldCaseObj.get(objCase.Id).UAC_transferMatch__c
          && objCase.UAC_transferMatch__c == strManualReviewCompletedStatus) {
        objCase.UAC_manualReviewCompletedDateTime__c = System.now();
      }
      if (objCase.UAC_InfluxPOCRecommendation__c
          != mapOldCaseObj.get(objCase.Id).UAC_InfluxPOCRecommendation__c) {
        objCase.UAC_InfluxPOCRecommendationDateTime__c = System.now();  // ORRUAC-1844
        if (objCase.UAC_InfluxProgram__c == null) {
          continue;
        }
        objCase.UAC_influxPOC__c = UserInfo.getUserId();
        if (objCase.UAC_InfluxPOCRecommendation__c == strPOCRecommendationReferred) {
          LstInfluxPOCRecReferred.add(objCase);
        } else {
          LstInfluxPOCRecNotReferred.add(objCase);
        }
      }
      if (objCase.UAC_LNORecommendation__c
          != mapOldCaseObj.get(objCase.Id).UAC_LNORecommendation__c) {
        objCase.UAC_LNORecommendationDateTime__c = System.now();
        objCase.UAC_lno__c = UserInfo.getUserId();
        if (objCase.UAC_LNORecommendation__c == strAccepted) {
          if (String.isBlank(objCase.UAC_manifest__c)) {
            objCase.addError(Label.UAC_admissionEntryManifestErrorMessage);
          } else {  // ORRUAC-2102
            if (objCase.UAC_InfluxPOCRecommendation__c == null) {
              if (objCase.UAC_transferMatch__c == strCaseTransferMatchEligible) {
                objCase.UAC_InfluxPOCRecommendation__c = strInfluxPOCRecommendationBypassed;
                objCase.UAC_InfluxPOCRecommendationDateTime__c = System.now();
              } else {
                objCase.UAC_transferMatch__c.addError(label.UAC_TransferMatchNotEligibleErrorMsg);
              }
            }
            InfluxProgram.add(objCase.UAC_InfluxProgram__c);
            InfluxProgram.add(objCase.UAC_programFacility__c);
            lstLNORecAcceptedCase.add(objCase);
            mapParentManifestStatus.put(objCase.UAC_manifest__c, null);
          }
        } else {
          lstLNONotAcceptedCase.add(objCase);
        }
      }
    }
    if (!mapParentManifestStatus.isEmpty()) {
      for (Case manifestCurrent : [
             SELECT Id,
             Status FROM Case WHERE RecordType.DeveloperName
              =:Label.UAC_caseRecordTypeManifest AND Id
             IN:mapParentManifestStatus.keyset()
           ]) {
        mapParentManifestStatus.put(manifestCurrent.Id, manifestCurrent.Status);
      }
      Set<Case> setManifestsToUpdate = new Set<Case>();
      for (Case objCase : mapNewCaseObj.values()) {
        if (objCase.UAC_LNORecommendation__c == strAccepted
            && String.isNotBlank(objCase.UAC_manifest__c)) {
          if (mapParentManifestStatus.get(objCase.UAC_manifest__c) == null) {
            objCase.addError(Label.UAC_caseManifestErrorRecordType);
          } else if (mapParentManifestStatus.get(objCase.UAC_manifest__c)
              == Label.UAC_caseStatusFinalManifest) {
            objCase.addError(Label.UAC_caseManifestErrorStatus);
          } else if (mapParentManifestStatus.get(objCase.UAC_manifest__c)
              == Label.UAC_caseStatusDraft) {
            setManifestsToUpdate.add(new Case(
                Id = objCase.UAC_manifest__c, Status = Label.UAC_caseStatusInitialManifest));
          }
        }
      }
      if (!setManifestsToUpdate.isEmpty()) {
        List<Case> lstCaseToUpdate = new List<Case>();
        lstCaseToUpdate.addAll(setManifestsToUpdate);
        update lstCaseToUpdate;
      }
    }
    createGroupEmailRecordsforLNODecision(
        lstLNORecAcceptedCase, strAccepted, strcaseRecordTypeAdmission);
    createGroupEmailRecordsforLNODecision(
        lstLNONotAcceptedCase, strNotAccepted, strcaseRecordTypeAdmission);
    createGroupEmailRecordsforLNODecision(
        LstInfluxPOCRecReferred, strPOCRecommendationReferred, strCaseAdmissionInfluxProgramPoc);
    createGroupEmailRecordsforLNODecision(
        LstInfluxPOCRecNotReferred, '', strCaseAdmissionInfluxProgramPoc);
    createInfluxTransferRequest(lstLNORecAcceptedCase, InfluxProgram, mapNewCaseObj);
  }

  /**
   * @description ORRUAC-1845 - Method to create Link to List view
   * @author Chaitanya Nandamuri (Deloitte) | 08/25/2020
   * @param List<Case> caseList
   * @return void
   **/
  public
  static string getLinkforListView(string SobjectType, String ListViewName) {
    List<Listview> LV = [select Id,SobjectType,name from Listview where SobjectType =:SobjectType and Name =:ListViewName limit 1];
    String lvstr;
    if(!LV.isEmpty()){
      lvstr = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/' + LV[0].SobjectType+ '/list?filterName=' + LV[0].Id;
    }
    else{
      lvstr = 'No List view found';
    }
    return lvstr;
  }
  /**
   * @description ORRUAC-1845 - Method to get Email Address of Users
   * @author Chaitanya Nandamuri (Deloitte) | 08/26/2020
   * @param List<Case> caseList
   * @return void
   **/
  public
  static Map<Id, String> getUserEmail(List<Id> lstUserId) {
    Map<Id, String> mapUserIdtoEmail = new Map<Id, String>();
    for (user CurrentUser : [select id, email from user where id In:lstUserId]) {
      mapUserIdtoEmail.put(CurrentUser.id, CurrentUser.email);
    }
    return mapUserIdtoEmail;
  }

  /* @description ORRUAC-1845 - method to get UserId and Email on program
   * @author Chaitanya Nandamuri (Deloitte) 8/26/2020
   * @param Set of Programs
   * @return Map of Program Id to LCM
   **/
  @testvisible private static map<String, list<String>> getUserDetailsonProgram(
      set<Id> Programs, List<string> lstTeamRole) {
    map<String, List<string>> programToATM = new map<String, List<string>>();

    for (AccountTeamMember ATM : [
           select UserId,
           AccountId,
           user.Email from AccountTeamMember where AccountId In:Programs and TeamMemberRole
                                                             In:lstTeamRole
         ]) {
      List<String> lstATMEmail;
      List<String> lstATMUserId;
      if (programToATM.containskey(ATM.AccountId + strKeyEmail)
          || programToATM.containsKey(ATM.AccountId + strKeyUserId)) {
        lstATMEmail = programToATM.get(ATM.AccountId + strKeyEmail);
        lstATMUserId = programToATM.get(ATM.AccountId + strKeyUserId);
      } else {
        lstATMEmail = new List<String>();
        lstATMUserId = new List<String>();
      }
      lstATMEmail.add(ATM.user.Email);
      lstATMUserId.add(ATM.UserId);
      programToATM.put(ATM.AccountId + strKeyEmail, lstATMEmail);
      programToATM.put(ATM.AccountId + strKeyUserId, lstATMUserId);
    }
    return programToATM;
  }

  /* @description ORRUAC-1845 - method to get Users on Case
   * @author Chaitanya Nandamuri (Deloitte) 8/26/2020
   * @param Set of Cases
   * @return Map of Case Id to UserId
   **/
  private
  static map<String, List<string>> getUseronCTM(set<Id> admissionCase, List<string> lstTeamRole) {

    map<String, List<string>> programToCTM = new map<String, List<string>>();

    for (CaseTeamMember CTM : [
           select id,
           parent.UAC_InfluxProgram__c,
           parent.UAC_programFacility__c,
           MemberId,
           Member.Email from CaseTeamMember where parentId In:admissionCase and TeamRole.Name
                                                           In:lstTeamRole
         ]) {

      List<String> lstCTMEmail;
      List<String> lstCTMUserId;
      if (programToCTM.containskey(CTM.parent.UAC_programFacility__c + strKeyEmail)
          || programToCTM.containsKey(CTM.parent.UAC_programFacility__c + strKeyUserId)) {
        lstCTMEmail = programToCTM.get(CTM.parent.UAC_programFacility__c + strKeyEmail);
        lstCTMUserId = programToCTM.get(CTM.parent.UAC_programFacility__c + strKeyUserId);
      } else {
        lstCTMEmail = new List<String>();
        lstCTMUserId = new List<String>();
      }
      lstCTMEmail.add(CTM.Member.Email);
      lstCTMUserId.add(CTM.MemberId);
      programToCTM.put(CTM.parent.UAC_programFacility__c + strKeyEmail, lstCTMEmail);
      programToCTM.put(CTM.parent.UAC_programFacility__c + strKeyUserId, lstCTMUserId);
    }
    return programToCTM;
  }

  /* @description ORRUAC-1846 - Create Influx Transfer Case for every LNO Recommendation Accepted
   *Case
   * @author Chaitanya Nandamuri (Deloitte) 8/20/2020
   * @param Parent Case record
   * @return None
   **/
  public
  static void createInfluxTransferRequest(
      List<Case> LNORecAcceptedCase, set<Id> InfluxProgram, Map<Id, Case> mapNewCases) {
    if (LNORecAcceptedCase.isEmpty()) {
      return;
    }
    Map<Id, Case> MapAdmissionCaseToInfluxTransfer = new Map<Id, case>();
    Map<Id, String> mapProgramToType = getTypeofProgram(InfluxProgram);
    Map<Id, Id> mapProgramToLCM = getUseronProgram(InfluxProgram, strLeadCaseManager);
    Map<String, List<case>> ExistingInfluxTransfer =
        queryExistingTransferRequest(LNORecAcceptedCase, '');
    for (Case LNO : LNORecAcceptedCase) {
      String StrKey = LNO.id + '.' + InfluxTransferRequestTypeId;
      if (ExistingInfluxTransfer.containsKey(StrKey)
          && ExistingInfluxTransfer.get(StrKey).size() > 0) {
        continue;
      }
      Case InfluxTRCase = new Case();
      InfluxTRCase.ParentId = LNO.Id;
      InfluxTRCase.RecordTypeId = InfluxTransferRequestTypeId;
      InfluxTRCase.ContactId = LNO.ContactId;
      InfluxTRCase.UAC_currentProgram__c = LNO.UAC_programFacility__c;
      InfluxTRCase.UAC_programFacility__c = LNO.UAC_InfluxProgram__c;
      InfluxTRCase.UAC_standardProgramType__c = label.UAC_EmergencyInflux;
      InfluxTRCase.UAC_manifest__c = LNO.UAC_manifest__c;
      InfluxTRCase.UAC_manifestStatus__c = 'Original';
      InfluxTRCase.UAC_programTypeRequested__c =
          mapProgramToType.containsKey(LNO.UAC_InfluxProgram__c)
          ? mapProgramToType.get(LNO.UAC_InfluxProgram__c)
          : '';
      if (String.isNotBlank(LNO.UAC_programFacility__c)
          && mapProgramToLCM.containskey(LNO.UAC_programFacility__c)
          && mapProgramToLCM.get(LNO.UAC_programFacility__c) != null) {
        InfluxTRCase.OwnerId = mapProgramToLCM.get(LNO.UAC_programFacility__c);
      }
      MapAdmissionCaseToInfluxTransfer.put(LNO.id, InfluxTRCase);
    }
    if (!MapAdmissionCaseToInfluxTransfer.isEmpty()) {
      database.insert(MapAdmissionCaseToInfluxTransfer.values());
      for (Id ParentAdmission : MapAdmissionCaseToInfluxTransfer.keyset()) {
        if (MapAdmissionCaseToInfluxTransfer.get(ParentAdmission).Id == null) {
          mapNewCases.get(ParentAdmission).addError('Influx Trasfer Request Creation Failed');
        }
      }
    }
  }

  /**
   * @description ORRUAC-1848 - Prevents changing manifest status to removed
   * @author James Qian (Deloitte) 9/2/2020
   * @param Maps of new and old Case record
   * @return None
   **/
  public
  static void preventStatusRemovedForInfluxTransfer(
      Map<Id, Case> mapNewCases, Map<Id, Case> mapOldCases) {
    List<Case> listCasesToProcess = new List<Case>();
    Map<Id, String> mapParentManifestStatus = new Map<Id, String>();
    for (Case caseCurrent : mapNewCases.values()) {
      if (caseCurrent.UAC_manifestStatus__c != mapOldCases.get(caseCurrent.Id).UAC_manifestStatus__c
          && caseCurrent.UAC_manifestStatus__c == Label.UAC_caseManifestStatusRemoved) {
        listCasesToProcess.add(caseCurrent);
        mapParentManifestStatus.put(caseCurrent.UAC_manifest__c, null);
      }
    }
    if (listCasesToProcess.isEmpty()) {
      return;
    }
    for (Case manifestCurrent : [
           SELECT Id,
           Status FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeManifest AND Id
                                                          IN:mapParentManifestStatus.keyset()
         ]) {
      mapParentManifestStatus.put(manifestCurrent.Id, manifestCurrent.Status);
    }
    for (Case caseCurrent : listCasesToProcess) {
      if (mapParentManifestStatus.get(caseCurrent.UAC_manifest__c) != null
          && mapParentManifestStatus.get(caseCurrent.UAC_manifest__c)
              == Label.UAC_caseStatusFinalManifest) {
        caseCurrent.addError(Label.UAC_influxTransferManifestRemovalError);
      }
    }
  }

  /**
   * @description ORRUAC-1845 - Group Email for Influx Transfer On Admission
   * @author Chaitanya Nandamuri (Deloitte) | 08/24/2020
   * @author Chaitany Nandamuri (Deloitte) | 8/27/2020 - ORRUAC-1843 refactoring code to work for
   *ORRDecision Approved
   * @param List<Case> caseList
   * @return void
   **/
  private
  static void createGroupEmailRecordsforLNODecision(
      List<Case> caseList, String decision, String CaseType) {

    if (caseList.isEmpty()) {
      return;
    }
    // common resource
    String Subject;
    String body;
    String setEmailDisplayname;
    String bellnotificationBody;
    List<String> lstUserTeamRoleOnProgram;
    List<String> lstUserTeamRoleOnCase;
    List<UAC_flowNotification> flowBellNotify = new List<UAC_flowNotification>();
    set<Id> setadmissionCaseId = new set<id>();
    Map<String, object> bellInput = new Map<String, Object>();
    Map<Id, List<Case>> mapProgramToListCases = new Map<Id, List<Case>>();
    Map<String, List<String>> mapProToCaseUserNotify;

    // List of Emails to Send
    List<Messaging.SingleEmailMessage> lstSendMails = new List<Messaging.SingleEmailMessage>();
    Id pathNotifyId = [select id from CustomNotificationType where DeveloperName
        =:uacPathCustomNotification limit 1]
                          .id;
    String strListViewUrl;
    if (CaseType == strcaseRecordTypeAdmission) {

      Subject = decision == strAccepted ? label.UAC_InfluxLNOAcceptedSubject
                                        : label.UAC_LNOdoesNotAcceptInfluxTransferSubject;
      body = decision == strAccepted ? Label.UAC_InfluxLNOAcceptedEmailBody
                                     : label.UAC_InfluxLNONotAcceptedEmailBody;
      bellnotificationBody = body;
      lstUserTeamRoleOnProgram = new List<String>{strInfluxPOC, strLeadCaseManager};
      lstUserTeamRoleOnCase = new List<String>{strCM};
      strListViewUrl = decision == strAccepted
          ? getLinkforListView('Case', strListViewInfluxTransferAcceptedUACs)
          : getLinkforListView('Case', strListViewName);

      for (Case LNOacc : caseList) {
        setadmissionCaseId.add(LNOacc.id);
        List<Case> listCases;
        if (mapProgramToListCases.containsKey(LNOacc.UAC_programFacility__c)) {
          listCases = mapProgramToListCases.get(LNOacc.UAC_programFacility__c);
        } else {
          listCases = new List<Case>();
        }
        listCases.add(LNOacc);
        mapProgramToListCases.put(LNOacc.UAC_programFacility__c, listCases);
      }
      mapProToCaseUserNotify = new Map<string, List<string>>();
      mapProToCaseUserNotify = getUseronCTM(setadmissionCaseId, lstUserTeamRoleOnCase);
    }

    if (CaseType == strCaseAdmissionInfluxProgramPoc) {

      Subject = decision == strPOCRecommendationReferred ? label.UAC_InfluxPOCRecReferredSubject
                                                         : label.UAC_InfluxPOCRecNotreferredSubject;
      body = decision == strPOCRecommendationReferred ? Label.UAC_InfluxPOCReferredEmailBody
                                                      : label.UAC_InfluxPOCNotReferredEmailBody;
      bellnotificationBody = body.substringBefore('.');
      lstUserTeamRoleOnProgram = decision == strPOCRecommendationReferred
          ? new List<String>{strLNOTeamRoleonProgram}
          : new List<String>{strLeadCaseManager};
      lstUserTeamRoleOnCase = new List<String>{strCM};
      strListViewUrl = decision == strPOCRecommendationReferred
          ? getLinkforListView('Case', strListViewInfluxTransferReferredUACsDevName)
          : getLinkforListView('Case', strListViewInfluxTransferNOTReferredUACsDevName);

      for (Case LNOacc : CaseList) {
        setadmissionCaseId.add(LNOacc.Id);
        List<Case> listCases;
        string strKeyProgram = decision == strPOCRecommendationReferred
            ? LNOacc.UAC_InfluxProgram__c
            : LNOacc.UAC_programFacility__c;
        if (mapProgramToListCases.containsKey(strKeyProgram)) {
          listCases = mapProgramToListCases.get(strKeyProgram);
        } else {
          listCases = new List<Case>();
        }
        listCases.add(LNOacc);
        mapProgramToListCases.put(strKeyProgram, listCases);
      }
      mapProToCaseUserNotify = decision != strPOCRecommendationReferred
          ? getUseronCTM(setadmissionCaseId, lstUserTeamRoleOnCase)
          : new Map<string, List<String>>();
    }

    if (CaseType == Label.UAC_TransferRequestInflux) {
      Subject = decision == strTransferApprovedORRDecision
          ? label.UAC_InfluxPocApprovesInfluxTransferSubject
          : label.UAC_InfluxPOCdoesNotApprovesInfluxTransfersubject;
      body = label.UAC_InfluxPOCFinalReviewEmailBody;
      bellnotificationBody = Label.UAC_InfluxPOCdoesNotApprovesBellBody;
      lstUserTeamRoleOnProgram = new List<String>{strLeadCaseManager};
      strListViewUrl = getLinkforListView('Case', strListViewFFSInfluxTransferRequests);

      for (Case LNOacc : caseList) {
        setadmissionCaseId.add(LNOacc.parentId);
        List<Case> listCases;
        if (mapProgramToListCases.containsKey(LNOacc.UAC_currentProgram__c)) {
          listCases = mapProgramToListCases.get(LNOacc.UAC_currentProgram__c);
        } else {
          listCases = new List<Case>();
        }
        listCases.add(LNOacc);
        mapProgramToListCases.put(LNOacc.UAC_currentProgram__c, listCases);
      }
      mapProToCaseUserNotify = getUserOwnerIdandEmail(setadmissionCaseId);
    }

    Map<String, List<String>> mapNotifyProgramUser =
        getUserDetailsonProgram(mapProgramToListCases.keyset(), lstUserTeamRoleOnProgram);

    if (!mapProgramToListCases.isEmpty()) {
      List<UAC_groupEmail__c> groupEmailsToInsert = new List<UAC_groupEmail__c>();

      for (Id sendingProgram : mapProgramToListCases.keyset()) {

        List<String> lstUserId = new List<String>();

        if (mapNotifyProgramUser.containsKey(sendingProgram + strKeyUserId)
            && mapNotifyProgramUser.get(sendingProgram + strKeyUserId) != null) {
          lstUserId.addAll(mapNotifyProgramUser.get(sendingProgram + strKeyUserId));
        }
        if (mapProToCaseUserNotify.containsKey(sendingProgram + strKeyUserId)
            && mapProToCaseUserNotify.get(sendingProgram + strKeyUserId) != null) {
          lstUserId.addAll(mapProToCaseUserNotify.get(sendingProgram + strKeyUserId));
        }

        // Bell Notificatiosn to User UAC_notificationsToSend
        flowBellNotify.add(new UAC_flowNotification(
            pathNotifyId, bellnotificationBody, Subject, lstUserId, sendingProgram));

        // Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mapNotifyProgramUser.get(sendingProgram + strKeyEmail));
        if (mapProToCaseUserNotify.containskey(sendingProgram + strKeyEmail)
            && mapProToCaseUserNotify.get(sendingProgram + strKeyEmail) != null) {
          mail.setCcAddresses(mapProToCaseUserNotify.get(sendingProgram + strKeyEmail));
        }
        mail.setSubject(Subject);
        String EmailBody = body + ' <a href=' + strListViewUrl + '>Link to List View </a>.';
        mail.setHtmlBody(EmailBody);
        lstSendMails.add(mail);
      }
      Messaging.sendEmail(lstSendMails, false);
      bellInput.put('UAC_notificationsToSend', flowBellNotify);
      Flow.Interview.UAC_sendMassNotifications BellFlow =
          new Flow.Interview.UAC_sendMassNotifications(bellInput);
      BellFlow.start();
    }
  }

  /* @description ORRUAC-1843 - method to get Case Managers (Case owner) and Email
   * @author Chaitanya Nandamuri (Deloitte) 8/27/2020
   * @param Set of Cases
   * @return Map of Case Id to UserId
   **/
  private
  static map<String, List<string>> getUserOwnerIdandEmail(set<Id> CaseId) {
    map<String, List<String>> mapProgramToCaseDetails = new Map<string, List<String>>();
    for (case cse :
        [select id, UAC_programFacility__c, OwnerId, owner.Email from Case where Id In:CaseId]) {
      List<String> lstUserEmail;
      List<String> lstUserId;
      if (mapProgramToCaseDetails.containsKey(cse.UAC_programFacility__c + strKeyEmail)
          || mapProgramToCaseDetails.containsKey(cse.UAC_programFacility__c + strKeyUserId)) {
        lstUserEmail = mapProgramToCaseDetails.get(cse.UAC_programFacility__c + strKeyEmail);
        lstUserId = mapProgramToCaseDetails.get(cse.UAC_programFacility__c + strKeyUserId);
      } else {
        lstUserEmail = new List<String>();
        lstUserId = new List<String>();
      }
      lstUserEmail.add(cse.owner.Email);
      lstUserId.add(cse.OwnerId);
      mapProgramToCaseDetails.put(cse.UAC_programFacility__c + strKeyEmail, lstUserEmail);
      mapProgramToCaseDetails.put(cse.UAC_programFacility__c + strKeyUserId, lstUserId);
    }
    return mapProgramToCaseDetails;
  }

  /*@description ORRUAC-1846 - method to get Type for a given Program
   * @author Chaitanya Nandamuri (Deloitte) 8/20/2020
   * @param Set of Programs
   * @return Map of Program Id to Type
   **/
  private
  static map<Id, String> getTypeofProgram(set<Id> Programs) {
    map<Id, string> mapProgramIdToType = new map<Id, String>();

    for (Account Program : [select id, Type from account where id In:Programs]) {
      mapProgramIdToType.put(Program.Id, Program.Type);
    }
    return mapProgramIdToType;
  }
  /* @description ORRUAC-1846 - method to get LCM on program
   * @author Chaitanya Nandamuri (Deloitte) 8/24/2020
   * @param Set of Programs
   * @return Map of Program Id to LCM
   **/
  private
  static map<Id, Id> getUseronProgram(set<Id> Programs, string strTeamRole) {
    map<Id, Id> mapUserIdonProgram = new map<Id, Id>();

    for (AccountTeamMember LCM : [
           select UserId,
           AccountId from AccountTeamMember where AccountId In:Programs and TeamMemberRole
                                                             =:strTeamRole
         ]) {
      mapUserIdonProgram.put(LCM.AccountId, LCM.UserId);
    }
    return mapUserIdonProgram;
  }
  /**
   * @description ORRUAC-1094: Sync UAC status to Admitted
   * @author James Qian (Deloitte) 08/06/2020
   * @param Map<Id, SObject> mapNewCases
   * @param Map<Id, SObject> mapOldCases
   **/
  public
  static void checkAdmissionCasesForParentUACStatusUpdate(
      Map<Id, Case> mapNewCases, Map<Id, Case> mapOldCases) {
    List<Case> listCasesAdmitted = new List<Case>();
    Set<Id> setAdmittedIds = new Set<Id>();
    for (Case objCase : mapNewCases.values()) {
      if (objCase.Status != mapOldCases.get(objCase.Id).Status
          && objCase.Status == strAdmittedStatus) {
        listCasesAdmitted.add(objCase);
        setAdmittedIds.add(objCase.Id);
      }
    }
    if (!listCasesAdmitted.isEmpty()) {
      syncContactStatusWithCaseStatusAdmission(listCasesAdmitted);
      if (!System.isFuture()) {
        UC_visualChecklistService.createAdmissionTasksForChecklistItems(
            setAdmittedIds, 'Admission');
      }
    }
  }

  /* @description ORRUAC-1686 AC1,AC2,AC3 -Auto Populate Sponsor related Fields for HS PRS
   *Referral Case
   * @author Piyush(Deloitte) 7/27/2020
   * @param List of new Case - before insert
   * @return None
   **/
  public
  static void setHsPrsSponsor(List<Case> lstNewCasess) {
    Id idHSPRSReferralRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeHSPRSReferral).getRecordTypeId();
    Set<Id> setContactIds = new set<Id>();
    Map<Id, UAC_adultContactRelationship__c> mapContactPrimarySponsor =
        new Map<Id, UAC_adultContactRelationship__c>();
    Map<Id, Id> mapUACContact = new Map<Id, Id>();
    Map<Id, Case> mapContactIdToAdmCaseRec = new Map<Id, Case>();
    for (Case objCase : lstNewCasess) {
      if (objCase.recordTypeId == idHSPRSReferralRecType && objCase.ContactId != null) {
        setContactIds.add(objCase.ContactId);
      }
    }
    Map<Id, Contact> mapUAC = new Map<Id, Contact>(
        [Select Id, UAC_program__c, UAC_A__c from Contact where id in:setContactIds]);

    for (Case objAdmission : [
           Select Id,
           ContactId,
           UAC_programFacility__c,
           UAC_admittedDateTime__c from Case where RecordType.DeveloperName
            =:strcaseRecordTypeAdmission and ContactId
           in:setContactIds
         ]) {
      mapContactIdToAdmCaseRec.put(objAdmission.ContactId, objAdmission);
    }

    List<Id> lstContactIds = new List<Id>(setContactIds);
    for (UAC_adultContactRelationship__c objadultContactRelationship : [
           SELECT Id,
           UAC_adultContact__c,
           UAC_uacLookup__c FROM UAC_adultContactRelationship__c WHERE UAC_uacLookup__c
           in:lstContactIds AND UAC_relationshipType__c
            =:strRelationshipTypePrimarySponso limit 200
         ]) {
      mapContactPrimarySponsor.put(
          objadultContactRelationship.UAC_uacLookup__c, objadultContactRelationship);
      mapUACContact.put(objadultContactRelationship.UAC_adultContact__c,
          objadultContactRelationship.UAC_uacLookup__c);
    }

    Map<Id, Contact> mapOfContactIdtoRecord = new Map<Id, Contact>([Select Id,
      MailingStreet,
      MailingCity,
      MailingState,
      MailingPostalCode,
      MailingAddress from Contact where Id in:mapUACContact.keyset()]);

    for (Case objCase : lstNewCasess) {
      if (objCase.recordTypeId == idHSPRSReferralRecType && objCase.ContactId != null
          && mapContactPrimarySponsor.containsKey(objCase.ContactId)) {
        objCase.UAC_sponsor__c =
            mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c;
        objCase.UAC_relationshipToUAC__c = mapContactPrimarySponsor.get(objCase.ContactId).Id;
        objCase.UAC_programFacility__c = mapUAC.get(objCase.ContactId).UAC_program__c;
        if (mapOfContactIdtoRecord.containsKey(
                mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
            && mapOfContactIdtoRecord
                    .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                    .MailingAddress
                != null) {
          objCase.UAC_dischargeAddress__c =
              mapOfContactIdtoRecord
                  .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                  .MailingStreet;
          objCase.UAC_dischargeCity__c =
              mapOfContactIdtoRecord
                  .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                  .MailingCity;
          objCase.UAC_dischargeState__c =
              stateMap(mapOfContactIdtoRecord
                           .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                           .MailingState);
          objCase.UAC_dischargeZipCode__c =
              mapOfContactIdtoRecord
                  .get(mapContactPrimarySponsor.get(objCase.ContactId).UAC_adultContact__c)
                  .MailingPostalCode;
        }
        if (mapContactIdToAdmCaseRec.containsKey(objCase.ContactId)) {
          objCase.UAC_admittedDateTime__c =
              mapContactIdToAdmCaseRec.get(objCase.ContactId).UAC_admittedDateTime__c;
        }
      }
    }
  }
  // 7/30/2020	   Ankur Aggarwal(Deloitte)		ORRUAC-1561 will be called after update to send
  // emails
  public
  static void ReleaseRequestAlertMedicalStaff(
      Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Id idReleaseRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeReleaseRequest).getRecordTypeId();

    list<EmailTemplate> objAlertMedicalStaff =
        [select id, developername from emailtemplate where developername = 'UAC_alertMedicalStaff'];
    list<Messaging.SingleEmailMessage> lstmessages = new list<Messaging.SingleEmailMessage>();
    if ((FeatureManagement.checkPermission(strCustomPermissionCaseManager)
            || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager))
        && objAlertMedicalStaff != null && objAlertMedicalStaff.size() > 0) {
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
      for (Case objOldCase : (list<case>) oldItems.values()) {
        Case objnewCase = (case) newItems.get(objOldCase.Id);
        if (objnewCase.Recordtypeid == idReleaseRecType
            && objnewCase.UAC_alertORRMedicalStaff__c != objOldCase.UAC_alertORRMedicalStaff__c
            && objnewCase.UAC_alertORRMedicalStaff__c == 'Yes') {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.toAddresses = new String[]{Label.UAC_releaseRequestAlertMedicalStaffEmail};
          message.setTemplateId(objAlertMedicalStaff[0].id);
          message.setWhatId(objnewCase.Id);
          message.settargetObjectId(objnewCase.ContactId);
          message.setTreatTargetObjectAsRecipient(false);
          lstmessages.add(message);
        }
      }
    }
    if (lstmessages != null && lstmessages.size() > 0)
      Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
  }
  /* @description ORRUAC-1561 - Changes to DNF
   * @author Ankur Aggarwal (Deloitte) 7/31/2020
   * @autor Chaitanya Nandamuri (Deloitte) 9/18/2020 - 2308 : AC-3.2 set status to Completed on
   *related admission.
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void setDischargeDateOnAdmission(
      Map<Id, SObject> mapNewCases, Map<Id, SObject> mapOldCases) {
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    Id idAdmissionRecType =
        mapRecordTypesByDeveloperName.get(strcaseRecordTypeAdmission).getRecordTypeId();

    list<case> lstAdmissionUpdateObjs = new list<case>();
    list<id> lstContactIds = new list<id>();
    list<id> lstProgramIds = new list<id>();
    list<case> lstDNFObjs = new list<case>();

    for (Case objCase : (list<case>) mapNewCases.values()) {
      Case objOld = (case) mapOldCases.get(objCase.id);
      if (objCase.recordTypeId == idDNFRecType && objCase.Status != objOld.Status
          && objCase.Status == strCaseStatusDischargeCompleted) {
        lstContactIds.add(objCase.contactid);
        lstProgramIds.add(objCase.UAC_programFacility__c);
        lstDNFObjs.add(objCase);
      }
    }
    if (lstDNFObjs != null && lstDNFObjs.size() > 0) {
      list<case> lstAdmissionObjs = [
        select id,
        contactid,
        UAC_programFacility__c from Case where recordtypeid
         =:idAdmissionRecType and contactid
        in:lstContactIds and UAC_programFacility__c
        in:lstProgramIds and UAC_dateTimeOfDischarge__c = null
      ];
      lstAdmissionUpdateObjs = new list<case>();

      for (Case objDNFcase : lstDNFObjs) {
        for (Case objAdmissioncase : lstAdmissionObjs) {
          if (objDNFcase.contactid == objAdmissioncase.contactid
              && objDNFcase.UAC_programFacility__c == objAdmissioncase.UAC_programFacility__c) {
            objAdmissioncase.UAC_dateTimeOfDischarge__c = objDNFcase.UAC_dateTimeOfDischarge__c;
            objAdmissionCase.Status = 'Completed';  // US-2308
            lstAdmissionUpdateObjs.add(objAdmissioncase);
          }
        }
      }
    }
    update lstAdmissionUpdateObjs;
  }
  /*@description ORRUAC-285 - Populate LCM and CC
   * @author Abhisek Pati (Deloitte) 8/6/2020
   * @param list of new Case record
   * @return None
   **/
  public
  static void setTransferRequestLCMandCC(List<case> transferRequest) {

    List<Id> lstOfAccountId = new List<Id>();
    List<Case> lstOfCases = new List<Case>();
    Map<String, AccountTeamMember> mapOfAccountIdtoTeam = new Map<String, AccountTeamMember>();

    for (case objCase : transferRequest) {
      if (objCase.UAC_currentProgram__c != null) {
        lstOfAccountId.add(objCase.UAC_currentProgram__c);
        lstOfCases.add(objCase);
      }
    }

    if (lstOfAccountId != null) {
      for (AccountTeamMember ObjTeam :
          [select id, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId
            In:lstOfAccountId AND TeamMemberRole IN(
                   : strCaseTeamRoleNameLCM)]) {
        mapOfAccountIdtoTeam.put(ObjTeam.AccountId + ObjTeam.TeamMemberRole, ObjTeam);
      }
    }
    if (!mapOfAccountIdtoTeam.isEmpty()) {
      for (Case objCase : lstOfCases) {
        if (mapOfAccountIdtoTeam.containsKey(
                objCase.UAC_currentProgram__c + strCaseTeamRoleNameLCM)) {
          objCase.UAC_leadCaseManager__c =
              mapOfAccountIdtoTeam.get(objCase.UAC_currentProgram__c + strCaseTeamRoleNameLCM)
                  .UserId;
        }
      }
    }
  }
  /* @description ORRUAC-1549- AC3: Notify PSA Team
   * @author Manoj Sharma (Deloitte) 8/4/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void NOCAlertPSATeam(List<Case> lstCase) {
    list<EmailTemplate> objAlertPSATeam = [select id,
      developername from emailtemplate where developername =:Label.UAC_notifyPSATeamEmailTemplate];
    list<Messaging.SingleEmailMessage> lstmessages = new list<Messaging.SingleEmailMessage>();
    if (!objAlertPSATeam.isEmpty()) {

      for (Case objNewCase : lstCase) {
        if (FeatureManagement.checkPermission(strCustomPermissionFFS)
            || FeatureManagement.checkPermission(strCustomPermissionCaseManager)
            || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
            || FeatureManagement.checkPermission(label.UAC_CustomPermissionDCW)
            || FeatureManagement.checkPermission(label.UAC_CustomPermissionSupervisor)
            || FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.toAddresses = new String[]{Label.UAC_NOCNotifyPSATeamEmail};
          message.setTemplateId(objAlertPSATeam[0].id);
          message.setWhatId(objnewCase.Id);
          message.settargetObjectId(objnewCase.ContactId);
          message.setTreatTargetObjectAsRecipient(false);
          lstmessages.add(message);
        }
      }
    }
    if (lstmessages != null && lstmessages.size() > 0)
      Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
  }
  /* @description ORRUAC-1549- AC8
   * @author Manoj Sharma (Deloitte) 8/4/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void populateNOCVaues(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    List<String> lstContactIds = New List<String>();
    List<String> lstSponsorIds = New List<String>();
    // Added for ORRUAC-4561 AC4 starts
    List<String> lstEventIds = New List<String>();
    // Added for ORRUAC-4561 AC4 ends
    List<String> lstContactIdsRelationshiptoUAC = New List<String>();
    List<String> lstSponsorIdsRelationshiptoUAC = New List<String>();
    Map<Id, Contact> mapIdContact;
    Map<Id, Contact> mapIdSponsor;
    Map<Id, Case> mapContactCase = New Map<Id, Case>();
    Map<Id, UAC_adultContactRelationship__c> mapRelationshiptoUAC =
        new Map<Id, UAC_adultContactRelationship__c>();
    UAC_accountSettings__c objAccountSettings = UAC_accountSettings__c.getOrgDefaults();
    UAC_appSettings__c objAppSettings = UAC_appSettings__c.getOrgDefaults();
    for (Case objCase : mapNewCase.Values()) {
      Case objOldCase;
      if (mapOldCase != null) {
        objOldCase = mapOldCase.get(objCase.Id);
        // Added for ORRUAC-4561 AC3.2 starts
        if (objOldCase.status != objCase.status && objCase.status == 'Submitted') {
          objCase.UAC_dateOfReportSubmission__c = system.now();
        }
        // Added for ORRUAC-4561 AC3.2 ends
        if (objOldCase.ContactId != objCase.ContactId) {
          lstContactIds.add(objCase.ContactId);
        }
        if (objOldCase.UAC_sponsor__c != objCase.UAC_sponsor__c) {
          lstSponsorIds.add(objCase.UAC_sponsor__c);
        }
        if (objOldCase.UAC_sponsor__c != null && objOldCase.ContactId != null
            && (objOldCase.UAC_sponsor__c != objCase.UAC_sponsor__c
                || objOldCase.ContactId != objCase.ContactId)) {
          lstContactIdsRelationshiptoUAC.add(objCase.ContactId);
          lstSponsorIdsRelationshiptoUAC.add(objCase.UAC_sponsor__c);
        }
        // Added for ORRUAC-4561 AC 5 Starts
        if (objOldCase.UAC_eventID__c != objCase.UAC_eventID__c && objCase.UAC_eventID__c != null) {
          lstEventIds.add(objCase.UAC_eventID__c);
        }
        // Added for ORRUAC-4561 AC 5 Ends
      } else {
        // Added for ORRUAC-4561 AC3.2 & ORRUAC-5258 starts
        if (objCase.status == 'Submitted') {
          objCase.UAC_dateOfReportSubmission__c = system.now();
        }
        // Added for ORRUAC-4561 AC3.2 & ORRUAC-5258 ends
        lstContactIds.add(objCase.ContactId);
        lstSponsorIds.add(objCase.UAC_sponsor__c);
        lstContactIdsRelationshiptoUAC.add(objCase.ContactId);
        lstSponsorIdsRelationshiptoUAC.add(objCase.UAC_sponsor__c);
        // Added for ORRUAC-4561 AC 5 Starts
        if (objCase.UAC_eventID__c != null) {
          lstEventIds.add(objCase.UAC_eventID__c);
        }
        // Added for ORRUAC-4561 AC 5 Ends
      }
      if (String.isNotBlank(objAccountSettings.UAC_NOCAccountId__c)
          && objCase.Type == Label.UAC_caseTypeSexualAbuseHotline) {
        objCase.AccountId = objAccountSettings.UAC_NOCAccountId__c;
      }
    }
    // Added for ORRUAC-4561 AC 4 - starts
    if (mapOldCase == null && !lstContactIds.isEmpty()) {
      map<id, UAC_adultContactRelationship__c> mapadultContactRelationship =
          new map<id, UAC_adultContactRelationship__c>();
      for (UAC_adultContactRelationship__c objAdulContactRelationship : [select id,
             UAC_relationshipType__c,
             UAC_uacLookup__c,
             UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_uacLookup__c
             in:lstContactIds and UAC_relationshipType__c = 'Primary Sponsor']) {
        mapadultContactRelationship.put(
            objAdulContactRelationship.UAC_uacLookup__c, objAdulContactRelationship);
      }
      for (Case objCase : mapNewCase.Values()) {
        if (mapadultContactRelationship.containskey(objCase.ContactId)) {
          objCase.UAC_sponsor__c =
              mapadultContactRelationship.get(objCase.ContactId).UAC_adultContact__c;
          lstSponsorIds.add(objCase.UAC_sponsor__c);
          lstSponsorIdsRelationshiptoUAC.add(objCase.UAC_sponsor__c);
        }
      }
    }
    // Added for ORRUAC-4561 AC 4 - ends
    // Added for ORRUAC-4561 AC 5 Starts
    if (!lstEventIds.isEmpty()) {
      map<id, UAC_Event__c> mapEvents = new map<id, UAC_Event__c>(
          [select id, UAC_eventStartDateTime__c from UAC_Event__c where id in:lstEventIds]);
      for (Case objCase : mapNewCase.Values()) {
        if (mapOldCase != null
            && mapOldCase.get(objCase.Id).UAC_eventID__c != objCase.UAC_eventID__c
            && objCase.UAC_eventID__c != null && mapEvents.containskey(objCase.UAC_eventID__c)) {
          objCase.UAC_dateOfIncident__c =
              mapEvents.get(objCase.UAC_eventID__c).UAC_eventStartDateTime__c;
        } else if (objCase.UAC_eventID__c != null
            && mapEvents.containskey(objCase.UAC_eventID__c)) {
          objCase.UAC_dateOfIncident__c =
              mapEvents.get(objCase.UAC_eventID__c).UAC_eventStartDateTime__c;
        }
      }
    }
    // Added for ORRUAC-4561 AC 5 Ends
    if (!lstContactIds.isEmpty()) {
      mapIdContact =
          New Map<Id, Contact>([Select UAC_program__c from Contact where Id in:lstContactIds]);
      for (Case objCaseDNF : [
             Select contactId,
             UAC_programFacility__c,
             UAC_dateTimeOfDischarge__c from Case Where RecordTYpe.DeveloperName =
                 'UAC_dischargeNotification' and contactId
             in:lstContactIds and UAC_typeOfDischarge__c
             !=:Label.UAC_typeOfDischargeTransfer order by UAC_dateTimeOfDischarge__c desc
           ]) {
        if (!mapContactCase.containsKey(objCaseDNF.contactId))
          mapContactCase.put(objCaseDNF.contactId, objCaseDNF);
      }
    }
    if (!lstSponsorIds.isEmpty()) {
      mapIdSponsor = New Map<Id, Contact>([Select id,
        MailingStreet,
        MailingCity,
        MailingPostalCode,
        MailingState from Contact where Id in:lstSponsorIds]);
    }
    if (!lstContactIdsRelationshiptoUAC.isEmpty() && !lstSponsorIdsRelationshiptoUAC.isEmpty()) {

      for (UAC_adultContactRelationship__c objAdultContactRelationship : [
             SELECT Id,
             UAC_adultContact__c,
             UAC_uacLookup__c FROM UAC_adultContactRelationship__c where UAC_adultContact__c
             in:lstSponsorIdsRelationshiptoUAC and UAC_uacLookup__c
             in:lstContactIdsRelationshiptoUAC
           ]) {
        mapRelationshiptoUAC.put(
            objadultContactRelationship.UAC_uacLookup__c, objadultContactRelationship);
      }
    }
    for (Case objCase : mapNewCase.Values()) {
      Case objOldCase;
      if (mapOldCase != null) {
        objOldCase = mapOldCase.get(objCase.Id);
        if (objOldCase.ContactId != objCase.ContactId && objCase.ContactId != null) {
          system.debug('mapContactCase:' + mapContactCase);
          system.debug('mapContactCase.containsKey(objCase.ContactId):'
              + mapContactCase.containsKey(objCase.ContactId));
          system.debug('mapIdContact:' + mapIdContact);
          system.debug(' mapIdContact.containsKey(objCase.ContactId:' + mapIdContact);
          If(mapContactCase.containsKey(objCase.ContactId)) {
            objCase.UAC_programFacility__c =
                mapContactCase.get(objCase.ContactId).UAC_programFacility__c;
            objCase.UAC_dateTimeOfDischarge__c =
                mapContactCase.get(objCase.ContactId).UAC_dateTimeOfDischarge__c;
          }
          else If(mapIdContact.containsKey(objCase.ContactId)) {
            objCase.UAC_programFacility__c = mapIdContact.get(objCase.ContactId).UAC_program__c;
          }
          else {
            objCase.UAC_programFacility__c = null;
            objCase.UAC_dateTimeOfDischarge__c = null;
          }
        }
        if (objOldCase.UAC_sponsor__c != objCase.UAC_sponsor__c && objCase.UAC_sponsor__c != null
            && mapIdSponsor != null && mapIdSponsor.containsKey(objCase.UAC_sponsor__c)) {
          objCase.UAC_dischargeAddress__c = mapIdSponsor.get(objCase.UAC_sponsor__c).MailingStreet;
          objCase.UAC_dischargeCity__c = mapIdSponsor.get(objCase.UAC_sponsor__c).MailingCity;
          objCase.UAC_dischargeState__c =
              stateMap(mapIdSponsor.get(objCase.UAC_sponsor__c).MailingState);
          objCase.UAC_dischargeZipCode__c =
              mapIdSponsor.get(objCase.UAC_sponsor__c).MailingPostalCode;
        }
        if ((objCase.UAC_notificationOfConcernCategory__c
                    != objOldCase.UAC_notificationOfConcernCategory__c
                || objCase.UAC_nocAllegedPerpertrator__c
                    != objOldCase.UAC_nocAllegedPerpertrator__c)
            && String.isNotBlank(objOldCase.UAC_notificationOfConcernCategory__c)
            && objOldCase.UAC_notificationOfConcernCategory__c.containsIgnoreCase(
                Label.UAC_notifOfConcAbuseNeg)
            && String.isNotBlank(objOldCase.UAC_nocAllegedPerpertrator__c)
            && objOldCase.UAC_nocAllegedPerpertrator__c.containsIgnoreCase(
                Label.UAC_notifOfConcernProgStaff)
            && String.isNotBlank(objAppSettings.UAC_NOCQueueID__c)) {
          objCase.AccountId = null;  // Will auto default to family group ID
        }
      } else {
        If(mapContactCase.containsKey(objCase.ContactId)) {
          objCase.UAC_programFacility__c =
              mapContactCase.get(objCase.ContactId).UAC_programFacility__c;
          objCase.UAC_dateTimeOfDischarge__c =
              mapContactCase.get(objCase.ContactId).UAC_dateTimeOfDischarge__c;
        }
        else If(mapIdContact.containsKey(objCase.ContactId)) {
          objCase.UAC_programFacility__c = mapIdContact.get(objCase.ContactId).UAC_program__c;
        }
        else {
          objCase.UAC_programFacility__c = null;
          objCase.UAC_dateTimeOfDischarge__c = null;
        }
        if (objCase.UAC_sponsor__c != null && mapIdSponsor.containsKey(objCase.UAC_sponsor__c)) {
          objCase.UAC_dischargeAddress__c = mapIdSponsor.get(objCase.UAC_sponsor__c).MailingStreet;
          objCase.UAC_dischargeCity__c = mapIdSponsor.get(objCase.UAC_sponsor__c).MailingCity;
          objCase.UAC_dischargeState__c =
              stateMap(mapIdSponsor.get(objCase.UAC_sponsor__c).MailingState);
          objCase.UAC_dischargeZipCode__c =
              mapIdSponsor.get(objCase.UAC_sponsor__c).MailingPostalCode;
        }
      }
      if (String.isNotBlank(objCase.UAC_notificationOfConcernCategory__c)
          && objCase.UAC_notificationOfConcernCategory__c.containsIgnoreCase(
              Label.UAC_notifOfConcAbuseNeg)
          && String.isNotBlank(objCase.UAC_nocAllegedPerpertrator__c)
          && objCase.UAC_nocAllegedPerpertrator__c.containsIgnoreCase(
              Label.UAC_notifOfConcernProgStaff)
          && String.isNotBlank(objAppSettings.UAC_NOCQueueID__c)) {
        objCase.OwnerId = objAppSettings.UAC_NOCQueueID__c;
        objCase.AccountId = objAccountSettings.UAC_NOCAccountId__c;
      }
      If(objCase.ContactId != null && mapRelationshiptoUAC.containsKey(objCase.ContactId)) {
        objCase.UAC_relationshipToUAC__c = mapRelationshiptoUAC.get(objCase.ContactId).id;
      }
    }
  }

  /**
   * @description Adds a manual CaseShare record for NOCs for the creator if specific criteria are
   * met. This should be async but since this is the only way the creator keeps access this needs to
   * be synchronous.
   * @author James Qian (Deloitte) 2/1/2021
   * @param List<Case> lstCase
   **/
  public
  static void addNOCCaseShare(List<Case> lstCase) {
    UAC_appSettings__c objAppSettings = UAC_appSettings__c.getOrgDefaults();
    if (String.isBlank(objAppSettings.UAC_NOCSharingGroupID__c)) {
      return;
    }
    List<CaseShare> listCaseShares = new List<CaseShare>();
    for (Case caseCurrent : lstCase) {
      if (String.isNotBlank(caseCurrent.UAC_notificationOfConcernCategory__c)
          && caseCurrent.UAC_notificationOfConcernCategory__c.containsIgnoreCase(
              Label.UAC_notifOfConcAbuseNeg)
          && String.isNotBlank(caseCurrent.UAC_nocAllegedPerpertrator__c)
          && caseCurrent.UAC_nocAllegedPerpertrator__c.containsIgnoreCase(
              Label.UAC_notifOfConcernProgStaff)) {
        if (caseCurrent.Status != 'Submitted') {
          listCaseShares.add(new CaseShare(CaseAccessLevel = 'Edit',
              CaseId = caseCurrent.Id,
              UserOrGroupId = UserInfo.getUserId()));
        }
        if (String.isNotBlank(objAppSettings.UAC_NOCSharingGroupID__c)
            && caseCurrent.Type != Label.UAC_caseTypeSexualAbuseHotline) {
          listCaseShares.add(new CaseShare(CaseAccessLevel = 'Edit',
              CaseId = caseCurrent.Id,
              UserOrGroupId = objAppSettings.UAC_NOCSharingGroupID__c));
        }
      }
    }
    if (listCaseShares.isEmpty()) {
      return;
    }
    List<Database.SaveResult> lstSaveResult = Database.insert(listCaseShares, false);
    for (Database.SaveResult objSaveResult : lstSaveResult) {
      if (!objSaveResult.isSuccess()) {
        for (Database.Error objError : objSaveResult.getErrors()) {
          UAC_errorLog.platformEventErrorLog(
              objError.getMessage(), 'addNOCCaseShare', 'addNOCCaseShare', objError.getMessage());
        }
      }
    }
  }

  /**
   * @description Adds a manual CaseShare record for NOCs for the creator if specific criteria are
   * met
   * @author James Qian (Deloitte) 3/8/2021
   * @param List<Case> lstCase
   **/
  public
  static void addNOCCaseShareOnUpdate(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {

    List<Case> listCasesToProcess = new List<Case>();
    for (Case caseCurrent : mapNewCase.values()) {
      if (String.isNotBlank(caseCurrent.UAC_notificationOfConcernCategory__c)
          && String.isNotBlank(caseCurrent.UAC_nocAllegedPerpertrator__c)
          && (caseCurrent.UAC_notificationOfConcernCategory__c
                  != mapOldCase.get(caseCurrent.Id).UAC_notificationOfConcernCategory__c
              || caseCurrent.UAC_nocAllegedPerpertrator__c
                  != mapOldCase.get(caseCurrent.Id).UAC_nocAllegedPerpertrator__c)) {
        listCasesToProcess.add(caseCurrent);
      }
    }
    if (listCasesToProcess.isEmpty()) {
      return;
    }
    addNOCCaseShare(listCasesToProcess);
  }

  /**
   * @description Deletes case share records for NOC if the NOC is submitted
   * @author James Qian (Deloitte) 3/8/2021
   * @param List<Case> lstCase
   **/
  public
  static void deleteNOCCaseShareOnUpdate(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    Set<Id> setCaseIds = new Set<Id>();
    for (Case caseCurrent : mapNewCase.values()) {
      if (caseCurrent.Status == 'Submitted'
          && caseCurrent.Status != mapOldCase.get(caseCurrent.Id).Status
          && String.isNotBlank(caseCurrent.UAC_notificationOfConcernCategory__c)
          && caseCurrent.UAC_notificationOfConcernCategory__c.containsIgnoreCase(
              Label.UAC_notifOfConcAbuseNeg)
          && String.isNotBlank(caseCurrent.UAC_nocAllegedPerpertrator__c)
          && caseCurrent.UAC_nocAllegedPerpertrator__c.containsIgnoreCase(
              Label.UAC_notifOfConcernProgStaff)) {
        setCaseIds.add(caseCurrent.Id);
      }
    }
    if (setCaseIds.isEmpty() || System.isFuture()) {
      return;
    }
    deleteNOCCaseShareForUser(setCaseIds);
  }

  /**
   * @description Async method to delete case shares
   * @author James Qian (Deloitte) 3/9/2021
   * @param Set<Id> setCaseIds
   **/
  @future private static void deleteNOCCaseShareForUser(Set<Id> setCaseIds) {
    if (setCaseIds.isEmpty()) {
      return;
    }
    UAC_appSettings__c objAppSettings = UAC_appSettings__c.getOrgDefaults();
    if (String.isBlank(objAppSettings.UAC_NOCQueueID__c)) {
      return;
    }
    List<Case> listCasesToUpdate = new List<Case>();
    for (Id caseId : setCaseIds) {
      listCasesToUpdate.add(new Case(Id = caseId, OwnerId = objAppSettings.UAC_NOCQueueID__c));
    }
    if (!listCasesToUpdate.isEmpty()) {
      try {
        update listCasesToUpdate;
      } catch (Exception e) {
        UAC_errorLog.logError(
            e.getMessage(), '', 'Updating NOC Case Owner', e.getStackTraceString());
      }
    }
    List<CaseShare> listCaseShareToDelete = new List<CaseShare>();
    for (CaseShare currentShare : [SELECT Id, UserOrGroupId FROM CaseShare WHERE CaseId
           IN:setCaseIds AND RowCause = 'Manual']) {
      if (String.valueOf(currentShare.UserOrGroupId).left(3) == '005') {
        listCaseShareToDelete.add(currentShare);
      }
    }
    if (!listCaseShareToDelete.isEmpty()) {
      try {
        delete listCaseShareToDelete;
      } catch (Exception e) {
        UAC_errorLog.logError(
            e.getMessage(), '', 'Deleting NOC Case Shares', e.getStackTraceString());
      }
    }
  }

  /* @description ORRUAC-2428 AC1- Email to ACF
   * @author Piyush 9/13/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void NOCEmailToHsPrsProv(List<Case> lstCase) {
    list<EmailTemplate> objAlertPSATeam = [select id,
      developername from emailtemplate where developername =:Label.UAC_NOCEmailToHsPrsProv];
    Set<Id> setParent = new Set<Id>();
    Set<Id> setUsers = new Set<Id>();
    for (Case obCse : lstCase) {
      if (obCse.ParentId != null) {
        setParent.add(obCse.ParentId);
      }
    }
    Map<Id, Case> mapHsPrsCase = new Map<Id, Case>(
        [Select Id, Status, Type, UAC_hSPRSPrimaryProviderName__c from Case where id in:setParent]);
    for (Case objCse : mapHsPrsCase.values()) {
      if (objCse.UAC_hSPRSPrimaryProviderName__c != null) {
        setUsers.add(objCse.UAC_hSPRSPrimaryProviderName__c);
      }
    }
    Map<Id, User> mapHsToUser =
        new Map<Id, User>([Select Id, Email from User where id in:setUsers]);
    list<Messaging.SingleEmailMessage> lstmessages = new list<Messaging.SingleEmailMessage>();
    if (!objAlertPSATeam.isEmpty()) {
      for (Case objNewCase : lstCase) {
        if (FeatureManagement.checkPermission(strCustomPermissionFFS)
            || FeatureManagement.checkPermission(strCustomPermissionCaseManager)
            || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)) {
          if (mapHsPrsCase.size() > 0
              && (mapHsPrsCase.get(objNewCase.ParentId).Type == strCaseTypePRSOnly
                  || mapHsPrsCase.get(objNewCase.ParentId).Type == strCaseTypePRSTVPRA
                  || mapHsPrsCase.get(objNewCase.ParentId).Type == strCaseTypePRSAfterORRMandated
                  || mapHsPrsCase.get(objNewCase.ParentId).Type == strCaseTypePRSAfterDiscretionary)
              && mapHsPrsCase.get(objNewCase.ParentId).Status == label.UAC_caseStatusActive) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[]{
                mapHsToUser
                    .get(mapHsPrsCase.get(objNewCase.ParentId).UAC_hSPRSPrimaryProviderName__c)
                    .Email};
            message.setTemplateId(objAlertPSATeam[0].id);
            message.setWhatId(objnewCase.Id);
            message.settargetObjectId(objnewCase.ContactId);
            message.setTreatTargetObjectAsRecipient(false);
            lstmessages.add(message);
          }
        }
      }
      if (lstmessages != null && lstmessages.size() > 0) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
      }
    }
  }

  /* @description ORRUAC-2428 AC3.1 3.2- Email to ACF
   * @author Piyush 9/13/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void NOCEmailToACFPrgDir(List<Case> lstCase) {
    list<EmailTemplate> objAlertACFDir =
        [select id, developername from emailtemplate where developername =:Label.UAC_NOCEmailToACF];
    Set<Id> setPrgram = new Set<Id>();
    Set<Id> setUsers = new Set<Id>();
    Map<Id, List<AccountTeamMember>> mapActIdTolstActMem = new Map<Id, List<AccountTeamMember>>();
    List<String> toLst = new List<String>();
    List<String> recipientlist = new List<String>{Label.UAC_nocACFPrgDir};
    for (Case obCse : lstCase) {
      if (obCse.UAC_programFacility__c != null) {
        setPrgram.add(obCse.UAC_programFacility__c);
      }
    }
    List<AccountTeamMember> lstActTmMem =
        [Select Id, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId
          in:setPrgram];
    for (AccountTeamMember act : lstActTmMem) {
      if (!setUsers.contains(act.UserId)) {
        setUsers.add(act.UserId);
      }
      if (mapActIdTolstActMem.containsKey(act.AccountId)) {
        List<AccountTeamMember> actlst = mapActIdTolstActMem.get(act.AccountId);
        actlst.add(act);
      } else {
        mapActIdTolstActMem.put(act.AccountId, new List<AccountTeamMember>{act});
      }
    }
    Map<Id, User> mapIdToUser =
        new Map<Id, User>([Select Id, Email from User where id in:setUsers]);
    list<Messaging.SingleEmailMessage> lstmessages = new list<Messaging.SingleEmailMessage>();

    if (!objAlertACFDir.isEmpty()) {
      for (Case objNewCase : lstCase) {
        if ((FeatureManagement.checkPermission(strCustomPermissionFFS)
                || FeatureManagement.checkPermission(strCustomPermissionCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
                || FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)
                || FeatureManagement.checkPermission(strCustomPermissionSupervisor)
                || FeatureManagement.checkPermission(strCustomPermissionDCW))
            && objNewCase.Status == Label.UAC_CaseNOCStatusSubmitted) {
          if (objNewCase.UAC_eventOccurredInORRCare__c == 'Yes'
              && objNewCase.UAC_notificationOfConcernCategory__c == Label.UAC_notifOfConcAbuseNeg) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for (AccountTeamMember atm :
                mapActIdTolstActMem.get(objNewCase.UAC_programFacility__c)) {
              if (atm.TeamMemberRole == Label.UAC_accountTeamRoleNameFFS) {
                toLst.add(atm.UserId);
              } else if (atm.TeamMemberRole == Label.UAC_accountTeamRoleNameFFFS) {
                toLst.add(atm.UserId);
              } else if (atm.TeamMemberRole == Label.UAC_accountTeamRoleNamePO) {
                toLst.add(atm.UserId);
              } else if (atm.TeamMemberRole == Label.UAC_accountTeamRolePD) {
                toLst.add(atm.UserId);
              }
            }
            if (!toLst.IsEmpty()) {
              for (String str : toLst) {
                recipientlist.add(mapIdToUser.get(str).Email);
              }
            }
            message.setToAddresses(recipientlist);
            message.setTemplateId(objAlertACFDir[0].id);
            message.setWhatId(objnewCase.Id);
            message.settargetObjectId(objnewCase.ContactId);
            message.setTreatTargetObjectAsRecipient(false);
            lstmessages.add(message);
          } else if (objNewCase.UAC_notificationOfConcernCategory__c
              == Label.UAC_notifOfConcDeathOfUAC) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for (AccountTeamMember atm :
                mapActIdTolstActMem.get(objNewCase.UAC_programFacility__c)) {
              if (atm.TeamMemberRole == Label.UAC_accountTeamRoleNameFFS) {
                toLst.add(atm.UserId);
              } else if (atm.TeamMemberRole == Label.UAC_accountTeamRoleNameFFFS) {
                toLst.add(atm.UserId);
              } else if (atm.TeamMemberRole == Label.UAC_accountTeamRoleNamePO) {
                toLst.add(atm.UserId);
              } else if (atm.TeamMemberRole == Label.UAC_accountTeamRolePD) {
                toLst.add(atm.UserId);
              }
            }
            if (!toLst.IsEmpty()) {
              for (String str : toLst) {
                recipientlist.add(mapIdToUser.get(str).Email);
              }
            }
            message.setToAddresses(recipientlist);
            message.setTemplateId(objAlertACFDir[0].id);
            message.setWhatId(objnewCase.Id);
            message.settargetObjectId(objnewCase.ContactId);
            message.setTreatTargetObjectAsRecipient(false);
            lstmessages.add(message);
          }
        }
      }
      if (lstmessages != null && lstmessages.size() > 0) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
      }
    }
  }

  /* @description ORRUAC-1549- AC5 Status of NOC = Submitted Then the
   *NOC cannot be deleted
   * @author Manoj Sharma (Deloitte) 8/3/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void CheckCaseNOCDelete(Map<Id, Case> mapOldCases, List<Case> listOldCase) {
    listOldCase[0].adderror(Label.UAC_CaseNOCStatusSubmitted);
  }
  /** @description ORRUAC-1547-  Create task for PrS entry owner
   * @author Ankur Aggarwal (Deloitte) 8/8/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void createTaskForPRS(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    string strnotificationRecordtypeTask = Label.UAC_notificationRecordtypeTask;
    string strPRSRecordtypeTask = Label.UAC_prsEventRecordType;

    Id idNotificationRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                   .get(strnotificationRecordtypeTask)
                                   .getRecordTypeId();

    /*Id idPRSEntryRecType =
    Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
    .get(strPRSRecordtypeTask)
    .getRecordTypeId();
    List<id> lstClosedHSPrsEntry = new list<id>();*/
    list<task> lstObjTask = new list<task>();
    /* list<UAC_referralAssessment__c> lstObjPRSEntry =  new list<UAC_referralAssessment__c>();*/

    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if (objOldCase.status != objCase.status && objCase.status == strHSPRSClosedStatus
          && (objCase.type == 'PRS -Only' || objCase.type == 'PRS-TVPRA'
              || objCase.type == 'PRS- After ORR Mandated'
              || objCase.type == 'PRS- After Discretionary')) {
        Task objTask = new Task();
        objTask.recordtypeid = idNotificationRecType;
        objTask.Subject = Label.UAC_subjectForPrsTask + ' ' + objCase.CaseNumber;
        objTask.whatid = objCase.id;
        objTask.OwnerId = objCase.OwnerId;
        objTask.Status = strNotStartedSatus;
        objTask.Priority = strHighPriority;
        lstObjTask.add(objTask);
      }
    }
    system.debug(lstObjTask);
    if (lstObjTask != null && lstObjTask.size() > 0) insert lstObjTask;
    /*system.debug(lstClosedHSPrsEntry);
    lstObjPRSEntry = [select id,name,UAC_assignedProviderName__c from UAC_referralAssessment__c
    where uac_entry__c in: lstClosedHSPrsEntry and  recordtype.id = :idPRSEntryRecType and
    uac_status__c != 'Submitted'];
    for(UAC_referralAssessment__c ObjPRSEntry : lstObjPRSEntry){
    }
    system.debug(lstObjTask);
    if(lstObjTask != null && lstObjTask.size() > 0)
      insert lstObjTask;*/
  }
  /**
   * @author       James Qian(Deloitte)
   * @description  Method will create Case team members on newly created manifests.
   * @param        Map of newly inserted cases
   */
  public
  static void setCaseTeamMembersOnManifests(Map<Id, Case> mapNewCases) {
    Map<Id, Id> mapProgramIdToLCMId = new Map<Id, Id>();

    for (Case objCase : mapNewCases.values()) {
      if (String.isNotBlank(objCase.UAC_currentProgram__c)) {
        mapProgramIdToLCMId.put(objCase.UAC_currentProgram__c, null);
      }
    }
    if (mapProgramIdToLCMId.isEmpty()) {
      return;
    }
    for (AccountTeamMember atmCurrent : [
           SELECT AccountId,
           UserId FROM AccountTeamMember WHERE AccountId
           IN:mapProgramIdToLCMId.keyset() AND TeamMemberRole
            =:Label.UAC_accountTeamRoleLCM
         ]) {
      mapProgramIdToLCMId.put(atmCurrent.AccountId, atmCurrent.UserId);
    }
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameLCM][0].Id;
    List<CaseTeamMember> listCaseTeamMembersToInsert = new List<CaseTeamMember>();
    for (Case objCase : mapNewCases.values()) {
      if (mapProgramIdToLCMId.get(objCase.UAC_currentProgram__c) != null) {
        listCaseTeamMembersToInsert.add(new CaseTeamMember(ParentId = objCase.Id,
            MemberId = mapProgramIdToLCMId.get(objCase.UAC_currentProgram__c),
            TeamRoleId = idCaseTeamRole));
      }
    }
    if (!listCaseTeamMembersToInsert.isEmpty()) {
      insert listCaseTeamMembersToInsert;
    }
  }
  /** @description Process Cases to update Beds
   * @author Issam Awwad (Deloitte) 8/11/2020
   * @param Map of new  Case record
   * @return None
   **/
  public
  static void processCasesForBedUpdate(
      List<Case> lstOfCasesToProcess, Map<Id, Case> mapOldCaseCasted) {
    UAC_assetService newAssetService = new UAC_assetService();
    newAssetService.mapRecordTypesByDeveloperName = mapRecordTypesByDeveloperName;
    newAssetService.handleAssetUpdates(lstOfCasesToProcess, mapOldCaseCasted);
  }

  /** @description ORRUAC-2382 -  Auto generate DNF from after udpate of Transfer Request
   * @author Piyush - 09/22/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void createDNFFmTReq(Map<Id, Case> mapNewCasess, Map<Id, Case> mapOldCase) {
    Id idTReqRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeTransferRequest)
                           .getRecordTypeId();
    Id idTreqInRecType =
        mapRecordTypesByDeveloperName.get(Label.UAC_TransferRequestInflux).getRecordTypeId();
    Id idDNFRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification).getRecordTypeId();
    List<Case> lstDNFCaseInser = new List<Case>();
    Set<Id> setParentTReq = new Set<Id>();
    for (Case obC : mapNewCasess.values()) {
      if (obC.ParentId != null) {
        setParentTReq.add(obC.ParentId);
      }
    }
    Map<Id, Case> mapIdToParentAd =
        new Map<Id, Case>([Select Id, UAC_admittedDateTime__c from Case where Id in:setParentTReq]);
    System.debug('map parent :' + mapIdToParentAd);
    for (Case objCase : mapNewCasess.values()) {
      Case objOldCase = mapOldCase.get(objCase.Id);
      if ((objCase.recordTypeId == idTReqRecType || objCase.recordTypeId == idTreqInRecType)
          && objCase.Status == strInTransferCaseStatusFFSRev
          && objCase.UAC_orrDecision__c == strTransferApprovedORR
          && (objOldCase.UAC_orrDecision__c != objCase.UAC_orrDecision__c
              || objOldCase.Status != objCase.Status)  // ORRUAC-4255
      ) {
        Case objDNFCase = new Case();
        objDNFCase.recordTypeId = idDNFRecType;
        objDNFCase.ParentId = objCase.Id;
        objDNFCase.ContactId = objCase.ContactId;
        objDNFCase.UAC_typeOfDischarge__c = strTypeOfDischargeTransfer;
        objDNFCase.UAC_programFacility__c = objCase.UAC_currentProgram__c;
        objDNFCase.UAC_dischargeProgramName__c = objCase.UAC_programFacility__c;
        objDNFCase.UAC_admittedDateTime__c =
            mapIdToParentAd.get(objCase.ParentId).UAC_admittedDateTime__c;
        System.debug('admi dt time ' + objDNFCase.UAC_admittedDateTime__c);
        objDNFCase.UAC_disORRFinalDecisionDateDischargeNew__c = objCase.UAC_orrFinalDecisionDate__c;
        lstDNFCaseInser.add(objDNFCase);
      }
    }
    system.debug('lstDNFCaseInser size:' + lstDNFCaseInser.size());
    if (!lstDNFCaseInser.IsEmpty()) {
      insert lstDNFCaseInser;
    }
  }
  /**
   * @description ORRUAC-438 - Create background check record for sponsor contacts changes for 2987
   * @author Vaibhav Kudesia (Deloitte) | 9/14/2020
   * @param lstCase
   * @return void
   **/
  public
  static void createCaseSponsorBackgroundChecks(set<Id> lstCaseIds) {
    list<UAC_backgroundCheck__c> lstBGCtoInsertFinal = new list<UAC_backgroundCheck__c>();
    list<Id> lstContactIds = new list<Id>();
    list<UAC_associatedSponsorApplication__c> lstASAtoInsert =
        new list<UAC_associatedSponsorApplication__c>();
    // For Sponsor
    // clang-format off
    list<Case> lstCases = [Select id,
      UAC_relationshipToUAC__r.UAC_category__c,
      UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresStateLocalCheck__c,
      UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresCAOrNCheck__c,
      UAC_relationshipToUAC__c,
      UAC_relationshipToUAC__r.UAC_adultContact__c,
      UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresFBIBackgroundCheck__c from case where Id =:lstCaseIds];
    // clang-format on

    for (Case cs : lstCases) {
      lstContactIds.add(cs.UAC_relationshipToUAC__r.UAC_adultContact__c);
    }

    List<UAC_backgroundCheck__c> lstBGCOld = [Select id,
      UAC_backgroundCheckType__c,
      UAC_adultContact__c from UAC_backgroundCheck__c where UAC_adultContact__c
      =:lstContactIds and UAC_expirationDate__c > TODAY];

    for (Case cs : lstCases) {

      Contact ObjSponsorContact = new Contact(Id = cs.UAC_relationshipToUAC__r.UAC_adultContact__c);
      ObjSponsorContact.UAC_FFSRequiresCAOrNCheck__c =
          cs.UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresCAOrNCheck__c;
      ObjSponsorContact.UAC_FFSRequiresFBIBackgroundCheck__c =
          cs.UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresFBIBackgroundCheck__c;
      ObjSponsorContact.UAC_FFSRequiresStateLocalCheck__c =
          cs.UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresStateLocalCheck__c;

      for (UAC_backgroundCheck__c objBGCNew :
          UAC_associatedContactTriggerHelper.createBackGroundChk(ObjSponsorContact,
              cs.UAC_relationshipToUAC__r.UAC_category__c,
              cs.Id,
              cs.UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresCAOrNCheck__c)) {
        boolean boolBGCExist = false;
        for (UAC_backgroundCheck__c objBGCOld : lstBGCOld) {
          if (objBGCOld.UAC_backgroundCheckType__c == objBGCNew.UAC_backgroundCheckType__c
              && objBGCOld.UAC_adultContact__c == objBGCNew.UAC_adultContact__c) {
            boolBGCExist = true;
            lstASAtoInsert.add(
                UAC_associatedContactTriggerHelper.createAssociatedSponsorApplication(
                    objBGCOld.Id, cs.Id));
          }
        }
        if (!boolBGCExist) {
          lstBGCtoInsertFinal.add(objBGCNew);
        }
      }
    }
    if (!lstBGCtoInsertFinal.isEmpty()) {
      List<Database.SaveResult> lstSaveResult = Database.insert(lstBGCtoInsertFinal, false);
      // Inspect save result
      for (Database.SaveResult objSaveResult : lstSaveResult) {
        if (!objSaveResult.isSuccess()) {
          for (Database.Error objError : objSaveResult.getErrors()) {
            UAC_errorLog.platformEventErrorLog(
                objError.getMessage(), 'createBackGroundChk', 'UAC_associatedContactTriggerHelper','');
          }
        }
      }
    }
    for (UAC_backgroundCheck__c objBGC : lstBGCtoInsertFinal) {
      for (Case cs : lstCases) {
        lstASAtoInsert.add(UAC_associatedContactTriggerHelper.createAssociatedSponsorApplication(
            objBGC.Id, cs.Id));
      }
    }
    if (!lstASAtoInsert.isEmpty()) {
      insert lstASAtoInsert;
    }
  }

  /**
   * @description ORRUAC-2774 - Populate medications and allergies on insert
   * @author Issam Awwad (Deloitte) | 09/29/2020
   * @param List<Case> lstOfInfluxTransferCases
   * @
   **/
  public
  static void populateInfluxTransferVaues(List<Case> lstOfInfluxTransferCases) {
    Set<Id> setOfUACs = new Set<Id>();
    Map<Id, List<UAC_medication__c>> mapOfUACToMedication = new Map<Id, List<UAC_medication__c>>();
    Map<Id, List<UAC_allergy__c>> mapOfUACToAllergies = new Map<Id, List<UAC_allergy__c>>();

    for (Case objCase : lstOfInfluxTransferCases) {
      setOfUACs.add(objCase.ContactId);
    }
    List<UAC_medication__c> lstOfMedication = [SELECT Id,
      UAC_associatedUAC__c,
      UAC_dateDiscontinued__c,
      Name FROM UAC_medication__c WHERE UAC_associatedUAC__c IN:setOfUACs];
    List<UAC_allergy__c> lstOfAllergies = [SELECT Id,
      UAC_associatedUAC__c,
      UAC_allergen__c FROM UAC_allergy__c WHERE UAC_associatedUAC__c IN:setOfUACs];
    for (UAC_medication__c objMedication : lstOfMedication) {
      List<UAC_medication__c> lstOfMedicationTemp = new List<UAC_medication__c>();
      if (objMedication.UAC_dateDiscontinued__c == null) {
        if (mapOfUACToMedication.containsKey(objMedication.UAC_associatedUAC__c)) {
          lstOfMedicationTemp = mapOfUACToMedication.get(objMedication.UAC_associatedUAC__c);
          lstOfMedicationTemp.add(objMedication);
          mapOfUACToMedication.put(objMedication.UAC_associatedUAC__c, lstOfMedicationTemp);
        } else {
          lstOfMedicationTemp.add(objMedication);
          mapOfUACToMedication.put(objMedication.UAC_associatedUAC__c, lstOfMedicationTemp);
        }
      }
    }
    for (UAC_allergy__c objAllergy : lstOfAllergies) {
      List<UAC_allergy__c> lstOfAllergiesTemp = new List<UAC_allergy__c>();
      if (mapOfUACToAllergies.containsKey(objAllergy.UAC_associatedUAC__c)) {
        lstOfAllergiesTemp = mapOfUACToAllergies.get(objAllergy.UAC_associatedUAC__c);
        lstOfAllergiesTemp.add(objAllergy);
        mapOfUACToAllergies.put(objAllergy.UAC_associatedUAC__c, lstOfAllergiesTemp);
      } else {
        lstOfAllergiesTemp.add(objAllergy);
        mapOfUACToAllergies.put(objAllergy.UAC_associatedUAC__c, lstOfAllergiesTemp);
      }
    }
    for (Case objCase : lstOfInfluxTransferCases) {
      String strMedication = '';
      String strAllergies = '';
      List<UAC_medication__c> lstOfMedicationTemp = mapOfUACToMedication.get(objCase.ContactId);
      List<UAC_allergy__c> lstOfAllergiesTemp = mapOfUACToAllergies.get(objCase.ContactId);
      if (lstOfMedicationTemp != null && !lstOfMedicationTemp.isEmpty()) {
        for (UAC_medication__c objMedication : lstOfMedicationTemp) {
          strMedication = strMedication + objMedication.Name + ';';
        }
      } else {
        strMedication = 'NONE';
      }
      if (lstOfAllergiesTemp != null && !lstOfAllergiesTemp.isEmpty()) {
        for (UAC_allergy__c objAllergy : lstOfAllergiesTemp) {
          strAllergies = strAllergies + objAllergy.UAC_allergen__c + ';';
        }
      } else {
        strAllergies = 'NONE';
      }
      objCase.UAC_medications__c = strMedication;
      objCase.UAC_allergies__c = strAllergies;
    }
  }
  /**
   * @description ORRUAC-2774 - generic method to process Admissions
   *methods.
   * @author Issam Awwad (Deloitte) 10/1/20
   * @param Map<Id, case> mapNewCases
   * @param Map<Id, case> mapOldCases
   * @return void
   **/
  public
  static void processAdmissionsOnUpdate(Map<Id, case> mapNewCases, Map<Id, case> mapOldCases) {

    for (Case objCase : mapNewCases.values()) {
      if (objCase.Status == strPendingMedicalClearanceStatus) {
        if (Userinfo.getUserId() == objCase.UAC_influxPOC__c
            && objCase.UAC_InfluxPOCRecommendation__c == 'Referred') {
          objCase.addError(
              'Influx POC Recommendation can\'t be set to “Referred” if Status = Pending Medical Clearance');
        } else if (Userinfo.getUserId() == objCase.UAC_lno__c
            && objCase.UAC_LNORecommendation__c == 'Accepted') {
          objCase.addError(
              'LNO Recommendation can\'t be set to "Accepted" if Status = Pending Medical Clearance');
        }
      }
    }
  }

  /* @description ORRUAC-2698- AC5
   * @author Piyush(Deloitte) 10/2/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void populateSWB(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    Id idSWBRecType = mapRecordTypesByDeveloperName.get(strCaseRecTypeSWB).getRecordTypeId();
    Set<Id> staffids = new Set<Id>();
    for (Case obC : mapNewCase.Values()) {
      if (obC.UAC_staffSignature__c != null) {
        staffids.add(obC.UAC_staffSignature__c);
      }
    }
    Map<Id, User> mapUser = new Map<Id, User>([Select Id, Title from User where Id in:staffids]);
    for (Case objCase : mapNewCase.Values()) {
      Case objOldCase;
      if (mapOldCase != null) {
        objOldCase = mapOldCase.get(objCase.Id);
      }
      if (objCase.Status == Label.UAC_CaseNOCStatusSubmitted
          && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager))
          && objCase.Status != objOldCase.Status && objCase.UAC_staffSignature__c != null) {
        objCase.UAC_staffTitle__c = mapUser.get(ObjCase.UAC_staffSignature__c).Title;
        objCase.UAC_dateTime__c = System.Now();
      }
    }
  }
  /**
   * @description ORRUAC-2416 - generic method to process Ltfc Travel Requests
   *methods.
   * @author Sarang Padhye (Deloitte) 10/1/20
   * @param List<case>lstLftcTravelRequests
   * @return void
   **/
  public
  static void processLftcTravelRequestBeforeInsert(List<case> lstLftcTravelRequests) {
    Map<ID, ID> mapParentCaseProgramToCurrCase = new Map<ID, ID>();
    set<id> setParentIds = new Set<id>();
    for (Case c : lstLftcTravelRequests) {
      if (c.ParentId != null) {
        setParentIds.add(c.ParentId);
      }
    }
    // Requery Case to get program
    Map<Id, Case> mapParentCases = new Map<Id, Case>([
      select id,
      UAC_admittedDateTime__c,
      UAC_programFacility__c from Case where id =:setParentIds and recordType.developername
                                                =:Label.UAC_caseRecordTypeAdmission
    ]);
    if (mapParentCases == null || mapParentCases.isEmpty()) return;
    Map<id, id> mapParentCaseToProgram = new map<id, id>();
    set<ID> setProgramSet = new set<ID>();
    for (Case c : mapParentCases.values()) {
      mapParentCaseToProgram.put(c.id, c.UAC_programFacility__c);
      setProgramSet.add(c.UAC_programFacility__c);
    }

    String lstUserTeamRole = strLeadCaseManager;
    Map<Id, Id> mapProgramToLCM = getUseronProgram(setProgramSet, lstUserTeamRole);
    for (Case objCase : lstLftcTravelRequests) {
      id idProgram = mapParentCaseToProgram.get(objCase.ParentId);
      id idLCM = null;
      if (idProgram != null) {
        idLCM = mapProgramToLCM.get(idProgram);
        objCase.UAC_currentProgram__c = idProgram;
        objCase.UAC_admittedDateTime__c =
            mapParentCases.get(objCase.Parentid).UAC_admittedDateTime__c;
      }
      if (idLCM != null) {
        objCase.UAC_leadCaseManager__c = idLCM;
      }
    }
  }
  /**
   * @description ORRUAC-2416 - generic method to process Ltfc Travel Requests
   *methods.
   * @author Sarang Padhye (Deloitte) 10/1/20
   * @param List<case>lstLftcTravelRequests
   * @return void
   **/
  public
  static void processLftcTravelRequestAfterInsert(map<id, case> mapCaseLtfcTravelRequest) {
    set<id> setParentIds = new set<id>();
    // Set<String> lstExcludeCaseMems = new set<String>{'Lead Case Manager','Case Manager'};
    List<CaseTeamMember> lstCaseTeamMemberToInsert = new List<CaseTeamMember>();
    id idReadOnlyCaseTeamMem =
        [select id from CaseTeamRole where name =:strReadOnlyCaseTeamMemRoleName][0].id;
    for (Case objCase : mapCaseLtfcTravelRequest.values()) {
      if (objCase.parentId != null) {
        setParentIds.add(objCase.parentId);
      }
    }
    // Query Case Team Members
    List<CaseTeamMember> lstCaseTeamMembers = new List<CaseTeamMember>();
    lstCaseTeamMembers =
        [select id, Parentid, Memberid, TeamRoleId, TeamRole.name from CaseTeamMember where Parentid
          =:setParentIds];
    if (lstCaseTeamMembers == null || lstCaseTeamMembers.isEmpty()) return;

    for (Case objCase : mapCaseLtfcTravelRequest.values()) {
      for (CaseTeamMember cTm : lstCaseTeamMembers) {
        // copy all members as readoly except the logged in user
        if (objCase.parentid == cTm.Parentid && cTm.memberid != UserInfo.getUserId()
            && !cTm.TeamRole.name.equals(strLeadCaseManager)) {
          CaseTeamMember newCaseTeamMem = new CaseTeamMember();
          newCaseTeamMem.Parentid = objCase.id;
          newCaseTeamMem.Memberid = cTm.Memberid;
          newCaseTeamMem.TeamRoleId = idReadOnlyCaseTeamMem;
          lstCaseTeamMemberToInsert.add(newCaseTeamMem);
        }
      }
    }
    if (!lstCaseTeamMemberToInsert.isEmpty()) {
      try {
        insert lstCaseTeamMemberToInsert;
      } catch (DMLException e) {
        system.debug('Exception ' + e.getMessage());
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Error Copying Case Team Members ');
      }
    }
  }
  /**
   * @description ORRUAC-2969: Histor tracking for NOC fields at Update
   *methods.
   * @author Manoj Sharma( Deloitte) 10/08/2020
   * @param Map<Id,Case> New Case, Map<Id,Case> Old Case
   * @return void
   **/
  public
  static void storeNOCHistoyTrackingUpdate(
      map<id, case> mapNocCaseNew, map<id, case> mapNocCaseOld) {

    List<UAC_historyTracking__c> lstHistoryTracking = new List<UAC_historyTracking__c>();
    List<Schema.FieldSetMember> trackedFields =
        SObjectType.Case.FieldSets.UAC_historyTrackingNOC.getFields();
    if (trackedFields.isEmpty()) return;
    List<UAC_historyTracking__c> fieldChanges = new List<UAC_historyTracking__c>();
    for (Case objCase : mapNocCaseNew.values()) {
      final Case objOldCase = mapNocCaseOld.get(objCase.Id);
      for (Schema.FieldSetMember fsm : trackedFields) {
        String fieldName = fsm.getFieldPath();
        String fieldLabel = fsm.getLabel();
        if (objCase.get(fieldName) == objOldCase.get(fieldName)) continue;
        UAC_historyTracking__c objHistoryTracking = new UAC_historyTracking__c();
        objHistoryTracking.UAC_date__c = System.Now();
        objHistoryTracking.UAC_lookupId__c = String.valueOf(objCase.Id);
        objHistoryTracking.UAC_field__c = fieldLabel;
        objHistoryTracking.UAC_fieldAPI__c = fieldName;
        objHistoryTracking.UAC_newValue__c = String.valueof(objCase.get(fieldName));
        objHistoryTracking.UAC_originalValue__c = String.valueof(objOldCase.get(fieldName));
        objHistoryTracking.UAC_user__c = userinfo.getuserid();
        lstHistoryTracking.add(objHistoryTracking);
      }
    }
    if (!lstHistoryTracking.isEmpty()) {
      Insert lstHistoryTracking;
    }
  }
  /**
   * @description ORRUAC-2969: Histor tracking for NOC fields at Inser
   *methods.
   * @author Manoj Sharma( Deloitte) 10/08/2020
   * @param List<Case> New Case
   * @return void
   **/
  public
  static void storeNOCHistoyTrackingInsert(List<Case> lstNocCaseNew) {

    List<UAC_historyTracking__c> lstHistoryTracking = new List<UAC_historyTracking__c>();
    List<Schema.FieldSetMember> trackedFields =
        SObjectType.Case.FieldSets.UAC_historyTrackingNOC.getFields();
    if (trackedFields.isEmpty()) return;
    List<UAC_historyTracking__c> fieldChanges = new List<UAC_historyTracking__c>();
    for (Case objCase : lstNocCaseNew) {

      for (Schema.FieldSetMember fsm : trackedFields) {
        String fieldName = fsm.getFieldPath();
        String fieldLabel = fsm.getLabel();
        if (objCase.get(fieldName) == null) continue;
        UAC_historyTracking__c objHistoryTracking = new UAC_historyTracking__c();
        objHistoryTracking.UAC_date__c = System.Now();
        objHistoryTracking.UAC_lookupId__c = String.valueOf(objCase.Id);
        objHistoryTracking.UAC_field__c = fieldLabel;
        objHistoryTracking.UAC_fieldAPI__c = fieldName;
        objHistoryTracking.UAC_newValue__c = String.valueof(objCase.get(fieldName));
        objHistoryTracking.UAC_user__c = userinfo.getuserid();
        lstHistoryTracking.add(objHistoryTracking);
      }
    }
    if (!lstHistoryTracking.isEmpty()) {
      Insert lstHistoryTracking;
    }
  }

  /** @description ORRUAC-1935 - Update ORR Decision on Sponsor Application
   * @author Rahul Roy (Deloitte) 10/28/2020
   * @param Map of new and old Case record
   * @return None
   **/
  public
  static void updateORRDecisionOnSponsorApplication(
      Map<Id, Case> mapNewCases, Map<Id, Case> mapOldCase) {
    Id idRelReqRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeReleaseRequest).getRecordTypeId();
    Id idSponsorAppRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeApiNameSponsorApplication)
            .getRecordTypeId();
    List<Case> lstCasesToUpdate = new List<Case>();
    Set<Id> setCaseIds = new Set<Id>();
    for (Case releaseReqCase : mapNewCases.values()) {
      if (releaseReqCase.RecordTypeId == idRelReqRecType
          && (releaseReqCase.UAC_orrDecision__c
                  != mapOldCase.get(releaseReqCase.Id).UAC_orrDecision__c
              || releaseReqCase.UAC_orrDecisionHS__c
                  != mapOldCase.get(releaseReqCase.Id).UAC_orrDecisionHS__c)) {
        setCaseIds.add(releaseReqCase.ParentId);
      }
    }
    Map<id, Case> mapOfParentIdToCase = new Map<id, Case>([
      SELECT id,
      ContactId,
      Status,
      ParentId,
      UAC_orrDecision__c,
      UAC_legacyCaseORRDecision__c,
      recordtype.DeveloperName,
      createddate FROM Case WHERE Id in:setCaseIds AND RecordType.DeveloperName
                                      =:strCaseRecordTypeApiNameSponsorApplication
    ]);

    if (!mapOfParentIdToCase.isEmpty()) {
      for (Case newCase : mapNewCases.values()) {
        Case objOldCase = mapOldCase.get(newCase.Id);
        if (newCase.recordTypeId == idRelReqRecType
            && objOldCase.UAC_orrDecision__c != newCase.UAC_orrDecision__c
            && newCase.ParentId != null && mapOfParentIdToCase.containsKey(newCase.ParentId)) {
          mapOfParentIdToCase.get(newCase.ParentId).UAC_legacyCaseORRDecision__c =
              newCase.UAC_orrDecision__c;
          lstCasesToUpdate.add(mapOfParentIdToCase.get(newCase.ParentId));
        }
        if (newCase.recordTypeId == idRelReqRecType
            && objOldCase.UAC_orrDecisionHS__c != newCase.UAC_orrDecisionHS__c
            && newCase.ParentId != null && mapOfParentIdToCase.containsKey(newCase.ParentId)) {
          mapOfParentIdToCase.get(newCase.ParentId).UAC_legacyCaseORRDecision__c =
              newCase.UAC_orrDecisionHS__c;
          lstCasesToUpdate.add(mapOfParentIdToCase.get(newCase.ParentId));
        }
      }
      if (!lstCasesToUpdate.isEmpty()) {
        update lstCasesToUpdate;
      }
    }
  }

  /* @description ORRUAC-1223 Auto populate Previous Sponsor Applications fields on Adult Contact
   * @author Rahul Roy (Deloitte) 11/02/2020
   * @param map of new and old Case record
   * @return None
   **/
  public
  static void populateFieldOnAdultContact(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    Id idSponsorAppRecType =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeApiNameSponsorApplication)
            .getRecordTypeId();
    List<Contact> lstAdultContactToUpdate = new List<Contact>();
    for (Case objCase : mapNewCase.values()) {
      Case objOld = mapOldCase.get(objCase.Id);
      if (objCase.recordTypeId == idSponsorAppRecType && objCase.Status != objOld.Status
          && (objCase.Status == strSponsorAppCompletionStatus
              || objCase.Status == Label.UAC_CaseStatusSponsorWithdrew
              || objCase.Status == strSponsorApplicationStatusFFSDecisionDoNotProceed)
          && objCase.UAC_sponsor__c != null) {
        Contact conToUpdate = new Contact(Id = objCase.UAC_sponsor__c);
        conToUpdate.UAC_previousApplication__c = true;
        lstAdultContactToUpdate.add(conToUpdate);
      }
    }
    if (!lstAdultContactToUpdate.isEmpty()) {
      try {
        update lstAdultContactToUpdate;
      } catch (DMLException e) {
        system.debug('Exception ' + e.getMessage());
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Error updating adult contact ');
      }
    }
  }

  /**
   * @description Sets CM and Clinician lookups for reference on influx
   * @author James Qian (Deloitte) 1/28/2021
   * @param List<Case> lstCase
   **/
  public
  static void setCMAndClinicianLookupsForInflux(List<Case> lstCase) {
    Map<Id, Id> mapAdmissionToCM = new Map<Id, Id>();
    Map<Id, Id> mapAdmissionToClinician = new Map<Id, Id>();
    for (Case caseCurrent : lstCase) {
      if (String.isNotBlank(caseCurrent.ParentId)) {
        mapAdmissionToCM.put(caseCurrent.ParentId, null);
      }
    }
    if (mapAdmissionToCM.isEmpty()) {
      return;
    }
    for (CaseTeamMember objCTM :
        [SELECT MemberId, ParentId, TeamRole.Name FROM CaseTeamMember WHERE ParentId
          IN:mapAdmissionToCM.keyset() AND TeamRole.Name IN(
                 : strCaseTeamRoleNameCM,
                 : Label.UAC_caseTeamRoleNameClinician)]) {
      if (objCTM.TeamRole.Name == strCaseTeamRoleNameCM) {
        mapAdmissionToCM.put(objCTM.ParentId, objCTM.MemberId);
      } else {
        mapAdmissionToClinician.put(objCTM.ParentId, objCTM.MemberId);
      }
    }
    for (Case caseCurrent : lstCase) {
      if (String.isBlank(caseCurrent.ParentId)) {
        continue;
      }
      if (mapAdmissionToCM.containsKey(caseCurrent.ParentId)
          && mapAdmissionToCM.get(caseCurrent.ParentId) != null) {
        caseCurrent.UAC_caseManager__c = mapAdmissionToCM.get(caseCurrent.ParentId);
      }
      if (mapAdmissionToClinician.containsKey(caseCurrent.ParentId)
          && mapAdmissionToClinician.get(caseCurrent.ParentId) != null) {
        caseCurrent.UAC_assignedClinician__c = mapAdmissionToClinician.get(caseCurrent.ParentId);
      }
    }
  }
  /**
   *
   * @author Ankur Aggarwal (Deloitte) |
   * description ORRUAC-3105
   **/
  public
  static void CheckValidations(string strobjectapi, string strrecordtype, list<case> lstnewCase) {

    set<string> setvaluesNotallowed = new set<string>();
    for (UAC_ObjectFieldValidation__mdt mdtObjectFieldValidation : [
           SELECT UAC_errorMessage__c,
           UAC_NewValue__c,
           UAC_recordType__c FROM UAC_ObjectFieldValidation__mdt WHERE UAC_ObjectAPI__c
           =:strobjectapi and UAC_recordType__c
           =:strrecordtype and UAC_action__c = 'insert'
         ]) {
      system.debug('mdt *** ' + mdtObjectFieldValidation);
      if (!setvaluesNotallowed.contains(mdtObjectFieldValidation.UAC_NewValue__c))
        setvaluesNotallowed.add(mdtObjectFieldValidation.UAC_NewValue__c);
    }
    if (setvaluesNotallowed != null && setvaluesNotallowed.size() > 0) {
      for (case objCase : lstnewCase) {
        system.debug(objCase.status + setvaluesNotallowed);
        system.debug(setvaluesNotallowed.contains(objCase.status));
        if (!Test.isRunningTest() && setvaluesNotallowed.contains(objCase.status))
          objCase.adderror(objCase.status + ' cannot be selected');
      }
    }
  }
  /**
   *
   * @author Ankur Aggarwal (Deloitte) |
   * description ORRUAC-3105
   **/
  public
  static void CheckValidations(string strobjectapi,
      string strrecordtype,
      map<id, case> mapNewCase,
      map<id, case> mapOldCase) {
    map<string, set<string>> mapOldNewValues = new map<string, set<string>>();
    for (UAC_ObjectFieldValidation__mdt mdtObjectFieldValidation : [
           SELECT UAC_errorMessage__c,
           UAC_NewValue__c,
           UAC_priorValue__c,
           UAC_recordType__c FROM UAC_ObjectFieldValidation__mdt WHERE UAC_ObjectAPI__c
           =:strobjectapi and UAC_recordType__c
           =:strrecordtype and UAC_action__c = 'update'
         ]) {
      system.debug('mdt *** ' + mdtObjectFieldValidation);
      set<string> setvaluesNotallowed = new set<string>();
      if (mapOldNewValues.containskey(mdtObjectFieldValidation.UAC_priorValue__c)) {
        setvaluesNotallowed = mapOldNewValues.get(mdtObjectFieldValidation.UAC_priorValue__c);
      }
      if (!setvaluesNotallowed.contains(mdtObjectFieldValidation.UAC_NewValue__c)) {
        setvaluesNotallowed.add(mdtObjectFieldValidation.UAC_NewValue__c);
      }
      mapOldNewValues.put(mdtObjectFieldValidation.UAC_priorValue__c, setvaluesNotallowed);
    }
    for (case objNewCase : mapNewCase.values()) {
      case objoldCase = mapOldCase.get(objNewCase.id);
      if(!Test.isRunningTest() && objNewCase.status != objOldcase.status && mapOldNewValues.containskey(objOldcase.status) && mapOldNewValues.get(objOldcase.status).contains(objNewCase.status))
        objNewCase.adderror(objNewCase.status + ' cannot be selected');
    }
  }

  /* @description ORRUAC-6531 AC1 Add CC in Entry team based on CC look up in Trans Req.
   * @author Piyush 9/13/2021
   * @param map of new cases list
   * @return None
   **/  
  public static void insrtTREntryTeam(Map<Id,Case> mapNewCase){
    Map<String, CaseTeamRole> mapRoleCsTmRole = new Map<String, CaseTeamRole>();
    List<CaseTeamMember> lstCsTmMemToInsrt = new List<CaseTeamMember>();
    for (CaseTeamRole objCsTmRole : [SELECT Id, Name, Accesslevel, PreferencesVisibleInCSP FROM CaseTeamRole]) {
      mapRoleCsTmRole.put(objCsTmRole.Name, objCsTmRole);
    }
    for (Case cs : mapNewCase.values()) {
      if (cs.UAC_caseCoordinator__c != null
          && (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
              || FeatureManagement.checkPermission(strCustomPermissionPD))) {
        lstCsTmMemToInsrt.add(new CaseTeamMember(ParentId = cs.Id,
            MemberId = cs.UAC_caseCoordinator__c,
            TeamRoleId = mapRoleCsTmRole.get('Case Coordinator').Id));
      }
    }
    if (!lstCsTmMemToInsrt.IsEmpty()) {
      try {
        insert lstCsTmMemToInsrt;
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error inserting TR Entry Team member',
            e.getStackTraceString());
      }
    }
  }
  /* @description ORRUAC-6531 AC2 update CC in Trans Req Entry team based on CC look up
    * @author Piyush 9/13/2021
    * @param map of old cases and new cases list
    * @return None
    **/
  public
  static void updtTREntryTeam(Map<Id, Case> mapNewCase, Map<Id, Case> mapOldCase) {
    Id transferRequestRecTypeId =
        mapRecordTypesByDeveloperName.get(strCaseRecordTypeTransferRequest).getRecordTypeId();
    Map<id, List<CaseTeamMember>> mapCsToCseTm = new Map<Id, List<CaseTeamMember>>();
    Map<String, CaseTeamRole> mapRoleCsTmRole = new Map<String, CaseTeamRole>();
    List<Case> listCasesToProcess = new List<Case>();
    for (Case currentCase : mapNewCase.values()) {
      if (currentCase.UAC_caseCoordinator__c
          != mapOldCase.get(currentCase.Id).UAC_caseCoordinator__c) {
        listCasesToProcess.add(currentCase);
      }
    }
    if (listCasesToProcess.isEmpty()) {
      return;
    }
    List<CaseTeamMember> lstCsTmMemToInsrt = new List<CaseTeamMember>();
    List<CaseTeamMember> lstCsTmMemToDel = new List<CaseTeamMember>();
    for (CaseTeamRole objCsTmRole :
        [SELECT Id, Name, Accesslevel, PreferencesVisibleInCSP FROM CaseTeamRole]) {
      mapRoleCsTmRole.put(objCsTmRole.Name, objCsTmRole);
    }
    for (CaseTeamMember ctm :
        [Select MemberId, ParentId, TeamRoleId from CaseTeamMember where ParentId
          in:mapNewCase.keyset()]) {
      if (mapCsToCseTm.containsKey(ctm.ParentId)) {
        mapCsToCseTm.get(ctm.ParentId).add(ctm);
      } else {
        mapCsToCseTm.put(ctm.ParentId, new List<CaseTeamMember>{ctm});
      }
    }
    for (Case cs : listCasesToProcess) {
      if (FeatureManagement.checkPermission(strCustomPermissionCaseManager)
          || FeatureManagement.checkPermission(strCustomPermissionLeadCaseManager)
          || FeatureManagement.checkPermission(strCustomPermissionCC)
          || FeatureManagement.checkPermission(strCustomPermissionPD)) {
        Case obOldCs = mapOldCase.get(cs.Id);
        if (cs.UAC_caseCoordinator__c != null) {
          lstCsTmMemToInsrt.add(new CaseTeamMember(ParentId = cs.Id,
              MemberId = cs.UAC_caseCoordinator__c,
              TeamRoleId = mapRoleCsTmRole.get('Case Coordinator').Id));
        }
        if (obOldCs.UAC_caseCoordinator__c != null && mapCsToCseTm != null
            && mapCsToCseTm.containsKey(obOldCs.Id)) {
          CaseTeamMember ctmAd = new CaseTeamMember();
          List<CaseTeamMember> lstctmDl = mapCsToCseTm.get(obOldCs.Id);
          lstctmDl = mapCsToCseTm.get(obOldCs.Id);
          for (CaseTeamMember ct : lstctmDl) {
            if (ct.MemberId == obOldCs.UAC_caseCoordinator__c
                && ct.TeamRoleId == mapRoleCsTmRole.get('Case Coordinator').Id) {
              lstCsTmMemToDel.add(ct);
            }
          }
        }
      }
    }
    try {
      if (!lstCsTmMemToDel.IsEmpty()) {
        delete lstCsTmMemToDel;
      }
      if (!lstCsTmMemToInsrt.IsEmpty()) {
        insert lstCsTmMemToInsrt;
      }
    } catch (DMLException e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'Error inserting/deleting TR Entry Team member',
          e.getStackTraceString());
    }
  }
   /* @description Assign Escalated to tier2 to true when owner is helpdesk tier2 queue
   * @author Anudeep 8/13/2020
   * @param map of old cases and new cases list
   * @return None
   **/
    public
        static void updateEscalationFlag(List<case> casesList, Map<Id, Case> mapOldCases) {
            Map<Id,Group> GroupIdToRecordMap = new Map<Id,Group>([Select Id from Group where type='Queue' and developername=:Tier_2_Helpdesk_Queue]);
            if(GroupIdToRecordMap.isEmpty()){
                return;
            }
                Id helpDeskQueueId = new List<Id>(GroupIdToRecordMap.keyset())[0];
                for(Case caseRec : casesList){
                    if((mapOldCases == NULL || mapOldCases != NULL && mapOldCases.get(caseRec.Id).ownerId != caseRec.ownerId)
                       && caseRec.ownerId == helpDeskQueueId){
                           caseRec.UC_escalatedToTier2__c = true;
                       }
                }
            }
}