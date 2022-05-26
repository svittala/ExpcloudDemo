/**
 * @File Name          : UAC_TestObjectUtil.cls
 * @Description        : Utility class containing commonly used variables/method for UAC_Test__c object
 *Evaluation object
 * @Author             : Ram Josyer (Creative)
 * @Group              : UAC_utilities
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    1/12/2021   Ram Josyer  (Creative)     Initial Version
 **/
public
inherited sharing class UAC_TestObjectUtil {

  static final Map<String, RecordTypeInfo> MAP_RECORD_TYPE_DEV_NAME =
      Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName();

  public
  static Id getRecordTypeIdByDeveloperName(String strName) {
    return MAP_RECORD_TYPE_DEV_NAME.get(strName).getRecordTypeId();
  }
}