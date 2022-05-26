/**
 * @File Name          : UAC_monitoringScheduleTriggerHandler.cls
 * @Description        : Handles all Monitoring Schedule trigger traffic
 * @Author             : Chase Oden (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 * 1.0      07/26/2021   Chase Oden (Deloitte)    Initial Implementation.
 **/
public
without sharing class UC_monitoringScheduleTriggerHandler implements UAC_ITriggerHandler {

 /**
   * @description Adding Bypass logic
   * @author Chase Oden (Deloitte) | 07/26/2021
   **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassMonitoringScheduleTrigger__c;
  }

  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_monitoringSchedule';

  /**
   * @description Method to handle before insert trigger traffic
   * @author Chase Oden (Deloitte)
   * @param lstNewDiagnosis List of new records
   * @return void
   **/
  public
  void beforeInsert(List<Sobject> newItems) {
  		// No Action
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
      newItems, newItems.keySet(), STR_EXCLUSION_LOGIC_MDT_NAME);
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
      oldItems, oldItems.keySet(), STR_EXCLUSION_LOGIC_MDT_NAME);
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
      newItems, newItems.keySet(), STR_EXCLUSION_LOGIC_MDT_NAME);
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
       // No Action
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Chase Oden (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
       // No Action
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Chase Oden (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
      // No Action
  }
}