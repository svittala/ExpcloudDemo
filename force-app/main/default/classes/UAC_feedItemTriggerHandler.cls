/**
 * @File Name          : UAC_feedItemTriggerHandler.cls
 * @Description        : Handles all FeedItem trigger traffic
 * @Author             : James Qian (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                           Modification
 * 1.0    9/29/2020      James Qian (Deloitte)             Initial Implementation
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)	 		Adding bypass logic
 **/
public
without sharing class UAC_feedItemTriggerHandler implements UAC_ITriggerHandler {
 /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassfeedItemTrigger__c;
  }
  public
  void beforeInsert(List<FeedItem> newItems) {
    UAC_feedItemTriggerHelper.preventFileUploadOnChatter(newItems);
  }
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }
  public
  void afterInsert(Map<Id, SObject> newItems) {
  }
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}