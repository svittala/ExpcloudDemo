/***************************************************************************************************************************
* @author Piyush - Deloitte
* @date 10/4/2020 
* @description  Scheduler class for UAC_swbBatch
* Modification Log: 
* **************************************************************************************************************************
* Developer      Date             Description 
* **************************************************************************************************************************
* Piyush       10/4/2020       Initial version
* *************************************************************************************************************************/

global without sharing class UAC_swbBatchScheduler implements Schedulable  
{
    global void execute(SchedulableContext objSC) 
    {
        UAC_swbBatch swbBatch = new UAC_swbBatch();
        Database.executebatch(swbBatch,10); 
    }
}