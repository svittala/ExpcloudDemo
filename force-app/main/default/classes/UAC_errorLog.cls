/**
*@name          UAC_errorLog
*@author        Issam Awwad (Deloitte)
*@date          05/13/2020
*@description   A generic class for developers to create an error log directly or through a platform
event Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)           05/11/2020   Initial Implementation.
Chaitanya Nandamuri(Deloitte)    05/15/2020   Adding the CustomException Class.
**/
public
without sharing class UAC_errorLog {
  public
  static final Id idInternalRecordType =
      Schema.SObjectType.UAC_errorLog__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_errorLogInternalRecordType)
          .getRecordTypeId();
  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will create a error log record and insert
   * @param        String strErrorMsg, String strRelatedRecordId, String strOrigin, String
   * strStackTrace
   * @return       void
   */
  public
  static void logError(
      String strErrorMsg, String strRelatedRecordId, String strOrigin, String strStackTrace) {
    UAC_errorLog__c objErrorLog = new UAC_errorLog__c();
    objErrorLog.UAC_errorMessage__c = strErrorMsg;
    objErrorLog.UAC_relatedRecordID__c = strRelatedRecordId;
    objErrorLog.UAC_errorOrigin__c = strOrigin;
    objErrorLog.UAC_stackTrace__c = strStackTrace;
    objErrorLog.RecordTypeId = idInternalRecordType;
    try {
      if(objErrorLog != null) {
        insert objErrorLog;
      }
    } catch (Exception e) {
      System.debug('Exception returned: ' + e.getMessage());
    }
  }

  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will create a error log platform event record and publish the event
   * @param        String strErrorMsg, String strRelatedRecordId, String strOrigin, String
   * strStackTrace
   * @return       void
   */
  public
  static void platformEventErrorLog(
      String strErrorMsg, String strRelatedRecordId, String strOrigin, String strStackTrace) {
    UAC_errorLogEvent__e objErrorLogEvent = new UAC_errorLogEvent__e();
    objErrorLogEvent.UAC_errorMessage__c = strErrorMsg;
    objErrorLogEvent.UAC_relatedRecordID__c = strRelatedRecordId;
    objErrorLogEvent.UAC_errorOrigin__c = strOrigin;
    objErrorLogEvent.UAC_stackTrace__c = strStackTrace;

    Database.SaveResult results = EventBus.publish(objErrorLogEvent);

    if (!results.isSuccess()) {
      for (Database.Error err : results.getErrors()) {
        System.debug('Error returned: ' + err.getMessage());
      }
    }
  }

  /**
   * @author       Chaitanya Nandamuri(Deloitte)
   * @description  This is a custom Exception class which can be used to Throw a Custom error.
   */
  public without sharing class CustomException Extends Exception {}
}