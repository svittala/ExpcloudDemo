/**
 * @File Name          : UAC_legalTriggerHandler.cls
 * @Description        : Handles all Legal trigger traffic
 * @Author             : Manoj Sharma (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 ------------------------------------------------------------------------------------
Developer                  Date         Description
------------------------------------------------------------------------------------
Manoj Sharma (Deloitte)    08/24/2020   Initial Implementation.
Sudeep Chintala(Deloitte)11/03/2020	 	Adding bypass logic
 **/

public
with sharing class UAC_legalTriggerHandler implements UAC_ITriggerHandler {
 /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypasslegalTrigger__c;
  }
  static Boolean boolRun = true;
  /**
   * @description Method to handle before insert trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_legal__c> newItems) {
    List<Id> lstUserIds = new List<Id>();
    List<UAC_legal__c> lstLegal = new List<UAC_legal__c>();
    Id idAttorneyOfRecordRecType = Schema.SObjectType.UAC_legal__c.getRecordTypeInfosByDeveloperName()
           .get(label.UAC_legalAttorneyOfRecord)
           .getRecordTypeId();
    Id idLegalMeetingsRecordTypee = Schema.SObjectType.UAC_legal__c.getRecordTypeInfosByDeveloperName()
        .get(label.UAC_legalLegalMeetingsRecordType)
        .getRecordTypeId();    
    for( UAC_legal__c objLegal : newItems){
     
     if(objLegal.UAC_attorney__c!=null && (objLegal.RecordTypeId== idAttorneyOfRecordRecType ||objLegal.RecordTypeId== idLegalMeetingsRecordTypee )){
        lstUserIds.add(objLegal.UAC_attorney__c); 
        lstLegal.add(objLegal); 
     }
     
    }   
    if(!lstUserIds.isEmpty() && !lstLegal.isEmpty()){
        UAC_legalTriggerHelper.populateLawFirm (lstLegal,lstUserIds);
    }
            
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    List<Id> lstUserIds = new List<Id>();
    List<UAC_legal__c> lstLegal = new List<UAC_legal__c>();
    Id idAttorneyOfRecordRecType = Schema.SObjectType.UAC_legal__c.getRecordTypeInfosByDeveloperName()
           .get(label.UAC_legalAttorneyOfRecord)
           .getRecordTypeId();
    Id idLegalMeetingsRecordTypee = Schema.SObjectType.UAC_legal__c.getRecordTypeInfosByDeveloperName()
        .get(label.UAC_legalLegalMeetingsRecordType)
        .getRecordTypeId();
    Map<Id, UAC_legal__c> newItemsCasted = (Map<Id, UAC_legal__c>) newItems;
    Map<Id, UAC_legal__c> oldItemsCasted = (Map<Id, UAC_legal__c>) oldItems;
    for( UAC_legal__c objLegal : newItemsCasted.values()){
     UAC_legal__c objLegalOld= oldItemsCasted.get(objLegal.Id);
     if(objLegal.UAC_attorney__c != objLegalOld.UAC_attorney__c && objLegal.UAC_attorney__c!=null && (objLegal.RecordTypeId== idAttorneyOfRecordRecType ||objLegal.RecordTypeId== idLegalMeetingsRecordTypee )){
        lstUserIds.add(objLegal.UAC_attorney__c); 
        lstLegal.add(objLegal); 
     }
     
    }   
    if(!lstUserIds.isEmpty() && !lstLegal.isEmpty()){
        UAC_legalTriggerHelper.populateLawFirm (lstLegal,lstUserIds);
    }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
     
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}