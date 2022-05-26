/**
 * @File Name          : UAC_addendumTriggerHandler.cls
 * @Description        : Handles all Addendum trigger traffic
 * @Author             : Priyanka (Deloitte)
 * @Group              : UAC_triggerHandler
 * @date               : 08/05/2020
 * @Test Class         : UAC_addendumTriggerTest
 * Ver       Date            Author                         Modification
 * 1.0      08-05-2020  Priyanka (Deloitte)				    Initial Implementation.
 * 1.1      06-30-2021	Nithin Malla (Deloitte)             ORRUAC-6040 Added Exclusion logic.
  **/
  public
  with sharing class UAC_addendumTriggerHandler implements UAC_ITriggerHandler {
  /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAddendumTrigger__c;
  }
   /*  @author       Priyanka Bolla
        @description  Before Insert
        @param        N/A
        @return       void
    */
    public
    void beforeInsert(List<UAC_addendum__c> lstNewItems) {
        
        UAC_addendumTriggerHelper.validateCurrentAddendum(lstNewItems);
        UAC_addendumTriggerHelper.populateSIRToAddendumOnInsert(lstNewItems);
        UAC_addendumTriggerHelper.populateAddendumDraftOnInsert(lstNewItems);
    }
  /*  @author       Priyanka Bolla
        @description  Before Update
        @param        N/A
        @return       void
    */
    public
    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Change to add if condision for Exclusion logic -- Nithin 07/06/21 ORRUAC-6040
        if (UC_exclusionLogicService.getInstance().runExclusionsForAddendum(newItems)) { 
            UAC_addendumTriggerHelper.addendumSubmittedProcess(newItems);
        }
    }
  
    public
    void beforeDelete(Map<Id, SObject> oldItems) {
      // Change to add if condision for Exclusion logic -- Nithin 07/06/21 ORRUAC-6050
      UC_exclusionLogicService.getInstance().runExclusionsForAddendum(oldItems);
    }  
    /*  @author       Priyanka Bolla
        @description  After Insert
        @param        N/A
        @return       void
    */
    public
    void afterInsert(Map<Id, SObject> newItems) {
      // Change to add if condision for Exclusion logic -- Nithin 07/06/21 ORRUAC-6040
      UC_exclusionLogicService.getInstance().runExclusionsForAddendum(newItems);
    }
     /*  @author       Priyanka Bolla
        @description  After Update
        @param        N/A
        @return       void
    */
    public
    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
       
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
        @description  After Undelete
        @param        N/A
        @return       void
    */
    public
    void afterUndelete(Map<Id, SObject> oldItems) {
    }
  }