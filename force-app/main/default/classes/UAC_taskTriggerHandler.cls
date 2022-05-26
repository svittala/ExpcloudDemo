/**
 * @File Name          : UAC_taskTriggerHandler.cls
 * @Description        : Handles all Task trigger traffic
 * @Author             : Issam Awwad (Deloitte)
 * @Last Modified By   : Issam Awwad (Deloitte)
 * @Last Modified On   : 8/5/2020, 12:50:03 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    8/5/2020   	 Issam Awwad (Deloitte)     Initial Implementation.
 * 2.0    8/6/2020   	 Rahul Roy (Deloitte)       ORRUAC-1548 updates.
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)	Adding bypass logic.
 * 2.2    8/04/2021      Nithin Malla (Deloitte)    ORRUAC-6037 Added Task Exclusion logic.
 **/
public
without sharing class UAC_taskTriggerHandler implements UAC_ITriggerHandler {

/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassTaskTrigger__c;
  }
  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypes =
      Schema.SObjectType.Task.getRecordTypeInfosById();
  private
  static final String strTaskRecordTypeTransfer = Label.UAC_taskRecordTypeTransfer;
  private
  static final String strTaskRecordTypeHSAddendum = Label.UAC_taskRecordTypeHSAddendum;
  private
  static final String strTaskRecordTypeCallLog = Label.UAC_taskTypeCallLog;
  private
  static final String strTaskRecordTypeHelpdesk = Label.UC_taskTypeHelpdesk;
  private
  static final String strCustomPermissionAdmin = Label.UAC_customPermissionAdmin;
  private
  static final String strRestrictTaskDeleteMsg = Label.UAC_restrictTaskDeleteMsg;
    
  public
  static final Boolean runTrigger = true;

  /**
   * @description Method to handle before insert trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param lstNewTasks List of new records
   * @return void
   **/
  public
  void beforeInsert(List<Task> lstNewTasks) {
    Map<Id, Task> mapHSAddendumTask = new Map<Id, Task>();
        
    // Populate collections
    for (Task taskCurrent : lstNewTasks) {
      if (taskCurrent.RecordTypeId == null) {
        continue;
      }
      String strRecordTypeDevName = mapRecordTypes.get(taskCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strTaskRecordTypeHSAddendum) {
        mapHSAddendumTask.put(taskCurrent.Id, taskCurrent);
      }
    }
      
    // Pass to helper methods
    if (!mapHSAddendumTask.isEmpty()) {
        UAC_taskTriggerHelper.processHSAddendumTask(mapHSAddendumTask, null);  
    }   
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    // Recursion check
    if (!runTrigger) {
      return;
    }
      
    UC_exclusionLogicService.getInstance().runExclusionsForTask((Map<Id, Task>)newItems);  
      
    Map<Id, Task> mapTaskNewCasted = (Map<Id, Task>) newItems;
  	Map<Id, Task> mapTaskOldCasted = (Map<Id, Task>) oldItems;
    Map<Id, Task> mapTaskTransfer = new Map<Id, Task>();
    Map<Id, Task> mapTaskTransfer2 = new Map<Id, Task>();
      
    // Populate collections
    for (Task taskCurrent : mapTaskNewCasted.values()) {
      if (taskCurrent.RecordTypeId == null) {
        continue;
      }
      String strRecordTypeDevName = mapRecordTypes.get(taskCurrent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strTaskRecordTypeTransfer) {
        mapTaskTransfer.put(taskCurrent.Id, taskCurrent);
      } 
      if (strRecordTypeDevName == strTaskRecordTypeHSAddendum) {
        mapTaskTransfer2.put(taskCurrent.Id, taskCurrent);
      }
    }
      
    // Pass to helper methods
    if (!mapTaskTransfer.isEmpty()) {
      UAC_taskTriggerHelper.processTransferTask(mapTaskTransfer, mapTaskOldCasted);
      UAC_taskTriggerHelper.updateTaskOwner(mapTaskTransfer, mapTaskOldCasted);  // ORRUAC 2328
    }     
    if (!mapTaskTransfer2.isEmpty()) {
        UAC_taskTriggerHelper.processHSAddendumTask(mapTaskTransfer2, mapTaskOldCasted);  
    }   
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @author Chaitanya Nandamuri (Deloitte) | 10/12/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
      
    UC_exclusionLogicService.getInstance().runExclusionsForTask((Map<Id, Task>)oldItems);
    
    for (Task taskCurrent : (List<task>) oldItems.values()) {
      if (taskCurrent.RecordTypeId == null) {
        continue;
      }
      if ((mapRecordTypes.get(taskCurrent.RecordTypeId).getDeveloperName()
                  == strTaskRecordTypeCallLog
              || mapRecordTypes.get(taskCurrent.RecordTypeId).getDeveloperName()
                  == strTaskRecordTypeHelpdesk)
          && !FeatureManagement.checkPermission(strCustomPermissionAdmin)) {
        taskCurrent.addError(strRestrictTaskDeleteMsg);
      }
    }
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
   UC_exclusionLogicService.getInstance().runExclusionsForTask((Map<Id, Task>)newItems);  
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    
    
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Issam Awwad (Deloitte) | 8/5/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}