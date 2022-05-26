/**
 * @File Name          : UAC_adultContactChildrenTriggerHandler.cls
 * @Description        : Handles all Adult Contact Children trigger traffic
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Last Modified On   : 02/1/2021
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 *  1.0      02/1/2021  Issam Awwad (Deloitte)         Initial Implementation.
 **/
public
without sharing class UAC_adultContactChildrenTriggerHandler implements UAC_ITriggerHandler {
  private
  static Boolean runTrigger = true;
  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypes =
      Schema.SObjectType.UAC_adultContactsChildren__c.getRecordTypeInfosById();
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAdultContactsChildrenTrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param lstNewAdultContactChildren List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_adultContactsChildren__c> lstNewAdultContactChildren) {
    List<UAC_adultContactsChildren__c> lstOfAdultRecords = new List<UAC_adultContactsChildren__c>();
    if (runTrigger) {
      UAC_adultContactChildrenTriggerHelper.validateAdultContactIsParent(
          lstNewAdultContactChildren);
    }
  }
  /**
   * @description Method to handle before update trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param newItems,oldItems
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param oldItems
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param newItems,oldItems
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }
  /**
   * @description Method to handle after insert trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param oldItems
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> oldItems) {
    runTrigger = false;
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param oldItems
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Issam Awwad (Deloitte) | 2/1/2021
   * @param oldItems
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}