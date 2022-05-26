/**
* @File Name          : UAC_asyncStatusAdmittedCreation.cls
* @Description        : This class is used for Queueable for status Admitted Updates.
* @Author             : Nithin Malla (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Nithin Malla (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/16/2021	   Nithin Malla (Deloitte)  	Initial version.
**/
public 
without sharing class UAC_asyncStatusAdmittedCreation implements Queueable {
    
    Set<Id> healthEvaluationSet;
    Set<Id> mentalHealthEvaluationSet;
    Set<Id> legalServiceProviderSet;
    
    /**
   * @description handling status updates
   * @author Nithin Malla (Deloitte) | 3/16/2021
   * @param healthEvaluationSet, mentalHealthEvaluationSet, legalServiceProviderSet
   * @return Constructor
   **/
    public UAC_asyncStatusAdmittedCreation(Set<Id> healthEvaluationSet, Set<Id> mentalHealthEvaluationSet, Set<Id> legalServiceProviderSet){
        this.healthEvaluationSet = healthEvaluationSet;
        this.mentalHealthEvaluationSet = mentalHealthEvaluationSet;
        this.legalServiceProviderSet = legalServiceProviderSet;
    }
    
    /**
   * @description handling Admitted Updates
   * @author Nithin Malla (Deloitte) | 3/16/2021
   * @param QueueableContext
   * @return void
   **/    
    public void execute(QueueableContext context) {
        try{
            UAC_asyncStatusAdmittedService.handleStatusUpdates(healthEvaluationSet, mentalHealthEvaluationSet, legalServiceProviderSet);
        } catch (Exception ex) {
            UAC_errorLog.logError(
                ex.getMessage(), null, 'Handling Status Admitted records Creation', ex.getStackTraceString());
        }
    }
}