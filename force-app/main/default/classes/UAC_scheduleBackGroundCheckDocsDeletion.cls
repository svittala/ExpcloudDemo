/**
 * @File Name          : UAC_backgroundCheckDocumentsDeletion.cls
 * @Description        : Scheduled job to call UAC_batchNotifyAdmissionAssessment
 * @Author             : Priyanka Bolla(Deloitte)
 * @Group              : UAC_backgroundCheckDocumentsDeletion
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/10/2020   Priyanka Bolla (Deloitte)     Initial Implementation.
 **/
global without sharing class UAC_scheduleBackGroundCheckDocsDeletion implements Schedulable {

  /**
   * @description Execute method that calls the Batch
   * @author Priyanka Bolla (Deloitte) | 9/10/2020
   * @param SchedulableContext
   **/
  global void execute(SchedulableContext sc) {
    Database.executeBatch(new UAC_backgroundCheckDocumentsDeletion());
  }
}