/**
 * @File Name          : UAC_TestTriggerHandler.cls
 * @Description        : Handles all Medical Test trigger traffic
 * @Author             : Ram Josyer (Creative Sys)
 * @Group              : UAC_triggerHelper
 * @Test Class         : 
 * @Last Modified By   : Chase Oden (Deloitte)
 * @Last Modified On   : 08-09-2021
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    11/24/2020   Ram Josyer (Creative Sys)   Initial Implementation.
 * 1.1    07/06/2021   Chase Oden (Deloitte)       ORRUAC-6079 Added Exclusion logic.
 * 1.2    08/09/2021   Chase Oden (Deloitte)       ORRUAC-6435 Increasing beforeInsert allowed record types.
 **/
public
inherited sharing class UAC_TestTriggerHandler implements UAC_ITriggerHandler {

  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassTestTrigger__c;
  }

  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_test';

  /**
   * @description Method to handle before insert trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param lstNewMedicalTest List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_Test__c> lstNewMedicalTest) {
    List<UAC_Test__c> lstEmailNotifyMedicalTest = new List<UAC_Test__c>();
    for (UAC_Test__c testObj : lstNewMedicalTest) {
      if (
          (testObj.RecordTypeId
          == UAC_TestObjectUtil.getRecordTypeIdByDeveloperName(System.label.UAC_testRecTypeImagingStudy))
          ||
          (testObj.RecordTypeId
          == UAC_TestObjectUtil.getRecordTypeIdByDeveloperName(System.label.UAC_testRecTypeBacteriologicalResults))
          )
        {
          lstEmailNotifyMedicalTest.add(testObj);
      }    
    }
    if (lstEmailNotifyMedicalTest.size() > 0) {
      UAC_TestTriggerHelper.populateMedicalTeamEmail(lstEmailNotifyMedicalTest);
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
        newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      UAC_TestTriggerHelper.populateMedicalTeamEmail(newItems.values());
    }
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
        oldItems, oldItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
        newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author RJ (CreativeSys) 11/24/20
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}