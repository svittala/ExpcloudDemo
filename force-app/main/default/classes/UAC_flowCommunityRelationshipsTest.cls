/**
 * @File Name          : UAC_flowCommunityRelationshipsTest.cls
 * @Description        : Test class used for testing Community Cloud relationship controllers
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_services
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 * 1.0    2/12/2021   James Qian (Deloitte) (Deloitte)     Initial Version
 **/
@isTest public class UAC_flowCommunityRelationshipsTest {
  private
  static final String STRING_A_NUMBER_PRIMARY = '111111111';
  private
  static final String STRING_A_NUMBER_SECONDARY = '222222222';

  /**
   * @description Test Setup method to generate test data
   * @return void
   **/
  @testsetup static void setupTestData() {
    Contact objUACContact = new UAC_testContactBuilder()
        .setANumber(STRING_A_NUMBER_PRIMARY)
        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
        .buildAndSave();
    Case objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('New Pending')
                             .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
                             .setUAC(objUACContact.id)
                             .buildAndSave();
  }

  /**
   * @description Tests positive scenario for inserting relationship without contact
   * @return void
   **/
  @isTest static void testApprehendedUACInsertWithoutContact() {
    Case queriedCase = [SELECT Id FROM Case LIMIT 1];
    UAC_flowCommunityManageRelationships.ApprehendedUACRelationship request
        = new UAC_flowCommunityManageRelationships.ApprehendedUACRelationship();
    request.strFirstName = 'UACName';
    request.strLastName = 'UACName2';
    request.strCOB = 'Mexico';
    request.strGender = 'Female';
    request.dateDOB = System.Today().addDays(-3000);
    request.referralID = queriedCase.Id;
    request.strANum = STRING_A_NUMBER_SECONDARY;
    request.strRelationship = 'Sister';
    Test.startTest();
    UAC_flowCommunityManageRelationships.insertApprehendedUAC(new List<UAC_flowCommunityManageRelationships.ApprehendedUACRelationship> {request});
    Test.stopTest();
    System.assertEquals(2, queryApprehendedRelationships().size());
    System.assertEquals(2, queryContacts().size());
  }

  /**
   * @description Tests positive scenario for inserting relationship with contact
   * @return void
   **/
  @isTest static void testApprehendedUACInsertWithContact() {
    Contact objUACContact = new UAC_testContactBuilder()
        .setANumber(STRING_A_NUMBER_SECONDARY)
        .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
        .buildAndSave();
    Case queriedCase = [SELECT Id FROM Case LIMIT 1];
    UAC_flowCommunityManageRelationships.ApprehendedUACRelationship request
        = new UAC_flowCommunityManageRelationships.ApprehendedUACRelationship();
    request.strFirstName = 'UACName';
    request.strLastName = 'UACName2';
    request.strCOB = 'Mexico';
    request.strGender = 'Female';
    request.dateDOB = System.Today().addDays(-3000);
    request.referralID = queriedCase.Id;
    request.strANum = STRING_A_NUMBER_SECONDARY;
    request.strRelationship = 'Sister';
    Test.startTest();
    UAC_flowCommunityManageRelationships.insertApprehendedUAC(new List<UAC_flowCommunityManageRelationships.ApprehendedUACRelationship> {request});
    Test.stopTest();
    System.assertEquals(2, queryApprehendedRelationships().size());
    System.assertEquals(2, queryContacts().size());
  }

  /**
   * @description Tests positive scenario for inserting adult relationship
   * @return void
   **/
  @isTest static void testApprehendedAdultInsert() {
    Case queriedCase = [SELECT Id FROM Case LIMIT 1];
    UAC_flowCommunityManageRelationships.ApprehendedUACRelationship request
        = new UAC_flowCommunityManageRelationships.ApprehendedUACRelationship();
    request.strFirstName = 'UACName';
    request.strLastName = 'UACName2';
    request.strCOB = 'Mexico';
    request.strGender = 'Female';
    request.dateDOB = System.Today().addDays(-3000);
    request.referralID = queriedCase.Id;
    request.strANum = STRING_A_NUMBER_SECONDARY;
    request.strRelationship = 'Sister';
    Test.startTest();
    UAC_flowCommunityInsertAdultRel.insertApprehendedAdult(new List<UAC_flowCommunityManageRelationships.ApprehendedUACRelationship> {request});
    Test.stopTest();
    System.assertEquals(1, queryApprehendedRelationships().size());
    System.assertEquals(1, queryContacts().size());
  }

  /**
   * @description Tests positive scenario for inserting relationship without contact
   * @return void
   **/
  @isTest static void testAdultContactInsertWithoutContact() {
    Case queriedCase = [SELECT Id FROM Case LIMIT 1];
    UAC_flowCommunityInsertAdultCon.AdultContactRelationship request
        = new UAC_flowCommunityInsertAdultCon.AdultContactRelationship();
    request.strFirstName = 'ACName';
    request.strLastName = 'ACName2';
    request.strPhone = '123123123';
    request.strAddress = '123 test street';
    request.referralID = queriedCase.Id;
    request.strANum = STRING_A_NUMBER_SECONDARY;
    request.strRelationship = 'Sister';
    Test.startTest();
    UAC_flowCommunityInsertAdultCon.insertAdultContactRelationship(new List<UAC_flowCommunityInsertAdultCon.AdultContactRelationship> {request});
    Test.stopTest();
    System.assertEquals(1, queryAdultRelationships().size());
    System.assertEquals(2, queryContacts().size());
  }

  /**
   * @description Tests positive scenario for inserting relationship with contact
   * @return void
   **/
  @isTest static void testAdultContactInsertWithContact() {
    Case queriedCase = [SELECT Id FROM Case LIMIT 1];
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setANumber(STRING_A_NUMBER_SECONDARY)
            .setEmail(STRING_A_NUMBER_SECONDARY + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .buildAndSave();
    UAC_flowCommunityInsertAdultCon.AdultContactRelationship request
        = new UAC_flowCommunityInsertAdultCon.AdultContactRelationship();
    request.strFirstName = 'ACName';
    request.strLastName = 'ACName2';
    request.strPhone = '123123123';
    request.strAddress = '123 test street';
    request.referralID = queriedCase.Id;
    request.strANum = STRING_A_NUMBER_SECONDARY;
    request.strRelationship = 'Sister';
    Test.startTest();
    UAC_flowCommunityInsertAdultCon.insertAdultContactRelationship(new List<UAC_flowCommunityInsertAdultCon.AdultContactRelationship> {request});
    Test.stopTest();
    System.assertEquals(1, queryAdultRelationships().size());
    System.assertEquals(2, queryContacts().size());
  }

  /**
   * @description Queries for test method
   * @return void
   **/
  private static List<UAC_apprehendedRelationship__c> queryApprehendedRelationships() {
    return [SELECT Id FROM UAC_apprehendedRelationship__c];
  }

  /**
   * @description Queries for test method
   * @return void
   **/
  private static List<UAC_adultContactRelationship__c> queryAdultRelationships() {
    return [SELECT Id FROM UAC_adultContactRelationship__c];
  }

  /**
   * @description Queries for test method
   * @return void
   **/
  private static List<Contact> queryContacts() {
    return [SELECT Id FROM Contact];
  }
}