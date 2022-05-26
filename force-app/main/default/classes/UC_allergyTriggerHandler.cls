/**
 * @File Name          : UC_allergyHandler.cls
 * @Description        : Utility class for Allergy Trigger , Handler 
 * @Author             : Piyush(Deloitte)
 * @Last Modified On   : 07/08/2021
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    07/08/2021   	Piyush (Deloitte)        Initial Version
 **/
public without sharing class UC_allergyTriggerHandler implements UAC_ITriggerHandler{

  public Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UC_bypassAllergyTrigger__c;
  }
  private static Boolean boolRun = true;
  private static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_allergy';

  /**
   * @description Method to handle before insert trigger traffic
   * @author Piyush(Deloitte) | 07/08/2021
   * @param newItems Map of new records
   * @return void
   **/
  public void beforeInsert(List<UAC_allergy__c> newItems) {
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Piyush(Deloitte) | 07/08/2021
   * @param newItems Map of new records
   * @return void
   **/
  public void afterInsert(Map<Id, SObject> newItems) {
    UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (!boolRun) {
      return;
    }
    UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Piyush(Deloitte) | 07/08/2021
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Piyush(Deloitte) | 07/08/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public void beforeDelete(Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Piyush(Deloitte) | 07/08/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Piyush(Deloitte) | 07/08/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public void afterUndelete(Map<Id, SObject> oldItems) {
  }
}