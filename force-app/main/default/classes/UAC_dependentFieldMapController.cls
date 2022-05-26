/**
 * @File Name         : UAC_dependentFieldMapController.cls
 * @Description       : Controller class used by various LWC to query for dependent field mapping.
 * @Group             : UAC_dependentFieldMap
 * @Test Class        : UAC_dependentFieldMapControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-26-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-30-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
with sharing class UAC_dependentFieldMapController {

  /**
   * @description Method to query dependent field option mapping
   * @return Map<String, Map<String, List<PicklistOption>> PicklistOption entries for each
   * controlling value for each dependent field
   */
  @AuraEnabled(cacheable = true) public static Map<String,
      Map<String, List<PicklistOption>>> getDependentFieldMap(String strObjectName,
      String strRecordTypeName) {
    Map<String, Map<String, List<PicklistOption>>> mapDependentFieldOptions =
        new Map<String, Map<String, List<PicklistOption>>>();
    for (UAC_dependentFieldMap__mdt objDependentFieldMap :
        // clang-format off
        [
        SELECT
          Id, UAC_dependentFieldApiName__c, UAC_controllingFieldValue__c, UAC_dependentFieldOptions__c
        FROM
          UAC_dependentFieldMap__mdt
        WHERE
          UAC_objectApiName__c = :strObjectName
          AND UAC_recordTypeApiName__c = :strRecordTypeName
        ]
        // clang-format on
    ) {
      String strFieldName = objDependentFieldMap.UAC_dependentFieldApiName__c;
      String strControllingValue = objDependentFieldMap.UAC_controllingFieldValue__c;
      List<PicklistOption> lstFieldOptions = new List<PicklistOption>();
      if (String.isNotBlank(objDependentFieldMap.UAC_dependentFieldOptions__c)) {
        for (String strOption : objDependentFieldMap.UAC_dependentFieldOptions__c.split('\n')) {
          strOption = strOption.replaceAll('\r','').trim();  // Remove carriage return and trim
          lstFieldOptions.add(new PicklistOption(strOption, strOption));
        }
      }
      if (!mapDependentFieldOptions.containsKey(strFieldName)) {
        mapDependentFieldOptions.put(strFieldName, new Map<String, List<PicklistOption>>());
      }
      mapDependentFieldOptions.get(strFieldName).put(strControllingValue, lstFieldOptions);
    }
    return mapDependentFieldOptions;
  }

  public
  inherited sharing class PicklistOption {
    @AuraEnabled public String label;
    @AuraEnabled public String value;
    public
    PicklistOption(String strLabel, String strValue) {
      this.label = strLabel;
      this.value = strValue;
    }
  }
}