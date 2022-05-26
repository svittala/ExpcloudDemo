/**
 * @File Name          : UAC_healthEvaluationUtil.cls
 * @Description        : Utility class containing commonly used variables/method for Health
 *Evaluation object
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_utilities
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 10-07-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    7/21/2020   Karthi Subramanian  (Deloitte)     Initial Version
 **/
public
inherited sharing class UAC_healthEvaluationUtil {

  static final Map<String, RecordTypeInfo> MAP_RECORD_TYPE_DEV_NAME =
      Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName();

  public
  static Id getRecordTypeIdByDeveloperName(String strName) {
    return MAP_RECORD_TYPE_DEV_NAME.get(strName).getRecordTypeId();
  }
}