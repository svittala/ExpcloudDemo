// clang-format off
/**
 * @File Name          : UAC_caseTriggerHandler.cls
 * @Description        : Handles all Case trigger traffic
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/3/2020, 12:50:03 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   Issam Awwad (Deloitte)     Initial Implementation.
 * 1.1    5/14/2020   Sachet Khanal (Deloitte)   ORRUAC-362: Update Contact Active Sponsor App flag
 * 1.2    5/28/2020   Ankur Aggarwal (Deloitte)  ORRUAC-189: Restrict multiple pending release
 *                                               request Active Sponsor App flag
 * 1.3    6/1/2020    Rahul Roy (Deloitte)       ORRUAC-324: Updates Case owner and Case status on insert/update
 * 1.4    6/3/2020    Sachet Khanal (Deloitte)   ORRUAC_-125: Auto-populate FRP Date Sent to Sponsor
 * 1.5    6/4/2020    Rahul Roy (Deloitte)       ORRUAC-317: Updates case owner and status from queue
 * 1.6    6/6/2020    Karthi Subramanian (Deloitte) ORRUAC-435: Auto-populate Application Completion Date
 * 1.7    6/8/2020    Rahul Roy (Deloitte)       ORRUAC-401: updates Final date on ORR Completed Status
 * 1.8    6/9/2020    Issam Awwad (Deloitte)      ORRUAC-69: Automatic Bed Update
 * 1.9    6/9/2020    Ankur Aggarwal (deloitte)  ORRUAC-480 -  Method restricts creating a discharge notification has an inactive discharge notification
 * 1.10   6/22/2020   Rahul Roy (Deloitte)       ORRUAC-187: Set program facility
 *                                               ORRUAC-187: Changes on Release Request
 * 1.11   6/24/2020   Abhisek Pati(Deloitte)     ORRUAC-39 - Create Initial Health Information Record
 * 1.12   7/14/2020   Rahul Roy (Deloitte)       ORRUAC-866: Auto generate HSPRS Referral
 * 1.13   7/21/2020   Ankur Aggarwal (Deloitte)  ORRUAC-1432: update RR status t HS completed- CM review
 * 1.14   7/21/2020   Abhisek Pati (Deloitte)    ORRUAC-206: Update Admitted Date and Contact LOC
 * 1.15   7/29/2020   James Qian (Deloitte)      Performance refactoring - pass by record type
 * 1.16   7/30/2020   Ankur Aggarwal (Deloitte)  Calling ReleaseRequestAlertMedicalStaff to send email
 * 1.17	  7/31/2020   chaitanya nandamuri(Deloitte) Calling TransferRequest functionality.
 * 1.18   8/06/2020   Abhisek Pati (Deloitte)   ORRUAC-285 - Auto populate LCM and CC on
                                                Transfer request.
 * 1.19   8/17/2020   Chaitanya Nandamuri(Deloitte) OORUAC-1849 Creation of Admission fro Transfer/Influx request. 
*  1.20   9/14/2020 	Vaibhav Kudesia(Deloitte)	ORRUAC-438 - Create Background check records for Sponsor Contact
*  1.21   10/09/2020  Manoj Sharma (Deloitte)	 ORRUAC-2969- CUstom History Tracking
 * 1.22   10/30/2020  Rahul Roy (Deloitte)      ORRUAC-3165  Auto populate Legal fields on UAC Contact
 * 1.22   11/02/2020  Rahul Roy (Deloitte)      ORRUAC-1223  Auto populate Previous Sponsor Applications fields on Adult Contact
**/
// clang-format off
public
without sharing class UAC_caseTriggerHandler implements UAC_ITriggerHandler {
/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassCaseTrigger__c;
  }
  private
  static Boolean runTrigger = true;
  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypes =
      Schema.SObjectType.Case.getRecordTypeInfosById();
  private
  static final String strCaseRecordTypeReleaseRequest = Label.UAC_caseRecordTypeReleaseRequest;
  private
  static final String strCaseRecordTypeSponsorship =
      Label.UAC_caseRecordTypeApiNameSponsorApplication;
  private
  static final String strCaseRecordTypeReferral = Label.UAC_referralRecordTypeName;
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_RR = 'UC_caseRR';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_DNF = 'UC_caseDNF';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_HSPRS = 'UC_caseHsPrs';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_NOC = 'UC_caseNoc';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_REF = 'UC_caseRef';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_SWB = 'UC_caseSwb';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_TR = 'UC_caseTR';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_TRI = 'UC_caseTRInF';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_MHR = 'UC_caseMHR';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_LTFC = 'UC_caseLtfcTrReq';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_RRDNFHSPRS = 'UC_caseRrDnfHsPrs';
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME_ADM = 'UC_admission';
  private
  static final String strCaseRecordTypeDNF = Label.UAC_caseRecordTypeDischargeNotification;
  private
  static final String strCaseRecordTypeHelpdesk = Label.UC_helpdeskTicket;
  private
  static final String strCaseRecordTypeAdmission = Label.UAC_caseRecordTypeAdmission;
  private
  static final String strCaseRecordTypeHSPRS = Label.UAC_caseRecordTypeHSPRSReferral;
  private
  static final String strCaseRecordTypeTransferRequest = Label.UAC_caseTransferRequest;
  private
  static final String strCaseRecordTypeNOC = Label.UAC_caseRecordTypeNOC;
  private
  static final String strCaseRecordTypeSWB = Label.UAC_caseRecordTypeSWB;  
  private
  static final String strCaseNOCStatusSubmitted = Label.UAC_CaseNOCStatusSubmitted;
  private
  static final String strCaseRecordTypeInfluxTransferRequest = Label.UAC_TransferRequestInflux;
  private
  static final String strCaseRecordTypeInfluxTransferManifest = Label.UAC_caseRecordTypeManifest;
  private
  static final String strCaseRecordTypelegacySponsorApplication = 'Legacy_Sponsor_Application' ;  //ORRUAC-3105
  private
  static final String strCaseRecordTypeLtfcTravelRequest =
      Label.UAC_LtfcTravelRequest;  // ORRUAC 2416

  /**
   * @description Method to handle before insert trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param lstNewCases List of new records
   * @return void
   **/
  public
  void beforeInsert(List<Case> lstNewCases) {
    // Instantiate collections for passing to helper methods
    List<Case> lstCaseReleaseRequest = new List<Case>();
    List<Case> lstCaseSponsorship = new List<Case>();
    List<Case> lstCaseDNF = new List<Case>();
    List<Case> lstCaseReferral = new List<Case>();
	List<Case> lstCaseHelpdesk = new List<Case>();
    List<Case> lstCaseAdmission = new List<Case>();
    List<Case> lstCaseHSPRS = new List<Case>();
    List<Case> lstCaseTransferRequest = new List<Case>();
    List<Case> lstCaseinfluxtransferManifest = new List<Case>();//ORRUAC-3105    
    List<Case> lstLtfcTravelRequest = new List<Case>();  // ORRUAC 2416
    Map<Id, Case> mapCaseNOC = new Map<Id, Case>();
    Map<Id, Case> mapCaseInfluxTransferRequest = new Map<Id, case>();

    // Populate collections
    for (Case caseCurrent : lstNewCases) {
      String strRecordTypeDevName = mapRecordTypes.get(caseCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strCaseRecordTypeReleaseRequest) {
        lstCaseReleaseRequest.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeSponsorship) {
        lstCaseSponsorship.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeReferral) {
        lstCaseReferral.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeDNF) {
        lstCaseDNF.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeAdmission) {
        lstCaseAdmission.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeHSPRS) {
        lstCaseHSPRS.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeTransferRequest) {
        lstCaseTransferRequest.add(caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeNOC) {
        mapCaseNOC.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferRequest) {
        mapCaseInfluxTransferRequest.put(caseCurrent.Id, caseCurrent);
      }  else if (strRecordTypeDevName == strCaseRecordTypeLtfcTravelRequest) {  // ORRUAC 2416
        lstLtfcTravelRequest.add(caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferManifest) {  // ORRUAC 3105
        lstCaseinfluxtransferManifest.add(caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeHelpdesk) {
        lstCaseHelpdesk.add(caseCurrent);
      }      
    }
    // Pass to helper methods
    UAC_caseTriggerHelper.populateValuesFromContact(lstNewCases);
    if (!lstCaseHelpdesk.isEmpty()){
      UAC_caseTriggerHelper.updateEscalationFlag(lstCaseHelpdesk,null);
    }
    if (!lstCaseAdmission.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeAdmission,lstCaseAdmission);//Added for ORRUAC-3015      
    }    
    if (!lstCaseReleaseRequest.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeReleaseRequest,lstCaseReleaseRequest);//Added for ORRUAC-3015      
      UAC_caseTriggerHelper.restrictMultiplePendingReleaseRequest(lstCaseReleaseRequest);
      //UAC_caseTriggerHelper.updateCaseOwner(lstCaseReleaseRequest); ORRUAC-4116 Not is used
      UAC_caseTriggerHelper.setStausToORRInitiated(
          lstCaseReleaseRequest);  // ORRUAC-321 Set the status to ORR Initiated
      UAC_caseTriggerHelper.setSponsor(
          lstNewCases, null);  // ORRUAC-309 -  Auto Populate Sponsor related Fields
      UAC_caseTriggerHelper.setProgramFacility(
          lstCaseReleaseRequest);  // ORRUAC-187 Populate Program Facility
      UAC_caseTriggerHelper.setRelReqLegalSection(
          lstCaseReleaseRequest);  // ORRUAC-2091 AC1 - Auto populate Rel Req Legal Section during
                                   // creation
    }
    if(!lstCaseinfluxtransferManifest.isEmpty()){
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeInfluxTransferManifest,lstCaseinfluxtransferManifest);//Added for ORRUAC-3015
    }    
    if (!lstCaseSponsorship.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeSponsorship,lstCaseSponsorship);//Added for ORRUAC-3015
      UAC_caseTriggerHelper.populateFRPDateSentToSponsor(
          lstCaseSponsorship, null);  // ORRUAC-125: Populate FRP Date Sent to Sponsor
      UAC_caseTriggerHelper.checkPreviousApplications(
          lstNewCases);  // ORRUAC-387 - Vaibhav : check for previous Applications
      UAC_caseTriggerHelper.populateAppCompletionDate(
          lstCaseSponsorship, null);  // OORUAC-435 Populate Application Completion Date
    }
    if (!lstCaseReferral.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeReferral,lstCaseReferral);//Added for ORRUAC-3015
      UC_referralService.processReferralsBeforeInsert(lstCaseReferral); // optimized per ORRUAC 5560
    }
    if (!lstCaseDNF.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeDNF,lstCaseDNF);//Added for ORRUAC-3015
      UAC_caseTriggerHelper.restrictMultiplePendingDischarge(lstCaseDNF);
      UAC_caseTriggerHelper.setDNFVal(lstCaseDNF);  // ORRUAC-617 AC1 AC3
    }
    if (!lstCaseHSPRS.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeHSPRS,lstCaseHSPRS);//Added for ORRUAC-3015
      UAC_caseTriggerHelper.preventduplicateHSPRSReferral(lstCaseHSPRS);
      UAC_caseTriggerHelper.setHsPrsSponsor(lstCaseHSPRS);
    }
    if (!lstCaseTransferRequest.isEmpty()) {
      UAC_caseTriggerHelper.setFieldsOnTransferRequestInsert(lstCaseTransferRequest);
      UAC_caseTriggerHelper.duplicateCheckTransferRequest(
          lstCaseTransferRequest);  // ORRUAC-254 Chaitanya Nandamuri
      UAC_caseTriggerHelper.setTransferRequestLCMandCC(lstCaseTransferRequest);  // ORRUAC-285
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeTransferRequest,lstCaseTransferRequest);//Added for ORRUAC-3015   
    }
    if (!mapCaseNOC.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeNOC,mapCaseNOC.values());//Added for ORRUAC-3015
      UAC_caseTriggerHelper.populateNOCVaues(mapCaseNOC, null);
    }
    if (!mapCaseInfluxTransferRequest.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeInfluxTransferRequest,mapCaseInfluxTransferRequest.values());//Added for ORRUAC-3015
      UAC_caseTriggerHelper.setCMAndClinicianLookupsForInflux(
          mapCaseInfluxTransferRequest.values());
      UAC_caseTriggerHelper.setFieldsOnTransferRequestInsert(mapCaseInfluxTransferRequest.values());
      UAC_caseTriggerHelper.populateInfluxTransferVaues(mapCaseInfluxTransferRequest.values());
    }
    if (!lstLtfcTravelRequest.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeLtfcTravelRequest,lstLtfcTravelRequest);//Added for ORRUAC-3015  
      UAC_caseTriggerHelper.processLftcTravelRequestBeforeInsert(
          lstLtfcTravelRequest);  // ORRUAC 2416
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * Modified 07/16/2021 : Exclusion logic check( runExclusions - ORRUAC- 6053 ) added for each Rec Type (RR,DNF,HSPRS,NOC,SWB,Ref,TR,TRI,Ltfc,MHR)
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (!runTrigger) {
      return;
    }
    // Instantiate collections for passing to helper methods
    Map<Id, Case> mapCaseReleaseRequest = new Map<Id, Case>();
    Map<Id, Case> mapCaseSponsorship = new Map<Id, Case>();
    Map<Id, Case> mapCaseDNF = new Map<Id, Case>();
    Map<Id, Case> mapCaseReferral = new Map<Id, Case>();
	Map<Id, Case> mapCaseHelpdesk = new Map<Id, Case>();
    Map<Id, Case> mapCaseAdmission = new Map<Id, Case>();
    Map<Id, Case> mapCaseHSPRS = new Map<Id, Case>();
    Map<Id, Case> mapCaseNOC = new Map<Id, Case>();
    Map<Id, Case> mapCaseSWB = new Map<Id, Case>();
    Map<Id, Case> mapCaseTransferRequest = new Map<Id, Case>();
    Map<Id, Case> mapCaseInfluxTransferRequest = new Map<Id, case>();
    Map<Id, Case> mapCaseinfluxTransferManifest = new Map<Id, case>(); //Added for ORRUAC-3105
    Map<Id, Case> mapCaselegacySponsorApplication  = new Map<Id, case>(); //Added for ORRUAC-3105
    Map<Id, Case> mapCaseLtfcTravelRequest  = new Map<Id, case>(); //Added for ORRUAC-3105
    Map<Id, Case> mapCaseMHR = new Map<Id, Case>();    
    Map<Id, Case> mapCaseNewCasted = (Map<Id, Case>) newItems;
    Map<Id, Case> mapCaseOldCasted = (Map<Id, Case>) oldItems;
    // Populate collections
    for (Case caseCurrent : mapCaseNewCasted.values()) {
      String strRecordTypeDevName = mapRecordTypes.get(caseCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strCaseRecordTypeReleaseRequest) {
        mapCaseReleaseRequest.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeSponsorship) {
        mapCaseSponsorship.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeReferral) {
        mapCaseReferral.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeDNF && !System.isBatch()) {
        mapCaseDNF.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeAdmission) {
        mapCaseAdmission.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeHSPRS) {
        mapCaseHSPRS.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeTransferRequest) {
        mapCaseTransferRequest.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeNOC) {
        mapCaseNOC.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeSWB){
        mapCaseSWB.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferRequest) {
        mapCaseInfluxTransferRequest.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferManifest) {//Added for ORRUAC-3105
        mapCaseinfluxTransferManifest.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypelegacySponsorApplication      ) {//Added for ORRUAC-3105
        mapCaselegacySponsorApplication.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeLtfcTravelRequest) {//Added for ORRUAC-3105
        mapCaseLtfcTravelRequest.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == 'UAC_mentalHealthReferral') { // map population added for MHR exclusion logic per ORRUAC - 6053
        mapCaseMHR.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeHelpdesk) { // map population added for helpdesk
        mapCaseHelpdesk.put(caseCurrent.Id, caseCurrent);
      } 
    }
    // Pass to helper methods
    if(!mapCaseHelpdesk.isEmpty()){
          UAC_caseTriggerHelper.updateEscalationFlag(mapCaseHelpdesk.values(),mapCaseOldCasted);
      }
    if (!mapCaseReleaseRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseReleaseRequest,mapCaseReleaseRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_RR)) {
     // UAC_caseTriggerHelper.updateCaseOwnerOnUpdate(mapCaseReleaseRequest, oldItems);ORRUAC-4116 Not is used
      UAC_caseTriggerHelper.updateCMCCRecommendationDate(mapCaseReleaseRequest, oldItems);
      UAC_caseTriggerHelper.setSponsor(mapCaseReleaseRequest.values(),
          mapCaseOldCasted);  // ORRUAC-309 -  Auto Populate Sponsor related Fields
      UAC_caseTriggerHelper.setDateOnORRDecisionSubmission(mapCaseReleaseRequest, oldItems);
      UAC_caseTriggerHelper.updateDocCfsFfs(mapCaseReleaseRequest,
          mapCaseOldCasted);  // ORRUAC-1099 Auto Populate DOC CFS & FFS
      UAC_caseTriggerHelper.changesToReleaseRequest(
          mapCaseReleaseRequest, oldItems);  // ORRUAC-187 Changes on Release Request
      UAC_caseTriggerHelper.updateStatusDNFGenerated(mapCaseReleaseRequest,
          mapCaseOldCasted);  // ORRUAC-403-1301 Changes on Release Request
      UAC_caseTriggerHelper.updatePendingInfoAndRemandInfoToNull(mapCaseReleaseRequest,
          mapCaseOldCasted);  // ORRUAC-187 Changes on Release Request    
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeReleaseRequest,mapCaseReleaseRequest, mapCaseOldCasted);//Added for ORRUAC-3105                   
    }
    if (!mapCaseSponsorship.isEmpty()) {
      UAC_caseTriggerHelper.populateFRPDateSentToSponsor(mapCaseSponsorship.values(),
          mapCaseOldCasted);  // ORRUAC-125: Populate FRP Date Sent to Sponsor
      UAC_caseTriggerHelper.populateAppCompletionDate(mapCaseSponsorship.values(),
          mapCaseOldCasted);  // OORUAC-435 Populate Application Completion Date
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeSponsorship,mapCaseSponsorship, mapCaseOldCasted);//Added for ORRUAC-3105          
    }
    if (!mapCaseReferral.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseReferral, mapCaseReferral.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_REF)) {
      UC_referralService.processReferralsBeforeUpdate(mapCaseReferral, mapCaseOldCasted); // optimized per ORRUAC 5560
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeReferral,mapCaseReferral, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaseDNF.isEmpty() && !System.isBatch() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseDNF, mapCaseDNF.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_DNF)) {
      UAC_caseTriggerHelper.saveDNFVal(mapCaseDNF, mapCaseOldCasted);  // ORRUAC-617 AC1
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeDNF,mapCaseDNF, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaseAdmission.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseAdmission, mapCaseAdmission.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_ADM)) {
      UAC_caseTriggerHelper.processAdmissionsOnUpdate(mapCaseAdmission, mapCaseOldCasted);
      UAC_caseTriggerHelper.setCaseAdmittedDate(mapCaseAdmission, mapCaseOldCasted);  // ORRUAC-206
      UAC_caseTriggerHelper.updateAdmitted(mapCaseReleaseRequest,
          mapCaseOldCasted);  // ORRUAC-2563 Changes on Release Request    
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeAdmission,mapCaseAdmission, mapCaseOldCasted);//Added for ORRUAC-3105      
    }
    if (!mapCaseHSPRS.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseHSPRS, mapCaseHSPRS.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_HSPRS)) {
      UAC_caseTriggerHelper.updateOwnertoQueueHS(mapCaseHSPRS,
          mapCaseOldCasted);  // ORRUAC-872- Update the Case Owner to Queue
      UAC_caseTriggerHelper.statusUpdatesHSPRSReferral(mapCaseHSPRS,
          mapCaseOldCasted);  // ORRUAC-869- Updates to HSPRS Referral Case Status
      UAC_caseTriggerHelper.HSPRSReferralAccepted(mapCaseHSPRS,
          mapCaseOldCasted);  // ORRUAC-2564- Updates to HSPRS Referral Case Status
          if(!System.isBatch()){// 4590  AC-2 bypass this if triggered by batch
            UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeHSPRS,mapCaseHSPRS, mapCaseOldCasted);//Added for ORRUAC-3105
          }
    }
    if (!mapCaseTransferRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseTransferRequest,mapCaseTransferRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_TR)) {
      UAC_caseTriggerHelper.updateTransferRequestFields(mapCaseTransferRequest, mapCaseOldCasted);
      UAC_caseTriggerHelper.updateTransferCompleted(mapCaseReleaseRequest,
          mapCaseOldCasted);  // ORRUAC-2563 Changes on Release Request  
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeTransferRequest,mapCaseTransferRequest, mapCaseOldCasted);//Added for ORRUAC-3105
      UAC_caseTriggerHelper.updtTREntryTeam(mapCaseTransferRequest,mapCaseOldCasted);  // ORRUAC-6531 AC-2
    }
    if (!mapCaseNOC.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseNOC, mapCaseNOC.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_NOC)) {
      UAC_caseTriggerHelper.populateNOCVaues(mapCaseNOC, mapCaseOldCasted);
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeNOC,mapCaseNOC, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaseSWB.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseSWB, mapCaseSWB.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_SWB)) {
      UAC_caseTriggerHelper.populateSWB(mapCaseSWB, mapCaseOldCasted);
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeSWB,mapCaseSWB, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaseInfluxTransferRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseInfluxTransferRequest,mapCaseInfluxTransferRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_TRI)) {
      UAC_caseTriggerHelper.updateTransferRequestFields(
          mapCaseInfluxTransferRequest, mapCaseOldCasted);  // ORRUAC-1849
      UAC_caseTriggerHelper.preventStatusRemovedForInfluxTransfer(
          mapCaseInfluxTransferRequest, mapCaseOldCasted);
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeInfluxTransferRequest,mapCaseInfluxTransferRequest, mapCaseOldCasted);//Added for ORRUAC-3105   
    }
    if (!mapCaseinfluxTransferManifest.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeInfluxTransferManifest,mapCaseinfluxTransferManifest, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaselegacySponsorApplication.isEmpty()) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypelegacySponsorApplication,mapCaselegacySponsorApplication, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaseLtfcTravelRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseLtfcTravelRequest,mapCaseLtfcTravelRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_LTFC)) {
      UAC_caseTriggerHelper.CheckValidations('case',strCaseRecordTypeLtfcTravelRequest,mapCaseLtfcTravelRequest, mapCaseOldCasted);//Added for ORRUAC-3105
    }
    if (!mapCaseMHR.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseMHR, mapCaseMHR.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_MHR)){
    }    
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param oldItems Map of old records
   * Modified 07/16/2021 : Exclusion logic check( runExclusions - ORRUAC- 6053 ) added for each Rec Type (RR,DNF,HSPRS,NOC,SWB,Ref,TR,TRI,Ltfc,MHR)
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    Map<Id, Case> MapCaseNOC = New Map<Id, Case>();
    map<id, case> mapCaseLtfcTravelRequest = new Map<id, Case>();
    Map<Id, Case> mapCaseSWB = new Map<Id, Case>();
    Map<Id, Case> mapCaseTransferRequest = new Map<Id, Case>();
    Map<Id, Case> mapCaseInfluxTransferRequest = new Map<Id, case>();
    Map<Id, Case> mapCaseMHR = new Map<Id, Case>();
    Map<Id, Case> mapCaseAdmission = new Map<Id, Case>(); 
    Map<Id, Case> mapCaseReleaseRequestDNF = new Map<Id, Case>();
    Map<Id, Case> mapCaseReferral = new Map<Id, Case>();      
    Map<Id, Case> mapCaseOldCasted = (Map<Id, Case>) oldItems;
    List<Case> lstCaseNOC = New List<Case>();
    for (Case caseCurrent : mapCaseOldCasted.values()) {
      String strRecordTypeDevName = mapRecordTypes.get(caseCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strCaseRecordTypeNOC) {
        MapCaseNOC.put(caseCurrent.Id, caseCurrent);
        if (strCaseNOCStatusSubmitted == caseCurrent.Status) {
          lstCaseNOC.add(caseCurrent);
        }
      }
      if (strRecordTypeDevName == strCaseRecordTypeReleaseRequest || strRecordTypeDevName == strCaseRecordTypeDNF || strRecordTypeDevName == strCaseRecordTypeHSPRS) { 
        mapCaseReleaseRequestDNF.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeReferral) {
        mapCaseReferral.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeLtfcTravelRequest) {  // map population added for Ltfc exclusion logic per ORRUAC - 6053
        mapCaseLtfcTravelRequest.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeTransferRequest) { // map population added for TR exclusion logic per ORRUAC - 6053
        mapCaseTransferRequest.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeSWB) { // map population added for SWB exclusion logic per ORRUAC - 6053
        mapCaseSWB.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferRequest ) { // map population added for TRI exclusion logic per ORRUAC - 6053
        mapCaseInfluxTransferRequest.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == 'UAC_mentalHealthReferral') { // map population added for MHR exclusion logic per ORRUAC - 6053
        mapCaseMHR.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeAdmission) {// added per exclusion logic  for admission ORRUAC - 6053
        mapCaseAdmission.put(caseCurrent.Id, caseCurrent);
      }      
    }
    if (!MapCaseNOC.isEmpty() && !lstCaseNOC.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(MapCaseNOC,MapCaseNOC.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_NOC)) {
      UAC_caseTriggerHelper.CheckCaseNOCDelete(MapCaseNOC, lstCaseNOC);
    }
    // Start -- exclusion logic check added for NOC,RR,DNF,HSPRS,SWB,TR,TRI,MHR,REF,LTFC per ORRUAC - 6053
    if (!mapCaseLtfcTravelRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseLtfcTravelRequest,mapCaseLtfcTravelRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_LTFC)) {
    }
	  if (!mapCaseReleaseRequestDNF.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseReleaseRequestDNF,mapCaseReleaseRequestDNF.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_RRDNFHSPRS)) {
    }
    if (!mapCaseSWB.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseSWB, mapCaseSWB.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_SWB)){
    }
    if (!mapCaseTransferRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseTransferRequest,mapCaseTransferRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_TR)){
    }
    if (!mapCaseInfluxTransferRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseInfluxTransferRequest,mapCaseInfluxTransferRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_TRI)){
    }
    if (!mapCaseMHR.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseMHR, mapCaseMHR.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_MHR)){
    }
    if (!mapCaseReferral.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseReferral, mapCaseReferral.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_REF)) {
    }
    if (!mapCaseAdmission.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseAdmission, mapCaseAdmission.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_ADM)) {
    }    
    // End -- exclusion logic check added for NOC,RR,DNF,HSPRS,SWB,TR,TRI,MHR,REF,LTFC per 6053       
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param newItems Map of new records
   * Modified 07/16/2021 : Exclusion logic check( runExclusions - ORRUAC- 6053 ) added for each Rec Type (RR,DNF,HSPRS,NOC,SWB,Ref,TR,TRI,Ltfc,MHR)
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    Map<Id, Case> mapCaseReleaseRequestDNF = new Map<Id, Case>();
    Map<Id, Case> mapCaseSponsorship = new Map<Id, Case>();
    Map<Id, Case> mapCaseReferral = new Map<Id, Case>();
    Map<Id, Case> mapCaseManifest = new Map<Id, Case>();
    Map<Id, Case> mapCaseNewCasted = (Map<Id, Case>) newItems;
    Set<Id> setActiveSponsorCaseContactIds = new Set<Id>();
    Set<Id> setConcurrentSponsorApplications = new Set<Id>();
    List<Case> lstCaseNOC = New List<Case>();            // Manoj: ORRUAC-1549
    List<Case> lstCaseNOCEmailToDCS = New List<Case>();  // Manoj: ORRUAC-1549
    List<Case> lstCaseNocAll = New List<Case>();
    map<id, case> mapCaseLtfcTravelRequest = new Map<id, Case>();  // ORRUAC 2416
    Map<Id, Case> mapCaseNOC = new Map<Id, Case>();
    Map<Id, Case> mapCaseSWB = new Map<Id, Case>();
    Map<Id, Case> mapCaseTransferRequest = new Map<Id, Case>();
    Map<Id, Case> mapCaseInfluxTransferRequest = new Map<Id, case>();
    Map<Id, Case> mapCaseMHR = new Map<Id, Case>();
    Map<Id, Case> mapCaseAdmission = new Map<Id, Case>();
    // Populate collections
    for (Case caseCurrent : mapCaseNewCasted.values()) {
      String strRecordTypeDevName = mapRecordTypes.get(caseCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strCaseRecordTypeReleaseRequest
         || strRecordTypeDevName == strCaseRecordTypeDNF || strRecordTypeDevName == strCaseRecordTypeHSPRS) { // added || strRecordTypeDevName == strCaseRecordTypeHSPRS for ORRUAC-3577
			mapCaseReleaseRequestDNF.put(caseCurrent.Id, caseCurrent);
      } 
      else if (strRecordTypeDevName == strCaseRecordTypeSponsorship) {
        mapCaseSponsorship.put(caseCurrent.Id, caseCurrent);
        setConcurrentSponsorApplications.add(caseCurrent.UAC_sponsor__c);
        if (UAC_caseTriggerHelper.isActiveSponsorApplication(caseCurrent)
            && caseCurrent.UAC_sponsor__c != null) {
          setActiveSponsorCaseContactIds.add(caseCurrent.UAC_sponsor__c);
        }
      } 
      else if (strRecordTypeDevName == strCaseRecordTypeReferral) {
        mapCaseReferral.put(caseCurrent.Id, caseCurrent);
      } 
      else if (strRecordTypeDevName == strCaseRecordTypeNOC) {
        mapCaseNOC.put(caseCurrent.Id, caseCurrent); // map added for exclusion logic for NOC per ORRUAC - 6053
        lstCaseNocAll.add(caseCurrent);
        if (caseCurrent.UAC_notifyPSATeam__c == Label.UAC_Yes) {
          lstCaseNOC.add(caseCurrent);
        }
        if (caseCurrent.UAC_notificationOfConcernCategory__c
            == Label.UAC_abuseofUACwhileinFederalCustody) {
          lstCaseNOCEmailToDCS.add(caseCurrent);
        }
      } 
      else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferManifest) {
        mapCaseManifest.put(caseCurrent.Id, caseCurrent);
      } 
      else if (strRecordTypeDevName == strCaseRecordTypeLtfcTravelRequest) {  // ORRUAC - 2416
        mapCaseLtfcTravelRequest.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeTransferRequest) { // map population added for TR exclusion logic per ORRUAC - 6053
        mapCaseTransferRequest.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeSWB) { // map population added for SWB exclusion logic per ORRUAC - 6053
        mapCaseSWB.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferRequest ) { // map population added for TRI exclusion logic per ORRUAC - 6053
        mapCaseInfluxTransferRequest.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == 'UAC_mentalHealthReferral') { // map population added for TRI exclusion logic per ORRUAC - 6053
        mapCaseMHR.put(caseCurrent.Id, caseCurrent);
      }
      else if (strRecordTypeDevName == strCaseRecordTypeAdmission) {// added per exclusion logic  for admission ORRUAC - 6053
        mapCaseAdmission.put(caseCurrent.Id, caseCurrent);
      }      
    }
    if (!mapCaseSponsorship.isEmpty()) {
      if (!setActiveSponsorCaseContactIds.isEmpty()) {
        UAC_caseTriggerHelper.updateContactActiveSponsorApplication(setActiveSponsorCaseContactIds);
      }
      // ORRUAC-438 - Create Background check records for Sponsor Contact
      UAC_caseTriggerHelper.createCaseSponsorBackgroundChecks(mapCaseSponsorship.keyset());
      //Call helper method to check if sponsor has concurrent applications
      if(!setConcurrentSponsorApplications.isEmpty()){
        UC_referralService.updateConcurrentSponsorApplications(setConcurrentSponsorApplications);
     }
    }
    runTrigger = false;
    if (!mapCaseReferral.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseReferral, mapCaseReferral.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_REF)) {
      UC_referralService.processReferralsAfterInsert(mapCaseReferral);
    }
    
    runTrigger = true;
    if (!lstCaseNOC.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseNOC, mapCaseNOC.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_NOC)) {
      UAC_caseTriggerHelper.NOCAlertPSATeam(lstCaseNOC);  // ORRUAC-1549
    }
    //if (!lstCaseNOCEmailToDCS.isEmpty()) {
      // UAC_caseTriggerHelper.NOCEmailToDCS(lstCaseNOCEmailToDCS);  // ORRUAC-1549
    //}
    if (!lstCaseNocAll.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseNOC, mapCaseNOC.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_NOC)) {
      UAC_caseTriggerHelper.NOCEmailToHsPrsProv(lstCaseNocAll);  // ORRUAC-2428
      UAC_caseTriggerHelper.NOCEmailToACFPrgDir(lstCaseNocAll);  // ORRUAC-2428
      UAC_caseTriggerHelper.storeNOCHistoyTrackingInsert(lstCaseNocAll);  // ORRUAC-2969
      UAC_caseTriggerHelper.addNOCCaseShare(lstCaseNocAll);  // ORRUAC-4954
    }
    if (!mapCaseManifest.isEmpty()) {
      UAC_caseTriggerHelper.setCaseTeamMembersOnManifests(mapCaseManifest);
    }
    // Start -- exclusion logic check added for NOC,RR,DNF,HSPRS,SWB,TR,TRI,MHR,REF,LTFC per ORRUAC - 6053
    if (!mapCaseLtfcTravelRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseLtfcTravelRequest,mapCaseLtfcTravelRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_LTFC)) {  // ORRUAC 2416
      UAC_caseTriggerHelper.processLftcTravelRequestAfterInsert(mapCaseLtfcTravelRequest);
    }
	if (!mapCaseReleaseRequestDNF.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseReleaseRequestDNF,mapCaseReleaseRequestDNF.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_RRDNFHSPRS)) {
      UAC_caseTriggerHelper.updateCaseTeam(mapCaseReleaseRequestDNF, null);
    }
    if (!mapCaseSWB.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseSWB, mapCaseSWB.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_SWB)){
    }
    if (!mapCaseTransferRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseTransferRequest,mapCaseTransferRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_TR)){
      UAC_caseTriggerHelper.insrtTREntryTeam(mapCaseTransferRequest);  //ORRUAC - 6531 AC-1
    }
    if (!mapCaseInfluxTransferRequest.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseInfluxTransferRequest,mapCaseInfluxTransferRequest.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME_TRI)){
    }
    if (!mapCaseMHR.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseMHR, mapCaseMHR.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_MHR)){
    }
    if (!mapCaseAdmission.isEmpty() && UC_exclusionLogicService.getInstance().runExclusions(mapCaseAdmission, mapCaseAdmission.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME_ADM)){
    }    
    // End -- exclusion logic check added for NOC,RR,DNF,HSPRS,SWB,TR,TRI,MHR,REF,LTFC per 6053    
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (!runTrigger) {
      return;
    }
    // Instantiate collections for passing to helper methods
	Map<Id, Case> mapCaseNOCHistoryTracking = new Map<Id, Case>(); //ORRUAC-2969
    Map<Id, Case> mapCaseReleaseRequest = new Map<Id, Case>();
    Map<Id, Case> mapCaseSponsorship = new Map<Id, Case>();
    Map<Id, Case> mapCaseDNF = new Map<Id, Case>();
    Map<Id, Case> mapCaseReleaseRequestDNF = new Map<Id, Case>();
    Map<Id, Case> mapCaseReferral = new Map<Id, Case>();
    Map<Id, Case> mapCaseAdmission = new Map<Id, Case>();
    Map<Id, Case> mapCaseHSPRS = new Map<Id, Case>();
    Map<Id, case> mapCaseTransferRequest = new Map<Id, Case>();  // ORRUAC-2020
    Map<Id, case> mapCaseInfluxTransferRequest = new Map<Id, Case>();
    Map<Id, Case> mapCaseNOC = new Map<Id, Case>();
    Map<Id, Case> mapCaseNewCasted = (Map<Id, Case>) newItems;
    Map<Id, Case> mapCaseOldCasted = (Map<Id, Case>) oldItems;
    Set<Id> setActiveSponsorCaseContactIds = new Set<Id>();
    Set<Id> setConcurrentSponsorApplications = new Set<Id>();
    List<Case> lstCaseNOC = New List<Case>();            // Manoj: ORRUAC-1549
    List<Case> lstCaseNOCEmailToDCS = New List<Case>();  // Manoj: ORRUAC-1549
    List<Case> lstOfCaseTransferRequest = new List<Case>();
	List<Case> lstCaseNocAll = New List<Case>();
    // Populate collections
    for (Case caseCurrent : mapCaseNewCasted.values()) {
      String strRecordTypeDevName = mapRecordTypes.get(caseCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strCaseRecordTypeReleaseRequest) {
        mapCaseReleaseRequest.put(caseCurrent.Id, caseCurrent);
        mapCaseReleaseRequestDNF.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeSponsorship) {
        mapCaseSponsorship.put(caseCurrent.Id, caseCurrent);
        Case objOldCase = mapCaseOldCasted.get(caseCurrent.Id);
        // ORRUAC-362: Check if Contact Active sponsor application flag should be updated
        // Changes to active sponsor application criteria and sponsor should trigger flag update
        if ((UAC_caseTriggerHelper.isActiveSponsorApplication(caseCurrent)
                && !UAC_caseTriggerHelper.isActiveSponsorApplication(objOldCase))
            || (!UAC_caseTriggerHelper.isActiveSponsorApplication(caseCurrent)
                && UAC_caseTriggerHelper.isActiveSponsorApplication(objOldCase))
            || (caseCurrent.UAC_sponsor__c != objOldCase.UAC_sponsor__c)) {
          // Add new Case Sponsor to update set if exists.
          if (caseCurrent.UAC_sponsor__c != null) {
            setActiveSponsorCaseContactIds.add(caseCurrent.UAC_sponsor__c);
          }
          // Add old Case sponsor to update set if exists to handle cases of Sponsor change.
          if (objOldCase.UAC_sponsor__c != null) {
            setActiveSponsorCaseContactIds.add(objOldCase.UAC_sponsor__c);
          }
          if(caseCurrent.status != objOldCase.status){
          	setConcurrentSponsorApplications.add(caseCurrent.UAC_sponsor__c);
          }
        }
      } else if (strRecordTypeDevName == strCaseRecordTypeReferral) {
        mapCaseReferral.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeDNF && !System.isBatch()) {
        mapCaseDNF.put(caseCurrent.Id, caseCurrent);
        mapCaseReleaseRequestDNF.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeAdmission) {
        mapCaseAdmission.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeTransferRequest) {
        mapCaseTransferRequest.put(caseCurrent.Id, caseCurrent);  // ORRUAC-2020
      } else if (strRecordTypeDevName == strCaseRecordTypeHSPRS) {
        mapCaseHSPRS.put(caseCurrent.Id, caseCurrent);
      } else if (strRecordTypeDevName == strCaseRecordTypeNOC) {
        Case objOldCase = mapCaseOldCasted.get(caseCurrent.Id);
        mapCaseNOC.put(caseCurrent.Id, caseCurrent);
        if (objOldCase.UAC_notifyPSATeam__c != caseCurrent.UAC_notifyPSATeam__c
            && caseCurrent.UAC_notifyPSATeam__c == Label.UAC_Yes) {
          lstCaseNOC.add(caseCurrent);
        }
        
        if (objOldCase.UAC_notificationOfConcernCategory__c != caseCurrent.UAC_notificationOfConcernCategory__c
            && caseCurrent.UAC_notificationOfConcernCategory__c == Label.UAC_abuseofUACwhileinFederalCustody) {
          lstCaseNOCEmailToDCS.add(caseCurrent);
        }
		// Below Code add by Manoj  : ORRUAC-2778
        if ((caseCurrent.UAC_notificationOfConcernCategory__c == Label.UAC_notifOfConcAbuseNeg || caseCurrent.UAC_notificationOfConcernCategory__c == Label.UAC_notifOfConcDeathOfUAC) 
            && objOldCase.status != caseCurrent.status && caseCurrent.status == Label.UAC_CaseNOCStatusSubmitted && caseCurrent.UAC_eventOccurredInORRCare__c == Label.UAC_Yes) {
          lstCaseNocAll.add(caseCurrent);
        } //  Code end by Manoj  : ORRUAC-2778
		mapCaseNOCHistoryTracking.put(caseCurrent.Id, caseCurrent);//ORRUAC-2969
      } else if (strRecordTypeDevName == strCaseRecordTypeInfluxTransferRequest) {
        mapCaseInfluxTransferRequest.put(caseCurrent.Id, caseCurrent);
      }
    }
    if (!mapCaseReleaseRequest.isEmpty()) {
      UAC_caseTriggerHelper.createDNF(
          mapCaseReleaseRequest, mapCaseOldCasted);  // Added by Manoj for ORRUAC-405
                                                     // Added by ankur for ORRUAC-320 & 398 starts
      UAC_caseTriggerHelper.ReleaseRequestTaskCreation(mapCaseReleaseRequest, oldItems);
      UAC_caseTriggerHelper.createHSPRSReferral(
          mapCaseReleaseRequest, mapCaseOldCasted);  // ORRUAC-866
      UAC_caseTriggerHelper.ReleaseRequestAlertMedicalStaff(
          mapCaseReleaseRequest, oldItems);  // ORRUAC-1261 AC4
      UAC_caseTriggerHelper.updateORRDecisionOnSponsorApplication(
          mapCaseReleaseRequest, mapCaseOldCasted);  // ORRUAC-1935
    }
    // ORRUAC-2020
    if (!mapCaseTransferRequest.isEmpty()) {
      UAC_caseTriggerHelper.processCasesForBedUpdate(
          mapCaseTransferRequest.values(), mapCaseOldCasted);
      UAC_caseTriggerHelper.createDNFFmTReq(mapCaseTransferRequest, mapCaseOldCasted);
      UAC_caseTriggerHelper.checkTransferRequestsForParentUACStatusUpdate(
          mapCaseTransferRequest, mapCaseOldCasted);
    }
    if (!mapCaseDNF.isEmpty() && !System.isBatch()) {
      UAC_caseTriggerHelper.DNFTaskCreation(
          mapCaseDNF, mapCaseOldCasted);  // ORRUAC-617 AC-11 - Piyush
      UAC_caseTriggerHelper.setDischargeDateOnAdmission(
          mapCaseDNF, mapCaseOldCasted);  // ORRUAC-1561 AC-8 - Ankur
      UAC_caseTriggerHelper.processCasesForBedUpdate(mapCaseDNF.values(), mapCaseOldCasted);
      UAC_caseTriggerHelper.updateContactProgramDNF(mapCaseDNF, mapCaseOldCasted);  // ORRUAC-2020
    }
    if (!mapCaseSponsorship.isEmpty()) {
      // Prepare set of Contact Ids to update Active Sponsor Application checkbox
      if (!setActiveSponsorCaseContactIds.isEmpty()) {
        UAC_caseTriggerHelper.updateContactActiveSponsorApplication(setActiveSponsorCaseContactIds);
      }
      // ORRUAC-436: Vaibhav - Update Adult contact Relationship to previous sponsor when Sponsor
      // Application is closed as Sponsor withdrew and prevent further changes to Case.
      UAC_caseTriggerHelper.upsdatesponsorrelation(mapCaseSponsorship, oldItems);
      UAC_caseTriggerHelper.populateFieldOnAdultContact(mapCaseSponsorship, mapCaseOldCasted);//1223

      //Call helper method to check if sponsor has concurrent applications
      if(!setConcurrentSponsorApplications.isEmpty()){
        UC_referralService.updateConcurrentSponsorApplications(setConcurrentSponsorApplications);
     }
    }
    if (!mapCaseReleaseRequestDNF.isEmpty()) {
      UAC_caseTriggerHelper.updateCaseTeam(mapCaseReleaseRequestDNF, mapCaseOldCasted);
    }
    if (!mapCaseHSPRS.isEmpty()) {
      UAC_caseTriggerHelper.markRRHSComplete(mapCaseHSPRS, mapCaseOldCasted);  // ORRUAC-866
      UAC_caseTriggerHelper.createTaskForPRS(mapCaseHSPRS, mapCaseOldCasted);  // ORRUAC-1547
	  UAC_caseTriggerHelper.updateCaseTeam(mapCaseHSPRS, mapCaseOldCasted); //ORRUAC-3577
    }
    if (!mapCaseAdmission.isEmpty()) {
      UAC_caseTriggerHelper.setContactAdmittedDate(
          mapCaseAdmission, mapCaseOldCasted);  // ORRUAC-206
      UAC_caseTriggerHelper.updateContactProgramAdmittedCase(
        mapCaseAdmission, mapCaseOldCasted);
      UAC_caseTriggerHelper.checkAdmissionCasesForParentUACStatusUpdate(
          mapCaseAdmission, mapCaseOldCasted);
      UAC_caseTriggerHelper.processCasesForBedUpdate(mapCaseAdmission.values(), mapCaseOldCasted);
    }
    if (!mapCaseReferral.isEmpty()) {
      UC_referralService.processReferralsAfterUpdate(mapCaseReferral, mapCaseOldCasted); // optimized per ORRUAC 5560
    }
    if (!lstCaseNOC.isEmpty()) {
      UAC_caseTriggerHelper.NOCAlertPSATeam(lstCaseNOC);  // ORRUAC-1549
    }
    //if (!lstCaseNOCEmailToDCS.isEmpty()) {
      // UAC_caseTriggerHelper.NOCEmailToDCS(lstCaseNOCEmailToDCS);  // ORRUAC-1549
    //}
    if (!mapCaseInfluxTransferRequest.isEmpty()) {
      UAC_caseTriggerHelper.processCasesForBedUpdate(
          mapCaseInfluxTransferRequest.values(), mapCaseOldCasted);
      UAC_caseTriggerHelper.createDNFFmTReq(mapCaseInfluxTransferRequest, mapCaseOldCasted);
    }
	if (!lstCaseNocAll.isEmpty()) {
      UAC_caseTriggerHelper.NOCEmailToACFPrgDir(lstCaseNocAll);  // manoj :ORRUAC-2778
    }
	 if(!mapCaseNOCHistoryTracking.isEmpty()) {
      UAC_caseTriggerHelper.storeNOCHistoyTrackingUpdate(mapCaseNOCHistoryTracking, mapCaseOldCasted); // manoj :ORRUAC-2969
    }
    if (!mapCaseNOC.isEmpty()) {
      UAC_caseTriggerHelper.addNOCCaseShareOnUpdate(mapCaseNOC, mapCaseOldCasted);
      UAC_caseTriggerHelper.deleteNOCCaseShareOnUpdate(mapCaseNOC, mapCaseOldCasted);
    }
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
    Map<Id, Case> mapCaseOldCasted = (Map<Id, Case>) oldItems;
    Set<Id> setConcurrentSponsorApplications = new Set<Id>();
    // Populate collections
    for (Case caseCurrent : mapCaseOldCasted.values()) {
      String strRecordTypeDevName = mapRecordTypes.get(caseCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strCaseRecordTypeSponsorship) {
      setConcurrentSponsorApplications.add(caseCurrent.UAC_sponsor__c);
      }
 
    }
        
    if(!setConcurrentSponsorApplications.isEmpty()){
         UC_referralService.updateConcurrentSponsorApplications(setConcurrentSponsorApplications);
      }
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Issam Awwad (Deloitte) | 5/11/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}