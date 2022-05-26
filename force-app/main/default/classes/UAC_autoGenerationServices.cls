/**
 * @File Name         : UAC_autoGenerationServices.cls
 * @Description       : Service class containing logic to auto-generate records
 * @Group             : UAC_autoGenerationServices
 * @Test Class        : UAC_autoGenerationServicesTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 08-04-2020
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   07-31-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   08-04-2020   Karthi Subramanian (Deloitte) Add Order by clause and RecordType check	
 **/
public
with sharing class UAC_autoGenerationServices {
  /**
   * @description Method to get records for auto-generation
   * @author Sachet Khanal (Deloitte) | 07-31-2020
   * @param strObjectName API Name of SObject
   * @param setRecordTypeName Set of API Names of Record Type
   * @return List<SObject>
   **/
  public
  static List<SObject> getRecords(Set<String> setSObjectName) {
    List<SObject> lstRecord = new List<SObject>();
    for (UAC_autoGenerateSettings__mdt objAutoGenerateSettings :
        // clang-format off
        [
          SELECT
            Id, UAC_objectApiName__c, UAC_recordTypeApiName__c, UAC_jsonFieldMap__c
          FROM
          UAC_autoGenerateSettings__mdt
          WHERE
            UAC_objectApiName__c IN :setSObjectName
            ORDER BY UAC_objectApiName__c
        ]
        // clang-format on
    ) {
      // Get SObjectType along with it's Record Type map
      SObjectType objSObjectType =
          Schema.getGlobalDescribe().get(objAutoGenerateSettings.UAC_objectApiName__c);
      Map<String, Schema.RecordTypeInfo> mapRecordTypeInfo =
          objSObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

      // Build sObject record - based on Record Type
      SObject objRecord = (objAutoGenerateSettings.UAC_recordTypeApiName__c!=null)? objSObjectType.newSObject(
        mapRecordTypeInfo.get(objAutoGenerateSettings.UAC_recordTypeApiName__c).getRecordTypeId(),
        true): objSObjectType.newSObject();

      // Pre-populate sObject record fields using field map in auto-generate settings
      Map<String, String> mapFieldValue = (Map<String, String>) JSON.deserialize(
          objAutoGenerateSettings.UAC_jsonFieldMap__c, Map<String, String>.class);
      for (String strFieldName : mapFieldValue.keySet()) {
        String strFieldValue = mapFieldValue.get(strFieldName);
        DisplayType objDisplayType =
            objSObjectType.getDescribe().fields.getMap().get(strFieldName).getDescribe().getType();
        if (objDisplayType == DisplayType.BOOLEAN) {
          objRecord.put(strFieldName, Boolean.valueOf(strFieldValue));
        } else if (objDisplayType == DisplayType.INTEGER || objDisplayType == DisplayType.DOUBLE
            || objDisplayType == DisplayType.CURRENCY) {
          objRecord.put(strFieldName, Decimal.valueOf(strFieldValue));
        } else if (objDisplayType == DisplayType.DATE) {
          objRecord.put(strFieldName, Date.valueOf(strFieldValue));
        } else if (objDisplayType == DisplayType.DATETIME) {
          objRecord.put(strFieldName, Datetime.valueOf(strFieldValue));
        } else {
          objRecord.put(strFieldName, strFieldValue);
        }
      }
      lstRecord.add(objRecord);
    }
    return lstRecord;
  }
}