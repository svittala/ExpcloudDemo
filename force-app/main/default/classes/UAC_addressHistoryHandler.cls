/**
*___________________________________________________
* @Name: UAC_addressHistoryHandler
* @Author: Ankur Aggarwal
* @Created Date: May 06, 2020
* @Used_By: UAC PATH
*___________________________________________________
* @Description: Handles all Address History trigger traffic
*___________________________________________________
* @Changes:
*
**/
public with sharing class UAC_addressHistoryHandler implements UAC_ITriggerHandler {
     /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAddressHistoryTrigger__c;
  }
    /*  @author       Ankur Aggarwal
        @description  Before Insert
        @param        N/A
        @return       void
    */     
    public void BeforeInsert(List<SObject> lstNewItems) {    
        UAC_addressHistoryServices.validateCurrentAddress(lstNewItems);  
        UAC_addressHistoryServices.validateOverlappingDates(lstNewItems);        
    }
    /*  @author       Ankur Aggarwal
        @description  Before Update
        @param        N/A
        @return       void
    */     
    public void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
        UAC_addressHistoryServices.validateCurrentAddress((Map<Id, UAC_addressHistory__c> )mapNewItems,(Map<Id, UAC_addressHistory__c> )mapOldItems);  
        UAC_addressHistoryServices.validateOverlappingDates((Map<Id, UAC_addressHistory__c> )mapNewItems,(Map<Id, UAC_addressHistory__c> )mapOldItems); 
    }  
    /*  @author       Ankur Aggarwal
        @description  Before Delete
        @param        N/A
        @return       void
    */ 
    public void BeforeDelete(Map<Id, SObject> mapOldItems){
        UAC_addressHistoryServices.handleVerifiedDelete((Map<Id, UAC_addressHistory__c> )mapOldItems); 
    }  
    /*  @author       Ankur Aggarwal
        @description  After Insert
        @param        N/A
        @return       void
    */ 
    public void AfterInsert(Map<Id, SObject> mapNewItems){
        
    }
    /*  @author       Ankur Aggarwal
        @description  After Update
        @param        N/A
        @return       void
    */     
    public void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems){
            
    }    
    /*  @author       Ankur Aggarwal
        @description  After Delete
        @param        N/A
        @return       void
    */ 
    public void AfterDelete(Map<Id, SObject> mapOldItems){

    }
    /*  @author       Ankur Aggarwal
        @description  After Undelete
        @param        N/A
        @return       void
    */     
    public void AfterUndelete(Map<Id, SObject> mapOldItems){

    }  
}