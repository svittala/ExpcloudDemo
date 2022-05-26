/**
*@name          UAC_contentDocumentLinkTriggerHandler
*@author        Ankur Aggarwal (Deloitte)
*@date          08/2/2020
*@description   Single trigger for handling all Content version transactions
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Ankur Aggarwal (Deloitte)    06/23/2020   Initial Implementation.
1.1	  9/22/2020	  Ranjith kumar(AI-Vets)	        ORRUAC-1564: Adding Logic to update ShareType for Health Evalution Documents
2.0    10/14/2020     Vaibhav Kudesia(Deloitte)	 Added before insert logic to restrict Document upload for Monitoring Visit based on status.
2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
**/


public with Sharing class UAC_contentDocumentLinkTriggerHandler implements UAC_ITriggerHandler{
    
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/    
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassContentDocumentLinkTrigger__c;
  }
     /*  @author       Ankur Aggarwal
      @description  Before Insert
      @param        N/A
      @return       void
  */
    public void beforeInsert(List<contentDocumentlink> lstNewFiles) {    
      //ORRUAC-1564: Upadating ShareType for Health Evalution Documents
      UAC_contentDocumentLinkTriggerHelper.updateShareForHealthEvaluation(lstNewFiles);   
    }
     /*  @author       Ankur Aggarwal
      @description  After Insert
      @param        N/A
      @return       void
  */
    public void afterInsert(Map<Id, sobject> newItems) {
      UAC_contentDocumentLinkTriggerHelper.linkToLSPRecord((Map<Id,ContentDocumentLink> )newItems);
      UAC_contentDocumentLinkTriggerHelper.verifycontentdocumentforMonitoringvisit(newItems.values());        
    }
     /*  @author       Ankur Aggarwal
      @description  After bUpdate
      @param        N/A
      @return       void
  */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}    
   /*  @author       Ankur Aggarwal
      @description  After Undelete
      @param        N/A
      @return       void
  */
    public void afterUndelete(Map<Id, SObject> oldItems) {}    
    /*  @author       Ankur Aggarwal
      @description  After Delete
      @param        N/A
      @return       void
  */
    
    public void afterDelete(Map<Id, SObject> oldItems) {}
    /*  @author       Ankur Aggarwal
      @description  Before Delete
      @param        N/A
      @return       void
  */
    public void beforeDelete(Map<Id, SObject> oldItems) {
    }
    /*  @author       Ankur Aggarwal
      @description  Before Update
      @param        N/A
      @return       void
  */
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
}