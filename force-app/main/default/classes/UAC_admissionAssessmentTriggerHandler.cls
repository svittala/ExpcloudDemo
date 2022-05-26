public
without sharing class UAC_admissionAssessmentTriggerHandler implements UAC_ITriggerHandler {
     /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAdmissionAssessment__c;
  }
  @testVisible
  private
  static Boolean boolRun = true;
  private
  static Id ISPRecordTypeId =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_assessmentRecordTypeISP)
          .getRecordTypeId();
  private
  static Id AssessmentForRisk =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_assessmentRecordTypeRisk)
          .getRecordTypeId();
  private
  static Id UacCaseReviewTypeId =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_assessmentRecordTypeReview)
          .getRecordTypeId();
  /**
   * @description Method to handle before insert trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void beforeInsert(List<UAC_admissionAssessment__c> newItems) {
    boolRun = false;
    List<UAC_admissionAssessment__c> lstOfNewAssessmentForRisk =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstOfNewCaseReview = new List<UAC_admissionAssessment__c>();
    for (UAC_admissionAssessment__c objNewAssessment : newItems) {
      if (objNewAssessment.RecordTypeId == AssessmentForRisk) {
        lstOfNewAssessmentForRisk.add(objNewAssessment);
      }
      if (objNewAssessment.RecordTypeId == UacCaseReviewTypeId) {
        lstOfNewCaseReview.add(objNewAssessment);
      }
    }
    if (!lstOfNewAssessmentForRisk.isEmpty()) {
      UAC_admissionAssessmentTriggerHelper.syncAssessmentForRiskFields(lstOfNewAssessmentForRisk);
    }
    if (!lstOfNewCaseReview.isEmpty()) {
      UAC_admissionAssessmentTriggerHelper.syncCaseReviewFields(lstOfNewCaseReview);
    }
    Map<String, List<UAC_admissionAssessment__c>> mapExistingAssessments =
        UAC_admissionAssessmentTriggerHelper.checkForDuplicates(newItems);
    UAC_admissionAssessmentTriggerHelper.setDefaultTeamMembers(newItems);
    UAC_admissionAssessmentTriggerHelper.setFieldsOnAssessmentInsert(
        newItems, mapExistingAssessments);
    UAC_admissionAssessmentTriggerHelper.setImeOnIntakesAssessments(newItems);
    boolRun = true;
  }

  /**
   * @description Method to handle after insert trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @return void
   **/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    Map<Id, UAC_admissionAssessment__c> mapNewAdmissionAssessmentCasted =
        (Map<Id, UAC_admissionAssessment__c>) newItems;
    List<UAC_admissionAssessment__c> lstOfNewISP = new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstOfNewAssessmentForRisk =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstOfNewCaseReview = new List<UAC_admissionAssessment__c>();

    for (UAC_admissionAssessment__c objNewAssessment : mapNewAdmissionAssessmentCasted.values()) {
      if (objNewAssessment.RecordTypeId == ISPRecordTypeId) {
        lstOfNewISP.add(objNewAssessment);
      }
      if (objNewAssessment.RecordTypeId == AssessmentForRisk) {
        lstOfNewAssessmentForRisk.add(objNewAssessment);
      }
      if (objNewAssessment.RecordTypeId == UacCaseReviewTypeId) {
        lstOfNewCaseReview.add(objNewAssessment);
      }
    }
    if (!lstOfNewISP.isEmpty()) {
      UAC_admissionAssessmentTriggerHelper.syncServiceRecordsToISP(lstOfNewISP);
    }
    if (!lstOfNewAssessmentForRisk.isEmpty()) {
      UAC_admissionAssessmentTriggerHelper.syncDocumentsForAssessments(
          lstOfNewAssessmentForRisk, Label.UAC_assessmentRecordTypeRisk);
    }
    if (!lstOfNewCaseReview.isEmpty()) {
      UAC_admissionAssessmentTriggerHelper.syncDocumentsForAssessments(
          lstOfNewCaseReview, Label.UAC_assessmentRecordTypeReview);
    }
    if (!System.isFuture()) {
      UC_visualChecklistService.updateAdmissionTasks(newItems.keyset(), 'In Progress');
    }
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    if (!boolRun) {
      return;
    }
    Map<Id, UAC_admissionAssessment__c> newItemsCasted =
        (Map<Id, UAC_admissionAssessment__c>) newItems;
    Map<Id, UAC_admissionAssessment__c> oldItemsCasted =
        (Map<Id, UAC_admissionAssessment__c>) oldItems;
    UAC_admissionAssessmentTriggerHelper.validateFieldsOnUpdate(newItemsCasted, oldItemsCasted);
    UAC_admissionAssessmentTriggerHelper.setFieldsOnUpdate(newItemsCasted, oldItemsCasted);
    UAC_admissionAssessmentTriggerHelper.updateParentContactPrimaryLanguage(
        newItemsCasted, oldItemsCasted);
  }

  /**
   * @description Method to handle after update trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    // Iterate over records and collect by record type and invoke respective helper methods
    Map<Id, UAC_admissionAssessment__c> mapNewIntakesAssessment =
        new Map<Id, UAC_admissionAssessment__c>();
    Id recordTypeIdIntakesAssessment =
        Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
            .get(Label.UAC_initialIntakesAssessmentRecordType)
            .getRecordTypeId();
    for (UAC_admissionAssessment__c objAdmission :
        (List<UAC_admissionAssessment__c>) newItems.values()) {
      if (objAdmission.RecordTypeId == recordTypeIdIntakesAssessment) {
        mapNewIntakesAssessment.put(objAdmission.Id, objAdmission);
      }
    }
    if (mapNewIntakesAssessment.size() > 0) {
      // ORRUAC_2786 Added to send email notification for Initial Intake Assesment
      UAC_admissionAssessmentTriggerHelper.intakeAssesmentEmailToClinician(
          mapNewIntakesAssessment, (Map<Id, UAC_admissionAssessment__c>) oldItems);
    }
    UAC_admissionAssessmentTriggerHelper.createRecordsOnSubmit(
          (Map<Id, UAC_admissionAssessment__c>) newItems,
          (Map<Id, UAC_admissionAssessment__c>) oldItems);
  }

  /**
   * @description Method to handle before delete trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after delete trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  /**
   * @description Method to handle after undelete trigger traffic
   * @author Issam Awwad (Deloitte) | 6/09/2020
   * @param oldItems Map of old records
   * @return void
   **/
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}