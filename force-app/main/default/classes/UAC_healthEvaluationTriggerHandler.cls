/**
 * @File Name          : UAC_healthEvaluationTriggerHandler.cls
 * @Description        : Handles all Health Evaluation trigger traffic
 * @Author             : Anupreeta Chakraborty (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 07-31-2020
 * @Modification Log   :
 * Ver       Date            Author                         Modification
 * 1.0      06-19-2020  Anupreeta Chakraborty (Deloitte)    Initial Implementation.
 * 1.1      07-31-2020  Sachet Khanal (Deloitte)            ORRUAC_1436 Added auto-generate logic
 * 1.3      09-25-2020  Ranjith kumar (AI_vets)             Adding bypass logic
 * 1.4      10-02-2020  Ranjith kumar (AI-Vets)             Adding Update Initial Mental Evaluation summary status field logic
 * 1.5      10-21-2020  Abhisek Pati (Deloitte)             ORRUAC-3049 Added logic to create Health Task
 * 1.6      07-06-2021	Abhisek Pati (Deloitte)             ORRUAC-6057 Added Exclusion logic.
 * 1.7      09-15-2021  Abhisek Pati (Deloitte)             ORRUAC-6552 Added logic for Updating IME Status and Due date.
 **/
public
inherited sharing class UAC_healthEvaluationTriggerHandler implements UAC_ITriggerHandler {

  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassHealthEvaluationTrigger__c;
  }

  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_healthEvaluation';

  /**
   * @description Method to handle before insert trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @param lstNewHealthEvaluation List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_healthEvaluation__c> lstIME) {
      List<UAC_healthEvaluation__c> lstClinicalContactHealthEval = new List<UAC_healthEvaluation__c>();   
      List<UAC_healthEvaluation__c> lstEmailNotifyHealthEval = new List<UAC_healthEvaluation__c>();   
          
      for (UAC_healthEvaluation__c objHealthEval : lstIME) {
       if (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameClinicalContact)){
          lstClinicalContactHealthEval.add(objHealthEval);
       } 
       if ((objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameHA)) ||
         (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameTBPHI)) ||
          (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameNonTBPHI)))          
          {
            lstEmailNotifyHealthEval.add(objHealthEval);
        }    
      }
      if(lstClinicalContactHealthEval.size()>0){    
          UAC_healthEvaluationTriggerHelper.populateClinicalContact(lstClinicalContactHealthEval);
      }
      if(lstEmailNotifyHealthEval.size() > 0) {  
        // ORRUAC-498 added for the medical notification stories 12/05/2020 RJ CreativeSys
        UAC_EmailFieldUtility.populateMedicalTeamEmailHealthEval(lstEmailNotifyHealthEval);
        // ORRUAC-2577 notify Entity Team members by role - Ram Josyer (Creative Sys) 12/31/2020
        UAC_EmailFieldUtility.mapEmailFieldsFromAccountTeamRoles(lstEmailNotifyHealthEval, 
                            'UAC_associatedUAC__c', 
                            new List<String> {'Case Manager', 'Clinician'},
                            new Map<String, String> {'Case Manager' => 'UAC_CaseManagerEmail__c',
                            'Clinician' => 'UAC_ClinicianEmail__c'}
                            ); 
      }                    
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      Map<Id, UAC_healthEvaluation__c> mapMentalHealthEval = new Map<Id, UAC_healthEvaluation__c>();
	  Map<Id, UAC_healthEvaluation__c> mapClinicalContactHealthEval = new Map<Id, UAC_healthEvaluation__c>();     
      for (UAC_healthEvaluation__c objHealthEval :
        (List<UAC_healthEvaluation__c>) newItems.values()) {
       if (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameInitialMental)){
          mapMentalHealthEval.put(objHealthEval.Id, objHealthEval);
          }
       if (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameClinicalContact)){
          mapClinicalContactHealthEval.put(objHealthEval.Id, objHealthEval);
          } 
      }
      if(mapClinicalContactHealthEval.size()>0)    
  UAC_healthEvaluationTriggerHelper.updateCertificationDateTime(mapClinicalContactHealthEval);
  
      if(mapMentalHealthEval.size()>0)    
      UAC_healthEvaluationTriggerHelper.updateEvaluationSummaryStatus(mapMentalHealthEval,( Map<Id, UAC_healthEvaluation__c>)oldItems);        
      UAC_healthEvaluationTriggerHelper.updateMentalHealthEvaluationStatus(mapMentalHealthEval);
    }       
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
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
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
    // Iterate over records and collect by record type and invoke respective helper methods
    Map<Id, UAC_healthEvaluation__c> mapNewIMEHealthEval = new Map<Id, UAC_healthEvaluation__c>();

    for (UAC_healthEvaluation__c objHealthEval :
        (List<UAC_healthEvaluation__c>) newItems.values()) {
      if (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_IMERectype)) {
        mapNewIMEHealthEval.put(objHealthEval.Id, objHealthEval);
      }
    }
    if (mapNewIMEHealthEval.size() > 0) {
      // ORRUAC_1436 Added auto-generate logic to create related records for IME
      UAC_healthEvaluationTriggerHelper.autoGenerateRelatedRecordsForIME(mapNewIMEHealthEval);
    }
  }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Map<Id, UAC_healthEvaluation__c> mapMentalHealthEval = new Map<Id, UAC_healthEvaluation__c>();
    Map<Id, UAC_healthEvaluation__c> mapNewIMEHealthEval = new Map<Id, UAC_healthEvaluation__c>();
    for (UAC_healthEvaluation__c objHealthEval :
        (List<UAC_healthEvaluation__c>) newItems.values()) {
      if (objHealthEval.RecordTypeId
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(
              System.label.UAC_healthEvaluationRecordTypeApiNameMentalHealthServiceReport)) {
        mapMentalHealthEval.put(objHealthEval.Id, objHealthEval);
      }
      if (objHealthEval.RecordTypeId 
          == UAC_healthEvaluationUtil.getRecordTypeIdByDeveloperName(System.label.UAC_IMERectype)) {
        mapNewIMEHealthEval.put(objHealthEval.Id, objHealthEval);
      }
    }
    if (mapMentalHealthEval.size() > 0) {
      UAC_healthEvaluationTriggerHelper.createHealthTask(
          mapMentalHealthEval, (Map<Id, UAC_healthEvaluation__c>) oldItems);
    }
    if (mapNewIMEHealthEval.size() > 0) {
      UAC_healthEvaluationTriggerHelper.UpdateContactIMEStatusandIMEDueDate(
          mapNewIMEHealthEval,(Map<Id, UAC_healthEvaluation__c>) oldItems);
    }
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 7/14/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}