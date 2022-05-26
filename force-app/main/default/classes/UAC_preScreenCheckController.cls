/**
 * @File Name          : UAC_preScreenCheckController.cls
 * @Description        : Controller for Pre-Screen logic and LWC. Approved after force reviewer that
 *                       the SOQL queries within the For-loop are necessary as per design
 * @Author             : Issam Awwad (Deloitte)
 * @Test Class         : UAC_preScreenCheckControllerTest
 * @Last Modified By   : Issam Awwad(Deloitte)
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    8/17/2020   Issam Awwad (Deloitte)        Initial Implementation.
 **/
public
without sharing class UAC_preScreenCheckController {

  private
  static Set<Id> setOfUACs = new Set<Id>();
  private
  static Map<String, Case> mapUACToCase = new Map<String, Case>();
  private
  static List<Case> lstOfCasesToUpdate = new List<Case>();
  // clang-format off
  private
  static String jsonInput =
    '{"UAC_isExpectedToBeReleasedToASponsor" :{ "Id": "UAC_isExpectedToBeReleasedToASponsor","Rank":"1", "Status":"Pass", "Comment":"", "Criteria":"Is expected to be released to a sponsor within 30 days" },"UAC_notBeScheduledToBeDischarged" :{ "Id": "UAC_notBeScheduledToBeDischarged","Status":"Pass", "Rank":"2", "Comment":"", "Criteria":"Not be scheduled to be discharged in three days or less" },"UAC_isAge13OrOlder" :{ "Id": "UAC_isAge13OrOlder","Status":"Fail","Rank":"3", "Comment":"", "Criteria":"Is age 13 or older" },"UAC_speaksEnglishOrSpanish" :{ "Id": "UAC_speaksEnglishOrSpanish","Status":"Fail", "Comment":"", "Rank":"4", "Criteria":"Speaks English or Spanish as his or her preferred language" },"UAC_isNotAPregnant" :{ "Id": "UAC_isNotAPregnant","Status":"Pass", "Comment":"", "Rank":"5","Criteria":"Is not a pregnant teen" },"UAC_isNotAParentingTeen" :{ "Id": "UAC_isNotAParentingTeen","Status":"Pass", "Comment":"", "Rank":"6","Criteria":"Is not a parenting teen" },"UAC_scheduledImmigration" :{ "Id": "UAC_scheduledImmigration","Status":"Pass", "Comment":"", "Rank":"7","Criteria":"Does not have a scheduled immigration or state/family court date of any kind/asylum hearing" },"UAC_doesNotHaveAnAttorneyOfRecord" :{ "Id": "UAC_doesNotHaveAnAttorneyOfRecord","Status":"Pass", "Comment":"", "Rank":"8", "Criteria":"Does not have an attorney of record" },"UAC_notBePartOfASiblingGroup" :{ "Id": "UAC_notBePartOfASiblingGroup","Status":"Pass", "Comment":"", "Rank":"9","Criteria":"Not be part of a sibling group with a sibling(s) age 12 years or younger" },"UAC_notPendingAgeDetermination" :{ "Id": "UAC_notPendingAgeDetermination","Status":"Pass", "Comment":"", "Rank":"10","Criteria":"Not be subject to a pending age determination (see Section 1.6)" },"UAC_notHaveAPendingHomeStudy" :{ "Id": "UAC_notHaveAPendingHomeStudy","Status":"Pass", "Comment":"", "Rank":"11","Criteria":"Not have a pending home study (see Section 2.4)" },"UAC_notBeTurning18YearsOld" :{ "Id": "UAC_notBeTurning18YearsOld","Status":"Pass", "Comment":"", "Rank":"12","Criteria":"Not be turning 18 years old" },"UAC_beMedicallyClearedAndVaccinated" :{ "Id": "UAC_beMedicallyClearedAndVaccinated","Status":"Pass", "Comment":"", "Rank":"13","Criteria":"Be medically cleared and vaccinated as required by the influx care facility (for instance, if the influx care facility is on a U.S. Department of Defense site)" },"UAC_noSeparatedMinors" :{ "Id": "UAC_noSeparatedMinors","Status":"Pass", "Comment":"", "Rank":"14","Criteria":"Not separated from parent/legal guardian" },"UAC_noCategory4" :{ "Id": "UAC_noCategory4","Status":"Pass", "Comment":"", "Rank":"15","Criteria":"No Category 4"},"CriteraPassCount" :{ "Id": "CriteraPassCount","Status":"", "Comment":"", "Rank":"26","Criteria":"", "Pass":"19"},"UAC_manualCriteria1" :{ "Id": "UAC_manualCriteria1","Status":"", "Comment":"", "Rank":"1","Criteria":"Does not have known special needs (including mental health or identified disabilities), behavioral health issues, medical issues, or dental issues that would be better served at an alternative care provider facility;"},"UAC_manualCriteria2" :{ "Id": "UAC_manualCriteria2","Status":"", "Comment":"", "Rank":"2","Criteria":"Is not a danger to self or others (including not having been charged with or convicted of a criminal offense)."},"UAC_manualCriteria3" :{ "Id": "UAC_manualCriteria3","Status":"", "Comment":"", "Rank":"3","Criteria":"Not be involved in an active State licensing, child protective services, or law enforcement investigation, or an investigation resulting from a sexual abuse allegation reported in accordance with Section 4.10"},"UAC_manualCriteria4" :{ "Id": "UAC_manualCriteria4","Status":"", "Comment":"", "Rank":"4","Criteria":"Have no known mental health, dental, or medical issues, including contagious diseases requiring additional evaluation, treatment, or monitoring by a healthcare provider"},"UAC_manualCriteria5" :{ "Id": "UAC_manualCriteria5","Status":"", "Comment":"", "Rank":"5","Criteria":"Initial Intakes Assessment and other UC assessments completed"},"manualCriteraPassCount" :{ "Id": "manualCriteraPassCount","Status":"", "Comment":"", "Rank":"27","Criteria":"", "Pass":""},"UAC_haveKYRAndLegalScreeningCompleted" :{ "Id": "UAC_haveKYRAndLegalScreeningCompleted","Status":"Fail", "Comment":"", "Rank":"16","Criteria":"Have KYR and legal screening completed" },"UAC_notPendingAdjustmentOfLegalStatus" :{ "Id": "UAC_notPendingAdjustmentOfLegalStatus","Status":"Pass", "Comment":"", "Rank":"17","Criteria":"Not pending adjustment of legal status" },"UAC_noFinalOrderOfRemoval" :{ "Id": "UAC_noFinalOrderOfRemoval","Status":"Pass", "Comment":"", "Rank":"18","Criteria":"No cases related to orders of removal or deportation" },"UAC_medicalChecklistCompleted" :{ "Id": "UAC_medicalChecklistCompleted","Status":"Pass", "Comment":"", "Rank":"19","Criteria":"Have a completed Medical Checklist for Influx Transfers" }}';

  private
      static List<String> manualCriteriaMeta = new List<String>{'UAC_manualCriteria1', 'UAC_manualCriteria2', 'UAC_manualCriteria3', 'UAC_manualCriteria4', 'UAC_manualCriteria5'};
  // clang-format on
  private
  static String strInfluxJSON = JSON.serialize(jsonInput);
  private
  static List<Case> lstCaseExpectedToBeReleasedCriteria;
  private
  static List<Case> lstCaseScheduledToBeDischargedCriteria;
  private
  static List<Contact> lstContactIsAge13OrOlderCriteria;
  private
  static List<UAC_admissionAssessment__c> lstAssessmentSpeaksEnglishOrSpanishCriteria;
  private
  static List<UAC_healthEvaluation__c> lstHealthIsNotAPregnantTeenCriteria;
  private
  static List<UAC_apprehendedRelationship__c> lstRelationshipIsNotAParentingTeenCriteria;
  private
  static List<UAC_legal__c> lstLegalScheduledImmigrationHearingCriteria;
  private
  static List<UAC_legal__c> lstLegalAttorneyOfRecordCriteria;
  private
  static List<UAC_apprehendedRelationship__c> lstRelationshipSiblingAge12OrYoungerCriteria;
  private
  static List<UAC_admissionAssessment__c> lstAssessmentPendingAgeCriteria;
  private
  static List<Case> lstCasePendingHomeStudyCriteria;
  private
  static List<Contact> lstContactNotTurning18Criteria;
  private
  static List<Contact> lstContactNotSeparatedFromParentCriteria;
  private
  static List<UAC_adultContactRelationship__c> lstRelationshipNoCategoryFourCriteria;
  private
  static final String strAdmissionCaseRecordType = Label.UAC_caseRecordTypeAdmission;
  private
  static final Boolean boolHasModifyPermission =
      FeatureManagement.checkPermission('UAC_modifyCensus');

  @AuraEnabled public static List<Case> getManifestChildCases(
      List<String> lstCaseIds, String strEntityId) {
    List<UAC_admissionInfluxPrescreening__mdt> lstOfInfluxMeta = getMetadataRecords();
    for (Case objCase : [
           SELECT id,
           CaseNumber,
           ContactId,
           Status,
           UAC_aNum__c,
           UAC_influxScreeningJSON__c,
           UAC_transferMatch__c,
           Contact.Name,
           Contact.UAC_COB__c,
           UAC_age__c,
           UAC_gender__c,
           Contact.UAC_otherGender__c,
           lastModifiedDate FROM Case WHERE CaseNumber =:lstCaseIds AND recordType.DeveloperName
                                                       =:strAdmissionCaseRecordType
         ]) {
      objCase.UAC_influxScreeningJSON__c = jsonInput;
      objCase.UAC_transferMatch__c = 'Pre-Screening Completed';
      mapUACToCase.put(objCase.ContactId, objCase);
      setOfUACs.add(objCase.ContactId);
    }
    if (!mapUACToCase.isEmpty()) {
      preScreeningCheck(lstOfInfluxMeta);
      for (Case objCase : mapUACToCase.values()) {
        objCase.UAC_influxScreeningJSON__c =
            updatePassCount(objCase.UAC_influxScreeningJSON__c, lstOfInfluxMeta);
      }
    }

    if (!mapUACToCase.isEmpty()) {
      try {
        update mapUACToCase.values();
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '', 'Updating influx json', e.getStackTraceString());
        throw new AuraHandledException(e.getdmlMessage(0));
      }
    }
    return [
      SELECT id,
      CaseNumber,
      ContactId,
      Status,
      UAC_aNum__c,
      UAC_influxScreeningJSON__c,
      UAC_transferMatch__c,
      Contact.Name,
      UAC_age__c,
      UAC_gender__c,
      lastModifiedDate FROM Case WHERE UAC_programFacility__c
      =:strEntityId AND recordType.DeveloperName
      =:strAdmissionCaseRecordType AND(Status != 'Pending Admission' AND isClosed = False)
            ORDER BY ContactId
    ];
  }

  public
  static List<UAC_admissionInfluxPrescreening__mdt> getMetadataRecords() {
    return [
      SELECT UAC_datatype__c,
      UAC_description__c,
      UAC_fieldAPIName__c,
      UAC_operator__c,
      UAC_order__c,
      UAC_queryRelatedRecord__c,
      UAC_recordIDRelatedRecord__c,
      UAC_type__c,
      UAC_value__c,
      DeveloperName,
      QualifiedApiName FROM UAC_admissionInfluxPrescreening__mdt Order By UAC_order__c
    ];
  }

  public
  static void preScreeningCheck(List<UAC_admissionInfluxPrescreening__mdt> lstOfInfluxMeta) {
    String strTarget = '{recordId}';
    Set<String> setUACIds = mapUACToCase.keySet();
    String strReplacement = 'setUACIds';
    List<sObject> lstOfFailedAutoField = new List<sObject>();
    List<Contact> lstOfContacts = new List<Contact>();
    List<Case> lstOfCases = new List<Case>();
    List<UAC_diagnosis__c> lstOfDiagnosis = new List<UAC_diagnosis__c>();
    List<UAC_apprehendedRelationship__c> lstOfRelationships =
        new List<UAC_apprehendedRelationship__c>();
    List<UAC_legal__c> lstOfLegal = new List<UAC_legal__c>();
    List<UAC_admissionAssessment__c> lstOfAdmissionAssessments =
        new List<UAC_admissionAssessment__c>();
    List<UAC_adultContactRelationship__c> lstOfAdultContact =
        new List<UAC_adultContactRelationship__c>();

    for (UAC_admissionInfluxPrescreening__mdt objInfluxMeta : lstOfInfluxMeta) {
      List<sObject> lstInfluxPrescreenResults = new List<sObject>();
      String strQuery = objInfluxMeta.UAC_queryRelatedRecord__c.replace(strTarget, strReplacement);
      // Code Review explanation - each custom metadata record represents a new query to validate
      // prescreening for the UAC
      if (objInfluxMeta.UAC_type__c == 'Automatic Related Record') {
        lstInfluxPrescreenResults = Database.query(strQuery);
        if (objInfluxMeta.UAC_order__c == 1 || objInfluxMeta.UAC_order__c == 2
            || objInfluxMeta.UAC_order__c == 14 || objInfluxMeta.UAC_order__c == 16
            || objInfluxMeta.UAC_order__c == 17) {
          lstOfCases = Database.query(strQuery);
          if (!lstOfCases.isEmpty()) {
            processFailedCases(lstOfCases, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 5) {
          lstOfDiagnosis = Database.query(strQuery);
          if (!lstOfDiagnosis.isEmpty()) {
            processAgeFailedDiagnosis(lstOfDiagnosis, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 6) {
          lstOfRelationships = Database.query(strQuery);
          if (!lstOfRelationships.isEmpty()) {
            processAgeFailedRelationships(lstOfRelationships, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 7 || objInfluxMeta.UAC_order__c == 8
            || objInfluxMeta.UAC_order__c == 9) {
          lstOfLegal = Database.query(strQuery);
          if (!lstOfLegal.isEmpty()) {
            processFailedLegal(lstOfLegal, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 10 || objInfluxMeta.UAC_order__c == 11
            || objInfluxMeta.UAC_order__c == 18) {
          lstOfContacts = Database.query(strQuery);
          if (!lstOfContacts.isEmpty()) {
            processAgeFailedContacts(lstOfContacts, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 13) {
          lstOfAdmissionAssessments = Database.query(strQuery);
          if (!lstOfAdmissionAssessments.isEmpty()) {
            processAgeFailedAssessments(lstOfAdmissionAssessments, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 19) {
          lstOfAdultContact = Database.query(strQuery);
          if (!lstOfAdultContact.isEmpty()) {
            processAgeFailedAdultContacts(lstOfAdultContact, objInfluxMeta);
          }
        }
      } else if (objInfluxMeta.UAC_type__c == 'Automatic Field') {
        if (objInfluxMeta.UAC_order__c == 3) {
          lstOfContacts = Database.query(strQuery);
          if (!lstOfContacts.isEmpty()) {
            processAgeFieldCriteria(lstOfContacts, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 4) {
          lstOfAdmissionAssessments = Database.query(strQuery);
          if (!lstOfAdmissionAssessments.isEmpty()) {
            processPrimaryLanguage(lstOfAdmissionAssessments, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 12) {
          lstOfRelationships = Database.query(strQuery);
          if (!lstOfRelationships.isEmpty()) {
            processSiblingAgeFieldCriteria(lstOfRelationships, objInfluxMeta);
          }
        } else if (objInfluxMeta.UAC_order__c == 15) {
          lstOfContacts = Database.query(strQuery);
          if (!lstOfContacts.isEmpty()) {
            processBirthdateCriteria(lstOfContacts, objInfluxMeta);
          }
        }
      }
    }
  }

  public
  static void processAgeFieldCriteria(
      List<Contact> lstOfContacts, UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (Contact objContact : lstOfContacts) {
      if (Integer.valueOf(objContact.UAC_currentAge__c) >= 13) {
        String strCaseInfluxJSON = mapUACToCase.get(objContact.Id).UAC_influxScreeningJSON__c;
        Map<String, Object> mapDeserializedJSON =
            (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
        Map<String, Object> mapCriteria =
            (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
        mapCriteria.put('Status', 'Pass');
        mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
        mapUACToCase.get(objContact.Id).UAC_influxScreeningJSON__c =
            JSON.serialize(mapDeserializedJSON);
      }
    }
  }

  public
  static void processSiblingAgeFieldCriteria(
      List<UAC_apprehendedRelationship__c> lstOfFailedCriteria,
      UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_apprehendedRelationship__c objRelationship : lstOfFailedCriteria) {
      if (objRelationship.UAC_age__c != null && Integer.valueOf(objRelationship.UAC_age__c) <= 12) {
        String strCaseInfluxJSON =
            mapUACToCase.get(objRelationship.UAC_uacLookup__c).UAC_influxScreeningJSON__c;
        Map<String, Object> mapDeserializedJSON =
            (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
        Map<String, Object> mapCriteria =
            (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
        mapCriteria.put('Status', 'Fail');
        mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
        mapUACToCase.get(objRelationship.UAC_uacLookup__c).UAC_influxScreeningJSON__c =
            JSON.serialize(mapDeserializedJSON);
      }
    }
  }

  public
  static void processBirthdateCriteria(
      List<Contact> lstOfContacts, UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (Contact objContact : lstOfContacts) {
      Date startDate = System.today();
      Date dateOfBirth = Date.ValueOf(objContact.Birthdate);
      Integer intAge = dateOfBirth.daysBetween(startDate) / 365;
      if (intAge >= 18) {
        String strCaseInfluxJSON = mapUACToCase.get(objContact.Id).UAC_influxScreeningJSON__c;
        Map<String, Object> mapDeserializedJSON =
            (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
        Map<String, Object> mapCriteria =
            (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
        mapCriteria.put('Status', 'Fail');
        mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
        mapUACToCase.get(objContact.Id).UAC_influxScreeningJSON__c =
            JSON.serialize(mapDeserializedJSON);
      }
    }
  }

  public
  static void processPrimaryLanguage(List<UAC_admissionAssessment__c> lstOfAdmissionAssessments,
      UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_admissionAssessment__c objAssessment : lstOfAdmissionAssessments) {
      if (objAssessment.UAC_primaryLanguageSpoken__c == 'English'
          || objAssessment.UAC_primaryLanguageSpoken__c == 'Spanish') {
        String strCaseInfluxJSON =
            mapUACToCase.get(objAssessment.UAC_uac__c).UAC_influxScreeningJSON__c;
        Map<String, Object> mapDeserializedJSON =
            (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
        Map<String, Object> mapCriteria =
            (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
        mapCriteria.put('Status', 'Pass');
        mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
        mapUACToCase.get(objAssessment.UAC_uac__c).UAC_influxScreeningJSON__c =
            JSON.serialize(mapDeserializedJSON);
      }
    }
  }

  public
  static void processFailedCases(
      List<Case> lstOfFailedCases, UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (Case objCase : lstOfFailedCases) {
      String strCaseInfluxJSON = mapUACToCase.get(objCase.ContactId).UAC_influxScreeningJSON__c;
      Map<String, Object> mapDeserializedJSON =
          (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      mapCriteria.put('Status', 'Fail');
      mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
      mapUACToCase.get(objCase.ContactId).UAC_influxScreeningJSON__c =
          JSON.serialize(mapDeserializedJSON);
    }
  }
  public
  static void processAgeFailedDiagnosis(List<UAC_diagnosis__c> lstOfFailedDiagnosis,
      UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_diagnosis__c objDiagnosis : lstOfFailedDiagnosis) {
      String strCaseInfluxJSON =
          mapUACToCase.get(objDiagnosis.UAC_associatedUAC__c).UAC_influxScreeningJSON__c;
      Map<String, Object> mapDeserializedJSON =
          (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      mapCriteria.put('Status', 'Fail');
      mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
      mapUACToCase.get(objDiagnosis.UAC_associatedUAC__c).UAC_influxScreeningJSON__c =
          JSON.serialize(mapDeserializedJSON);
    }
  }
  public
  static void processAgeFailedRelationships(
      List<UAC_apprehendedRelationship__c> lstOfFailedRelationship,
      UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_apprehendedRelationship__c objRelationship : lstOfFailedRelationship) {
      String strCaseInfluxJSON =
          mapUACToCase.get(objRelationship.UAC_uacLookup__c).UAC_influxScreeningJSON__c;
      Map<String, Object> mapDeserializedJSON =
          (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      mapCriteria.put('Status', 'Fail');
      mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
      mapUACToCase.get(objRelationship.UAC_uacLookup__c).UAC_influxScreeningJSON__c =
          JSON.serialize(mapDeserializedJSON);
    }
  }
  public
  static void processFailedLegal(
      List<UAC_legal__c> lstOfFailedLegal, UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_legal__c objLegal : lstOfFailedLegal) {
      if (objInfluxMeta.UAC_order__c == 7) {
        String strCaseInfluxJSON =
            mapUACToCase.get(objLegal.UAC_uacProfile__c).UAC_influxScreeningJSON__c;
        Map<String, Object> mapDeserializedJSON =
            (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
        Map<String, Object> mapCriteria =
            (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
        mapCriteria.put('Status', 'Pass');
        mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
        mapUACToCase.get(objLegal.UAC_uacProfile__c).UAC_influxScreeningJSON__c =
            JSON.serialize(mapDeserializedJSON);
      } else {
        String strCaseInfluxJSON =
            mapUACToCase.get(objLegal.UAC_uacProfile__c).UAC_influxScreeningJSON__c;
        Map<String, Object> mapDeserializedJSON =
            (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
        Map<String, Object> mapCriteria =
            (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
        mapCriteria.put('Status', 'Fail');
        mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
        mapUACToCase.get(objLegal.UAC_uacProfile__c).UAC_influxScreeningJSON__c =
            JSON.serialize(mapDeserializedJSON);
      }
    }
  }
  public
  static void processAgeFailedContacts(
      List<Contact> lstOfFailedContact, UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (Contact objContact : lstOfFailedContact) {
      String strCaseInfluxJSON = mapUACToCase.get(objContact.Id).UAC_influxScreeningJSON__c;
      Map<String, Object> mapDeserializedJSON =
          (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      mapCriteria.put('Status', 'Fail');
      mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
      mapUACToCase.get(objContact.Id).UAC_influxScreeningJSON__c =
          JSON.serialize(mapDeserializedJSON);
    }
  }
  public
  static void processAgeFailedAssessments(List<UAC_admissionAssessment__c> lstOfFailedAssessments,
      UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_admissionAssessment__c objAssessment : lstOfFailedAssessments) {
      String strCaseInfluxJSON =
          mapUACToCase.get(objAssessment.UAC_uac__c).UAC_influxScreeningJSON__c;
      Map<String, Object> mapDeserializedJSON =
          (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      mapCriteria.put('Status', 'Fail');
      mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
      mapUACToCase.get(objAssessment.UAC_uac__c).UAC_influxScreeningJSON__c =
          JSON.serialize(mapDeserializedJSON);
    }
  }
  public
  static void processAgeFailedAdultContacts(
      List<UAC_adultContactRelationship__c> lstOfFailedAdultContacts,
      UAC_admissionInfluxPrescreening__mdt objInfluxMeta) {
    for (UAC_adultContactRelationship__c objAdultContact : lstOfFailedAdultContacts) {
      String strCaseInfluxJSON =
          mapUACToCase.get(objAdultContact.UAC_uacLookup__c).UAC_influxScreeningJSON__c;
      Map<String, Object> mapDeserializedJSON =
          (Map<String, Object>) JSON.deserializeUntyped(strCaseInfluxJSON);
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      mapCriteria.put('Status', 'Fail');
      mapDeserializedJSON.put(objInfluxMeta.DeveloperName, mapCriteria);
      mapUACToCase.get(objAdultContact.UAC_uacLookup__c).UAC_influxScreeningJSON__c =
          JSON.serialize(mapDeserializedJSON);
    }
  }
  @AuraEnabled public static List<Case> updateEntryInflux(String strCaseNum, String strInfluxJSON) {
    if (!boolHasModifyPermission) {
      return null;
    }
    List<UAC_admissionInfluxPrescreening__mdt> lstOfInfluxMeta = getMetadataRecords();
    Case objCase = [SELECT Id,
      UAC_influxScreeningJSON__c,
      UAC_programFacility__c,
      UAC_transferMatch__c FROM Case WHERE CaseNumber =:strCaseNum];
    String strUnescape = strInfluxJSON.unescapeJava();
    strUnescape = strUnescape.replaceAll(']', '}').unescapeJava();
    objCase.UAC_influxScreeningJSON__c = updatePassCount(strInfluxJSON, lstOfInfluxMeta);
    Map<String, Object> mapDeserializedJSON =
        (Map<String, Object>) JSON.deserializeUntyped(objCase.UAC_influxScreeningJSON__c);
    Map<String, Object> mapCriteria =
        (Map<String, Object>) mapDeserializedJSON.get('CriteraPassCount');
    Map<String, Object> mapManualCriteria =
        (Map<String, Object>) mapDeserializedJSON.get('manualCriteraPassCount');
    if (String.valueOf(mapCriteria.get('Pass')).startsWithIgnoreCase('19')
        && String.valueOf(mapManualCriteria.get('Pass')).startsWithIgnoreCase('5')) {
      objCase.UAC_transferMatch__c = 'Eligible';
    } else {
      objCase.UAC_transferMatch__c = 'Not Eligible';
    }

    try {
      if (objCase != null) {
        update objCase;
      }

    } catch (Exception e) {
      UAC_errorLog.logError(
          e.getMessage(), '', 'Updating influx json on entry', e.getStackTraceString());
    }
    return getCaseRecords(objCase.UAC_programFacility__c);
  }
  @AuraEnabled(cacheable = true) public static List<Case> getCaseRecords(String strEntityId) {
    InnerClass innerClassObj = new InnerClass();
    return innerClassObj.getCaseRecords(strEntityId);
  }
  private
  with sharing class InnerClass {
    public
    List<Case> getCaseRecords(String strEntityId) {
      return [
        SELECT id,
        CaseNumber,
        ContactId,
        Status,
        UAC_aNum__c,
        UAC_influxScreeningJSON__c,
        UAC_transferMatch__c,
        Contact.Name,
        UAC_age__c,
        UAC_gender__c,
        lastModifiedDate FROM Case WHERE UAC_programFacility__c
        =:strEntityId AND recordType.DeveloperName
        =:strAdmissionCaseRecordType AND(Status != 'Pending Admission' AND isClosed = False)
              ORDER BY ContactId
      ];
    }
  } public static String updatePassCount(
      String strInfluxJSON, List<UAC_admissionInfluxPrescreening__mdt> lstOfInfluxMeta) {
    Integer intPassCount = 0;
    Integer intManualPassCount = 0;
    Boolean boolOverride = false;
    Map<String, Object> mapDeserializedJSON =
        (Map<String, Object>) JSON.deserializeUntyped(strInfluxJSON);
    for (UAC_admissionInfluxPrescreening__mdt objInfluxMeta : lstOfInfluxMeta) {
      Map<String, Object> mapCriteria =
          (Map<String, Object>) mapDeserializedJSON.get(objInfluxMeta.DeveloperName);
      if (mapCriteria.get('Status') == 'Pass') {
        intPassCount++;
      }
      if (mapCriteria.get('Status') == 'Passed (Override)') {
        intPassCount++;
        boolOverride = true;
      }
    }
    for (String strKey : manualCriteriaMeta) {
      Map<String, Object> mapCriteria = (Map<String, Object>) mapDeserializedJSON.get(strKey);
      if (mapCriteria.get('Status') == 'Pass') {
        intManualPassCount++;
      }
    }
    Map<String, Object> mapPassCount =
        (Map<String, Object>) mapDeserializedJSON.get('CriteraPassCount');
    mapPassCount.put('Pass', String.valueOf(intPassCount));
    if (boolOverride) {
      mapPassCount.put('Comment', 'Override');
    }
    mapDeserializedJSON.put('CriteraPassCount', mapPassCount);
    Map<String, Object> mapManualPassCount =
        (Map<String, Object>) mapDeserializedJSON.get('manualCriteraPassCount');

    mapManualPassCount.put('Pass', String.valueOf(intManualPassCount));
    mapDeserializedJSON.put('manualCriteraPassCount', mapManualPassCount);
    return JSON.serialize(mapDeserializedJSON);
  }

  @AuraEnabled public static SaveResponse setTransferMatch(
      List<TransferMatchResult> transferMatchResults) {
    if (!boolHasModifyPermission) {
      return null;
    }
    SaveResponse newResponse = new SaveResponse();
    newResponse.success = false;
    newResponse.message = 'Default';
    if (transferMatchResults == null || transferMatchResults.isEmpty()) {
      newResponse.message = 'You have not selected any UACs to update transfer match for.';
      return newResponse;
    }
    List<Case> listCasesToUpdate = new List<Case>();
    System.debug('transferMatchResults');
    System.debug(transferMatchResults);
    for (TransferMatchResult objMatch : transferMatchResults) {
      if (String.isBlank(objMatch.caseId)) {
        newResponse.message = 'You have not provided a record ID to update.';
        return newResponse;
      }
      listCasesToUpdate.add(new Case(Id = objMatch.caseId,
          UAC_transferMatch__c = objMatch.boolMatch ? 'Eligible' : 'Not Eligible'));
    }
    if (!listCasesToUpdate.isEmpty()) {
      try {
        update listCasesToUpdate;
      } catch (DMLException de) {
        newResponse.message = de.getMessage().substringAfter('first error: ');
        return newResponse;
      }
    }
    newResponse.success = true;
    return newResponse;
  }
  @AuraEnabled public static void updateManualCompletedDate(String strCaseNum) {
    if (!boolHasModifyPermission) {
      return;
    }
    Case objCase =
        [SELECT Id, UAC_manualReviewCompletedDateTime__c FROM Case WHERE CaseNumber =:strCaseNum];
    objCase.UAC_manualReviewCompletedDateTime__c = System.now();
    try {
      if (objCase != null) {
        update objCase;
      }
    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'Updating manual review completed datetime on entry',
          e.getStackTraceString());
    }
  }

  Private without sharing Class TransferMatchResult {
    @AuraEnabled public String caseId;
    @AuraEnabled public Boolean boolMatch;
  }

  Private without sharing Class SaveResponse {
    @AuraEnabled public String message;
    @AuraEnabled public Boolean success;
  }
}