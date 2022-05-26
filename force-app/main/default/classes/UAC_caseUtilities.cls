/**
 * @File Name          : UAC_caseUtilities.cls
 * @Description        : Utility class containing commonly used variables/method for Case object
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_utilities
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 10-07-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/18/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
public
inherited sharing class UAC_caseUtilities {

  private
  static Set<String> setActiveStatus;
  private
  static final Map<String, RecordTypeInfo> MAP_RECORD_TYPE_DEV_NAME =
      Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

  public
  static Set<String> getActiveStatuses() {
    if (setActiveStatus == null) {
      setActiveStatus = new Set<String>(Label.UAC_caseActiveStatusList.split(';'));
    }
    return setActiveStatus;
  }

  public
  static Id getRecordTypeIdByDeveloperName(String strName) {
    return MAP_RECORD_TYPE_DEV_NAME.get(strName).getRecordTypeId();
  }
}