/**
 * @File Name          : UAC_taskTriggerHelperTest.cls
 * @Description        : Test class for UAC_taskTriggerHelper
 * @Author             : Rahul Roy (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Rahul Roy (Deloitte)
 * @Last Modified On   : 8/6/2020, 7:43:13 PM
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    08/06/2020   Rahul Roy (Deloitte)          Initial Version
 **/
@isTest(seeAllData = false) public without sharing class UAC_taskTriggerHelperTest {

  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static final String strReferralAssessmentRecordTypeHSAssessment =
      Label.UAC_referralAssessmentRecordTypeHSAssessment;
  private
  static case objUACReleaseRequestCase;

  private
  static case objTransferCase;

  public
  static final string strVolagQueueName = Label.UAC_volagQueueName;
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    UAC_healthEvaluation__c objIME =
        new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    UAC_Diagnosis__c Diagnosis = new UAC_testDiagnosisBuilder().buildAndSave(objUACContact);

    Account objProgram = new UAC_testAccountBuilder()
                             .setName('Program')
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType('Secure')
                             .setMaleBeds(10)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 10, true);

    Account objSendingProgram =
        new UAC_testAccountBuilder()
            .setName('Volag Program')
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType('Secure')
            .setMaleBeds(10)
            .build();
    objSendingProgram.UAC_withinORRNetwork__c = 'Yes';
    objSendingProgram.UAC_volagGrantee__c = 'Yes';
    insert objSendingProgram;
    UAC_TestUtility.createAssets(objSendingProgram.Id, 'Male', 'Available', 10, true);

    AccountTeamMember objATM = new AccountTeamMember();
    objATM.AccountId = objProgram.Id;
    objATM.TeamMemberRole = 'Lead Case Manager';
    objATM.UserId = UserInfo.getUserId();
    insert objATM;

    AccountTeamMember objATMSending = new AccountTeamMember();
    objATMSending.AccountId = objSendingProgram.Id;
    objATMSending.TeamMemberRole = 'Lead Case Manager';
    objATMSending.UserId = UserInfo.getUserId();
    insert objATMSending;
  }
  /*
   * @description Method to test task creation on HS Addendum
   * @author Rahul Roy (Deloitte) | 08/06/2020
   * @return void
   **/
  @isTest static void testProcessHSAddendumTask() {

    User HSPRSProviderUser = UAC_TestUtility.CreateUser('HS/PRS Provider');
    Id idTaskHSAddendumRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                     .get(Label.UAC_taskRecordTypeHSAddendum)
                                     .getRecordTypeId();
    Id idHSAssessmentRecType =
        Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
            .get(strReferralAssessmentRecordTypeHSAssessment)
            .getRecordTypeId();
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    objUACContact.ownerId = HSPRSProviderUser.id;
    update objUACContact;
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .setMaleBeds(10)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.ownerId = HSPRSProviderUser.id;
    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 10, true);

    objUACReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('CM to Provide Further Information')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeReleaseRequest)
            .setUAC(objUACContact.id)
            .build();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objUACReleaseRequestCase.ownerId = HSPRSProviderUser.id;
    insert objUACReleaseRequestCase;
    Test.startTest();
    objUACReleaseRequestCase.Status = Label.UAC_caseStatusHSRequested;
    objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_conductHomeStudyTVPRA;
    objUACReleaseRequestCase.UAC_orrComment__c = 'Test8';
    update objUACReleaseRequestCase;

    Id idhsRef = [SELECT Id FROM Case WHERE parentID =:objUACReleaseRequestCase.Id].Id;
    System.debug('hs ref id is ' + idhsRef);
    Case hsRef = [SELECT Id, Status, Type, UAC_hsPrsQueue__c FROM Case WHERE parentID
      =:objUACReleaseRequestCase.Id limit 1];
    System.debug('hs ref case type is ' + hsRef.Type);
    System.debug('hs ref case status is ' + hsRef.Status);
    hsRef.Status = 'Active';
    hsRef.Type = 'Home Study - Discretionary';
    update hsRef;

    UAC_referralAssessment__c objReferralAssessment = new UAC_referralAssessment__c();
    objReferralAssessment.UAC_entry__c = idhsRef;
    objReferralAssessment.RecordTypeId = idHSAssessmentRecType;
    objReferralAssessment.UAC_hsprsSupervisor__c = HSPRSProviderUser.id;
    objReferralAssessment.UAC_status__c = 'Draft';
    insert objReferralAssessment;
    objReferralAssessment.UAC_hsprsWorkerPrintedName__c = 'ABC';
    update objReferralAssessment;
    Task createdTask =
        [SELECT Id, Status, whatid, OwnerId, UAC_verifyAndSubmit__c FROM Task WHERE whatid
          =:objReferralAssessment.Id limit 1];
    System.debug('@@RR createdTask ' + createdTask);
    System.AssertNotEquals(createdTask, Null);
    createdTask.RecordTypeId = idTaskHSAddendumRecType;
    createdTask.UAC_verifyAndSubmit__c = true;
    System.runAs(HSPRSProviderUser) {
      update createdTask;
    }
    createdTask = [SELECT Id,
      Status,
      whatid,
      OwnerId,
      UAC_dateAddendumCompleted__c,
      UAC_verifyAndSubmit__c FROM Task WHERE whatid =:objReferralAssessment.Id limit 1];
    System.debug('@@RR createdTask.UAC_verifyAndSubmit__c ' + createdTask.UAC_verifyAndSubmit__c);
    System.AssertNotEquals(Null, createdTask.UAC_dateAddendumCompleted__c);

    Test.stopTest();
  }

  /*
   * @description Method to test transfer task creation
   * @author Issam Awwad (Deloitte) | 08/07/2020
   * @return void
   **/
  @isTest static void testProcessTransferTask() {

    Id idTaskTransferRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                   .get('UAC_transferReferral')
                                   .getRecordTypeId();
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    UAC_healthEvaluation__c healthEvaluation = new UAC_healthEvaluation__c();
    healthEvaluation.UAC_associatedUAC__c = objUACContact.id;
    insert healthEvaluation;
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType('Secure')
                             .setMaleBeds(10)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 10, true);
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 10, true);

    Account objProgram1 = new UAC_testAccountBuilder()
                              .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                              .setType('Secure')
                              .setMaleBeds(10)
                              .build();
    objProgram1.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram1;
    UAC_TestUtility.createAssets(objProgram1.Id, 'Male', 'Available', 10, true);
    UAC_TestUtility.createAssets(objProgram1.Id, 'Female', 'Available', 10, true);

    Account objSendingProgram =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType('Secure')
            .setMaleBeds(10)
            .build();
    objSendingProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objSendingProgram;
    UAC_TestUtility.createAssets(objSendingProgram.Id, 'Male', 'Available', 10, true);
    UAC_TestUtility.createAssets(objSendingProgram.Id, 'Female', 'Available', 10, true);

    Case objCase2 = new UAC_testCaseBuilder()
                        .setStatus('Pending Admission')
                        .setUAC(objUACContact.Id)
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
                        .build();
    objCase2.UAC_programFacility__c = objProgram1.Id;
    insert objCase2;

    objUACReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('CM to Provide Further Information')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeTransferRequest)
            .setUAC(objUACContact.id)
            .build();
    objUACReleaseRequestCase.UAC_currentProgram__c = objProgram.Id;
    objUACReleaseRequestCase.UAC_programTypeRequested__c = 'Secure';
    objUACReleaseRequestCase.UAC_secure__c = 'Charged with a crime';
    objUACReleaseRequestCase.ParentId = objCase2.id;
    objUACReleaseRequestCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    objUACReleaseRequestCase.UAC_standardProgramType__c = 'Flight Risk';
    insert objUACReleaseRequestCase;

    objUACReleaseRequestCase.UAC_caseCoordinatorRecommendation__c = 'Transfer Concurred';
    objUACReleaseRequestCase.UAC_caseManagerRecommendation__c = 'Transfer Recommended';
    objUACReleaseRequestCase.UAC_orrDecision__c = 'Transfer Approved';
    update objUACReleaseRequestCase;

    AccountTeamMember objATM = new AccountTeamMember();
    objATM.AccountId = objProgram.Id;
    objATM.TeamMemberRole = 'Lead Case Manager';
    objATM.UserId = UserInfo.getUserId();
    insert objATM;

    AccountTeamMember objATMSending = new AccountTeamMember();
    objATMSending.AccountId = objSendingProgram.Id;
    objATMSending.TeamMemberRole = 'Lead Case Manager';
    objATMSending.UserId = UserInfo.getUserId();
    insert objATMSending;

    Task objTask = new Task();
    objTask.UAC_program__c = objSendingProgram.id;
    objTask.Priority = 'Normal';
    objTask.Status = 'Transfer Review Pending';
    objTask.OwnerId = userinfo.getuserid();
    objTask.WhatId = objUACReleaseRequestCase.id;
    objTask.recordTypeId = idTaskTransferRecType;
    objTask.UAC_notAcceptedReason__c = 'Capacity';
    insert objTask;
    Test.startTest();
    objTask.Status = 'Transfer Designated';
    update objTask;
    objUACReleaseRequestCase = [select id, status from case where status = 'FFS Review' limit 1];
    System.AssertEquals('FFS Review', objUACReleaseRequestCase.status);
    Test.stopTest();
  }

  /*
   * @description Method to test transfer task creation
   * @author James Qian (Deloitte) | 03/23/2021
   * @return void
   **/
  @isTest static void testTransferReferralAccepted() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType('Secure')
                             .setMaleBeds(10)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;
    List<Asset> listAssets =
        UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 10, false);
    listAssets.addAll(
        UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 10, false));

    Account objSendingProgram =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType('Secure')
            .setMaleBeds(10)
            .build();
    objSendingProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objSendingProgram;
    listAssets.addAll(
        UAC_TestUtility.createAssets(objSendingProgram.Id, 'Male', 'Available', 10, false));
    listAssets.addAll(
        UAC_TestUtility.createAssets(objSendingProgram.Id, 'Female', 'Available', 10, false));
    insert listAssets;
    Case objCase = new UAC_testCaseBuilder()
                       .setStatus('Pending Admission')
                       .setUAC(objUACContact.Id)
                       .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
                       .build();
    objCase.UAC_programFacility__c = objSendingProgram.Id;
    insert objCase;
    Case caseTransfer = new UAC_testCaseBuilder()
                            .setStatus('CM to Provide Further Information')
                            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeTransferRequest)
                            .setUAC(objUACContact.id)
                            .build();
    caseTransfer.UAC_currentProgram__c = objProgram.Id;
    caseTransfer.UAC_programTypeRequested__c = 'Secure';
    caseTransfer.UAC_secure__c = 'Charged with a crime';
    caseTransfer.ParentId = objCase.id;
    caseTransfer.UAC_leadCaseManager__c = UserInfo.getUserId();
    caseTransfer.UAC_caseCoordinator__c = UserInfo.getUserId();
    caseTransfer.UAC_standardProgramType__c = 'Flight Risk';
    insert caseTransfer;

    caseTransfer.UAC_caseCoordinatorRecommendation__c = 'Transfer Concurred';
    caseTransfer.UAC_caseManagerRecommendation__c = 'Transfer Recommended';
    caseTransfer.UAC_orrDecision__c = 'Transfer Approved';
    update caseTransfer;
    AccountTeamMember objATM = new AccountTeamMember();
    objATM.AccountId = objProgram.Id;
    objATM.TeamMemberRole = 'Lead Case Manager';
    objATM.UserId = UserInfo.getUserId();
    insert objATM;

    AccountTeamMember objATMSending = new AccountTeamMember();
    objATMSending.AccountId = objSendingProgram.Id;
    objATMSending.TeamMemberRole = 'Lead Case Manager';
    objATMSending.UserId = UserInfo.getUserId();
    insert objATMSending;

    Task objTask = new Task();
    objTask.UAC_program__c = objSendingProgram.id;
    objTask.Priority = 'Normal';
    objTask.Status = 'Transfer Review Pending';
    objTask.OwnerId = UserInfo.getuserid();
    objTask.WhatId = caseTransfer.id;
    objTask.recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                               .get('UAC_transferReferral')
                               .getRecordTypeId();
    objTask.UAC_notAcceptedReason__c = 'Capacity';
    insert objTask;
    Test.startTest();
    objTask.Status = 'Transfer Accepted';
    update objTask;
    Account queriedAccount =
        [SELECT Id, UC_teenMaleBeds__c, UC_teenFemaleBeds__c FROM Account WHERE Id
          =:objSendingProgram.id];
    Test.stopTest();
    System.AssertEquals(9, queriedAccount.UC_teenFemaleBeds__c);
  }

  /*
   * @description Method to test update Task Owner when the substatus changes
   * @author Sarang Padhye (Deloitte) | 08/07/2020
   * @return void
   **/
  @isTest static void changeInSubstatusShouldChangeTaskOwner() {

    Id idTaskTransferRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                   .get('UAC_transferReferral')
                                   .getRecordTypeId();
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    UAC_healthEvaluation__c healthEvaluation = new UAC_healthEvaluation__c();
    healthEvaluation.UAC_associatedUAC__c = objUACContact.id;
    Account objSendingProgram = [select id from account where name = 'Volag Program' limit 1];
    Account objProgram = [select id from account where name = 'Program' limit 1];
    Account objProgram1 = new UAC_testAccountBuilder()
                              .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                              .setType('Secure')
                              .setMaleBeds(10)
                              .build();
    objProgram1.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram1;
    UAC_TestUtility.createAssets(objProgram1.Id, 'Male', 'Available', 10, true);
    UAC_TestUtility.createAssets(objProgram1.Id, 'Female', 'Available', 10, true);
    Case objCase2 = new UAC_testCaseBuilder()
                        .setStatus('Pending Admission')
                        .setUAC(objUACContact.Id)
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
                        .build();
    objCase2.UAC_programFacility__c = objProgram1.Id;
    insert objCase2;
    objTransferCase = new UAC_testCaseBuilder()
                          .setStatus('CM to Provide Further Information')
                          .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeTransferRequest)
                          .setUAC(objUACContact.id)
                          .build();
    objTransferCase.UAC_currentProgram__c = objProgram.Id;
    objTransferCase.UAC_programTypeRequested__c = 'Secure';
    objTransferCase.UAC_secure__c = 'Charged with a crime';
    objTransferCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    objTransferCase.ParentId = objCase2.id;
    objTransferCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    objTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    insert objTransferCase;

    Task objTask = new Task();
    objTask.UAC_program__c = objSendingProgram.id;
    objTask.Priority = 'Normal';
    objTask.Status = 'Transfer Review Pending';
    objTask.UAC_subStatus__c = null;
    objTask.OwnerId = userinfo.getuserid();
    objTask.WhatId = objTransferCase.id;
    objTask.recordTypeId = idTaskTransferRecType;
    objTask.UAC_notAcceptedReason__c = 'Capacity';
    insert objTask;
    Test.startTest();
    objTask.UAC_subStatus__c = 'Transfer Accepted';
    update objTask;
    Task testTask = [select id, ownerid from Task where id =:objTask.id];
    System.AssertEquals(getVolagQueueId(), testTask.ownerid);
    Test.stopTest();
  }
  /*
   * @description Method to test update Task Owner when the status changes
   * @author Sarang Padhye (Deloitte) | 08/07/2020
   * @return void
   **/
  @isTest static void changeInStatusShouldChangeTaskOwner() {

    Id idTaskTransferRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                   .get('UAC_transferReferral')
                                   .getRecordTypeId();
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    UAC_healthEvaluation__c healthEvaluation = new UAC_healthEvaluation__c();
    healthEvaluation.UAC_associatedUAC__c = objUACContact.id;
    Account objSendingProgram = [select id from account where name = 'Volag Program' limit 1];
    Account objProgram = [select id from account where name = 'Program' limit 1];
    Account objProgram1 = new UAC_testAccountBuilder()
                              .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                              .setType('Secure')
                              .setMaleBeds(10)
                              .build();
    objProgram1.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram1;
    Case objCase2 = new UAC_testCaseBuilder()
                        .setStatus('Pending Admission')
                        .setUAC(objUACContact.Id)
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
                        .build();
    objCase2.UAC_programFacility__c = objProgram1.Id;
    insert objCase2;
    objTransferCase = new UAC_testCaseBuilder()
                          .setStatus('CM to Provide Further Information')
                          .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeTransferRequest)
                          .setUAC(objUACContact.id)
                          .build();
    objTransferCase.UAC_currentProgram__c = objProgram.Id;
    objTransferCase.UAC_programTypeRequested__c = 'Secure';
    objTransferCase.UAC_secure__c = 'Charged with a crime';
    objTransferCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    objTransferCase.ParentId = objCase2.id;
    objTransferCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    objTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    insert objTransferCase;
    Task objTask = new Task();
    objTask.UAC_program__c = objSendingProgram.id;
    objTask.Priority = 'Normal';
    objTask.Status = 'Transfer Review Pending';
    objTask.UAC_subStatus__c = null;
    objTask.OwnerId = userinfo.getuserid();
    objTask.WhatId = objTransferCase.id;
    objTask.recordTypeId = idTaskTransferRecType;
    objTask.UAC_notAcceptedReason__c = 'Capacity';
    insert objTask;
    Test.startTest();
    objTask.Status = 'Transfer Accepted';
    update objTask;
    Task testTask = [select id, ownerid from Task where id =:objTask.id];
    System.AssertEquals(userinfo.getuserid(), testTask.ownerid);
    Test.stopTest();
  }

  /**
   * @description Method to get QueueId
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @return String
   **/
  private
  static String getVolagQueueId() {
    return
        [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:strVolagQueueName limit 1].id;
  }
}