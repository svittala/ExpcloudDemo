/**
 *___________________________________________________
 * @Name: UAC_apprehendedRelationshipHandler
 * @Author: Piyush Pranav
 * @Created Date: May 08, 2020
 * @Used_By: UAC PATH
 *___________________________________________________
 * @Description: Handles all Apprehended Relationship trigger traffic
 *___________________________________________________
 * @Changes:
 *
 **/
public
without sharing class UAC_apprehendedRelationshipHandler implements UAC_ITriggerHandler {
  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_apprehendedRelationshipUpdateDelete';
  private
  static final Id idUACApprRecordType =
      Schema.SObjectType.UAC_apprehendedRelationship__c.getRecordTypeInfosByDeveloperName()
          .get('UAC_apprehendedUAC')
          .getRecordTypeId();

 /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassApprehendedRelationshipTrigger__c;
  }

  /*  @author       Piyush Pranav
      @description  Before Insert
      @param        N/A
      @return       void
  */
  public
  void BeforeInsert(List<SObject> lstNewItems) {
    List<UAC_apprehendedRelationship__c> lstTriggerNew =
        (List<UAC_apprehendedRelationship__c>) lstNewItems;
    if (UC_exclusionLogicService.getInstance().runExclusionsForRelationshipOnInsert(
            lstTriggerNew)) {
      List<UAC_apprehendedRelationship__c> lstUACNew = new List<UAC_apprehendedRelationship__c>();
      for (UAC_apprehendedRelationship__c lstApprRel : lstTriggerNew) {
        if (lstApprRel.RecordTypeId == idUACApprRecordType) {
          lstUACNew.add(lstApprRel);
        }
      }
      if (lstUACNew.size() > 0) {
        UAC_apprehendedRelationshipHelper.setPairID(lstUACNew);
        UAC_apprehendedRelationshipHelper.reciprocalCreation(lstUACNew);
      }
    }
  }

  /*  @author       Piyush Pranav
      @description  Before Update
      @param        N/A
      @return       void
  */
  public
  void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            mapNewItems, mapNewItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      UAC_apprehendedRelationshipHelper.setReferralLookups(mapNewItems, mapOldItems);
      UAC_apprehendedRelationshipHelper.RelationshipUpdates(mapNewItems, mapOldItems);
    }
  }

  /*  @author       Piyush Pranav
      @description  Before Delete
      @param        N/A
      @return       void
  */
  public
  void BeforeDelete(Map<Id, SObject> mapOldItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            mapOldItems, mapOldItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      Map<Id, UAC_apprehendedRelationship__c> mapOldAppItems =
          (Map<Id, UAC_apprehendedRelationship__c>) mapOldItems;
      UAC_apprehendedRelationshipHelper.reciprocalDeletion(mapOldAppItems);
    }
  }

  /*  @author       Piyush Pranav
      @description  After Insert
      @param        N/A
      @return       void
  */
  public
  void AfterInsert(Map<Id, SObject> mapNewItems) {
  }

  /*  @author       Piyush Pranav
      @description  After Update
      @param        N/A
      @return       void
  */
  public
  void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
  }

  /*  @author       Piyush Pranav
      @description  After Delete
      @param        N/A
      @return       void
  */
  public
  void AfterDelete(Map<Id, SObject> mapOldItems) {
  }

  /*  @author       Piyush Pranav
      @description  After Undelete
      @param        N/A
      @return       void
  */
  public
  void AfterUndelete(Map<Id, SObject> mapOldItems) {
  }
}