/**
 * @File Name          : UAC_admissionAssessmentTriggerHelper.cls
 * @Description        : Main helper class for trigger logic for UAC_admissionAssessment
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_admissionAssessment
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/14/2020   James Qian (Deloitte)     Initial Implementation.
 * 1.1    7/17/2020   Abhisek Pati (Deloitte)   Added record type UAC Assessment for
 *                                              checkForDuplicates
 * 1.2    8/12/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-1811 Autopopulation of Allergies and few
 *                                                  fields for Case Review and Assessment.
 * 1.3    10/13/2020   Karthi Subramanian (Deloitte) ORRUAC-2786 Email To clincian and Lead
 *Clinician 1.4    10/15/2020   Abhisek Pati (Deloitte)       ORRUAC-2786 Email to Account and Case
 *Team 1.5    10/20/2020   Abhisek Pati (Deloitte)       ORRUAC-3129 Added Email logic for Other
 *Prescription
 * 1.6 03/01/2021  Satish Kota (KVortex) ORRUAC-4774 Update Duplicate check for Assessments
 *  1.7   07/30/2021  Chase Oden (Deloitte)     Removed all references to deprecated UAC_gangAffiliation__c field
 **/
public
without sharing class UAC_admissionAssessmentTriggerHelper {
  private
  static final Set<String> setRecordTypesForTeamMembers =
      new Set<String>{Label.UAC_assessmentRecordTypeAssessment,
          Label.UAC_assessmentRecordTypeISP,
          Label.UAC_assessmentRecordTypeReview};
  private
  static final Set<String> setRTypesForAutoPopulation =
      new Set<String>{Label.UAC_assessmentRecordTypeAssessment,
          Label.UAC_assessmentRecordTypeReview,
          Label.UAC_initialIntakesAssessmentRecordType};
  private
  static final Map<Id, Schema.RecordTypeInfo> mapRecordTypes =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosById();
  private
  static final String strInitialIntakesAssessmentRecordType =
      Label.UAC_initialIntakesAssessmentRecordType;
  private
  static final String strInitialIntakesAssessmentErrorMessage =
      Label.UAC_initialIntakesAssessmentErrorMessage;
  private
  static final String strAssessmentForRiskRecordType = Label.UAC_assessmentRecordTypeRisk;
  private
  static final String strAssessmentForRiskErrorMessage = Label.UAC_assessmentErrorDuplicateRisk;
  private
  static set<string> caseReviewFieldSet = new set<string>();
  private
  static Id InitialIntakesRecordTypeId =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_initialIntakesAssessmentRecordType)
          .getRecordTypeId();
  private
  static Id UacAssessmentRecordTypeId =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_assessmentRecordTypeAssessment)
          .getRecordTypeId();
  private
  static Id UacCaseReviewTypeId =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_assessmentRecordTypeReview)
          .getRecordTypeId();
  /**
   * @description Sets fields when the Admission Assessment is inserted
   * @author James Qian (Deloitte) | 7/14/2020
   * @param List<UAC_admissionAssessment__c>
   **/
  public
  static void setFieldsOnAssessmentInsert(List<UAC_admissionAssessment__c> newItems,
      Map<String, List<UAC_admissionAssessment__c>> mapExistingAssessments) {
    Map<Id, Case> mapParentCase = new Map<Id, Case>();
    Set<Id> setRiskAssessmentCaseIds = new Set<Id>();
    Set<Id> setofUAC = new Set<Id>();
    List<UAC_admissionAssessment__c> lstNewCaseReview = new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstNewUACAssessment = new List<UAC_admissionAssessment__c>();
    Map<Id, UAC_healthEvaluation__c> mapCaseToHealthEvaluation =
        new Map<Id, UAC_healthEvaluation__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : newItems) {
      mapParentCase.put(assessmentCurrent.UAC_entry__c, null);
    }
    if (!mapParentCase.isEmpty()) {
      for (Case caseCurrent :
          [
            SELECT Id,
            ContactId,
            ParentId,
            Parent.UAC_criminalConcerns__c,
            Parent.UAC_footguide__c,
            UAC_referral__c,
            UAC_referral__r.UAC_criminalConcerns__c,
            UAC_referral__r.UAC_footguide__c,
            Contact.UAC_mppCase__c,
            Contact.UAC_separatedFromParentLegalGuardian__c FROM Case WHERE RecordType.DeveloperName
             =:Label.UAC_caseRecordTypeAdmission AND Id
            IN:mapParentCase.keySet()
          ]) {
        mapParentCase.put(caseCurrent.Id, caseCurrent);
      }
      for (UAC_admissionAssessment__c assessmentCurrent : newItems) {
        assessmentCurrent.UAC_uac__c = mapParentCase.get(assessmentCurrent.UAC_entry__c).ContactId;
        if (String.isNotBlank(mapParentCase.get(assessmentCurrent.UAC_entry__c).UAC_referral__c)) {
          assessmentCurrent.UAC_referral__c =
              mapParentCase.get(assessmentCurrent.UAC_entry__c).UAC_referral__c;
        } else {
          assessmentCurrent.UAC_referral__c =
              mapParentCase.get(assessmentCurrent.UAC_entry__c).ParentId;
        }

        if (setRTypesForAutoPopulation.contains(
                mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName())) {
          // collecting all Case review and Assessment record
          lstNewCaseReview.add(assessmentCurrent);
          setofUAC.add(assessmentCurrent.UAC_uac__c);
        }
        if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
            == Label.UAC_assessmentRecordTypeAssessment) {
          lstNewUACAssessment.add(assessmentCurrent);
        }
      }
      if (!lstNewCaseReview.isEmpty()) {
        setCaseReviewFields(lstNewCaseReview, mapExistingAssessments, setofUAC, mapParentCase);
      }
      if (!lstNewUACAssessment.isEmpty()) {
        syncUACAssessmentFields(lstNewUACAssessment);
      }
      setHealthEvaluationFields(newItems, mapParentCase);
    }
  }

  /**
   * @description Method that checks for duplicates from existing assessments
   * @author James Qian (Deloitte) | 7/14/2020
   * @param List<UAC_admissionAssessment__c>
   * @author Satish Kota (Deloitte) | 03/03/2021
   **/
  public
  static Map<String, List<UAC_admissionAssessment__c>> checkForDuplicates(
      List<UAC_admissionAssessment__c> newItems) {
    Map<String, List<UAC_admissionAssessment__c>> mapCaseExistingAssessments =
        queryExistingAssessments(newItems);
    if (mapCaseExistingAssessments.values().isEmpty()) {
      return mapCaseExistingAssessments;
    }
    List<UAC_admissionAssessment__c> listAssessmentsToUpdate =
        new List<UAC_admissionAssessment__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : newItems) {
      String recordTypeNameStr =
          mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName();
      String strKey = assessmentCurrent.UAC_entry__c + '.' + assessmentCurrent.RecordTypeId;
      if (!mapCaseExistingAssessments.containsKey(strKey)) {
        continue;
      }
      if (recordTypeNameStr == Label.UAC_assessmentRecordTypeISP
          || recordTypeNameStr == Label.UAC_assessmentRecordTypeReview
          || recordTypeNameStr == Label.UAC_assessmentRecordTypeRisk) {
        listAssessmentsToUpdate.addAll(
            checkDuplicateISP(assessmentCurrent, mapCaseExistingAssessments.get(strKey)));
      } else if (recordTypeNameStr == Label.UAC_assessmentRecordTypeAssessment
          && !mapCaseExistingAssessments.get(strKey).isEmpty()) {
        assessmentCurrent.addError(Label.UAC_assessmentErrorUACAssessment);
      } else if (recordTypeNameStr == strInitialIntakesAssessmentRecordType
          && !mapCaseExistingAssessments.get(strKey).isEmpty()) {
        assessmentCurrent.addError(strInitialIntakesAssessmentErrorMessage);
      }
    }
    if (!listAssessmentsToUpdate.isEmpty()) {
      update listAssessmentsToUpdate;
    }
    return mapCaseExistingAssessments;
  }

  /**
   * @description Method on create that sets Case Manager and Clinician lookups based on Case Team
   * @author James Qian (Deloitte) | 7/14/2020
   * @param List<UAC_admissionAssessment__c>
   **/
  public
  static void setDefaultTeamMembers(List<UAC_admissionAssessment__c> newItems) {
    Set<Id> setParentCaseIDs = new Set<Id>();
    for (UAC_admissionAssessment__c assessmentCurrent : newItems) {
      if (!setRecordTypesForTeamMembers.contains(
              mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName())) {
        continue;
      }
      setParentCaseIDs.add(assessmentCurrent.UAC_entry__c);
    }
    Map<String, Id> mapCaseIdRoleToUserId = getParentCaseTeamMembers(setParentCaseIDs);
    if (mapCaseIdRoleToUserId.isEmpty()) {
      return;
    }
    for (UAC_admissionAssessment__c assessmentCurrent : newItems) {
      if (!setRecordTypesForTeamMembers.contains(
              mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName())) {
        continue;
      }
      String strClinicianKey =
          Label.UAC_caseTeamRoleNameClinician + '.' + assessmentCurrent.UAC_entry__c;
      String strCaseManagerKey =
          Label.UAC_caseTeamRoleNameCM + '.' + assessmentCurrent.UAC_entry__c;
      if (mapCaseIdRoleToUserId.containsKey(strClinicianKey)) {
        assessmentCurrent.UAC_clinicianLookup__c = mapCaseIdRoleToUserId.get(strClinicianKey);
      }
      if (mapCaseIdRoleToUserId.containsKey(strCaseManagerKey)) {
        assessmentCurrent.UAC_caseManagerLookup__c = mapCaseIdRoleToUserId.get(strCaseManagerKey);
      }
    }
  }

  /**
   * @description Sets IME ID for UAC to link medication records.
   * @author James Qian (Deloitte) | 10/6/2020
   * @param List<UAC_admissionAssessment__c> listAdmissionAssessments
   **/
  public
  static void setImeOnIntakesAssessments(
      List<UAC_admissionAssessment__c> listAdmissionAssessments) {
    Map<ID, ID> mapUacInitialAdmAssesments = new Map<ID, ID>();
    for (UAC_admissionAssessment__c adm : listAdmissionAssessments) {
      if (mapRecordTypes.get(adm.RecordTypeId).getDeveloperName()
          == strInitialIntakesAssessmentRecordType) {
        mapUacInitialAdmAssesments.put(adm.UAC_uac__c, null);
      }
    }
    if (mapUacInitialAdmAssesments.isEmpty()) {
      return;
    }
    for (UAC_healthEvaluation__c healthEvaluationCurrent : [
           SELECT Id,
           UAC_associatedUAC__c FROM UAC_healthEvaluation__c WHERE UAC_associatedUAC__c
           IN:mapUacInitialAdmAssesments.keyset() AND RecordType.DeveloperName
            =:Label.UAC_healthEvaluationRecordTypeApiNameIME ORDER BY CreatedDate ASC
         ]) {
      mapUacInitialAdmAssesments.put(
          healthEvaluationCurrent.UAC_associatedUAC__c, healthEvaluationCurrent.Id);
    }
    for (UAC_admissionAssessment__c adm : listAdmissionAssessments) {
      if (mapRecordTypes.get(adm.RecordTypeId).getDeveloperName()
              == strInitialIntakesAssessmentRecordType
          && mapUacInitialAdmAssesments.containsKey(adm.UAC_uac__c)
          && mapUacInitialAdmAssesments.get(adm.UAC_uac__c) != null) {
        adm.UAC_healthEvaluationIme__c = mapUacInitialAdmAssesments.get(adm.UAC_uac__c);
      }
    }
  }

  /**
   * @description Method on update that locks fields if status is submitted.
   * @author James Qian (Deloitte) | 7/14/2020
   * @param Map<Id, UAC_admissionAssessment__c> newItems
   * @param Map<Id, UAC_admissionAssessment__c> oldItems
   **/
  public
  static void validateFieldsOnUpdate(
      Map<Id, UAC_admissionAssessment__c> newItems, Map<Id, UAC_admissionAssessment__c> oldItems) {
    List<UAC_admissionAssessment__c> listAssessmentsSubmitted =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsPending =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsNowSubmitted =
        new List<UAC_admissionAssessment__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : newItems.values()) {
      if (assessmentCurrent.UAC_assessmentStatus__c == Label.UAC_assessmentStatusSubmitted) {
        listAssessmentsSubmitted.add(assessmentCurrent);
        if (oldItems.get(assessmentCurrent.Id).UAC_assessmentStatus__c
            == Label.UAC_assessmentStatusPending) {
          listAssessmentsNowSubmitted.add(assessmentCurrent);
          assessmentCurrent.UAC_submittedDateTime__c = System.now();
        }
      } else if (assessmentCurrent.UAC_assessmentStatus__c == Label.UAC_assessmentStatusPending) {
        listAssessmentsPending.add(assessmentCurrent);
      }
    }
    if (!listAssessmentsSubmitted.isEmpty()) {
      List<Schema.FieldSetMember> listFieldsToLock = getFieldsToLock('UAC_postSubmitLockedFields');
      for (UAC_admissionAssessment__c assessmentCurrent : listAssessmentsSubmitted) {
        checkFieldsToLock(assessmentCurrent, oldItems.get(assessmentCurrent.Id), listFieldsToLock);
      }
    }
    if (!listAssessmentsPending.isEmpty()) {
      checkDependentFields(listAssessmentsPending);
    }
    if (!listAssessmentsNowSubmitted.isEmpty()) {
      checkRequiredFieldsOnSubmit(listAssessmentsNowSubmitted);
    }
  }

  /**
   * @description Method on update that sets fields.
   * @author James Qian (Deloitte) | 7/14/2020
   * @param Map<Id, UAC_admissionAssessment__c> newItems
   * @param Map<Id, UAC_admissionAssessment__c> oldItems
   **/
  public
  static void setFieldsOnUpdate(
      Map<Id, UAC_admissionAssessment__c> newItems, Map<Id, UAC_admissionAssessment__c> oldItems) {
    for (UAC_admissionAssessment__c assessmentCurrent : newItems.values()) {
      if (assessmentCurrent.UAC_assessmentStatus__c
          == oldItems.get(assessmentCurrent.Id).UAC_assessmentStatus__c) {
        continue;
      }
      if (assessmentCurrent.UAC_assessmentStatus__c == Label.UAC_assessmentStatusSubmitted) {
        assessmentCurrent.UAC_submittedDate__c = System.today();
      } else {
        assessmentCurrent.UAC_submittedDate__c = null;
      }
    }
  }

  /**
   * @description Updates parent contact primary language
   * @author James Qian (Deloitte) | 10/6/2020
   * @param Map<Id, UAC_admissionAssessment__c> mapAdmissionAssessmentsNew
   * @param Map<Id, UAC_admissionAssessment__c> mapAdmissionAssessmentsOld
   **/
  public
  static void updateParentContactPrimaryLanguage(
      Map<Id, UAC_admissionAssessment__c> mapAdmissionAssessmentsNew,
      Map<Id, UAC_admissionAssessment__c> mapAdmissionAssessmentsOld) {
    Map<Id, String> mapContactToNewLanguage = new Map<Id, String>();
    for (UAC_admissionAssessment__c assessmentCurrent : mapAdmissionAssessmentsNew.values()) {
      if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
              == strInitialIntakesAssessmentRecordType
          && assessmentCurrent.UAC_primaryLanguageSpoken__c
              != mapAdmissionAssessmentsOld.get(assessmentCurrent.Id).UAC_primaryLanguageSpoken__c
          && String.isNotBlank(assessmentCurrent.UAC_primaryLanguageSpoken__c)) {
        mapContactToNewLanguage.put(
            assessmentCurrent.UAC_uac__c, assessmentCurrent.UAC_primaryLanguageSpoken__c);
      }
    }
    if (!mapContactToNewLanguage.isEmpty()) {
      List<Contact> listContactsToUpdate = new List<Contact>();
      for (Id key : mapContactToNewLanguage.keyset()) {
        listContactsToUpdate.add(
            new Contact(Id = key, UAC_primaryLanguageSpoken__c = mapContactToNewLanguage.get(key)));
      }
      if (listContactsToUpdate != null && !listContactsToUpdate.isEmpty()) {
        update listContactsToUpdate;
      }
    }
  }

  /**
   * @description Method that gets a field set based on a field set api name
   * @author James Qian (Deloitte) | 7/14/2020
   * @param String strFieldSetName
   **/
  private
  static List<Schema.FieldSetMember> getFieldsToLock(String strFieldSetName) {
    return Schema.getGlobalDescribe()
        .get(Label.UAC_assessmentObjectAPIName)
        .getDescribe()
        .FieldSets.getMap()
        .get(strFieldSetName)
        .getFields();
  }

  /**
   * @description Method that loops through a field set for a specified record and throws an error
   * if a field is changed.
   * @author James Qian (Deloitte) | 7/14/2020
   * @param UAC_admissionAssessment__c assessment
   * @param UAC_admissionAssessment__c assessmentOld
   * @param List<Schema.FieldSetMember> listFieldsToLock
   **/
  private
  static void checkFieldsToLock(UAC_admissionAssessment__c assessment,
      UAC_admissionAssessment__c assessmentOld,
      List<Schema.FieldSetMember> listFieldsToLock) {
    for (Schema.FieldSetMember currentField : listFieldsToLock) {
      if (assessment.get(currentField.getFieldPath())
          != assessmentOld.get(currentField.getFieldPath())) {
        assessment.addError(
            'Your assessment has been submitted so you are unable to change the following field: '
            + currentField.getLabel());
      }
    }
  }

  /**
   * @description Method that loops through the field dependency custom metadata type and throws
   *errors
   * @author James Qian (Deloitte) | 7/23/2020
   * @param List<UAC_admissionAssessment__c> listAssessmentsPending
   **/
  private
  static void checkDependentFields(List<UAC_admissionAssessment__c> listAssessmentsPending) {
    Map<String, Schema.sObjectField> assessmentFieldLabelMap =
        Schema.SObjectType.UAC_admissionAssessment__c.fields.getMap();
    List<UAC_admissionAssessmentFieldDependency__mdt> listDependenciesAssessment =
        [SELECT UAC_controllingFieldName__c,
          UAC_dependentFieldName__c,
          UAC_customErrorMessage__c FROM UAC_admissionAssessmentFieldDependency__mdt WHERE
              UAC_recordTypeDeveloperName__c =:Label.UAC_assessmentRecordTypeAssessment];
    List<UAC_admissionAssessmentFieldDependency__mdt> listDependenciesRisk =
        [SELECT UAC_controllingFieldName__c,
          UAC_dependentFieldName__c,
          UAC_customErrorMessage__c FROM UAC_admissionAssessmentFieldDependency__mdt WHERE
              UAC_recordTypeDeveloperName__c =:Label.UAC_assessmentRecordTypeRisk];
    List<UAC_admissionAssessmentFieldDependency__mdt> listDependenciesInitialIntakesAssessment =
        [SELECT UAC_controllingFieldName__c,
          UAC_dependentFieldName__c,
          UAC_customErrorMessage__c FROM UAC_admissionAssessmentFieldDependency__mdt WHERE
              UAC_recordTypeDeveloperName__c =:strInitialIntakesAssessmentRecordType];
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessmentsPending) {
      if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
          == Label.UAC_assessmentRecordTypeRisk) {
        checkDependentFields(assessmentCurrent, listDependenciesRisk, assessmentFieldLabelMap);
      } else if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
              == Label.UAC_assessmentRecordTypeAssessment
          || mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
              == Label.UAC_assessmentRecordTypeReview) {
        checkDependentFields(
            assessmentCurrent, listDependenciesAssessment, assessmentFieldLabelMap);
      } else if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
          == strInitialIntakesAssessmentRecordType) {
        checkDependentFields(
            assessmentCurrent, listDependenciesInitialIntakesAssessment, assessmentFieldLabelMap);
      }
    }
  }

  /**
   * @description Method that the required field metadata type and throws errors
   * @author James Qian (Deloitte) | 7/23/2020
   * @param List<UAC_admissionAssessment__c> listAssessmentsPending
   **/
  private
  static void checkRequiredFieldsOnSubmit(
      List<UAC_admissionAssessment__c> listAssessmentsNowSubmitted) {
    Map<String, Schema.sObjectField> assessmentFieldLabelMap =
        Schema.SObjectType.UAC_admissionAssessment__c.fields.getMap();
    Map<String, List<UAC_admissionAssessmentRequiredField__mdt>> mapRequiredFieldsByRecordType =
        new Map<String, List<UAC_admissionAssessmentRequiredField__mdt>>();
    for (UAC_admissionAssessmentRequiredField__mdt metadataCurrent : [
           SELECT UAC_recordTypeDeveloperName__c,
           UAC_fieldAPIName__c,
           UAC_sectionName__c,
           UAC_customFieldLabel__c FROM UAC_admissionAssessmentRequiredField__mdt
         ]) {
      List<UAC_admissionAssessmentRequiredField__mdt> listMetadataRecords;
      if (mapRequiredFieldsByRecordType.containsKey(
              metadataCurrent.UAC_recordTypeDeveloperName__c)) {
        listMetadataRecords =
            mapRequiredFieldsByRecordType.get(metadataCurrent.UAC_recordTypeDeveloperName__c);
      } else {
        listMetadataRecords = new List<UAC_admissionAssessmentRequiredField__mdt>();
      }
      listMetadataRecords.add(metadataCurrent);
      mapRequiredFieldsByRecordType.put(
          metadataCurrent.UAC_recordTypeDeveloperName__c, listMetadataRecords);
    }
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessmentsNowSubmitted) {
      if (!mapRecordTypes.containsKey(assessmentCurrent.RecordTypeId)) {
        continue;
      }
      if (mapRequiredFieldsByRecordType.containsKey(
              mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName())) {
        checkRequiredFields(assessmentCurrent,
            mapRequiredFieldsByRecordType.get(
                mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()),
            assessmentFieldLabelMap);
      }
    }
  }

  /**
   * @description Method that loops through a field set for a specified record and throws an error
   * if a field is changed.
   * @author James Qian (Deloitte) | 7/14/2020
   * @param UAC_admissionAssessment__c assessment
   * @param UAC_admissionAssessment__c assessmentOld
   * @param List<Schema.FieldSetMember> listFieldsToLock
   **/
  private
  static void checkDependentFields(UAC_admissionAssessment__c assessment,
      List<UAC_admissionAssessmentFieldDependency__mdt> listDependencies,
      Map<String, Schema.sObjectField> assessmentFieldLabelMap) {
    List<String> listStrError = new List<String>();
    for (UAC_admissionAssessmentFieldDependency__mdt currentDependency : listDependencies) {
      if (String.valueOf(assessment.get(currentDependency.UAC_controllingFieldName__c)) == 'Yes'
          && String.isBlank(
              String.valueOf(assessment.get(currentDependency.UAC_dependentFieldName__c)))) {
        String strErrorMessage;
        if (String.isNotBlank(currentDependency.UAC_customErrorMessage__c)) {
          strErrorMessage = currentDependency.UAC_customErrorMessage__c;
        } else {
          strErrorMessage = 'Please enter a value for: '
              + assessmentFieldLabelMap.get(currentDependency.UAC_dependentFieldName__c)
                    .getDescribe()
                    .getLabel();
        }
        listStrError.add(strErrorMessage);
      }
    }
    if (!listStrError.isEmpty()) {
      assessment.addError(String.join(listStrError, ', '));
    }
  }

  /**
   * @description Method that loops through a list of custom metadata records and throws errors
   * @author James Qian (Deloitte) | 7/23/2020
   * @param UAC_admissionAssessment__c assessment
   * @param List<UAC_admissionAssessmentRequiredField__mdt> listRequiredFields
   **/
  private
  static void checkRequiredFields(UAC_admissionAssessment__c assessment,
      List<UAC_admissionAssessmentRequiredField__mdt> listRequiredFields,
      Map<String, Schema.sObjectField> assessmentFieldLabelMap) {
    List<String> listStrError = new List<String>();
    for (UAC_admissionAssessmentRequiredField__mdt currentRequiredField : listRequiredFields) {
      if (String.isBlank(
              String.valueOf(assessment.get(currentRequiredField.UAC_fieldAPIName__c)))) {
        String strErrorMessage = 'Required field missing';
        if (String.isNotBlank(currentRequiredField.UAC_sectionName__c)) {
          strErrorMessage += ' in section "' + currentRequiredField.UAC_sectionName__c + '": ';
        } else {
          strErrorMessage += ': ';
        }
        if (String.isNotBlank(currentRequiredField.UAC_customFieldLabel__c)) {
          strErrorMessage += currentRequiredField.UAC_customFieldLabel__c;
        } else {
          strErrorMessage += assessmentFieldLabelMap.get(currentRequiredField.UAC_fieldAPIName__c)
                                 .getDescribe()
                                 .getLabel();
        }
        listStrError.add(strErrorMessage);
      }
    }
    if (!listStrError.isEmpty()) {
      assessment.addError(String.join(listStrError, ', '));
    }
  }

  /**
   * @description Sets height, weight, and bmi for risk assessment.
   * @author James Qian (Deloitte) | 7/16/2020
   * @param List<UAC_admissionAssessment__c> listAdmissionAssessments
   * @param Map<Id, Id> mapCaseToContactIds
   **/
  private
  static void setHealthEvaluationFields(
      List<UAC_admissionAssessment__c> listAdmissionAssessments, Map<Id, Case> mapParentCase) {
    Map<Id, Id> mapRiskAssessmentToContact = new Map<Id, Id>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAdmissionAssessments) {
      if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
          == Label.UAC_assessmentRecordTypeRisk) {
        mapRiskAssessmentToContact.put(assessmentCurrent.UAC_entry__c,
            mapParentCase.get(assessmentCurrent.UAC_entry__c).ContactId);
      }
    }
    if (mapRiskAssessmentToContact.isEmpty()) {
      return;
    }
    Map<Id, UAC_healthEvaluation__c> mapContactToHealthEvaluation =
        new Map<Id, UAC_healthEvaluation__c>();
    for (UAC_healthEvaluation__c queriedEvaluation : [SELECT Id,
           UAC_associatedUAC__c,
           UAC_measuredHeightInches__c,
           UAC_weightPounds__c,
           UAC_BMIPercentile__c FROM UAC_healthEvaluation__c WHERE UAC_associatedUAC__c
           IN:mapRiskAssessmentToContact.values() ORDER BY LastModifiedDate ASC]) {
      mapContactToHealthEvaluation.put(queriedEvaluation.UAC_associatedUAC__c, queriedEvaluation);
    }
    if (mapContactToHealthEvaluation.isEmpty()) {
      return;
    }
    for (UAC_admissionAssessment__c assessmentCurrent : listAdmissionAssessments) {
      if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
              == Label.UAC_assessmentRecordTypeRisk
          && mapContactToHealthEvaluation.containsKey(
              mapRiskAssessmentToContact.get(assessmentCurrent.UAC_entry__c))) {
        assessmentCurrent.UAC_height__c =
            mapContactToHealthEvaluation
                .get(mapRiskAssessmentToContact.get(assessmentCurrent.UAC_entry__c))
                .UAC_measuredHeightInches__c;
        assessmentCurrent.UAC_weight__c =
            mapContactToHealthEvaluation
                .get(mapRiskAssessmentToContact.get(assessmentCurrent.UAC_entry__c))
                .UAC_weightPounds__c;
        assessmentCurrent.UAC_bMI__c =
            mapContactToHealthEvaluation
                .get(mapRiskAssessmentToContact.get(assessmentCurrent.UAC_entry__c))
                .UAC_BMIPercentile__c;
      }
    }
  }

  /**
   * @description Autopopulation fields on Case review .
   * @author chaitanya Nandamuri (Deloitte) | 7/22/2020
   * @param List<UAC_admissionAssessment__c> listAdmissionAssessments
   * @param Map<Id, Id> mapCaseToContactIds
   **/
  private
  static void setCaseReviewFields(List<UAC_admissionAssessment__c> NewCaseReview,
      Map<string, List<UAC_admissionAssessment__c>> mapExistingAssessments,
      Set<Id> setofUAC,
      Map<Id, Case> mapParentCase) {
    Map<id, set<String>> mapUACtoSetAllergy = new Map<id, Set<String>>();
    Map<Id, UAC_admissionAssessment__c> mapCaseToAssessment =
        new Map<Id, UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstOfUACAssessments = [
      SELECT Id,
      UAC_criminalConcerns__c,
      UAC_footguide__c,
      UAC_entry__c FROM UAC_admissionAssessment__c WHERE recordType.DeveloperName
       =:Label.UAC_assessmentRecordTypeAssessment AND UAC_entry__c
      IN:mapParentCase.keySet()
    ];
    for (UAC_admissionAssessment__c objAssessment : lstOfUACAssessments) {
      if (!mapCaseToAssessment.containsKey(objAssessment.UAC_entry__c)) {
        mapCaseToAssessment.put(objAssessment.UAC_entry__c, objAssessment);
      }
    }
    for (UAC_allergy__c allergy : [select id,
           UAC_allergen__c,
           UAC_associatedUAC__c from UAC_allergy__c where UAC_associatedUAC__c In:setofUAC]) {
      set<string> alleryNames;
      if (mapUACtoSetAllergy.containsKey(allergy.UAC_associatedUAC__c)) {
        alleryNames = mapUACtoSetAllergy.get(allergy.UAC_associatedUAC__c);
      } else {
        alleryNames = new set<String>();
      }
      alleryNames.add(allergy.UAC_allergen__c);
      mapUACtoSetAllergy.put(allergy.UAC_associatedUAC__c, alleryNames);
    }

    for (UAC_admissionAssessment__c currentCaseReview : NewCaseReview) {
      if (mapUACtoSetAllergy.get(currentCaseReview.UAC_uac__c) != null) {
        currentCaseReview.UAC_listAnyAllergies__c = String.join(
            (Iterable<String>) mapUACtoSetAllergy.get(currentCaseReview.UAC_uac__c), ',');
      }
      if (!mapParentCase.containsKey(currentCaseReview.UAC_entry__c)
          || mapParentCase.get(currentCaseReview.UAC_entry__c) == null) {
        continue;
      }
      if (String.isNotBlank(mapParentCase.get(currentCaseReview.UAC_entry__c).ContactId)) {
        currentCaseReview.UAC_migrantProtectionProtocolCase__c =
            mapParentCase.get(currentCaseReview.UAC_entry__c).Contact.UAC_mppCase__c ? 'Yes' : 'No';
        currentCaseReview.UAC_separatedfromParentsLegalGuardianNew__c =
            mapParentCase.get(currentCaseReview.UAC_entry__c)
                .Contact.UAC_separatedFromParentLegalGuardian__c
            ? 'Yes'
            : 'No';
      }
      if (mapCaseToAssessment.get(currentCaseReview.UAC_entry__c) != null) {
        currentCaseReview.UAC_criminalConcerns__c =
            mapCaseToAssessment.get(currentCaseReview.UAC_entry__c).UAC_criminalConcerns__c;
        currentCaseReview.UAC_footguide__c =
            mapCaseToAssessment.get(currentCaseReview.UAC_entry__c).UAC_footguide__c;
      } else if (String.isNotBlank(
                     mapParentCase.get(currentCaseReview.UAC_entry__c).UAC_referral__c)) {
        currentCaseReview.UAC_criminalConcerns__c =
            mapParentCase.get(currentCaseReview.UAC_entry__c)
                .UAC_referral__r.UAC_criminalConcerns__c;
        currentCaseReview.UAC_footguide__c =
            mapParentCase.get(currentCaseReview.UAC_entry__c).UAC_referral__r.UAC_footguide__c;
      } else if (String.isNotBlank(mapParentCase.get(currentCaseReview.UAC_entry__c).ParentId)) {
        currentCaseReview.UAC_criminalConcerns__c =
            mapParentCase.get(currentCaseReview.UAC_entry__c).Parent.UAC_criminalConcerns__c;
        currentCaseReview.UAC_footguide__c =
            mapParentCase.get(currentCaseReview.UAC_entry__c).Parent.UAC_footguide__c;
      }
      if (mapExistingAssessments.isEmpty()) {
        continue;
      }
      if (mapExistingAssessments.get(
              currentCaseReview.UAC_entry__c + '.' + InitialIntakesRecordTypeId)
          != null) {
        PopulateInitialIntakeIntoReview(currentCaseReview,
            mapExistingAssessments.get(
                currentCaseReview.UAC_entry__c + '.' + InitialIntakesRecordTypeId));
      }
      if (mapExistingAssessments.get(
              currentCaseReview.UAC_entry__c + '.' + UacAssessmentRecordTypeId)
          != null) {
        PopulateAssessmentIntoReview(currentCaseReview,
            mapExistingAssessments.get(
                currentCaseReview.UAC_entry__c + '.' + UacAssessmentRecordTypeId));
      }
    }
  }

  /**
   * @description Method that loops through Existing IntitalIntakes field and Populates on
   *CaseReview and Assessment
   * @author Chaitanya Nandamuri (Deloitte) | 7/23/2020
   * @param UAC_admissionAssessment__c assessmentCurrent
   * @param
   **/
  private
  static void PopulateInitialIntakeIntoReview(UAC_admissionAssessment__c currentCaseReview,
      List<UAC_admissionAssessment__c> mapExistingAssessments) {

    for (UAC_admissionAssessment__c assessmentToPopulate : mapExistingAssessments) {

      if (!assessmentToPopulate.UAC_mostRecentAssessment__c) {
        continue;
      }
      currentCaseReview.UAC_cityofBirth__c = assessmentToPopulate.UAC_cityofBirth__c;
      currentCaseReview.UAC_neighborhoodofBirth__c =
          assessmentToPopulate.UAC_neighborhoodofBirth__c;
      currentCaseReview.UAC_whodidUAClivewithbeforeplacement__c =
          assessmentToPopulate.UAC_whodidUAClivewithbeforeplacement__c;
      currentCaseReview.UAC_religiousAffiliation__c =
          assessmentToPopulate.UAC_religiousAffiliation__c;
      if (currentCaseReview.RecordTypeId == UacAssessmentRecordTypeId) {
        currentCaseReview.UAC_whereWereYouPlanningonLiving__c =
            assessmentToPopulate.UAC_whereWereYouPlanningonLiving__c;
      }
    }
  }

  /**
   * @description Method that loops through Existing Assessment field and Populates on CaseReview
   * @author Chaitanya Nandamuri (Deloitte) | 7/23/2020
   * @param UAC_admissionAssessment__c assessmentCurrent
   * @param
   **/
  private
  static void PopulateAssessmentIntoReview(UAC_admissionAssessment__c currentCaseReview,
      List<UAC_admissionAssessment__c> mapExistingAssessments) {
    if (currentCaseReview.RecordTypeId != UacCaseReviewTypeId) {
      return;
    }

    for (UAC_admissionAssessment__c assessmentToPopulate : mapExistingAssessments) {
      if (!assessmentToPopulate.UAC_mostRecentAssessment__c) {
        continue;
      }
      for (string field : caseReviewFieldSet) {
        currentCaseReview.put(field, assessmentToPopulate.get(field));
      }
    }
  }

  /**
   * @description Method that loops through a field set for a specified record and throws an error
   * if a field is changed.
   * @author James Qian (Deloitte) | 7/14/2020
   * @param UAC_admissionAssessment__c assessmentCurrent
   * @param List<UAC_admissionAssessment__c> listAssessmentsToCompare
   **/
  private
  static List<UAC_admissionAssessment__c> checkDuplicateISP(
      UAC_admissionAssessment__c assessmentCurrent,
      List<UAC_admissionAssessment__c> listAssessmentsToCompare) {
    List<UAC_admissionAssessment__c> listAssessmentsToUpdate =
        new List<UAC_admissionAssessment__c>();
    String recordTypeName = mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName();
    String ErrorMsg;
    if (recordTypeName == Label.UAC_assessmentRecordTypeISP) {
      ErrorMsg = Label.UAC_assessmentErrorDuplicateISP;
    } else if (recordTypeName == Label.UAC_assessmentRecordTypeReview) {
      ErrorMsg = Label.UAC_assessmentErrorDuplicateProvider;
    } else if (recordTypeName == Label.UAC_assessmentRecordTypeRisk) {
      ErrorMsg = Label.UAC_assessmentErrorDuplicateRisk;
    }
    for (UAC_admissionAssessment__c assessmentToCompare : listAssessmentsToCompare) {
      if (assessmentToCompare.UAC_assessmentStatus__c == Label.UAC_assessmentStatusPending) {
        assessmentCurrent.addError(ErrorMsg);
      } else if (assessmentToCompare.UAC_mostRecentAssessment__c) {
        listAssessmentsToUpdate.add(new UAC_admissionAssessment__c(
            Id = assessmentToCompare.Id, UAC_mostRecentAssessment__c = false));
      }
    }
    return listAssessmentsToUpdate;
  }

  /**
   * @description Method that queries existing sibling assessments for duplicate check
   * @author James Qian (Deloitte) | 7/14/2020
   * @param List<UAC_admissionAssessment__c>
   * @param Map<String, List<UAC_admissionAssessment__c>>
   **/
  private
  static Map<String, List<UAC_admissionAssessment__c>> queryExistingAssessments(
      List<UAC_admissionAssessment__c> newItems) {
    Map<String, List<UAC_admissionAssessment__c>> mapCaseExistingAssessments =
        new Map<String, List<UAC_admissionAssessment__c>>();
    Set<Id> setParentCases = new Set<Id>();
    for (UAC_admissionAssessment__c assessmentCurrent : newItems) {
      setParentCases.add(assessmentCurrent.UAC_entry__c);
    }
    List<UAC_admissionAssessment__c> listExistingSiblingsAssessment;
    String queryBase =
        'SELECT Id, UAC_entry__c,RecordTypeId,UAC_assessmentStatus__c,CreatedDate,UAC_mostRecentAssessment__c,UAC_entry__r.Account.Type,UAC_entry__r.UAC_programType__c,UAC_cityofBirth__c , UAC_neighborhoodofBirth__c,UAC_whodidUAClivewithbeforeplacement__c,UAC_religiousAffiliation__c,UAC_whereWereYouPlanningonLiving__c  ';
    String queryEnd = ' FROM UAC_admissionAssessment__c WHERE UAC_entry__c IN:setParentCases';

    for (Schema.FieldSetMember fieldSetMemberObj : UAC_utilities.getFieldSet(
             'UAC_admissionAssessment__c', 'UAC_caseReviewPrepopulationFields')) {
      caseReviewFieldSet.add(fieldSetMemberObj.getFieldPath());
      queryBase += ', ' + fieldSetMemberObj.getFieldPath();
    }
    queryBase += queryEnd;
    listExistingSiblingsAssessment = Database.query(queryBase);
    for (UAC_admissionAssessment__c assessmentCurrent : listExistingSiblingsAssessment) {
      List<UAC_admissionAssessment__c> listAssessments;
      String strKey = assessmentCurrent.UAC_entry__c + '.' + assessmentCurrent.RecordTypeId;
      if (mapCaseExistingAssessments.containsKey(strKey)) {
        listAssessments = mapCaseExistingAssessments.get(strKey);
      } else {
        listAssessments = new List<UAC_admissionAssessment__c>();
      }
      listAssessments.add(assessmentCurrent);
      mapCaseExistingAssessments.put(strKey, listAssessments);
    }
    return mapCaseExistingAssessments;
  }

  /**
   * @description Method that queries existing case team members
   * @author James Qian (Deloitte) | 7/14/2020
   * @param Set<Id> setCaseIds
   * @param Map<String, Id>
   **/
  private
  static Map<String, Id> getParentCaseTeamMembers(Set<Id> setCaseIds) {
    Map<String, Id> mapCaseIdRoleToUserId = new Map<String, Id>();
    if (setCaseIds.isEmpty()) {
      return mapCaseIdRoleToUserId;
    }
    Set<String> setTeamMemberRoles =
        new Set<String>{Label.UAC_caseTeamRoleNameClinician, Label.UAC_caseTeamRoleNameCM};
    for (CaseTeamMember caseTeamMemberCurrent : [
           SELECT Id,
           ParentId,
           MemberId,
           TeamRole.Name FROM CaseTeamMember WHERE ParentId IN:setCaseIds AND TeamRole.Name
                                                            IN:setTeamMemberRoles
         ]) {
      mapCaseIdRoleToUserId.put(
          caseTeamMemberCurrent.TeamRole.Name + '.' + caseTeamMemberCurrent.ParentId,
          caseTeamMemberCurrent.MemberId);
    }
    return mapCaseIdRoleToUserId;
  }
  /**
   * @description Email Notification to Clincian and Lead Clincian
   * @author Karthi Subramanian (Deloitte) | 10/12/2020
   * @param Map<Id, UAC_admissionAssessment__c> mapNewIntakeAssesment
   * @param Map<Id, UAC_admissionAssessment__c> mapOldIntakeAssesment
   **/
  public
  static void intakeAssesmentEmailToClinician(
      Map<Id, UAC_admissionAssessment__c> mapNewIntakeAssesment,
      Map<Id, UAC_admissionAssessment__c> mapOldIntakeAssesment) {

    Map<Id, UAC_admissionAssessment__c> mapIntakeAssesmentUpd =
        new Map<Id, UAC_admissionAssessment__c>();
    Map<Id, UAC_admissionAssessment__c> mapIntakeAssesmentVictimUpd =
        new Map<Id, UAC_admissionAssessment__c>();
    Map<Id, UAC_admissionAssessment__c> mapIntakeAssesmentNonPrescribedUpd =
        new Map<Id, UAC_admissionAssessment__c>();

    for (UAC_admissionAssessment__c objNewAdmission : mapNewIntakeAssesment.values()) {
      UAC_admissionAssessment__c objOldAdmission =
          (mapOldIntakeAssesment != null) ? mapOldIntakeAssesment.get(objNewAdmission.Id) : null;
      if (objOldAdmission != null) {
        if ((objOldAdmission.UAC_thoughtsOfHurtingYourselfOrOthers__c
                != objNewAdmission.UAC_thoughtsOfHurtingYourselfOrOthers__c)
            && (objNewAdmission.UAC_thoughtsOfHurtingYourselfOrOthers__c == System.label.UAC_Yes)) {
          mapIntakeAssesmentUpd.put(objNewAdmission.Id, objNewAdmission);
        }
        if ((objOldAdmission.UAC_victimOfSexualAssaultRapedLast72__c
                != objNewAdmission.UAC_victimOfSexualAssaultRapedLast72__c)
            && (objNewAdmission.UAC_victimOfSexualAssaultRapedLast72__c == System.label.UAC_Yes)) {
          mapIntakeAssesmentVictimUpd.put(objNewAdmission.Id, objNewAdmission);
        }
        if ((objOldAdmission.UAC_takingAnythingOtherThanPrescribed__c
                != objNewAdmission.UAC_takingAnythingOtherThanPrescribed__c)
            && (objNewAdmission.UAC_takingAnythingOtherThanPrescribed__c == System.label.UAC_Yes)) {
          mapIntakeAssesmentNonPrescribedUpd.put(objNewAdmission.Id, objNewAdmission);
        }
      }
    }

    if (mapIntakeAssesmentUpd.size() > 0) {
      sendEmailToClinicianRole(mapIntakeAssesmentUpd);
    }
    if (mapIntakeAssesmentVictimUpd.size() > 0) {
      sendEmailToCaseAndAccountTeam(mapOldIntakeAssesment, mapIntakeAssesmentVictimUpd);
    }
    if (mapIntakeAssesmentNonPrescribedUpd.size() > 0) {
      sendEmailToCaseAndAccountTeam(mapOldIntakeAssesment, mapIntakeAssesmentNonPrescribedUpd);
    }
  }

  /**
   * @description ORRUAC-2786 - Send Email to Clinician and Lead Clinican based on Intake Assesment
   *input
   * @author Karthi Subramanian (Deloitte) | 10/12/2020
   * @param Map<Id,UAC_admissionAssessment__c>
   * @return void
   **/
  public
  static void sendEmailToClinicianRole(Map<Id, UAC_admissionAssessment__c> mapIntakeAssesment) {

    List<EmailTemplate> objTemplateClincian =
        [select id, developername from emailtemplate where developername
          =:Label.UAC_intakeAssesmentHarmingEmailTemplate];
    Set<Id> setCases = new Set<Id>();
    Set<String> setCaseTeamRoleName =
        new set<String>{Label.UAC_caseTeamRoleNameClinician, Label.UAC_caseTeamRoleNameLC};
    Map<Id, List<String>> mapIdIntakeAssesmentEmail = new Map<Id, List<String>>();
    Map<Id, List<CaseTeamMember>> mapCaseIdCaseTM = new Map<Id, List<CaseTeamMember>>();

    // Add Case Ids to set
    for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
      if (objIntakeAssesment.UAC_entry__c != null) setCases.add(objIntakeAssesment.UAC_entry__c);
    }

    // Create a Map for Intake Assesment Id and  CaseTeammember
    Map<Id, CaseTeamMember> mapCaseTeam = new Map<Id, CaseTeamMember>([
      Select Id,
      MemberId,
      ParentId,
      TeamRoleId,
      Member.Email from CaseTeamMember where TeamRole.Name in:setCaseTeamRoleName and ParentId
                                                           in:setCases
    ]);

    for (CaseTeamMember objCaseTM : mapCaseTeam.values()) {

      if (mapCaseIdCaseTM.containsKey(objCaseTM.ParentId)) {
        List<CaseTeamMember> lstCaseTM = mapCaseIdCaseTM.get(objCaseTM.ParentId);
        lstCaseTM.add(objCaseTM);
        mapCaseIdCaseTM.put(objCaseTM.ParentId, lstCaseTM);
      } else {
        List<CaseTeamMember> lstNewCaseTM = new List<CaseTeamMember>();
        lstNewCaseTM.add(objCaseTM);
        mapCaseIdCaseTM.put(objCaseTM.ParentId, lstNewCaseTM);
      }
    }

    for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
      for (CaseTeamMember objCaseTeam : mapCaseTeam.values()) {
        if (objCaseTeam.ParentId == objIntakeAssesment.UAC_entry__c) {
          if (mapCaseIdCaseTM.containsKey(objCaseTeam.ParentId)) {
            List<CaseTeamMember> lstNewCaseTM = mapCaseIdCaseTM.get(objCaseTeam.ParentId);
            List<String> lstStrEmail = new List<String>();
            for (CaseTeamMember objCaseTM : lstNewCaseTM) {
              lstStrEmail.add(objCaseTM.Member.Email);
            }
            if (!mapIdIntakeAssesmentEmail.containsKey(objIntakeAssesment.Id))
              mapIdIntakeAssesmentEmail.put(objIntakeAssesment.Id, lstStrEmail);
          }
          break;
        }
      }
    }

    List<Messaging.SingleEmailMessage> lstmessages = new List<Messaging.SingleEmailMessage>();
    if (!objTemplateClincian.isEmpty()) {
      for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
        if (mapIdIntakeAssesmentEmail.size() > 0) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.toAddresses = mapIdIntakeAssesmentEmail.get(objIntakeAssesment.Id);
          message.setTemplateId(objTemplateClincian[0].id);
          message.settargetObjectId(objIntakeAssesment.UAC_uac__c);
          message.setWhatId(objIntakeAssesment.Id);
          message.setTreatTargetObjectAsRecipient(false);
          lstmessages.add(message);
        }
      }
      if (lstmessages != null && lstmessages.size() > 0) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
      }
    }
  }

  /**
   * @description Method to get records for Family Friends
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   * @return Map<Id, List<UAC_apprehendedRelationship__c>>
   **/
  private
  static Map<Id, List<UAC_apprehendedRelationship__c>> getSnapshotFamilyFriends(
      List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_apprehendedRelationship__c>> mapApprehendedRelationships =
        new Map<Id, List<UAC_apprehendedRelationship__c>>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      mapApprehendedRelationships.put(assessmentCurrent.UAC_uac__c, null);
    }
    if (mapApprehendedRelationships.isEmpty()) {
      return mapApprehendedRelationships;
    }
    for (UAC_apprehendedRelationship__c objRelationship : [SELECT Id,
           UAC_uacLookup__c,
           Name,
           UAC_firstName__c,
           UAC_lastName__c,
           UAC_type__c,
           UAC_relationshipToUAC__c,
           UAC_uacLookup__r.Name,
           UAC_address__c,
           UAC_country__c,
           UAC_phone__c,
           UAC_lastContactWithThisPerson__c,
           UAC_familyAge__c FROM UAC_apprehendedRelationship__c WHERE recordtype.Name =
               'Family Friend' AND UAC_uacLookup__c IN:mapApprehendedRelationships.keyset()]) {
      List<UAC_apprehendedRelationship__c> listChildRelationships;
      if (mapApprehendedRelationships.get(objRelationship.UAC_uacLookup__c) != null) {
        listChildRelationships = mapApprehendedRelationships.get(objRelationship.UAC_uacLookup__c);
      } else {
        listChildRelationships = new List<UAC_apprehendedRelationship__c>();
      }
      listChildRelationships.add(objRelationship);
      mapApprehendedRelationships.put(objRelationship.UAC_uacLookup__c, listChildRelationships);
    }
    return mapApprehendedRelationships;
  }

  /**
   * @description Method to create snapshot records for Family Friends
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   **/
  private
  static void createSnapshotFamilyFriends(List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_apprehendedRelationship__c>> mapApprehendedRelationships =
        getSnapshotFamilyFriends(listAssessment);
    if (mapApprehendedRelationships.isEmpty()) {
      return;
    }
    List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate =
        new List<UAC_admissionAssessmentSnapshot__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      if (!mapApprehendedRelationships.containsKey(assessmentCurrent.UAC_uac__c)
          || mapApprehendedRelationships.get(assessmentCurrent.UAC_uac__c) == null) {
        continue;
      }
      for (UAC_apprehendedRelationship__c relationshipCurrent :
          mapApprehendedRelationships.get(assessmentCurrent.UAC_uac__c)) {
        listSnapshotsToCreate.add(
            new UAC_admissionAssessmentSnapshot__c(UAC_type__c = 'UAC_familyFriend',
                UAC_admissionAssessment__c = assessmentCurrent.Id,
                UAC_relatedRecordID__c = relationshipCurrent.Id,
                UAC_relatedRecordName__c = relationshipCurrent.Name,
                UAC_textField1__c = relationshipCurrent.UAC_firstName__c,
                UAC_textField2__c = relationshipCurrent.UAC_lastName__c,
                UAC_textField3__c = relationshipCurrent.UAC_type__c,
                UAC_textField4__c = relationshipCurrent.UAC_relationshipToUAC__c,
                UAC_textField5__c = relationshipCurrent.UAC_familyAge__c,
                UAC_textField6__c = relationshipCurrent.UAC_uacLookup__r.Name,
                UAC_textField7__c = relationshipCurrent.UAC_address__c,
                UAC_textField8__c = relationshipCurrent.UAC_country__c,
                UAC_textField9__c = relationshipCurrent.UAC_phone__c,
                UAC_dateField1__c = relationshipCurrent.UAC_lastContactWithThisPerson__c));
      }
    }
    insertSnapshotRecords(listSnapshotsToCreate);
  }

  /**
   * @description Method to get records for UAC Children
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   * @return Map<Id, List<UAC_apprehendedRelationship__c>>
   **/
  private
  static Map<Id, List<UAC_apprehendedRelationship__c>> getSnapshotUACChildren(
      List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_apprehendedRelationship__c>> mapApprehendedRelationships =
        new Map<Id, List<UAC_apprehendedRelationship__c>>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      mapApprehendedRelationships.put(assessmentCurrent.UAC_uac__c, null);
    }
    if (mapApprehendedRelationships.isEmpty()) {
      return mapApprehendedRelationships;
    }
    for (UAC_apprehendedRelationship__c objRelationship : [SELECT Name,
           UAC_uacLookup__c,
           UAC_firstName__c,
           UAC_lastName__c,
           UAC_relationshipToUAC__c,
           UAC_familyAge__c,
           UAC_childAge__c,
           UAC_childCurrentLocation__c,
           UAC_childDOB__c,
           UAC_childFirstName__c,
           UAC_childLastName__c FROM UAC_apprehendedRelationship__c WHERE RecordType.DeveloperName =
               'UAC_apprehendedUAC' AND UAC_uacLookup__c IN:mapApprehendedRelationships.keyset()]) {
      List<UAC_apprehendedRelationship__c> listChildRelationships;
      if (mapApprehendedRelationships.get(objRelationship.UAC_uacLookup__c) != null) {
        listChildRelationships = mapApprehendedRelationships.get(objRelationship.UAC_uacLookup__c);
      } else {
        listChildRelationships = new List<UAC_apprehendedRelationship__c>();
      }
      listChildRelationships.add(objRelationship);
      mapApprehendedRelationships.put(objRelationship.UAC_uacLookup__c, listChildRelationships);
    }
    return mapApprehendedRelationships;
  }

  /**
   * @description Method to create snapshot records for UAC Children
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   **/
  private
  static void createSnapshotUACChildren(List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_apprehendedRelationship__c>> mapApprehendedRelationships =
        getSnapshotUACChildren(listAssessment);
    if (mapApprehendedRelationships.isEmpty()) {
      return;
    }
    List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate =
        new List<UAC_admissionAssessmentSnapshot__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      if (!mapApprehendedRelationships.containsKey(assessmentCurrent.UAC_uac__c)
          || mapApprehendedRelationships.get(assessmentCurrent.UAC_uac__c) == null) {
        continue;
      }
      for (UAC_apprehendedRelationship__c relationshipCurrent :
          mapApprehendedRelationships.get(assessmentCurrent.UAC_uac__c)) {
        listSnapshotsToCreate.add(
            new UAC_admissionAssessmentSnapshot__c(UAC_type__c = 'UAC_apprehendedUAC',
                UAC_admissionAssessment__c = assessmentCurrent.Id,
                UAC_relatedRecordID__c = relationshipCurrent.Id,
                UAC_relatedRecordName__c = relationshipCurrent.Name,
                UAC_textField1__c = relationshipCurrent.UAC_firstName__c,
                UAC_textField2__c = relationshipCurrent.UAC_lastName__c,
                UAC_textField3__c = relationshipCurrent.UAC_relationshipToUAC__c,
                UAC_textField4__c = relationshipCurrent.UAC_familyAge__c,
                UAC_textField5__c = relationshipCurrent.UAC_childAge__c,
                UAC_textField6__c = relationshipCurrent.UAC_childCurrentLocation__c,
                UAC_textField7__c = relationshipCurrent.UAC_childDOB__c,
                UAC_textField8__c = relationshipCurrent.UAC_childFirstName__c,
                UAC_textField9__c = relationshipCurrent.UAC_childLastName__c));
      }
    }
    insertSnapshotRecords(listSnapshotsToCreate);
  }

  /**
   * @description Method to get records for Adult Contact Relationships
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   * @return Map<Id, List<UAC_adultContactRelationship__c>>
   **/
  private
  static Map<Id, List<UAC_adultContactRelationship__c>> getSnapshotAdultContacts(
      List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_adultContactRelationship__c>> mapAdultContactRelations =
        new Map<Id, List<UAC_adultContactRelationship__c>>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      mapAdultContactRelations.put(assessmentCurrent.UAC_uac__c, null);
    }
    if (mapAdultContactRelations.isEmpty()) {
      return mapAdultContactRelations;
    }
    for (UAC_adultContactRelationship__c objRelationship : [SELECT Id,
           Name,
           UAC_uacLookup__c,
           UAC_adultContact__c,
           UAC_adultContact__r.Name,
           UAC_relationshipType__c,
           UAC_relationshipToUAC__c,
           UAC_dateOfBirth__c,
           UAC_lastContactWithThisPerson__c,
           UAC_phoneNumber__c FROM UAC_adultContactRelationship__c WHERE UAC_uacLookup__c
           IN:mapAdultContactRelations.keyset()]) {
      List<UAC_adultContactRelationship__c> listChildRelationships;
      if (mapAdultContactRelations.get(objRelationship.UAC_uacLookup__c) != null) {
        listChildRelationships = mapAdultContactRelations.get(objRelationship.UAC_uacLookup__c);
      } else {
        listChildRelationships = new List<UAC_adultContactRelationship__c>();
      }
      listChildRelationships.add(objRelationship);
      mapAdultContactRelations.put(objRelationship.UAC_uacLookup__c, listChildRelationships);
    }
    return mapAdultContactRelations;
  }

  /**
   * @description Method to create snapshot records for Adult Contacts
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   **/
  private
  static void createSnapshotAdultContacts(List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_adultContactRelationship__c>> mapAdultContactRelations =
        getSnapshotAdultContacts(listAssessment);
    if (mapAdultContactRelations.isEmpty()) {
      return;
    }
    List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate =
        new List<UAC_admissionAssessmentSnapshot__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      if (!mapAdultContactRelations.containsKey(assessmentCurrent.UAC_uac__c)
          || mapAdultContactRelations.get(assessmentCurrent.UAC_uac__c) == null) {
        continue;
      }
      for (UAC_adultContactRelationship__c relationshipCurrent :
          mapAdultContactRelations.get(assessmentCurrent.UAC_uac__c)) {
        listSnapshotsToCreate.add(
            new UAC_admissionAssessmentSnapshot__c(UAC_type__c = 'UAC_adultContactRelationship__c',
                UAC_admissionAssessment__c = assessmentCurrent.Id,
                UAC_relatedRecordID__c = relationshipCurrent.Id,
                UAC_relatedRecordName__c = relationshipCurrent.Name,
                UAC_relatedRecord2ID__c = relationshipCurrent.UAC_adultContact__c,
                UAC_relatedRecord2Name__c = relationshipCurrent.UAC_adultContact__r.Name,
                UAC_textField1__c = relationshipCurrent.UAC_relationshipType__c,
                UAC_textField2__c = relationshipCurrent.UAC_relationshipToUAC__c,
                UAC_dateField1__c = relationshipCurrent.UAC_dateOfBirth__c,
                UAC_textField4__c = relationshipCurrent.UAC_phoneNumber__c,
                UAC_textField5__c =
                    String.valueOf(relationshipCurrent.UAC_lastContactWithThisPerson__c)));
      }
    }
    insertSnapshotRecords(listSnapshotsToCreate);
  }

  /**
   * @description Method to get records for Previous Sponsor Applications
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   * @return Map<Id, List<Case>>
   **/
  private
  static Map<Id, List<Case>> getSnapshotPreviousSponsors(
      List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<Case>> mapPreviousSponsorships = new Map<Id, List<Case>>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      mapPreviousSponsorships.put(assessmentCurrent.UAC_uac__c, null);
    }
    if (mapPreviousSponsorships.isEmpty()) {
      return mapPreviousSponsorships;
    }
    for (Case objCase : [
           SELECT Id,
           CaseNumber,
           UAC_sponsor__r.Name,
           UAC_aNum__c,
           UAC_relationshipToUAC__r.Name,
           UAC_relationshipToUAC__r.UAC_uacLookup__c,
           UAC_relationshipToUACPickLst__c,
           UAC_relationshipToSponsor__c,
           UAC_FRPForms__c FROM Case WHERE UAC_relationshipToUAC__c IN(
               SELECT Id FROM UAC_adultContactRelationship__c WHERE UAC_uacLookup__c IN
               : mapPreviousSponsorships.keyset())
         ]) {
      List<Case> listCases;
      if (mapPreviousSponsorships.get(objCase.UAC_relationshipToUAC__r.UAC_uacLookup__c) != null) {
        listCases = mapPreviousSponsorships.get(objCase.UAC_relationshipToUAC__r.UAC_uacLookup__c);
      } else {
        listCases = new List<Case>();
      }
      listCases.add(objCase);
      mapPreviousSponsorships.put(objCase.UAC_relationshipToUAC__r.UAC_uacLookup__c, listCases);
    }
    return mapPreviousSponsorships;
  }

  /**
   * @description Method to create snapshot records for Previous Sponsorships
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   **/
  private
  static void createSnapshotPreviousSponsorships(List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<Case>> mapPreviousSponsorships = getSnapshotPreviousSponsors(listAssessment);
    if (mapPreviousSponsorships.isEmpty()) {
      return;
    }
    List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate =
        new List<UAC_admissionAssessmentSnapshot__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      if (!mapPreviousSponsorships.containsKey(assessmentCurrent.UAC_uac__c)
          || mapPreviousSponsorships.get(assessmentCurrent.UAC_uac__c) == null) {
        continue;
      }
      for (Case objCase : mapPreviousSponsorships.get(assessmentCurrent.UAC_uac__c)) {
        listSnapshotsToCreate.add(new UAC_admissionAssessmentSnapshot__c(UAC_type__c = 'Case',
            UAC_admissionAssessment__c = assessmentCurrent.Id,
            UAC_relatedRecordID__c = objCase.Id,
            UAC_relatedRecordName__c = objCase.CaseNumber,
            UAC_textField1__c = objCase.UAC_sponsor__r.Name,
            UAC_textField2__c = objCase.UAC_aNum__c,
            UAC_textField3__c = objCase.UAC_relationshipToUAC__r.Name,
            UAC_textField4__c = objCase.UAC_relationshipToUACPickLst__c,
            UAC_textField5__c = objCase.UAC_FRPForms__c,
            UAC_textField6__c = objCase.UAC_relationshipToSponsor__c));
      }
    }
    insertSnapshotRecords(listSnapshotsToCreate);
  }

  /**
   * @description Method to get records for Medications
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_medication__c> listAssessment
   * @return Map<Id, List<Case>>
   **/
  private
  static Map<Id, List<UAC_medication__c>> getSnapshotMedication(
      List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_medication__c>> mapMedications = new Map<Id, List<UAC_medication__c>>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      mapMedications.put(assessmentCurrent.UAC_uac__c, null);
    }
    if (mapMedications.isEmpty()) {
      return mapMedications;
    }
    for (UAC_medication__c objMedication : [SELECT Id,
           Name,
           UAC_dateStarted__c,
           UAC_dose__c,
           UAC_direction__c,
           UAC_psychotropic__c,
           UAC_dischargedWithMedication__c,
           UAC_associatedUAC__c FROM UAC_medication__c WHERE UAC_associatedUAC__c
           IN:mapMedications.keyset()]) {
      List<UAC_medication__c> listMedications;
      if (mapMedications.get(objMedication.UAC_associatedUAC__c) != null) {
        listMedications = mapMedications.get(objMedication.UAC_associatedUAC__c);
      } else {
        listMedications = new List<UAC_medication__c>();
      }
      listMedications.add(objMedication);
      mapMedications.put(objMedication.UAC_associatedUAC__c, listMedications);
    }
    return mapMedications;
  }

  /**
   * @description Method to create snapshot records for Medication
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listAssessment
   **/
  private
  static void createSnapshotMedication(List<UAC_admissionAssessment__c> listAssessment) {
    Map<Id, List<UAC_medication__c>> mapMedications = getSnapshotMedication(listAssessment);
    if (mapMedications.isEmpty()) {
      return;
    }
    List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate =
        new List<UAC_admissionAssessmentSnapshot__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : listAssessment) {
      if (!mapMedications.containsKey(assessmentCurrent.UAC_uac__c)
          || mapMedications.get(assessmentCurrent.UAC_uac__c) == null) {
        continue;
      }
      for (UAC_medication__c objMedication : mapMedications.get(assessmentCurrent.UAC_uac__c)) {
        listSnapshotsToCreate.add(
            new UAC_admissionAssessmentSnapshot__c(UAC_type__c = 'UAC_medication__c',
                UAC_admissionAssessment__c = assessmentCurrent.Id,
                UAC_relatedRecordID__c = objMedication.Id,
                UAC_relatedRecordName__c = objMedication.Name,
                UAC_dateField1__c = objMedication.UAC_dateStarted__c,
                UAC_textField1__c = objMedication.UAC_dose__c,
                UAC_textField2__c = objMedication.UAC_direction__c,
                UAC_textField3__c = objMedication.UAC_psychotropic__c,
                UAC_textField4__c = objMedication.UAC_dischargedWithMedication__c));
      }
    }
    insertSnapshotRecords(listSnapshotsToCreate);
  }

  /**
   * @description Utility method to insert snapshot records
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate
   **/
  private
  static void insertSnapshotRecords(
      List<UAC_admissionAssessmentSnapshot__c> listSnapshotsToCreate) {
    if (!listSnapshotsToCreate.isEmpty()) {
      try {
        insert listSnapshotsToCreate;
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error saving snapshot of Assessment data of type '
                + listSnapshotsToCreate[0].UAC_type__c + ': ',
            e.getStackTraceString());
      }
    }
  }

  /**
   * @description Calls child record creation methods on assessment submission
   * @author James Qian (Deloitte) | 10/28/2020
   * @param Map<Id, UAC_admissionAssessment__c> newItems
   * @param Map<Id, UAC_admissionAssessment__c> oldItems
   **/
  public
  static void createRecordsOnSubmit(
      Map<Id, UAC_admissionAssessment__c> newItems, Map<Id, UAC_admissionAssessment__c> oldItems) {
    List<UAC_admissionAssessment__c> listAssessmentsSubmitted =
        new List<UAC_admissionAssessment__c>();
    Set<Id> setSubmittedIds = new Set<Id>();
    for (UAC_admissionAssessment__c assessmentCurrent : newItems.values()) {
      if (assessmentCurrent.UAC_assessmentStatus__c
              == oldItems.get(assessmentCurrent.Id).UAC_assessmentStatus__c
          || assessmentCurrent.UAC_assessmentStatus__c != Label.UAC_assessmentStatusSubmitted) {
        continue;
      }
      listAssessmentsSubmitted.add(assessmentCurrent);
      setSubmittedIds.add(assessmentCurrent.Id);
    }
    if (!listAssessmentsSubmitted.isEmpty()) {
      createSnapshotsOnSubmit(listAssessmentsSubmitted);
      if (!System.isFuture()) {
        UC_visualChecklistService.updateAdmissionTasks(setSubmittedIds, 'Completed');
      }
    }
  }

  /**
   * @description Creates snapshots of child records on assessment submission
   * @author James Qian (Deloitte) | 10/28/2020
   * @param List<UAC_admissionAssessment__c> listSubmittedAssessments
   **/
  public
  static void createSnapshotsOnSubmit(List<UAC_admissionAssessment__c> listSubmittedAssessments) {
    List<UAC_admissionAssessment__c> listAssessmentsForFFSnapshot =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsForPSASnapshot =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsForACRSnapshot =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsForMedSnapshot =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsForUACCSnapshot =
        new List<UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> listAssessmentsSubmitted =
        new List<UAC_admissionAssessment__c>();
    for (UAC_admissionAssessment__c assessmentCurrent : listSubmittedAssessments) {
      if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
          == Label.UAC_assessmentRecordTypeAssessment) {
        listAssessmentsForFFSnapshot.add(assessmentCurrent);
        listAssessmentsForACRSnapshot.add(assessmentCurrent);
        listAssessmentsForPSASnapshot.add(assessmentCurrent);
        listAssessmentsForUACCSnapshot.add(assessmentCurrent);
      } else if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
          == strInitialIntakesAssessmentRecordType) {
        listAssessmentsForFFSnapshot.add(assessmentCurrent);
        listAssessmentsForACRSnapshot.add(assessmentCurrent);
        listAssessmentsForMedSnapshot.add(assessmentCurrent);
      } else if (mapRecordTypes.get(assessmentCurrent.RecordTypeId).getDeveloperName()
          == Label.UAC_assessmentRecordTypeReview) {
        listAssessmentsForACRSnapshot.add(assessmentCurrent);
        listAssessmentsForPSASnapshot.add(assessmentCurrent);
      }
    }
    if (!listAssessmentsForFFSnapshot.isEmpty()) {
      createSnapshotFamilyFriends(listAssessmentsForFFSnapshot);
    }
    if (!listAssessmentsForACRSnapshot.isEmpty()) {
      createSnapshotAdultContacts(listAssessmentsForACRSnapshot);
    }
    if (!listAssessmentsForPSASnapshot.isEmpty()) {
      createSnapshotPreviousSponsorships(listAssessmentsForPSASnapshot);
    }
    if (!listAssessmentsForMedSnapshot.isEmpty()) {
      createSnapshotMedication(listAssessmentsForMedSnapshot);
    }
    if (!listAssessmentsForUACCSnapshot.isEmpty()) {
      createSnapshotUACChildren(listAssessmentsForUACCSnapshot);
    }
  }

  /**
   * @description ORRUAC-2786 - Send Email to Clinician,Lead Clinican, DHUC and Medical Coordinator
   *based on Intake Assesment input
   * @author Abhisek Pati (Deloitte) | 10/15/2020
   * @param Map<Id,UAC_admissionAssessment__c>
   * @return void
   **/
  public
  static void sendEmailToCaseAndAccountTeam(
      Map<Id, UAC_admissionAssessment__c> mapOldIntakeAssesment,
      Map<Id, UAC_admissionAssessment__c> mapIntakeAssesment) {

    list<EmailTemplate> objTemplateVictim =
        [select id, developername from emailtemplate where developername
          =:Label.UAC_intakeAssesmentVictimEmailTemplate];
    list<EmailTemplate> objTemplateNotPrescribed =
        [select id, developername from emailtemplate where developername
          =:Label.UAC_intakeAssesmentNotPrescribedEmailTemplate];
    Set<Id> setCases = new Set<Id>();
    Set<Id> setContacts = new Set<Id>();
    Set<Id> setAccounts = new Set<Id>();
    Set<String> setCaseTeamRoleName =
        new set<String>{Label.UAC_caseTeamRoleNameClinician, Label.UAC_caseTeamRoleNameLC};
    Set<String> setAccountTeamRoleName =
        new set<String>{Label.UAC_profileDHUCMedicalTeamMember, Label.UAC_accountTeamRoleMC};
    Map<Id, List<String>> mapIdIntakeAssesmentEmail = new Map<Id, List<String>>();
    Map<Id, List<String>> mapIdIntakeAssesmentEmailAccount = new Map<Id, List<String>>();
    Map<Id, List<CaseTeamMember>> mapCaseIdCaseTM = new Map<Id, List<CaseTeamMember>>();
    Map<Id, List<AccountTeamMember>> mapAccountIdAccountTM = new Map<Id, List<AccountTeamMember>>();
    Map<Id, Id> mapIdContacttoAccount = new Map<Id, Id>();

    // Add Case Ids to set
    for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
      if (objIntakeAssesment.UAC_entry__c != null) {
        setCases.add(objIntakeAssesment.UAC_entry__c);
        setContacts.add(objIntakeAssesment.UAC_uac__c);
      }
    }

    // Add Account Ids to set
    for (Contact objContact : [Select Id, AccountId from Contact where Id IN:setContacts]) {
      if (objContact.AccountId != null) {
        setAccounts.add(objContact.AccountId);
        mapIdContacttoAccount.put(objContact.Id, objContact.AccountId);
      }
    }

    // Create a Map for Case Id and  CaseTeammember
    Map<Id, CaseTeamMember> mapCaseTeam = new Map<Id, CaseTeamMember>([
      Select Id,
      MemberId,
      ParentId,
      TeamRoleId,
      Member.Email from CaseTeamMember where TeamRole.Name in:setCaseTeamRoleName and ParentId
                                                           in:setCases
    ]);
    for (CaseTeamMember objCaseTM : mapCaseTeam.values()) {

      if (mapCaseIdCaseTM.containsKey(objCaseTM.ParentId)) {
        List<CaseTeamMember> lstCaseTM = mapCaseIdCaseTM.get(objCaseTM.ParentId);
        lstCaseTM.add(objCaseTM);
        mapCaseIdCaseTM.put(objCaseTM.ParentId, lstCaseTM);
      } else {
        List<CaseTeamMember> lstNewCaseTM = new List<CaseTeamMember>();
        lstNewCaseTM.add(objCaseTM);
        mapCaseIdCaseTM.put(objCaseTM.ParentId, lstNewCaseTM);
      }
    }
    // Create a Map for Intake Assessment Id and  Case Team member
    for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
      for (CaseTeamMember objCaseTeam : mapCaseTeam.values()) {
        if (objCaseTeam.ParentId == objIntakeAssesment.UAC_entry__c) {
          if (mapCaseIdCaseTM.containsKey(objCaseTeam.ParentId)) {
            List<CaseTeamMember> lstNewCaseTM = mapCaseIdCaseTM.get(objCaseTeam.ParentId);
            List<String> lstStrEmail = new List<String>();
            for (CaseTeamMember objCaseTM : lstNewCaseTM) {
              lstStrEmail.add(objCaseTM.Member.Email);
            }
            if (!mapIdIntakeAssesmentEmail.containsKey(objIntakeAssesment.Id))
              mapIdIntakeAssesmentEmail.put(objIntakeAssesment.Id, lstStrEmail);
          }
          break;
        }
      }
    }

    // Create a Map for Account Id and  CaseTeammember
    Map<Id, AccountTeamMember> mapAccountTeam = new Map<Id, AccountTeamMember>([
      Select Id,
      AccountId,
      UserId,
      TeamMemberRole,
      User.Email from AccountTeamMember where TeamMemberRole in:setAccountTeamRoleName and AccountId
                                                             in:setAccounts
    ]);
    for (AccountTeamMember objAccountTM : mapAccountTeam.values()) {

      if (mapAccountIdAccountTM.containsKey(objAccountTM.AccountId)) {
        List<AccountTeamMember> lstAccountTM = mapAccountIdAccountTM.get(objAccountTM.AccountId);
        lstAccountTM.add(objAccountTM);
        mapAccountIdAccountTM.put(objAccountTM.AccountId, lstAccountTM);
      } else {
        List<AccountTeamMember> lstNewAccountTM = new List<AccountTeamMember>();
        lstNewAccountTM.add(objAccountTM);
        mapAccountIdAccountTM.put(objAccountTM.AccountId, lstNewAccountTM);
      }
    }
    // Create a Map for Intake Assessment Id and  Account Team member
    for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
      for (AccountTeamMember objAccountTeam : mapAccountTeam.values()) {
        if (objAccountTeam.AccountId == mapIdContacttoAccount.get(objIntakeAssesment.UAC_uac__c)) {
          if (mapAccountIdAccountTM.containsKey(objAccountTeam.AccountId)) {
            List<AccountTeamMember> lstNewAccountTM =
                mapAccountIdAccountTM.get(objAccountTeam.AccountId);
            List<String> lstStrATEmail = new List<String>();
            for (AccountTeamMember objAccountTM : lstNewAccountTM) {
              lstStrATEmail.add(objAccountTM.User.Email);
            }
            if (!mapIdIntakeAssesmentEmailAccount.containsKey(objIntakeAssesment.Id))
              mapIdIntakeAssesmentEmailAccount.put(objIntakeAssesment.Id, lstStrATEmail);
          }
          break;
        }
      }
    }
    list<Messaging.SingleEmailMessage> lstmessages = new list<Messaging.SingleEmailMessage>();
    List<String> lstEmail = new List<String>();
    for (UAC_admissionAssessment__c objIntakeAssesment : mapIntakeAssesment.values()) {
      if (mapIdIntakeAssesmentEmail.size() > 0) {
        lstEmail.addAll(mapIdIntakeAssesmentEmail.get(objIntakeAssesment.Id));
      }
      if (mapIdIntakeAssesmentEmailAccount.size() > 0) {
        lstEmail.addAll(mapIdIntakeAssesmentEmailAccount.get(objIntakeAssesment.Id));
      }
      if (!objTemplateVictim.isEmpty() && !lstEmail.isEmpty()
          && mapOldIntakeAssesment.get(objIntakeAssesment.Id)
                  .UAC_victimOfSexualAssaultRapedLast72__c
              != System.label.UAC_Yes
          && objIntakeAssesment.UAC_victimOfSexualAssaultRapedLast72__c == System.label.UAC_Yes) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = lstEmail;
        message.setTemplateId(objTemplateVictim[0].id);
        message.settargetObjectId(objIntakeAssesment.UAC_uac__c);
        message.setWhatId(objIntakeAssesment.Id);
        message.setTreatTargetObjectAsRecipient(false);
        lstmessages.add(message);
      }
      if (!objTemplateNotPrescribed.isEmpty() && !lstEmail.isEmpty()
          && mapOldIntakeAssesment.get(objIntakeAssesment.Id)
                  .UAC_takingAnythingOtherThanPrescribed__c
              != System.label.UAC_Yes
          && objIntakeAssesment.UAC_takingAnythingOtherThanPrescribed__c == System.label.UAC_Yes) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = lstEmail;
        message.setTemplateId(objTemplateNotPrescribed[0].id);
        message.settargetObjectId(objIntakeAssesment.UAC_uac__c);
        message.setWhatId(objIntakeAssesment.Id);
        message.setTreatTargetObjectAsRecipient(false);
        lstmessages.add(message);
      }
      if (lstmessages != null && lstmessages.size() > 0) {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
      }
    }
  }
  /**
   * @description Sync UAC Assessment fields from Initial Intakes and UAC Referral
   * @author Issam Awwad (Deloitte) | 10/27/2020
   * @param List<UAC_admissionAssessment__c> lstOfNewUACAssessments
   * @param Set<Id> setOfEntries
   **/
  public
  static void syncUACAssessmentFields(List<UAC_admissionAssessment__c> lstOfNewUACAssessments) {
    Set<Id> setOfProfiles = new Set<Id>();
    for (UAC_admissionAssessment__c objAssessment : lstOfNewUACAssessments) {
      setOfProfiles.add(objAssessment.UAC_uac__c);
    }
    Map<String, Case> mapOfProfileToReferral = new Map<String, Case>();
    List<Case> lstOfUACReferrals = [
      SELECT Id,
      UAC_criminalConcerns__c,
      UAC_footguide__c,
      ContactId FROM Case WHERE ContactId IN:setOfProfiles AND recordType.DeveloperName
                                           =:Label.UAC_caseRecordTypeApiNameUACReferral
    ];

    for (Case objReferral : lstOfUACReferrals) {
      mapOfProfileToReferral.put(objReferral.ContactId, objReferral);
    }
    for (UAC_admissionAssessment__c objNewUACAssessment : lstOfNewUACAssessments) {
      if (mapOfProfileToReferral.get(objNewUACAssessment.UAC_uac__c) == null) {
        continue;
      }
      Case objReferral = mapOfProfileToReferral.get(objNewUACAssessment.UAC_uac__c);
      objNewUACAssessment.UAC_criminalConcerns__c = objReferral.UAC_criminalConcerns__c;
      objNewUACAssessment.UAC_footguide__c = objReferral.UAC_footguide__c;
    }
  }
  /**
   * @description Check for existing Case Review and clone fields
   * @author Issam Awwad (Deloitte) | 10/27/2020
   * @param List<UAC_admissionAssessment__c> lstOfNewCaseReview
   **/
  public
  static void syncCaseReviewFields(List<UAC_admissionAssessment__c> lstOfNewCaseReview) {
    Set<Id> setofEntries = new Set<Id>();

    String strFieldSet = '';
    SObjectType schemaCaseReview = Schema.getGlobalDescribe().get('UAC_admissionAssessment__c');
    Map<String, Schema.SObjectField> schemaFields = schemaCaseReview.getDescribe().fields.getMap();
    for (String str : schemaFields.keySet()) {
      strFieldSet = strFieldSet + schemaFields.get(str) + ',';
    }
    strFieldSet = strFieldSet.removeEnd(',');
    for (UAC_admissionAssessment__c objNewAssessment : lstOfNewCaseReview) {
      setofEntries.add(objNewAssessment.UAC_entry__c);
    }
    Map<String, UAC_admissionAssessment__c> mapOfEntryToExistingCaseReview =
        new Map<String, UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstOFExistingCaseReview = Database.query('SELECT '
        + strFieldSet
        + ' FROM UAC_admissionAssessment__c WHERE UAC_entry__c IN :setofEntries AND recordType.DeveloperName =\''
        + Label.UAC_assessmentRecordTypeReview + '\' AND UAC_mostRecentAssessment__c = true');

    for (UAC_admissionAssessment__c objAssessment : lstOFExistingCaseReview) {
      mapOfEntryToExistingCaseReview.put(objAssessment.UAC_entry__c, objAssessment);
    }
    if (!lstOFExistingCaseReview.isEmpty()) {
      for (UAC_admissionAssessment__c objAssessment : lstOfNewCaseReview) {
        if (mapOfEntryToExistingCaseReview.containsKey(objAssessment.UAC_entry__c)) {
          for (String strField : schemaFields.keySet()) {
            if (schemaFields.get(strField).getDescribe().isUpdateable()) {
              objAssessment.put(schemaFields.get(strField),
                  mapOfEntryToExistingCaseReview.get(objAssessment.UAC_entry__c)
                      .get(schemaFields.get(strField)));
            }
          }
        }
        if (!FeatureManagement.checkPermission('UC_dataIntegrationUser')) {
          objAssessment.UAC_assessmentStatus__c = 'Pending';
          objAssessment.UAC_confirmCM__c = false;
          objAssessment.UAC_clinicianConfirm__c = false;
          objAssessment.UAC_printedNameCM__c = null;
          objAssessment.UAC_printedNameClinician__c = null;
          objAssessment.UAC_translatorNameCM__c = '';
          objAssessment.UAC_translatorNameClinician__c = '';
          objAssessment.UAC_languageCM__c = '';
          objAssessment.UAC_languageClinician__c = '';
          objAssessment.UAC_legacyID__c = '';
        }
      }
    }
  }
  /**
   * @description Check for existing ISP records and sync service records
   * @author Issam Awwad (Deloitte) | 10/27/2020
   * @param UAC_admissionAssessment__c objNewISPAssessment
   * @param Set<Id> setofEntries
   **/
  public
  static void syncServiceRecordsToISP(List<UAC_admissionAssessment__c> lstOfNewISPAssessment) {
    Set<Id> setofEntries = new Set<Id>();
    for (UAC_admissionAssessment__c objNewAssessment : lstOfNewISPAssessment) {
      setofEntries.add(objNewAssessment.UAC_entry__c);
    }
      System.debug('setofEntries: '+setofEntries);
    Map<Id, UAC_admissionAssessment__c> mapOfExistingISP = new Map<Id, UAC_admissionAssessment__c>([
      SELECT Id,
      UAC_mostRecentAssessment__c,
      UAC_entry__c FROM UAC_admissionAssessment__c WHERE UAC_entry__c
      IN:setofEntries AND recordType.DeveloperName
       =:Label.UAC_assessmentRecordTypeISP AND UAC_mostRecentAssessment__c = false
    ]);

    Map<String, List<Contract>> mapOfEntryToMandatoryService = new Map<String, List<Contract>>();
    Map<String, List<Contract>> mapOfEntryToOptionalService = new Map<String, List<Contract>>();
    List<Contract> lstOfContractsToUpdate = new List<Contract>();
System.debug('mapOfExistingISP.keySet: '+mapOfExistingISP.keySet());
    List<Contract> lstOfExistingMandatoryService = [SELECT Id,
      UAC_individualServicePlan__c,
      AccountId,
      Name,
      UAC_service__c,
      UAC_taskLong__c,
      UAC_Notes__c,
      UAC_personResponsibleLong__c,
      StartDate,
      EndDate,
      UAC_frequency__c FROM Contract WHERE UAC_individualServicePlan__c
      IN:mapOfExistingISP.keySet() AND recordType.DeveloperName = 'UAC_mandatory'];
    List<Contract> lstOfExistingOptionalService = [SELECT Id,
      UAC_individualServicePlan__c,
      AccountId,
      Name,
      UAC_service__c,
      UAC_taskLong__c,
      UAC_Notes__c,
      UAC_personResponsibleLong__c,
      StartDate,
      EndDate,
      UAC_frequency__c FROM Contract WHERE UAC_individualServicePlan__c
      IN:mapOfExistingISP.keySet() AND recordType.DeveloperName = 'UAC_optional'];

    for (Contract objContract : lstOfExistingMandatoryService) {
      List<Contract> lstOfContract = new List<Contract>();
      if (mapOfExistingISP.containsKey(objContract.UAC_individualServicePlan__c)) {
        String strEntryId =
            mapOfExistingISP.get(objContract.UAC_individualServicePlan__c).UAC_entry__c;
        if (mapOfEntryToMandatoryService.containsKey(strEntryId)) {
          lstOfContract = mapOfEntryToMandatoryService.get(strEntryId);
          lstOfContract.add(objContract);
          mapOfEntryToMandatoryService.put(strEntryId, lstOfContract);
        } else {
          lstOfContract.add(objContract);
          mapOfEntryToMandatoryService.put(strEntryId, lstOfContract);
        }
      }
    }
    for (Contract objContract : lstOfExistingOptionalService) {
      List<Contract> lstOfContract = new List<Contract>();
      if (mapOfExistingISP.containsKey(objContract.UAC_individualServicePlan__c)) {
        String strEntryId =
            mapOfExistingISP.get(objContract.UAC_individualServicePlan__c).UAC_entry__c;
        if (mapOfEntryToOptionalService.containsKey(strEntryId)) {
          lstOfContract = mapOfEntryToOptionalService.get(strEntryId);
          lstOfContract.add(objContract);
          mapOfEntryToOptionalService.put(strEntryId, lstOfContract);
        } else {
          lstOfContract.add(objContract);
          mapOfEntryToOptionalService.put(strEntryId, lstOfContract);
        }
      }
    }

    for (UAC_admissionAssessment__c objNewISP : lstOfNewISPAssessment) {
      if (mapOfEntryToMandatoryService.containsKey(objNewISP.UAC_entry__c)) {
        for (Contract objContract : mapOfEntryToMandatoryService.get(objNewISP.UAC_entry__c)) {
          Contract objClonedContract = objContract.clone();
          objClonedContract.UAC_individualServicePlan__c = objNewISP.Id;
          lstOfContractsToUpdate.add(objClonedContract);
        }
      }
      if (mapOfEntryToOptionalService.containsKey(objNewISP.UAC_entry__c)) {
        for (Contract objContract : mapOfEntryToOptionalService.get(objNewISP.UAC_entry__c)) {
          Contract objClonedContract = objContract.clone();
          objClonedContract.UAC_individualServicePlan__c = objNewISP.Id;
          lstOfContractsToUpdate.add(objClonedContract);
        }
      }
    }

    if (!lstOfContractsToUpdate.isEmpty()) {
      try {
        insert lstOfContractsToUpdate;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error with sync of service records to ISP',
            e.getStackTraceString());
      }
    }
  }
  /**
   * @description Check for existing Assessment For Risk and clone fields
   * @author Issam Awwad (Deloitte) | 10/27/2020
   * @param UAC_admissionAssessment__c lstOfNewAssessmentForRisk
   **/
  public
  static void syncAssessmentForRiskFields(
      List<UAC_admissionAssessment__c> lstOfNewAssessmentForRisk) {
    Set<Id> setofEntries = new Set<Id>();
    List<UAC_admissionAssessment__c> lstOfClonedAssessmentForRisk =
        new List<UAC_admissionAssessment__c>();

    String strFieldSet = '';
    SObjectType schemaAssessment = Schema.getGlobalDescribe().get('UAC_admissionAssessment__c');
    Map<String, Schema.SObjectField> schemaFields = schemaAssessment.getDescribe().fields.getMap();
    for (String str : schemaFields.keySet()) {
      strFieldSet = strFieldSet + schemaFields.get(str) + ',';
    }
    strFieldSet = strFieldSet.removeEnd(',');
    for (UAC_admissionAssessment__c objNewAssessment : lstOfNewAssessmentForRisk) {
      setofEntries.add(objNewAssessment.UAC_entry__c);
    }
    Map<String, UAC_admissionAssessment__c> mapOfEntryToExistingAssessmentForRisk =
        new Map<String, UAC_admissionAssessment__c>();
    List<UAC_admissionAssessment__c> lstOFExistingAssessmentForRisk = Database.query('SELECT '
        + strFieldSet
        + ' FROM UAC_admissionAssessment__c WHERE UAC_entry__c IN :setofEntries AND recordType.DeveloperName =\''
        + Label.UAC_assessmentRecordTypeRisk + '\' AND UAC_mostRecentAssessment__c = true');

    for (UAC_admissionAssessment__c objAssessment : lstOFExistingAssessmentForRisk) {
      mapOfEntryToExistingAssessmentForRisk.put(objAssessment.UAC_entry__c, objAssessment);
    }
    for (UAC_admissionAssessment__c objAssessment : lstOfNewAssessmentForRisk) {
      if (mapOfEntryToExistingAssessmentForRisk.containsKey(objAssessment.UAC_entry__c)) {
        for (String strField : schemaFields.keySet()) {
          if (schemaFields.get(strField).getDescribe().isUpdateable()) {
            objAssessment.put(schemaFields.get(strField),
                mapOfEntryToExistingAssessmentForRisk.get(objAssessment.UAC_entry__c)
                    .get(schemaFields.get(strField)));
          }
        }
      }
      objAssessment.UAC_assessmentStatus__c = 'Pending';
      objAssessment.UAC_confirmCM__c = false;
      objAssessment.UAC_clinicianConfirm__c = false;
      objAssessment.UAC_printedNameCM__c = null;
      objAssessment.UAC_printedNameClinician__c = null;
      objAssessment.UAC_translatorNameCM__c = '';
      objAssessment.UAC_translatorNameClinician__c = '';
      objAssessment.UAC_languageCM__c = '';
      objAssessment.UAC_languageClinician__c = '';
      objAssessment.UAC_legacyID__c = '';
    }
  }
  /**
   * @description Check for existing Assessment For Risk and clone fields
   * @author Issam Awwad (Deloitte) | 10/27/2020
   * @param UAC_admissionAssessment__c lstOfNewAssessment
   * @param String strRecordType
   **/
  public
  static void syncDocumentsForAssessments(
      List<UAC_admissionAssessment__c> lstOfNewAssessment, String strRecordType) {
    Set<Id> setofEntries = new Set<Id>();
    for (UAC_admissionAssessment__c objNewAssessment : lstOfNewAssessment) {
      setofEntries.add(objNewAssessment.UAC_entry__c);
    }
    Map<Id, UAC_admissionAssessment__c> mapOfExistingAssessment =
        new Map<Id, UAC_admissionAssessment__c>([
          SELECT Id,
          UAC_mostRecentAssessment__c,
          UAC_entry__c FROM UAC_admissionAssessment__c WHERE UAC_entry__c
          IN:setofEntries AND recordType.DeveloperName
           =:strRecordType AND UAC_mostRecentAssessment__c = false
        ]);

    if (mapOfExistingAssessment.isEmpty()) {
      return;
    }
    List<ContentDocumentLink> lstOfDocuments =
        [SELECT ContentDocumentId, Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId
          IN:mapOfExistingAssessment.keySet()];
    Map<String, List<ContentDocumentLink>> mapOFEntryToDocuments =
        new Map<String, List<ContentDocumentLink>>();
    for (ContentDocumentLink objContentDocument : lstOfDocuments) {
      List<ContentDocumentLink> lstOfTempDocuments = new List<ContentDocumentLink>();
      if (mapOFEntryToDocuments.containsKey(objContentDocument.LinkedEntityId)) {
        lstOfTempDocuments = mapOFEntryToDocuments.get(objContentDocument.LinkedEntityId);
        lstOfTempDocuments.add(objContentDocument);
        mapOFEntryToDocuments.put(
            mapOfExistingAssessment.get(objContentDocument.LinkedEntityId).UAC_entry__c,
            lstOfTempDocuments);
      } else {
        lstOfTempDocuments.add(objContentDocument);
        mapOFEntryToDocuments.put(
            mapOfExistingAssessment.get(objContentDocument.LinkedEntityId).UAC_entry__c,
            lstOfTempDocuments);
      }
    }

    List<ContentDocumentLink> lstOfNewContentDocument = new List<ContentDocumentLink>();

    for (UAC_admissionAssessment__c objNewAssessment : lstOfNewAssessment) {
      if (mapOFEntryToDocuments.containsKey(objNewAssessment.UAC_entry__c)) {
        for (ContentDocumentLink objDocument :
            mapOFEntryToDocuments.get(objNewAssessment.UAC_entry__c)) {
          ContentDocumentLink objNewContentDocument = new ContentDocumentLink();
          objNewContentDocument.LinkedEntityId = objNewAssessment.id;
          objNewContentDocument.ContentDocumentId = objDocument.ContentDocumentId;
          lstOfNewContentDocument.add(objNewContentDocument);
        }
      }
    }

    if (!lstOfNewContentDocument.isEmpty()) {
      try {
        insert lstOfNewContentDocument;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error with sync of documents from Assessments',
            e.getStackTraceString());
      }
    }
  }
}