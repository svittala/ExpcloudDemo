/**
 * @File Name          : UAC_sharingRecalculateBatchTest.cls
 * @Description        : Test class for the Batch
 * @Group              :
 * @Test Class         :
 * @Last Modified By   : Sarang Padhye (Deloitte)
 * @Last Modified On   : 8/30/2020,
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    8/28/2020   Sarang Padhye (Deloitte)        Initial Implementation.
 */

@isTest(seeAllData = false) public without sharing class UAC_sharingRecalculateBatchTest {
  private
  static final String strSupervisorApprovedError = Label.UAC_supervisorApprovedErrorMessage;
  private
  static final String STR_ADULT_CONTACT_A_NUMBER = '987654321';
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static Contact objUACContact;
  private
  static Account objDischargedFromProgram;
  private
  static Account objProgram;
  private
  static Account objProgram2;
  private
  static Case objDischargedCase;
  private
  static Case objCase;
  private
  static Account objFamGroupAccount;
  private
  static AccountTeamMember objAtm1;
  private
  static AccountTeamMember objAtm2;
  private
  static AccountTeamMember objAtm3;
  private
  static AccountTeamMember objAtm4;
  private
  static CaseTeamMember objCtm;
  private
  static CaseTeamMember objCtm1;
  private
  static List<CaseTeamRole> objCaseTeamRole;
  private
  static final String strRecordTypeFamGroup = 'UAC_familyGroup';
  private
  static final String strDischargeRecordType = Label.UAC_caseRecordTypeDischarge;
  private
  static final String strDischargeCompletedStatus = Label.UAC_caseStatusDischargeCompleted;
  private
  static final String strDateTimeLiteral_45 = 'LAST_N_DAYS:45';
  private
  static final String query = Label.UAC_sharingBatchBaseQuery
      + ' recordType.DeveloperName=:strDischargeRecordType AND status=:strDischargeCompletedStatus AND UAC_dateTimeOfDischarge__c < '
      + strDateTimeLiteral_45;

  /**
   * @description ORRUAC-1850 - Test Setup Method
   * @author Sarang Padhye (Deloitte) | 08/28/2020`
   * @return void
   **/
  @TestSetup static void makeData() {
    // Create an UAC contact

    objFamGroupAccount = new UAC_testAccountBuilder()
                             .setName('Test Family Name')
                             .setRecordTypeDeveloperName(strRecordTypeFamGroup)
                             .build();
    insert objFamGroupAccount;

    objUACContact = new UAC_testContactBuilder()
                        .setANumber(STR_UAC_CONTACT_A_NUMBER)
                        .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                        .build();
    objUACContact.AccountId = objFamGroupAccount.id;
    objUACContact.UAC_Gender__c = 'Male';
    insert objUACContact;

    objCase = new UAC_testCaseBuilder()
                  .setStatus('New Pending')
                  .setUAC(objUACContact.Id)
                  .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                  .build();
    insert objCase;

    objProgram = new UAC_testAccountBuilder()
                     .setName('Test Current Program')
                     .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();

    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Unavailable', 7, true);
    UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Unavailable', 7, true);

    objProgram2 = new UAC_testAccountBuilder()
                      .setName('Contact Current Program')
                      .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                      .setType(STR_PROGRAM_TYPE)
                      .build();

    insert objProgram2;
    UAC_TestUtility.createAssets(objProgram2.Id, 'Female', 'Available', 7, true);
    UAC_TestUtility.createAssets(objProgram2.Id, 'Male', 'Available', 7, true);

    Datetime dtDischarge_45 = Datetime.now().addDays(-46);
    objDischargedCase = new UAC_testCaseBuilder()
                            .setStatus(strDischargeCompletedStatus)
                            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeDischarge)
                            .setUAC(objUACContact.id)
                            .build();
    objDischargedCase.UAC_currentProgram__c = objProgram.id;
    objDischargedCase.UAC_dateTimeOfDischarge__c = dtDischarge_45;
    insert objDischargedCase;

    objAtm1 = new AccountTeamMember(AccountId = objProgram.id,
        TeamMemberRole = 'Lead Case Manager',
        UserId = UserInfo.getUserId());
    insert objAtm1;

    objAtm2 = new AccountTeamMember(AccountId = objFamGroupAccount.id,
        TeamMemberRole = 'Lead Case Manager',
        UserId = UserInfo.getUserId());
    insert objAtm2;

    objAtm3 = new AccountTeamMember(AccountId = objProgram2.id,
        TeamMemberRole = 'Lead Case Manager',
        UserId = UserInfo.getUserId());
    insert objAtm3;

    user LeadClinician = new user();
    LeadClinician = CreateUser();

    objAtm4 = new AccountTeamMember(
        AccountId = objProgram2.id, TeamMemberRole = 'Lead Clinician', UserId = LeadClinician.id);
    insert objAtm4;

    objCaseTeamRole =
        [select id from CaseTeamRole where Name IN('Lead Case Manager', 'Lead Clinician')];
    objCtm = new CaseTeamMember(
        Parentid = objCase.id, Memberid = UserInfo.getUserId(), TeamRoleId = objCaseTeamRole[0].id);
    insert objCtm;

    objCtm1 = new CaseTeamMember(
        Parentid = objCase.id, Memberid = LeadClinician.id, TeamRoleId = objCaseTeamRole[1].id);
    insert objCtm1;
  }
  /**
   * @description ORRUAC-1850 - Method to test if the Account Team members and Case Team Members
   * are deleted.
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @return void
   **/
  @isTest static void testBatchFlow1() {

    Test.startTest();
    UAC_sharingRecalculateBatch batch = new UAC_sharingRecalculateBatch(
        strDischargeRecordType, strDischargeCompletedStatus, strDateTimeLiteral_45, query);
    Database.executeBatch(batch);
    Test.stopTest();
    // Check if Account Team member is deleted
    List<Account> objTestFamGrp = [select id from Account where Name = 'Test Family Name'];
    List<AccountTeamMember> objTestAtm =
        [select id from AccountTeamMember where Accountid =:objTestFamGrp[0].id];
    System.assert(objTestAtm.isEmpty());
    // Check if Case Team member is deleted
    List<CaseTeamMember> objTestCtm =
        [select id from CaseTeamMember where Memberid =:UserInfo.getUserId()];
    System.assert(objTestCtm.isEmpty());
    // Check that sharing recalculated flag is true
    List<case> objTestCase =
        [select UAC_Sharing_Recalculated__c from case where status =:strDischargeCompletedStatus];
    System.assert(objTestCase[0].UAC_Sharing_Recalculated__c);
  }
  /**
   * @description ORRUAC-1850 - Method to test if Account Team Members and Case Team Members are not
   *deleted
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @return void
   **/
  @isTest static void testBatchFlow2() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_program__c'};
    List<Account> objTestContactProg =
        [select id from Account where Name = 'Contact Current Program'];
    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUACContact.UAC_program__c = objTestContactProg[0].id;
    update objUACContact;

    Test.startTest();
    UAC_sharingRecalculateBatch batch = new UAC_sharingRecalculateBatch(
        strDischargeRecordType, strDischargeCompletedStatus, strDateTimeLiteral_45, query);
    Database.executeBatch(batch);
    Test.stopTest();
    // Check if Account Team member is NOT deleted
    List<Account> objTestFamGrp = [select id from Account where Name = 'Test Family Name'];
    List<AccountTeamMember> objTestAtm =
        [select id from AccountTeamMember where Accountid =:objTestFamGrp[0].id];
    System.assert(!objTestAtm.isEmpty());
    // Check if Case Team member is NOT deleted
    List<CaseTeamMember> objTestCtm =
        [select id from CaseTeamMember where Memberid =:UserInfo.getUserId()];
    System.assert(!objTestCtm.isEmpty());
    // Check that sharing recalculated flag is true
    List<case> objTestCase =
        [select UAC_Sharing_Recalculated__c from case where status =:strDischargeCompletedStatus];
    System.assert(objTestCase[0].UAC_Sharing_Recalculated__c);
  }
  /**
   * @description ORRUAC-1850 - Method for exceptions
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @return void
   **/
  @isTest static void testBatchFlow3() {
    Test.StartTest();
    UAC_sharingRecalculateBatch batch = new UAC_sharingRecalculateBatch(
        strDischargeRecordType, strDischargeCompletedStatus, strDateTimeLiteral_45, query);
    UAC_sharingServiceHelper.forceException = true;
    Id idBatch = Database.executeBatch(batch);
    Test.StopTest();
    System.assert(String.isNotBlank(idBatch));
  }
  /**
   * @description ORRUAC-1850 - Method to test Batch Scheduler
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @return void
   **/
  @isTest static void testScheduler() {
    Test.StartTest();
    Id idSched = UAC_sharingRecalculateBatchScheduler.scheduleBatch('UAC_sharingRecalculateBatchTest');
    Test.StopTest();
    System.assert(String.isNotBlank(idSched));
  }
  /**
   * @description ORRUAC-1850 - Method to create user
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @return void
   **/
  static User CreateUser() {
    String orgId = UserInfo.getOrganizationId();
    String dateString =
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;
    u.Alias = 'Tcode';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;

    return u;
  }
}