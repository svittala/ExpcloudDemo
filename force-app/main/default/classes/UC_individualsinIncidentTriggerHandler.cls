/**
 * @File Name          : UC_individualsinIncidentTriggerHandler.cls
 * @Description        : Handles all Individuals Involved in Incident trigger traffic
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Group              : UC_individualsinIncidentTriggerHandler
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/19/2021   Vaibhav Kudesia (Deloitte)    Initial Implementation.
 **/
public without sharing 
class UC_individualsinIncidentTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UC_bypassIndividualsinIncidentTrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_individualsInvolvedinIncident__c> newItems) {
    // place holder
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
      UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), 'UC_individualsInvolvedinIncident');
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), 'UC_individualsInvolvedinIncident');
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    // place-holder
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
      UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), 'UC_individualsInvolvedinIncident');
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
    // place-holder
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Vaibhav Kudesia (Deloitte) | 7/19/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}