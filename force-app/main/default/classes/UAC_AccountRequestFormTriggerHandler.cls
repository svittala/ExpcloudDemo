/**
 * @File Name          : UAC_AccountRequestFormTriggerHandler.cls
 * @Description        : Handles all Account Request Form trigger traffic
 * @Author             : Abhisek Pati (Deloitte)
 * @Group              : UAC_accountRequestFormTrigger
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 * 1.0      01/15/2021   Abhisek Pati (Deloitte)    Initial Implementation.
 **/
public
class UAC_AccountRequestFormTriggerHandler implements UAC_ITriggerHandler {

  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypes =
      Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosById();
  private
  static final String strARFServiceCloudRecordType = Label.UC_serviceCloudRecordTypeARF;

  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAccountRequestFormTrigger__c;
  }

  /**
   * @description Method to handle before insert trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param lstNewARFS List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_AccountRequestForm__c> lstNewARFS) {
    List<UAC_AccountRequestForm__c> lstOfServiceCloudRecords =
        new List<UAC_AccountRequestForm__c>();
    for (UAC_AccountRequestForm__c objARFCurrent : lstNewARFS) {
      String strRecordTypeDevName =
          mapRecordTypes.get(objARFCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strARFServiceCloudRecordType) {
        lstOfServiceCloudRecords.add(objARFCurrent);
      }
    }

    if (!lstOfServiceCloudRecords.isEmpty()) {
      UAC_accountRequestFormTriggerHelper.setUserType(lstOfServiceCloudRecords);
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    List<UAC_AccountRequestForm__c> lstOfServiceCloudRecords = new List<UAC_AccountRequestForm__c>();    
    Map<Id, UAC_AccountRequestForm__c> mapARFNewCasted = (Map<Id, UAC_AccountRequestForm__c>) newItems;
    Map<Id, UAC_AccountRequestForm__c> mapARFOldCasted = (Map<Id, UAC_AccountRequestForm__c>) oldItems;
    Map<Id, UAC_AccountRequestForm__c> mapNewExistingUserSvcCloud = new Map<Id, UAC_AccountRequestForm__c>();
    for (UAC_AccountRequestForm__c objARFCurrent : mapARFNewCasted.values()) {
      String strRecordTypeDevName = mapRecordTypes.get(objARFCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strARFServiceCloudRecordType && objARFCurrent.User_Email__c != mapARFOldCasted.get(objARFCurrent.Id).User_Email__c) {
        lstOfServiceCloudRecords.add(objARFCurrent);
      }
      //Added changes for 5598 for Existing users - update status to Initale form Completion request
      if (strRecordTypeDevName == strARFServiceCloudRecordType && objARFCurrent.UC_existingUser__c) {
          mapNewExistingUserSvcCloud.put(objARFCurrent.Id, objARFCurrent);
      }
    }
        
    if(!lstOfServiceCloudRecords.isEmpty()){
              UAC_accountRequestFormTriggerHelper.setUserType(lstOfServiceCloudRecords);
    }
    //Added changes for 5598 for Existing users - update status to Initale form Completion request
    if(!(mapNewExistingUserSvcCloud.values().isEmpty())){
      UAC_accountRequestFormTriggerHelper.setStatusInitiateFormForExistingSvcUsers(mapNewExistingUserSvcCloud,(Map<Id, UAC_AccountRequestForm__c>)oldItems);        
    }
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  	Map<Id, UAC_AccountRequestForm__c> mapNewExistingUserSvcCloud = new Map<Id, UAC_AccountRequestForm__c>();
    
    UAC_accountRequestFormTriggerHelper.createUserrecords((Map<Id, UAC_AccountRequestForm__c>) newItems, (Map<Id, UAC_AccountRequestForm__c>) oldItems);
     
    for (UAC_AccountRequestForm__c objARFNew : (List<UAC_AccountRequestForm__c>)newItems.values()) {
       String strRecordTypeDevName = mapRecordTypes.get(objARFNew.RecordTypeId).getDeveloperName();
       //Added changes for 5598 for Existing users - to update User Record ORR Auth User when Compliance form uploaded
       if (strRecordTypeDevName == strARFServiceCloudRecordType && objARFNew.UC_existingUser__c) {
         mapNewExistingUserSvcCloud.put(objARFNew.Id, objARFNew);
       }
    }

    //Added changes for 5598 for Existing users - to update User Record ORR Auth User when Compliance form uploaded
    if(!(mapNewExistingUserSvcCloud.values().isEmpty())){
          UAC_accountRequestFormTriggerHelper.updUsrORRAuthFlag(mapNewExistingUserSvcCloud,(Map<Id, UAC_AccountRequestForm__c>)oldItems);        
    }

  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Sudeep Chintala (Deloitte)
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}