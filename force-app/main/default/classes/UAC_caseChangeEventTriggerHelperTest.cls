/**
 * @File Name         : UAC_caseChangeEventTriggerHelperTest.cls
 * @Description       : Test class for the following:
 * Apex Class
 * - UAC_caseChangeEventTriggerHelper
 * - UAC_caseChangeEventTriggerHandler
 * Apex Trigger
 * - UAC_caseChangeEventTrigger
 * @Group             : UAC_caseChangeEventTrigger
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-29-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-28-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
@isTest public class UAC_caseChangeEventTriggerHelperTest {

  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_PROGRAM_TYPE = 'Influx Care Facility';
  private
  static final String STR_ROLE_LEAD_CM = label.UAC_accountTeamRoleLCM;
  private
  static final String STR_RECORD_TYPE_FAMILY_GROUP = 'UAC_familyGroup';

  @TestSetup static void setupData() {
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    User leadCM = UAC_TestUtility.createUser(STR_ROLE_LEAD_CM, Label.UAC_userRoleProgramStaff);
    User leadCM2 = UAC_TestUtility.createUser(STR_ROLE_LEAD_CM, Label.UAC_userRoleProgramStaff);
    User medicalCoordinator = UAC_TestUtility.createUser(
        UAC_caseChangeEventTriggerHelper.ROLE_MEDICAL_COORDINATOR, Label.UAC_userRoleProgramStaff);
    User medicalCoordinator2 = UAC_TestUtility.createUser(
        UAC_caseChangeEventTriggerHelper.ROLE_MEDICAL_COORDINATOR, Label.UAC_userRoleProgramStaff);
    System.runAs(altAdminUser) {
      Account objFamilyGroupAccount = new UAC_testAccountBuilder()
                                          .setName('Test Family Name')
                                          .setRecordTypeDeveloperName(STR_RECORD_TYPE_FAMILY_GROUP)
                                          .buildAndSave();
      Account objProgram =
          new UAC_testAccountBuilder()
              .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
              .setStatus('Draft')
              .setType(STR_PROGRAM_TYPE)
              .buildAndSave();
      List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
      lstAccountTeamMember.add(new AccountTeamMember(AccountId = objProgram.Id,
          UserId = leadCM.Id,
          AccountAccessLevel = 'Edit',
          TeamMemberRole = STR_ROLE_LEAD_CM,
          ContactAccessLevel = 'Edit'));
      lstAccountTeamMember.add(new AccountTeamMember(AccountId = objProgram.Id,
          UserId = medicalCoordinator.Id,
          TeamMemberRole = UAC_caseChangeEventTriggerHelper.ROLE_MEDICAL_COORDINATOR,
          AccountAccessLevel = 'Edit',
          ContactAccessLevel = 'Edit'));
      insert lstAccountTeamMember;
      Contact objUACContact = new UAC_testContactBuilder()
                                  .setANumber(STR_A_NUM_UAC)
                                  .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                  .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                  .build();
      objUACContact.AccountId = objFamilyGroupAccount.Id;
      insert objUACContact;
    }
  }

  /**
   * @description Method to test update of Entry Team Member records on update of UAC program.
   * @author Sachet Khanal (Deloitte) | 10-29-2020
   **/
  @isTest static void updatingUACProgramShouldUpdateEntryTeam() {
    Test.enableChangeDataCapture();
    Account objProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:Label.UAC_accountRecordTypeAPINameProgram LIMIT 1];
    Contact objUACContact =
        UAC_TestContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
    Case objMentalHealthReferral = new UAC_testCaseBuilder()
                                       .setUAC(objUACContact.Id)
                                       .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeMHR)
                                       .buildAndSave();
    CaseTeamRole idRoleMedicalCoordinator =
        UAC_caseChangeEventTriggerHelper.getCaseTeamRolesByName().get(
            UAC_caseChangeEventTriggerHelper.ROLE_MEDICAL_COORDINATOR);
    CaseTeamMember objCaseTeamMember = new CaseTeamMember(TeamRoleId = idRoleMedicalCoordinator.Id,
        ParentId = objMentalHealthReferral.Id,
        MemberId = UserInfo.getUserId());
    insert objCaseTeamMember;
    Test.getEventBus().deliver();
    Test.startTest();
    objUACContact.UAC_program__c = objProgram.Id;
    update objUACContact;
    Test.stopTest();
    Test.getEventBus().deliver();
    // clang-format off
      AccountTeamMember objProgramMedicalCoordinator = [
        SELECT
          Id, UserId
        FROM
          AccountTeamMember
        WHERE
          TeamMemberRole = :idRoleMedicalCoordinator.Name
          AND AccountId = :objProgram.Id
        LIMIT 1
      ];
    // clang-format on
    List<CaseTeamMember> lstCaseTeamMember =
        [SELECT Id FROM CaseTeamMember WHERE ParentId =:objMentalHealthReferral.Id AND MemberId
                                                      =:objProgramMedicalCoordinator.UserId];
    System.assert(!lstCaseTeamMember.isEmpty(),
        'Test method: updatingUACProgramShouldUpdateEntryTeam() failed.');
  }

  /**
   * @description Method to cover code coverage for unimplemented trigger handler methods.
   * @author Sachet Khanal (Deloitte) | 10-29-2020
   **/
  @isTest static void caseChangeEventTriggerHandlerUnimplementedMethodTest() {
    UAC_caseChangeEventTriggerHandler objCaseChangeEventTriggerHandler =
        new UAC_caseChangeEventTriggerHandler();
    objCaseChangeEventTriggerHandler.beforeInsert(null);
    objCaseChangeEventTriggerHandler.beforeUpdate(null, null);
    objCaseChangeEventTriggerHandler.beforeDelete(null);
    objCaseChangeEventTriggerHandler.afterUpdate(null, null);
    objCaseChangeEventTriggerHandler.afterDelete(null);
    objCaseChangeEventTriggerHandler.afterUndelete(null);
    System.assert(!objCaseChangeEventTriggerHandler.isDisabled(),
        'Test method: caseChangeEventTriggerHandlerUnimplementedMethodTest() failed.');
  }
}