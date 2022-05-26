/**
 * @File Name          : UAC_accountTeamMemberTriggerTest.cls
 * @Description        : Provides test class coverage for accountTeamMember Trigger
 * @Author             : Chaitanya Nandamuri (Deloitte)
 * @Group              :
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/9/2020   Chaitanya Nandamuri (Deloitte)     Initial Implementation.
 **/
@isTest public with sharing class UAC_accountTeamMemberTriggerTest {

  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STRING_PROGRAM_RECORD_NAME = 'UAC_program';
  private
  static final String STRING_FamilyGroup_RECORD_NAME = 'UAC_familyGroup';
  Private static final String STRING_LCM_TeamRole = 'Lead Case Manager';
  Private static final String STRING_CM_TeamRole = 'Case Manager';
  private
  static final String STRING_FIELD_TYPE = 'Long Term Foster Care';
  private
  static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;

  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();

    User userLCM = new user();
    userLCM = UAC_TestUtility.createUser(STRING_LCM_TeamRole);
    Account Org = new UAC_testAccountBuilder()
                      .setRecordTypeDeveloperName(Label.UAC_organizationRecordTypeDevName)
                      .setType(STRING_FIELD_TYPE)
                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                      .build();
    Org.UAC_organizationContact1__c = UserInfo.getUserId();
    insert Org;
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .build();
    programToInsert.UAC_programStatus__c = 'Draft';
    programToInsert.parentId = Org.id;
    insert programToInsert;
          
    AccountTeamMember ProgramATM = new AccountTeamMember(TeamMemberRole = STRING_LCM_TeamRole,
        AccountId = programToInsert.Id,
        UserId = userLCM.Id,
        AccountAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit');
    insert ProgramATM;
    AccountShare objAccountShare = new AccountShare();
    objAccountShare.AccountAccessLevel = 'Edit';
    objAccountShare.CaseAccessLevel = 'Edit';
    objAccountShare.ContactAccessLevel = 'Edit';
    objAccountShare.OpportunityAccessLevel = 'None';
    objAccountShare.RowCause = 'Manual';
    objAccountShare.userorgroupid = userLCM.Id;
    objAccountShare.AccountId = Org.id;
    insert objAccountShare;
  }

  @isTest static void replicateAccountTeamOnFamilyGroup() {
    // List<String> LstTeamRoles = new List<String>{'Lead Case Manager','Lead Clinician', };
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .buildAndSave();

    Account FamilyGroupToInsert = new UAC_testAccountBuilder()
                                      .setRecordTypeDeveloperName(STRING_FamilyGroup_RECORD_NAME)
                                      .setType(STRING_FIELD_TYPE)
                                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                      .build();
    FamilyGroupToInsert.UAC_familyName__c = 'TestFamilyG';
    test.starttest();
    insert FamilyGroupToInsert;

    contact UAC = [select id from contact];
    Uac.accountId = FamilyGroupToInsert.id;
    Uac.UAC_program__c = programToInsert.id;
    update UAC;

    AccountTeamMember ProgramATM = new AccountTeamMember(TeamMemberRole = STRING_LCM_TeamRole,
        AccountId = programToInsert.Id,
        UserId = userInfo.getUserId(),
        AccountAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit');
    insert ProgramATM;
    Test.stopTest();
    List<AccountTeamMember> lstFGATM =
        [select id from AccountTeamMember where accountId =:FamilyGroupToInsert.Id];
    system.assertequals(1, lstFGATM.size());
  }
  /**
   * @description Method to test setting LTFC permission set on new account team members
   * @author James Qian (Deloitte) | 9/21/2020
   **/
  @isTest static void accountTeamMemberPermissionSet() {
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .buildAndSave();
    User userLCM = new user();
    userLCM = UAC_TestUtility.createUser(STRING_LCM_TeamRole);
    Test.startTest();
    AccountTeamMember ProgramATM = new AccountTeamMember(TeamMemberRole = STRING_LCM_TeamRole,
        AccountId = programToInsert.Id,
        UserId = userLCM.Id,
        AccountAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit');
    insert ProgramATM;
    Test.stopTest();
    List<PermissionSetAssignment> listPermissionSet =
        [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =:userLCM.Id AND PermissionSet.Name
                                                                 =:Label.UAC_permissionSetNameLTFC];
    System.AssertEquals(1, listPermissionSet.size());
  }
  /**
   * @description Method to test Account Share Creation
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @return void
   **/
  @isTest static void creatingAtmShouldShareOrgRecords() {
    User userLCM = new user();
    userLCM = UAC_TestUtility.createUser(STRING_LCM_TeamRole);
    Account Org = new UAC_testAccountBuilder()
                      .setRecordTypeDeveloperName(Label.UAC_organizationRecordTypeDevName)
                      .setType(STRING_FIELD_TYPE)
                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                      .build();
    Org.UAC_organizationContact1__c = UserInfo.getUserId();
    insert Org;

    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .build();
    programToInsert.UAC_programStatus__c = 'Draft';
    programToInsert.parentId = Org.id;
    insert programToInsert;
    Test.startTest();
    AccountTeamMember ProgramATM = new AccountTeamMember(TeamMemberRole = STRING_LCM_TeamRole,
        AccountId = programToInsert.Id,
        UserId = userLCM.Id,
        AccountAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit');
    insert ProgramATM;
    Test.stopTest();
    List<AccountShare> listAccountShare =
        [select id from AccountShare where Accountid =:Org.id and rowcause = 'Manual'];
    system.assert(!listAccountShare.isEmpty());
  }
  /**
   * @description Method to test Account Shares or Org Accounts
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @return void
   **/
  @isTest static void creatingAtmShouldNotCreateShareRecords() {
    User userLCM = new user();
    userLCM = UAC_TestUtility.createUser(STRING_LCM_TeamRole);
    Account Org = new UAC_testAccountBuilder()
                      .setRecordTypeDeveloperName(Label.UAC_organizationRecordTypeDevName)
                      .setType(STRING_FIELD_TYPE)
                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                      .build();
    Org.UAC_organizationContact1__c = UserInfo.getUserId();
    insert Org;
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .build();
    programToInsert.UAC_programStatus__c = 'Draft';
    programToInsert.parentId = Org.id;
    insert programToInsert;

    Account programToInser2 = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .build();
    programToInser2.UAC_programStatus__c = 'Draft';
    programToInser2.parentId = Org.id;
    insert programToInser2;
    Test.startTest();
    AccountTeamMember ProgramATM = new AccountTeamMember(TeamMemberRole = STRING_LCM_TeamRole,
        AccountId = programToInsert.Id,
        UserId = userLCM.Id,
        AccountAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit');
    insert ProgramATM;
    AccountTeamMember ProgramATM2 = new AccountTeamMember(TeamMemberRole = STRING_LCM_TeamRole,
        AccountId = programToInser2.Id,
        UserId = userLCM.Id,
        AccountAccessLevel = 'Read',
        CaseAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit');
    insert ProgramATM2;
    Test.stopTest();
    List<AccountShare> listAccountShare =
        [select id from AccountShare where Accountid =:Org.id and rowcause = 'Manual'];
    system.assert(listAccountShare.size() == 1);
  }
  /**
   * @description Method to test Account Share deletion
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @return void
   **/
  @isTest static void deletingAtmShouldDeleteAccountShares() {
    Test.startTest();
    Account programToInsert1 =
        [select id from account where RecordType.DeveloperName =:STRING_PROGRAM_RECORD_NAME];
    AccountTeamMember aTm =
        [select id from AccountTeamMember where TeamMemberRole =:STRING_LCM_TeamRole and Accountid
                                                               =:programToInsert1.id];
    delete aTm;
    Test.stopTest();
    Account objTestAccount = [select id from account where recordType.developerName
        =:Label.UAC_organizationRecordTypeDevName];
    List<AccountShare> listAccountShare =
        [select id from AccountShare where Accountid =:objTestAccount.id and rowcause = 'Manual'];
    system.assert(listAccountShare.isEmpty());
  }

  /**
   * @description Method to test non-insert scenarios
   * @author James Qian (Deloitte) | 11/13/2020
   * @return void
   **/
  @isTest static void updatingDeletingRecordShouldBeSuccessful() {
    Account programToInsert1 =
        [select id from account where RecordType.DeveloperName =:STRING_PROGRAM_RECORD_NAME];
    AccountTeamMember aTm =
        [select id from AccountTeamMember where TeamMemberRole =:STRING_LCM_TeamRole and Accountid
                                                               =:programToInsert1.id];
    Test.startTest();
    update aTm;
    delete aTm;
    Test.stopTest();
    List<AccountTeamMember> listATm =
        [select id from AccountTeamMember where TeamMemberRole =:STRING_LCM_TeamRole and Accountid
                                                               =:programToInsert1.id];
    System.assertEquals(true, listATm.isEmpty());
  }
}