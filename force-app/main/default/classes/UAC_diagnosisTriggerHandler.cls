/**
 * @File Name          : UAC_diagnosisTriggerHandler.cls
 * @Description        : Handles all Diagnosis trigger traffic
 * @Author             : Anupreeta Chakraborty (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 10-30-2020
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 * 1.0  06-19-2020  Anupreeta Chakraborty (Deloitte)  Initial Implementation.
 * 1.1  09-19-2020  Vijayakumar Pethanan (Deloitte)   #2257,#1794 story
 * 1.2  09-22-2020  Abhisek Pati (Deloitte)           Create Diagnosis Outcome for 2478
 * 1.3  09-25-2020  Sachet Khanal (Deloitte)          Adding bypass logic
 * 1.4  07-08-2020  Abhisek Pati (Deloitte)           ORRUAC-6046 - Added Exclusion Logic
 **/
public
inherited sharing class UAC_diagnosisTriggerHandler implements UAC_ITriggerHandler {

  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassDiagnosisTrigger__c;
  }

  private
  static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_diagnosis';

  /**
   * @description Method to handle before insert trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
   * @param lstNewDiagnosis List of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_diagnosis__c> lstNewDiagnosis) {
    //UAC_diagnosisTriggerHelper.populateMedicalTeamEmail(lstNewDiagnosis);    
    // 12/30/2020 Ram Josyer Creative Sys 
    UAC_EmailFieldUtility.populateMedicalTeamEmail(lstNewDiagnosis);
    // 12/30/2020 Ram Josyer Creative Sys 
    UAC_EmailFieldUtility.mapEmailFieldsFromAccountTeamRoles(lstNewDiagnosis, 
                                                            'UAC_associatedUAC__c', 
                                                            new List<String> {'Case Manager', 'Clinician'},
                                                            new Map<String, String> {'Case Manager' => 'UAC_CaseManagerEmail__c',
                                                             'Clinician' => 'UAC_ClinicianEmail__c'}
                                                            );


  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusions(
            newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
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
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    if (UC_exclusionLogicService.getInstance().runExclusions(
            newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME)) {
      UAC_diagnosisTriggerHelper.createHealthTaskAndExposureEvent(newItems.keyset());
      UAC_diagnosisTriggerHelper.createDiagnosisOutcomeRecord(newItems.keyset());
    }
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UAC_diagnosisTriggerHelper.createHealthTaskAndExposureEvent(newItems.keyset(), oldItems);
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Anupreeta Chakraborty (Deloitte) | 6/19/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}