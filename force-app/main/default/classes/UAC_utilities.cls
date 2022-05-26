/**
 * @File Name          : UAC_utilities.cls
 * @Description        : Generic utilities class containing commonly used variables and methods
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_utilities
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 08-12-2020
 * @Modification Log   :
 * Ver       Date            Author      		      Modification
 * 1.0    5/29/2020   Sachet Khanal (Deloitte)    Initial Version
 * 1.1    7/14/2020   Sachet Khanal (Deloitte)  Added cleanFieldValues() method
 **/
public
with sharing class UAC_utilities {
  public
  static final UAC_accountSettings__c OBJ_ACCOUNT_SETTINGS =
      UAC_accountSettings__c.getOrgDefaults();

  /**
   * @description Method to clean value types. Used to clean values from Flow.
   * @author Sachet Khanal (Deloitte) | 07-14-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static SObject cleanFieldValues(SObject objSObject) {
    for (String strFieldName : objSObject.getPopulatedFieldsAsMap().keySet()) {
      DisplayType enumFieldType = objSObject.getSObjectType()
                                      .getDescribe()
                                      .fields.getMap()
                                      .get(strFieldName)
                                      .getDescribe()
                                      .getType();
      if (enumFieldType == Schema.DisplayType.PICKLIST) {
        objSObject.put(strFieldName, String.valueOf(objSObject.get(strFieldName)));
      } else if (enumFieldType == Schema.DisplayType.MULTIPICKLIST) {
        String strValue = String.valueOf(objSObject.get(strFieldName));
        if (!String.isBlank(strValue)) {
          strValue = strValue.replace('[', '').replace(']', '');
        }
        objSObject.put(strFieldName, strValue);
      }
    }
    return objSObject;
  }
  /**
   * @description Method to get Field set.
   * @author Chaitanya Nandauri (Deloitte) | 07-22-2020
   * @param String,string (Object Name and Field set name)
   * @return SObject
   **/
  public
  static List<Schema.FieldSetMember> getFieldSet(String objectName, String fieldSetName) {
    Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);
    Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();

    Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    return fieldSetObj.getFields();
  }
}