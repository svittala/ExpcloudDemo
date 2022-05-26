/**
 * @File Name          : UAC_callLogContactList.cls
 * @Description        : Test Class to test Call Log Functionality
 * @Author             : Chaitanya Nandamuri (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    11/12/2020   Chaitanya Nandamuri (Deloitte)     Initial Version
 **/

@isTest public class UAC_callLogContactListTest {
  private
  static final String STRING_A_NUMBER_PRIMARY = '1111111111';
  private
  static final String STRING_A_NUMBER_SECONDARY = '2222222222';
  private
  static final String STRING_MALE = 'Male';
  private
  static final String UAC_RELATIONSHIP_RECORD_TYPE = 'Family Friend';
  private
  static final String UAC_RELATIONSHIP_API_NAME = 'UAC_apprehendedRelationship__c';
  private
  static final String RELATIONSHIP_BROTHER = 'Brother';
  public
  static final string strTaskCallLog = Label.UAC_taskTypeCallLog;
  public
  static final string str_Language_English = 'English';

  /* @author       Chaitanya Nandamuri
   * @description  Creates the data required to run the test method
   * @param        N/A
   * @return       N/A
   */
  @testSetup static void setupMethod() {

    List<Contact> listUAC = new List<Contact>();
    listUAC.add(new UAC_TestContactBuilder().setANumber(STRING_A_NUMBER_PRIMARY).build());
    listUAC.add(new UAC_TestContactBuilder()
                    .setANumber(STRING_A_NUMBER_SECONDARY)
                    .setGender(STRING_MALE)
                    .build());
    insert listUAC;
  }

  /* @author      Chaitanya Nandamuri
   * @description  Method to verify List of associated ContactRelation List of UAC
   * @param        UAC Id
   * @return       List<Sobject>
   */
  @isTest static void getContactRelationsOfUAC() {

    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    Contact contactSecondary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_SECONDARY, new Set<String>());

    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);

    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();

    objAdultContactRelationship.UAC_relationshipType__c = 'Potential Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = contactPrimary.id;
    objAdultContactRelationship.UAC_contactType__c = 'Authorized';
    objAdultContactRelationship.UAC_contactApprovedDate__c = date.today();
    objAdultContactRelationship.UAC_proofOfRelationship__c = 'No';
    Test.startTest();
    insert objAdultContactRelationship;

    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            contactPrimary.Id, contactSecondary.Id, recordTypeId, RELATIONSHIP_BROTHER, true);
    newRelationship.UAC_contactType__c = 'Restricted';
    newRelationship.UAC_contactRestrictedDate__c = date.today();
    update newRelationship;
    Test.stopTest();
    List<sobject> callLogContactList = UAC_callLogContactList.getContactList(contactPrimary.id);
    system.assertEquals(2, callLogContactList.size());
  }

  /* @author      Chaitanya Nandamuri
   * @description  Method to verify PrimarySpoken of UAC
   * @param        UAC Id
   * @return       List<Sobject>
   */

  @isTest static void getPrimaryLanguageSpoken() {
    Contact contactPrimary =
        UAC_testContactBuilder.getContactByANumber(STRING_A_NUMBER_PRIMARY, new Set<String>());
    contactPrimary.UAC_primaryLanguageSpoken__c = str_Language_English;
    update contactPrimary;

    UAC_callLogContactList.UAC_callLogWrapper CLW =
        UAC_callLogContactList.getCallLogTaskRecordIdandPrimeLan(contactPrimary.id);
    system.assertEquals(Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                            .get(strTaskCallLog)
                            .getRecordTypeId(),
        CLW.TaskCallLogRecordId);
    system.assertEquals(str_Language_English, CLW.strPrimaryLanguageSpoken);
  }
}