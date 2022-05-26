/**
* @File Name          : UAC_asyncIMERiskBasedRecordCreation.cls
* @Description        : This class is used for Queueable IME Risk Lab Child record creation.
* @Author             : Abhisek Pati (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Abhisek Pati (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/22/2021	   Abhisek Pati (Deloitte)  	Initial version.
**/
public 
without sharing class UAC_asyncIMERiskBasedRecordCreation implements Queueable {
    
    Set<Id> healthEvaluationIMEIds;
    
    /**
   * @description creating IME child records
   * @author Abhisek Pati (Deloitte) | 3/22/2021
   * @param healthEvaluationIMEIds
   * @return Constructor
   **/
    public UAC_asyncIMERiskBasedRecordCreation(Set<Id> healthEvaluationIMEIds){
        this.healthEvaluationIMEIds = healthEvaluationIMEIds;
    }
    
    /**
   * @description creating IME child records
   * @author Abhisek Pati (Deloitte) | 3/22/2021
   * @param QueueableContext
   * @return void
   **/    
    public void execute(QueueableContext context) {
            UAC_asyncIMEChildRecordService.createIMERiskBasedLabRecords(healthEvaluationIMEIds);
    }   
}