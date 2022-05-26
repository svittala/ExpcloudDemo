/**
 * @File Name          : UAC_sirNotificationTriggerHandler.cls
 * @Description        : Handles all SIR Notification trigger traffic
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
*  1.0      07/31/2020   Vaibhav Kudesia (Deloitte)    Initial Implementation.
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)          Adding bypass logic
 **/
public
with sharing class UAC_sirNotificationTriggerHandler implements UAC_ITriggerHandler {
/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypasssirNotificationtrigger__c;
  }
  /**
   * @description Method to handle before insert trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param lstNewDiagnosis List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_sirNotification__c> lstNewDiagnosis) {
    //  UAC_sirNotificationTriggerHelper.updateSIREmailNotification(lstNewDiagnosis,false);
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
     UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), 'UC_SIRNotification');
    //   UAC_sirNotificationTriggerHelper.updateSIREmailNotification(newItems.values(),false);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
      if(UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), 'UC_SIRNotification')){
          UAC_sirNotificationTriggerHelper.verifyDeletionofSirNotifications(oldItems.values());
      }
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
       if(UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), 'UC_SIRNotification')){
           UAC_sirNotificationTriggerHelper.updateSIREmailNotification(newItems.values(),false);
       }
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
       UAC_sirNotificationTriggerHelper.updateSIREmailNotification(newItems.values(),false);
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
       UAC_sirNotificationTriggerHelper.updateSIREmailNotification(oldItems.values(),true);
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Vaibhav Kudesia (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}