/**
 * @File Name          : UAC_referralAssessmentTriggerHandler.cls
 * @Description        : Handles all Referral Assessment trigger traffic
 * @Author             : Rahul Roy (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 ------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Rahul Roy (Deloitte)    08/04/2020   Initial Implementation.
Sudeep Chintala(Deloitte) 11/03/2020 Adding Bypass Logic
 **/

public
with sharing class UAC_referralAssessmentTriggerHandler implements UAC_ITriggerHandler {
/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassreferralAssessmenttrigger__c;
  }
  private
  static final String strReferralAssessmentRecordTypeHSAssessment =
      Label.UAC_referralAssessmentRecordTypeHSAssessment;
  private 
  static final String strReferralAssessmentRecordTypePRSEvent =
      Label.UAC_prsEventRecordType;      
  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypes =
      Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosById();
  private
  static Boolean boolRun = true;
  private static final String STR_EX_LOGIC_MDT_NAME_HSREFASSESS = 'UC_hsPrsRefAssessment';
  /**
   * @description Method to handle before insert trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_referralAssessment__c> newItems) {
    boolRun = false;
    UAC_referralAssessmentTriggerHelper.populateUACAndSponsor(newItems);
    boolRun = true;
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param newItems Map of new records
   * @return void
   * modified 07202021 - Added Exclusion logic (runExclusions method )per ORRUAC - 6056 in after insert , before update & before Delete
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    // Exclusion logic check - ORRUAC 6056
    if(UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_EX_LOGIC_MDT_NAME_HSREFASSESS)){
      Map<Id, UAC_referralAssessment__c> newItemsCasted = (Map<Id, UAC_referralAssessment__c>) newItems;
      UAC_referralAssessmentTriggerHelper.populateHouseHoldMember(newItemsCasted.values());
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (!boolRun) {
      return;
    }
    // Exclusion logic check - ORRUAC 6056
    if(UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_EX_LOGIC_MDT_NAME_HSREFASSESS)){
      Map<Id, UAC_referralAssessment__c> newItemsCasted = (Map<Id, UAC_referralAssessment__c>) newItems;
      Map<Id, UAC_referralAssessment__c> oldItemsCasted = (Map<Id, UAC_referralAssessment__c>) oldItems;
      UAC_referralAssessmentTriggerHelper.populateDateFields(newItemsCasted, oldItemsCasted);
    }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   * modified 07202021 - Added Exclusion logic (runExclusions method )per ORRUAC - 6056 in after insert , before update & before Delete
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      UAC_referralAssessmentTriggerHelper.hsAssessmentTaskCreation(newItems, oldItems);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param oldItems Map of old records
   * @return void
   * modified 07202021 - Added Exclusion logic (runExclusions method )per ORRUAC - 6056 in after insert , before update & before Delete
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    // Exclusion logic check - ORRUAC 6056
    if(UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), STR_EX_LOGIC_MDT_NAME_HSREFASSESS)){
      Map<Id,UAC_referralAssessment__c> mapHSAssessment= New Map<Id,UAC_referralAssessment__c>();
      Map<Id,UAC_referralAssessment__c> mapPRSEventAssessment= New Map<Id,UAC_referralAssessment__c>();
      Map<Id, UAC_referralAssessment__c> mapHSAssessmentOldCasted = (Map<Id, UAC_referralAssessment__c>) oldItems;
      List<UAC_referralAssessment__c> lstHSAssessment = New List<UAC_referralAssessment__c>();
      List<UAC_referralAssessment__c> lstPRSAssessment = New List<UAC_referralAssessment__c>();
      for (UAC_referralAssessment__c hsAssessmentCurrent : mapHSAssessmentOldCasted.values()) {
        String strRecordTypeDevName = mapRecordTypes.get(hsAssessmentCurrent.RecordTypeId).getDeveloperName();
        if (strRecordTypeDevName == strReferralAssessmentRecordTypeHSAssessment) {
          mapHSAssessment.put(hsAssessmentCurrent.Id, hsAssessmentCurrent);
          if(hsAssessmentCurrent.UAC_status__c != 'Draft'){
            lstHSAssessment.add(hsAssessmentCurrent);
          }
        } 
        if (strRecordTypeDevName == strReferralAssessmentRecordTypePRSEvent) {
          mapPRSEventAssessment.put(hsAssessmentCurrent.Id, hsAssessmentCurrent);
          if(hsAssessmentCurrent.UAC_status__c != 'Draft'){
            lstPRSAssessment.add(hsAssessmentCurrent);
          }
        }
      }
      system.debug(lstPRSAssessment);
      system.debug(mapPRSEventAssessment);
      if(!mapHSAssessment.isEmpty() && !lstHSAssessment.isEmpty()){
        UAC_referralAssessmentTriggerHelper.validateHSAssessmentDeletion(mapHSAssessment, lstHSAssessment);
      }
      if(!mapPRSEventAssessment.isEmpty() && !lstPRSAssessment.isEmpty()){
        UAC_referralAssessmentTriggerHelper.validatePRSAssessmentDeletion(mapPRSEventAssessment, lstPRSAssessment);
      }
    }
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}