/**
 * @File Name          : UAC_accountTeamMemberController.cls
 * @Description        : Account Team Member related list to avoid sharing issues
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_accountTeamMemberController
 */
public
without sharing class UAC_accountTeamMemberController {

  // Allows permissions check to fail for tests
  @TestVisible private static Boolean boolProgramPermissions;
  /**
   * @description Queries existing Account team members for a given Account
   * @author James Qian (Deloitte) | 11/10/2020
   * @param Id idAccount
   * @return List<AccountTeamMemberWrapper>
   **/
  @AuraEnabled public static List<AccountTeamMemberWrapper> getAccountTeamMembers(Id idAccount) {
    List<AccountTeamMemberWrapper> listWrapper = new List<AccountTeamMemberWrapper>();
    if (!checkPermissions('Read', idAccount)) {
      return listWrapper;
    }
    for (AccountTeamMember accountTeamMemberQueried : [SELECT Id,
           UserId,
           User.Name,
           TeamMemberRole,
           AccountAccessLevel,
           CaseAccessLevel,
           ContactAccessLevel FROM AccountTeamMember WHERE AccountId =:idAccount]) {
      listWrapper.add(new AccountTeamMemberWrapper(accountTeamMemberQueried.Id,
          accountTeamMemberQueried.User.Name,
          '/' + accountTeamMemberQueried.Id,
          accountTeamMemberQueried.TeamMemberRole,
          translateValues(accountTeamMemberQueried.AccountAccessLevel),
          translateValues(accountTeamMemberQueried.CaseAccessLevel),
          translateValues(accountTeamMemberQueried.ContactAccessLevel)));
    }
    return listWrapper;
  }

  /**
   * @description Creates new Account Team Member and runs extra logic
   * @author James Qian (Deloitte) | 11/10/2020
   * @param Id idUser
   * @param Id idAccount,
   * @param strRole,
   * @param strAccAccessLevel,
   * @param strCaseAccessLevel,
   * @param strContactAccessLevel
   * @return AccountTeamMemberRequest
   **/
  @AuraEnabled public static AccountTeamMemberRequest createAccountTeamMember(Id idUser,
      Id idAccount,
      String strRole,
      String strAccAccessLevel,
      String strCaseAccessLevel,
      String strContactAccessLevel) {
    AccountTeamMemberRequest newRequest = new AccountTeamMemberRequest();
    Id loggedSubUser = UserInfo.getUserId();
    newRequest.success = true;
    newRequest.message = 'Success';
    if (!checkPermissions('Edit', idAccount)) {
      newRequest.success = false;
      newRequest.message = Label.UAC_accountTeamsPermissionError;
      return newRequest;
    } else if (idUser == UserInfo.getUserId() && getProfileName(userinfo.getProfileId()) != Label.UAC_projectOfficerProfileName ) {
      newRequest.success = false;
      newRequest.message = Label.UAC_accountTeamsSelfUpdateError;
      return newRequest;
    }
    try {
      insert new AccountTeamMember(UserId = idUser,
          AccountId = idAccount,
          TeamMemberRole = strRole,
          AccountAccessLevel = strAccAccessLevel,
          CaseAccessLevel = strCaseAccessLevel,
          ContactAccessLevel = strContactAccessLevel);
    } catch (DMLException e) {
      newRequest.success = false;
      newRequest.message = e.getMessage().substringAfter('first error: ');
    }
    return newRequest;
  }

  /**
   * @description Update Account Team Member and runs extra logic
   * @author Chaitanya Nandamuri (Deloitte) | 11/23/2020
   * @param ATMRecordId
   * @param strRole,
   * @param strAccAccessLevel,
   * @param strCaseAccessLevel,
   * @param strContactAccessLevel
   * @return AccountTeamMemberRequest
   **/
  @AuraEnabled public static AccountTeamMemberRequest updateAccountTeamMember(Id idATMRecord,
      Id idAccount,
      String strRole,
      String strAccAccessLevel,
      String strCaseAccessLevel,
      String strContactAccessLevel) {
    AccountTeamMemberRequest newRequest = new AccountTeamMemberRequest();
    Id loggedSubUser = UserInfo.getUserId();
    newRequest.success = true;
    newRequest.message = 'Success';
    List<AccountTeamMember> queriedATM =
        [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE Id =:idATMRecord];
    if (queriedATM == null || queriedATM.isEmpty() || !checkPermissions('Edit', idAccount)) {
      newRequest.success = false;
      newRequest.message = Label.UAC_accountTeamsPermissionError;
      return newRequest;
    }
    if (queriedATM[0].UserId == UserInfo.getUserId() && getProfileName(userinfo.getProfileId()) != Label.UAC_projectOfficerProfileName ) {
      newRequest.success = false;
      newRequest.message = Label.UAC_accountTeamsSelfUpdateError;
      return newRequest;
    }
    try {
      update new AccountTeamMember(Id = idATMRecord,
          TeamMemberRole = strRole,
          AccountAccessLevel = strAccAccessLevel,
          CaseAccessLevel = strCaseAccessLevel,
          ContactAccessLevel = strContactAccessLevel);
    } catch (DMLException e) {
      newRequest.success = false;
      newRequest.message = e.getMessage().substringAfter('first error: ');
    }
    return newRequest;
  }

  /**
   * @description Deletes Account Team Member
   * @author James Qian (Deloitte) | 11/10/2020
   * @param Id idAccountTeamMember
   * @return AccountTeamMemberRequest
   **/
  @AuraEnabled public static AccountTeamMemberRequest deleteAccountTeamMember(
      Id idAccountTeamMember) {
    AccountTeamMemberRequest newRequest = new AccountTeamMemberRequest();
    newRequest.success = true;
    newRequest.message = 'Success';
    List<AccountTeamMember> queriedATM =
        [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE Id =:idAccountTeamMember];
    if (queriedATM == null || queriedATM.isEmpty()
        || !checkPermissions('Edit', queriedATM[0].AccountId)) {
      newRequest.success = false;
      newRequest.message = Label.UAC_accountTeamsPermissionError;
      return newRequest;
    } else if (queriedATM[0].UserId == UserInfo.getUserId() && getProfileName(userinfo.getProfileId()) != Label.UAC_projectOfficerProfileName ) {
      newRequest.success = false;
      newRequest.message = Label.UAC_accountTeamsSelfUpdateError;
      return newRequest;
    }
    try {
      delete new AccountTeamMember(Id = idAccountTeamMember);
    } catch (DMLException e) {
      newRequest.success = false;
      newRequest.message = e.getMessage().substringAfter('first error: ');
    }
    return newRequest;
  }

  /**
   * @description Translates database values to front-end values
   * @author James Qian (Deloitte) | 11/10/2020
   * @param String input
   * @return String
   **/
  private
  static String translateValues(String input) {
    if (input == 'Edit') {
      return 'Read/Write';
    }
    if (input == 'Read') {
      return 'Read';
    }
    return 'None';
  }

  /**
   * @description Checks permissions on the parent record before carrying out operations
   * @author James Qian (Deloitte) | 11/10/2020
   * @param String strOperation
   * @param Id idRecord
   * @return Boolean
   **/
  private
  static Boolean checkPermissions(String strOperation, Id idRecord) {
    UserRecordAccess objAccessLevel = [
      select RecordId,
      HasEditaccess,
      HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId
                                                       =:idRecord
    ];
    Account objAccount = [SELECT RecordType.DeveloperName FROM Account WHERE Id =:idRecord];
    if (strOperation == 'Read' && objAccessLevel.HasReadAccess) {
      return true;
    }
    if (boolProgramPermissions == null) {
      boolProgramPermissions = FeatureManagement.checkPermission('UAC_manageAccountTeamsProgram');
    }
    if (strOperation == 'Edit'
        && ((objAccount.RecordType.DeveloperName == Label.UAC_accountRecordTypeAPINameProgram
                && boolProgramPermissions)
            || (objAccessLevel.HasEditaccess
                && objAccount.RecordType.DeveloperName != Label.UAC_accountRecordTypeAPINameProgram
                && FeatureManagement.checkPermission('UAC_manageAccountTeams')))) {
      return true;
    }
    return false;
  }

  /**
   * @description Inner class for handling errors and returning to LWC
   * @author James Qian (Deloitte) | 11/10/2020
   **/
  @TestVisible private without sharing class AccountTeamMemberRequest {
    @AuraEnabled public String message;
    @AuraEnabled public Boolean success;
  }

  /**
   * @description Inner class for displaying URLs in datatable
   * @author James Qian (Deloitte) | 11/10/2020
   **/
  @TestVisible private without sharing class AccountTeamMemberWrapper {
    @AuraEnabled public Id idRecord;
    @AuraEnabled public String strMemberName;
    @AuraEnabled public String strMemberURL;
    @AuraEnabled public String strRole;
    @AuraEnabled public String strAccAccessLevel;
    @AuraEnabled public String strCaseAccessLevel;
    @AuraEnabled public String strContactAccessLevel;

    private
    AccountTeamMemberWrapper(Id idRecordInput,
        String strMemberNameInput,
        String strMemberURLInput,
        String strRoleInput,
        String strAccAccessLevelInput,
        String strCaseAccessLevelInput,
        String strContactAccessLevelInput) {
      idRecord = idRecordInput;
      strMemberName = strMemberNameInput;
      strMemberURL = strMemberURLInput;
      strRole = strRoleInput;
      strAccAccessLevel = strAccAccessLevelInput;
      strCaseAccessLevel = strCaseAccessLevelInput;
      strContactAccessLevel = strContactAccessLevelInput;
    }
  }
  private
  static String getProfileName(Id ProfileId){
         String profileName = [Select Id, Name from Profile where Id =: ProfileId].Name;
         return profileName;
     }
}