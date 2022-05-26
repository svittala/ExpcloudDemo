/**
 * @File Name         : UAC_dependentFieldMapControllerTest.cls
 * @Description       : Test class for UAC_dependentFieldMapController
 * @Group             : UAC_dependentFieldMapController
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 07-31-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-31-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
@isTest public class UAC_dependentFieldMapControllerTest {

  static final String STR_OBJECT_NAME = UAC_test__c.sObjectType.getDescribe().getName();
  static final String STR_RECORD_TYPE_NAME = Label.UAC_testRecTypeRiskBasedLabTest;

  /**
   * @description Method to test querying dependent picklist option map
   * @author Sachet Khanal (Deloitte) | 07-31-2020
   * @param ;
   **/
  @isTest static void getDependentFieldMapShouldReturnOptionMap() {
    Test.startTest();
    Map<String, Map<String, List<UAC_dependentFieldMapController.PicklistOption>>>
        mapDependentFieldOptions = UAC_dependentFieldMapController.getDependentFieldMap(
            STR_OBJECT_NAME, STR_RECORD_TYPE_NAME);
    Test.stopTest();
    System.assert(mapDependentFieldOptions.containsKey('UAC_test__c'),
        'Test method: getDependentFieldMapShouldReturnOptionMap() failed.');
  }
}