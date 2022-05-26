/**
 * @File Name          : UAC_fileListController.cls
 * @Description        : Controller class for uacFileList LWC (ORRUAC-1022)
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_fileList
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 10-26-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
public
with sharing class UAC_fileListController {

  /**
   * @description Method to get list of fields to be displayed as data table columns
   * @return List<UAC_fieldInfo>
   */
  @AuraEnabled(cacheable = true) public static List<UAC_fieldInfo> getFieldList() {
    List<UAC_fieldInfo> lstFieldInfo = new List<UAC_fieldInfo>();
    for (Schema.DescribeFieldResult objDescribeFieldResult :
        UAC_fileServices.getFileFieldDescribeList()) {
      lstFieldInfo.add(new UAC_fieldInfo(objDescribeFieldResult.getLabel(),
          objDescribeFieldResult.getName(),
          objDescribeFieldResult.getType()));
    }
    return lstFieldInfo;
  }

  /**
   * @description Method to get list of files (Content Version) related to an SObject record
   * @param idRecord Id of SObject to query the related files
   * @return List<ContentVersion>
   */
  @AuraEnabled public static List<ContentVersion> getFileList(
      String idRecord, String recordTypeName) {
    return UAC_fileServices.getFilesFromSObject(idRecord, recordTypeName);
  }
  /**
   * @description Method to get list of latest legal files (Content Version) related to an SObject
   * record
   * @param idRecord Id of SObject to query the related files
   * @return List<ContentVersion>
   */
  @AuraEnabled public static List<ContentVersion> getLegalFileList(
      String idRecord, String recordTypeName) {

    list<contentversion> lstfiles = UAC_fileServices.getFilesFromSObject(idRecord, recordTypeName);
    system.debug(lstfiles.size());
    // list<contentversion > lstfilesfinal = new list<contentversion >();
    map<string, contentversion> mapfiles = new map<string, contentversion>();
    for (contentversion objCurrcontectversion : lstfiles) {
      contentversion ojcontectversion = new contentversion();
      string keystr =
          objCurrcontectversion.UAC_recordType__c + objCurrcontectversion.uac_documenttype__C;
      if (mapfiles.containskey(keystr)) {
        ojcontectversion = mapfiles.get(keystr);
        if (ojcontectversion.createddate < objCurrcontectversion.createddate)
          mapfiles.put(keystr, objCurrcontectversion);
      } else {
        mapfiles.put(keystr, objCurrcontectversion);
      }
    }
    return mapfiles.values();
  }
  public
  inherited sharing class UAC_fieldInfo {
    @AuraEnabled public String strLabel;
    @AuraEnabled public String strFieldName;
    @AuraEnabled public String strDisplayType;
    public
    UAC_fieldInfo(String strLabel, String strFieldName, DisplayType objDisplayType) {
      this.strLabel = strLabel;
      this.strFieldName = strFieldName;
      this.strDisplayType = objDisplayType.name();
    }
  }
}