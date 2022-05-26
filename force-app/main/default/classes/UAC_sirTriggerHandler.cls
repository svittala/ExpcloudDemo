/**
 * @File Name          : UAC_sirTriggerHandler.cls
 * @Description        : Handles all SIR trigger traffic
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 *  1.0      10/29/2020     Sarang Padhye (Deloitte)     Initial Implementation.
 *  2.0      11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
 *  3.0      7/19/2021      Nithin Malla (Deloitte)      ORRUAC-6071 Added SIR Exclusion logic.
 **/
public
without sharing class UAC_sirTriggerHandler implements UAC_ITriggerHandler {

/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassSIRTrigger__c;
  }
  /**
   * @description Method to handle before insert trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param lstNewSirs List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_sir__c> lstNewSirs) {
    UAC_sirTriggerHelper.resetSIRFieldsOnCreate(lstNewSirs);
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      // Change to add if condision for Exclusion logic -- Nithin 07/19/21 ORRUAC-6071
      if (UC_exclusionLogicService.getInstance().runExclusionsForSIR(newItems)) { 
          UAC_sirTriggerHelper.validateSIRStatusUpdates((Map<Id, UAC_sir__c>) newItems, (Map<Id, UAC_sir__c>) oldItems);
      }
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
      // Change to add if condision for Exclusion logic -- Nithin 07/19/21 ORRUAC-6071
      UC_exclusionLogicService.getInstance().runExclusionsForSIR(oldItems);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
      // Change to add if condision for Exclusion logic -- Nithin 07/19/21 ORRUAC-6071
      UC_exclusionLogicService.getInstance().runExclusionsForSIR(newItems);
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Sarang Padhye (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}