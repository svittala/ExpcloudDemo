/**
 * @File Name          : UAC_accountTriggerHandler.cls
 * @Description        : Handles all Account trigger traffic
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/2/2020   James Qian (Deloitte)     Initial Implementation.
 * 1.1    8/28/2020  Rahul Roy (Deloitte)      ORRUAC-2060 Subcontractor Account Task Creation.
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
 **/
public
without sharing class UAC_accountTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAccountTrigger__c;
  }
  /**
   * @description Method to handle before insert trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param newItems List of new records
   * @return void
   **/
  public
  void beforeInsert(List<Account> newItems) {
    UAC_accountTriggerHelper.handleInsertSearchTag(newItems);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    if (UC_exclusionLogicService.getInstance().runExclusionsForAccount(newItems)) {
      UAC_accountTriggerHelper.setFamilyGroupName(newItems);
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (UC_exclusionLogicService.getInstance().runExclusionsForAccount(newItems)) {
      UAC_accountTriggerHelper.handleUpdateSearchTag(newItems, oldItems);
    }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UAC_accountTriggerHelper.subcontractorAccountTaskCreation(newItems, oldItems);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusionsForAccount(oldItems);
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author James Qian (Deloitte) | 6/2/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}