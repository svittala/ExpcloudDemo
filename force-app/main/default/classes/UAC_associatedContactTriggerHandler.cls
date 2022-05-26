/**
 * @File Name          : UAC_associatedContactTriggerHandler.cls
 * @Description        : Handles all Associated Contact trigger traffic
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_ITriggerHandler
 * @Test Class         : UAC_associatedContactTriggerHelperTest
 * @Modification Log   :
 * Ver       Date            Author      		          Modification
 * 1.0    6/7/2020    Karthi Subramanian (Deloitte)   Initial Implementation.
 * 1.1    6/8/2020    Sachet Khanal (Deloitte)        ORRUAC-1017 Associated Contact Uniqueness
 * 2.0	  9/14/2020   Vaibhav Kudesia(Deloitte)		  ORRUAC-438 Create Background check records on
 *Associate COntact Insert
   2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
 **/
public
inherited sharing class UAC_associatedContactTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAssociatedcontacttrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param newItems List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_associatedContact__c> lstNewItems) {
    // ORRUAC-1017 - Validate Associated Contact uniqueness
    UAC_associatedContactTriggerHelper.checkDuplicate(lstNewItems);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    // ORRUAC-438 - Create Background check records on Associate Contact Insert
    UAC_associatedContactTriggerHelper.processCaseRelatedData(newItems.values());
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> mapNewItem, Map<Id, SObject> mapOldItem) {
    List<UAC_associatedContact__c> lstValidateUniqueness = new List<UAC_associatedContact__c>();
    for (Id idNewItem : mapNewItem.keySet()) {
      UAC_associatedContact__c objNew = (UAC_associatedContact__c) mapNewItem.get(idNewItem);
      UAC_associatedContact__c objOld = (UAC_associatedContact__c) mapOldItem.get(idNewItem);
      // Add to list for uniqueness validation if Case or Contact lookup changes
      if (objNew.UAC_case__c != objOld.UAC_case__c
          || objNew.UAC_contact__c != objOld.UAC_contact__c) {
        lstValidateUniqueness.add(objNew);
      }
    }
    if (!lstValidateUniqueness.isEmpty()) {
      // ORRUAC-1017 - Validate Associated Contact uniqueness
      UAC_associatedContactTriggerHelper.checkDuplicate(lstValidateUniqueness);
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
    UAC_associatedContactTriggerHelper.checkHouseHoldAdultCareGiverFlagChange(
        (Map<Id, UAC_associatedContact__c>) newItems,
        (Map<Id, UAC_associatedContact__c>) oldItems);  // ORRUAC-789
    UAC_associatedContactTriggerHelper.populateSponsorRole(
        (Map<Id, UAC_associatedContact__c>) newItems, (Map<Id, UAC_associatedContact__c>) oldItems);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
    UAC_associatedContactTriggerHelper.validateResultsUpdateBackGroundChk(
        (Map<Id, UAC_associatedContact__c>) oldItems);  // ORRUAC-789
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