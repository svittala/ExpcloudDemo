/**
 * @File Name          : UAC_healthEvaluationTriggerHelper.cls
 * @Description        : Helper method for UAC_healthEvaluationTriggerHandler
 * @Author             : Anupreeta Chakraborty (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_healthEvaluationTriggerHelperTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 12-10-2020
 * @Modification Log   :
 *
 * Ver  Date        Author                              Modification
 * 1.0  06-19-2020  Anupreeta Chakraborty (Deloitte)    Initial Implementation.
 * 1.1  07-31-2020  Sachet Khanal (Deloitte)            ORRUAC-1436 Added auto-generate logic
 * 1.2  10-02-2020  Ranjith kumar (AI-Vets)             Adding Update Initial Mental Evaluation
 *                                                      summary status field logic
 * 1.3  10-21-2020  Abhisek Pati (Deloitte)             ORRUAC-3049 Added logic to create Health
 *                                                      Task
 * 1.4  11-04-2020  Abhisek Pati (Deloitte)             ORRUAC-3647 - Added Contact Id to Task
 *                                                      creation.
 * 1.6  03-22-2020  Abhisek Pati (Deloitte)             ORRUAC-5563 Added code for async process.
 * 1.7  09-15-2021  Abhisek Pati (Deloitte)             ORRUAC-6552 Added logic for Updating IME Status and Due date.
 **/

