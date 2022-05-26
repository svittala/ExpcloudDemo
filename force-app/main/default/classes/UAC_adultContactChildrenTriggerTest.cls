/**
 * @File Name          : UAC_adultContactChildrenTriggerTest.cls
 * @Description        : Test class for UAC_adultContactChildren.trigger,
 *UAC_adultContactChildrenTriggerHandler.cls, UAC_adultContactChildrenTriggerHelper.cls
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2/1/2021   Issam Awwad (Deloitte)     Initial Version
 **/
@isTest(seeAllData = false) public without sharing class UAC_adultContactChildrenTriggerTest {
  static final String STR_A_NUM_ADULT_CONTACT = '123456';
  static final String STR_A_NUM_ADULT_CONTACT_2 = '1234567';
  static final String STR_A_NUM_UAC = '1234';
  static final String STR_A_NUM_UAC_2 = '2345';
  public
  static final String strErrorMessage = Label.UAC_errorMessageForAdultContactChildrenParent;
  private
  static final string strPendingAdmissionStatus = 'Pending Admission';

  /* @author     Issam Awwad
   * @description  Creates the data required to run the test method
   * @param        N/A
   * @return       N/A
   */
  @testSetup static void setupMethod() {
    list<contact> lstContacts = new list<contact>();
    list<UAC_adultContactRelationship__c> lstAdultContRelationshp =
        new list<UAC_adultContactRelationship__c>();
    Contact objAdultContact =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT)
            .build();
    Contact objAdultContact2 =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT_2)
            .build();
    Contact objUAC = new UAC_testContactBuilder()
                         .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                         .setANumber(STR_A_NUM_UAC)
                         .build();
    Contact objUAC2 = new UAC_testContactBuilder()
                          .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                          .setANumber(STR_A_NUM_UAC_2)
                          .build();
    insert new List<Contact>{objAdultContact, objAdultContact2, objUAC, objUAC2};

    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objAdultContact2.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Potential Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUAC.id;
    UAC_adultContactRelationship__c objAdultContactRelationship2 =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship2.UAC_adultContact__c = objAdultContact.id;
    objAdultContactRelationship2.UAC_relationshipType__c = 'Potential Sponsor';
    objAdultContactRelationship2.UAC_relationshipToUAC__c = 'Grandfather';
    objAdultContactRelationship2.UAC_uacLookup__c = objUAC.id;
    insert new List<UAC_adultContactRelationship__c>{
        objAdultContactRelationship, objAdultContactRelationship2};
  }

  /**
   * @author      Issam Awwad
   * @description  Test insert of adult contact children with child that is not in orr care
   * @param        N/A
   * @return       N/A
   */
  @isTest static void adultContactChildrenNotInORRTest() {
    Set<String> fieldsToQuery = new Set<String>{'Id'};

    Contact objUAC = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, fieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_2, fieldsToQuery);
    Test.startTest();
    UAC_adultContactsChildren__c objADC = new UAC_adultContactsChildren__c();
    objADC.UAC_adultContact__c = objAdultContact.Id;
    objADC.UAC_child__c = objUAC.Id;
    try {
      insert objADC;
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage().contains(strErrorMessage) ? true : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }
    Test.stopTest();
  }
  /**
   * @author      Issam Awwad
   * @description  Test insert of adult contact children with father
   * @param        N/A
   * @return       N/A
   */
  @isTest static void adultContactChildrenWithFatherTest() {
    Set<String> fieldsToQuery = new Set<String>{'Id'};

    Contact objUAC = UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, fieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_2, fieldsToQuery);
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus(strPendingAdmissionStatus)
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(objUAC.id)
            .buildAndSave();
    Test.startTest();
    UAC_adultContactsChildren__c objADC = new UAC_adultContactsChildren__c();
    objADC.UAC_adultContact__c = objAdultContact.Id;
    objADC.UAC_child__c = objUAC.Id;
    insert objADC;
    objADC = [SELECT Id FROM UAC_adultContactsChildren__c LIMIT 1];
    System.assertNotEquals(null, objADC);
    Test.stopTest();
  }
}