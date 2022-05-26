/**
 * @File Name          : UC_immunizationHandler.cls
 * @Description        : Handles all Exposure Event trigger traffic
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Test Class         : 
 * @Last Modified By   : Nithin Malla (Deloitte)
 * @Last Modified On   : 07/07/2021
 * @Modification Log   :
 * Ver       Date            Author                           Modification
 * 1.0    07/07/2021   	    Nithin Malla (Deloitte)           Initial Implementation
 **/
public
without sharing class UC_immunizationHandler implements UAC_ITriggerHandler {
    
    private
    static final String STR_IMMUNIZATION_SOQL = 'UC_immunization';
    
    /**
   * @description Adding Bypass logic
   * @author Nithin Malla (Deloitte) | 07/07/2021
  **/
    public
        Boolean isDisabled() {
            return UAC_bypassSettings__c.getInstance().UC_bypassImmunizationTrigger__c;
        }
    
    /**
   * @description Method to handle before insert trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void BeforeInsert(List<SObject> newItems) {
        
    }
    
    /**
   * @description Method to handle before update trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_IMMUNIZATION_SOQL);
    }  
    
    /**
   * @description Method to handle before delete trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void BeforeDelete(Map<Id, SObject> oldItems){
        UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), STR_IMMUNIZATION_SOQL);
    }  
    
    /**
   * @description Method to handle after insert trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterInsert(Map<Id, SObject> newItems){
        UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(),STR_IMMUNIZATION_SOQL);
    }
    
    /**
   * @description Method to handle after update trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> mapOldItems){
        
    }    
    
    /**
   * @description Method to handle after delete trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterDelete(Map<Id, SObject> newItems){
        
    }
    
    /**
   * @description Method to handle after Undelete trigger traffic
   * @author Nithin Malla (Deloitte) | 07/07/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterUndelete(Map<Id, SObject> newItems){
        
    }  
}