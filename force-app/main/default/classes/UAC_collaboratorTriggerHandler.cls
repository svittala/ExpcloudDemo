/**
 * @File Name          : UAC_collaborator TriggerHandler.cls
 * @Description        : Handles all Collaborator trigger traffic
 * @Author             : Priyanka (Deloitte)
 * @Group              : UAC_triggerHandler
 * @date               : 07/15/2020
 * @Test Class         : UAC_collaboratorTriggerTest
* Ver       Date            Author                   		Modification
* 1.0    	7/15/2020   	Priyanka Bolla (Deloitte)   	Initial Version
* 1.1    	10/02/2020  	Nithin Malla (Deloitte)      	Adding Sharing visibility keyword
* 2.0    	10/09/2020  	Vaibhav Kudesia (Deloitte)    Adding chck for Program team while adding Monitoring collaborators
2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
  **/
public
with sharing class UAC_collaboratorTriggerHandler implements UAC_ITriggerHandler {
/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassCollaboratorstrigger__c;
  }
 /*  @author       Priyanka Bolla
      @description  Before Insert
      @param        N/A
      @return       void
  */
  public
  void beforeInsert(List<SObject> newItems) {
   	UAC_collaboratorTriggerHelper.checkifUserFromProgramTeam(newItems);
  }
/*  @author       Priyanka Bolla
      @description  Before Update
      @param        N/A
      @return       void
  */
  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    UAC_collaboratorTriggerHelper.checkifUserFromProgramTeam(newItems.values());
  }

  public
  void beforeDelete(Map<Id, SObject> oldItems) {
      for (Id idOldItemId : OldItems.keySet()) {
    
      UAC_collaborators__c objOld =
          (UAC_collaborators__c) OldItems.get(idOldItemId);

  // Call the Flow
Map<String, Object> params = new Map<String, Object>();

          if(!test.isRunningTest() && Objold.UAC_sir__c != null){
              params.put('sirRecordId',Objold.UAC_sir__c);
              params.put('IsManualDelete',true);
              Flow.Interview.CollaboratorForMonitoringRecordNew myflowMonitoring = new Flow.Interview.CollaboratorForMonitoringRecordNew(params);              
              myflowMonitoring.start();
          }
          if(!test.isRunningTest() && Objold.UAC_monitoring__c != null){
              params.put('monitoringRecordId',Objold.UAC_monitoring__c);
              params.put('IsManualDelete',true);
              Flow.Interview.CollaboratorForMonitoringRecordNew myflowMonitoring = new Flow.Interview.CollaboratorForMonitoringRecordNew(params);              
              myflowMonitoring.start();
          }
        
      }
  }  
  /*  @author       Priyanka Bolla
      @description  After Insert
      @param        N/A
      @return       void
  */
  public
  void afterInsert(Map<Id, SObject> newItems) {
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