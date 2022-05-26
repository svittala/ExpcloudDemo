// clang-format off
/**
 * @File Name          : UAC_preScreenCheckControllerTest.cls
 * @Description        : Test class for UAC_preScreenCheckController
 * @Author             : Issam Awwad (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    8/28/2020   Issam Awwad (Deloitte)     Initial Version
 **/
// clang-format on
@isTest(seeAllData = false) public without sharing class UAC_preScreenCheckControllerTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static Contact objUACContact;
  private
  static final String UAC_RELATIONSHIP_RECORD_TYPE = 'UAC_apprehendedUAC';
  private
  static Account objProgram;
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  public
  static final String strAdmissionCaseRecordType = Label.UAC_caseRecordTypeAdmission;
  private
  static final String STRING_A_NUMBER_SECONDARY = '2222222222';
  private
  static final String STRING_A_NUMBER_THIRD = '3332222222';
  private
  static final String RELATIONSHIP_BROTHER = 'Brother';
  private
  static final String UAC_RELATIONSHIP_API_NAME = 'UAC_apprehendedRelationship__c';
  /**
   * @description Method to setup data used in test instance.
   * @author Issam Awwad (Deloitte) | 8/28/2020
   * @return void
   **/
  @TestSetup static void setupData() {
    // Create an UAC contact
    objUACContact = new UAC_testContactBuilder()
                        .setANumber(STR_UAC_CONTACT_A_NUMBER)
                        .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                        .build();
    insert objUACContact;
    // Create a Program Account
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();

    List<Contact> listUAC = new List<Contact>();
    listUAC.add(new UAC_TestContactBuilder()
                    .setANumber(STRING_A_NUMBER_SECONDARY)
                    .setGender('Male')
                    .build());
    listUAC.add(
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_THIRD).setGender('Male').build());
    insert listUAC;

    objProgram.UAC_bedCountAvailableMale__c = 5;
    objProgram.UAC_bedCountAvailableFemale__c = 6;
    objProgram.UAC_withinORRNetwork__c = 'Yes';

    insert objProgram;
  }

  /**
   * @description method to test prescreen json construct
   * @author Issam Awwad (Deloitte) | 8/28/2020
   * @return void
   **/
  @isTest static void testPrescreenJSON() {
    List<String> lstCaseIds = new List<String>();
    Set<String> setFieldsToQuery = new Set<String>{
        'Id', 'UAC_activeSponsorApplication__c', 'UAC_A__c', 'UAC_currentAge__c', 'Birthdate'};
    List<Contact> listContactsToUpdate = new List<Contact>();
    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUACContact.Birthdate = date.ValueOf('2000-09-21');
    objUACContact.UAC_pendingAdjustmentofLegalStatus__c = true;
    listContactsToUpdate.add(objUACContact);

    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, setFieldsToQuery);
    contactSecondary.Birthdate = date.ValueOf('2010-09-21');
    listContactsToUpdate.add(contactSecondary);
    Contact contactThird =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_THIRD, setFieldsToQuery);
    contactThird.Birthdate = date.ValueOf('2010-09-21');
    listContactsToUpdate.add(contactThird);
    update listContactsToUpdate;

    Id recordTypeId = UAC_TestUtility.getRecordTypeIdByDevName(
        UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    List<UAC_apprehendedRelationship__c> listApprehended =
        new List<UAC_apprehendedRelationship__c>();
    listApprehended.add(UAC_TestUtility.createApprehendedRelationshipRecord(
        objUACContact.Id, contactSecondary.Id, recordTypeId, 'Son', false));
    listApprehended.add(UAC_TestUtility.createApprehendedRelationshipRecord(
        objUACContact.Id, contactThird.Id, recordTypeId, 'Brother', false));
    insert listApprehended;
    UAC_apprehendedRelationship__c newRelationship =
        [select id, UAC_age__c from UAC_apprehendedRelationship__c LIMIT 1];

    Case objReleaseRequestCase = new UAC_testCaseBuilder()
                                     .setUAC(objUACContact.Id)
                                     .setRecordTypeDeveloperName(strAdmissionCaseRecordType)
                                     .build();
    insert objReleaseRequestCase;
    Test.startTest();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        objReleaseRequestCase.Id, 'UAC_initialIntakesAssessment', false);
    UAC_admissionAssessment__c assessmentNewSecond = UAC_TestUtility.createAdmissionAssessment(
        objReleaseRequestCase.Id, 'UAC_caseReview', false);
    UAC_admissionAssessment__c assessmentNewThird = UAC_TestUtility.createAdmissionAssessment(
        objReleaseRequestCase.Id, 'UAC_initialIntakesAssessment', false);
    UAC_admissionAssessment__c assessmentNewFourth = UAC_TestUtility.createAdmissionAssessment(
        objReleaseRequestCase.Id, 'UAC_initialIntakesAssessment', false);
    List<UAC_admissionAssessment__c> listAssessmentsToInsert = new List<UAC_admissionAssessment__c>{
        assessmentNew, assessmentNewSecond, assessmentNewThird, assessmentNewFourth};
    insert listAssessmentsToInsert;
    assessmentNew = [
      select id,
      UAC_primaryLanguageSpoken__c,
      UAC_uac__c,
      recordType.DeveloperName from UAC_admissionAssessment__c limit 1
    ];
    assessmentNew.UAC_primaryLanguageSpoken__c = 'English';
    assessmentNew.UAC_uac__c = objUACContact.Id;
    assessmentNew.Id = listAssessmentsToInsert[0].Id;
    update assessmentNew;

    assessmentNewThird = [
      select id,
      UAC_primaryLanguageSpoken__c,
      UAC_uac__c,
      recordType.DeveloperName from UAC_admissionAssessment__c where recordType.DeveloperName =
          'UAC_initialIntakesAssessment' limit 1
    ];

    assessmentNewThird.UAC_primaryLanguageSpoken__c = 'English';
    assessmentNewThird.UAC_uac__c = objUACContact.Id;
    assessmentNewThird.Id = listAssessmentsToInsert[2].Id;
    update assessmentNewThird;

    assessmentNewFourth = [
      select id,
      UAC_primaryLanguageSpoken__c,
      UAC_uac__c,
      recordType.DeveloperName from UAC_admissionAssessment__c where recordType.DeveloperName =
          'UAC_initialIntakesAssessment' limit 1
    ];

    assessmentNewFourth.UAC_primaryLanguageSpoken__c = 'Spanish';
    assessmentNewFourth.UAC_uac__c = objUACContact.Id;
    assessmentNewFourth.Id = listAssessmentsToInsert[3].Id;
    update assessmentNewFourth;

    assessmentNewSecond = [
      select id,
      UAC_concernWithUACsAgeOrIdentity__c,
      UAC_uac__c,
      recordType.DeveloperName,
      RecordTypeId from UAC_admissionAssessment__c limit 1
    ];
    assessmentNewSecond.UAC_concernWithUACsAgeOrIdentity__c = 'Yes';
    assessmentNewSecond.UAC_uac__c = objUACContact.Id;
    assessmentNewSecond.UAC_akaName__c = 'test';
    assessmentNewSecond.UAC_akaDOBPerBirthCertificate__c = date.ValueOf('2010-09-21');
    assessmentNewSecond.UAC_akaA__c = 'test';
    assessmentNewSecond.RecordTypeId = Schema.getGlobalDescribe()
                                           .get('UAC_admissionAssessment__c')
                                           .getDescribe()
                                           .getRecordTypeInfosByDeveloperName()
                                           .get('UAC_caseReview')
                                           .getRecordTypeId();
    assessmentNew.Id = listAssessmentsToInsert[1].Id;
    update assessmentNewSecond;
    assessmentNewSecond = [
      select id,
      UAC_concernWithUACsAgeOrIdentity__c,
      UAC_uac__c,
      recordType.DeveloperName from UAC_admissionAssessment__c limit 1
    ];

    UAC_legal__c objLegal = new UAC_legal__c();
    objLegal.RecordTypeId = Schema.getGlobalDescribe()
                                .get('UAC_legal__c')
                                .getDescribe()
                                .getRecordTypeInfosByDeveloperName()
                                .get('UAC_legalMeetings')
                                .getRecordTypeId();
    objLegal.UAC_uacProfile__c = objUACContact.Id;
    insert objLegal;

    UAC_legal__c objLegalSecondCriteria = new UAC_legal__c();
    objLegalSecondCriteria.RecordTypeId = Schema.getGlobalDescribe()
                                              .get('UAC_legal__c')
                                              .getDescribe()
                                              .getRecordTypeInfosByDeveloperName()
                                              .get('UAC_immigrationHearings')
                                              .getRecordTypeId();
    objLegalSecondCriteria.UAC_uacProfile__c = objUACContact.Id;
    insert objLegalSecondCriteria;

    UAC_legal__c objLegalThirdCriteria = new UAC_legal__c();
    objLegalThirdCriteria.RecordTypeId = Schema.getGlobalDescribe()
                                             .get('UAC_legal__c')
                                             .getDescribe()
                                             .getRecordTypeInfosByDeveloperName()
                                             .get('UAC_attorneyOfRecord')
                                             .getRecordTypeId();
    objLegalThirdCriteria.UAC_uacProfile__c = objUACContact.Id;
    objLegalThirdCriteria.UAC_status__c = 'Current';
    insert objLegalThirdCriteria;

    UAC_legal__c objLegalCriteriaSeventh = new UAC_legal__c();
    objLegalCriteriaSeventh.RecordTypeId = Schema.getGlobalDescribe()
                                               .get('UAC_legal__c')
                                               .getDescribe()
                                               .getRecordTypeInfosByDeveloperName()
                                               .get('UAC_legalMeetings')
                                               .getRecordTypeId();
    objLegalCriteriaSeventh.UAC_uacProfile__c = objUACContact.Id;
    objLegalCriteriaSeventh.UAC_knowYourRights__c = true;
    insert objLegalCriteriaSeventh;
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(objUACContact.Id)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .buildAndSave();
    UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                     .setAssociatedUAC(objUACContact.Id)
                                     .setAssociatedHealthEval(objIME.Id)
                                     .build();
    diagnosis.UAC_status__c = 'Final/Confirmed';
    diagnosis.UAC_WDCategory__c = 'Genito-urinary/Reproductive';
    diagnosis.UAC_WDCondition__c = 'Pregnant';
    insert diagnosis;

    List<UAC_admissionAssessment__c> lstOFassessmentNew = [
      select id,
      UAC_primaryLanguageSpoken__c,
      UAC_uac__c,
      recordType.DeveloperName from UAC_admissionAssessment__c
    ];
    System.debug('lstOFassessmentNew: ' + lstOFassessmentNew);

    objReleaseRequestCase = [SELECT Id, CaseNumber, UAC_programFacility__c FROM Case LIMIT 1];
    lstCaseIds.add(objReleaseRequestCase.CaseNumber);
    UAC_preScreenCheckController.getManifestChildCases(
        lstCaseIds, objReleaseRequestCase.UAC_programFacility__c);
    objReleaseRequestCase =
        [SELECT id, UAC_influxScreeningJSON__c, CaseNumber FROM Case WHERE CaseNumber
          =:objReleaseRequestCase.CaseNumber LIMIT 1];
    UAC_preScreenCheckController.updateEntryInflux(
        objReleaseRequestCase.CaseNumber, objReleaseRequestCase.UAC_influxScreeningJSON__c);
    UAC_preScreenCheckController.updateManualCompletedDate(objReleaseRequestCase.CaseNumber);

    System.assert(objReleaseRequestCase.UAC_influxScreeningJSON__c != null);
    test.stopTest();
  }
}