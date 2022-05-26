/**
 * @File Name         : UAC_listViewController.cls
 * @Description       : Controller class for uacListView LWC
 * @Group             : UAC_listView
 * @Test Class        : UAC_listViewControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-07-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-10-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
with sharing class UAC_listViewController {

  @AuraEnabled public static List<SObject> getRecords(String query, String childRelationshipQuery) {

    UAC_query objQuery = (UAC_query) JSON.deserialize(query, UAC_query.class);
    List<UAC_query> lstChildRelationshipQuery = new List<UAC_query>();
    if (String.isNotBlank(childRelationshipQuery)) {
      lstChildRelationshipQuery =
          (List<UAC_query>) JSON.deserialize(childRelationshipQuery, List<UAC_query>.class);
    }

    Boolean hasId = new Set<String>(objQuery.fieldsToQuery).contains('Id');
    if (!hasId) {
      objQuery.fieldsToQuery.add('Id');
    }
    for (UAC_query objChildQuery : lstChildRelationshipQuery) {
      Boolean hasIdField = new Set<String>(objChildQuery.fieldsToQuery).contains('Id');
      if (!hasIdField) {
        objChildQuery.fieldsToQuery.add('Id');
      }
      String strChildQuery = '(SELECT ' + String.join(objChildQuery.fieldsToQuery, ',');
      strChildQuery += ' FROM ' + String.escapeSingleQuotes(objChildQuery.objectApiName);
      if (String.isNotBlank(objChildQuery.filter)) {
        strChildQuery += ' WHERE ' + objChildQuery.filter;
      }
      strChildQuery += ')';
      objQuery.fieldsToQuery.add(strChildQuery);
    }
    String strQuery =
        'SELECT ' + String.join(objQuery.fieldsToQuery, ',') + ' FROM ' + objQuery.objectApiName;
    if (String.isNotBlank(objQuery.filter)) {
      strQuery += ' WHERE ' + objQuery.filter;
    }
    strQuery += ' WITH SECURITY_ENFORCED ';
    strQuery += ' ORDER BY CreatedDate ';
    return Database.query(strQuery);
  }

  public
  inherited sharing class UAC_query {
    @AuraEnabled public String objectApiName;
    @AuraEnabled public List<String> fieldsToQuery;
    @AuraEnabled public String filter;
  }
}