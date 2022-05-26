/**
 * @File Name          : UC_physicalExamHandler.cls
 * @Description        : Handles all Physical Exam trigger traffic
 * @Author             : Abhisek Pati (Deloitte)
 * @Group              : UC_physicalExamTrigger
 * @Test Class         : 
 * @Last Modified By   : Abhisek Pati (Deloitte)
 * @Last Modified On   : 07/15/2021
 * @Modification Log   :
 * Ver       Date            Author                           Modification
 * 1.0    07/15/2021   	    Abhisek Pati (Deloitte)           Initial Implementation
 **/
public
without sharing class UC_physicalExamHandler implements UAC_ITriggerHandler {
    
    private
    static final String STR_EXCLUSION_LOGIC_MDT_NAME = 'UC_physicalExam';
    
    /**
   * @description Adding Bypass logic
   * @author Abhisek Pati (Deloitte) | 07/15/2021
  **/
    public
        Boolean isDisabled() {
            return UAC_bypassSettings__c.getInstance().UC_bypassPhysicalExamTrigger__c;
        }
    
    /**
   * @description Method to handle before insert trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/12/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void BeforeInsert(List<SObject> newItems) {
        
    }
    
    /**
   * @description Method to handle before update trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/05/2021
   * @param newItems Map of new records
   * @param oldItems Map of old records
   * @return void
   **/
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
    }  
    
    /**
   * @description Method to handle before delete trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/15/2021
   * @param oldItems Map of new records
   * @return void
   **/
    public void BeforeDelete(Map<Id, SObject> oldItems){
        UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), STR_EXCLUSION_LOGIC_MDT_NAME);
    }  
    
    /**
   * @description Method to handle after insert trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/15/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterInsert(Map<Id, SObject> newItems){
        UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(),STR_EXCLUSION_LOGIC_MDT_NAME);
    }
    
    /**
   * @description Method to handle after update trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/15/2021
   * @param newItems Map of new records
   * @param oldItems Map of new records
   * @return void
   **/
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> mapOldItems){
        
    }    
    
    /**
   * @description Method to handle after delete trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/15/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterDelete(Map<Id, SObject> newItems){
        
    }
    
    /**
   * @description Method to handle after Undelete trigger traffic
   * @author Abhisek Pati (Deloitte) | 07/15/2021
   * @param newItems Map of new records
   * @return void
   **/
    public void AfterUndelete(Map<Id, SObject> newItems){
        
    }  
}