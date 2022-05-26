/**
 * @File Name          : UC_AccountRequestFormProfileSchedule.cls
 * @Description        : Change Profile and Role for the Account Request User when training is completed
 * @Author             : Ankur Aggarwal (Deloitte)
 * @Group              : UC_AccountRequestFormProfileSchedule
 */
global without sharing class UC_AccountRequestFormProfileSchedule implements Schedulable {

  global void execute(SchedulableContext ctx) {
    UC_AccountRequestFormProfileBatch p = new UC_AccountRequestFormProfileBatch();
       database.executeBatch(p);
  }   
}