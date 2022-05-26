/**
 * @File Name          : UC_visualChecklistService.cls
 * @Description        : Main helper class for visual checklist module
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_admissionAssessment
 * */
public
without sharing class UC_visualChecklistService {

  private
  static final String STR_TASK_OTHER = 'Other';
  private
  static final String STR_TASK_PRIORITY = 'High';
  private
  static final String STR_ADMISSION_CONFIG = 'Admission';
  private
  static final String STR_ADMISSION_PREDEFINED = 'Admission Assessment';
  private
  static final String STR_FIELD_API_RECORDTYPE = 'RecordTypeId';
  private
  static final String STR_FIELD_API_ID = 'Id';
  private
  static final String STR_QUERY_1 = 'SELECT Id, ';
  private
  static final String STR_QUERY_COMMA = ', ';
  private
  static final String STR_QUERY_UPDATE_3 = ' FROM ';
  private
  static final String STR_QUERY_UPDATE_4 = ' WHERE Id = :checklistItemId';
  private
  static final String STR_QUERY_READ_2 = ' FROM ';
  private
  static final String STR_QUERY_READ_3 = ' WHERE ';
  private
  static final String STR_QUERY_READ_4 = ' = :recordId';
  private
  static final String STR_ICON_STATUS_COMPLETE = 'Completed';
  private
  static final String STR_ICON_STATUS_OVERDUE = 'Overdue';
  private
  static final String STR_ICON_STATUS_NEW = 'Not Started';
  private
  static final String STR_ICON_STATUS_PROGRESS = 'In Progress';
  private
  static final String STR_PLACEMENT_RECURRING_TASK = 'Notice of Placement in a Restrictive Setting';
  private
  static final Set<String> SET_ASSESSMENT_RECURRING_TASK =
      new Set<String>{'UC Assessment for Risk', 'Individual Service Plan', 'UC Case Review'};
  private
  static final String STR_PROGRAM_TYPE_EIS = 'Emergency Intake Sites';
  private
  static final Integer INT_OFFSET = 30;
  private
  static final String STR_FIELD_API_TASK_DATE = 'ActivityDate';
  private
  static final String STR_FIELD_API_TASK_DATETIME = 'UAC_dateTime__c';
  private
  static final String STR_UC_STATUS_DISCHARGED = 'Discharged';

  /**
   * @description Future method for creating checklist items - called from case trigger
   * @author James Qian (Deloitte) | 9/20/21
   * @param Set<Id> recordIds, String strConfiguration
   **/
  @future public static void createAdmissionTasksForChecklistItems(
      Set<Id> recordIds, String strConfiguration) {
    createAdmissionTasks(recordIds, strConfiguration);
  }

  /**
   * @description Future method for creating checklist items - called from case trigger
   * @author James Qian (Deloitte) | 9/20/21
   * @param Set<Id> recordIds, String strConfiguration
   **/
  @testvisible private static void createAdmissionTasks(
      Set<Id> recordIds, String strConfiguration) {
    Set<String> setEISTypes = new Set<String>{'Individual Service Plan', 'UC Case Review'};
    Set<String> setSecureTypes = new Set<String>{'Notice of Placement in a Restrictive Setting',
        'Summary Notes Thirty Day Restrictive Placement Case Review',
        'Request for a Flores Bond Hearing notice'};
    Set<String> setProgramTypesSecure =
        new Set<String>{'Secure', 'Staff Secure', 'Residential Treatment Center'};
    Map<Id, Case> mapParentCases =
        new Map<Id, Case>([SELECT Id, UAC_programFacility__r.Type FROM Case WHERE Id IN:recordIds]);
    List<Task> listTasks = (List<Task>) createChecklistItems(recordIds, strConfiguration);
    for (Integer i = (listTasks.size() - 1); i >= 0; i--) {
      Task currentTask = listTasks[i];
      if (mapParentCases.containsKey(currentTask.WhatId)
          && mapParentCases.get(currentTask.WhatId).UAC_programFacility__r.Type != null) {
        String strProgramType = mapParentCases.get(currentTask.WhatId).UAC_programFacility__r.Type;
        if ((strProgramType == STR_PROGRAM_TYPE_EIS && setEISTypes.contains(currentTask.Subject))
            || (!setProgramTypesSecure.contains(strProgramType)
                && setSecureTypes.contains(currentTask.Subject))) {
          listTasks.remove(i);
        }
      }
      currentTask.ActivityDate = currentTask.UAC_datetime__c.Date();
      currentTask.Type = STR_TASK_OTHER;
      currentTask.Priority = STR_TASK_PRIORITY;
    }
    try {
      if (!listTasks.isEmpty()) {
        insert listTasks;
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '', 'Admission Task Creation', e.getStackTraceString() + ', record IDs: ' + recordIds.toString());
    }
  }

  /**
   * @description Queries assessments for discharged status check
   * @author James Qian (Deloitte) | 9/24/21
   * @param Set<Id> recordIds
   **/
  private
  static List<UAC_admissionAssessment__c> getAssessments(Set<Id> recordIds) {
    return [SELECT Id,
      UAC_entry__c,
      UAC_entry__r.UAC_programFacility__r.Type,
      UAC_uac__r.UAC_status__c,
      RecordType.DeveloperName FROM UAC_admissionAssessment__c WHERE Id IN:recordIds];
  }

  /**
   * @description Future method for updating checklist item
   * @author James Qian (Deloitte) | 9/20/21
   * @param Set<Id> setRecordIds, String strStatus
   **/
  @future public static void updateAdmissionTasks(Set<Id> setRecordIds, String strStatus) {
    // clang-format off
    Map<String, String> mapRecordTypeToSubject = new Map<String, String>{
      'UAC_assessment' => 'UC Assessment',
      'UAC_caseReview' => 'UC Case Review',
      'UAC_assessmentForRisk' => 'UC Assessment for Risk',
      'UAC_initialIntakesAssessment' => 'UC Initial Intakes Assessment',
      'UAC_individualServicePlan' => 'Individual Service Plan'
    };
    // clang-format on
    List<UAC_admissionAssessment__c> listAssessments = getAssessments(setRecordIds);
    if (listAssessments.isEmpty()) {
      return;
    }
    Set<Id> setEntryIds = new Set<Id>();
    for (UAC_admissionAssessment__c currentAssessment : listAssessments) {
      setEntryIds.add(currentAssessment.UAC_entry__c);
    }
    Map<String, Task> mapTasksToUpdate = new Map<String, Task>();
    for (Task currentTask : [
           SELECT Id,
           Subject,
           UAC_dateTime__c,
           ActivityDate,
           WhatId FROM Task WHERE WhatId IN:setEntryIds AND Status
                                         !=:STR_ICON_STATUS_COMPLETE AND UAC_typeOfInteraction__c
                                          =:STR_ADMISSION_PREDEFINED
         ]) {
      mapTasksToUpdate.put(currentTask.WhatId + ':' + currentTask.Subject, currentTask);
    }
    List<Task> listTaskToUpdate = new List<Task>();
    for (UAC_admissionAssessment__c currentAssessment : listAssessments) {
      String strSubject = mapRecordTypeToSubject.get(currentAssessment.RecordType.DeveloperName);
      String strKey = currentAssessment.UAC_entry__c + ':' + strSubject;
      if (mapTasksToUpdate.containsKey(strKey)) {
        Task taskToUpdate = mapTasksToUpdate.get(strKey);
        if (strStatus == STR_ICON_STATUS_COMPLETE
            && SET_ASSESSMENT_RECURRING_TASK.contains(strSubject)
            && currentAssessment.UAC_entry__r.UAC_programFacility__r.Type != STR_PROGRAM_TYPE_EIS
            && currentAssessment.UAC_uac__r.UAC_status__c != STR_UC_STATUS_DISCHARGED) {
          taskToUpdate.Status = STR_ICON_STATUS_NEW;
          taskToUpdate.UAC_dateTime__c = System.Now().addDays(INT_OFFSET);
          taskToUpdate.ActivityDate = System.Today().addDays(INT_OFFSET);
        } else {
          taskToUpdate.Status = strStatus;
        }
        listTaskToUpdate.add(taskToUpdate);
      }
    }
    try {
      if (!listTaskToUpdate.isEmpty()) {
        update listTaskToUpdate;
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '', 'Admission Task Update', e.getStackTraceString() + ', record IDs: ' + setRecordIds.toString());
    }
  }

  /**
   * @description Future method for creating checklist items - abstracted
   * @author James Qian (Deloitte) | 9/20/21
   * @param Set<Id> recordIds, String strConfiguration
   **/
  public
  static List<SObject> createChecklistItems(Set<Id> recordIds, String strConfiguration) {
    List<UC_visualChecklistConfiguration__mdt> listConfigurations = [SELECT UC_objectAPIName__c,
      UC_parentLookupAPIName__c,
      UC_recordTypeDeveloperName__c,
      UC_statusFieldAPIName__c,
      UC_subjectFieldAPIName__c,
      UC_taskDescription__c,
      UC_dueDateFieldAPIName__c,
      UC_completeStatuses__c,
      UC_defaultStatusValue__c,
      UC_hoursToOffset__c,
      UC_predefinedField1__c,
      UC_predefinedValue1__c FROM UC_visualChecklistConfiguration__mdt WHERE UC_configuration__c
      =:strConfiguration];
    if (listConfigurations.isEmpty()) {
      return null;
    }
    List<SObject> listObjectsToInsert = new List<SObject>();
    Map<String, Schema.SObjectType> mapSchema = Schema.getGlobalDescribe();
    for (Id currentRecordId : recordIds) {
      for (UC_visualChecklistConfiguration__mdt objConfig : listConfigurations) {
        Schema.SObjectType currentObjType = mapSchema.get(objConfig.UC_objectAPIName__c);
        SObject newRecord = currentObjType.newSObject();
        newRecord.put(objConfig.UC_parentLookupAPIName__c, currentRecordId);
        newRecord.put(objConfig.UC_statusFieldAPIName__c, objConfig.UC_defaultStatusValue__c);
        newRecord.put(objConfig.UC_subjectFieldAPIName__c, objConfig.UC_taskDescription__c);
        newRecord.put(objConfig.UC_dueDateFieldAPIName__c,
            System.Now().addHours(objConfig.UC_hoursToOffset__c.intvalue()));
        if (String.isNotBlank(objConfig.UC_recordTypeDeveloperName__c)) {
          newRecord.put(STR_FIELD_API_RECORDTYPE,
              currentObjType.getDescribe()
                  .getRecordTypeInfosByDeveloperName()
                  .get(objConfig.UC_recordTypeDeveloperName__c)
                  .getRecordTypeId());
        }
        if (String.isNotBlank(objConfig.UC_predefinedField1__c)) {
          newRecord.put(objConfig.UC_predefinedField1__c, objConfig.UC_predefinedValue1__c);
        }
        listObjectsToInsert.add(newRecord);
      }
    }
    return listObjectsToInsert;
  }

  /**
   * @description Aura method for updating a checklist item
   * @author James Qian (Deloitte) | 9/20/21
   * @param Id checklistItemId, String strSubject, String strConfiguration, String strNewStatus
   **/
  @AuraEnabled public static ChecklistResponse updateChecklistItem(
      Id recordId, Id checklistItemId, String strSubject, String strConfiguration, String strNewStatus) {
    ChecklistResponse newResponse = new ChecklistResponse();
    newResponse.success = false;
    try {
      List<UC_visualChecklistConfiguration__mdt> listConfig = [
        SELECT Id,
        UC_parentLookupAPIName__c,
        UC_subjectFieldAPIName__c,
        UC_statusFieldAPIName__c,
        UC_defaultStatusValue__c,
        UC_hoursRemainingFieldAPIName__c,
        UC_completeStatuses__c,
        UC_inProgressStatuses__c,
        UC_predefinedField1__c,
        UC_dueDateFieldAPIName__c,
        UC_objectAPIName__c FROM UC_visualChecklistConfiguration__mdt WHERE UC_configuration__c
        =:strConfiguration AND UC_taskDescription__c
        =:strSubject
      ];
      if (listConfig.isEmpty() || getRecordStatus(recordId, strConfiguration)) {
        return newResponse;
      }
      UC_visualChecklistConfiguration__mdt objConfig = listConfig[0];
      List<String> listFieldsToQuery = new List<String>(getFieldsToQuery(objConfig));
      if (strConfiguration == STR_ADMISSION_CONFIG) {
        listFieldsToQuery.add(STR_FIELD_API_TASK_DATE);
        listFieldsToQuery.add(STR_FIELD_API_TASK_DATETIME);
      }
      String strQuery = STR_QUERY_1 + String.join(listFieldsToQuery, STR_QUERY_COMMA)
          + STR_QUERY_READ_2 + objConfig.UC_objectAPIName__c + STR_QUERY_UPDATE_4;
      List<SObject> listChecklistItem = Database.query(String.escapeSingleQuotes(strQuery));
      if (listChecklistItem.isEmpty()) {
        return newResponse;
      }
      SObject queriedChecklistItem = listChecklistItem[0];
      if (queriedChecklistItem.get(objConfig.UC_statusFieldAPIName__c) != strNewStatus) {
        queriedChecklistItem.put(objConfig.UC_statusFieldAPIName__c, strNewStatus);
      }
      if (queriedChecklistItem.get(objConfig.UC_subjectFieldAPIName__c)
              == STR_PLACEMENT_RECURRING_TASK
          && strNewStatus == STR_ICON_STATUS_COMPLETE &&
          [SELECT Contact.UAC_status__c FROM Case WHERE Id =:recordId LIMIT 1][0]
                  .Contact.UAC_status__c
              != STR_UC_STATUS_DISCHARGED) {
        Datetime currentDatetime = System.Now();
        currentDatetime = currentDatetime.addDays(INT_OFFSET);
        queriedChecklistItem.put(objConfig.UC_dueDateFieldAPIName__c, currentDatetime);
        queriedChecklistItem.put(
            objConfig.UC_statusFieldAPIName__c, objConfig.UC_defaultStatusValue__c);
        queriedChecklistItem.put(STR_FIELD_API_TASK_DATE, currentDatetime.Date());
      }
      update queriedChecklistItem;
      newResponse.success = true;
      newResponse.message = getIconStatus(objConfig,
      queriedChecklistItem,
          (String) queriedChecklistItem.get(objConfig.UC_statusFieldAPIName__c));
    } catch (Exception e) {
      newResponse.message = e.getMessage();
    }
    return newResponse;
  }

  /**
   * @description Aura method for getting current record status for editability
   * @author James Qian (Deloitte) | 9/21/21
   * @param Id recordId, String strConfiguration
   **/
  @AuraEnabled public static Boolean getRecordStatus(Id recordId, String strConfiguration) {
    Boolean boolLockStatus = false;
    try {
      if (strConfiguration == STR_ADMISSION_CONFIG) {
        Case currentCase = [SELECT Id, Status FROM Case WHERE Id =:recordId];
        if (currentCase.Status == Label.UAC_caseStatusCompleted) {
          boolLockStatus = true;
        }
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'Admission getRecordStatus, Id: ' + recordId,
          e.getStackTraceString());
    }
    return boolLockStatus;
  }

  /**
   * @description Aura method for reading checklist items for a record
   * @author James Qian (Deloitte) | 9/20/21
   * @param Id recordId, String strConfiguration
   **/
  @AuraEnabled public static ChecklistResponse getChecklistItems(
      Id recordId, String strConfiguration) {
    ChecklistResponse newResponse = new ChecklistResponse();
    newResponse.success = false;
    Map<String, List<UC_visualChecklistConfiguration__mdt>> mapObjectToConfig =
        new Map<String, List<UC_visualChecklistConfiguration__mdt>>();
    for (UC_visualChecklistConfiguration__mdt currentConfig : [SELECT UC_objectAPIName__c,
           UC_parentLookupAPIName__c,
           UC_statusFieldAPIName__c,
           UC_subjectFieldAPIName__c,
           UC_taskDescription__c,
           UC_completeStatuses__c,
           UC_hoursRemainingFieldAPIName__c,
           UC_predefinedField1__c,
           UC_inProgressStatuses__c FROM UC_visualChecklistConfiguration__mdt WHERE
               UC_configuration__c =:strConfiguration]) {
      if (mapObjectToConfig.containsKey(currentConfig.UC_objectAPIName__c)) {
        mapObjectToConfig.get(currentConfig.UC_objectAPIName__c).add(currentConfig);
      } else {
        mapObjectToConfig.put(currentConfig.UC_objectAPIName__c,
            new List<UC_visualChecklistConfiguration__mdt>{currentConfig});
      }
    }
    Set<String> setObjects = mapObjectToConfig.keyset();
    newResponse.data = parseWrappers(strConfiguration,
        executeQueryAndConstructWrappers(setObjects, mapObjectToConfig, recordId));
    newResponse.success = true;
    return newResponse;
  }

  /**
   * @description Abstract method for running generic query
   * @author James Qian (Deloitte) | 9/20/21
   * @param Set<String> setObjectsToProcess,
      Map<String, List<UC_visualChecklistConfiguration__mdt>> mapObjectToConfig,
      Id recordId
   **/
  private
  static List<ChecklistWrapper> executeQueryAndConstructWrappers(Set<String> setObjectsToProcess,
      Map<String, List<UC_visualChecklistConfiguration__mdt>> mapObjectToConfig,
      Id recordId) {
    List<ChecklistWrapper> listWrappers = new List<ChecklistWrapper>();
    List<UC_visualChecklistConfiguration__mdt> listConfigs;
    String objectToProcess;
    String descriptionField;

    // Find configs to process for this run
    for (String firstObject : setObjectsToProcess) {
      listConfigs = mapObjectToConfig.get(firstObject);
      descriptionField = listConfigs[0].UC_subjectFieldAPIName__c;
      objectToProcess = firstObject;
      break;
    }
    String strQuery = constructQuery(listConfigs, objectToProcess);
    System.debug(strQuery);
    if (String.isBlank(strQuery)) {
      return listWrappers;
    }
    // Query records and process into wrappers
    listWrappers.addAll(constructWrappers(
        listConfigs, Database.query(String.escapeSingleQuotes(strQuery)), descriptionField));

    // Recursion control
    setObjectsToProcess.remove(objectToProcess);
    if (!setObjectsToProcess.isEmpty()) {
      listWrappers.addAll(
          executeQueryAndConstructWrappers(setObjectsToProcess, mapObjectToConfig, recordId));
    }
    return listWrappers;
  }

  /**
   * @description Method to parse and set individual values on checklist wrappers
   * @author James Qian (Deloitte) | 9/20/21
   * @param String strConfiguration, List<ChecklistWrapper> listWrappers
   **/
  private
  static List<ChecklistWrapper> parseWrappers(
      String strConfiguration, List<ChecklistWrapper> listWrappers) {
    for (ChecklistWrapper currentWrapper : listWrappers) {
      if (strConfiguration == STR_ADMISSION_CONFIG
          && currentWrapper.otherAttribute == STR_ADMISSION_PREDEFINED) {
        currentWrapper.editable = false;
      }
    }
    return listWrappers;
  }

  /**
   * @description Method to construct wrappers
   * @author James Qian (Deloitte) | 9/20/21
   * @param List<UC_visualChecklistConfiguration__mdt> listConfigs,
      List<SObject> listObjects,
      String strRecordSubjectField
   **/
  private
  static List<ChecklistWrapper> constructWrappers(
      List<UC_visualChecklistConfiguration__mdt> listConfigs,
      List<SObject> listObjects,
      String strRecordSubjectField) {
    List<ChecklistWrapper> listWrappers = new List<ChecklistWrapper>();
    Map<String, UC_visualChecklistConfiguration__mdt> mapConfigs =
        new Map<String, UC_visualChecklistConfiguration__mdt>();
    for (UC_visualChecklistConfiguration__mdt currentConfig : listConfigs) {
      mapConfigs.put(currentConfig.UC_taskDescription__c, currentConfig);
    }
    for (SObject currentRecord : listObjects) {
      if (!mapConfigs.containsKey((String) currentRecord.get(strRecordSubjectField))) {
        continue;
      }
      UC_visualChecklistConfiguration__mdt matchedConfig =
          mapConfigs.get((String) currentRecord.get(strRecordSubjectField));
      listWrappers.add(getChecklistItem(matchedConfig, currentRecord));
    }
    return listWrappers;
  }

  /**
   * @description General method to get checklist items for specific record
   * @author James Qian (Deloitte) | 9/20/21
   * @param UC_visualChecklistConfiguration__mdt matchedConfig, SObject currentRecord
   **/
  private
  static ChecklistWrapper getChecklistItem(
      UC_visualChecklistConfiguration__mdt matchedConfig, SObject currentRecord) {
    String strStatusActual = (String) currentRecord.get(matchedConfig.UC_statusFieldAPIName__c);
    String strIconStatus = getIconStatus(matchedConfig, currentRecord, strStatusActual);
    String strOtherAttribute = null;
    if (String.isNotBlank(matchedConfig.UC_predefinedField1__c)) {
      strOtherAttribute = (String) currentRecord.get(matchedConfig.UC_predefinedField1__c);
    }
    return new ChecklistWrapper(strStatusActual,
        strIconStatus,
        matchedConfig.UC_taskDescription__c,
        (Decimal) currentRecord.get(matchedConfig.UC_hoursRemainingFieldAPIName__c),
        (Id) currentRecord.get(STR_FIELD_API_ID),
        strOtherAttribute);
  }

  private
  static String getIconStatus(UC_visualChecklistConfiguration__mdt matchedConfig,
      SObject currentRecord,
      String strStatusActual) {
    if (matchedConfig.UC_completeStatuses__c.split(';').contains(strStatusActual)) {
      return STR_ICON_STATUS_COMPLETE;
    } else if ((Decimal) currentRecord.get(matchedConfig.UC_hoursRemainingFieldAPIName__c) <= 0) {
      return STR_ICON_STATUS_OVERDUE;
    } else if (matchedConfig.UC_inProgressStatuses__c.split(';').contains(strStatusActual)) {
      return STR_ICON_STATUS_PROGRESS;
    }
    return STR_ICON_STATUS_NEW;
  }

  /**
   * @description General method to build query
   * @author James Qian (Deloitte) | 9/20/21
   * @param List<UC_visualChecklistConfiguration__mdt> listConfigs, String strObjectName
   **/
  private
  static String constructQuery(
      List<UC_visualChecklistConfiguration__mdt> listConfigs, String strObjectName) {
    Set<String> setFieldsToQuery = new Set<String>();
    String strLookupName;
    for (UC_visualChecklistConfiguration__mdt currentConfig : listConfigs) {
      if (String.isBlank(strLookupName)) {
        strLookupName = currentConfig.UC_parentLookupAPIName__c;
      }
      setFieldsToQuery.addAll(getFieldsToQuery(currentConfig));
    }
    if (setFieldsToQuery.isEmpty() || String.isBlank(strObjectName)
        || String.isBlank(strLookupName)) {
      return '';
    }
    return STR_QUERY_1 + String.join(new List<String>(setFieldsToQuery), STR_QUERY_COMMA)
        + STR_QUERY_READ_2 + strObjectName + STR_QUERY_READ_3 + strLookupName + STR_QUERY_READ_4;
  }

  /**
   * @description Method to dynamically get fields for query
   * @author James Qian (Deloitte) | 9/20/21
   * @param UC_visualChecklistConfiguration__mdt currentConfig
   **/
  private
  static Set<String> getFieldsToQuery(UC_visualChecklistConfiguration__mdt currentConfig) {
    Set<String> setFields = new Set<String>();
    setFields.add(currentConfig.UC_parentLookupAPIName__c);
    setFields.add(currentConfig.UC_statusFieldAPIName__c);
    setFields.add(currentConfig.UC_subjectFieldAPIName__c);
    setFields.add(currentConfig.UC_hoursRemainingFieldAPIName__c);
    setFields.add(currentConfig.UC_predefinedField1__c);
    return setFields;
  }

  /**
   * @description Wrapper class for response
   * @author James Qian (Deloitte) | 9/20/21
   **/
  public
  class ChecklistResponse {
    @AuraEnabled public Boolean success;
    @AuraEnabled public String message;
    @AuraEnabled public List<ChecklistWrapper> data;
  }

  /**
   * @description Wrapper class for response
   * @author James Qian (Deloitte) | 9/20/21
   **/
  public class ChecklistWrapper {
    @AuraEnabled public String status;
    @AuraEnabled public String icon;
    @AuraEnabled public String subject;
    @AuraEnabled public Decimal hoursRemaining;
    @AuraEnabled public Id checklistId;
    @AuraEnabled public String otherAttribute;
    @AuraEnabled public Boolean editable;
    /**
     * @description Constructor for wrapper class
     * @author James Qian (Deloitte) | 9/20/21
     **/
    public
    ChecklistWrapper(String strStatus,
        String strIcon,
        String strSubject,
        Decimal intHoursRemaining,
        Id idRecord,
        String strOtherAttribute) {
      status = strStatus;
      icon = strIcon;
      subject = strSubject;
      hoursRemaining = intHoursRemaining;
      checklistId = idRecord;
      otherAttribute = strOtherAttribute;
      editable = true;
    }
  }
}