/**
*@name          UAC_contentDocumentTriggerHandler
*@author        Piyush(Deloitte)
*@date          07/21/2020
*@description   Single trigger for handling all Content Document transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer            Date         Description
------------------------------------------------------------------------------------
Piyush(Deloitte)     07/21/2020   Initial Implementation.
Sudeep Chintala(Deloitte)	11/03/2020	 Adding bypass logic
**/
public
with sharing class UAC_contentDocumentTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
   **/
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassContentDocumentTrigger__c;
  }
  /*  @author       Piyush
   @description  Before Insert
   @param        N/A
   @return       void
*/
  public
  void beforeInsert(List<ContentDocument> lstNewFiles) {
  }
  /*  @author       Piyush
   @description  After Insert
   @param        N/A
   @return       void
*/
  public
  void afterInsert(Map<Id, SObject> newItems) {
  }
  /*  @author       Piyush
   @description  After bUpdate
   @param        N/A
   @return       void
*/
  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }
  /*  @author       Piyush
     @description  After Undelete
     @param        N/A
     @return       void
 */
  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
  /*  @author       Piyush
    @description  After Delete
    @param        N/A
    @return       void
*/

  public
  void afterDelete(Map<Id, SObject> oldItems) {
    UAC_contentDocumentTriggerHelper.afterDeleteHelper((Map<Id, ContentDocument>) oldItems);
  }
  /*  @author       Piyush
    @description  Before Delete
    @param        N/A
    @return       void
*/
  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusionsForContentDocument(
        (Map<Id, ContentDocument>) oldItems);
    UAC_contentDocumentTriggerHelper.preventHSPRSDocDel((Map<Id, ContentDocument>) oldItems);
    UAC_contentDocumentTriggerHelper.deleteContactLinksForPhotos(
        (Map<Id, ContentDocument>) oldItems);
    UAC_contentDocumentTriggerHelper.eraseDateARIReceievedOnDelete(
        (Map<Id, ContentDocument>) oldItems);
  }
  /*  @author       Piyush
    @description  Before Update
    @param        N/A
    @return       void
*/
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
  }
}