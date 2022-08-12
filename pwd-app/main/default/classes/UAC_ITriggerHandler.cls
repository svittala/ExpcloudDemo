/**
*@name          UAC_ITriggerHandler 
*@author        Issam Awwad (Deloitte)
*@date          05/5/2020
*@description   The Interface of the Trigger Framework which dictactes which method every trigger handler must implement.
*@Class         UAC_ITriggerHandler
Modification    Log:
------------------------------------------------------------------------------------
Developer                          Date         Description
------------------------------------------------------------------------------------
Issam Awwad (Deloitte)    5/1/2020   Initial Implementation.
*/
public interface UAC_ITriggerHandler  {
    
    void BeforeInsert(List<SObject> lstnewItems);
 
    void BeforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems);
 
    void BeforeDelete(Map<Id, SObject> mapOldItems);
 
    void AfterInsert(Map<Id, SObject> mapNewItems);
 
    void AfterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems);
 
    void AfterDelete(Map<Id, SObject> mapOldItems);
 
    void AfterUndelete(Map<Id, SObject> mapOldItems);
 
    Boolean IsDisabled();
}