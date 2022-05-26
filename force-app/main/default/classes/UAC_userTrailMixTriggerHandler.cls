/**
 * @File Name          : UAC_userTrailMixTriggerHandler.cls
 * @Description        : Handles all User TrailMix trigger traffic
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_ITriggerHandler
 * @Modification Log   :
 * Ver       Date           Author      		    			Modification
 * 1.0    	2/09/2021   	Nithin Malla (Deloitte)    			Initial Implementation.
 **/
public
with sharing class UAC_userTrailMixTriggerHandler implements UAC_ITriggerHandler {
/**
   * @description Adding Bypass logic
   * @author Nithin Malla (Deloitte) | 2/9/2021
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassTrailheadappUserTrailMix__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param newItems List of new records
   * @return void
   **/
  public
  void beforeInsert(List<trailheadapp__User_Trailmix__c> newItems) {
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param oldItems Map of old records
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
     UAC_userTrailMixTriggerHelper.updateCompletedTrailMixToARF(newItems, oldItems);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Nithin Malla (Deloitte) | 2/9/2021
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}