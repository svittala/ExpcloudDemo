/**
 * @File Name          : UC_ACFAuthenticationHandlerTest.cls
 * @Description        : Test class class for creating User Record for unit test ACF Handler.
 * @Author             : Karthi Subramanian
 * @Group              : 
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 04-28-2021
 * @Modification Log   :
 * Ver       Date            Author                         Modification
 * 1.0    03/26/2021    Karthi Subramanian (Deloitte)       Initial Version
 * 1.1    04/28/2021    Karthi Subramanian (Deloitte)       updated PortalId value default definition in test methods 
 **/
@isTest
public with sharing class UC_ACFAuthenticationHandlerTest {
    
    
    public static User setupTestData() {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name ='MyTrailhead' LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFGenUser';
    objUser.LastName = 'ARFGenUserLast';
    objUser.Alias = 'ARFGenUser'.substring(0, 1) + 'ARFGenUserLast'.substring(0, 4);
    objUser.Email = 'arfacctcreationtest@arfuserreqacfauth.com';
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
     * @description Test Builder Method for ACF Handler Create User method.
     * * @author Karthi Subrmanian (Deloitte) | 03-26-2021
     * @param N/A
     * @return N/A
  **/
  @isTest 
  private static void testCreateUser() {
      Id portalId;
      final String USER_EMAIL = 'arfacctcreationtest@arfuserreqacfauth.com';
      final String HHSID_IDENTIFIER = '9884411857';
      Auth.UserData sampleUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
      'testFirst testLast', USER_EMAIL, null, 'testuserlong', 'en_US', 'testSite',
      null, new Map<String, String>{'hhsid' => HHSID_IDENTIFIER});
      User objUser =  setupTestData();//new UC_testUserBuilder().buildUserWithORRFlagACFAuth(USER_EMAIL,HHSID_IDENTIFIER);
      Test.startTest();
      UAC_ACFAuthenticationHandler handler = new UAC_ACFAuthenticationHandler();
      handler.createUser(portalId,sampleUserData);
      Test.stopTest();

      // Select more fields and do more assertions than this
      User newUser = [SELECT Email, IsActive, UAC_ACFHHSID__c FROM User where id =: objUser.id];
      System.assertEquals(USER_EMAIL, newUser.Email);
      System.assertEquals(true, newUser.IsActive);
      System.assertEquals(HHSID_IDENTIFIER, newUser.UAC_ACFHHSID__c);
  }
  /**
     * @description Test Builder Method for ACF Handler Update User method.
     * * @author Karthi Subrmanian (Deloitte) | 03-26-2021
     * @param N/A
     * @return N/A
  **/
  @isTest 
  private static void testUpdateUser() {
      Id portalId;
      final String USER_EMAIL = 'arfacctcreationtest@arfuserreqacfauth.com';
      final String HHSID_IDENTIFIER = '9884411857';
      Auth.UserData sampleUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
      'testFirst testLast', USER_EMAIL, null, 'testuserlong', 'en_US', 'testSite',
      null, new Map<String, String>{'hhsid' => HHSID_IDENTIFIER});
      User objUser =  setupTestData();//new UC_testUserBuilder().buildUserWithORRFlagACFAuth(USER_EMAIL,HHSID_IDENTIFIER);
      Test.startTest();
      UAC_ACFAuthenticationHandler handler = new UAC_ACFAuthenticationHandler();
      handler.updateUser(objUser.id,portalId,sampleUserData);
      Test.stopTest();

      // Select more fields and do more assertions than this
      User newUser = [SELECT Email, IsActive, UAC_ACFHHSID__c FROM User where id =: objUser.id];
      System.assertEquals(USER_EMAIL, newUser.Email);
      System.assertEquals(true, newUser.IsActive);
      System.assertEquals(HHSID_IDENTIFIER, newUser.UAC_ACFHHSID__c);
  }
  /**
     * @description Test Builder Method for ACF Handler Create User method with blank email.
     * * @author Karthi Subrmanian (Deloitte) | 03-26-2021
     * @param N/A
     * @return N/A
  **/
  @isTest 
  private static void testCreateUserNegativeScenario() {
      Id portalId;
      final String USER_EMAIL = 'arfacctcreationtest@arfuserreqacfauth.com';
      final String HHSID_IDENTIFIER = '9884411857';
      Auth.UserData sampleUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
      'testFirst testLast', null, null, 'testuserlong', 'en_US', 'testSite',
      null, new Map<String, String>{'hhsid' => HHSID_IDENTIFIER});
      User objUser =  setupTestData();//new UC_testUserBuilder().buildUserWithORRFlagACFAuth(USER_EMAIL,HHSID_IDENTIFIER);
      Test.startTest();
      UAC_ACFAuthenticationHandler handler = new UAC_ACFAuthenticationHandler();
      handler.createUser(portalId,sampleUserData);
      Test.stopTest();

      // Select more fields and do more assertions than this
      User newUser = [SELECT Email, IsActive, UAC_ACFHHSID__c FROM User where id =: objUser.id];
      System.assertEquals(USER_EMAIL, newUser.Email);
      System.assertEquals(true, newUser.IsActive);
      System.assertEquals(HHSID_IDENTIFIER, newUser.UAC_ACFHHSID__c);
  }
  /**
     * @description Test Builder Method for ACF Handler Create User method with blank email.
     * * @author Karthi Subrmanian (Deloitte) | 03-26-2021
     * @param N/A
     * @return N/A
  **/
/*  @isTest 
  private static void testCreateUserNegativeScenarioTwo() {
      Id portalId;
      final String USER_EMAIL = 'arfacctcreationtest@arfuserreqacfauth.com';
      final String INCORRECT_USER_EMAIL = 'arfacctcreationincorrect@arfuserreqacfauth.com';
      final String HHSID_IDENTIFIER = '9884411857';
      final String INCORRECT_HHSID_IDENTIFIER = '8884411857';      
      Auth.UserData sampleUserData = new Auth.UserData('testId', 'testFirst', 'testLast',
      'testFirst testLast', USER_EMAIL, null, 'testuserlong', 'en_US', 'testSite',
      null, new Map<String, String>{'hhsid' => INCORRECT_HHSID_IDENTIFIER});
      User objUser =  setupTestData();//new UC_testUserBuilder().buildUserWithORRFlagACFAuth(USER_EMAIL,HHSID_IDENTIFIER);
      Test.startTest();
      UAC_ACFAuthenticationHandler handler = new UAC_ACFAuthenticationHandler();
      handler.createUser(portalId,sampleUserData);
      Test.stopTest();

      // Select more fields and do more assertions than this
      User newUser = [SELECT Email, IsActive, UAC_ACFHHSID__c FROM User where id =: objUser.id];
      System.assertEquals(USER_EMAIL, newUser.Email);
      System.assertEquals(true, newUser.IsActive);
      System.assertNotEquals(INCORRECT_HHSID_IDENTIFIER, newUser.UAC_ACFHHSID__c);
  }  */

  
}