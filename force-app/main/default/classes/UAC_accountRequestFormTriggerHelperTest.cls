/**
 * @File Name          : UAC_accountRequestFormTriggerHelperTest.cls
 * @Description        : Helper method for UAC_accountRequestFormTriggerHelper
 * @Author             : Abhisek Pati (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   :
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    01-26-2021   Abhisek Pati (Deloitte)        Initial Implementation.
 * 1.1    03-19-2021   Karthi Subramanian (Deloitte)  Added Test methods.
 * 1.2    03-25-2021   Nithin Malla (Deloitte)        Updated Test methods.
 **/

@isTest(seeAllData = false) public class UAC_accountRequestFormTriggerHelperTest {

  private
  static final String strARFServiceCloudRecordType = Label.UC_serviceCloudRecordTypeARF;

  /**
   * @description create User from Account Request Form and Update the User Map
   * count.
   */
  @isTest static void createUsertest() {
    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFUser';
    objARF.Last_Name__c = 'SampleUser';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.com';
    objARF.UAC_Status__c = 'Initiate Form Completion Request';
    insert objARF;

    Test.startTest();
    objARF.UAC_Status__c = Label.UAC_arfStatusApproved;
    update objARF;
    Test.stopTest();
    UAC_AccountRequestForm__c objARFQuery =
        [SELECT Id, User_map__c FROM UAC_AccountRequestForm__c WHERE Id =:objARF.Id];
    System.assertNOTEquals(null, objARFQuery.User_map__c);
  }

  /**
   * @description Test Method to create Account request form records and test negative scenario
   * @author Karthi Subramanian (Deloitte)
   * @return void
   **/
  @isTest static void createUserNegativeScenariotest() {
    Test.startTest();
    Profile objProfile = [SELECT Id FROM Profile WHERE Name =:Label.UAC_myTrailhead LIMIT 1];
    User objUser = new User();
    // Add User Information
    objUser.FirstName = 'ARFUser';
    objUser.LastName = 'SampleUser';
    objUser.Alias = 'ARFUser'.substring(0, 1) + 'SampleUser'.substring(0, 4);
    objUser.Email = 'arfacctcreation@arfuserreq.com';
    objUser.Username = 'arfacctcreation@arfuserreq.com' + Label.UAC_arfUsernameExtension;
    objUser.ProfileId = objProfile.id;
    objUser.TimeZoneSidKey = 'America/New_York';
    objUser.LanguageLocaleKey = 'en_US';
    objUser.EmailEncodingKey = 'ISO-8859-1';
    objUser.LocaleSidKey = 'en_US';
    objUser.UserPermissionsSupportUser = true;
    objUser.UserPermissionsInteractionUser = true;
    objUser.UAC_ORRAuthorizedUser__c = true;
    insert objUser;
    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFUser';
    objARF.Last_Name__c = 'SampleUser';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.com';
    objARF.UAC_Status__c = 'Initiate Form Completion Request';
    insert objARF;
    objARF.UAC_Status__c = Label.UAC_arfStatusApproved;
    update objARF;
    Test.stopTest();
    UAC_AccountRequestForm__c objARFQuery =
        [SELECT Id, User_map__c FROM UAC_AccountRequestForm__c WHERE Id =:objARF.Id];
    System.assertEquals(null, objARFQuery.User_map__c);
  }

