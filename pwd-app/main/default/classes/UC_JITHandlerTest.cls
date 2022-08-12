/**
 * @File Name          : UC_JITHandlerTest.cls
 * @Description        : Builder class for creating User Record for unit test JIT Handler.
 * @Author             : Karthi Subramanian
 * @Group              :
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 03-24-2021
 * @Modification Log   :
 * Ver       Date            Author                         Modification
 * 1.0    03/24/2021    Karthi Subramanian (Deloitte)       Initial Version
 **/
@isTest public with sharing class UC_JITHandlerTest {
    
    
    public static User setupTestData() {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name ='MyTrailhead' LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFGenUser';
    objUser.LastName = 'ARFGenUserLast';
    objUser.Alias = 'ARFGenUser'.substring(0, 1) + 'ARFGenUserLast'.substring(0, 4);
    objUser.Email = 'arfacctcreationtest@arfuserreqjit.com';
    objUser.Username = 'fake@fake.com' + '.prod';
    objUser.ProfileId = objProfile.id;
    objUser.TimeZoneSidKey = 'America/New_York';
    objUser.LanguageLocaleKey = 'en_US';
    objUser.EmailEncodingKey = 'ISO-8859-1';
    objUser.LocaleSidKey = 'en_US';
    objUser.UserPermissionsSupportUser = true;
    objUser.UserPermissionsInteractionUser = true;
    objUser.UAC_ORRAuthorizedUser__c = true;
    objUser.UAC_ACFHHSID__c = '9884411857';
    insert objUser;
    return objUser;
    }
    
    
  /**
   * @description Test Builder Method for JIT Handler Create User method.
   * * @author Karthi Subrmanian (Deloitte) | 03-24-2021
   * @param N/A
   * @return N/A
   **/
  @isTest private static void testCreateUser() {
    final Id samlSsoProviderId = '0LE000000000000';
    final Id communityId = '0DB000000000000';
    final Id portalId = '0DB000000000000';
    final String federationIdentifier = 'federationIdentifier';
    final String USER_EMAIL = 'arfacctcreationtest@arfuserreqjit.com';
    final String XID_FED_IDENTIFIER = 'XIDFedIdentifier';
    // clang-format off
    final Map<String, String> attributes = new Map<String, String>{
        'email' => USER_EMAIL,
         'XID' => XID_FED_IDENTIFIER
        };
    // clang-format on
    final String assertion = 'assertion';
    User objUser = setupTestData();
    Test.startTest();
    UAC_JITHandler handler = new UAC_JITHandler();
    handler.createUser(
        samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    Test.stopTest();

    // Select more fields and do more assertions than this
    User newUser = [SELECT Email, IsActive, FederationIdentifier FROM User where id =:objUser.id];
    System.assertEquals(USER_EMAIL, newUser.Email);
    System.assertEquals(true, newUser.IsActive);
    System.assertEquals(XID_FED_IDENTIFIER, newUser.FederationIdentifier);
  }

  /**
   * @description Test Builder Method for JIT Handler Create User Exception Scenario.
   * * @author Karthi Subrmanian (Deloitte) | 03-24-2021
   * @param N/A
   * @return N/A
   **/
  @isTest private static void testCreateUserNegativeScenario() {
    final Id samlSsoProviderId = '0LE000000000000';
    final Id communityId = '0DB000000000000';
    final Id portalId = '0DB000000000000';
    final String federationIdentifier = 'federationIdentifier';
    final String USER_EMAIL = 'test@arfuserreqjit.com';
    final String USER_INVALID_EMAIL = 'testinvalid@arfuserreqjit.com';
    final String XID_FED_IDENTIFIER = 'XIDFedIdentifier';
    // clang-format off
    final Map<String, String> attributes = new Map<String, String>{
        'email' => USER_EMAIL,
         'XID' => XID_FED_IDENTIFIER
        };
    // clang-format on
    final String assertion = 'assertion';
    string exceptionMsg;
        Profile objProfile = [SELECT Id FROM Profile WHERE Name ='MyTrailhead' LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFGenUser';
    objUser.LastName = 'ARFGenUserLast';
    objUser.Alias = 'ARFGenUser'.substring(0, 1) + 'ARFGenUserLast'.substring(0, 4);
    objUser.Email = USER_INVALID_EMAIL;
    objUser.Username = 'fake@fake.com' + '.prod';
    objUser.ProfileId = objProfile.id;
    objUser.TimeZoneSidKey = 'America/New_York';
    objUser.LanguageLocaleKey = 'en_US';
    objUser.EmailEncodingKey = 'ISO-8859-1';
    objUser.LocaleSidKey = 'en_US';
    objUser.UserPermissionsSupportUser = true;
    objUser.UserPermissionsInteractionUser = true;
    objUser.UAC_ORRAuthorizedUser__c = true;
    objUser.UAC_ACFHHSID__c = '9884411857';
    insert objUser;
    Test.startTest();
    try {
      UAC_JITHandler handler = new UAC_JITHandler();
      handler.createUser(
          samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      exceptionMsg = ex.getMessage();
    }
    Test.stopTest();
    // Select more fields and do more assertions than this
    User newUser = [SELECT Email, IsActive, FederationIdentifier FROM User where id =:objUser.id];
    System.assertNOTEquals(null, exceptionMsg);
    System.assertNOTEquals(USER_EMAIL, newUser.Email);
    System.assertEquals(true, newUser.IsActive);
    System.assertNOTEquals(XID_FED_IDENTIFIER, newUser.FederationIdentifier);
  }

  /**
   * @description Test Builder Method for JIT Handler Update User method.
   * * @author Karthi Subrmanian (Deloitte) | 03-24-2021
   * @param N/A
   * @return N/A
   **/
  @isTest private static void testUpdateUser() {
    final Id samlSsoProviderId = '0LE000000000000';
    final Id communityId = '0DB000000000000';
    final Id portalId = '0DB000000000000';
    final String federationIdentifier = 'federationIdentifier';
    final String USER_EMAIL = 'arfacctcreationtest@arfuserreqjit.com';
    final String XID_FED_IDENTIFIER = 'XIDFedIdentifier';
    // clang-format off
    final Map<String, String> attributes = new Map<String, String>{
        'email' => USER_EMAIL,
         'XID' => XID_FED_IDENTIFIER
        };
    // clang-format on
    final String assertion = 'assertion';
    User objUser = setupTestData();
    objUser.federationIdentifier = federationIdentifier;
    update objUser;
    Test.startTest();
    UAC_JITHandler handler = new UAC_JITHandler();
    handler.updateUser(objUser.id,
        samlSsoProviderId,
        communityId,
        portalId,
        federationIdentifier,
        attributes,
        assertion);
    Test.stopTest();

    // Select more fields and do more assertions than this
    User newUser = [SELECT Email, IsActive, FederationIdentifier FROM User where id =:objUser.id];
    System.assertEquals(USER_EMAIL, newUser.Email);
    System.assertEquals(true, newUser.IsActive);
  }

  /**
   * @description Test Builder Method for JIT Handler Update User method negative scenario.
   * * @author Issam Awwad (Deloitte) | 04-15-2021
   * @param N/A
   * @return N/A
   **/
  @isTest private static void testUpdateUserNegativeScenario() {
    final Id samlSsoProviderId = '0LE000000000000';
    final Id communityId = '0DB000000000000';
    final Id portalId = '0DB000000000000';
    final String federationIdentifier = 'federationIdentifier';
    final String USER_EMAIL = 'arfacctcreationtest@arfuserreqjit.com';
    final String XID_FED_IDENTIFIER = 'XIDFedIdentifier';
    final String errorMessage = 'User is not active or not ORR Authorized';
    // clang-format off
    final Map<String, String> attributes = new Map<String, String>{
        'email' => USER_EMAIL,
         'XID' => XID_FED_IDENTIFIER
        };
    // clang-format on
    final String assertion = 'assertion';
    User objUser = setupTestData();
    objUser.federationIdentifier = federationIdentifier;
    objUser.UAC_ORRAuthorizedUser__c = false;
    update objUser;
    string exceptionMsg;
    Test.startTest();
    try {
      UAC_JITHandler handler = new UAC_JITHandler();
      handler.updateUser(objUser.id,
          samlSsoProviderId,
          communityId,
          portalId,
          federationIdentifier,
          attributes,
          assertion);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      exceptionMsg = ex.getMessage();
    }
    Test.stopTest();

    System.assertEquals(errorMessage, exceptionMsg);
  }

  /**
   * @description Test Builder Method for JIT Handler Create User Exception Scenario.
   * * @author Issam Awwad (Deloitte) | 04-15-2021
   * @param N/A
   * @return N/A
   **/
  @isTest private static void testCreateUserNegativeScenarioSecond() {
    final Id samlSsoProviderId = '0LE000000000000';
    final Id communityId = '0DB000000000000';
    final Id portalId = '0DB000000000000';
    final String federationIdentifier = 'federationIdentifier';
    final String USER_EMAIL = 'arfacctcreationtest@arfuserreqjit.com';
    final String USER_INVALID_EMAIL = 'testinvalid@arfuserreqjit.com';
    final String XID_FED_IDENTIFIER = 'XIDFedIdentifier';
    final String errorMessage = 'Federation Ids do not match. Please contact your administrator.';
    // clang-format off
    final Map<String, String> attributes = new Map<String, String>{
        'email' => USER_EMAIL,
         'XID' => XID_FED_IDENTIFIER
        };
    // clang-format on
    final String assertion = 'assertion';
    string exceptionMsg;
    User objUser = setupTestData();
    objUser.federationIdentifier = 'fedIdentifier';
    objUser.UAC_ORRAuthorizedUser__c = true;
    update objUser;
    Test.startTest();
    try {
      UAC_JITHandler handler = new UAC_JITHandler();
      handler.createUser(
          samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      exceptionMsg = ex.getMessage();
    }
    Test.stopTest();
    System.assertEquals(errorMessage, exceptionMsg);
  }
}