/**
 * @File Name          : UAC_assetTriggerHandler.cls
 * @Description        : Handles all Asset trigger traffic
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_assetTriggerHandler
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/09/2020   Issam Awwad (Deloitte)     Initial Implementation.
 * 1.1    6/09/2020   Issam Awwad (Deloitte)   ORRUAC-69: Automatic bed update
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
 **/
public
without sharing class UAC_assetTriggerHandler implements UAC_ITriggerHandler {
  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_asset';
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAssetTrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeInsert(List<Asset> newItems) {
    UAC_assetTriggerHelper.setSearchKey(newItems);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      UAC_assetTriggerHelper.setAssetName(newItems);
      UAC_assetTriggerHelper.autoBedInsert(newItems);
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      UAC_assetTriggerHelper.setSearchKey((List<Asset>) newItems.values());
      UAC_assetTriggerHelper.emptyProfileOnStatusChange(
          (List<Asset>) newItems.values(), (Map<Id, Asset>) oldItems);
    }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UAC_assetTriggerHelper.autoBedUpdate(
        (List<Asset>) newItems.values(), (Map<Id, Asset>) oldItems);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
        oldItems, oldItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
    UAC_assetTriggerHelper.autoBedDelete(oldItems);
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}