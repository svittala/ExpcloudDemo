/**
 * @File Name          : UAC_exposureEventTriggerHandler.cls
 * @Description        : Handles all Exposure Event trigger traffic
 * @Author             : Satish (Kvortex)
 * @Group              : UAC_triggerHandler
 * @Test Class         : UAC_exposureEventTriggerTest
 * @Last Modified By   : Sreenath Tella
 * @Last Modified On   : 08-19-2021
 * @Modification Log   : Enforcing Sharing
 * Ver       Date            Author                           Modification
 * 1.0    07/14/2021   	    Satish (Kvortex)               Initial Implementation

**/
public without sharing class UAC_exposureEventTriggerHandler implements UAC_ITriggerHandler {
public
    Boolean isDisabled() {
        return UAC_bypassSettings__c.getInstance().UAC_bypassExposureEventtrigger__c;
    }

public void BeforeInsert(List<SObject> newItems) {
    
}

public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UC_exclusionLogicService.getInstance().runExclusionsForExposureEvents(newItems) ;
}  

public void BeforeDelete(Map<Id, SObject> oldItems){
    UC_exclusionLogicService.getInstance().runExclusionsForExposureEvents(oldItems) ;
}  

public void AfterInsert(Map<Id, SObject> newItems){
    UC_exclusionLogicService.getInstance().runExclusionsForExposureEvents(newItems) ;
}

public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> mapOldItems){
    
}    

public void AfterDelete(Map<Id, SObject> newItems){
    
}

public void AfterUndelete(Map<Id, SObject> newItems){
    
}  
}