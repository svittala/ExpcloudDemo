/**
 * @File Name          : UAC_caseTeamMemberHelperTest.cls
 * @Description        : Test method for UAC_caseTeamMemberHelper.cls
 * @Author             : James Qian (Deloitte)
 * @Group              : Test
 */
@isTest public without sharing class UAC_caseTeamMemberHelperTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';

  /**
   * @description Sets up generic test data
   * @author James Qian (Deloitte) | 08/20/2020
   * @return void
   **/
  @TestSetup static void setupTestData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(objUACContact.id)
            .buildAndSave();
  }

  /**
   * @description Tests positive cases of reading existing case team members
   * @author James Qian (Deloitte) | 08/20/2020
   * @return void
   **/
  @isTest static void getCaseTeamMembersShouldReturnRecords() {
    Test.startTest();
    Id idCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName
        =:Label.UAC_caseRecordTypeApiNameUACReferral]
                    .Id;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert new CaseTeamMember(
        MemberId = UserInfo.getUserId(), ParentId = idCase, TeamRoleId = idCaseTeamRole);
    List<UAC_caseTeamMemberHelper.CaseTeamMemberWrapper> listWrappers =
        UAC_caseTeamMemberHelper.getCaseTeamMembers(idCase);
    List<CaseTeamRole> listCaseTeamRoles = UAC_caseTeamMemberHelper.getCaseTeamRoles();
    Test.stopTest();
    System.assertEquals(1, listWrappers.size());
    System.assertNotEquals(0, listCaseTeamRoles.size());
  }

  /**
   * @description Tests positive cases of creating new case team members and account team members
   * @author James Qian (Deloitte) | 08/20/2020
   * @return void
   **/
  @isTest static void createCaseTeamMembersShouldCreateRecords() {
    Test.startTest();
    Id idCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName
        =:Label.UAC_caseRecordTypeApiNameUACReferral]
                    .Id;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    UAC_caseTeamMemberHelper.CaseTeamMemberRequest objResponse =
        UAC_caseTeamMemberHelper.createCaseTeamMember(UserInfo.getUserId(), idCase, idCaseTeamRole);
    Test.stopTest();
    System.assertEquals(true, objResponse.success);
    System.assertNotEquals(
        null, [SELECT Id FROM CaseTeamMember WHERE MemberId =:UserInfo.getUserId()][0].Id);
    System.assertNotEquals(
        null, [SELECT Id FROM AccountTeamMember WHERE UserId =:UserInfo.getUserId()][0].Id);
  }

  /**
   * @description Tests positive cases of deleting existing case team members
   * @author James Qian (Deloitte) | 08/20/2020
   * @return void
   **/
  @isTest static void deleteCaseTeamMembersShouldDeleteRecords() {
    Test.startTest();
    Id idCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName
        =:Label.UAC_caseRecordTypeApiNameUACReferral]
                    .Id;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    CaseTeamMember caseTeamMemberNew = new CaseTeamMember(
        MemberId = UserInfo.getUserId(), ParentId = idCase, TeamRoleId = idCaseTeamRole);
    insert caseTeamMemberNew;
    UAC_caseTeamMemberHelper.CaseTeamMemberRequest objResponse =
        UAC_caseTeamMemberHelper.deleteCaseTeamMember(caseTeamMemberNew.Id , idCase);
    Test.stopTest();
    System.assertEquals(true, objResponse.success);
    System.assert(
        [SELECT Id FROM CaseTeamMember WHERE MemberId =:UserInfo.getUserId()].isEmpty());
  }
}