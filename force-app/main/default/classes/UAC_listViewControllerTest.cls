/**
 * @File Name         : UAC_listViewControllerTest.cls
 * @Description       : Test class for UAC_listViewController
 * @Group             : UAC_listView
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 09-02-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-11-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
@IsTest public class UAC_listViewControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';

  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
  }

  @isTest static void getRecordsShouldReturnRecordList() {
    UAC_listViewController.UAC_query objQuery = new UAC_listViewController.UAC_query();
    objQuery.objectApiName = 'Contact';
    objQuery.fieldsToQuery = new List<String>{'Name'};
    objQuery.filter = 'UAC_a__c=\'' + STR_A_NUM_UAC + '\'';
    UAC_listViewController.UAC_query objChildQuery = new UAC_listViewController.UAC_query();
    objChildQuery.objectApiName = 'Cases';
    objChildQuery.fieldsToQuery = new List<String>{'Id'};
    objChildQuery.filter = 'Id!=null';
    List<UAC_listViewController.UAC_query> lstChildQuery =
        new List<UAC_listViewController.UAC_query>();
    lstChildQuery.add(objChildQuery);
    Test.startTest();
    List<Contact> lstContact = (List<Contact>) UAC_listViewController.getRecords(
        JSON.serialize(objQuery), JSON.serialize(lstChildQuery));
    Test.stopTest();
    System.assert(
        lstContact.size() == 1, 'Test method: getRecordsShouldReturnRecordList() failed.');
  }
}