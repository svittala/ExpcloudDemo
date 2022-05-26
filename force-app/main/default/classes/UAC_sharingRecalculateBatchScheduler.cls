/**
 * @File Name          : UAC_sharingRecalculateBatchScheduler.cls
 * @Description        : Batch Service Helper Class
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              :
 * @Test Class         : UAC_sharingRecalculateBatchTest
 * @Last Modified By   : Sarang Padhye (Deloitte)
 * @Last Modified On   : 8/30/2020,
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    8/28/2020   Sarang Padhye (Deloitte)        Initial Implementation.
 */

global without sharing class UAC_sharingRecalculateBatchScheduler implements Schedulable {

  /**
   * @description ORRUAC-1850 - Schedular method to call batch class
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param sc SchedulableContext
   * @return void
   **/
  global void execute(SchedulableContext sc) {
    String strDischargeRecordType = Label.UAC_caseRecordTypeDischarge;
    String strDischargeCompletedStatus = Label.UAC_caseStatusDischargeCompleted;
    String strDateTimeLiteral_45 = 'LAST_N_DAYS:45';
    String query = Label.UAC_sharingBatchBaseQuery;
    query +=
        ' recordType.DeveloperName=:strDischargeRecordType AND status=:strDischargeCompletedStatus AND UAC_dateTimeOfDischarge__c < '
        + strDateTimeLiteral_45;

    try {
      UAC_sharingRecalculateBatch batch = new UAC_sharingRecalculateBatch(
          strDischargeRecordType, strDischargeCompletedStatus, strDateTimeLiteral_45, query);
      Database.executeBatch(batch);

    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'UAC_sharingRecalculateBatchScheduler:Batch execution error',
          e.getStackTraceString());
    }
  }
  /**
   * @description ORRUAC-1850 - Method to schedule batch via execute anonymous
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @return ID
   **/
  public
  static ID scheduleBatch() {
    return scheduleBatch('UAC_sharingRecalculateBatchScheduler');
  }

  /**
   * @description ORRUAC-1850 - Different signature to handle test class issue with duplicate batch names
   * @author James Qian (Deloitte) | 01/20/2021
   * @param String strBatchName
   * @return ID
   **/
  public
  static ID scheduleBatch(String strBatchName) {
    String CRON_EXPR = '0 15 3 * * ? *';

    UAC_sharingRecalculateBatchScheduler sch = new UAC_sharingRecalculateBatchScheduler();
    Id idSched = system.schedule(strBatchName, CRON_EXPR, sch);
    return idSched;
  }
}