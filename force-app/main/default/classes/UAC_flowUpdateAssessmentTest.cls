/**
 * @File Name         : UAC_flowUpdateAssessmentTest
 * @Description       : Test class for UAC_flowUpdateAssessment class
 * @Group             : UAC_flowUpdateAssessment
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  : Abhisek Pati (Deloitte)
 * @Last Modified On  : 07-17-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-17-2020   Abhisek Pati (Deloitte)   Initial Version
 **/
@isTest public without sharing class UAC_flowUpdateAssessmentTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static final String STR_TEST_CLASS_NAME = UAC_flowUpdateAssessmentTest.class.getName();

  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
  }

  @isTest static void updateAssessmentShouldUpdateAssessmentRecord() {

    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 5, true);
    UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 5, true);
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(objUACContact.id)
            .buildAndSave();
    objUACReferralCase.UAC_programFacility__c = objProgram.Id;
    test.startTest();
    objUACReferralCase.Status = 'Placement Designated';
    update objUACReferralCase;
    Test.stopTest();
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        idAdmissionCase, Label.UAC_assessmentRecordTypeAssessment, true);
    assessmentNew.UAC_whatDoesTheWordDisciplineMeanto__c = STR_TEST_CLASS_NAME;
    assessmentNew.UAC_doYouIdentifyAs__c = '[Lesbian;Gay]';
    assessmentNew.UAC_sexualActivityType__c = '[Oral;Vaginal]';
    UAC_flowUpdateAssessment.Request objRequest = new UAC_flowUpdateAssessment.Request();
    objRequest.objRecord = assessmentNew;
    UAC_flowUpdateAssessment.Response objResponse = UAC_flowUpdateAssessment.updateAssessment(
        new List<UAC_flowUpdateAssessment.Request>{objRequest})[0];
    System.assertEquals(null,
        objResponse.errorMessage,
        'Test method: updateAssessmentShouldUpdateAssessmentRecord() failed.');
  }
}