/**
*@name          UC_contentPlatformEvtTest
*@author        Issam Awwad (Deloitte)
*@date          07/09/2021
*@description   A generic class for developers to create a platform event for ContentVersion
event Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)           07/09/2021   Initial Implementation.
**/

public
inherited sharing class UC_contentPlatformEvt {

  /**
   * @author       Issam Awwad(Deloitte)
   * @description  Method will create a content version platform event record and publish the event
   * @param        String strOperationType, String strRecordIds, String strObjectType
   * @return       void
   */
  public
  static void platformEventContent(
      String strOperationType, String strRecordIds, String strObjectType) {
    UC_contentPlatformEvt__e objContentVersionEvent = new UC_contentPlatformEvt__e();
    objContentVersionEvent.UC_operationType__c = strOperationType;
    objContentVersionEvent.UC_recordIds__c = strRecordIds;
    objContentVersionEvent.UC_sObjectType__c = strObjectType;

    /*Database.SaveResult results = EventBus.publish(objContentVersionEvent);

    if (!results.isSuccess()) {
      Database.Error[] err = results.getErrors();
      System.debug('Error returned: ' + err[0].getMessage());
      UAC_errorLog.platformEventErrorLog(
          err[0].getMessage(),'', strRecordIds, 'UC_contentPlatformEvt__e');
    }*/
  }
}