/**
 * @File Name          : UAC_scheduleBatchNotify.cls
 * @Description        : Scheduled job to call UAC_batchNotifyAdmissionAssessment
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_admissionAssessment
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/14/2020   James Qian (Deloitte)     Initial Implementation.
 **/
global without sharing class UAC_scheduleBatchNotify implements Schedulable {
  public
  static final String STR_CRON_EXP = Label.UAC_cronScheduleAdmissionBatch;
  /**
   * @description Execute method that calls the Batch
   * @author James Qian (Deloitte) | 7/15/2020
   * @param SchedulableContext
   **/
  global void execute(SchedulableContext sc) {
    Database.executeBatch(new UAC_batchNotifyAdmissionAssessment());
  }
}