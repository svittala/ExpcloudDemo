/**
 * @File Name          : UAC_backGroundChkTriggerHandler.cls
 * @Description        : Handles all Background Check trigger traffic
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_ITriggerHandler
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/7/2020   Karthi Subramanian (Deloitte)     Initial Implementation.
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
 **/
public
with sharing class UAC_backGroundChkTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassbackgroundchktrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param newItems List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_backgroundCheck__c> newItems) {
    // UAC_backGroundChkTriggerHelper.canCreateBGRecords(newItems); // *CHANGE* US - 3798 -- US-469
    // - Vaibhav Kudesia - Background check validation
    UAC_backGroundChkTriggerHelper.populateDateARIReceived(newItems);
    UAC_backGroundChkTriggerHelper.populateSponsorRole(newItems);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    List<UAC_backgroundCheck__c> lstOfFBICriminalBackground = new List<UAC_backgroundCheck__c>();
    Map<Id, UAC_backgroundCheck__c> mapCaseNewBackgroundCasted =
        (Map<Id, UAC_backgroundCheck__c>) newItems;
    Map<Id, UAC_backgroundCheck__c> mapCaseOldBackgroundCasted =
        (Map<Id, UAC_backgroundCheck__c>) oldItems;
    for (UAC_backgroundCheck__c objNewBackgroundCheck : mapCaseNewBackgroundCasted.values()) {
      if (objNewBackgroundCheck.UAC_backgroundCheckType__c == Label.UAC_bcgTypeFBICriminalHistory &&
          objNewBackgroundCheck.UAC_sponsorApplication__c
              != mapCaseOldBackgroundCasted.get(objNewBackgroundCheck.Id).UAC_sponsorApplication__c) {
        lstOfFBICriminalBackground.add(objNewBackgroundCheck);
      }
    }
    if (!lstOfFBICriminalBackground.isEmpty()) {
      UAC_backGroundChkTriggerHelper.populateSponsorRole(lstOfFBICriminalBackground);
    }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UAC_backGroundChkTriggerHelper.validateResultsUpdate(
        (Map<Id, UAC_backgroundCheck__c>) oldItems);  // ORRUAC-789
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}