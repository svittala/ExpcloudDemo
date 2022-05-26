/**
 * @File Name          : UAC_uacMonitorTriggerHandler.cls
 * @Description        : Handles all SIR Notification trigger traffic
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
*  1.0      10/12/2020   Vaibhav Kudesia (Deloitte)      Initial Implementation.
*  2.1      11/03/2020   Sudeep Chintala(Deloitte)	  Adding bypass logic
*  3.0      07/28/2021   Nithin Malla (Deloitte)	       ORRUAC-6064 Added Exclusion logic.
 **/
public
without sharing class UAC_monitoringTriggerHandler implements UAC_ITriggerHandler {

    private
    static final String STR_MONITORING_SOQL = 'UC_Monitoring';

/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassmonitoringtrigger__c;
  }
  /**
   * @description Method to handle before insert trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param lstNewDiagnosis List of new records
   * @return void
   **/
  public
  void beforeInsert(List<Sobject> newItems) {
  		UAC_monitoringTriggerHelper.updatePreMonitoringEmailNotification(newItems,false,null,null);
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
     if(UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_MONITORING_SOQL)){
          UAC_monitoringTriggerHelper.updatePreMonitoringEmailNotification(newItems.values(),false,newItems,oldItems);
          //UAC_monitoringTriggerHelper.uacMonitorValidation(newItems,oldItems); 
     }
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
     UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), STR_MONITORING_SOQL);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
     UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(),STR_MONITORING_SOQL);
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
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
   * @author Vaibhav Kudesia (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
       // No Action
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
      // No Action
  }
}