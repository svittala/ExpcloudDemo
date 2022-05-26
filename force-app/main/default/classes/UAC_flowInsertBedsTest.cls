/**
 * @File Name         : UAC_flowInsertBedsTest
 * @Description       : Test class for UAC_flowInsertBeds class
 * @Author            : Issam Awwad (Deloitte)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   11-10-2020   Issam Awwad (Deloitte)   Initial Version
 **/
@isTest public class UAC_flowInsertBedsTest {

  private
  static final String STRING_FIELD_TYPE = 'Long Term Foster Care';
  private
  static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;
  @TestSetup static void setupData() {
    Account Org = new UAC_testAccountBuilder()
                      .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                      .setType(STRING_FIELD_TYPE)
                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                      .build();
    Org.UAC_organizationContact1__c = UserInfo.getUserId();
    Org.UAC_programStatus__c = 'Active';
    insert Org;
  }

  /**
   * @description Test Method to validate create beds action
   * * @author Issam Awwad (Deloitte) | 11-10-2020
   * @param N/A
   * @return N/A
   **/
  @isTest static void testCreateBeds() {
    UAC_flowInsertBeds.Request objRequest = new UAC_flowInsertBeds.Request();
    objRequest.intOfDeliveredMaleBeds = 1;
    objRequest.intOfUndeliveredMaleBeds = 1;
    objRequest.intOfDeliveredFemaleBeds = 1;
    objRequest.intOfUndeliveredFemaleBeds = 1;
    objRequest.intOfMinimumAge = 1;
    objRequest.intOfMaximumAge = 17;
    objRequest.strEntityId = [select id from Account limit 1].Id;
    objRequest.strEntityState = 'Arizona';
    objRequest.dateProposedDelivery = System.Date.today();

    Test.startTest();
    UAC_flowInsertBeds.insertBeds(new List<UAC_flowInsertBeds.Request>{objRequest});
    Asset objAsset = [
      select id,
      UAC_overallStatus__c from Asset where UAC_overallStatus__c = 'Delivered' LIMIT 1
    ];
    System.assertNotEquals(null, objAsset);
    Test.stopTest();
  }
}