public
without sharing class UAC_healthEvaluationTriggerHelper {

  static final String STRING_HEALTH_TASK_RECORD_TYPE = Label.UAC_taskRecordTypeUACHealthTask;

  public
  static final Id ID_RECORD_HEALTH_TASK =
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
          .get(STRING_HEALTH_TASK_RECORD_TYPE)
          .getRecordTypeId();
  static final String STRING_TASK_TYPE_SPECIALIST_REFERRAL = Label.UAC_specialistReferral;
  static final String STRING_SPECIALIST_TYPE = Label.UAC_pediatrician;

  /**
   * @description ORRUAC-1436 Method to create related records for IME using Auto-Generate Settings
   * @author Sachet Khanal (Deloitte) | 07-31-2020
   * @param mapHealthEvaluation Map of health evaluation records
   **/
  public
  static void autoGenerateRelatedRecordsForIME(
      Map<Id, UAC_healthEvaluation__c> mapHealthEvaluation) {
    UAC_asyncIMEPhysicalExamRecordCreation handleIMEPhysicalExamRecord =
    new UAC_asyncIMEPhysicalExamRecordCreation(mapHealthEvaluation.keyset());
    system.enqueueJob(handleIMEPhysicalExamRecord);

    /*Set<String> setSObjectToGenerate = new Set<String>();
    setSObjectToGenerate.add(UAC_test__c.sObjectType.getDescribe().getName());
    setSObjectToGenerate.add(UAC_physicalExam__c.sObjectType.getDescribe().getName());
    List<SObject> lstAutoGenerateRecord =
        UAC_autoGenerationServices.getRecords(setSObjectToGenerate);
    // Initialize sObjectType map to prevent chucking error and insert records
    Map<SObjectType, List<SObject>> mapSObjectTypeToInsert = new Map<SObjectType, List<SObject>>();
    for (UAC_healthEvaluation__c objHealthEvaluation : mapHealthEvaluation.values()) {
      for (SObject objRecord : lstAutoGenerateRecord) {
        objRecord = objRecord.clone();
        // Conditionally set fields based on sObject type if necessary
        if (objRecord.getSObjectType() == UAC_test__c.sObjectType) {
          objRecord.put(UAC_test__c.UAC_systemGenerated__c.getDescribe().getName(), true);
        }
        objRecord.put('UAC_associatedHealthEvaluation__c', objHealthEvaluation.Id);
        objRecord.put('UAC_associatedUAC__c', objHealthEvaluation.UAC_associatedUAC__c);
        SObjectType objSObjectType = objRecord.getSObjectType();
        if (!mapSObjectTypeToInsert.containsKey(objSObjectType)) {
          mapSObjectTypeToInsert.put(objSObjectType, new List<SObject>());
        }
        mapSObjectTypeToInsert.get(objSObjectType).add(objRecord);
      }
    }
    List<SObject> lstRecordsToInsert = new List<SObject>();
    for (List<SObject> lstSObject : mapSObjectTypeToInsert.values()) {
      lstRecordsToInsert.addAll(lstSObject);
    }
    if (!lstRecordsToInsert.isEmpty()) {
      insert lstRecordsToInsert;
    }*/
  }

  /**
   * @description ORRUAC-2834 Method to update 'Mental Health Evaluation Status' field
   * @author Anupreeta Chakraborty (Deloitte) | 09-30-2020
   * @param mapHealthEvaluation Map of health evaluation records
   **/
  public
  static void updateMentalHealthEvaluationStatus(
      Map<Id, UAC_healthEvaluation__c> mapmentalHealthEvaluation) {
    List<SObject> lstRecordsToUpdate = new List<SObject>();
    for (UAC_healthEvaluation__c objHealthEvaluation : mapmentalHealthEvaluation.values()) {
      if (objHealthEvaluation.UAC_mentalStatusEvaluationStatus__c == Label.UAC_statusComplete
          && objHealthEvaluation.UAC_suicidalHomicidalRiskStatus__c == Label.UAC_statusComplete
          && objHealthEvaluation.UAC_substanceUseHistoryStatus__c == Label.UAC_statusComplete
          && objHealthEvaluation.UAC_evaluationSummaryStatus__c == Label.UAC_statusComplete) {
        // Update overall status to 'Complete'
        // if all of the above sections status values are marked as "Complete"
        objHealthEvaluation.UAC_mentalHealthEvaluationStatus__c = Label.UAC_statusComplete;
      }

      else if (objHealthEvaluation.UAC_mentalStatusEvaluationStatus__c != Label.UAC_statusNotStarted
          || objHealthEvaluation.UAC_suicidalHomicidalRiskStatus__c != Label.UAC_statusNotStarted
          || objHealthEvaluation.UAC_substanceUseHistoryStatus__c != Label.UAC_statusNotStarted
          || objHealthEvaluation.UAC_evaluationSummaryStatus__c != Label.UAC_statusNotStarted) {
        // Update overall status to 'In progress'
        // if at least one of the above status values are not = Not Started
        objHealthEvaluation.UAC_mentalHealthEvaluationStatus__c = Label.UAC_statusInProgress;
      } else {
        objHealthEvaluation.UAC_mentalHealthEvaluationStatus__c = Label.UAC_statusNotStarted;
      }
    }
  }
  /**
   * @description ORRUAC-2832 Method to update 'Evaluation Summary Status' field
   * @author Ranjith Kumar(AI-Vets) | 10-02-2020
   * @param mapHealthEvaluation Map of health evaluation records
   **/
  public
  static void updateEvaluationSummaryStatus(
      Map<Id, UAC_healthEvaluation__c> mapmentalHealthEvaluation,
      Map<Id, UAC_healthEvaluation__c> oldItems) {
    List<SObject> lstRecordsToUpdate = new List<SObject>();
    for (UAC_healthEvaluation__c objHealthEvaluation : mapmentalHealthEvaluation.values()) {
      UAC_healthEvaluation__c oldobjHealthEvaluation = oldItems.get(objHealthEvaluation.Id);
      if (objHealthEvaluation.UAC_dueDate__c != null
          && objHealthEvaluation.UAC_nameofClinician__c != null
          && objHealthEvaluation.UAC_dateCompleted__c != null
          && objHealthEvaluation.UAC_recommendation__c != null
          && (oldobjHealthEvaluation.UAC_dueDate__c != objHealthEvaluation.UAC_dueDate__c
              || oldobjHealthEvaluation.UAC_nameofClinician__c
                  != objHealthEvaluation.UAC_nameofClinician__c
              || oldobjHealthEvaluation.UAC_dateCompleted__c
                  != objHealthEvaluation.UAC_dateCompleted__c
              || oldobjHealthEvaluation.UAC_recommendation__c
                  != objHealthEvaluation.UAC_recommendation__c)) {
        // Update Evaluation Summary Status to 'Complete'
        // if all of the required fields populated update status as "Complete"
        objHealthEvaluation.UAC_evaluationSummaryStatus__c = Label.UAC_statusComplete;
      }
    }
  }

  /**
   * @description ORRUAC-2795 Method to update 'Certification Date/Time' field to Today
   * @author Anupreeta Chakraborty (Deloitte) | 10-05-2020
   * @param mapHealthEvaluation Map of health evaluation records
   **/
  public
  static void updateCertificationDateTime(
      Map<Id, UAC_healthEvaluation__c> mapClinicalContactHealthEvaluation) {
    for (UAC_healthEvaluation__c objHealthEvaluation :
        mapClinicalContactHealthEvaluation.values()) {
      if (objHealthEvaluation.UAC_certificationConfirmation__c) {
        // If Certification Confirmation is populated on save then the system should populated the
        // the Certification Date/Time to //TODAY
        objHealthEvaluation.UAC_certificationDateTime__c = System.Now();
      }
    }
  }

  /**
   * @description ORRUAC-3125 Method to populate Clinical Contact fields on record creation
   * @author Anupreeta Chakraborty (Deloitte) | 10-21-2020
   * @param mapHealthEvaluation Map of health evaluation records
   * @return None
   **/
  public
  static void populateClinicalContact(List<UAC_healthEvaluation__c> lstMentalHealthEvaluation) {

    List<Id> lstContacts = new List<Id>();
    Map<Id, Contact> mapAssociatedContact = new Map<Id, Contact>();

    // Get the list of UACs associated to the clinical contacts
    for (UAC_healthEvaluation__c objClinicalContact : lstMentalHealthEvaluation)
      lstContacts.add(objClinicalContact.UAC_associatedUAC__c);

    // Set the map of contact fields
    for (Contact objContact : [Select UAC_admissionDateforMostRecentORRStay__c,
           UAC_dischargeDateforMostRecentORRStay__c,
           UAC_admissionAgeforMostRecentORRStay__c,
           UAC_currentAge__c,
           UAC_program__c,
           UAC_program__r.name from Contact where id IN:lstContacts]) {
      mapAssociatedContact.put(objContact.Id, objContact);
    }
    // populate clinical contact fields
    for (UAC_healthEvaluation__c objClinicalContact : lstMentalHealthEvaluation) {
      if (objClinicalContact.UAC_associatedUAC__c != null) {
        objClinicalContact.UAC_admissionDateforMostRecentORRStay__c =
            mapAssociatedContact.get(objClinicalContact.UAC_associatedUAC__c)
                .UAC_admissionDateforMostRecentORRStay__c;
        objClinicalContact.UAC_dischargeDateforMostRecentORRStay__c =
            mapAssociatedContact.get(objClinicalContact.UAC_associatedUAC__c)
                .UAC_dischargeDateforMostRecentORRStay__c;
        if (mapAssociatedContact.get(objClinicalContact.UAC_associatedUAC__c).UAC_currentAge__c
            != null)
          objClinicalContact.UAC_ageAtAdmission__c = Integer.valueOf(
              mapAssociatedContact.get(objClinicalContact.UAC_associatedUAC__c).UAC_currentAge__c);
        objClinicalContact.UAC_lookupAssociatedProgram__c =
            mapAssociatedContact.get(objClinicalContact.UAC_associatedUAC__c).UAC_program__c;
        objClinicalContact.UAC_dateReportEntered__c = System.Today();
        objClinicalContact.UAC_programNameattheTimeofExam__c =
            mapAssociatedContact.get(objClinicalContact.UAC_associatedUAC__c).UAC_program__r.name;
      }
    }
  }

  /**
   * @description ORRUAC-3049 Method to create Health Task when "UAC Needs to See Pediatrician?" =
   *Yes
   * @author Abhisek Pati (Deloitte) | 10-21-2020
   * @param mapHealthEvaluation Map of health evaluation records
   * @return None
   **/
  public
  static void createHealthTask(Map<Id, UAC_healthEvaluation__c> mapMentalHealthEvaluation,
      Map<Id, UAC_healthEvaluation__c> mapOldMentalHealthEvaluation) {
    list<task> lstObjTask = new list<task>();
    List<Group> lstQueue = [select Id, Name, DeveloperName from Group where Type = 'Queue' and Name
      =:Label.uac_medicalHealthTaskQueue Limit 1];
    for (UAC_healthEvaluation__c objHealthEvaluation : mapMentalHealthEvaluation.values()) {
      UAC_healthEvaluation__c objOldHealthEvaluation =
          mapOldMentalHealthEvaluation.get(objHealthEvaluation.Id);
      if (objOldHealthEvaluation.UAC_needstoSeePediatrician__c
              != objHealthEvaluation.UAC_needstoSeePediatrician__c
          && objHealthEvaluation.UAC_needstoSeePediatrician__c == Label.UAC_Yes) {
        Task objTask = new Task();
        objTask.recordtypeid = ID_RECORD_HEALTH_TASK;
        objTask.WhoId = objHealthEvaluation.UAC_associatedUAC__c;
        objTask.UAC_Contact__c = objHealthEvaluation.UAC_associatedUAC__c;
        objTask.WhatId = objHealthEvaluation.id;
        objTask.UAC_associatedHealthEvaluation__c = objHealthEvaluation.id;
        objTask.Type = STRING_TASK_TYPE_SPECIALIST_REFERRAL;
        objTask.Subject = STRING_TASK_TYPE_SPECIALIST_REFERRAL;
        objTask.ActivityDate = System.Today() + 14;
        objTask.UAC_specialistType__c = STRING_SPECIALIST_TYPE;
        if (!lstQueue.isEmpty()) {
          objTask.OwnerId = lstQueue[0].id;
        }
        lstObjTask.add(objTask);
      }
    }
    if (!lstObjTask.isEmpty()) {
      insert lstObjTask;
    }
  }
  /**
   * @description ORRUAC-6552 Added logic for Updating IME Status and Due date.
   * @author Abhisek Pati (Deloitte) | 09-15-2021
   * @param mapHealthEvaluation Map of health evaluation records
   * @return None
   **/
    
  public
  static void UpdateContactIMEStatusandIMEDueDate(Map<Id, UAC_healthEvaluation__c> mapinitialHealthEvaluation,
     Map<Id, UAC_healthEvaluation__c> mapOldInitialHealthEvaluation) {
     Set<Id> setContactIds = new Set<Id>();
     for(UAC_HealthEvaluation__c objIME: [select id,UAC_associatedUAC__c,UAC_healthEvaluationStatus__c
                                          from UAC_HealthEvaluation__c 
                                          where id IN:mapInitialHealthEvaluation.keyset()] ){
     UAC_healthEvaluation__c objOldHealthEvaluation = mapOldInitialHealthEvaluation.get(objIME.Id);
       if (objOldHealthEvaluation.UAC_healthEvaluationStatus__c != objIME.UAC_healthEvaluationStatus__c){
                    setContactIds.add(objIME.UAC_associatedUAC__c);  
           }
      }
    if(!setContactIds.isEmpty()){
    UAC_asyncIMEStatusAndDueDateUpdate handleIMEStatusAndDueDate = new UAC_asyncIMEStatusAndDueDateUpdate(setContactIds);
    system.enqueueJob(handleIMEStatusAndDueDate);
    }
  }
}