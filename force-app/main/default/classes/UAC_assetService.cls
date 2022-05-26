/**
 * @File Name          : UAC_assetService.cls
 * @Description        : Utility class for asset/bed updates
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_assetService
 * @Last Modified By   : James Qian (Deloitte)
 * @Last Modified On   : 3/17/2021
 * @Modification Log   :
 * Ver       Date            Author      		            Modification
 * 1.0     3/17/2021         James Qian (Deloitte)      Initial Version
 **/
public
without sharing class UAC_assetService {
  public
  Map<String, Schema.RecordTypeInfo> mapRecordTypesByDeveloperName;
  private
  static final String strCaseRecordTypeDischargeNotification =
      Label.UAC_caseRecordTypeDischargeNotification;
  private
  static final string strcaseRecordTypeAdmission = Label.UAC_caseRecordTypeAdmission;
  private
  static final String strCaseRecordTypeTransferRequest = Label.UAC_caseTransferRequest;
  private
  static final String strPlacementDesignatedStatus = Label.UAC_placementDesignatedContactStatus;
  private
  static final String strPlacementRequestedStatus = Label.UAC_placementRequestedContactStatus;
  private
  static final String strPlacementNotAcceptedStatus = Label.UAC_placementNotAcceptedContactStatus;
  private
  static final String strCaseStatusDischargeCompleted = Label.UAC_caseStatusDischargeCompleted;
  private
  static final String strReleaseRequestStatusFFSReview = Label.UAC_ReleaseRequestStatusFFSReview;
  private
  static final String strTransferApprovedORR = Label.UAC_orrDecisionTransferApproved;
  private
  static final String strTransferNotApprovedORR = Label.UAC_transferNotApprovedORRDecision;
  private
  static final String strTransferRemandedORR = Label.UAC_transferRemandedORRDecision;
  private
  static final String strAdmittedStatus = Label.UAC_admittedContactStatus;
  private
  static final String strAccepted = 'Accepted';
  private
  static final String strBedStatusAvailable = 'Available';
  private
  static final String strBedStatusOnHold = 'On-Hold';
  private
  static final String strBedStatusOccupied = 'Occupied';
  private
  static final String STR_ERR_REQ_FIELD = 'Error: Missing required field for selecting a bed.';
  private
  static final String STR_ERR_NO_BEDS =
      'Error: This Program doesn\'t have enough beds for this child\'s gender and age.';
  private
  static final String STR_ERR_CAUGHT = 'Error while updating beds: ';
  private
  Set<String> setOfSearchKeys = new Set<String>();
  private
  Set<Id> setOfContactIds = new Set<Id>();
  private
  Set<Id> setOfProgramsForAssignedBedUpdates = new Set<Id>();
  private
  Map<Id, AssetUpdateWrapper> mapAssetUpdateWrapper = new Map<Id, AssetUpdateWrapper>();
  private
  Map<String, List<Asset>> mapSearchKeyToAssets = new Map<String, List<Asset>>();
  private
  Map<Id, Asset> mapContactIdToAsset = new Map<Id, Asset>();

  /*
   * @description Main method for updating assets for referral scenarios
   * @author James Qian (Deloitte) | 3/17/2021
   * @param List<Case> listReferralsToProcess
   * @param Map<Id, Case> mapOldCase
   * @return
   **/
  public
  void handleReferralAssetUpdates(List<Case> listReferralsToProcess, Map<Id, Case> mapOldCase) {
    instantiateCollections();
    if (listReferralsToProcess.isEmpty()) {
      return;
    }

    // Loop through referrals and add to collections
    for (Case objCase : listReferralsToProcess) {
      if (!validateReferralFields(objCase)) {
        objCase.addError(STR_ERR_REQ_FIELD);
        continue;
      }
      setQueryParamsForReferral(objCase, mapOldCase.get(objCase.Id));
    }
    if (mapAssetUpdateWrapper.isEmpty()) {
      return;
    }

    // Query assets that meet criteria and store in maps
    queryAndStoreAssets();

    // Update assets as needed
    updateAssets(listReferralsToProcess);
  }

  /*
   * @description Main method for updating assets for non-referral scenarios like transfer and
   * discharge
   * @author James Qian (Deloitte) | 3/17/2021
   * @param List<Case> lstOfCasesToProcess
   * @param Map<Id, Case> mapOldCase
   * @return
   **/
  public
  void handleAssetUpdates(List<Case> lstOfCasesToProcess, Map<Id, Case> mapOldCase) {
    instantiateCollections();
    if (lstOfCasesToProcess.isEmpty()) {
      return;
    }
    for (Case objCase : lstOfCasesToProcess) {
      Case objOld = mapOldCase.get(objCase.id);
      if (!validateCaseFields(objCase) && objCase.UAC_techSwbGenerated__c == objOld.UAC_techSwbGenerated__c) {        
          objCase.addError(STR_ERR_REQ_FIELD);
          continue;
      }
      setQueryParamsForCase(objCase, mapOldCase.get(objCase.Id));
    }
    if (mapAssetUpdateWrapper.isEmpty()) {
      return;
    }

    // Query assets that meet criteria and store in maps
    queryAndStoreAssets();

    // Update assets as needed
    updateAssets(lstOfCasesToProcess);
  }

  /*
   * @description Sets instruction wrapper for future methods for each referral
   * @author James Qian (Deloitte) | 3/17/2021
   * @param Case objCase
   * @param Case oldCase
   * @return
   **/
  private
  void setQueryParamsForReferral(Case objCase, Case oldCase) {

    // Create a new wrapper
    AssetUpdateWrapper objWrapper = new AssetUpdateWrapper();
    String strGender = String.isBlank(objCase.UC_bedTypeOverride__c)
        ? objCase.UAC_gender__c
        : objCase.UC_bedTypeOverride__c;
    // clang-format off
    String searchKey = String.valueOf(objCase.UAC_programFacility__c) + '.' + strGender + '.'
                + String.valueOf(Integer.valueOf(objCase.UAC_age__c) <= 12 ? 'Tender Age' : 'Teen') + '.';
    // clang-format on

    // Based on status and placement request set values on the wrapper for future logic
    if (objCase.Status == strPlacementDesignatedStatus) {
      objWrapper.strFutureStatus = strBedStatusOccupied;
      if (objCase.UAC_requiresPlacementRequest__c) {
        objWrapper.boolUseId = true;
      } else {
        searchKey += strBedStatusAvailable;
        objWrapper.boolUseId = false;
      }
    } else if (objCase.Status == strPlacementRequestedStatus
        && objCase.UAC_requiresPlacementRequest__c) {
      objWrapper.strFutureStatus = strBedStatusOnHold;
      searchKey += strBedStatusAvailable;
      objWrapper.boolUseId = false;
    } else if (objCase.Status == strPlacementNotAcceptedStatus
        && objCase.UAC_requiresPlacementRequest__c) {
      objWrapper.strFutureStatus = strBedStatusAvailable;
      objWrapper.boolUseId = true;
      objWrapper.boolEmptyId = true;
    } else if (oldCase.Status == strPlacementDesignatedStatus
        && objCase.Status != strPlacementDesignatedStatus) {
      objWrapper.strFutureStatus = strBedStatusAvailable;
      objWrapper.boolUseId = true;
      objWrapper.boolEmptyId = true;
    } else {
      return;
    }
    // Add wrapper info to collections for other methods
    if (objWrapper.boolUseId) {
      setOfContactIds.add(objCase.ContactId);
      setOfProgramsForAssignedBedUpdates.add(objCase.UAC_programFacility__c);
    } else {
      objWrapper.strSearchKey = searchKey;
      setOfSearchKeys.add(searchKey);
    }
    mapAssetUpdateWrapper.put(objCase.Id, objWrapper);
  }

  /*
   * @description Sets instruction wrapper for future methods for each non-referral Case
   * @author James Qian (Deloitte) | 3/17/2021
   * @param Case objCase
   * @param Case oldCase
   * @return
   **/
  private
  void setQueryParamsForCase(Case objCase, Case objOldCase) {
    Id idProgram;
    String bedStatus;
    // Create a new wrapper
    AssetUpdateWrapper objWrapper = new AssetUpdateWrapper();

    // Based on status and placement request set values on the wrapper for future logic

    // Transfer not approved - make bed available
    if (objCase.Status == strReleaseRequestStatusFFSReview
        && objCase.UAC_orrDecision__c != objOldCase.UAC_orrDecision__c
        && (objCase.UAC_orrDecision__c == strTransferNotApprovedORR
            || objCase.UAC_orrDecision__c == strTransferRemandedORR)) {
      objWrapper.strFutureStatus = strBedStatusAvailable;
      objWrapper.boolUseId = true;
      objWrapper.boolEmptyId = true;
      idProgram = objCase.UAC_programFacility__c;
    // Transfer approved influx - make on-hold/assigned bed occupied
    } else if (objCase.Status == strReleaseRequestStatusFFSReview
        && objCase.UAC_orrDecision__c != objOldCase.UAC_orrDecision__c
        && objCase.UAC_orrDecision__c == strTransferApprovedORR
        && objCase.RecordTypeId
            == mapRecordTypesByDeveloperName.get(strCaseRecordTypeTransferRequest)
                   .getRecordTypeId()) {
      objWrapper.strFutureStatus = strBedStatusOccupied;
      objWrapper.boolUseId = true;
      idProgram = objCase.UAC_programFacility__c;
    // Discharge completed - make occupied/assigned bed available
    } else if (objCase.Status == strCaseStatusDischargeCompleted
        && objCase.Status != objOldCase.Status
        && objCase.RecordTypeId
            == mapRecordTypesByDeveloperName.get(strCaseRecordTypeDischargeNotification)
                   .getRecordTypeId()) {
      objWrapper.strFutureStatus = strBedStatusAvailable;
      objWrapper.boolUseId = true;
      objWrapper.boolEmptyId = true;
      idProgram = objCase.UAC_currentProgram__c;
    // Transfer LNO recommended Influx - make available bed on-hold
    } else if (objCase.UAC_LNORecommendation__c != objOldCase.UAC_LNORecommendation__c
        && objCase.UAC_LNORecommendation__c == strAccepted
        && objCase.RecordTypeId
            == mapRecordTypesByDeveloperName.get(strCaseRecordTypeAdmission).getRecordTypeId()) {
      objWrapper.strFutureStatus = strBedStatusOnHold;
      objWrapper.boolUseId = false;
      bedStatus = strBedStatusAvailable;
      idProgram = objCase.UAC_InfluxProgram__c;
    // Transfer/Admission influx, make on-hold bed occupied
    } else if (objCase.Status != objOldCase.Status && objCase.Status == strAdmittedStatus
        && objCase.Type == Label.UAC_CaseTypeInfluxTransfer
        && objCase.RecordTypeId
            == mapRecordTypesByDeveloperName.get(strCaseRecordTypeAdmission).getRecordTypeId()) {
      objWrapper.strFutureStatus = strBedStatusOccupied;
      objWrapper.boolUseId = true;
      idProgram = objCase.UAC_programFacility__c;
    } else {
      return;
    }
    // Add wrapper info to collections for other methods
    if (objWrapper.boolUseId && String.isNotBlank(idProgram)) {
      setOfProgramsForAssignedBedUpdates.add(idProgram);
      setOfContactIds.add(objCase.ContactId);
    } else if (String.isNotBlank(bedStatus) && String.isNotBlank(idProgram)) {
      String strGender = String.isBlank(objCase.UC_bedTypeOverride__c)
          ? objCase.UAC_gender__c
          : objCase.UC_bedTypeOverride__c;
      objWrapper.strSearchKey = String.valueOf(idProgram) + '.' + strGender + '.'
          + String.valueOf(Integer.valueOf(objCase.UAC_age__c) <= 12 ? 'Tender Age' : 'Teen') + '.'
          + bedStatus;
      setOfSearchKeys.add(objWrapper.strSearchKey);
    } else {
      objCase.addError(STR_ERR_REQ_FIELD);
      return;
    }
    mapAssetUpdateWrapper.put(objCase.Id, objWrapper);
  }

  /*
   * @description Queries assets that meet criteria and stores in structure
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  private
  void queryAndStoreAssets() {

    // Query
    for (Asset objAsset : [
           SELECT Id,
           Status,
           AccountId,
           ContactId,
           UAC_gender__c,
           UAC_searchKey__c FROM Asset WHERE(
               UAC_searchKey__c in
               : setOfSearchKeys OR(ContactId IN
                                    : setOfContactIds AND AccountId IN
                                    : setOfProgramsForAssignedBedUpdates))
               AND UAC_overallStatus__c = 'Delivered'
         ]) {

      // Store in maps for searching
      if (objAsset.ContactId != null) {
        mapContactIdToAsset.put(objAsset.ContactId, objAsset);
      } else {
        List<Asset> lstOfAssets;
        if (mapSearchKeyToAssets.containsKey(objAsset.UAC_searchKey__c)) {
          lstOfAssets = mapSearchKeyToAssets.get(objAsset.UAC_searchKey__c);
        } else {
          lstOfAssets = new List<Asset>();
        }
        lstOfAssets.add(objAsset);
        mapSearchKeyToAssets.put(objAsset.UAC_searchKey__c, lstOfAssets);
      }
    }
  }

  /**
   * @description ORRUAC-69: Automatic Bed Update - Refactored for 5432
   * @author Issam Awwad (Deloitte) | 6/3/2020
   * @return void
   **/
  private
  void updateAssets(List<Case> listCasesToProcess) {
    List<Asset> lstBedsToUpdate = new List<Asset>();

    // Loop through all cases
    for (Case objCase : listCasesToProcess) {
      if (!mapAssetUpdateWrapper.containsKey(objCase.Id)) {
        continue;
      }

      // Get wrapper from map
      AssetUpdateWrapper objWrapper = mapAssetUpdateWrapper.get(objCase.Id);

      // Get Asset to update and handle errors
      Asset bedToUpdate = getBedToUpdate(objWrapper, objCase);
      if (bedToUpdate != null) {
        lstBedsToUpdate.add(bedToUpdate);
      } else if (!objWrapper.boolUseId) {
        // If finding an open bed, throw an error
        objCase.addError(STR_ERR_NO_BEDS);
      }
    }

    // DML and error handling
    if (!lstBedsToUpdate.isEmpty()) {
      try {
        update lstBedsToUpdate;
      } catch (Exception e) {
        String str = e.getMessage();
        if (str.contains('Insufficient')){
          Integer indx = str.indexOf('Insufficient');
          Integer indx2 = str.indexOf('Portal') + 7;
          listCasesToProcess[0].addError(STR_ERR_CAUGHT + str.substring(indx,indx2));
        }
        else{
        UAC_errorLog.logError(e.getMessage(), '', 'Updating bed fields', e.getStackTraceString());
        listCasesToProcess[0].addError(STR_ERR_CAUGHT + e.getMessage());
        }
      }
    }
  }

  /**
   * @description ORRUAC-69: Automatic Bed Update - Refactored for 5432
   * @author Issam Awwad (Deloitte) | 6/3/2020
   * @param AssetUpdateWrapper objWrapper
   * @param Case objCase
   * @return Asset(Bed) to update
   **/
  private
  Asset getBedToUpdate(AssetUpdateWrapper objWrapper, Case objCase) {
    Asset objAsset;

    // If changing a bed that is on-hold/occupied, use ID to find asset
    if (objWrapper.boolUseId && mapContactIdToAsset.containsKey(objCase.ContactId)) {
      objAsset = mapContactIdToAsset.get(objCase.ContactId);
    } else if (!objWrapper.boolUseId && mapSearchKeyToAssets.containsKey(objWrapper.strSearchKey)) {
      // Otherwise use search key and pull first asset that meets requirements
      List<Asset> listAssets = mapSearchKeyToAssets.get(objWrapper.strSearchKey);
      if (listAssets == null || listAssets.isEmpty()) {
        return null;
      }
      objAsset = listAssets[0];
      listAssets.remove(0);
      mapSearchKeyToAssets.put(objWrapper.strSearchKey, listAssets);
    } else {
      return null;
    }

    // Set fields on Asset and return Asset
    objAsset.Status = objWrapper.strFutureStatus;
    if (objWrapper.boolEmptyId) {
      objAsset.ContactId = null;
    } else {
      objAsset.ContactId = objCase.ContactId;
    }
    return objAsset;
  }

  /*
   * @description Resets collections
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  private
  void instantiateCollections() {
    setOfSearchKeys = new Set<String>();
    setOfContactIds = new Set<Id>();
    mapAssetUpdateWrapper = new Map<Id, AssetUpdateWrapper>();
    mapSearchKeyToAssets = new Map<String, List<Asset>>();
    mapContactIdToAsset = new Map<Id, Asset>();
  }

  /*
   * @description Checks for empty fields for referral
   * @author James Qian (Deloitte) | 3/17/2021
   * @param Case objCase
   * @return Boolean
   **/
  private
  static Boolean validateReferralFields(Case objCase) {
    if (String.isBlank(objCase.UAC_programFacility__c) || String.isBlank(objCase.UAC_gender__c)
        || objCase.UAC_age__c == null || objCase.ContactId == null) {
      return false;
    } else {
      return true;
    }
  }

  /*
   * @description Checks for empty fields for non-referral Case
   * @author James Qian (Deloitte) | 3/17/2021
   * @param Case objCase
   * @return Boolean
   **/
  private
  static Boolean validateCaseFields(Case objCase) {
    if (String.isBlank(objCase.UAC_gender__c) || objCase.UAC_age__c == null
        || objCase.ContactId == null) {
      return false;
    } else {
      return true;
    }
  }

  /*
   * @description Wrapper class to store instructions for asset updates
   * @author James Qian (Deloitte) | 3/17/2021
   **/
  private
  without sharing class AssetUpdateWrapper {
    private
    String strSearchKey;
    private
    Boolean boolUseId;
    private
    String strFutureStatus;
    private
    Boolean boolEmptyId = false;
  }
}