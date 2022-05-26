/**
 * @File Name          : UAC_contactChangeEventHelperTest.cls
 * @Description        : Test class for UAC_contactChangeEventTrigger
 *
 * @Author             : Sarang Padhye (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    8/20/2020   Sarang Padhye (Deloitte)     Initial Version - ORRUAC-2020
 **/
@isTest(seeAllData = false) public class UAC_contactChangeEventHelperTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Influx Care Facility';
  private
  static Contact objUACContact;
  private
  static Account objTargetProgram;
  private
  static Account familyGroupAccount;
  private
  static Case objCase;
  private
  static Account objCurrentProgram;

  /**
   * @description Method to test Contact Change Event Trigger
   * @author Sarang Padhye (Deloitte) | 8/20/2020
   * @return void
   **/
  @isTest static void testContactChangeEventTrigger() {
    // Enable all Change Data Capture

    Test.enableChangeDataCapture();
    String strRecordTypeFamGroup = 'UAC_familyGroup';
    objCurrentProgram = new UAC_testAccountBuilder()
                            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                            .setType(STR_PROGRAM_TYPE)
                            .setStatus('Draft')
                            .build();
    objCurrentProgram.UAC_bedCountAvailableMale__c = 7;
    objCurrentProgram.UAC_bedCountAvailableFemale__c = 0;
    insert objCurrentProgram;

    UAC_TestUtility.createAssets(objCurrentProgram.Id, 'Male', 'Available', 7, true);

    objTargetProgram = new UAC_testAccountBuilder()
                           .setName('Test Name')
                           .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                           .setStatus('Draft')
                           .setType(STR_PROGRAM_TYPE)
                           .build();
    objTargetProgram.UAC_bedCountAvailableMale__c = 7;
    objTargetProgram.UAC_bedCountAvailableFemale__c = 0;
    insert objTargetProgram;

    UAC_TestUtility.createAssets(objTargetProgram.Id, 'Male', 'Available', 7, true);

    familyGroupAccount = new UAC_testAccountBuilder()
                             .setName('Test Family Name')
                             .setRecordTypeDeveloperName(strRecordTypeFamGroup)
                             .build();
    insert familyGroupAccount;

    objUACContact = new UAC_testContactBuilder()
                        .setANumber(STR_UAC_CONTACT_A_NUMBER)
                        .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                        .build();
    objUACContact.UAC_program__c = objCurrentProgram.id;
    objUACContact.AccountId = familyGroupAccount.id;
    insert objUACContact;

    objCase = new UAC_testCaseBuilder()
                  .setStatus('New Pending')
                  .setUAC(objUACContact.Id)
                  .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                  .build();

    objCase.UAC_programFacility__c = objCurrentProgram.Id;
    insert objCase;

    user LeadClinician = new user();
    LeadClinician = CreateUser();

    user ProgramDirector = new User();
    ProgramDirector = CreateUser();

    user MedicalCoordinator = new User();
    MedicalCoordinator = CreateUser();

    // creating AccountTeamMember
    AccountTeamMember LCM = new AccountTeamMember();
    LCM.AccountId = objTargetProgram.id;
    LCM.TeamMemberRole = 'Lead Case Manager';
    LCM.UserId = UserInfo.getUserId();
    insert LCM;

    AccountTeamMember LC = new AccountTeamMember();
    LC.AccountId = objTargetProgram.id;
    LC.TeamMemberRole = 'Lead Clinician';
    LC.UserId = LeadClinician.id;
    insert LC;

    AccountTeamMember PD = new AccountTeamMember();
    PD.AccountId = objTargetProgram.id;
    PD.TeamMemberRole = 'Program Director';
    PD.UserId = ProgramDirector.id;
    insert PD;

    AccountTeamMember MC = new AccountTeamMember();
    MC.AccountId = objTargetProgram.id;
    MC.TeamMemberRole = 'Medical Coordinator';
    MC.UserId = MedicalCoordinator.id;
    insert MC;

    Test.getEventBus().deliver();

    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_program__c', 'Gender'};

    Contact queriedUAC = [
      select id,
      UAC_program__c,
      UAC_Gender__c,
      Ownerid from contact where lastname = 'TestContactLastName'
    ];

    Account objProgram = [select id from Account where Name = 'Test Name'];
    // Update contact Program Id to Target Program Id
    queriedUAC.UAC_program__c = objProgram.id;
    system.debug('queriedUAC ' + queriedUAC + 'objProgram ' + objProgram);

    update queriedUAC;
    // Deliver test change events
    Test.getEventBus().deliver();

    List<AccountTeamMember> lstAccountTeamMemberList =
        [select id from AccountTeamMember where accountid =:familyGroupAccount.id];
    // Account Team Members are transfer check
    System.assertEquals(4, lstAccountTeamMemberList.size());
    // Contact Ownership check
    System.assertEquals(UserInfo.getUserId(), queriedUAC.Ownerid);
    // Family Group Account Ownership check
    Account objFamAccount = [select id, ownerid from Account where id =:familyGroupAccount.id];
    System.assertEquals(UserInfo.getUserId(), objFamAccount.Ownerid);
  }

  /*
   * @description Method to create User
   * @author Chaitanya Nandamuri (Deloitte) | 6/5/2020
   * @return
   **/
  @isTest static User CreateUser() {
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
  /**
   * @description Method to test Contact Change Event Trigger
   * @author Vaibhav Kudesia (Deloitte) | 8/31/2020
   * @return void
   **/
  @isTest static void testContactChangeEventTriggerforSIR() {
    // Enable all Change Data Capture

    Test.enableChangeDataCapture();
    String strRecordTypeFamGroup = 'UAC_familyGroup';
    objCurrentProgram = new UAC_testAccountBuilder()
                            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                            .setStatus('Draft')
                            .setType(STR_PROGRAM_TYPE)
                            .build();
    objCurrentProgram.UAC_bedCountAvailableMale__c = 7;
    objCurrentProgram.UAC_bedCountAvailableFemale__c = 0;
    insert objCurrentProgram;

    UAC_TestUtility.createAssets(objCurrentProgram.Id, 'Male', 'Available', 7, true);

    objTargetProgram = new UAC_testAccountBuilder()
                           .setName('Test Name')
                           .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                           .setStatus('Draft')
                           .setType(STR_PROGRAM_TYPE)
                           .build();
    objTargetProgram.UAC_bedCountAvailableMale__c = 7;
    objTargetProgram.UAC_bedCountAvailableFemale__c = 0;
    insert objTargetProgram;

    UAC_TestUtility.createAssets(objTargetProgram.Id, 'Male', 'Available', 7, true);

    familyGroupAccount = new UAC_testAccountBuilder()
                             .setName('Test Family Name')
                             .setRecordTypeDeveloperName(strRecordTypeFamGroup)
                             .build();
    insert familyGroupAccount;

    objUACContact = new UAC_testContactBuilder()
                        .setANumber(STR_UAC_CONTACT_A_NUMBER)
                        .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                        .build();
    objUACContact.UAC_program__c = objCurrentProgram.id;
    objUACContact.AccountId = familyGroupAccount.id;
    insert objUACContact;

    UAC_Event__c tempEvent = UAC_testSIRBuilder.buildanEvent();
    tempEvent.UAC_programID__c = objTargetProgram.id;
    insert tempEvent;

    UAC_sir__c tempSir = UAC_testSIRBuilder.buildStandardSIR();
    tempSir.UAC_uaclookup__c = objUACContact.id;
    tempSir.UAC_eventID__c = tempEvent.id;
    tempSir.UAC_status__c = 'Submitted';
    tempSir.UAC_category__c = '';
    tempSIR.UAC_howWasThisUACInvolved__c = 'Victim';
    tempSIR.UAC_isCPSDifferentFromStateLicensing__c = 'No';
    tempSIR.UAC_reportedToStateLicensing__c = '';
    tempSIR.UAC_incidentatOtherCareProvFacility__c = 'No';
    tempSIR.UAC_title__c = 'Test Title';
    tempSIR.UAC_printedName__c = 'Test Printed Name';
    tempSIR.UAC_iConfirmThatIHaveCompletedAll__c = true;
    insert tempSir;

    objCase = new UAC_testCaseBuilder()
                  .setStatus('New Pending')
                  .setUAC(objUACContact.Id)
                  .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                  .build();

    objCase.UAC_programFacility__c = objCurrentProgram.Id;
    insert objCase;

    user LeadClinician = new user();
    LeadClinician = CreateUser();

    user ProgramDirector = new User();
    ProgramDirector = CreateUser();

    user MedicalCoordinator = new User();
    MedicalCoordinator = CreateUser();

    // creating AccountTeamMember
    AccountTeamMember LCM = new AccountTeamMember();
    LCM.AccountId = objTargetProgram.id;
    LCM.TeamMemberRole = 'Lead Case Manager';
    LCM.UserId = UserInfo.getUserId();
    insert LCM;

    AccountTeamMember LC = new AccountTeamMember();
    LC.AccountId = objTargetProgram.id;
    LC.TeamMemberRole = 'Lead Clinician';
    LC.UserId = LeadClinician.id;
    insert LC;

    AccountTeamMember PD = new AccountTeamMember();
    PD.AccountId = objTargetProgram.id;
    PD.TeamMemberRole = 'Program Director';
    PD.UserId = ProgramDirector.id;
    insert PD;

    AccountTeamMember MC = new AccountTeamMember();
    MC.AccountId = objTargetProgram.id;
    MC.TeamMemberRole = 'Medical Coordinator';
    MC.UserId = MedicalCoordinator.id;
    insert MC;

    Test.getEventBus().deliver();

    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_program__c', 'Gender'};

    Contact queriedUAC = [
      select id,
      UAC_program__c,
      UAC_Gender__c,
      Ownerid from contact where lastname = 'TestContactLastName'
    ];

    Account objProgram = [select id from Account where Name = 'Test Name'];
    // Update contact Program Id to Target Program Id
    queriedUAC.UAC_program__c = objProgram.id;
    system.debug('queriedUAC ' + queriedUAC + 'objProgram ' + objProgram);

    update queriedUAC;
    // Deliver test change events
    Test.getEventBus().deliver();

    List<AccountTeamMember> lstAccountTeamMemberList =
        [select id from AccountTeamMember where accountid =:familyGroupAccount.id];
    // Account Team Members are transfer check
    System.assertEquals(4, lstAccountTeamMemberList.size());
    // Contact Ownership check
    System.assertEquals(UserInfo.getUserId(), queriedUAC.Ownerid);
    // Family Group Account Ownership check
    Account objFamAccount = [select id, ownerid from Account where id =:familyGroupAccount.id];
    System.assertEquals(UserInfo.getUserId(), objFamAccount.Ownerid);
  }
}