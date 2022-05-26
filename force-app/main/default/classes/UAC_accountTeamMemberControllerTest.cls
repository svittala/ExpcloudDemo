/**
 * @File Name          : UAC_accountTeamMemberControllerTest.cls
 * @Description        : Account Team Member related list to avoid sharing issues
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_accountTeamMemberController
 */
@isTest public class UAC_accountTeamMemberControllerTest {
  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final String STRING_PROFILE_NAME = 'Case Manager';

  /**
     * @description Test setup method
     * @author James Qian (Deloitte) | 2/23/2021
     **/
    @testSetup static void setupTestData() {
        UAC_TestUtility.createUser(STRING_PROFILE_NAME);
    }

  /**
   * @description Positive test case for inserting case team members
   * @author James Qian (Deloitte) | 11/10/2020
   **/
  @isTest static void createTeamMemberShouldBeSuccessful() {
    Account programToInsert =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STRING_FIELD_TYPE)
            .buildAndSave();
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequest =
        UAC_accountTeamMemberController.createAccountTeamMember(queryUser().Id,
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Edit',
            'Edit',
            'Edit');
    List<UAC_accountTeamMemberController.AccountTeamMemberWrapper> listWrapperToValidate =
        UAC_accountTeamMemberController.getAccountTeamMembers(programToInsert.Id);
    System.assertEquals(1, listWrapperToValidate.size());
    System.assertEquals(true, newRequest.success);
  }

  /**
   * @description Positive test case for deleting case team members
   * @author James Qian (Deloitte) | 11/10/2020
   **/
  @isTest static void deleteTeamMemberShouldBeSuccessful() {
    Account programToInsert =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STRING_FIELD_TYPE)
            .buildAndSave();
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestCreate =
        UAC_accountTeamMemberController.createAccountTeamMember(queryUser().Id,
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Edit',
            'Edit',
            'Edit');
    AccountTeamMember queriedAccountTeamMember =
        [SELECT Id FROM AccountTeamMember WHERE AccountId =:programToInsert.Id];
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestDelete =
        UAC_accountTeamMemberController.deleteAccountTeamMember(queriedAccountTeamMember.Id);
    List<UAC_accountTeamMemberController.AccountTeamMemberWrapper> listWrapperToValidate =
        UAC_accountTeamMemberController.getAccountTeamMembers(programToInsert.Id);
    System.assertEquals(0, listWrapperToValidate.size());
    System.assertEquals(true, newRequestDelete.success);
  }

  /**
   * @description Positive test case for updating case team members
   * @author James Qian (Deloitte) | 2/23/2021
   **/
  @isTest static void updateTeamMemberShouldBeSuccessful() {
    Account programToInsert =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STRING_FIELD_TYPE)
            .buildAndSave();
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestCreate =
        UAC_accountTeamMemberController.createAccountTeamMember(queryUser().Id,
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Edit',
            'Edit',
            'Edit');
    AccountTeamMember queriedAccountTeamMember =
        [SELECT Id FROM AccountTeamMember WHERE AccountId =:programToInsert.Id];
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestToUpdate =
        UAC_accountTeamMemberController.updateAccountTeamMember(queriedAccountTeamMember.Id,
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Read',
            'Read',
            'Read');
    List<UAC_accountTeamMemberController.AccountTeamMemberWrapper> listWrapperToValidate =
        UAC_accountTeamMemberController.getAccountTeamMembers(programToInsert.Id);
    System.assertEquals(1, listWrapperToValidate.size());
    System.assertEquals('Read', listWrapperToValidate[0].strAccAccessLevel);
    System.assertEquals(true, newRequestToUpdate.success);
  }

  /**
   * @description Negative test case for inserting case team members
   * @author James Qian (Deloitte) | 2/23/2021
   **/
  @isTest static void createTeamMemberShouldNotBeSuccessful() {
    Account programToInsert =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STRING_FIELD_TYPE)
            .buildAndSave();
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequest =
        UAC_accountTeamMemberController.createAccountTeamMember(UserInfo.getUserId(),
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Edit',
            'Edit',
            'Edit');
    UAC_accountTeamMemberController.boolProgramPermissions = false;
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequest2 =
        UAC_accountTeamMemberController.createAccountTeamMember(UserInfo.getUserId(),
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Edit',
            'Edit',
            'Edit');
    List<UAC_accountTeamMemberController.AccountTeamMemberWrapper> listWrapperToValidate =
        UAC_accountTeamMemberController.getAccountTeamMembers(programToInsert.Id);
    System.assertEquals(0, listWrapperToValidate.size());
    System.assertEquals(false, newRequest.success);
    System.assertEquals(false, newRequest2.success);
  }

  /**
   * @description Negative test case for deleting case team members
   * @author James Qian (Deloitte) | 2/23/2021
   **/
  @isTest static void deleteTeamMemberShouldNotBeSuccessful() {
    Account programToInsert =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STRING_FIELD_TYPE)
            .buildAndSave();
    insert new AccountTeamMember(UserId = UserInfo.getUserId(),
        AccountId = programToInsert.Id,
        TeamMemberRole = Label.UAC_accountTeamRoleLCM,
        AccountAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit');
    AccountTeamMember queriedAccountTeamMember =
        [SELECT Id FROM AccountTeamMember WHERE AccountId =:programToInsert.Id];
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestDelete =
        UAC_accountTeamMemberController.deleteAccountTeamMember(queriedAccountTeamMember.Id);
    UAC_accountTeamMemberController.boolProgramPermissions = false;
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestDelete2 =
        UAC_accountTeamMemberController.deleteAccountTeamMember(queriedAccountTeamMember.Id);
    List<UAC_accountTeamMemberController.AccountTeamMemberWrapper> listWrapperToValidate =
        UAC_accountTeamMemberController.getAccountTeamMembers(programToInsert.Id);
    System.assertEquals(1, listWrapperToValidate.size());
    System.assertEquals(false, newRequestDelete.success);
    System.assertEquals(false, newRequestDelete2.success);
  }

  /**
   * @description Negative test case for updating case team members
   * @author James Qian (Deloitte) | 2/23/2021
   **/
  @isTest static void updateTeamMemberShouldNotBeSuccessful() {
    Account programToInsert =
        new UAC_testAccountBuilder()
            .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
            .setType(STRING_FIELD_TYPE)
            .buildAndSave();
    insert new AccountTeamMember(UserId = UserInfo.getUserId(),
        AccountId = programToInsert.Id,
        TeamMemberRole = Label.UAC_accountTeamRoleLCM,
        AccountAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit');
    AccountTeamMember queriedAccountTeamMember =
        [SELECT Id FROM AccountTeamMember WHERE AccountId =:programToInsert.Id];
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestToUpdate =
        UAC_accountTeamMemberController.updateAccountTeamMember(queriedAccountTeamMember.Id,
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Read',
            'Read',
            'Read');
    UAC_accountTeamMemberController.boolProgramPermissions = false;
    UAC_accountTeamMemberController.AccountTeamMemberRequest newRequestToUpdate2 =
        UAC_accountTeamMemberController.updateAccountTeamMember(queriedAccountTeamMember.Id,
            programToInsert.Id,
            Label.UAC_accountTeamRoleLCM,
            'Read',
            'Read',
            'Read');
    List<UAC_accountTeamMemberController.AccountTeamMemberWrapper> listWrapperToValidate =
        UAC_accountTeamMemberController.getAccountTeamMembers(programToInsert.Id);
    System.assertEquals(false, newRequestToUpdate.success);
    System.assertEquals(false, newRequestToUpdate2.success);
  }

  /**
   * @description Queries user for ATM operations
   * @return User
   * @author James Qian (Deloitte) | 2/23/2021
   **/
  private
  static User queryUser() {
    return
        [SELECT Id FROM User WHERE CreatedById =:UserInfo.getUserId() AND Profile.Name
                                                =:STRING_PROFILE_NAME AND IsActive = true LIMIT 1];
  }
}