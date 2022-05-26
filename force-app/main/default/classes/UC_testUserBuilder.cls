/**
 * @File Name          : UC_testUserBuilder.cls
 * @Description        : Builder class for creating User Record for unit test.
 * @Author             : Karthi Subramanian
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 03-26-2021
 * @Modification Log   :
 * Ver       Date            Author                         Modification
 * 1.0    03/19/2021    Karthi Subramanian (Deloitte)       Initial Version
 * 2.0    03/24/2021    Karthi Subramanian (Deloitte)       Added buildUserWithORRFlag Method
 * 3.0    03/26/2021    Karthi Subramanian (Deloitte)       Added buildUserWithORRFlagACFAuth Method 
 **/
@isTest
public class UC_testUserBuilder {

  /**
     * @description Test Builder Method for User Record.
     * * @author Karthi Subrmanian (Deloitte) | 03-19-2021
     * @param N/A
     * @return User
  **/
  public User build() {
    Profile objProfile = [SELECT Id FROM Profile WHERE Name =:Label.UAC_myTrailhead LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFGenUser';
    objUser.LastName = 'ARFGenUserLast';
    objUser.Alias = 'ARFGenUser'.substring(0, 1) + 'ARFGenUserLast'.substring(0, 4);
    objUser.Email = 'arfacctcreationtest@arfuserreq.com';
    objUser.Username = 'arfacctcreationtest@arfuserreq.com' + Label.UAC_arfUsernameExtension;
    objUser.ProfileId = objProfile.id;
    objUser.TimeZoneSidKey = 'America/New_York';
    objUser.LanguageLocaleKey = 'en_US';
    objUser.EmailEncodingKey = 'ISO-8859-1';
    objUser.LocaleSidKey = 'en_US';
    objUser.UserPermissionsSupportUser = true;
    objUser.UserPermissionsInteractionUser = true;
    objUser.UAC_ORRAuthorizedUser__c = false;
    return objUser;
  }
  
  public User buildAndSave() {
    User objUser = this.build();
    insert objUser;
    return objUser;
  }

  /**
     * @description Test Builder Method for User Record to be used in JIT Handler.
     * * @author Karthi Subrmanian (Deloitte) | 03-24-2021
     * @param N/A
     * @return User
  **/
  public User buildUserWithORRFlag(string emailAddr) {
    Profile objProfile = [SELECT Id FROM Profile WHERE Name =:Label.UAC_myTrailhead LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFGenUser';
    objUser.LastName = 'ARFGenUserLast';
    objUser.Alias = 'ARFGenUser'.substring(0, 1) + 'ARFGenUserLast'.substring(0, 4);
    objUser.Email = emailAddr;
    objUser.Username = emailAddr + Label.UAC_arfUsernameExtension;
    objUser.ProfileId = objProfile.id;
    objUser.TimeZoneSidKey = 'America/New_York';
    objUser.LanguageLocaleKey = 'en_US';
    objUser.EmailEncodingKey = 'ISO-8859-1';
    objUser.LocaleSidKey = 'en_US';
    objUser.UserPermissionsSupportUser = true;
    objUser.UserPermissionsInteractionUser = true;
    objUser.UAC_ORRAuthorizedUser__c = true;
    insert objUser;
    return objUser;
  }

  /**
     * @description Test Builder Method for User Record to be used in ACF Handler.
     * * @author Karthi Subrmanian (Deloitte) | 03-26-2021
     * @param N/A
     * @return User
  **/
  public User buildUserWithORRFlagACFAuth(string emailAddr,string hhsid) {
    Profile objProfile = [SELECT Id FROM Profile WHERE Name =:Label.UAC_myTrailhead LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFGenUser';
    objUser.LastName = 'ARFGenUserLast';
    objUser.Alias = 'ARFGenUser'.substring(0, 1) + 'ARFGenUserLast'.substring(0, 4);
    objUser.Email = emailAddr;
    objUser.Username = emailAddr + Label.UAC_arfUsernameExtension;
    objUser.ProfileId = objProfile.id;
    objUser.TimeZoneSidKey = 'America/New_York';
    objUser.LanguageLocaleKey = 'en_US';
    objUser.EmailEncodingKey = 'ISO-8859-1';
    objUser.LocaleSidKey = 'en_US';
    objUser.UserPermissionsSupportUser = true;
    objUser.UserPermissionsInteractionUser = true;
    objUser.UAC_ORRAuthorizedUser__c = true;
    objUser.UAC_ACFHHSID__c=hhsid;
    insert objUser;
    return objUser;
  }
}