/**
 * @File Name         : UAC_flowUpdateReferralAssessmentTest
 * @Description       : Test class for UAC_flowUpdateReferralAssessmentTest class
 * @Group             : UAC_flowUpdateReferralAssessmentTest
 * @Author            : Ankur Aggarwal (Deloitte)
 * @Last Modified By  : Ankur Aggarwal (Deloitte)
 * @Last Modified On  : 08-05-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-05-2020   Ankur Aggarwal (Deloitte)   Initial Version
 * 1.1   08-06-2020   Piyush                    Added coverage for HS Assessment
 * 1.2   02-22-2020   Abhisek Pati (Deloitte)   Added code coverage.
 **/
@isTest public class UAC_flowUpdateReferralAssessmentTest {
  private static final String STR_A_NUM_UAC = '123456';
  private static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private static case objUACReleaseRequestCase;  


  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
  }
    
  @isTest static void updateHSAssessment() {
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram; 
    
    objUACReleaseRequestCase = new UAC_testCaseBuilder()
    .setStatus('CM to Provide Further Information')
    .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeReleaseRequest)
    .setUAC(objUACContact.id)
    .build();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReleaseRequestCase;
    
    objUACReleaseRequestCase.Status = Label.UAC_caseStatusHSRequested;
    objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_conductHomeStudyTVPRA;
    objUACReleaseRequestCase.UAC_orrComment__c = 'Test5';
    update objUACReleaseRequestCase; 
    
    Id idhsRef = [SELECT Id FROM Case WHERE parentID =: objUACReleaseRequestCase.Id].Id;
    System.debug('hs ref id is ' +idhsRef);
    Case  hsRef = [SELECT Id,Status,Type,UAC_hsPrsQueue__c FROM Case WHERE parentID =: objUACReleaseRequestCase.Id limit 1];
    System.debug('hs ref case type is ' +hsRef.Type);
    System.debug('hs ref case status is ' +hsRef.Status);
    hsRef.Status = 'Active';
    hsRef.Type = 'Home Study - Discretionary';
    update hsRef;

    Test.startTest();
    UAC_referralAssessment__c objReferralAssessment = new UAC_referralAssessment__c();
    objReferralAssessment.UAC_entry__c = idhsRef;
    insert objReferralAssessment;
    objReferralAssessment.UAC_sponsorsReasonsForWantingToSponsor__c = 'Test1';
    objReferralAssessment.UAC_describeTheSponsorsRelationship__c = 'Test2';
    objReferralAssessment.UAC_doesTheSponsorHaveAFamilySupport__c = 'Test3';
    objReferralAssessment.UAC_wasSponsorAwareOrInvolvedInUACsPlan__c = 'Test4';
    objReferralAssessment.UAC_wasSponsorAwareOfUACsApprehension__c = 'Test5';
    objReferralAssessment.UAC_describeAnyPreviousUACSponsorships__c = 'Test6';
    objReferralAssessment.UAC_outsideSpace__c = 'Patio;Porch';
    UAC_flowUpdateReferralAssessment.Request objRequest = new UAC_flowUpdateReferralAssessment.Request();
    objRequest.objRecord = objReferralAssessment;    
    UAC_flowUpdateReferralAssessment.Response objResponse =
    UAC_flowUpdateReferralAssessment.updateReferralAssessment(new List<UAC_flowUpdateReferralAssessment.Request>{objRequest})[0];
    System.assertEquals('Test1',objReferralAssessment.UAC_sponsorsReasonsForWantingToSponsor__c);
    test.stopTest();
  }
       
}