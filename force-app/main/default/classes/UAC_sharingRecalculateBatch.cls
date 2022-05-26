/**
 * @File Name          : UAC_sharingRecalculateBatch.cls
 * @Description        : Batch class to remove access after 45 days
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              :
 * @Test Class         : UAC_sharingRecalculateBatchTest
 * @Last Modified By   : Sarang Padhye (Deloitte)
 * @Last Modified On   : 8/30/2020,
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    8/28/2020   Sarang Padhye (Deloitte)        Initial Implementation.
 */
global without sharing class UAC_sharingRecalculateBatch implements Database.Batchable<sObject> {

  global String strDischargeRecordType;
  global String strDischargeCompletedStatus;
  global String strDateTimeLiteral_45;
  global String query;
  public

  /**
   * @description ORRUAC-1850 - Constructor method
   *discharge notification
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param strDischargeRecordType Discharge Cases Record Types
   * @param strDischargeCompletedStatus Discharged Completed Status
   * @param strDateTimeLiteral_45 Last 45 days
   * @param query Batch selecttion query
   * @return void
   **/
  UAC_sharingRecalculateBatch(String strDischargeRecordType,
      String strDischargeCompletedStatus,
      String strDateTimeLiteral_45,
      String query) {
    this.strDischargeRecordType = strDischargeRecordType;
    this.strDischargeCompletedStatus = strDischargeCompletedStatus;
    this.strDateTimeLiteral_45 = strDateTimeLiteral_45;
    this.query = query;
  }

  /**
   * @description ORRUAC-1850 - Batch start method
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param BC BatchableContext
   * @return Database.QueryLocator
   **/
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }
  /**
   * @description ORRUAC-1850 - Batch execute method
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstCases Scope of the batch
   * @return void
   **/
  global void execute(Database.BatchableContext BC, List<sObject> lstCases) {
    UAC_sharingService sharingService = new UAC_sharingService(lstCases);
  }
  /**
   * @description ORRUAC-1850 - Batch Finish method
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param BC BatchableContext
   * @return void
   **/
  global void finish(Database.BatchableContext BC) {
  }
}