/**
 * @File Name         : UAC_autoGenerationServicesTest.cls
 * @Description       : Test class for UAC_autoGenerationServices class
 * @Group             : UAC_autoGenerationServices
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 07-31-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-31-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
@isTest public class UAC_autoGenerationServicesTest {
  public
  static final String STR_OBJECT_NAME = UAC_test__c.sObjectType.getDescribe().getName();

  @isTest static void getRecordsShouldReturnRecordsForGeneration() {
    Test.startTest();
    List<SObject> lstRecord =
        UAC_autoGenerationServices.getRecords(new Set<String>{STR_OBJECT_NAME});
    Test.stopTest();
    System.assert(
        !lstRecord.isEmpty(), 'Test method: getRecordsShouldReturnRecordsForGeneration() failed.');
  }
}