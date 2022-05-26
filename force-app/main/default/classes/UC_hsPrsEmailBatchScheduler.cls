/**
* @File Name          : UC_hsPrsEmailBatchScheduler.cls
* @Description        : ORRUAC-4590 AC-1,AC-3 : Batch class to send Email notif. to Entry Team members for HSPRS Referall Cases for UCs turning 18
* @Author             : Piyush(Deloitte)
* @Parent Batch class : UC_hsPrsEmailBatch.cls
* @Test Class         : UC_hsPrsEmailBatchTest.cls
* @Modification Log   :
* Ver       Date            Author               Modification
* 1.0    8/26/2021     Piyush(Deloitte)     Initial Implementation.
**/
global without sharing class UC_hsPrsEmailBatchScheduler implements Schedulable{
    global void execute(SchedulableContext objSC) 
    {
        UC_hsPrsEmailBatch hpEBatch = new UC_hsPrsEmailBatch();
        Database.executebatch(hpEBatch,10); 
    }
}