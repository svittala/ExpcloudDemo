/**
 * @File Name          : UAC_accountTriggerTest.cls
 * @Description        : Provides test class coverage for Contact Trigger
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_test
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/2/2020   James Qian (Deloitte)     Initial Implementation.
 * 2.0    9/3/2020   Rahul Roy (Deloitte)      ORRUAC-2060 Tests task creation on Subcontractor account creation.
 **/
@isTest public with sharing class UAC_accountTriggerTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  public
  static final String strContactRecordTypeNameSubcontractors = Label.UAC_contactRecordTypeNameSubcontractors;
  public
  static final String strnotificationRecordtypeTask = Label.UAC_notificationRecordtypeTask;
  public
  static final String strTaskSubjectSubcontractorApproval = Label.UAC_taskSubjectSubcontractorApproval;
  private
  static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;
  private
  static final Integer INTEGER_FIELD_MALE_BEDS = 1;
  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final String STRING_PROGRAM_RECORD_NAME = 'UAC_program';
  private
  static final String STRING_ASSERT_SEARCH_TAGS =
      'Search tags should have been set on save of this Program.';
  private
  static final String STRING_SEARCH_TAGS_FEMALE = 'Female Beds Available';
  private
  static final String STRING_SEARCH_TAGS_MALE = 'Male Beds Available';
  private
  static final String STRING_SEARCH_TAGS_NEAR_HOSPITAL = 'Near Hospital';
    
  @TestSetup static void setupData() {
        Contact objUACContact = new UAC_testContactBuilder()
            .setANumber(STR_UAC_CONTACT_A_NUMBER)
            .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
            .buildAndSave();
  } 

  /**
   * @description Tests positive test cases of inserting Program and getting proper search tags.
   */
  @isTest public static void accountInsertionShouldSetSearchTags() {
    Test.startTest();
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .buildAndSave();
    Test.stopTest();
    List<Account> programQueried = queryAccountSearchTags(programToInsert.Id);
    System.assertEquals(1, programQueried.size(), STRING_ASSERT_SEARCH_TAGS);
    System.assert(programQueried[0].UAC_searchTags__c.containsIgnoreCase(STRING_SEARCH_TAGS_FEMALE),
        STRING_ASSERT_SEARCH_TAGS);
    System.assert(
        programQueried[0].UAC_searchTags__c.containsIgnoreCase(STRING_SEARCH_TAGS_NEAR_HOSPITAL),
        STRING_ASSERT_SEARCH_TAGS);
  }

  /**
   * @description Tests positive test cases of updating Program and getting proper search tags.
   */
  @isTest public static void accountUpdateShouldSetSearchTags() {
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                  .setType(STRING_FIELD_TYPE)
                                  .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                  .buildAndSave();
    programToInsert.UAC_bedCountAvailableMale__c = INTEGER_FIELD_MALE_BEDS;
    Test.startTest();
    update programToInsert;
    Test.stopTest();
    List<Account> programQueried = queryAccountSearchTags(programToInsert.Id);
    System.assertEquals(1, programQueried.size(), STRING_ASSERT_SEARCH_TAGS);
    Set<String> searchTagsSplit = new Set<String>();
    searchTagsSplit.addAll(programQueried[0].UAC_searchTags__c.split(', '));
    System.assert(searchTagsSplit.contains(STRING_SEARCH_TAGS_MALE), STRING_ASSERT_SEARCH_TAGS);
  }

  /**
   * @description Queries Account/Search Tags for a given ID
   * @param accountId
   * @return List of Accounts (Collection to handle nulls)
   */
  private
  static List<Account> queryAccountSearchTags(Id accountId) {
    return [
      // clang-format off
        SELECT
          Id,
          UAC_searchTags__c
        FROM
          Account
        WHERE
          Id = :accountId
      // clang-format on
    ];
  }
    
  /**
   * @description Tests task creation on Subcontractor account creation
   * @author Rahul Roy (Deloitte) | 09/03/2020
   * @param 
   */
  @isTest public static void testSubcontractorAccountTaskCreation() {
  
	//User POUser = UAC_TestUtility.CreateUser('Project Officer');
	User HSPRSProviderUser = UAC_TestUtility.CreateUser('HS/PRS Provider');
	HSPRSProviderUser.ManagerId = userinfo.getuserid();// POUser.Id;
	update HSPRSProviderUser;
    Id idTaskNotificationRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
				   .get(strnotificationRecordtypeTask)
				   .getRecordTypeId();

    Contact objUACContact = UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    objUACContact.ownerId=HSPRSProviderUser.id;  
    update objUACContact;
      
    Account programToInsert = new UAC_testAccountBuilder()
                                  .setRecordTypeDeveloperName(strContactRecordTypeNameSubcontractors)
                                  .setType(STRING_FIELD_TYPE)
                                  .build();
    
	programToInsert.ownerId=HSPRSProviderUser.id;
    insert programToInsert;
    Test.startTest();
    programToInsert.UAC_techSubcontractorApproved__c ='Pending';
    update programToInsert;
    System.debug('@@RR programToInsert ' + programToInsert);
	Task  createdTask = [SELECT Id,Status,whatid,OwnerId,Subject FROM Task WHERE whatid =: programToInsert.Id limit 1];
    System.debug('@@RR createdTask ' + createdTask);
    System.AssertNotEquals(createdTask, Null);

    Test.stopTest();
  }
}