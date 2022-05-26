/**
 * @File Name          : UAC_fileServices.cls
 * @Description        : Service class containing logic to generation/query of file attachments.
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_services
 * @Test Class         : UAC_fileServicesTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 09-09-2020
 * @Modification Log   :
 * Ver       Date            Author                 		Modification
 * 1.0    	5/5/2020   		Sachet Khanal (Deloitte)     	Initial Version
 * 1.1    	6/16/2020  		Sachet Khanal (Deloitte)     	ORRUAC-1022 Custom Files Table
 * 1.2    	7/20/2020  		Ankur Aggarwal (Deloitte)    	update contact with profile pic id
 * 1.3    	9/14/2020  		James Qian (Deloitte)        	Use content version instead of Attachment
 * 1.4    	9/17/2020  		Nithin Malla (Deloitte)      	ORRUAC-2511 Record Visibility for PSC, FFS & FFSS
 **/
public
without sharing class UAC_fileServices {

  private
  static final String STR_JSON_FILE_MAP_FIELD_NAME = 'UAC_jsonFileMap__c';

  /**
   * @description Method to get File Type Settings custom metadata map
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param setFileTypeName Set of file type names to filter. NULL value skips filter.
   * @return List<UAC_fileTypeSetting__mdt>
   **/
  public
  static List<UAC_fileTypeSetting__mdt> getFileTypeSettings(Set<String> setFileTypeName) {
    String strQuery = 'SELECT Id, Label, UAC_maxSize__c, UAC_supportedFileTypes__c';
    strQuery += ' FROM UAC_fileTypeSetting__mdt';
    if (setFileTypeName != null) {
      strQuery += ' WHERE Label IN :setFileTypeName';
    }
    return Database.query(strQuery);
  }

  /**
   * @description This method is used to return file type to id mapping from an SObject
   * @author Sachet Khanal (Deloitte) | 5/7/2020
   * @param idFileMapObject Id of SObject to get file type mappings
   * @return Map<String, String> Map of file type to file id
   **/
  public
  static Map<String, String> getFileTypeMapping(Id idFileMapObject) {
    Map<String, String> mapFileTypeToId = new Map<String, String>();

    // Query for existing file type mapping from SObject to map
    SObjectType typeSObject = idFileMapObject.getSobjectType();
    String strQuery = 'SELECT Id, {0} FROM {1} WHERE Id = :idFileMapObject LIMIT 1';
    strQuery = String.format(strQuery,
        new List<String>{
            STR_JSON_FILE_MAP_FIELD_NAME, typeSObject.getDescribe().getName(), idFileMapObject});
    SObject objFileMapObject = Database.query(strQuery);
    if (objFileMapObject.get(STR_JSON_FILE_MAP_FIELD_NAME) != null) {
      mapFileTypeToId = (Map<String, String>) JSON.deserialize(
          (String) objFileMapObject.get(STR_JSON_FILE_MAP_FIELD_NAME), Map<String, String>.class);
    }

    return mapFileTypeToId;
  }

  /**
   * @description Method to create/replace attachments and update field mapping for SObject
   * @author Sachet Khanal (Deloitte) | 5/7/2020
   * @param idFileMapObject Id of SObject to store file mapping
   * @param lstFileWrapper List of file wrapper object to insert
   * @param boolReplaceFiles Boolean flag to indicate whether to replace old files or not
   * @return List<UAC_fileWrapper> Update list of file wrapper objects with update file id
   **/
  public
  static List<UAC_fileWrapper> generateSObjectFiles(
      Id idFileMapObject, List<UAC_fileWrapper> lstFileWrapper, Boolean boolReplaceFiles) {
    // Get file type mappings
    Map<String, String> mapFileTypeToId = UAC_fileServices.getFileTypeMapping(idFileMapObject);

    // Delete old files if replace files is set to true
    if (boolReplaceFiles) {
      Set<String> setFileIdsToDelete = new Set<String>();
      for (UAC_fileWrapper objFileWrapper : lstFileWrapper) {
        if (mapFileTypeToId.containsKey(objFileWrapper.strFileType)
            && !String.valueOf(mapFileTypeToId.containsKey(objFileWrapper.strFileType))
                    .startsWith('00P')) {
          setFileIdsToDelete.add(mapFileTypeToId.get(objFileWrapper.strFileType));
        }
      }
      // Get related content document IDs from content version records to delete
      if (!setFileIdsToDelete.isEmpty()) {
        List<ContentDocument> listContentDocumentToDelete = new List<ContentDocument>();
        for (ContentVersion objContentVersionCurrent :
            [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:setFileIdsToDelete]) {
          listContentDocumentToDelete.add(
              new ContentDocument(Id = objContentVersionCurrent.ContentDocumentId));
        }
        if(!listContentDocumentToDelete.isEmpty()) {
          delete listContentDocumentToDelete;
        }
      }
    }

    // Generate files and update file map
    for (UAC_fileWrapper objFileWrapper : UAC_fileServices.generateFiles(lstFileWrapper)) {
      mapFileTypeToId.put(objFileWrapper.strFileType, objFileWrapper.idFile);
    }
    SObject objFileMapObject = idFileMapObject.getSobjectType().newSObject(idFileMapObject);
    if (objFileMapObject != null) {
      update objFileMapObject;
    }

    return lstFileWrapper;
  }

  /**
   * @description This method creates attachment records.
   * @author Sachet Khanal (Deloitte) | 5/5/2020
   * @param lstFileWrapper List of file wrapper object to insert as attachments
   * @return List<UAC_fileWrapper> Updated file wrapper list with new file id
   **/
  public
  static List<UAC_fileWrapper> generateFiles(List<UAC_fileWrapper> lstFileWrapper) {
    Id idRecordType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                          .get('UAC_profilePicture')
                          .getRecordTypeId();
    // Create content versions from file wrappers
    List<contact> lstObjContactToupdate = new list<contact>();
    List<ContentVersion> lstContentVersion = new List<ContentVersion>();
    List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
    Map<Id, Id> mapVersionToDocument = new Map<Id, Id>();
    if (lstFileWrapper.isEmpty()) {
      return lstFileWrapper;
    }
    // Create content version records
    for (Integer i = 0; i < lstFileWrapper.size(); i++) {
      UAC_fileWrapper objFileWrapper = lstFileWrapper[i];
      lstContentVersion.add(new ContentVersion(Title = objFileWrapper.strFileName,
          RecordTypeId = idRecordType,
          VersionData = EncodingUtil.base64Decode(objFileWrapper.strBase64Data),
          IsMajorVersion = true,
          PathOnClient = objFileWrapper.strFileName.replaceAll('\\s+', '') + '.jpg',
          UAC_individual__c = lstFileWrapper[i].idParent,
          UAC_dateReceived__c = System.Today()));
    }
    if(!lstContentVersion.isEmpty()) {
      insert lstContentVersion;
    }
    // Add IDs to map
    for (ContentVersion objInsertedContentVersion : lstContentVersion) {
      mapVersionToDocument.put(objInsertedContentVersion.Id, null);
    }
    // Query related ContentDocumentIds
    for (ContentVersion objQueriedContentVersion : [SELECT Id,
           ContentDocumentId FROM ContentVersion WHERE Id IN:mapVersionToDocument.keyset()]) {
      mapVersionToDocument.put(
          objQueriedContentVersion.Id, objQueriedContentVersion.ContentDocumentId);
    }
    // Add ContentDocumentLink records so sharing applies
    for (Integer i = 0; i < lstFileWrapper.size(); i++) {
      if (mapVersionToDocument.get(lstContentVersion[i].Id) != null) {
        lstContentDocumentLink.add(
            new ContentDocumentLink(LinkedEntityId = lstFileWrapper[i].idParent,
                ShareType = 'V',
                ContentDocumentId = mapVersionToDocument.get(lstContentVersion[i].Id)));
      }
    }
    // Insert ContentDocumentLink records
    if(!lstContentDocumentLink.isEmpty()) {
      insert lstContentDocumentLink;
    }

    // Update Contact with the Content Version id
    for (Integer i = 0; i < lstFileWrapper.size(); i++) {
      Map<String, String> mapFileTypeIdCV = new Map<String, String>();
      mapFileTypeIdCV.put(lstFileWrapper[i].strFileType, String.valueOf(lstContentVersion[i].Id));
      lstObjContactToupdate.add(new Contact(Id = lstFileWrapper[i].idParent,
          UAC_Profile_pic_Id__c = lstContentVersion[i].Id + '.jpg',
          UAC_jsonFileMap__c = JSON.serialize(mapFileTypeIdCV)));
    }
    if (!lstObjContactToupdate.isEmpty()) {
      update lstObjContactToupdate;
    }

    // Populate file wrapper idFile with new Content Version record id
    for (Integer i = 0; i < lstFileWrapper.size(); i++) {
      if (mapVersionToDocument.get(lstContentVersion[i].Id) != null) {
        lstFileWrapper[i].idFile = mapVersionToDocument.get(lstContentVersion[i].Id);
      }
    }
    return lstFileWrapper;
  }

  /**
   * @description This method is used to get files for specific file types from an SObject.
   * @author Sachet Khanal (Deloitte) | 5/7/2020
   * @param idSObject Id of SObject to query the specific type of file
   * @param setFileType Set of file types to query
   * @return List<UAC_fileWrapper> File wrapper list
   **/
  public
  static List<UAC_fileWrapper> getFilesFromSObject(Id idSObject, Set<String> setFileType) {
    // Get map of file type to attachment Id and map as id to file type used for querying as well as
    // determining file type  for file wrapper based on attachment id
    Map<String, String> mapFileTypeToId = UAC_fileServices.getFileTypeMapping(idSObject);
    Map<String, String> mapIdToFileType = new Map<String, String>();
    for (String strFileType : setFileType) {
      if (mapFileTypeToId.containsKey(strFileType)) {
        mapIdToFileType.put(mapFileTypeToId.get(strFileType), strFileType);
      }
    }

    // Query Content Version and map it into UAC_fileWrapper object
    List<UAC_fileWrapper> lstFileWrapper = new List<UAC_fileWrapper>();
    // clang-format off
    for(ContentVersion objContentVersion : [
      SELECT
        Id, Title, VersionData, ContentDocumentId
      FROM
        ContentVersion
      WHERE
        Id IN :mapIdToFileType.keySet()
    ]) {
      // clang-format on
      UAC_fileWrapper objFileWrapper = new UAC_fileWrapper();
      objFileWrapper.idFile = objContentVersion.ContentDocumentId;
      objFileWrapper.idParent = idSObject;
      objFileWrapper.strBase64Data = EncodingUtil.base64Encode(objContentVersion.VersionData);
      objFileWrapper.strFileType = mapIdToFileType.get(objContentVersion.Id);
      lstFileWrapper.add(objFileWrapper);
    }
    return lstFileWrapper;
  }

  /**
   * @description Method to get list of fields from field set to display as columns in file list.
   *(ORRUAC-1022)
   * @author Sachet Khanal (Deloitte) | 6/16/2020
   * @return List<Schema.DescribeFieldResult>
   **/
  public
  static List<Schema.DescribeFieldResult> getFileFieldDescribeList() {
    List<Schema.DescribeFieldResult> lstFieldDescribe = new List<Schema.DescribeFieldResult>();
    for (Schema.FieldSetMember objFieldSetMember :
        Schema.SObjectType.ContentVersion.fieldSets.UAC_fileList.getFields()) {
      Schema.DescribeFieldResult objFieldDescribe =
          objFieldSetMember.getSObjectField().getDescribe();
      if (objFieldDescribe.isAccessible()) {
        lstFieldDescribe.add(objFieldDescribe);
      }
    }
    return lstFieldDescribe;
  }

  /**
   * @description Method to get list of files (Content Version) from an SObject record (ORRUAC-1022)
   * @author Sachet Khanal (Deloitte) | 6/16/2020
   * @param idSObject Id of SObject to query related files
   * @return List<ContentVersion>
   **/
  public
  static List<ContentVersion> getFilesFromSObject(Id idSObject, String recordTypeName) {
    // Query for set of all related content document ids for the SObject
    Set<Id> setContentDocumentId = new Set<Id>();
    for (ContentDocumentLink objContentDocumentLink :
        [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:idSObject]) {
      setContentDocumentId.add(objContentDocumentLink.ContentDocumentId);
    }
    // Query the latest content version record related to the content documents of the SObject
    Set<String> setQueryFields = new Set<String>{'Id',
        'ContentDocumentId',
        'Title',
        'RecordTypeId',
        'UAC_recordType__c',
        'CreatedDate',
        'UAC_documentType__c'};
    for (Schema.DescribeFieldResult objFieldDescribe : getFileFieldDescribeList()) {
      setQueryFields.add(objFieldDescribe.getName());
    }
    String strQuery = 'SELECT ' + String.join(new List<String>(setQueryFields), ',')
        + ' FROM ContentVersion '
        + 'WHERE IsLatest=true AND ContentDocumentId IN :setContentDocumentId ';
    if (!String.isBlank(recordTypeName) && recordTypeName.contains(';')) {
      strQuery = strQuery + 'AND RecordType.Name IN (\''
          + String.join(recordTypeName.split(';'), '\',\'') + '\') ';
    } else if (!String.isBlank(recordTypeName)) {
      strQuery = strQuery + 'AND RecordType.Name = \'' + recordTypeName + '\' ';
    } else {
      strQuery = strQuery + 'AND RecordType.DeveloperName != \'UAC_legacyDocuments\' ';
    }
    return filterFilesFromSObject(Database.query(strQuery));
  }
    
    /**
   * @description Method to get list of files (Content Version) from an SObject record (ORRUAC-2511)
   * @author Nithin Malla (Deloitte) | 9/18/2020
   * @param Filtering document visisbility
   * @return List<ContentVersion>
   **/
  public
  static List<ContentVersion> filterFilesFromSObject(List<ContentVersion> conVerList) {
    
    UAC_byPassFiles__c bypassFileSetting = UAC_byPassFiles__c.getInstance();
      for(Integer i = 0; i < conVerList.size(); i++){
          String recordTypeName = Schema.SObjectType.ContentVersion.getRecordTypeInfosById().get(conVerList.get(i).RecordTypeId).getDeveloperName();
          if(recordTypeName==bypassFileSetting.UAC_recordType__c && !bypassFileSetting.UAC_isVisibile__c
            && conVerList.get(i).UAC_documentType__c == bypassFileSetting.UAC_documentType__c){
              conVerList.remove(i);
          }
      }
      
      return conVerList;
  }
}