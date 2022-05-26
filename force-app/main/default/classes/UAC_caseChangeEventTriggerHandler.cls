/**
 * @File Name         : UAC_caseChangeEventTriggerHandler.cls
 * @Description       : Trigger handler for handling trigger traffic on CaseChangeEvent
 * @Group             : UAC_caseChangeEventTrigger
 * @Test Class        : UAC_caseChangeEventTriggerHelperTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-29-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-28-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
inherited sharing class UAC_caseChangeEventTriggerHandler implements UAC_ITriggerHandler {

  /**
   * @description Method to check if trigger handler should be disabled.
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @return Boolean
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassCaseChangeEventTrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param lstNew List of new records
   * @return void
   **/
  public
  void beforeInsert(List<SObject> lstNew) {
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param mapNew Map of new records
   * @param mapOld Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param mapOld Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> mapOld) {
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param mapNew Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> mapNew) {
    Map<Id, CaseChangeEvent> mapCaseChangeEvent = (Map<Id, CaseChangeEvent>) mapNew;
    Set<String> setCaseIdForEntryTeamMapping = new Set<String>();
    for (CaseChangeEvent objCaseChangeEvent : mapCaseChangeEvent.values()) {
      EventBus.ChangeEventHeader objChangeEventHeader = objCaseChangeEvent.ChangeEventHeader;
      setCaseIdForEntryTeamMapping.addAll(objChangeEventHeader.getRecordIds());
    }
    if (!setCaseIdForEntryTeamMapping.isEmpty()) {
      UAC_caseChangeEventTriggerHelper.handleEntryTeamMapping(setCaseIdForEntryTeamMapping);
    }
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param mapNew Map of new records
   * @param mapOld Map of old records
   **/
  public
  void afterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param mapOld Map of old records
   **/
  public
  void afterDelete(Map<Id, SObject> mapOld) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Sachet Khanal (Deloitte) | 10-28-2020
   * @param mapOld Map of old records
   **/
  public
  void afterUndelete(Map<Id, SObject> mapOld) {
  }
}