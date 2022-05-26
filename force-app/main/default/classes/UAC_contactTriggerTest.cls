/**
 * @File Name          : UAC_contactTriggerTest.cls
 * @Description        : Provides test class coverage for Contact Trigger
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/29/2020, 3:07:46 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/13/2020   James Qian (Deloitte)     Initial Implementation.
 * 1.1    6/23/2020   Abhisek Pati (Deloitte)   Added test method testPopulateANumOnCases.
 * 1.2    7/29/2020   Anupreeta Chakraborty (Deloitte)   Added test method testCreateIMEonStatusAdmitted. 
 * 1.3    3/18/2021   Nithin Malla (Deloitte)   ORRUAC-5561: Updated test methods to handle asyc approach
 **/
@isTest(seeAllData = false) public without sharing class UAC_contactTriggerTest {
  private
  static final String STRING_A_NUMBER_PRIMARY = '111111111';
  private
  static final String STRING_A_NUMBER_SECONDARY = '222222222';
  private
  static final String STRING_YES = 'Yes';
  private
  static final String STRING_ASSERT_POSITIVE_NEW =
      'An Account should have been created and assigned to this Contact.';
  private
  static final String STRING_ASSERT_POSITIVE_ADMINISTRATIVE_ACCOUNT =
      'An administrative account should have been assigned to this Contact.';

  /**
   * @description Method to setup required data for test instance
   * @author Sachet Khanal (Deloitte) | 5/29/2020
   * @return void
   **/
  @TestSetup static void setupData() {
    UAC_appSettingsService.setAppSettings();
  }

  /**
   * @description Method to test auto-population of administrative account for Adult Contacts
   * @author Sachet Khanal (Deloitte) | 5/29/2020
   * @return void
   **/
  @isTest static void adultContactCreationShouldPopulateAdministrativeAccount() {
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setANumber(STRING_A_NUMBER_PRIMARY)
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .build();
    UAC_accountSettings__c objAccountSettings = UAC_accountSettings__c.getOrgDefaults();
    Test.startTest();
    insert objAdultContact;
    Test.stopTest();
    objAdultContact = UAC_testContactBuilder.getContactByANumber(
        STRING_A_NUMBER_PRIMARY, new Set<String>{'AccountId'});
    System.assertEquals(objAccountSettings.UAC_administrativeAccountId__c,
        objAdultContact.AccountId,
        STRING_ASSERT_POSITIVE_ADMINISTRATIVE_ACCOUNT
            + 'Test method: adultContactCreationShouldPopulateAdministrativeAccount() failed.');
  }

  /**
   * @description Tests for positive scenarios of creating a new Account on Contact insert.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void contactCreationShouldCreateAccount() {
    Test.startTest();
    Contact contactNewUAC =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).buildAndSave();
    Test.stopTest();
    List<Account> lstAccountForAssertion = getAccountFromANumber(STRING_A_NUMBER_PRIMARY);
    Contact contactForAssertion = UAC_testContactBuilder.getContactByANumber(
        STRING_A_NUMBER_PRIMARY, new Set<String>{'AccountId'});
    System.assertEquals(1, lstAccountForAssertion.size(), STRING_ASSERT_POSITIVE_NEW);
    System.assertEquals(
        lstAccountForAssertion[0].Id, contactForAssertion.AccountId, STRING_ASSERT_POSITIVE_NEW);
  }

  /**
   * @description Tests for positive scenarios of updating a Contact if an existing Account is
   * found.
   * @author James Qian (Deloitte) | 5/13/2020
   * @return void
   **/
  @isTest static void contactCreationShouldAssignExistingRelatedAccount() {
    Contact contactNewUAC =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_SECONDARY).build();
    contactNewUAC.UAC_uipFamilyGroupNumber__c = '123';
    insert contactNewUAC;
    Test.startTest();
    Contact contactExistingUAC = new UAC_TestContactBuilder()
                                     .setANumber(STRING_A_NUMBER_PRIMARY)
                                     .setRelatedANum(STRING_A_NUMBER_SECONDARY)
                                     .setRelatedToOtherUAC(STRING_YES)
                                     .build();
    contactExistingUAC.UAC_uipFamilyGroupNumber__c = '123';
    insert contactExistingUAC;
    Test.stopTest();
    List<Account> lstAccountForAssertion = getAccountFromANumber(STRING_A_NUMBER_SECONDARY);
    Contact contactForAssertion = UAC_testContactBuilder.getContactByANumber(
        STRING_A_NUMBER_PRIMARY, new Set<String>{'AccountId'});
    System.assertEquals(1, lstAccountForAssertion.size(), STRING_ASSERT_POSITIVE_NEW);
    System.assertEquals(
        lstAccountForAssertion[0].Id, contactForAssertion.AccountId, STRING_ASSERT_POSITIVE_NEW);
  }

  /**
   * @description Query method to get an Account from an A Number
   * @author James Qian (Deloitte) | 5/13/2020
   * @return List<Account>
   **/
  private
  static List<Account> getAccountFromANumber(String strANumber) {
    return [
      // clang-format off
        SELECT
          Id
        FROM
          Account
        WHERE
          UAC_A__c = :strANumber
      // clang-format on
    ];
  }
   /**
   * @description Method to test update Salutation value
   * @author Priyanka Bolla(Deloitte) | 6/03/2020
   * @return void
   **/
  @isTest static void updateSalutation() {
      
    Test.startTest();
    Contact contactNewUAC =
         new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_SECONDARY).build();
    
     contactNewUAC.Salutation = 'None';
       insert contactNewUAC;
      Test.stopTest();
       Contact contactForAssertion = UAC_testContactBuilder.getContactByANumber(
         contactNewUAC.UAC_A__c, new Set<String>{'Salutation'});
       System.AssertEquals(null,contactForAssertion.Salutation);
   }
 
   /**
    * @description Method to test update Salutation value on Insert
    * @author Priyanka Bolla(Deloitte) | 6/03/2020
    * @return void
    **/
    @isTest static void updateSalutationoOnUpdate() {
       
    Test.startTest();
    Contact contactNewUAC =
         new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_SECONDARY).buildAndSave();
    
     contactNewUAC.Salutation = 'None';
       Update contactNewUAC;
      
      Test.stopTest();
       Contact contactForAssertion = UAC_testContactBuilder.getContactByANumber(
         contactNewUAC.UAC_A__c, new Set<String>{'Salutation'});
       System.AssertEquals(null,contactForAssertion.Salutation);
    
   }

   /**
   * @description Method to test update A# value
   * @author Abhisek Pati (Deloitte) | 6/23/2020
   * @return void
   **/
  @isTest static void testPopulateANumOnCases() {

    Contact contactNewUAC =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).buildAndSave();

    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('New Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(contactNewUAC.id)
            .buildAndSave();

    Test.startTest();
    contactNewUAC.UAC_A__c = STRING_A_NUMBER_SECONDARY;
    Update contactNewUAC;
    Case objUACReferralCaseUpdated =
        [select id, UAC_aNum__c from case where id =:objUACReferralCase.id];
    Test.stopTest();

    System.AssertEquals(contactNewUAC.UAC_A__c, objUACReferralCaseUpdated.UAC_aNum__c);
  }
  
      /**
   * @description Method to test IME creation
   * @author Anupreeta Chakraborty(Deloitte) | 7/29/2020
   * @return void
   **/
   @isTest static void testCreateIMEonStatusAdmitted() {
       
    String strIMERecordType = System.label.UAC_IMERectype;           
    Contact contactNewUAC =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).buildAndSave();
    
    Test.startTest();
    contactNewUAC.UAC_status__c = Label.UAC_placementDesignatedContactStatus;
    Update contactNewUAC;
    contactNewUAC.UAC_status__c = Label.UAC_admittedContactStatus;
    Update contactNewUAC;

    //Added by Nithin for ORRUAC-5561 to handle asyc approach
    UAC_asyncStatusAdmittedService.handleStatusUpdates(new set<Id>{contactNewUAC.id},new Set<Id>(),new Set<Id>());
    
    UAC_healthEvaluation__c objIME = [select id, recordtype.developerName from UAC_healthEvaluation__c where UAC_associatedUAC__c = :contactNewUAC.id and recordtype.developerName =: strIMERecordType];

    Test.stopTest();
      
    System.AssertNotEquals(objIME, null);
   
  }
  @isTest static void testcreateLegalStatusonStatusAdmitted() {
       
    Contact contactNewUAC =
         new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).buildAndSave();
     
     Test.startTest();
     contactNewUAC.UAC_status__c = Label.UAC_placementDesignatedContactStatus;
     Update contactNewUAC;
     contactNewUAC.UAC_status__c = Label.UAC_admittedContactStatus;
     Update contactNewUAC;
   contactNewUAC.UAC_status__c = Label.UAC_placementDesignatedContactStatus;
     Update contactNewUAC;
     contactNewUAC.UAC_status__c = Label.UAC_admittedContactStatus;
     Update contactNewUAC;  
     
     //Added by Nithin for ORRUAC-5561 to handle asyc approach
     UAC_asyncStatusAdmittedService.handleStatusUpdates(new Set<Id>(),new Set<Id>(),new set<Id>{contactNewUAC.id});
      
    
     System.assertEquals( contactNewUAC.UAC_status__c , Label.UAC_admittedContactStatus);
    test.stopTest();

       
     //System.AssertNotEquals(objIME, null);
    
   } 
 /**
   * @author Ankur Aggarwal (Deloitte)
   * @return void
   **/
  @isTest static void assignOwnerHSPRSContractortest() {
    Account programToInsert = new UAC_testAccountBuilder()
                            .setRecordTypeDeveloperName('UAC_program')
                            .setType('Secure')
                            .setFemaleBeds(1)
                            .buildAndSave();
    Account objAdministrativeAccount =
      new UAC_testAccountBuilder()
          .setRecordTypeDeveloperName('UAC_HSPRSSubcontractors')
          .buildAndSave();
    objAdministrativeAccount.UAC_techSubcontractorApproved__c  = 'True';
    objAdministrativeAccount.UAC_approvalStatus__c = 'Approved';
    update objAdministrativeAccount;
    Contact objAdultContact =
      new UAC_testContactBuilder()
          .setANumber(STRING_A_NUMBER_PRIMARY)
          .setRecordTypeDeveloperName(label.UAC_HSPRSSubcontractors)
          .build();
    objAdultContact.UAC_subcontractor__c = objAdministrativeAccount.id;
    objAdultContact.OwnerId = userinfo.getUserId();
    objAdultContact.UAC_userName__c = userinfo.getUserId();

    insert objAdultContact;
	test.startTest();
    objAdultContact.UAC_status__c = Label.UAC_admittedContactStatus;
    update objAdultContact; 
    objAdultContact.UAC_program__c = programToInsert.id;
    update objAdultContact;
	System.assertEquals( objAdultContact.UAC_status__c , Label.UAC_admittedContactStatus);
    test.stopTest();

    }

      /**
   * @description Method to test Initial Mental Health Evaluatio record creation
   * @author Anupreeta Chakraborty(Deloitte) | 10/08/2020
   * @return void
   **/
   @isTest static void createInitialMentalHEonStatusAdmittedTest() {
   String strIMHERecordType = System.label.UAC_healthEvaluationRecordTypeApiNameInitialMental;
   Contact contactNewUAC =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).buildAndSave();    
    Test.startTest();
    contactNewUAC.UAC_status__c = Label.UAC_admittedContactStatus;
    Update contactNewUAC;

    //Added by Nithin for ORRUAC-5561 to handle asyc approach  
    UAC_asyncStatusAdmittedService.handleStatusUpdates(new Set<Id>(),new set<Id>{contactNewUAC.id},new Set<Id>());
      
    UAC_healthEvaluation__c objIMHE = [select id, recordtype.developerName from UAC_healthEvaluation__c where UAC_associatedUAC__c = :contactNewUAC.id and recordtype.developerName =: strIMHERecordType];
    Test.stopTest();
      
    System.AssertNotEquals(objIMHE, null);
   
  }

  /**
   * @description Method to test updating child Account IDs on parent Contact update
   * @author James Qian (Deloitte) | 11/6/2020
   * @return void
   **/
  @isTest static void updateContactAccountIdShouldUpdateChildCases() {
    List<Contact> listContacts = new List<Contact>();
    Contact contactNewUAC1 =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).build();
    Contact contactNewUAC2 =
        new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_SECONDARY).build();
    listContacts.add(contactNewUAC1);
    listContacts.add(contactNewUAC2);
    insert listContacts;
    Test.startTest();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('New Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(contactNewUAC1.Id)
            .buildAndSave();
    Account accountUAC2Queried = getAccountFromANumber(STRING_A_NUMBER_SECONDARY)[0];
    update new Contact(Id = contactNewUAC1.Id, AccountId = accountUAC2Queried.Id);
    Test.stopTest();
    Case objReferralQueried = [SELECT Id, AccountId FROM Case WHERE Id =:objUACReferralCase.Id];
    System.assertEquals(accountUAC2Queried.Id, objReferralQueried.AccountId);
  }

  /**
   * @description Method to test async Status Admitted Exception
   * @author Nithin Malla (Deloitte) | 03/19/2021
   * @return void
   **/  
  @isTest static void asyncStatusAdmittedFailureTest() {
      
    Test.startTest();
    new UAC_asyncStatusAdmittedCreation(new Set<Id>(),null,new Set<Id>()).execute(null);
    Test.stopTest();
    
    UAC_errorLog__c errRec= [Select Id,UAC_errorOrigin__c from UAC_errorLog__c];
    System.assertEquals(errRec.UAC_errorOrigin__c,'Handling Status Admitted records Creation');
    System.AssertNotEquals(errRec, null);
  }
}