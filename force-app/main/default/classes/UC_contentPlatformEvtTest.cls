/**
*@name          UC_contentPlatformEvtTest
*@author        Issam Awwad (Deloitte)
*@date          07/09/2021
*@description   Test class for UC_contentPlatformEvt
event Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)           07/09/2021   Initial Implementation.
**/
@isTest public without sharing class UC_contentPlatformEvtTest {

  /**
   * @description Method to test content platform event
   * @author Issam Awwad (Deloitte) | 5/15/2020
   * @return
   **/
  @isTest static void platformEventTest() {
    Test.startTest();
    Boolean boolSuccess = true;
    try {
      UC_contentPlatformEvt.platformEventContent('Insert', 'testrecordID', 'ContentVersion');
    } catch (Exception e) {
      boolSuccess = false;
    }
    Test.stopTest();
    System.assertEquals(true, boolSuccess);
  }
}