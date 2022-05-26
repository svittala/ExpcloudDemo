/**
*@name          UAC_errorLogTest
*@author        Issam Awwad (Deloitte)
*@date          05/15/2020
*@description   Test class for UAC_errorLog
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)    05/15/2020   Initial Implementation.
**/
@isTest public without sharing class UAC_errorLogTest {

  /**
   * @description Method to test logging an error
   * @author Issam Awwad (Deloitte) | 5/15/2020
   * @return
   **/
  @isTest static void logError() {
    Test.startTest();
    Boolean boolSuccess = true;
    try {
      UAC_errorLog.logError('test error message', 'testrecordID', 'test origin', 'UAC_errorLogTest');
    } catch (Exception e) {
      boolSuccess = false;
    }
    Test.stopTest();
    System.assertEquals(true, boolSuccess);
  }

  /**
   * @description Method to test logging an error through platform event
   * @author Issam Awwad (Deloitte) | 5/15/2020
   * @return
   **/
  @isTest static void platformEventErrorLog() {
    Test.startTest();
    Boolean boolSuccess = true;
    try {
      UAC_errorLog.platformEventErrorLog(
        'test error message', 'testrecordID', 'test origin', 'UAC_errorLogTest');
    } catch (Exception e) {
      boolSuccess = false;
    }
    Test.stopTest();
    System.assertEquals(true, boolSuccess);
  }
}