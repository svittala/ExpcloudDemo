/**
 * @File Name          : UAC_batchNotifyAdmissionAssessment.cls
 * @Description        : Batch to generate tasks for admission assessments
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_admissionAssessment
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/14/2020   James Qian (Deloitte)     Initial Implementation.
 * 1.1    7/15/2020   Chaitanya Nandauri (Deloitte) Create Task for Case Review
 * 1.2    7/17/2020   Issam Awwad (Deloitte)     Create Task for Risk Assessment
 **/
global without sharing class UAC_batchNotifyAdmissionAssessment implements
    Database.Batchable<sObject> {
  private
  Date dateLowOffset;
  private
  Date dateHighOffset;
  private
  Id idISPRecordType;
  private
  Id idReviewRecordType;
  private
  Id idRiskRecordType;
  private
  Id idInitialIntakesAssessmentRecordType;
  private
  Set<Id> setRecordTypeIds;
  private
  static final String strInitialIntakesAssessmentRecordType =
      Label.UAC_initialIntakesAssessmentRecordType;
  private
  Id idTaskRecordType;
  // Chaitanya Deloitte
  private
  static final Set<String> setRecordTypesForAssessmentNotify =
      new Set<String>{Label.UAC_assessmentRecordTypeISP, Label.UAC_assessmentRecordTypeReview};
  /**
   * @description Constructor that sets class variables
   * @author James Qian (Deloitte) | 7/15/2020
   * @return void
   **/
  global UAC_batchNotifyAdmissionAssessment() {
    Map<String, Schema.RecordTypeInfo> mapRecordTypes =
        Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName();
    setRecordTypeIds = new Set<Id>();    
    setRecordTypeIds.add(mapRecordTypes.get(Label.UAC_assessmentRecordTypeISP).getRecordTypeId());
    setRecordTypeIds.add(
        mapRecordTypes.get(Label.UAC_assessmentRecordTypeReview).getRecordTypeId());
    setRecordTypeIds.add(mapRecordTypes.get(Label.UAC_assessmentRecordTypeRisk).getRecordTypeId());
    idTaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                           .get(Label.UAC_taskRecordTypeAdmission)
                           .getRecordTypeId();
    dateLowOffset = System.Today().addDays(-1 * Integer.valueOf(Label.UAC_assessmentOffsetShort));
    dateHighOffset = System.Today().addDays(-1 * Integer.valueOf(Label.UAC_assessmentOffsetLong));
    idISPRecordType = mapRecordTypes.get(Label.UAC_assessmentRecordTypeISP).getRecordTypeId();
    idReviewRecordType =   mapRecordTypes.get(Label.UAC_assessmentRecordTypeReview).getRecordTypeId();
    idRiskRecordType = mapRecordTypes.get(Label.UAC_assessmentRecordTypeReview).getRecordTypeId();
    idInitialIntakesAssessmentRecordType = mapRecordTypes.get(strInitialIntakesAssessmentRecordType).getRecordTypeId();
  }

  /**
   * @description Start method that sets query from custom labels.
   * @author James Qian (Deloitte) | 7/15/2020
   * @param Database.BatchableContext
   * @return Database.QueryLocator
   **/
  global Database.QueryLocator start(Database.BatchableContext bc) {
    String strQuery = Label.UAC_assessmentTaskBaseQuery + ' RecordTypeId In :setRecordTypeIds ';
    strQuery += Label.UAC_assessmentTaskQueryShort + ' ';
    // system.debug('q1 ' + strQuery);
    // system.debug('q2 ' + Label.UAC_assessmentTaskQueryLong);
    strQuery += Label.UAC_assessmentTaskQueryLong;
    return Database.getQueryLocator(strQuery);
  }

  /**
   * @description Execute method, called once per batch
   * @author James Qian (Deloitte) | 7/15/2020
   * @param Database.BatchableContext
   * @param List<UAC_admissionAssessment__c>
   **/
  global void execute(Database.BatchableContext bc, List<UAC_admissionAssessment__c> scope) {
    this.createTasks(scope);
  }

  /**
   * @description Main method called from execute. Inserts Tasks based on parent record data.
   * @author James Qian (Deloitte) | 7/15/2020
   * @param List<UAC_admissionAssessment__c>
   **/
  private
  void createTasks(List<UAC_admissionAssessment__c> scope) {
    List<Task> listTasksToInsert = new List<Task>();
    for (UAC_admissionAssessment__c assessmentCurrent : scope) {
      if ((assessmentCurrent.RecordTypeId == idISPRecordType
              || assessmentCurrent.RecordTypeId == idReviewRecordType)
          && String.isNotBlank(assessmentCurrent.UAC_caseManagerLookup__c)) {
             
              string strTaskSubject;
              if (assessmentCurrent.RecordTypeId == idISPRecordType ){
                  strTaskSubject = Label.UAC_assessmentTaskSubjectISP + assessmentCurrent.UAC_aNum__c;
              } else if (assessmentCurrent.RecordTypeId == idReviewRecordType ){
                   strTaskSubject = Label.UAC_assessmentTaskSubjectReview + assessmentCurrent.UAC_aNum__c;
              } else if (assessmentCurrent.RecordTypeId == idRiskRecordType) {
                strTaskSubject = Label.UAC_assessmentRecordTypeRisk + assessmentCurrent.UAC_aNum__c;
              } else if (assessmentCurrent.RecordTypeId == idInitialIntakesAssessmentRecordType ){
                strTaskSubject = strInitialIntakesAssessmentRecordType + assessmentCurrent.UAC_aNum__c;
              }  
           
        listTasksToInsert.add(
            new Task(Subject = strTaskSubject,
                WhatId = assessmentCurrent.UAC_entry__c,
                WhoId = assessmentCurrent.UAC_uac__c,
                OwnerId = assessmentCurrent.UAC_caseManagerLookup__c,
                ActivityDate = System.Today(),
                RecordTypeId = idTaskRecordType));
      }
    }
    if (!listTasksToInsert.isEmpty()) {
      insert listTasksToInsert;
    }
  }

  /**
   * @description Finish method - not used for this batch.
   * @author James Qian (Deloitte) | 7/15/2020
   * @param Database.BatchableContext
   **/
  global void finish(Database.BatchableContext bc) {
  }
}