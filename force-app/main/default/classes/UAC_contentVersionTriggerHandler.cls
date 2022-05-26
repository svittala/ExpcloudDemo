/**
*@name          UAC_contentVersionTriggerHandler
*@author        Priyanka Bolla (Deloitte)
*@date          06/23/2020
*@description   Single trigger for handling all Content version transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Priyanka Bolla (Deloitte)    06/23/2020   Initial Implementation.
Ankur Aggarwal (Deloitte)    06/24/2020   ORRUAC-607
Nithin Malla (Deloitte)    	 10/02/2020		Adding Sharing visibility keyword
Sudeep Chintala(Deloitte)	 		11/03/2020		Adding bypass logic
Abhisek Pati (Deloitte)      06/10/2020 ORRUAC-5858 Changed Sharing to accomodate compliance forms
**/

public
without sharing class UAC_contentVersionTriggerHandler implements UAC_ITriggerHandler {

  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassContentversionTrigger__c;
  }
  /*  @author       Priyanka Bolla
   @description  Before Insert
   @param        N/A
   @return       void
*/
  public
  void beforeInsert(List<ContentVersion> lstNewFiles) {
    List<ContentVersion> lstContentVersions = new List<ContentVersion>();
    // Added for ORRUAC-607
    UAC_contentVersionTriggerHelper.ReleaseRequestOrDischarge(lstNewFiles);
    UAC_contentVersionTriggerHelper.beforeInsertHelper(lstNewFiles);
    // ORRUAC 1271 Start
    for (ContentVersion cV : lstNewFiles) {
      if (UAC_contentVersionTriggerHelper.isObjectEntity(cV)) {
        lstContentVersions.add(cV);
      }
    }
    if (lstContentVersions != null || !lstContentVersions.isEmpty()) {
      UAC_contentVersionTriggerHelper.handleEntityDocuments(lstContentVersions);
    }  // ORRUAC 1271 End
  }
  /*  @author       Priyanka Bolla
   @description  After Insert
   @param        N/A
   @return       void
*/
  public
  void afterInsert(Map<Id, SObject> newItems) {
    UC_exclusionLogicService.getInstance().runExclusionsForContentVersion(
        (Map<Id, ContentVersion>) newItems);
    UAC_contentVersionTriggerHelper.afterInsertHelper((Map<Id, ContentVersion>) newItems);
  }
  /*  @author       Priyanka Bolla
   @description  After bUpdate
   @param        N/A
   @return       void
*/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UAC_contentVersionTriggerHelper.afterUpdateHelper((Map<Id, ContentVersion>) newItems);
  }
  /*  @author       Priyanka Bolla
     @description  After Undelete
     @param        N/A
     @return       void
 */
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
  /*  @author       Priyanka Bolla
    @description  After Delete
    @param        N/A
    @return       void
*/

  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }
  /*  @author       Priyanka Bolla
    @description  Before Delete
    @param        N/A
    @return       void
*/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
  }
  /*  @author       Priyanka Bolla
    @description  Before Update
    @param        N/A
    @return       void
*/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusionsForContentVersion(
        (Map<Id, ContentVersion>) newItems);
    UAC_contentVersionTriggerHelper.beforeUpdatetHelper(
        newItems.values(), (Map<Id, ContentVersion>) oldItems);
    // ORRUAC-2997
    UAC_contentVersionTriggerHelper.handleLegacyDocumentsBeforeUpdate(
        (Map<Id, ContentVersion>) newItems, (Map<Id, ContentVersion>) oldItems);
    UAC_contentVersionTriggerHelper.eraseDateARIReceieved(
        (Map<Id, ContentVersion>) newItems, (Map<Id, ContentVersion>) oldItems);
  }
}