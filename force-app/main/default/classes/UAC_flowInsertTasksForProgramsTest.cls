/**
 * @File Name          : UAC_flowInsertTasksForProgramsTest.cls
 * @Description        : Main test class for transfer program selection
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_case
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0     8/4/2020   James Qian (Deloitte)     Initial Implementation.
 **/
@isTest public without sharing class UAC_flowInsertTasksForProgramsTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';

  /**
   * @description Sets up generic test data
   * @author James Qian (Deloitte) | 08/04/2020
   * @return void
   **/
  @TestSetup static void setupTestData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    System.debug('Queries after Inserting Contact: ' + Limits.getQueries());
    Account objProgram1 = new UAC_testAccountBuilder()
                              .setName('Non Volag Program')
                              .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                              .setType(STR_PROGRAM_TYPE)
                              .setMaleBeds(10)
                              .build();
    objProgram1.UAC_volagGrantee__c = 'No';
    objProgram1.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram1;
    UAC_TestUtility.createAssets(objProgram1.Id, 'Male', 'Available', 10, true);

    Account objProgram2 = new UAC_testAccountBuilder()
                              .setName('Volag Program')
                              .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                              .setType(STR_PROGRAM_TYPE)
                              .setMaleBeds(10)
                              .build();
    objProgram2.UAC_volagGrantee__c = 'Yes';
    objProgram2.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram2;
    UAC_TestUtility.createAssets(objProgram2.Id, 'Male', 'Available', 10, true);
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(objUACContact.id)
            .buildAndSave();
    insert new AccountTeamMember(UserId = UserInfo.getUserId(),
        AccountId = objProgram1.Id,
        TeamMemberRole = Label.UAC_caseTeamRoleNameLCM);

    insert new AccountTeamMember(UserId = UserInfo.getUserId(),
        AccountId = objProgram2.Id,
        TeamMemberRole = Label.UAC_caseTeamRoleNameLCM);
  }

  /**
   * @description Tests positive cases of creating Tasks as CC
   * @author James Qian (Deloitte) | 08/04/2020
   * @return void
   **/
  @isTest static void providingInputShouldCreateTasks() {
    UAC_flowInsertTasksForPrograms.Request newRequest =
        new UAC_flowInsertTasksForPrograms.Request();
    List<Account> queriedAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:Label.UAC_accountRecordTypeAPINameProgram];
    Case queriedCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName
        =:Label.UAC_caseRecordTypeApiNameUACReferral];
    List<id> testAccId = new List<id>();
    for (Account acc : queriedAccount) {
      testAccId.add(acc.id);
    }
    newRequest.listAccountIds = testAccId;
    newRequest.idTransferRequest = queriedCase.Id;
    List<UAC_flowInsertTasksForPrograms.Response> listResponse =
        new List<UAC_flowInsertTasksForPrograms.Response>();
    Test.startTest();
    User u = createUser(Label.UAC_accountTeamRoleNameCC, Label.UAC_accountTeamRoleNameCC, null);
    System.runAs(u) {
      listResponse = UAC_flowInsertTasksForPrograms.insertTasksForPrograms(
          new List<UAC_flowInsertTasksForPrograms.Request>{newRequest});
    }
    Test.stopTest();
    List<Task> queriedTasks = [SELECT Id FROM Task WHERE WhatId =:queriedCase.Id];
    List<AccountTeamMember> queriedAccountTeamMembers =
        [SELECT Id FROM AccountTeamMember WHERE TeamMemberRole = 'Temporary'];
    System.assertEquals(null, listResponse[0].strErrorMessage);
    System.assertEquals(2, queriedTasks.size());
    System.assertEquals(1, queriedAccountTeamMembers.size());
  }
  /**
   * @description Tests positive cases of creating Tasks as Volag
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @return void
   **/
  @isTest static void providingInputShouldCreateTasksVolag() {
    UAC_flowInsertTasksForPrograms.Request newRequest =
        new UAC_flowInsertTasksForPrograms.Request();
    Account queriedAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:Label.UAC_accountRecordTypeAPINameProgram and Name = 'Volag Program'];
    Case queriedCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName
        =:Label.UAC_caseRecordTypeApiNameUACReferral];
    List<id> testAccId = new List<id>();
    testAccid.add(queriedAccount.id);
    newRequest.listAccountIds = testAccid;
    newRequest.idTransferRequest = queriedCase.Id;
    List<UAC_flowInsertTasksForPrograms.Response> listResponse =
        new List<UAC_flowInsertTasksForPrograms.Response>();
    Test.startTest();
    User u = createUser('Director', 'Program Leadership', 'UAC_volagUser');
    System.runAs(u) {
      listResponse = UAC_flowInsertTasksForPrograms.insertTasksForPrograms(
          new List<UAC_flowInsertTasksForPrograms.Request>{newRequest});
    }
    Test.stopTest();
    List<Task> queriedTasks = [SELECT Id FROM Task WHERE WhatId =:queriedCase.Id];
    System.assertEquals(null, listResponse[0].strErrorMessage);
    System.assertEquals(1, queriedTasks.size());
  }

  /**
   * @description Tests positive cases of querying Accounts
   * @author James Qian (Deloitte) | 08/04/2020
   * @return void
   **/
  @isTest static void queryingAccountsShouldReturnResult() {
    String searchKey = 'Volag';
    Test.startTest();
    List<Account> listAccounts = UAC_flowInsertTasksForPrograms.queryAccounts(searchKey);
    Test.stopTest();
    System.assertEquals(2, listAccounts.size());
  }
  /**
   * @description Utility Method to create User
   * @author Sarang Padhye (Deloitte) | 08/04/2020
   * @param String profileName
   * @param String userRole
   * @param String permSetName
   * @return User
   **/
  private
  static User createUser(String profileName, String userRole, String permSetName) {
    UserRole r = [select id, Name from UserRole where Name =:userRole];

    User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name =:profileName].Id,
        LastName = 'last',
        Email = 'puser000@amamama.com',
        Username = 'puser000@amamama.com' + System.currentTimeMillis(),
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        UserRoleId = r.Id);

    insert u;

    if (permSetName != null) {
      PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:permSetName];
      insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
    }
    return u;
  }
}