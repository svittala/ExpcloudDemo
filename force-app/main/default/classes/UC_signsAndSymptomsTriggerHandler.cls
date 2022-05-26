/**
 * @File Name          : UC_signsAndSymptomsTriggerHandler.cls
 * @Description        : Handles all Signs and Symptoms Notification trigger traffic
 * @Author             : Chase Oden (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 * 1.0      07/07/2021   Chase Oden (Deloitte)    Initial Implementation.
 **/
public
without sharing class UC_signsAndSymptomsTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Chase Oden (Deloitte) | 07/07/2021
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UC_bypassSignsAndSymptomsTrigger__c;
  }

  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_signsAndSymptoms';

  /**
   * @description Method to handle before insert trigger traffic
   * @author Chase Oden (Deloitte)
   * @param newItems List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_signsAndSymptoms__c> newItems) {
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Chase Oden (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
      newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Chase Oden (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
      oldItems, oldItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Chase Oden (Deloitte)
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
      newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Chase Oden (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Chase Oden (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Chase Oden (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}