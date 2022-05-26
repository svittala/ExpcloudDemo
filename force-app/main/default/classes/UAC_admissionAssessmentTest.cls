/**
 * @File Name          : UAC_admissionAssessmentTest.cls
 * @Description        : Helper method for Admission Assessment code including
 *                       UAC_admissionAssessmentTriggerHelper
 * @Author             : James Qian (Deloitte)
 * @Group              : Test
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/15/2020   James Qian (Deloitte)     Initial Implementation.
 * 1.1    8/12/2020   Chaitanya Nandamuri(Deloitte) Test for Auto population.
 * 1.2    10/15/2020  Abhisek Pati (Deloitte)    Added test method for Email Notification.
 * 1.3    10/20/2020  Abhisek Pati (Deloitte)    ORRUAC-3129 Added test coverage.
 */
@isTest public without sharing class UAC_admissionAssessmentTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static final Map<String, Schema.RecordTypeInfo> mapAssessmentRecordTypes =
      Schema.SObjectType.UAC_admissionAssessment__c.getRecordTypeInfosByDeveloperName();
  private
  static AccountTeamMember objAtm1;
  private
  static AccountTeamMember objAtm2;
  private
  static final String STR_A_NUM_ADULT_CONTACT = '123456788';

  /**
   * @description Sets up generic test data
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @TestSetup static void setupTestData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    System.debug('Queries after Inserting Contact: ' + Limits.getQueries());
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;
    objUACContact.AccountId = objProgram.Id;
    update objUACContact;
    System.debug('Queries after Inserting Account: ' + Limits.getQueries());
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 1, true);
    System.debug('Queries after Inserting Asset: ' + Limits.getQueries());
    Case objUACReferralCase = new UAC_testCaseBuilder()
                                  .setStatus('Processed Pending')
                                  .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                                  .setUAC(objUACContact.id)
                                  .buildAndSave();
    System.debug('Queries after Inserting Case: ' + Limits.getQueries());
    objUACReferralCase.UAC_programFacility__c = objProgram.Id;
    update objUACReferralCase;
    System.debug('Queries after Updating Case: ' + Limits.getQueries());
    Id idAdmissionCase = [SELECT Id FROM Case].Id;

    Map<String, Id> mapCaseTeamRoles = UAC_TestUtility.getCaseTeamRoleMap();
    UAC_TestUtility.createCaseTeamMember(UserInfo.getUserId(),
        mapCaseTeamRoles.get(Label.UAC_caseTeamRoleNameCM),
        idAdmissionCase,
        true);
    System.debug('Queries after Test Setup: ' + Limits.getQueries());
  }

  /**
   * @description Tests positive cases of setting fields on insert
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void insertingAssessmentShouldSetFields() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, true);
    UAC_admissionAssessment__c assessmentQueried = getAdmissionAssessment(assessmentNew.Id);
    Test.stopTest();
    System.assertEquals(idUAC, assessmentQueried.UAC_uac__c);
    System.assertEquals(UserInfo.getUserId(), assessmentQueried.UAC_caseManagerLookup__c);
  }

  /**
   * @description Tests positive cases of rejecting duplicate assessment
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void insertingAssessmentShouldRejectDuplicates() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, true);
    String strError;
    try {
      UAC_admissionAssessment__c assessmentDuplicate = UAC_TestUtility.createAdmissionAssessment(
          idAdmissionCase, Label.UAC_assessmentRecordTypeISP, true);
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
  }

  /**
   * @description Tests positive cases of setting health information on risk assessment insert
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void insertingRiskAssessmentShouldSetHealthFields() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(idUAC)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .build();
    objIME.UAC_measuredHeight__c = 50;
    objIME.UAC_measuredWeight__c = 100;
    objIME.UAC_BMIPercentile__c = 28;
    insert objIME;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeRisk, true);
    UAC_admissionAssessment__c assessmentQueried = getAdmissionAssessment(assessmentNew.Id);
    Test.stopTest();
    System.assertNotEquals(null, assessmentQueried.UAC_height__c);
    System.assertNotEquals(null, assessmentQueried.UAC_weight__c);
    System.assertNotEquals(null, assessmentQueried.UAC_bMI__c);
  }

  /**
   * @description Tests positive cases of setting health evaluation lookup
   * @author James Qian (Deloitte) | 10/6/2020
   * @return void
   **/
  @isTest static void insertingInitialAssessmentShouldSetHealthEvalLookup() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(idUAC)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .buildAndSave();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    UAC_admissionAssessment__c assessmentQueried = getAdmissionAssessment(assessmentNew.Id);
    Test.stopTest();
    System.assertEquals(objIME.Id, assessmentQueried.UAC_healthEvaluationIme__c);
  }

  /**
   * @description Tests positive cases of setting fields on update
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldSetFields() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, false);
    assessmentNew.UAC_caseManagerLookup__c = UserInfo.getUserId();
    assessmentNew.UAC_clinicianLookup__c = UserInfo.getUserId();
    insert assessmentNew;
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    update assessmentNew;
    UAC_admissionAssessment__c assessmentQueried = getAdmissionAssessment(assessmentNew.Id);
    Test.stopTest();
    System.assertEquals(System.Today(), assessmentQueried.UAC_submittedDate__c);
  }

  /**
   * @description Tests positive cases of setting language on parent Contact
   * @author James Qian (Deloitte) | 10/6/2020
   * @return void
   **/
  @isTest static void updatingInitialAssessmentShouldUpdateLanguage() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    assessmentNew.UAC_primaryLanguageSpoken__c = 'English';
    update assessmentNew;
    Contact contactQueried =
        [SELECT Id, UAC_primaryLanguageSpoken__c FROM Contact WHERE Id =:idUAC];
    Test.stopTest();
    System.assertEquals(
        assessmentNew.UAC_primaryLanguageSpoken__c, contactQueried.UAC_primaryLanguageSpoken__c);
  }

  /**
   * @description Tests positive cases of locking fields on update
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldLockOnSubmit() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    insert assessmentNew;
    assessmentNew.UAC_caseManagerLookup__c = null;
    String strError;
    try {
      assessmentNew.UAC_caseManagerLookup__c = null;
      update assessmentNew;
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
  }

  /**
   * @description Tests positive cases of requiring fields on submit
   * @author James Qian (Deloitte) | 07/23/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldRequireFieldsOnSubmit() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    delete[select id from caseteammember];
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending;
    insert assessmentNew;
    String strError;
    try {
      assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
      update assessmentNew;
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
    System.assert(strError.containsIgnoreCase('Required field missing'));
  }

  /**
   * @description Tests positive cases of enforcing dependencies on update
   * @author James Qian (Deloitte) | 07/16/2020
   * @return void
   **/
  @isTest static void updatingRiskAssessmentShouldThrowErrorWhenPending() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeRisk, true);
    String strError;
    try {
      update new UAC_admissionAssessment__c(
          Id = assessmentNew.Id, UAC_otherSpecificInformationOrSafety__c = 'Yes');
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
  }

  /**
   * @description Tests positive cases of running batch class for tasks
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void runningBatchShouldCreateTask() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    assessmentNew.UAC_submittedDate__c =
        System.Today().addDays(-1 * Integer.valueOf(Label.UAC_assessmentOffsetShort));
    assessmentNew.UAC_mostRecentAssessment__c = true;
    insert assessmentNew;
    Database.executeBatch(new UAC_batchNotifyAdmissionAssessment());
    Test.stopTest();
    Task taskQueried = getTask(idAdmissionCase);
    System.assertEquals(UserInfo.getUserId(), taskQueried.OwnerId);
  }
  /**
   * @description Tests Auto population on Assessment creation.
   * @author Chaitanya Nandamuri (Deloitte) | 08/13/2020
   * @return void
   **/
  @isTest static void assessmentFieldsAutoPopulation() {
    test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    List<UAC_allergy__c> lstAllergies = new List<UAC_allergy__c>();
    Integer count = 1;
    While(count < 6) {
      UAC_allergy__c allergy = new UAC_allergy__c();
      allergy.UAC_associatedUAC__c = idUAC;
      allergy.UAC_allergyType__c = 'Food';
      allergy.UAC_reaction__c = 'Stomach upset';
      allergy.UAC_allergen__c = 'Peanuts' + count;
      lstAllergies.add(allergy);
      count++;
    }
    insert lstAllergies;
    UAC_admissionAssessment__c initialIntakesAssesment = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);

    UAC_admissionAssessment__c Assesment = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeAssessment, true);

    UAC_admissionAssessment__c CaseReviewAssesment = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeReview, true);

    String autoPopulateAllergy =
        [select UAC_listAnyAllergies__c from UAC_admissionAssessment__c where
                recordtype.developername =:Label.UAC_assessmentRecordTypeAssessment limit 1]
            .UAC_listAnyAllergies__c;
    test.stopTest();
    for (UAC_allergy__c allergy : lstAllergies) {
      system.assert(autoPopulateAllergy.contains(allergy.UAC_allergen__c));
    }
  }

  /**
   * @description Tests positive cases of running batch class to create Review tasks
   * @author Chaitanya Nandamuri (Deloitte) | 07/16/2020
   * @return void
   **/
  @isTest static void runningBatchShouldCreateReviewTask() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c ReviewassessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeReview, false);
    ReviewassessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    ReviewassessmentNew.UAC_submittedDate__c =
        System.Today().addDays(-1 * Integer.valueOf(Label.UAC_assessmentOffsetShort));
    ReviewassessmentNew.UAC_mostRecentAssessment__c = true;
    insert ReviewassessmentNew;
    Database.executeBatch(new UAC_batchNotifyAdmissionAssessment());
    Test.stopTest();
    Task taskQueried = getTask(idAdmissionCase);
    System.assertEquals(UserInfo.getUserId(), taskQueried.OwnerId);
  }

  /**
   * @description Tests positive cases of running scheduled job
   * @author James Qian (Deloitte) | 07/15/2020
   * @return void
   **/
  @isTest static void runningSchedulerShouldStartBatch() {
    Test.startTest();
    Boolean boolScheduled;
    try {
      UAC_scheduleBatchNotify newInstanceScheduled = new UAC_scheduleBatchNotify();
      System.Schedule('Test runningSchedulerShouldStartBatch',
          UAC_scheduleBatchNotify.STR_CRON_EXP,
          newInstanceScheduled);
      boolScheduled = true;
    } catch (Exception e) {
      boolScheduled = false;
    }
    Test.stopTest();
    System.assertEquals(true, boolScheduled);
  }

  /**
   * @description Tests positive cases of creating snapshot records for Adult Contact Relationships
   * @author James Qian (Deloitte) | 10/29/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldSetSnapshotForACR() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT)
            .build();
    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Potential Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = idUAC;
    insert objAdultContactRelationship;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending;
    insert assessmentNew;
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    UAC_admissionAssessmentTriggerHandler.boolRun = false;
    update assessmentNew;
    Test.stopTest();
    System.AssertEquals(1, getAdmissionAssessmentSnapshot().size());
  }

  /**
   * @description Tests positive cases of creating snapshot records for UAC Children
   * @author James Qian (Deloitte) | 10/29/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldSetSnapshotForUACC() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_ADULT_CONTACT)
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Id idRecordType = Schema.getGlobalDescribe()
                          .get('UAC_apprehendedRelationship__c')
                          .getDescribe()
                          .getRecordTypeInfosByDeveloperName()
                          .get('UAC_apprehendedUAC')
                          .getRecordTypeId();
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            idUAC, objUACContact.Id, idRecordType, 'Son', true);
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeAssessment, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending;
    insert assessmentNew;
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    UAC_admissionAssessmentTriggerHandler.boolRun = false;
    update assessmentNew;
    Test.stopTest();
    System.AssertEquals(1, getAdmissionAssessmentSnapshot().size());
  }

  /**
   * @description Tests positive cases of creating snapshot records for Medications
   * @author James Qian (Deloitte) | 10/29/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldSetSnapshotForMed() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Contact objUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC];
    UAC_Diagnosis__c Diagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUAC);
    UAC_medication__c objMedication =
        new UAC_testMedicationBuilder().buildAndSave(objUAC, Diagnosis, null);
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending;
    insert assessmentNew;
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    UAC_admissionAssessmentTriggerHandler.boolRun = false;
    update assessmentNew;
    Test.stopTest();
    System.AssertEquals(1, getAdmissionAssessmentSnapshot().size());
  }

  /**
   * @description Tests positive cases of creating snapshot records for Family Friends
   * @author James Qian (Deloitte) | 10/29/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldSetSnapshotForFF() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    Id idRecordType = Schema.getGlobalDescribe()
                          .get('UAC_apprehendedRelationship__c')
                          .getDescribe()
                          .getRecordTypeInfosByDeveloperName()
                          .get('UAC_familyFriend')
                          .getRecordTypeId();
    UAC_apprehendedRelationship__c objFF =
        new UAC_apprehendedRelationship__c(RecordTypeId = idRecordType,
            UAC_uacLookup__c = idUAC,
            UAC_firstName__c = 'John',
            UAC_lastName__c = 'Smith');
    insert objFF;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending;
    insert assessmentNew;
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    UAC_admissionAssessmentTriggerHandler.boolRun = false;
    update assessmentNew;
    Test.stopTest();
    System.AssertEquals(1, getAdmissionAssessmentSnapshot().size());
  }

  /**
   * @description Tests positive cases of creating snapshot records for Previous Sponsor
   *Applications
   * @author James Qian (Deloitte) | 10/29/2020
   * @return void
   **/
  @isTest static void updatingAssessmentShouldSetSnapshotForPSA() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT)
            .build();
    insert objAdultContact;
    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = idUAC;
    insert objAdultContactRelationship;
    Case objActiveSponsorCase =
        new UAC_testCaseBuilder().setUAC(idUAC).setSponsor(objAdultContact.Id).build();
    objActiveSponsorCase.UAC_relationshipToUAC__c = objAdultContactRelationship.Id;
    insert objActiveSponsorCase;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeAssessment, false);
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending;
    insert assessmentNew;
    assessmentNew.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    UAC_admissionAssessmentTriggerHandler.boolRun = false;
    update assessmentNew;
    Test.stopTest();
    System.AssertEquals(2, getAdmissionAssessmentSnapshot().size());
  }

  /**
   * @description Tests positive cases of Intake Assesment for Harming others scenario
   * @author Karthi Subramanian (Deloitte) | 10/13/2020
   * @return void
   **/
  @isTest static void updatingInitialAssessmentHurtingOthersField() {
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Map<String, Id> mapCaseTeamRoles = UAC_TestUtility.getCaseTeamRoleMap();
    User usrClincian = UAC_TestUtility.createUser('System Administrator');
    User usrLeadClincian = UAC_TestUtility.createUser('System Administrator');
    UAC_TestUtility.createCaseTeamMember(usrClincian.Id,
        mapCaseTeamRoles.get(Label.UAC_caseTeamRoleNameClinician),
        idAdmissionCase,
        true);
    UAC_TestUtility.createCaseTeamMember(usrLeadClincian.Id,
        mapCaseTeamRoles.get(Label.UAC_caseTeamRoleNameLC),
        idAdmissionCase,
        true);
    Test.startTest();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    assessmentNew.UAC_thoughtsOfHurtingYourselfOrOthers__c = System.label.UAC_Yes;
    update assessmentNew;
    Test.stopTest();
    System.assertEquals(
        System.label.UAC_Yes, assessmentNew.UAC_thoughtsOfHurtingYourselfOrOthers__c);
  }

  /**
   * @description Tests positive cases of Intake Assesment for Victim scenario
   * @author Abhisek Pati (Deloitte) | 10/15/2020
   * @return void
   **/
  @isTest static void updatingInitialAssessmentVictimField() {
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:Label.UAC_accountRecordTypeAPINameProgram]
                       .Id;
    Id idUACContact = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                          .Id;
    Map<String, Id> mapCaseTeamRoles = UAC_TestUtility.getCaseTeamRoleMap();
    User usrClincian = UAC_TestUtility.createUser('System Administrator');
    User usrLeadClincian = UAC_TestUtility.createUser('System Administrator');
    List<Account> objTestFamGrp = [select id from Account where Name = 'Test Family Name'];
    UAC_TestUtility.createCaseTeamMember(usrClincian.Id,
        mapCaseTeamRoles.get(Label.UAC_caseTeamRoleNameClinician),
        idAdmissionCase,
        true);
    UAC_TestUtility.createCaseTeamMember(usrLeadClincian.Id,
        mapCaseTeamRoles.get(Label.UAC_caseTeamRoleNameLC),
        idAdmissionCase,
        true);
    objAtm1 = new AccountTeamMember(
        AccountId = idProgram, TeamMemberRole = 'Medical Coordinator', UserId = usrLeadClincian.Id);
    insert objAtm1;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    assessmentNew.UAC_uac__c = idUACContact;
    update assessmentNew;
    Test.startTest();
    assessmentNew.UAC_victimOfSexualAssaultRapedLast72__c = System.label.UAC_Yes;
    assessmentNew.UAC_takingAnythingOtherThanPrescribed__c = System.label.UAC_Yes;
    update assessmentNew;
    Test.stopTest();
    System.assertEquals(
        System.label.UAC_Yes, assessmentNew.UAC_victimOfSexualAssaultRapedLast72__c);
  }

  /**
   * @description Test check for duplicates with multiple different record types
   * @author Issam Awwad (Deloitte) | 09/28/2021
   * @return void
   **/
  @isTest static void testWithMultipleAdmissionAssessmentInitialRecordTypes() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    String strError;
    try {
      UAC_admissionAssessment__c assessmentDuplicate = UAC_TestUtility.createAdmissionAssessment(
          idAdmissionCase, Label.UAC_initialIntakesAssessmentRecordType, true);
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
  }
  /**
   * @description Test check for duplicates with multiple different record types
   * @author Issam Awwad (Deloitte) | 09/28/2021
   * @return void
   **/
  @isTest static void testWithMultipleAdmissionAssessmentReviewRecordTypes() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeReview, true);
    String strError;
    try {
      UAC_admissionAssessment__c assessmentDuplicate = UAC_TestUtility.createAdmissionAssessment(
          idAdmissionCase, Label.UAC_assessmentRecordTypeReview, true);
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
  }
  /**
   * @description Test check for duplicates with multiple different record types
   * @author Issam Awwad (Deloitte) | 09/28/2021
   * @return void
   **/
  @isTest static void testWithMultipleAdmissionAssessmentRiskRecordTypes() {
    Test.startTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeRisk, true);
    String strError;
    try {
      UAC_admissionAssessment__c assessmentDuplicate = UAC_TestUtility.createAdmissionAssessment(
          idAdmissionCase, Label.UAC_assessmentRecordTypeRisk, true);
    } catch (DMLException e) {
      strError = e.getMessage();
    }
    Test.stopTest();
    System.assert(String.isNotBlank(strError));
  }
  /**
   * @description Test sync service records to isp
   * @author Issam Awwad (Deloitte) | 09/28/2021
   * @return void
   **/
  @isTest static void testSyncServiceRecordstoISP() {

    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    Id idUAC = [SELECT Id FROM Contact WHERE RecordType.DeveloperName
        =:Label.UAC_contactRecordTypeApiNameUAC]
                   .Id;
    Account objProgram = [select id from Account limit 1];
    UAC_admissionAssessment__c assessmentExisting = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, true);
    assessmentExisting.UAC_mostRecentAssessment__c = false;

    assessmentExisting.UAC_clinicianLookup__c = userinfo.getuserid();
    update assessmentExisting;
    assessmentExisting.UAC_assessmentStatus__c = Label.UAC_assessmentStatusSubmitted;
    update assessmentExisting;
    List<Contract> lstOfContracts = new List<Contract>();
    Contract objMandatoryContract = new Contract();
    objMandatoryContract.UAC_individualServicePlan__c = assessmentExisting.Id;
    objMandatoryContract.AccountId = objProgram.Id;
    objMandatoryContract.recordTypeId =
        Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName()
            .get(Label.UC_contractMandatoryRecordType)
            .getRecordTypeId();
    lstOfContracts.add(objMandatoryContract);
    Contract objMandatoryContract2 = new Contract();
    objMandatoryContract2.UAC_individualServicePlan__c = assessmentExisting.Id;
    objMandatoryContract2.AccountId = objProgram.Id;
    objMandatoryContract2.recordTypeId =
        Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName()
            .get(Label.UC_contractMandatoryRecordType)
            .getRecordTypeId();
    lstOfContracts.add(objMandatoryContract2);

    Contract objOptionalContract = new Contract();
    objOptionalContract.UAC_individualServicePlan__c = assessmentExisting.Id;
    objOptionalContract.AccountId = objProgram.Id;
    objOptionalContract.recordTypeId =
        Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName()
            .get(Label.UC_contractOptionalRecordType)
            .getRecordTypeId();
    lstOfContracts.add(objOptionalContract);
    Contract objOptionalContract2 = new Contract();
    objOptionalContract2.UAC_individualServicePlan__c = assessmentExisting.Id;
    objOptionalContract2.AccountId = objProgram.Id;
    objOptionalContract2.recordTypeId =
        Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName()
            .get(Label.UC_contractOptionalRecordType)
            .getRecordTypeId();
    lstOfContracts.add(objOptionalContract2);
    insert lstOfContracts;

    Test.startTest();

    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeISP, true);

    Test.stopTest();
    System.assert(true);
  }
  /**
   * @description Queries assessment record for assertion
   * @author James Qian (Deloitte) | 07/15/2020
   * @param Id idAdmissionAssessment
   * @return UAC_admissionAssessment__c
   **/
  private
  static UAC_admissionAssessment__c getAdmissionAssessment(Id idAdmissionAssessment) {
    return [
      // clang-format off
      SELECT
        Id,
        UAC_caseManagerLookup__c,
        UAC_clinicianLookup__c,
        UAC_uac__c,
        UAC_submittedDate__c,
        UAC_height__c,
        UAC_weight__c,
        UAC_bMI__c,
        UAC_healthEvaluationIme__c
      FROM
        UAC_admissionAssessment__c
      WHERE
        Id = :idAdmissionAssessment
      // clang-format on
    ];
  }

  /**
   * @description Queries Task record for assertion
   * @author James Qian (Deloitte) | 07/15/2020
   * @param Id idWhat
   * @return Task
   **/
  private
  static Task getTask(Id idWhat) {
    return [
      // clang-format off
      SELECT
        Id,
        WhatId,
        Subject,
        OwnerId
      FROM
        Task
      WHERE
        WhatId = :idWhat
      // clang-format on
    ];
  }

  /**
   * @description Queries Admission Assessment snapshot record for assertion
   * @author James Qian (Deloitte) | 10/29/2020
   * @return Admission Assessment snapshot
   **/
  private
  static List<UAC_admissionAssessmentSnapshot__c> getAdmissionAssessmentSnapshot() {
    return [
      // clang-format off
      SELECT
        Id
      FROM
        UAC_admissionAssessmentSnapshot__c
      LIMIT
        100
      // clang-format on
    ];
  }
}