  /**
   * @description Test Method to test user type setting
   * @author Issam Awwad (Deloitte)
   * @return void
   **/
  @isTest static void testsetUserType() {
    Id idRecordType =
        Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosByDeveloperName()
            .get(strARFServiceCloudRecordType)
            .getRecordTypeId();

    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFUser';
    objARF.Last_Name__c = 'SampleUser';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.gov';
    objARF.RecordTypeId = idRecordType;
    insert objARF;
    objARF = [SELECT UC_userType__c FROM UAC_AccountRequestForm__c LIMIT 1];
    System.assertEquals(Label.UC_accountRequestFormInternalUserType, objARF.UC_userType__c);
  }
  /**
   * @description Test Method to test user type setting Grantee
   * @author Issam Awwad (Deloitte)
   * @return void
   **/
  @isTest static void testsetUserTypeGrantee() {
    Id idRecordType =
        Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosByDeveloperName()
            .get(strARFServiceCloudRecordType)
            .getRecordTypeId();

    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFUser';
    objARF.Last_Name__c = 'SampleUser';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.com';
    objARF.UAC_Status__c = 'Rejected';
    objARF.RecordTypeId = idRecordType;
    insert objARF;
    objARF = [SELECT UC_userType__c FROM UAC_AccountRequestForm__c LIMIT 1];
    System.assertEquals(Label.UC_accountRequestFormGranteeUserType, objARF.UC_userType__c);
  }
  /**
   * @description Test Method to test Status update for Existing Internal User Type
   * @author Karthi Subramanian (Deloitte)
   * @return void
   **/
  @isTest static void testStatusUpdExistingInternalUser() {
    Id idRecordType =
        Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosByDeveloperName()
            .get(strARFServiceCloudRecordType)
            .getRecordTypeId();

    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFExistingInternalUser';
    objARF.Last_Name__c = 'Existing Internal Last Name';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.gov';
    objARF.UC_existingUser__c = true;
    objARF.UAC_Status__c='In Progress';
    objARF.RecordTypeId = idRecordType;
    objARF.User_Profile__c = 'FFS';
    insert objARF;
    Test.startTest();
    objARF.UAC_ROB_Uploaded__c=true;
    update objARF;
    UAC_AccountRequestForm__c objARFTest = [SELECT UAC_Status__c FROM UAC_AccountRequestForm__c where id =:objARF.id];
    Test.stopTest();
    System.assertEquals(Label.UC_accountRequestFormIFCRStatus, objARFTest.UAC_Status__c);
  }
  /**
   * @description Test Method to test Status update for Existing Grantee User Type
   * @author Karthi Subramanian (Deloitte)
   * @return void
   **/
  @isTest static void testStatusUpdExistingGranteeUser() {
    Id idRecordType =
        Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosByDeveloperName()
            .get(strARFServiceCloudRecordType)
            .getRecordTypeId();

    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFExistingGranteeUser';
    objARF.Last_Name__c = 'Existing Grantee Last Name';
    objARF.User_Email__c = 'arfacctcreation@testarfdev.com';
    objARF.UC_existingUser__c = true;
    objARF.UAC_Status__c='In Progress';
    objARF.UAC_ROB_Uploaded__c=false;
    objARF.UAC_Privacy_101_Uploaded__c=false;
    objARF.UAC_Cyber_Security_Uploaded__c=false;    
    objARF.RecordTypeId = idRecordType;
    objARF.User_Profile__c = 'FFS';
    insert objARF;
    Test.startTest();
    objARF.UAC_ROB_Uploaded__c=true;
    objARF.UAC_Privacy_101_Uploaded__c=true;
    objARF.UAC_Cyber_Security_Uploaded__c=true;
    update objARF;
    UAC_AccountRequestForm__c objARFTest = [SELECT UAC_Status__c FROM UAC_AccountRequestForm__c where id =:objARF.id];
    Test.stopTest();
    System.assertEquals(Label.UC_accountRequestFormIFCRStatus, objARFTest.UAC_Status__c);
  }
  /**
   * @description Test Method to Update ORRAuth User Flag for Existing Grantee User Type
   * @author Karthi Subramanian (Deloitte)
   * @return void
   **/
  @isTest static void testUserUpdExistingGranteeUser() {
    Id idRecordType =
        Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosByDeveloperName()
            .get(strARFServiceCloudRecordType)
            .getRecordTypeId();
    User objUser = new UC_testUserBuilder().buildAndSave();
    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFExistingGranteeUser';
    objARF.Last_Name__c = 'Existing Grantee Last Name';
    objARF.User_Email__c = 'arfacctcreation@testarfdev.com';
    objARF.UC_existingUser__c = true;
    objARF.UAC_Status__c='In Progress';
    objARF.UAC_ROB_Uploaded__c=false;
    objARF.UAC_Privacy_101_Uploaded__c=false;
    objARF.UAC_Cyber_Security_Uploaded__c=false;  
    objARF.RecordTypeId = idRecordType;
    insert objARF;
    Test.startTest();
    objARF.User_map__c=objUser.Id;
    objARF.UAC_Privacy_101_Uploaded__c=true;
    objARF.UAC_Cyber_Security_Uploaded__c=true;    
    objARF.UAC_ROB_Uploaded__c=true;
    update objARF;
    Test.stopTest();
    User objUserUpd = [Select Id, UAC_ORRAuthorizedUser__c from User where id =:objUser.Id];

    System.assertEquals(true, objUserUpd.UAC_ORRAuthorizedUser__c);
  }
  /**
   * @description Test Method to Update ORRAuth User Flag for Existing Internal User Type
   * @author Karthi Subramanian (Deloitte)
   * @return void
   **/
  @isTest static void testUserUpdExistingInternalUser() {
    Id idRecordType =
        Schema.SObjectType.UAC_AccountRequestForm__c.getRecordTypeInfosByDeveloperName()
            .get(strARFServiceCloudRecordType)
            .getRecordTypeId();
    User objUser = new UC_testUserBuilder().buildAndSave();
    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFExistingInternalUser';
    objARF.Last_Name__c = 'Existing Internal Last Name';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.gov';
    objARF.UC_existingUser__c = true;
    objARF.UAC_Status__c='In Progress';
    objARF.UAC_ROB_Uploaded__c=false;
    objARF.UAC_Privacy_101_Uploaded__c=false;
    objARF.UAC_Cyber_Security_Uploaded__c=false;  
    objARF.RecordTypeId = idRecordType;
    insert objARF;
    Test.startTest();
    objARF.User_map__c=objUser.Id;
    objARF.UAC_ROB_Uploaded__c=true;
    update objARF;
    Test.stopTest();
    User objUserUpd = [Select Id, UAC_ORRAuthorizedUser__c from User where id =:objUser.Id];

    System.assertEquals(true, objUserUpd.UAC_ORRAuthorizedUser__c);
  }     
}