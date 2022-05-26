/**
 * @File Name          : UAC_diagnosisTriggerHelper.cls
 * @Description        : Helper method for UAC_diagnosisTriggerHandler
 * @Author             : Anupreeta Chakraborty (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_diagnosisTriggerHelperTest
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 10-30-2020
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    6/19/2020   Anupreeta Chakraborty (Deloitte)   Initial Implementation.
 * 1.1    9/19/2020   Vijayakumar Pethanan (Deloitte)    #2257,#1794 story
 * 1.2    9/22/2020   Abhisek Pati (Deloitte)            Create Diagnosis Outcome for 2478
 * 1.3    10/23/2020  Ranjith Kumar (AI-Vets)     #2982 story - Mental Health Task Creation
 * 1.4    11/4/2020   Abhisek Pati (Deloitte)     #3647 story - Added Contact Id to Task creation.
 * 1.5    11/23/2020  Abhisek Pati (Deloitte)     #4491 story - Added Program Id to Exposure Event.
 * 1.6    6/9/2021    Abhisek Pati (Deloitte)     #5867 story - Renamed UAC to UC Exposure Event.
 **/
public
without sharing class UAC_diagnosisTriggerHelper {

  static final String STRING_ORR_CUSTODY_RECORD_TYPE =
      Label.UAC_expEvtRecTypeUACDiagnosedInORRCustody;

  static final String STRING_HEALTH_TASK_RECORD_TYPE = Label.UAC_taskRecordTypeUACHealthTask;

  static final String STRING_MENTAL_HEALTH_TASK_RECORD_TYPE = Label.UAC_taskMentalHealthRecType;

  static final String STRING_NOT_STARTED_STATUS = Label.UAC_statusNotStarted;

  static final String STRING_FINAL_STATUS = Label.UAC_statusFinal;

  static final String STRING_YES = Label.UAC_Yes;

  static final String STRING_TB_DISEASE = Label.UAC_TBActiveDisease;

  static final String STRING_SEPSIS = Label.UAC_sepsis;

  static final String STRING_FIELD_CURRENT_STATUS =
      UAC_diagnosis__c.UAC_status__c.getDescribe().getName();

  static final String STRING_FIELD_POTENTIALLY_EXPOSED =
      UAC_diagnosis__c.UAC_potentiallyExposedUAC__c.getDescribe().getName();
  static final String STRING_FIELD_CONDITION =
      UAC_diagnosis__c.UAC_WDCondition__c.getDescribe().getName();
  static final String STRING_FIELD_CONDTION_TYPE =
      UAC_diagnosis__c.UAC_WDConditionType__c.getDescribe().getName();

  // User story 1794
  static final String STRING_FIELD_FOLLOWUP_VISIT =
      UAC_diagnosis__c.UAC_wdFollowUpVisitRequired__c.getDescribe().getName();
  static final String STRING_FIELD_FOLLOWUP_VISIT_DATE =
      UAC_diagnosis__c.UAC_wdFollowUpVisitDate__c.getDescribe().getName();
  static final String STRING_FIELD_REFERAL =
      UAC_diagnosis__c.UAC_wdReferralToSpecialistRequired__c.getDescribe().getName();
  static final String STRING_FIELD_REFERAL_DATE =
      UAC_diagnosis__c.UAC_specialistVisitEstimatedDueDate__c.getDescribe().getName();
  static final String STRING_FIELD_ISOLATION =
      UAC_diagnosis__c.UAC_wdIsIsolationQuarantineRequired__c.getDescribe().getName();
  static final String STRING_FIELD_ISOLATION_DATE =
      UAC_diagnosis__c.UAC_wdIsolationQuarantineEndDate__c.getDescribe().getName();
  static final String STRING_FIELD_DISCHARGE =
      UAC_diagnosis__c.UAC_wdWillDischargeNeedtobeDelayed__c.getDescribe().getName();

  static final String STRING_FIELD_DISCHARGE_DATE =
      UAC_diagnosis__c.UAC_delayedDischargeEstimatedEndDate__c.getDescribe().getName();

  // User story 1794 Task Subject
  static final String STRING_TASK_TYPE_FOLLOW_UP = 'Follow-Up Visit';
  static final String STRING_TASK_TYPE_SPECIALIST = 'Specialist Referral';
  static final String STRING_TASK_TYPE_ISOLATION = 'Isolation/Quarantine';
  static final String STRING_TASK_TYPE_DEALYED_DISCHARGE = 'Delayed Discharge';

  static final String STRING_ORR_CUSTODY = 'UC Diagnosed in ORR Custody';

  static final List<String> CONDITION_LIST =
      Label.UAC_diagnosisConditionsForExposureEvent.split(',');

  static final List<String> SEPSIS_CONDITION_TYPE =
      Label.UAC_diagnosisSepsisConditionTypesForExposureEvent.split(',');

  static final List<String> TB_CONDITION_TYPE =
      Label.UAC_diagnosisTBConditionTypesForExposureEvent.split(',');

  static final Id ID_RECORD_TYPE_ORR_CUSTODY =
      Schema.SObjectType.UAC_exposureEvent__c.getRecordTypeInfosByDeveloperName()
          .get(STRING_ORR_CUSTODY_RECORD_TYPE)
          .getRecordTypeId();
 
  public
  static final Id ID_RECORD_HEALTH_TASK =
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
          .get(STRING_HEALTH_TASK_RECORD_TYPE)
          .getRecordTypeId();
          
  public
  static final Id ID_RECORD_MENTAL_HEALTH_TASK =
        Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
            .get(STRING_MENTAL_HEALTH_TASK_RECORD_TYPE)
            .getRecordTypeId();        

  /**
   * IF criteria mathcehd as per User story  #2257 and #1794 then
   * create task and Exposure event
   * @param diagnosisList  list of diagnosis record
   */
  public
  static void createHealthTaskAndExposureEvent(Set<Id> diagnosisList) {
    createHealthTaskAndExposureEvent(diagnosisList, null);
  }
  /**
   * @description Method Create an exposure event and Health Task.
   *  ORRUAC-2257 ,ORRUAC -1794
   * @author Vijayakumar Pethanan (Deloitte) | 09-16-2020
   * @param diagnosisList list of diagnosis Id
   * @param oldItems Map of old values from trigger
   **/
  public
  static void createHealthTaskAndExposureEvent(Set<Id> diagnosisList, Map<Id, Sobject> oldItems) {
    List<UAC_exposureEvent__c> exposureEventList = new List<UAC_exposureEvent__c>();
    List<Task> taskList = new List<Task>();
    for (UAC_diagnosis__c diagnosis :
        // clang-format off
            [SELECT
            Id, UAC_status__c, UAC_WDCondition__c,UAC_potentiallyExposedUAC__c,
            UAC_WDConditionType__c,UAC_specifyOtherWDCondition__c,
            UAC_wdFollowUpVisitRequired__c,UAC_wdFollowUpVisitDate__c,
            UAC_wdReferralToSpecialistRequired__c,UAC_specialistVisitEstimatedDueDate__c,
            UAC_wdSpecialistType__c,
            UAC_wdIsIsolationQuarantineRequired__c,UAC_wdIsolationQuarantineStartDate__c,
            UAC_wdIsolationQuarantineEndDate__c,
            UAC_wdWillDischargeNeedtobeDelayed__c,UAC_delayedDischargeEstimatedEndDate__c,
            UAC_associatedUAC__c,UAC_associatedUAC__r.UAC_program__c,UAC_associatedHealthEvaluation__c,UAC_WDCategory__c
            FROM
            UAC_diagnosis__c
            WHERE
            Id IN :diagnosisList
            ]
        // clang-format on
    ) {

      UAC_diagnosis__c oldDiagnosis = null;
      if (oldItems != null) {
        oldDiagnosis = (UAC_diagnosis__c) oldItems.get(diagnosis.id);
      }

      /* Current status = 'Final'
       Potentially Exposed UAC = 'Yes'
       Condition in
       'Acute Hepatitis A',
       'COVID-19',
       'Measles',
       'Mumps',
       'Pertussis',
       'Rubella',
       'Varicella (Chickenpox)',
       'Viral Hemorrhagic Fever'
       */
      if ((isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_CURRENT_STATUS)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_POTENTIALLY_EXPOSED)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_CONDITION))
          && STRING_FINAL_STATUS == diagnosis.UAC_status__c
          && STRING_YES == diagnosis.UAC_potentiallyExposedUAC__c
          && CONDITION_LIST.contains(diagnosis.UAC_WDCondition__c)) {
        exposureEventList.add(createExposureEvent(diagnosis));
      }
      /*Current status = 'Final'
      Potentially Exposed UAC = 'Yes'
      Condition =    Sepsis/Meningitis'
      Condition type in
      'Hemophilus Influenzae Type b (Hib)',
      'Neisseria Meningitidis',
      'Streptococcus Pneumoniae'

       or
       Condition =   'TB, Active Disease'
        Condition type in
        'Lab-confirmed Pulmonary TB',
        'Clinically Diagnosed Pulmonary TB'
      */
      if ((isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_CURRENT_STATUS)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_POTENTIALLY_EXPOSED)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_CONDITION)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_CONDTION_TYPE))
          && STRING_FINAL_STATUS == diagnosis.UAC_status__c
          && STRING_YES == diagnosis.UAC_potentiallyExposedUAC__c
          && (STRING_SEPSIS == diagnosis.UAC_WDCondition__c
              || STRING_TB_DISEASE == diagnosis.UAC_WDCondition__c)
          && (SEPSIS_CONDITION_TYPE.contains(diagnosis.UAC_WDConditionType__c)
              || TB_CONDITION_TYPE.contains(diagnosis.UAC_WDConditionType__c))) {
        exposureEventList.add(createExposureEvent(diagnosis));
      }
      // Condition added user story #1794
      // Follow up task creation
      if ((isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_FOLLOWUP_VISIT)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_FOLLOWUP_VISIT_DATE))
          && (STRING_YES == diagnosis.UAC_wdFollowUpVisitRequired__c
              && diagnosis.UAC_wdFollowUpVisitDate__c != null)) {
        taskList.add(createTask(
            diagnosis, STRING_TASK_TYPE_FOLLOW_UP, diagnosis.UAC_wdFollowUpVisitDate__c));
      }
      // Referal Task creation
      if ((isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_REFERAL)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_REFERAL_DATE)
              || isValueChanged(diagnosis,
                  oldDiagnosis,
                  UAC_diagnosis__c.UAC_wdSpecialistType__c.getDescribe().getName()))
          && (STRING_YES == diagnosis.UAC_wdReferralToSpecialistRequired__c
              && diagnosis.UAC_wdSpecialistType__c != null
              && diagnosis.UAC_specialistVisitEstimatedDueDate__c != null)

      ) {
        taskList.add(createTask(diagnosis,
            STRING_TASK_TYPE_SPECIALIST,
            diagnosis.UAC_specialistVisitEstimatedDueDate__c));
      }

      // Isolation/Qurantine Task creation
      if ((isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_ISOLATION)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_ISOLATION_DATE)
              || isValueChanged(diagnosis,
                  oldDiagnosis,
                  UAC_diagnosis__c.UAC_wdIsolationQuarantineStartDate__c.getDescribe().getName()))
          && (STRING_YES == diagnosis.UAC_wdIsIsolationQuarantineRequired__c
              && diagnosis.UAC_wdIsolationQuarantineStartDate__c != null
              && diagnosis.UAC_wdIsolationQuarantineEndDate__c != null)

      ) {
        taskList.add(createTask(
            diagnosis, STRING_TASK_TYPE_ISOLATION, diagnosis.UAC_wdIsolationQuarantineEndDate__c));
      }
      // Delayed Discharge Task creation
      if ((isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_DISCHARGE)
              || isValueChanged(diagnosis, oldDiagnosis, STRING_FIELD_DISCHARGE_DATE))
          && (STRING_YES == diagnosis.UAC_wdWillDischargeNeedtobeDelayed__c
              && diagnosis.UAC_delayedDischargeEstimatedEndDate__c != null)) {
        taskList.add(createTask(diagnosis,
            STRING_TASK_TYPE_DEALYED_DISCHARGE,
            diagnosis.UAC_delayedDischargeEstimatedEndDate__c));
      }
    }

    if (exposureEventList.isEmpty() == false) {
      try {
        insert exposureEventList;
      } catch (Exception e) {
        // Keep single line increase code coverage Precentage
        UAC_errorLog.platformEventErrorLog(e.getMessage(),'',
            'UAC_diagnosisTriggerHelper cls insert on exposureEvent List ',
            e.getStackTraceString());
      }
    }

    if (taskList.isEmpty() == false) {

      try {
        List<Group> groupRec =
            [select Id, Name, DeveloperName from Group where Type = 'Queue' and Name
              =:Label.uac_medicalHealthTaskQueue Limit 1];

        if (groupRec.isEmpty() == false) {

          for (Task task : taskList) {
            task.OwnerId = groupRec[0].id;
          }
        }

        insert taskList;
      } catch (Exception e) {
        // Keep single line increase code coverage Precentage
        UAC_errorLog.platformEventErrorLog(e.getMessage(),'',
            'UAC_diagnosisTriggerHelper cls insert on taskList  ',
            e.getStackTraceString());
      }
    }
  }

  /**
   * Check value is changed from previous value and current values
   * @param diagnosis current value
   * @param oldDiagnosis previous value
   * @param fieldName field name refere in  object
   * @return if values is changed or previous value is null
   */
  public
  static Boolean isValueChanged(
      UAC_diagnosis__c diagnosis, UAC_diagnosis__c oldDiagnosis, String fieldName) {
    return oldDiagnosis == null
        || getFieldValue(oldDiagnosis, fieldName) != getFieldValue(diagnosis, fieldName);
  }

  /**
   * Check value is changed from previous value and current values
   * @param diagnosis hold dignosis informaation
   * @return field values
   */
  public
  static String getFieldValue(UAC_diagnosis__c diagnosis, String fieldName) {
    return String.valueOf(diagnosis.get(fieldName));
  }

  /**
   * Create exposoure event
   * @param diagnosis  dignosis informaation
   * @return UAC_exposureEvent__c
   */
  public
  static UAC_exposureEvent__c createExposureEvent(UAC_diagnosis__c diagnosis) {
    UAC_exposureEvent__c exposureEvent = new UAC_exposureEvent__c();
    exposureEvent.UAC_systemGenerated__c = true;
    exposureEvent.UAC_associatedHealthEvaluation__c = diagnosis.UAC_associatedHealthEvaluation__c;
    exposureEvent.UAC_associatedDiagnosis__c = diagnosis.id;
    exposureEvent.UAC_PHIProgram__c = diagnosis.UAC_associatedUAC__r.UAC_program__c;
    exposureEvent.UAC_indexUAC__c = diagnosis.UAC_associatedUAC__c;
    exposureEvent.UAC_diseaseCondition__c = diagnosis.UAC_WDCondition__c;
    exposureEvent.UAC_specifyCondition__c = diagnosis.UAC_specifyOtherWDCondition__c;
    exposureEvent.UAC_diseaseConditionType__c = diagnosis.UAC_WDConditionType__c;
    exposureEvent.recordtypeId = ID_RECORD_TYPE_ORR_CUSTODY;
    exposureEvent.UAC_PHIStatus__c = STRING_NOT_STARTED_STATUS;
    exposureEvent.UAC_sourceOfPotentialExposure__c = STRING_ORR_CUSTODY;
    return exposureEvent;
  }

  /**
   * Create Task from diagnosis
   * @param diagnosis  dignosis informaation
   * @param type  task type
   * @param dueDate  task due date
   * @return Task
   */
  public
  static Task createTask(UAC_diagnosis__c diagnosis, String type, Date dueDate) {
    Task task = new Task();
    if(diagnosis.UAC_WDCategory__c == 'Behavioral and Mental Health Concerns' || diagnosis.UAC_WDCategory__c == 'Mental Health Diagnosis'){
      task.recordtypeId = ID_RECORD_MENTAL_HEALTH_TASK;
    }else{
      task.recordtypeId = ID_RECORD_HEALTH_TASK;
    }
    if(diagnosis.UAC_wdSpecialistType__c != null && type == STRING_TASK_TYPE_SPECIALIST){
      task.UAC_specialistType__c = diagnosis.UAC_wdSpecialistType__c;
    }
    task.WhoId = diagnosis.UAC_associatedUAC__c;
    task.UAC_Contact__c = diagnosis.UAC_associatedUAC__c;
    task.Type = type;
    task.subject = type;
    task.WhatId = diagnosis.id;
    task.UAC_diagnosis__c = diagnosis.id;
    task.UAC_associatedHealthEvaluation__c = diagnosis.UAC_associatedHealthEvaluation__c;
    task.ActivityDate = dueDate;
    return task;
  }

  /**
   * @description Method Create an Diagnosis Outcome junction object record.
   * @author Abhisek Pati (Deloitte) | 09-22-2020
   * @param diagnosisList list of diagnosis Id
   * @param New values from trigger
   **/

  public
  static void createDiagnosisOutcomeRecord(Set<Id> diagnosisList) {

    List<UAC_diagnosisOutcome__c> diagnosisOutcomeList = new List<UAC_diagnosisOutcome__c>();
    for (UAC_diagnosis__c diagnosis :
        // clang-format off
          [SELECT
          Id,UAC_associatedHealthEvaluation__c
          FROM
          UAC_diagnosis__c
          WHERE
          Id IN :diagnosisList
          ]
        // clang-format on
    ) {
      diagnosisOutcomeList.add(createDiagnosisOutcome(diagnosis));
    }
    database.insert(diagnosisOutcomeList);
  }

  /**
   * Create Diagnosis Outcome
   * @param dignosis information
   * @return UAC_diagnosisOutcome__c
   */
  public
  static UAC_diagnosisOutcome__c createDiagnosisOutcome(UAC_diagnosis__c diagnosis) {
    UAC_diagnosisOutcome__c diagnosisOutcome = new UAC_diagnosisOutcome__c();
    diagnosisOutcome.UAC_associatedHealthEvaluation__c =
        diagnosis.UAC_associatedHealthEvaluation__c;
    diagnosisOutcome.UAC_associatedDiagnosis__c = diagnosis.id;
    diagnosisOutcome.UAC_outcomeofEvaluation__c = 'New Diagnosis/Condition';
    return diagnosisOutcome;
  }
    
  
    
}