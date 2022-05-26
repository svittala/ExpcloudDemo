/**
 * @File Name          : UAC_fileApexData.cls
 * @Description        : LOOP External Apex Data class to get list of File (ContentVersion) with
 *additional external data fields related to Associated Contacts
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_docGenApexData
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/26/2020, 4:24:09 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/26/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
global class UAC_fileApexData implements Loop.IApexDataSource {

  // Loop.IApexDataSource interface requires four public methods with the following signatures:
  // Set<String> getGlobalDescribe()
  // Set<String> getChildRelationships(String objectName)
  // List<Loop.ExternalData.DataObject> describeObjects(List<String> objectNames)
  // Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo)

  private
  static final String STR_FILE_OBJECT_NAME = 'UAC_fileApexData';
  private
  static final Map<String, Schema.SObjectField> MAP_FILE_FIELDS =
      Schema.SObjectType.ContentVersion.fields.getMap();
  // clang-format off
  private static final Map<String, Schema.DisplayType> MAP_ADDITIONAL_FILE_FIELDS = new Map<String, Schema.DisplayType>{
      'IndividualName' => Schema.DisplayType.STRING,
      'Sponsor' => Schema.DisplayType.BOOLEAN,
      'HHM' => Schema.DisplayType.BOOLEAN,
      'AACG' => Schema.DisplayType.BOOLEAN,
      'FamilyAndFriends' => Schema.DisplayType.BOOLEAN,
      'SupervisionPlanPerson' => Schema.DisplayType.BOOLEAN
  };
  // clang-format on

  /**
   * @description Method to return set of apex data objects available
   * @author Sachet Khanal (Deloitte) | 6/26/2020
   * @return Set<String>
   **/
  public
  Set<String> getGlobalDescribe() {
    return new Set<String>{STR_FILE_OBJECT_NAME};
  }

  /**
   * @description Method to describe apex data objects and their fields
   * @author Sachet Khanal (Deloitte) | 6/5/2020
   * @param lstObjectName List of apex data object names
   * @return List<Loop.ExternalData.DataObject>
   **/
  public
  List<Loop.ExternalData.DataObject> describeObjects(List<String> lstObjectName) {
    List<Loop.ExternalData.DataObject> lstDataObject = new List<Loop.ExternalData.DataObject>();
    for (String strObjectName : lstObjectName) {
      List<Loop.ExternalData.FieldInfo> lstDataField = new List<Loop.ExternalData.FieldInfo>();
      if (strObjectName == STR_FILE_OBJECT_NAME) {
        // Describe data fields for File object
        lstDataField = getExternalDataFieldInfoFromFieldMap(MAP_FILE_FIELDS);
        for (String strFieldName : MAP_ADDITIONAL_FILE_FIELDS.keySet()) {
          lstDataField.add(new Loop.ExternalData.FieldInfo(
              strFieldName, MAP_ADDITIONAL_FILE_FIELDS.get(strFieldName)));
        }
      }
      lstDataObject.add(new Loop.ExternalData.DataObject(strObjectName, lstDataField));
    }
    return lstDataObject;
  }

  /**
   * @description Method to return set of child data objects for given object name
   * @author Sachet Khanal (Deloitte) | 6/5/2020
   * @param strObjectName Name of data object to return child objects for
   * @return Set<String> Set of child object names
   **/
  public
  Set<String> getChildRelationships(String strObjectName) {
    return new Set<String>();
  }

  /**
   * @description Method to query and return related data
   * @author Sachet Khanal (Deloitte) | 6/5/2020
   * @param objRequestInfo Query request containing object info
   * @return Loop.ExternalData.QueryResultSet
   **/
  public
  Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo objRequestInfo) {
    Loop.ExternalData.QueryResultSet objQueryResultSet = new Loop.ExternalData.QueryResultSet();

    Loop.ExternalData.QueryResult objFileQueryResult =
        new Loop.ExternalData.QueryResult(STR_FILE_OBJECT_NAME, new List<String>());

    Id idRecord = objRequestInfo.RecordId;
    if (idRecord.getSObjectType() == Case.getSObjectType()) {

      // Get sponsor Id from Case
      Id idSponsor = [SELECT Id, UAC_sponsor__c FROM Case WHERE Id =:idRecord].UAC_sponsor__c;

      // Query and map Adult Contact Id to Associated Contact record to identify association
      Map<Id, UAC_associatedContact__c> mapAssociatedContact =
          new Map<Id, UAC_associatedContact__c>();
      for (UAC_associatedContact__c objAssociatedContact :
          // clang-format off
            [SELECT
              Id, UAC_householdMember__c, UAC_alternateAdultCaregiver__c,
              UAC_familyAndFriends__c, UAC_supervisionPlanPerson__c,
              UAC_contact__c, UAC_contact__r.Name
            FROM
              UAC_associatedContact__c
            WHERE
              UAC_case__c = :idRecord
            ]
          // clang-format on
      ) {
        mapAssociatedContact.put(objAssociatedContact.UAC_contact__c, objAssociatedContact);
      }

      // Get latest content version Ids from content document link to query
      Set<Id> setContentVersionId = new Set<Id>();
      for (ContentDocumentLink objContentDocumentLink : [SELECT Id,
             ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId
             =:idRecord]) {
        setContentVersionId.add(objContentDocumentLink.ContentDocument.LatestPublishedVersionId);
      }

      // Declare fields list for QueryResult instance
      List<String> lstField = new List<String>();
      // Get list of fields from the ContentVersion object
      for (String strFieldName : MAP_FILE_FIELDS.keySet()) {
        lstField.add(strFieldName);
      }

      // Construct query string for the list of fields
      String strQuery = String.format(
          'SELECT {0}, UAC_individual__r.Name FROM ContentVersion WHERE Id IN :setContentVersionId  ',
          new List<String>{String.join(lstField, ',')});

      // Add additional external data fields to be manually mapped
      lstField.addAll(MAP_ADDITIONAL_FILE_FIELDS.keySet());

      objFileQueryResult = new Loop.ExternalData.QueryResult(STR_FILE_OBJECT_NAME, lstField);

      for (ContentVersion objContentVersion : Database.query(strQuery)) {
        List<String> lstFieldValue = new List<String>();
        for (String strFieldName : lstField) {
          if (strFieldName == 'IndividualName') {
            lstFieldValue.add(getFieldValue(objContentVersion, 'UAC_individual__r.Name'));
          } else if (strFieldName == 'Sponsor') {
            lstFieldValue.add(String.valueOf(objContentVersion.UAC_individual__c == idSponsor));
          } else if (strFieldName == 'HHM') {
            lstFieldValue.add(
                String.valueOf(mapAssociatedContact.containsKey(objContentVersion.UAC_individual__c)
                    && mapAssociatedContact.get(objContentVersion.UAC_individual__c)
                           .UAC_householdMember__c));
          } else if (strFieldName == 'AACG') {
            lstFieldValue.add(
                String.valueOf(mapAssociatedContact.containsKey(objContentVersion.UAC_individual__c)
                    && mapAssociatedContact.get(objContentVersion.UAC_individual__c)
                           .UAC_alternateAdultCaregiver__c));
          } else if (strFieldName == 'FamilyAndFriends') {
            lstFieldValue.add(
                String.valueOf(mapAssociatedContact.containsKey(objContentVersion.UAC_individual__c)
                    && mapAssociatedContact.get(objContentVersion.UAC_individual__c)
                           .UAC_familyAndFriends__c));
          } else if (strFieldName == 'SupervisionPlanPerson') {
            lstFieldValue.add(
                String.valueOf(mapAssociatedContact.containsKey(objContentVersion.UAC_individual__c)
                    && mapAssociatedContact.get(objContentVersion.UAC_individual__c)
                           .UAC_supervisionPlanPerson__c));
          } else {
            lstFieldValue.add(getFieldValue(objContentVersion, strFieldName));
          }
        }
        objFileQueryResult.rows.add(lstFieldValue);
      }

      for (String strObjectName : objRequestInfo.getObjectNames()) {
        if (strObjectName == STR_FILE_OBJECT_NAME) {
          objQueryResultSet.add(objFileQueryResult);
        }
      }
    }
    return objQueryResultSet;
  }

  /**
   * @description Method to return list fo external data fields from map of SObjectField
   * @author Sachet Khanal (Deloitte) | 6/5/2020
   * @param mapField Map of field name to SObjectField used to create external data field
   * @return List<Loop.ExternalData.FieldInfo>
   **/
  private
  List<Loop.ExternalData.FieldInfo> getExternalDataFieldInfoFromFieldMap(
      Map<String, Schema.SObjectField> mapField) {
    List<Loop.ExternalData.FieldInfo> lstDataField = new List<Loop.ExternalData.FieldInfo>();
    for (String strKey : mapField.keySet()) {
      Schema.DescribeFieldResult objFieldDescribe = mapField.get(strKey).getDescribe();
      Loop.ExternalData.FieldInfo objFieldInfo =
          new Loop.ExternalData.FieldInfo(objFieldDescribe.getName(), objFieldDescribe.getType());
      objFieldInfo.referenceTo = objFieldDescribe.getReferenceTo().size() > 0
          ? String.valueOf(objFieldDescribe.getReferenceTo()[0])
          : null;
      objFieldInfo.scale = objFieldDescribe.getScale();
      objFieldInfo.label = objFieldDescribe.getLabel();
      lstDataField.add(objFieldInfo);
    }
    return lstDataField;
  }

  /**
   * @description Method to get field value from SObject field
   * @author Sachet Khanal (Deloitte) | 6/5/2020
   * @param objRecord Name of sObject
   * @param strField Name of field
   * @return String
   **/
  private
  String getFieldValue(SObject objRecord, String strField) {
    if (objRecord == null) {
      return '';
    }
    String[] lstFieldPart = strField.split('\\.');
    SObject objCurrentRecord = objRecord;
    for (Integer i = 0; i < lstFieldPart.size() - 1; i++) {
      objCurrentRecord = objCurrentRecord.getSObject(lstFieldPart[i]);
      if (objCurrentRecord == null) {
        return '';
      }
    }
    return String.valueOf(objCurrentRecord.get(lstFieldPart[lstFieldPart.size() - 1]));
  }
}