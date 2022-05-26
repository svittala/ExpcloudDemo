/**
* @File Name          : UAC_asyncIMEStatusAndDueDateUpdate.cls
* @Description        : This class is used to update IME status and Due date on profile (UC).
* @Author             : Abhisek Pati (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Abhisek Pati (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	9/15/2021	   Abhisek Pati (Deloitte)  	Initial version.
**/
public 
without sharing class UAC_asyncIMEStatusAndDueDateUpdate implements Queueable {
    
    Set<Id> setContactIds;
    
    /**
   * @description Update IME status and Due date
   * @author Abhisek Pati (Deloitte) | 9/15/2021
   * @param setContactIds
   * @return Constructor
   **/
    public UAC_asyncIMEStatusAndDueDateUpdate(Set<Id> setContactIds){
        this.setContactIds = setContactIds;
    }
    
    /**
   * @description Update IME status and Due date
   * @author Abhisek Pati (Deloitte) | 9/15/2021
   * @param QueueableContext
   * @return void
   **/    
    public void execute(QueueableContext context) {
            UAC_asyncIMEStatusAndDueDateService.updateIMEStatusAndDueDate(setContactIds);
    }   
}