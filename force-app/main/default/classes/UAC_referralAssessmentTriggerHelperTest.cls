/**
 * @File Name          : UAC_referralAssessmentTriggerHelperTest.cls
 * @Description        : Test class for UAC_referralAssessmentTriggerHelper,UAC_referralAssessmentTriggerHandler
 * @Author             : Rahul Roy (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Rahul Roy (Deloitte)
 * @Last Modified On   : 8/6/2020, 7:43:13 PM
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    08/06/2020   Rahul Roy (Deloitte)          Initial Version
 **/
@isTest(seeAllData = false) public class UAC_referralAssessmentTriggerHelperTest {

  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static final String strReferralAssessmentRecordTypeHSAssessment =
      Label.UAC_referralAssessmentRecordTypeHSAssessment;
    private static case objUACReleaseRequestCase;  
  /**
   * @description Sets up generic test data
   * @author Rahul Roy (Deloitte) | 8/6/2020
   * @return void
   **/
    /*
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
    System.debug('Queries after Inserting Account: ' + Limits.getQueries());
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 1, true);
    System.debug('Queries after Inserting Asset: ' + Limits.getQueries());
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('HS/PRS Referral Initiation')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
            .setUAC(objUACContact.id)
            .buildAndSave();
    System.debug('Queries after Inserting Case: ' + Limits.getQueries());
    objUACReferralCase.UAC_programFacility__c = objProgram.Id;
    update objUACReferralCase;
    System.debug('Queries after Updating Case: ' + Limits.getQueries());
    Id idHSPRSReferralCase = [SELECT Id FROM Case WHERE ParentId =:objUACReferralCase.Id].Id;
    Map<String, Id> mapCaseTeamRoles = UAC_TestUtility.getCaseTeamRoleMap();
    System.debug('Queries after Test Setup: ' + Limits.getQueries());
  }*/
    @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Contact objAdultContact1 =
    new UAC_testContactBuilder()
        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
        .setANumber('1234561')
        .setEmail('1234561' + '@example.invalid')
        .buildAndSave();                            
  	} 
   /*
    * @description Method to test date field population 
    * @author Rahul Roy (Deloitte) | 08/06/2020
    * @return void
    **/
    @isTest static void testPopulateDateFields() {
                        Contact objUACContact = UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
                        Contact objAdultContact1 = UAC_testContactBuilder.getContactByANumber('1234561', new Set<String>{'Id'});
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram; 
    
    // Insert primary sponsor relationship for Sponsor Application case creation
    UAC_adultContactRelationship__c objAdultContactRelationship =
    new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact1.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUACContact.id;
    insert objAdultContactRelationship;
    // Insert Sponsor Application Case
    Case objSponsorApplicationCase =
        new UAC_testCaseBuilder()
            .setSponsor(objAdultContact1.Id)
            .setUAC(objUACContact.Id)
            .setRelationshipToUAC(objAdultContactRelationship.Id)
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .buildAndSave();            
    objUACReleaseRequestCase = new UAC_testCaseBuilder()
    .setStatus('CM to Provide Further Information')
    .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeReleaseRequest)
    .setUAC(objUACContact.id)
    .buildAndSave();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    update objUACReleaseRequestCase;
    
    objUACReleaseRequestCase.Status = Label.UAC_caseStatusHSRequested;
    objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_conductHomeStudyTVPRA;
    objUACReleaseRequestCase.UAC_orrComment__c = 'Test9';
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

    UAC_referralAssessment__c objHSReferralAssessment = new UAC_referralAssessment__c();
    objHSReferralAssessment.recordtypeid = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
                              .get(strReferralAssessmentRecordTypeHSAssessment)
                              .getRecordTypeId();
    objHSReferralAssessment.UAC_techSponsorApplication__c =idhsRef;
    objHSReferralAssessment.UAC_entry__c = idhsRef;
    insert objHSReferralAssessment;
    
    system.debug('recordtypeid ' + objAdultContact1.id);
    UAC_associatedContact__c objAssociatedContact = new UAC_associatedContact__c();
    objAssociatedContact.UAC_contact__c = objAdultContact1.Id;
    objAssociatedContact.UAC_case__c = objSponsorApplicationCase.id;
    objAssociatedContact.UAC_householdMember__c = true;
    objAssociatedContact.UAC_alternateAdultCaregiver__c = true;
    objAssociatedContact.UAC_employed__c = 'Yes';
    objAssociatedContact.UAC_dependentOnSponsorIncome__c ='Yes';
    objAssociatedContact.UAC_relationshipToSponsor__c = 'Grandson';
    insert objAssociatedContact;
    
    objReferralAssessment.UAC_status__c = Label.UAC_referralAssessmentStatusDraft;
    objReferralAssessment.UAC_hsprsWorkerPrintedName__c = 'ABC';
    objReferralAssessment.UAC_hsprsSupervisorPrintedName__c = 'ABC';      
    objReferralAssessment.UAC_hsprsSupervisor__c = userinfo.getUserId();
	  update objReferralAssessment;  
    System.AssertNotEquals([Select UAC_hsprsWorkerCompletedDate__c from UAC_referralAssessment__c where Id =: objReferralAssessment.Id LIMIT 1], Null);
    //System.assertEquals('Test1',objReferralAssessment.UAC_sponsorsReasonsForWantingToSponsor__c);
    objReferralAssessment.UAC_status__c = Label.UAC_referralAssessmentStatusDraftApprovedBySupervisor;
    objReferralAssessment.UAC_hsprsSupervisorPrintedName__c = 'CBA';  
    objReferralAssessment.UAC_assignedProviderName__c = userinfo.getUserId();
    update objReferralAssessment;
    objReferralAssessment.UAC_status__c = Label.UAC_referralAssessmentStatusSubmitted;
    objReferralAssessment.UAC_verifyAndSubmit__c  =true;        
	update objReferralAssessment;          
    try{
    	delete objReferralAssessment;
    }
    catch(Exception ex){
       System.AssertNotEquals('',ex.getMessage());        
    }
    UAC_referralAssessment__c objReferralAssessment2 = new UAC_referralAssessment__c();
    objReferralAssessment2.UAC_entry__c = idhsRef;
    objReferralAssessment2.UAC_status__c = 'Draft';
    insert objReferralAssessment2;

    system.AssertNotEquals([select id  from  UAC_agenciesContacted__c where UAC_entryID__c = :idhsRef],null);
    delete objReferralAssessment2;        
    Test.stopTest();
  }
  @isTest static void testPRStests() {
    String strReferralAssessmentRecordTypePRSEvent =
      Label.UAC_prsEventRecordType;
    Id idPRSEventRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
  .get(strReferralAssessmentRecordTypePRSEvent)
  .getRecordTypeId();
    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
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
    .buildAndSave();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c  = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    update objUACReleaseRequestCase;
    
    objUACReleaseRequestCase.Status = Label.UAC_caseStatusHSRequested;
    objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_conductHomeStudyTVPRA;
    objUACReleaseRequestCase.UAC_orrComment__c = 'Test6';
    update objUACReleaseRequestCase; 
    
    Id idhsRef = [SELECT Id FROM Case WHERE parentID =: objUACReleaseRequestCase.Id].Id;
      
    System.debug('hs ref id is ' +idhsRef);
    Case  hsRef = [SELECT Id,Status,Type,UAC_hsPrsQueue__c FROM Case WHERE parentID =: objUACReleaseRequestCase.Id limit 1];
    System.debug('hs ref case type is ' +hsRef.Type);
    System.debug('hs ref case status is ' +hsRef.Status);
    hsRef.Status = 'Active';
    hsRef.Type = 'PRS-TVPRA';
    update hsRef;
        
    Test.startTest();
    UAC_referralAssessment__c objReferralAssessment = new UAC_referralAssessment__c();
    objReferralAssessment.recordtypeid = idPRSEventRecType;  
    objReferralAssessment.UAC_entry__c = idhsRef;
    insert objReferralAssessment;
    objReferralAssessment.UAC_status__c = Label.UAC_referralAssessmentStatusDraft;
    objReferralAssessment.UAC_hsprsWorkerPrintedName__c = 'ABC';
    objReferralAssessment.UAC_hsprsSupervisorPrintedName__c = 'ABC';      
    objReferralAssessment.UAC_hsprsSupervisor__c = userinfo.getUserId();
	update objReferralAssessment;  
    System.AssertNotEquals([Select UAC_hsprsWorkerCompletedDate__c from UAC_referralAssessment__c where Id =: objReferralAssessment.Id LIMIT 1], Null);
    //System.assertEquals('Test1',objReferralAssessment.UAC_sponsorsReasonsForWantingToSponsor__c);
    objReferralAssessment.UAC_status__c = Label.UAC_referralAssessmentStatusDraftApprovedBySupervisor;
    objReferralAssessment.UAC_hsprsSupervisorPrintedName__c = 'CBA';  
    objReferralAssessment.UAC_assignedProviderName__c = userinfo.getUserId();
    update objReferralAssessment;         
    try{
    	delete objReferralAssessment;
    }
    catch(Exception ex){
       System.AssertNotEquals('',ex.getMessage());        
    }
    UAC_referralAssessment__c objReferralAssessment2 = new UAC_referralAssessment__c();
    objReferralAssessment2.recordtypeid = idPRSEventRecType;
    objReferralAssessment2.UAC_entry__c = idhsRef;
    objReferralAssessment2.UAC_status__c = 'Draft';
    insert objReferralAssessment2;
    delete objReferralAssessment2;        
    Test.stopTest();
  }    
}