/**
 * @File Name         : UC_flowUpdtIniHealthAssessTest
 * @Description       : Test class for UC_flowUpdtIniHealthAssess class
 * @Author            : Piyush
 * @Last Modified On  : 03-36-2021
 **/
@isTest public without sharing class UC_flowUpdtInitHealthAssessTest {
    private static final String STR_A_NUM_UAC = '123456';
    private static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    private static final String STR_TEST_CLASS_NAME = UAC_flowUpdateAssessmentTest.class.getName();
    @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder().setANumber(STR_A_NUM_UAC).setEmail(STR_A_NUM_UAC + '@example.invalid')
                                                        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC).buildAndSave();
    }
    @isTest static void updateIniHealthAssessRec() {
        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
        Account objProgram = new UAC_testAccountBuilder().setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram).setType(STR_PROGRAM_TYPE).build();
        objProgram.UAC_withinORRNetwork__c = 'Yes';
        insert objProgram;
        UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 5, true);
        UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 5, true);
        Case objUACReferralCase = new UAC_testCaseBuilder().setStatus('Processed Pending').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
                                                           .setUAC(objUACContact.id).buildAndSave();
        objUACReferralCase.UAC_programFacility__c = objProgram.Id;
        test.startTest();
        objUACReferralCase.Status = 'New Pending';
        update objUACReferralCase;
        Test.stopTest();
        Id idAdmissionCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_referralRecordTypeName].Id;
        //UAC_referralRelatedRecord__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(idAdmissionCase, Label.UAC_assessmentRecordTypeAssessment, true);
        Id idIniAssRecType = Schema.SObjectType.UAC_referralRelatedRecord__c.getRecordTypeInfosByDeveloperName().get('UAC_initialHealthInformation').getRecordTypeId();
        UAC_referralRelatedRecord__c assessmentNew = new UAC_referralRelatedRecord__c(RecordTypeId = idIniAssRecType,UAC_referral__c = idAdmissionCase);
        insert assessmentNew;
        assessmentNew.UAC_medicationDetails__c = 'test1';
        assessmentNew.UAC_typeOfMedicalConcern__c = '[Injury;Pregnant]';
        UC_flowUpdtInitHealthAssess.Request objRequest = new UC_flowUpdtInitHealthAssess.Request();
        objRequest.objRecord = assessmentNew;
        UC_flowUpdtInitHealthAssess.Response objResponse = UC_flowUpdtInitHealthAssess.updateIniHealthAssessment(new List<UC_flowUpdtInitHealthAssess.Request>{objRequest})[0];
        System.assertEquals(null,objResponse.errorMessage,'Test method: updateIniHealthAssessRec() failed.');
      }    
}