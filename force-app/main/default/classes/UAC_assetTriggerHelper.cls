/**
 * @File Name          : UAC_assetTriggerHelper .cls
 * @Description        : Helper for Asset trigger
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_assetTriggerHelper
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    6/09/2020   Issam Awwad (Deloitte)     Initial Implementation.
 * 1.1    6/09/2020   Issam Awwad (Deloitte)   ORRUAC-69: Automatic Bed Update
 * 1.2    6/09/2020   James Qian (Deloitte)  ORRUAC-70: Manual Bed Update
 * 1.3    3/17/2021   James Qian (Deloitte)  ORRUAC-5432: Refactor to add Type
 **/
public
without sharing class UAC_assetTriggerHelper {

  /**
   * @description Method to set asset name to value of UAC_bedID__c
   * @author James Qian(Deloitte) | 6/09/2020
   * @param mapNewItems map of new records
   * @return void
   **/
  public
  static void setAssetName(Map<Id, sObject> mapNewItems) {
    Map<Id, Asset> mapNewBeds = (Map<Id, Asset>) mapNewItems;
    List<Asset> listAssetsToUpdate = new List<Asset>();
    for (Asset assetCurrent : mapNewBeds.values()) {
      listAssetsToUpdate.add(new Asset(Name = assetCurrent.UAC_bedID__c, Id = assetCurrent.Id));
    }
    if (!listAssetsToUpdate.isEmpty()) {
      update listAssetsToUpdate;
    }
  }

  /**
   * @description ORRUAC-5432: Emptying out contact field when status is updated.
   * @author James Qian (Deloitte) | 3/17/2021
   * @param lstNewAsset List of new Asset records
   * @param mapOldAsset Map of old Asset records
   * @return void
   **/
  public
  static void emptyProfileOnStatusChange(List<Asset> lstNewAsset, Map<Id, Asset> mapOldAsset) {
    for (Asset objNewAsset : lstNewAsset) {
      if (objNewAsset.Status == 'Available' && objNewAsset.ContactId != null
          && objNewAsset.Status != mapOldAsset.get(objNewAsset.Id).Status) {
        objNewAsset.ContactId = null;
      }
    }
  }

  /**
   * @description ORRUAC-69: Automatic Bed Update:
   * Method to update bed(s) availablilty fields on related account on creation of new beds
   * @author Issam Awwad(Deloitte) | 6/09/2020
   * @param mapNewItems map of new records
   * @return void
   **/
  public
  static void autoBedInsert(Map<Id, sObject> mapNewItems) {
    Map<Id, Asset> mapNewBeds = (Map<Id, Asset>) mapNewItems;
    Map<Id, Account> mapAccountIds = new Map<Id, Account>();
    for (Asset assetCurrent : mapNewBeds.values()) {
      mapAccountIds.put(assetCurrent.AccountId, null);
    }
    mapAccountIds = getAccountsForUpdate(mapAccountIds.keyset());
    for (Asset assetCurrent : mapNewBeds.values()) {
      Account objAccount = setAccountDefaultsForUpdate(assetCurrent.AccountId, mapAccountIds);
      String newRollupVariance = getRollupFieldToUpdateVariance(assetCurrent);
      String newRollupType = getRollupFieldToUpdateType(assetCurrent);
      String newRollupStandard = getRollupFieldToUpdate(assetCurrent);
      if (String.isNotBlank(newRollupStandard)) {
        Decimal newRollupValue = (Decimal) objAccount.get(newRollupStandard);
        objAccount.put(newRollupStandard, newRollupValue + 1);
      }
      if (String.isNotBlank(newRollupVariance)) {
        Decimal newRollupValue = (Decimal) objAccount.get(newRollupVariance);
        objAccount.put(newRollupVariance, newRollupValue + 1);
      }
      if (String.isNotBlank(newRollupType)) {
        Decimal newRollupValue = (Decimal) objAccount.get(newRollupType);
        objAccount.put(newRollupType, newRollupValue + 1);
      }
      objAccount.UAC_fundedCapacity__c = objAccount.UAC_fundedCapacity__c + 1;
      mapAccountIds.put(objAccount.Id, objAccount);
    }
    updateAccounts(mapAccountIds.values());
  }
  /**
   * @description ORRUAC-69: Automatic Bed Update:
   * Method to update bed(s) availablilty fields on related account on update of beds
   * @author Issam Awwad (Deloitte) | 6/3/2020
   * @param lstNewAsset List of new Asset records
   * @param mapOldAsset Map of old Asset records
   * @return void
   **/
  public
  static void autoBedUpdate(List<Asset> lstNewAsset, Map<Id, Asset> mapOldAsset) {
    Set<Id> setAccountIds = new Set<Id>();
    List<Asset> lstOfValidAssets = new List<Asset>();

    // First loop looks for changes, stores in collections
    for (Asset objNewAsset : lstNewAsset) {
      Asset objOldAsset = mapOldAsset.get(objNewAsset.Id);
      if (objNewAsset.Status != objOldAsset.Status
          || objNewAsset.UAC_overallStatus__c != objOldAsset.UAC_overallStatus__c
          || objNewAsset.UAC_gender__c != objOldAsset.UAC_gender__c
          || objNewAsset.UC_Type__c != objOldAsset.UC_Type__c
          || objNewAsset.UAC_varianceBed__c != objOldAsset.UAC_varianceBed__c) {
        setAccountIds.add(objNewAsset.AccountId);
        lstOfValidAssets.add(objNewAsset);
      }
    }
    if (setAccountIds.isEmpty()) {
      return;
    }

    // Query accounts
    Map<Id, Account> mapToAccount = getAccountsForUpdate(setAccountIds);

    // Loop through assets to update Account fields
    for (Asset objAsset : lstOfValidAssets) {
      Account objAccount = setAccountDefaultsForUpdate(objAsset.AccountId, mapToAccount);
      Asset objOldAsset = mapOldAsset.get(objAsset.Id);
      updateAccountWithVarianceRollups(objAccount, objAsset, objOldAsset);
      updateAccountWithStandardRollups(objAccount, objAsset, objOldAsset);
      updateAccountWithTypeRollups(objAccount, objAsset, objOldAsset);
      mapToAccount.put(objAsset.AccountId, objAccount);
    }
    updateAccounts(mapToAccount.values());
  }

  /**
   * @description Refactor for standard bed rollup calculation
   * @author James Qian (Deloitte) | 3/15/2021
   * @param Account objAccount Account to update
   * @param Asset objNewAsset New asset in trigger
   * @param Asset objOldAsset Old asset in trigger
   * @return String
   **/
  private
  static void updateAccountWithStandardRollups(
      Account objAccount, Asset objNewAsset, Asset objOldAsset) {
    if (objNewAsset.Status == objOldAsset.Status
        && objNewAsset.UAC_gender__c == objOldAsset.UAC_gender__c
        && objNewAsset.UC_Type__c == objOldAsset.UC_Type__c
        && objNewAsset.UAC_overallStatus__c == objOldAsset.UAC_overallStatus__c) {
      return;
    }
    String oldRollup = getRollupFieldToUpdate(objOldAsset);
    String newRollup = getRollupFieldToUpdate(objNewAsset);
    if (oldRollup == newRollup) {
      return;
    }
    if (String.isNotBlank(oldRollup)) {
      Decimal oldRollupValue = (Decimal) objAccount.get(oldRollup);
      objAccount.put(oldRollup, handleNegatives(oldRollupValue - 1));
    }
    if (String.isNotBlank(newRollup)) {
      Decimal newRollupValue = (Decimal) objAccount.get(newRollup);
      objAccount.put(newRollup, newRollupValue + 1);
    }
  }

  /**
   * @description Refactor for variance bed rollup calculation
   * @author James Qian (Deloitte) | 3/15/2021
   * @param Account objAccount Account to update
   * @param Asset objNewAsset New asset in trigger
   * @param Asset objOldAsset Old asset in trigger
   * @return String
   **/
  private
  static void updateAccountWithVarianceRollups(
      Account objAccount, Asset objNewAsset, Asset objOldAsset) {
    if (objNewAsset.UAC_varianceBed__c == objOldAsset.UAC_varianceBed__c
        && objNewAsset.UAC_overallStatus__c == objOldAsset.UAC_overallStatus__c) {
      return;
    }
    String oldRollup = getRollupFieldToUpdateVariance(objOldAsset);
    String newRollup = getRollupFieldToUpdateVariance(objNewAsset);
    if (oldRollup == newRollup) {
      return;
    }
    if (String.isNotBlank(oldRollup)) {
      Decimal oldRollupValue = (Decimal) objAccount.get(oldRollup);
      objAccount.put(oldRollup, handleNegatives(oldRollupValue - 1));
    }
    if (String.isNotBlank(newRollup)) {
      Decimal newRollupValue = (Decimal) objAccount.get(newRollup);
      objAccount.put(newRollup, newRollupValue + 1);
    }
  }

  /**
   * @description Refactor for Type bed rollup calculation
   * @author James Qian (Deloitte) | 3/15/2021
   * @param assetCurrent Bed that was updated
   * @return String
   **/
  private
  static void updateAccountWithTypeRollups(
      Account objAccount, Asset objNewAsset, Asset objOldAsset) {
    if (objNewAsset.UAC_gender__c == objOldAsset.UAC_gender__c
        && objNewAsset.UC_Type__c == objOldAsset.UC_Type__c
        && objNewAsset.Status == objOldAsset.Status) {
      return;
    }
    String oldRollup = getRollupFieldToUpdateType(objOldAsset);
    String newRollup = getRollupFieldToUpdateType(objNewAsset);
    if (oldRollup == newRollup) {
      return;
    }
    if (String.isNotBlank(oldRollup)) {
      Decimal oldRollupValue = (Decimal) objAccount.get(oldRollup);
      objAccount.put(oldRollup, handleNegatives(oldRollupValue - 1));
    }
    if (String.isNotBlank(newRollup)) {
      Decimal newRollupValue = (Decimal) objAccount.get(newRollup);
      objAccount.put(newRollup, newRollupValue + 1);
    }
  }

  /**
   * @description ORRUAC-69/70: Automatic Bed Update:
   * Method to return which fields needed to be updated on related account based on bed that was
   *updated
   * @author James Qian (Deloitte) | 6/9/2020
   * @param assetCurrent Bed that was updated
   * @return String
   **/
  private
  static String getRollupFieldToUpdate(Asset assetCurrent) {
    if (assetCurrent.UAC_overallStatus__c == 'Delivered') {
      if (assetCurrent.Status == 'Available') {
        if (assetCurrent.UAC_gender__c == 'Male') {
          return 'UAC_bedCountAvailableMale__c';
        } else if (assetCurrent.UAC_gender__c == 'Female') {
          return 'UAC_bedCountAvailableFemale__c';
        }
      } else if (assetCurrent.Status == 'Unavailable') {
        if (assetCurrent.UAC_gender__c == 'Male') {
          return 'UAC_Bed_Count_Unavailable_Male__c';
        } else if (assetCurrent.UAC_gender__c == 'Female') {
          return 'UAC_Bed_Count_Unavailable_Female__c';
        }
      } else if (assetCurrent.Status == 'On-Hold') {
        if (assetCurrent.UAC_gender__c == 'Male') {
          return 'UAC_bedCountOnHoldMale__c';
        } else if (assetCurrent.UAC_gender__c == 'Female') {
          return 'UAC_bedCountOnHoldFemale__c';
        }
      } else if (assetCurrent.Status == 'Occupied') {
        if (assetCurrent.UAC_gender__c == 'Male') {
          return 'UAC_bedCountUnavailableMale__c';
        } else if (assetCurrent.UAC_gender__c == 'Female') {
          return 'UAC_bedCountUnavailableFemale__c';
        }
      }
    } else if (assetCurrent.UAC_overallStatus__c == 'Undelivered') {
      if (assetCurrent.Status == 'Warm') {
        return 'UAC_undeliveredWarmStatus__c';
      } else if (assetCurrent.Status == 'Reserve') {
        return 'UAC_undeliveredReserveStatus__c';
      }
    }
    return '';
  }

  /**
   * @description Refactor for variance bed rollup calculation
   * @author James Qian (Deloitte) | 3/15/2021
   * @param assetCurrent Bed that was updated
   * @return String
   **/
  private
  static String getRollupFieldToUpdateVariance(Asset assetCurrent) {
    if (assetCurrent.UAC_varianceBed__c) {
      if (assetCurrent.UAC_overallStatus__c == 'Undelivered') {
        return 'UAC_undeliveredVarianceBeds__c';
      } else if (assetCurrent.UAC_overallStatus__c == 'Delivered') {
        return 'UAC_deliveredVarianceBeds__c';
      }
    }
    return '';
  }

  /**
   * @description ORRUAC-69/70: Automatic Bed Update:
   * Method to return which fields needed to be updated on related account based on bed that was
   *updated
   * @author James Qian (Deloitte) | 6/9/2020
   * @param assetCurrent Bed that was updated
   * @return String
   **/
  private
  static String getRollupFieldToUpdateType(Asset assetCurrent) {
    if (assetCurrent.Status != 'Available') {
      return '';
    }
    if (assetCurrent.UAC_gender__c == 'Female') {
      if (assetCurrent.UC_Type__c == 'Tender Age') {
        return 'UC_tenderFemaleBeds__c';
      } else if (assetCurrent.UC_Type__c == 'Teen') {
        return 'UC_teenFemaleBeds__c';
      }
    } else if (assetCurrent.UAC_gender__c == 'Male') {
      if (assetCurrent.UC_Type__c == 'Tender Age') {
        return 'UC_tenderMaleBeds__c';
      } else if (assetCurrent.UC_Type__c == 'Teen') {
        return 'UC_teenMaleBeds__c';
      }
    }
    return '';
  }

  /**
   * @description ORRUAC-70: Manual Bed Update:
   * Method to update bed(s) availablilty fields on related account on deletion of beds
   * @author James Qian (Deloitte) | 6/9/2020
   * @param mapOldItems Map of old Case records
   * @return void
   **/
  public
  static void autoBedDelete(Map<Id, sObject> mapOldItems) {
    Map<Id, Asset> mapOldBeds = (Map<Id, Asset>) mapOldItems;
    Map<Id, Account> mapAccountIds = new Map<Id, Account>();
    for (Asset assetCurrent : mapOldBeds.values()) {
      mapAccountIds.put(assetCurrent.AccountId, null);
    }
    mapAccountIds = getAccountsForUpdate(mapAccountIds.keyset());
    for (Asset assetCurrent : mapOldBeds.values()) {
      Account objAccount = setAccountDefaultsForUpdate(assetCurrent.AccountId, mapAccountIds);
      String oldRollupVariance = getRollupFieldToUpdateVariance(assetCurrent);
      String oldRollupType = getRollupFieldToUpdateType(assetCurrent);
      String oldRollupStandard = getRollupFieldToUpdate(assetCurrent);
      if (String.isNotBlank(oldRollupStandard)) {
        Decimal newRollupValue = (Decimal) objAccount.get(oldRollupStandard);
        objAccount.put(oldRollupStandard, handleNegatives(newRollupValue - 1));
      }
      if (String.isNotBlank(oldRollupVariance)) {
        Decimal newRollupValue = (Decimal) objAccount.get(oldRollupVariance);
        objAccount.put(oldRollupVariance, handleNegatives(newRollupValue - 1));
      }
      if (String.isNotBlank(oldRollupType)) {
        Decimal newRollupValue = (Decimal) objAccount.get(oldRollupType);
        objAccount.put(oldRollupType, handleNegatives(newRollupValue - 1));
      }
      objAccount.UAC_fundedCapacity__c = handleNegatives(objAccount.UAC_fundedCapacity__c - 1);
      mapAccountIds.put(objAccount.Id, objAccount);
    }
    updateAccounts(mapAccountIds.values());
  }

  /**
   * @description ORRUAC-70: Manual Bed Update:
   * Method to return a map of related accounts needed to be updated
   * @author James Qian (Deloitte) | 6/9/2020
   * @param accountIds set of account ids related to bed(s) that were updated
   * @return  Map<Id, Account>
   **/
  private
  static Map<Id, Account> getAccountsForUpdate(Set<Id> accountIds) {
    return new Map<Id, Account>([
      // clang-format off
      SELECT
        Id,
        UAC_bedCountUnavailableMale__c,
        UAC_bedCountOnHoldMale__c,
        UAC_bedCountUnavailableFemale__c,
        UAC_bedCountOnHoldFemale__c,
        UAC_bedCountAvailableMale__c,
        UAC_bedCountAvailableFemale__c,
        UAC_fundedCapacity__c,
        UAC_Bed_Count_Unavailable_Female__c,
        UAC_Bed_Count_Unavailable_Male__c,
        UAC_deliveredVarianceBeds__c,
        UAC_undeliveredReserveStatus__c,
        UAC_undeliveredVarianceBeds__c,
        UAC_undeliveredWarmStatus__c,
        UC_teenFemaleBeds__c,
        UC_teenMaleBeds__c,
        UC_tenderFemaleBeds__c,
        UC_tenderMaleBeds__c
      FROM
        Account
      WHERE
        Id IN :accountIds
      // clang-format on
    ]);
  }

  /**
   * @description ORRUAC-69: Automatic Bed Update:
   * Method to perform update operation
   * @author Issam Awwad (Deloitte) | 6/9/2020
   * @param listAccounts list of accounts to update
   * @return  void
   **/
  private
  static void updateAccounts(List<Account> listAccounts) {
    if (!listAccounts.isEmpty()) {
      try {
        update listAccounts;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Updating Account bed availability fields',
            e.getStackTraceString());
      }
    }
  }

  /**
   * @description ORRUAC-69: Automatic Bed Update:
   * Method to set bed availability related fields on account - refactored in 5432 to reduce map calls
   * @author Issam Awwad (Deloitte) | 6/9/2020
   * @param idAccount id of account to update, mapAccountIds map of ids to account
   * @return  Account
   **/
  private
  static Account setAccountDefaultsForUpdate(Id idAccount, Map<Id, Account> mapAccountIds) {
    Account objAccount = mapAccountIds.get(idAccount);
    objAccount.UAC_bedCountAvailableMale__c = objAccount.UAC_bedCountAvailableMale__c == null
        ? 0
        : objAccount.UAC_bedCountAvailableMale__c;
    objAccount.UAC_bedCountAvailableFemale__c = objAccount.UAC_bedCountAvailableFemale__c == null
        ? 0
        : objAccount.UAC_bedCountAvailableFemale__c;
    objAccount.UAC_bedCountUnavailableMale__c = objAccount.UAC_bedCountUnavailableMale__c == null
        ? 0
        : objAccount.UAC_bedCountUnavailableMale__c;
    objAccount.UAC_bedCountOnHoldMale__c =
        objAccount.UAC_bedCountOnHoldMale__c == null ? 0 : objAccount.UAC_bedCountOnHoldMale__c;
    objAccount.UAC_bedCountUnavailableFemale__c =
        objAccount.UAC_bedCountUnavailableFemale__c == null
        ? 0
        : objAccount.UAC_bedCountUnavailableFemale__c;
    objAccount.UAC_bedCountOnHoldFemale__c =
        objAccount.UAC_bedCountOnHoldFemale__c == null ? 0 : objAccount.UAC_bedCountOnHoldFemale__c;
    objAccount.UAC_fundedCapacity__c =
        objAccount.UAC_fundedCapacity__c == null ? 0 : objAccount.UAC_fundedCapacity__c;
    objAccount.UAC_Bed_Count_Unavailable_Male__c =
        objAccount.UAC_Bed_Count_Unavailable_Male__c == null
        ? 0
        : objAccount.UAC_Bed_Count_Unavailable_Male__c;
    objAccount.UAC_Bed_Count_Unavailable_Female__c =
        objAccount.UAC_Bed_Count_Unavailable_Female__c == null
        ? 0
        : objAccount.UAC_Bed_Count_Unavailable_Female__c;
    objAccount.UAC_undeliveredReserveStatus__c = objAccount.UAC_undeliveredReserveStatus__c == null
        ? 0
        : objAccount.UAC_undeliveredReserveStatus__c;
    objAccount.UAC_undeliveredVarianceBeds__c = objAccount.UAC_undeliveredVarianceBeds__c == null
        ? 0
        : objAccount.UAC_undeliveredVarianceBeds__c;
    objAccount.UAC_undeliveredWarmStatus__c = objAccount.UAC_undeliveredWarmStatus__c == null
        ? 0
        : objAccount.UAC_undeliveredWarmStatus__c;
    objAccount.UAC_deliveredVarianceBeds__c = objAccount.UAC_deliveredVarianceBeds__c == null
        ? 0
        : objAccount.UAC_deliveredVarianceBeds__c;
    objAccount.UC_teenFemaleBeds__c =
        objAccount.UC_teenFemaleBeds__c == null ? 0 : objAccount.UC_teenFemaleBeds__c;
    objAccount.UC_teenMaleBeds__c =
        objAccount.UC_teenMaleBeds__c == null ? 0 : objAccount.UC_teenMaleBeds__c;
    objAccount.UC_tenderFemaleBeds__c =
        objAccount.UC_tenderFemaleBeds__c == null ? 0 : objAccount.UC_tenderFemaleBeds__c;
    objAccount.UC_tenderMaleBeds__c =
        objAccount.UC_tenderMaleBeds__c == null ? 0 : objAccount.UC_tenderMaleBeds__c;
    return objAccount;
  }
  /**
   * @description Set searchKey of asset on insert/update
   * @author Issam Awwad (Deloitte) | 8/11/2020
   * @param lstOfAssets list of assets to update searchkey
   * @return  Account
   **/
  public
  static void setSearchKey(List<Asset> lstOfAssets) {
    for (Asset objAsset : lstOfAssets) {
      if (String.isBlank(objAsset.UC_Type__c) || String.isBlank(objAsset.AccountId)
          || String.isBlank(objAsset.UAC_gender__c) || String.isBlank(objAsset.Status)) {
        continue;
      }
      objAsset.UAC_searchKey__c = String.valueOf(objAsset.AccountId) + '.'
          + String.valueOf(objAsset.UAC_gender__c) + '.' + String.valueOf(objAsset.UC_Type__c) + '.'
          + String.valueOf(objAsset.Status);
    }
  }

  /**
   * @description Handles negative numbers
   * @author James Qian (Deloitte) | 4/21/2021
   * @param Decimal decBeds
   * @return  Decimal
   **/
  private
  static Decimal handleNegatives(Decimal decBeds) {
    if (decBeds == null || decBeds < 0) {
      return 0;
    } else {
      return decBeds;
    }
  }
}