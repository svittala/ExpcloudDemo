/**
 * @File Name          : UAC_flowContactQueryTest
 * @Description        : Test class for UAC_flowContactQuery class
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                         Modification
 * 1.0     03/26/2021   Vaibhav Kudesia (Deloitte)     Initial Implementation.
 **/

@isTest public class UAC_flowContactQueryTest {

  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
  }

  /**
   * @description Test Method to query returns results
   * * @author Vaibhav Kudesia (Deloitte)
   * @param N/A
   * @return N/A
   **/
  @isTest static void testflowContactQueryOne() {
        
    Test.startTest();
    List<Contact> queryresult = UAC_flowContactQuery.queryContactANumber(new list<string>{STR_UAC_CONTACT_A_NUMBER});
    System.assertNotEquals(null, queryresult[0].Id);
    Test.stopTest();
  }
  /**
   * @description Test Method to query returns results
   * * @author Vaibhav Kudesia (Deloitte)
   * @param N/A
   * @return N/A
   **/
  @isTest static void testflowContactQueryTwo() {
        
    Test.startTest();
    List<Contact> queryresult = UAC_flowContactQuery.queryContactANumber(new list<string>{STR_UAC_CONTACT_A_NUMBER + '12'});
    System.assertEquals(null, queryresult[0].Id);
    Test.stopTest();
  }
}