/**
 * @File Name          : UC_exclusionLogicService.cls
 * @Description        : This class is used to block users from updating records for programs not
 *                       mastered in Path.
 * @Author             : James Qian (Deloitte)
 * @Modification Log   : Initial version
 * Ver       Date           Author                      	Modification
 * 1.0    	6/28/2021	   James Qian (Deloitte)  	    Initial version.
 * 1.1      7/07/2021      Nithin Malla (Deloitte)      ORRUAC-6040 Added Exclusion logic.
 * 1.2      7/12/2021      Satish (Kvortex)             ORRUAC-6025 Added Exclusion logic for Contact.
 * 1.3      7/14/2021      Satish (Kvortex)             ORRUAC-6049 Added Exclusion logic for Exposure Events.
 * 1.4      7/19/2021      Nithin Malla (Deloitte)      ORRUAC-6071 Added SIR Exclusion logic.
 * 1.5      8/04/2021      Nithin Malla (Deloitte)      ORRUAC-6037 Added Task Exclusion logic.
 * 1.6      8/06/2021      Chase Oden (Deloitte)        ORRUAC-6285 Added Exclusion Logic - Content Version for Case Module.
 * 1.7      8/09/2021      Nithin Malla (Deloitte)      ORRUAC-6286 Added Exclusion Logic - Content Version for Monitoring Module.
 * 1.8      8/10/2021      Abhisek Pati (Deloitte)      ORRUAC-6283 Added Exclusion Logic - Content Version for Health Module. 
 * 1.9      8/12/2021      Chase Oden (Deloitte)        ORRUAC-6285 Added Exclusion Logic - Content Version for HS/PRS Referral Assessment Module.
 **/
public without sharing
class UC_exclusionLogicService {
  private
  static UC_exclusionLogicService instance;
  private
  static final String STR_ERROR_MESSAGE =
      'Insufficient access to this record in Path. Program is only active in Portal';
  private
  static String STR_NO_CONFIG = 'Was not able to find a configuration record with the name: ';
  private
  static String STR_QUERY_EXCEPTION = 'Error running query: ';
  private
  static final String STR_ASSET_MDT = 'UC_asset';
  private
  static final String STR_CASE_MDT = 'UC_caseGeneral';
  private
  static final String STR_RELATIONSHIP_MDT = 'UC_apprehendedRelationshipUpdateDelete';
  private
  static final String STR_ADDENDUM_PLE_SOQL = 'UC_addendumPLE';
  private
  static final String STR_ADDENDUM_NONPLE_SOQL = 'UC_addendumNonPLE';
  private
  static final String STR_SIR_PLE_SOQL = 'UC_sirPLE';
  private
  static final String STR_SIR_NONPLE_SOQL = 'UC_sirNonPLE';
  static final String STR_SIRNOTIFICATION_SOQL = 'UC_SIRNotification';    
  private 
  static final String STR_INDIVIDUALSINVOLVEDININCIDENT_SOQL = 'UC_individualsInvolvedinIncident';
  private 
  static final String STR_EVENT_SOQL = 'UC_eventNonNOC';
  private
  static final String STR_Monitoring_SOQL = 'UC_Monitoring';
  private
  static final String STR_Monitoring_Schedule_SOQL = 'UC_monitoringSchedule';
  private
  static final String STR_UC_Monitor_SOQL = 'UC_UCMonitoring';
  private
  static final String STR_HEALTHEVALUATION_SOQL = 'UC_healthEvaluation';
  private
  static final String STR_REFERRAL_ASSESSMENT_SOQL = 'UC_hsPrsRefAssessment';
  private
  static final String STR_TEST_SOQL = 'UC_test';
  private 
  static Set<String> setCompleted = new Set<String>();
  private
  Boolean boolBypassExclusion = false;
  private
  Boolean boolBypassAddError = false;
  Map<String, UC_exclusionLogicConfiguration__mdt> mapExclusionConfigs;

  /**
   * @description Returns instance of service class
   * @author James Qian (Deloitte) | 6/28/2021
   * @return UC_exclusionLogicService
   **/
  public
  static UC_exclusionLogicService getInstance() {
    if (instance == null) {
      instance = new UC_exclusionLogicService();
      instance.mapExclusionConfigs = new Map<String, UC_exclusionLogicConfiguration__mdt>();
      instance.boolBypassExclusion = UAC_bypassSettings__c.getInstance().UC_bypassExclusionLogic__c;
      instance.getMetadataRecords();
    }
    return instance;
  }

  /**
   * @description Sets exclusion bypass
   * @author James Qian (Deloitte) | 6/28/2021
   * @param boolBypass
   * @return void
   **/
  public
  void bypassExclusions(Boolean boolBypass) {
    boolBypassExclusion = boolBypass;
  }

  /**
   * @description Retrieves UC_exclusionLogicConfiguration__mdt records and stores in map
   * @author James Qian (Deloitte) | 6/28/2021
   * @return void
   **/
  private
  void getMetadataRecords() {
    for (UC_exclusionLogicConfiguration__mdt currentMetadata : [
           SELECT DeveloperName,
           UC_idField__c,
           UC_query__c,
           UC_errorMessage__c FROM UC_exclusionLogicConfiguration__mdt
         ]) {
      mapExclusionConfigs.put(currentMetadata.DeveloperName, currentMetadata);
    }
  }

  /**
   * @description Main method to call from trigger/handler
   * @author James Qian (Deloitte) | 6/28/2021
   * @param mapRecords - NewMap or OldMap if using Id as key, otherwise custom map
   * @param idSet - set of record IDs for use in metadata query
   * @param strConfigDevName - DeveloperName of metadata record for query
   * @return Boolean True if no exclusion errors were raised - check before calling other methods
   **/
  public
  Boolean runExclusions(Map<Id, sObject> mapRecords, Set<Id> idSet, String strConfigDevName) {
    Boolean boolNoErrors = true;
    if (mapRecords.isEmpty() || boolBypassExclusion) {
      return true;
    }
    Map<Id, sObject> mapQueriedRecords = new Map<Id, sObject>();

    // Get metadata record for exclusion logic
    UC_exclusionLogicConfiguration__mdt objConfig;
    if (mapExclusionConfigs.containsKey(strConfigDevName)) {
      objConfig = mapExclusionConfigs.get(strConfigDevName);
    } else {
      if (!boolBypassAddError) {
        addErrorsToAll(mapRecords, STR_NO_CONFIG + strConfigDevName);
      }
      return false;
    }

    // Run exclusion logic query and add errors
    try {
      for (sObject objRecord : Database.query(objConfig.UC_query__c)) {
        Id queriedId = (Id) objRecord.get(objConfig.UC_idField__c);
        if (mapRecords.containsKey(queriedId)) {
          boolNoErrors = false;
          break;
        }
      }
      if (!boolNoErrors && !boolBypassAddError) {
        addErrorsToAll(mapRecords, objConfig.UC_errorMessage__c);
      }
    } catch (Exception e) {
      if (!boolBypassAddError) {
        addErrorsToAll(mapRecords, STR_QUERY_EXCEPTION + e.getMessage());
      }
      return false;
    }
    return boolNoErrors;
  }

  /**
   * @description Utility method for adding errors to all records
   * @author James Qian (Deloitte) | 7/28/2021
   * @param mapRecords - NewMap or OldMap
   * @param strError - Error message
   **/
  private
  static void addErrorsToAll(Map<Id, SObject> mapRecords, String strError) {
    for (SObject objRecordOriginal : mapRecords.values()) {
      objRecordOriginal.addError(strError);
    }
  }

  /**
   * @description Helper method for account record types
   * @author James Qian (Deloitte) | 6/30/2021
   * @param mapAccountsSobject - NewMap or OldMap
   * @return Boolean True if no exclusion errors were raised
   **/
  public
  Boolean runExclusionsForAccount(Map<Id, SObject> mapAccountsSobject) {
    Boolean boolNoErrors = true;
    if (boolBypassExclusion) {
      return boolNoErrors;
    }

    Map<Id, Account> mapAccounts = (Map<Id, Account>) mapAccountsSobject;
    String strOrgRecordType = Label.UAC_organizationRecordTypeDevName;
    String strLawRecordType = Label.UAC_lawFirmAccountRecordType;
    Map<Id, Schema.RecordTypeInfo> mapAccountRecordTypes =
        Schema.SObjectType.Account.getRecordTypeInfosById();
    List<Account> listPrograms = new List<Account>();
    Map<Id, Account> mapFamilyGroups = new Map<Id, Account>();
    Map<Id, Account> mapOrgs = new Map<Id, Account>();
    Map<Id, Account> mapLawFirms = new Map<Id, Account>();

    for (Account currentAccount : mapAccounts.values()) {
      String strRecordTypeDevName =
          mapAccountRecordTypes.get(currentAccount.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == UAC_accountTriggerHelper.STRING_FAMILY_GROUP_RECORD_TYPE) {
        mapFamilyGroups.put(currentAccount.Id, currentAccount);
      } else if (strRecordTypeDevName == UAC_accountTriggerHelper.STRING_PROGRAM_RECORD_TYPE) {
        listPrograms.add(currentAccount);
      } else if (strRecordTypeDevName == strOrgRecordType) {
        mapOrgs.put(currentAccount.Id, currentAccount);
      } else if (strRecordTypeDevName == strLawRecordType) {
        mapLawFirms.put(currentAccount.Id, currentAccount);
      }
    }
    if (!listPrograms.isEmpty() && !runExclusionsForProgram(listPrograms)) {
      boolNoErrors = false;
    }
    if (!mapFamilyGroups.isEmpty()
        && !runExclusions(mapFamilyGroups, mapFamilyGroups.keyset(), 'UC_accountFamilyGroup')) {
      boolNoErrors = false;
    }
    if (!mapLawFirms.isEmpty()
        && !runExclusions(mapLawFirms, mapLawFirms.keyset(), 'UC_accountLawFirm')) {
      boolNoErrors = false;
    }
    if (!mapOrgs.isEmpty() && !runExclusions(mapOrgs, mapOrgs.keyset(), 'UC_accountOrganization')) {
      boolNoErrors = false;
    }
    return boolNoErrors;
  }

  /**
   * @description Runs exclusion logic for program record type
   * @author James Qian (Deloitte) | 6/30/2021
   * @param listAccounts - List of Programs
   * @return Boolean True if no exclusion errors were raised
   **/
  private
  Boolean runExclusionsForProgram(List<Account> listAccounts) {
    Boolean boolNoErrors = true;
    if (FeatureManagement.checkPermission(Label.UAC_CustomPermissionPO)) {
      return boolNoErrors;
    }
    for (Account currentAccount : listAccounts) {
      if (!currentAccount.UC_activeInPath__c) {
        boolNoErrors = false;
        if (!boolBypassAddError) {
          currentAccount.addError(STR_ERROR_MESSAGE);
        }
      }
    }
    return boolNoErrors;
  }

  /**
   * @description Runs exclusion logic for relationships on insert. Special method for before-insert
   * due to most business logic being before-insert
   * @author James Qian (Deloitte) | 7/9/2021
   * @param listRelationships - List of records
   * @return Boolean True if no exclusion errors were raised
   **/
  public
  Boolean runExclusionsForRelationshipOnInsert(
      List<UAC_apprehendedRelationship__c> listRelationships) {
    Boolean boolNoErrors = true;
    Map<Id, UAC_apprehendedRelationship__c> mapContactToRelationship =
        new Map<Id, UAC_apprehendedRelationship__c>();
    for (UAC_apprehendedRelationship__c currentRelationship : listRelationships) {
      mapContactToRelationship.put(currentRelationship.UAC_uacLookup__c, currentRelationship);
    }
    if (!mapContactToRelationship.isEmpty()
        && !runExclusions(mapContactToRelationship,
            mapContactToRelationship.keyset(),
            'UC_apprehendedRelationshipInsert')) {
      boolNoErrors = false;
    }
    return boolNoErrors;
  }

  /**
   * @description Helper method for addendum record types
   * @author Nithin Malla (KVortex) | 07/06/2021
   * @param mapAddendumSobject - NewMap or OldMap
   * @return Boolean True if no exclusion errors were raised
   **/  
  public
  Boolean runExclusionsForAddendum(Map<Id, SObject> mapAddendumSobject) {
    Boolean boolNoErrors = true;
    if (boolBypassExclusion) {
      return boolNoErrors;
    }

    Map<Id, UAC_addendum__c> mapAddendums = (Map<Id, UAC_addendum__c>) mapAddendumSobject;
    String strPLEReportRecordType = System.label.UC_addendumRecordTypeNamePLEReport;
      
    Map<Id, Schema.RecordTypeInfo> mapAddedRecordTypes =
        Schema.SObjectType.UAC_addendum__c.getRecordTypeInfosById();
    Map<Id, UAC_addendum__c> mapPLEAddendums = new Map<Id, UAC_addendum__c>();
    Map<Id, UAC_addendum__c> mapNonPLEAddendums = new Map<Id, UAC_addendum__c>();

    for (UAC_addendum__c currentAddendum : mapAddendums.values()) {
      String strRecordTypeDevName =
          mapAddedRecordTypes.get(currentAddendum.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strPLEReportRecordType) {
        mapPLEAddendums.put(currentAddendum.Id, currentAddendum);
      } else {
        mapNonPLEAddendums.put(currentAddendum.Id, currentAddendum);
      } 
    }
    
    if (!mapPLEAddendums.isEmpty()
        && !runExclusions(mapPLEAddendums, mapPLEAddendums.keyset(), STR_ADDENDUM_PLE_SOQL)) {
      boolNoErrors = false;
    }
    if (!mapNonPLEAddendums.isEmpty()
        && !runExclusions(mapNonPLEAddendums, mapNonPLEAddendums.keyset(), STR_ADDENDUM_NONPLE_SOQL)) {
      boolNoErrors = false;
    }
      
    return boolNoErrors;
  }

  /**
   * @description Helper method for SIR record types
   * @author Nithin Malla (KVortex) | 07/19/2021
   * @param mapAddendumSobject - NewMap or OldMap
   * @return Boolean True if no exclusion errors were raised
   **/
  public
  Boolean runExclusionsForSIR(Map<Id, SObject> mapSIRSobject) {
    Boolean boolNoErrors = true;
    if (boolBypassExclusion) {
      return boolNoErrors;
    }

    Map<Id, UAC_sir__c> mapSIRs = (Map<Id, UAC_sir__c>) mapSIRSobject;
    String strPLEReportRecordType = System.label.UC_sirRecordTypeNamePLEReport;

    Map<Id, Schema.RecordTypeInfo> mapAddedRecordTypes =
        Schema.SObjectType.UAC_sir__c.getRecordTypeInfosById();
    Map<Id, UAC_sir__c> mapPLESIRs = new Map<Id, UAC_sir__c>();
    Map<Id, UAC_sir__c> mapNonPLESIRs = new Map<Id, UAC_sir__c>();

    for (UAC_sir__c currentSIR : mapSIRs.values()) {
      String strRecordTypeDevName =
          mapAddedRecordTypes.get(currentSIR.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strPLEReportRecordType) {
        mapPLESIRs.put(currentSIR.Id, currentSIR);
      } else {
        mapNonPLESIRs.put(currentSIR.Id, currentSIR);
      }
    }

    if (!mapPLESIRs.isEmpty()
        && !runExclusions(mapPLESIRs, mapPLESIRs.keyset(), STR_SIR_PLE_SOQL)) {
      boolNoErrors = false;
    }
    if (!mapNonPLESIRs.isEmpty()
        && !runExclusions(
            mapNonPLESIRs, mapNonPLESIRs.keyset(), STR_SIR_NONPLE_SOQL)) {
      boolNoErrors = false;
    }

    return boolNoErrors;
  }

  /**
   * @description Helper method for contact record types
   * @author Satish (KVortex) | 07/12/2021
   * @param mapContactsSobject - NewMap or OldMap
   * @return Boolean True if no exclusion errors were raised
   **/  
  public
  Boolean runExclusionsForContacts(Map<Id, SObject> mapContactsSobject) {
    Boolean boolNoErrors = true;
    if (boolBypassExclusion) {
      return boolNoErrors;
    }

    Map<Id, Contact> mapContacts = (Map<Id, Contact>) mapContactsSobject;
    String strContactUAC = System.label.UAC_contactRecordTypeApiNameUAC;
    Map<Id, Schema.RecordTypeInfo> mapContactRecordTypes =
        Schema.SObjectType.Contact.getRecordTypeInfosById();
    Map<Id, Contact> mapContactUACs = new Map<Id, Contact>();

    for (Contact currentContact : mapContacts.values()) {
      String strRecordTypeDevName =
          mapContactRecordTypes.get(currentContact.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strContactUAC) {
        mapContactUACs.put(currentContact.Id, currentContact);
      }
    }
    
    if (!mapContactUACs.isEmpty()
        && !runExclusions(mapContactUACs, mapContactUACs.keyset(), 'UC_contactUC')) {
      boolNoErrors = false;
    }
    return boolNoErrors;
  }

  /**
   * @description Helper method for Exposure Event record types ORRUAC-6049
   * @author Satish (KVortex) | 07/14/2021
   * @param mapExpEventsSobject - NewMap or OldMap
   * @return Boolean True if no exclusion errors were raised
   **/
  public
  Boolean runExclusionsForExposureEvents(Map<Id, SObject> mapExpEventsSobject) {
    Boolean boolNoErrors = true;
    if (boolBypassExclusion) {
      return boolNoErrors;
    }
    Map<Id, UAC_exposureEvent__c> mapExpEvents = (Map<Id, UAC_exposureEvent__c>) mapExpEventsSobject;
    String strNonUACExpEVents = System.label.UAC_expEvtRecTypeNonUACExpEvt;
    String strInORRExpEvents = System.label.UAC_expEvtRecTypeUACDiagnosedInORRCustody;
    String strOutofORRExpEvents = System.label.UAC_expEvtRecTypeUACDiagnosedOutOfORRCustody;
    Map<Id, Schema.RecordTypeInfo> mapExpEventsRecordTypes =
        Schema.SObjectType.UAC_exposureEvent__c.getRecordTypeInfosById();
    Map<Id, UAC_exposureEvent__c> mapNonUACExpEvents = new Map<Id, UAC_exposureEvent__c>();
    Map<Id, UAC_exposureEvent__c> mapInORRExpEvents = new Map<Id, UAC_exposureEvent__c>();
    Map<Id, UAC_exposureEvent__c> mapOutofORRExpEvents = new Map<Id, UAC_exposureEvent__c>();

    for (UAC_exposureEvent__c currentExpEvent : mapExpEvents.values()) {
      String strRecordTypeDevName =
          mapExpEventsRecordTypes.get(currentExpEvent.RecordTypeId).getDeveloperName();
      if (strRecordTypeDevName == strNonUACExpEVents) {
		if(currentExpEvent.UAC_PHIProgram__c!=Null){ // Additional Null check as PHI program field is not mandatory for NonUAC Record tyoe on pagelayout. 
			mapNonUACExpEvents.put(currentExpEvent.Id, currentExpEvent);
		}
      } else if (strRecordTypeDevName == strInORRExpEvents) {
        mapInORRExpEvents.put(currentExpEvent.Id, currentExpEvent);
      } else if (strRecordTypeDevName == strOutofORRExpEvents) {
        mapOutofORRExpEvents.put(currentExpEvent.Id, currentExpEvent);
      }
    }
	if (!mapNonUACExpEvents.isEmpty()
        && !runExclusions(mapNonUACExpEvents, mapNonUACExpEvents.keyset(), 'UC_exposureEventNonUC')) {
      boolNoErrors = false;
    }
    if (!mapInORRExpEvents.isEmpty()
        && !runExclusions(
            mapInORRExpEvents, mapInORRExpEvents.keyset(), 'UC_exposureEventInORR')) {
      boolNoErrors = false;
    }
    if (!mapOutofORRExpEvents.isEmpty()
        && !runExclusions(mapOutofORRExpEvents, mapOutofORRExpEvents.keyset(), 'UC_exposureEventOutOfORR')) {
      boolNoErrors = false;
    }
    return boolNoErrors;
	}
  /**
   * @author       Vaibhav Kudesia (Deloitte)
   * @description  get Object linked to document
   * @param        Map<ID, ContentVersion> newItems
   * @return       void
   */
  public
  void runExclusionsForContentDocument(Map<Id, ContentDocument> oldItems) {

      if (runExclusionsForContentVersion( new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN:oldItems.keyset()]))) {
        addErrorsToAll(oldItems, STR_ERROR_MESSAGE);
      }  
  }
  /**
  * @author       Vaibhav Kudesia (Deloitte)
  * @description  get Object linked to document
  * @param        Map<ID, ContentVersion> newItems
  * @return       void
  */
  public
  Boolean runExclusionsForContentVersion(Map<Id, ContentVersion> newItems) {
  boolBypassAddError = true ;
  Map<String, set<Id>> mapObjectList = new Map<String, set<Id>>();
  Map<Id, Id> mapDocumentCV = new Map<Id, Id>();
  Map<String, Boolean> mapObjError = new Map<String, Boolean>();
  Map<Id, Set<Id>> mapLinkIdDocList = new Map<Id, Set<Id>>();

  for (ContentVersion c : newItems.values()) {
    mapDocumentCV.put(c.ContentDocumentId, c.Id);
  }

  for (ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId
        =:mapDocumentCV.keyset()]) {
    
    if (!mapObjectList.keyset().contains(
            cdl.LinkedEntityId.getsobjecttype().getDescribe().getName())) {
      mapObjectList.put(cdl.LinkedEntityId.getsobjecttype().getDescribe().getName(),
          new set<Id>{cdl.LinkedEntityId});
    } else {
      mapObjectList.get(cdl.LinkedEntityId.getsobjecttype().getDescribe().getName())
          .add(cdl.LinkedEntityId);
    }
    if (!mapLinkIdDocList.keyset().contains(cdl.LinkedEntityId)) {
      mapLinkIdDocList.put(cdl.LinkedEntityId, new Set<Id>{cdl.ContentDocumentId});
    } else {
      mapLinkIdDocList.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
    }
  }

  mapObjError = processObjects(mapObjectList, mapObjError);
  
  for (String objName : mapObjError.keyset()) {
    if(!mapObjError.get(objName)){
      for (Id LinkId : mapObjectList.get(objName)) {
        for (Id DocId : mapLinkIdDocList.get(LinkId)) {
          if(trigger.isdelete && trigger.isbefore){
            return true;
          }  
          else{
            newItems.get(mapDocumentCV.get(DocId)).adderror(STR_ERROR_MESSAGE);
          }
       }
     }
   }
  }
  return false;
}
  /**
  * @author       Vaibhav Kudesia (Deloitte)
  * @description  get Object linked to document
  * @param        Map<ID, ContentVersion> newItems
  * @return       void
  */
  public
  static Map<String, Boolean> processObjects(Map<String, set<Id>> mapObjectList, Map<String, Boolean> mapObjError) {
        
  if (mapObjectList.isEmpty() || mapObjectList.keyset().size() <= setCompleted.size()) {
    return mapObjError;
  }
  String objName;
  for (String strCurrentKey : mapObjectList.keySet()) {
    if (!setCompleted.contains(strCurrentKey)) {
      objName = strCurrentKey;
      setCompleted.add(objName);
      break;
    }
  }
  if (String.isBlank(objName)) {
    return mapObjError;
  }
  if (objName == 'Case') {
    Map<Id, Case> mapCases =
        (Map<Id, Case>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(
          mapCases, mapCases.keyset(), STR_CASE_MDT));
  } else if (objName == 'Contact') {
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusionsForContacts(
            (Map<Id, Contact>) getqueryrecords(objName, mapObjectList.get(objName))));
  } else if (objName == 'Account') {
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusionsForAccount(
            (Map<Id, Account>) getqueryrecords(objName, mapObjectList.get(objName))));
  } else if (objName == 'UAC_apprehendedRelationship__c') {
    Map<Id, UAC_apprehendedRelationship__c> mapRelationships =
        (Map<Id, UAC_apprehendedRelationship__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(
            mapRelationships, mapRelationships.keyset(), STR_RELATIONSHIP_MDT));
  } else if (objName == 'Asset') {
    Map<Id, Asset> mapAssets =
        (Map<Id, Asset>) getqueryrecords(objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(
            mapAssets, mapAssets.keyset(), STR_ASSET_MDT));
  } else if (objName == 'UAC_sir__c') {
    Map<Id, UAC_sir__c> mapSirs =
        (Map<Id, UAC_sir__c>) getqueryrecords(objName, mapObjectList.get(objName));
    mapObjError.put(objName, UC_exclusionLogicService.getInstance().runExclusionsForSIR(mapSirs));
  } else if (objName == 'UAC_Event__c') {
    Map<Id, UAC_Event__c> mapEvent =
        (Map<Id, UAC_Event__c>) getqueryrecords(objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(
            mapEvent, mapEvent.keyset(), STR_EVENT_SOQL));
  } else if (objName == 'UAC_addendum__c') {
    Map<Id, UAC_addendum__c> mapAddendum =
        (Map<Id, UAC_addendum__c>) getqueryrecords(objName, mapObjectList.get(objName));
    mapObjError.put(
        objName, UC_exclusionLogicService.getInstance().runExclusionsForAddendum(mapAddendum));
  } else if (objName == 'UAC_sirNotification__c') {
    Map<Id, UAC_sirNotification__c> mapSirNotification =
        (Map<Id, UAC_sirNotification__c>) getqueryrecords(objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(
            mapSirNotification, mapSirNotification.keyset(), STR_SIRNOTIFICATION_SOQL));
  } else if (objName == 'UAC_individualsInvolvedinIncident__c') {
    Map<Id, UAC_individualsInvolvedinIncident__c> mapIndividualsInvolvedinIncident =
        (Map<Id, UAC_individualsInvolvedinIncident__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapIndividualsInvolvedinIncident,
            mapIndividualsInvolvedinIncident.keyset(),
            STR_INDIVIDUALSINVOLVEDININCIDENT_SOQL));
  } else if (objName == 'UAC_monitoring__c') {
    Map<Id, UAC_monitoring__c> mapTest =
        (Map<Id, UAC_monitoring__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapTest,
            mapTest.keyset(),
            STR_Monitoring_SOQL));
  } else if (objName == 'UAC_monitoringSchedule__c') {
    Map<Id, UAC_monitoringSchedule__c> mapTest =
        (Map<Id, UAC_monitoringSchedule__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapTest,
            mapTest.keyset(),
            STR_Monitoring_Schedule_SOQL));
  } else if (objName == 'UAC_monitor__c') {
    Map<Id, UAC_monitor__c> mapTest =
        (Map<Id, UAC_monitor__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapTest,
            mapTest.keyset(),
            STR_UC_Monitor_SOQL));
  }
  else if (objName == 'UAC_healthEvaluation__c') {
    Map<Id, UAC_healthEvaluation__c> mapHealthEvaluation =
        (Map<Id, UAC_healthEvaluation__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapHealthEvaluation,
            mapHealthEvaluation.keyset(),
            STR_HEALTHEVALUATION_SOQL));
  }
  else if (objName == 'UAC_referralAssessment__c') {
    Map<Id, UAC_referralAssessment__c> mapReferralAssessment =
        (Map<Id, UAC_referralAssessment__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapReferralAssessment,
            mapReferralAssessment.keyset(),
            STR_REFERRAL_ASSESSMENT_SOQL));
  }
  else if (objName == 'UAC_test__c') {
    Map<Id, UAC_test__c> mapTest =
        (Map<Id, UAC_test__c>) getqueryrecords(
            objName, mapObjectList.get(objName));
    mapObjError.put(objName,
        UC_exclusionLogicService.getInstance().runExclusions(mapTest,
            mapTest.keyset(),
            STR_TEST_SOQL));
  }
  if (mapObjectList.keyset().size() > setCompleted.size()) {
    mapObjError = processObjects(mapObjectList, mapObjError);
  }
  return mapObjError;
  }

  
  /**
   * @author       Nithin Malla (Deloitte)
   * @description  get Object linked to Task
   * @param        Map<ID, Task> newItems
   * @return       void
   */
  public
  void runExclusionsForTask(Map<Id, Task> newItems) {
    boolBypassAddError = true ;
    Map<String, set<Id>> mapObjectList = new Map<String, set<Id>>();
    Map<String, Boolean> mapObjError = new Map<String, Boolean>();
    Map<Id, Set<Id>> mapLinkIdTaskList = new Map<Id, Set<Id>>();

    for (Task tsk : newItems.values()) {
      system.debug('tsk List : ' + tsk);
      if (tsk.whoId != null) {
        string objName = tsk.whoId.getsobjecttype().getDescribe().getName();
        if (!mapObjectList.keyset().contains(objName)) {
          mapObjectList.put(objName, new set<Id>{tsk.whoId});
        } else {
          mapObjectList.get(objName).add(tsk.whoId);
        }
          
        if (!mapLinkIdTaskList.keyset().contains(tsk.whoId)) {
            mapLinkIdTaskList.put(tsk.whoId, new Set<Id>{tsk.Id});
        } else {
            mapLinkIdTaskList.get(tsk.whoId).add(tsk.Id);
        }
      } else if (tsk.WhatId != null) {
        string objName = tsk.WhatId.getsobjecttype().getDescribe().getName();
        if (!mapObjectList.keyset().contains(objName)) {
          mapObjectList.put(objName, new set<Id>{tsk.WhatId});
        } else {
          mapObjectList.get(objName).add(tsk.WhatId);
        }
          
        if (!mapLinkIdTaskList.keyset().contains(tsk.WhatId)) {
            mapLinkIdTaskList.put(tsk.WhatId, new Set<Id>{tsk.Id});
        } else {
            mapLinkIdTaskList.get(tsk.WhatId).add(tsk.Id);
        }
      }
    }

    mapObjError = processObjects(mapObjectList, mapObjError);
      
      for (String objName : mapObjError.keyset()) {
          if (!mapObjError.get(objName)) {
              for (Id relatedId : mapObjectList.get(objName)) {
                  system.debug('relatedId List : ' + mapObjectList.get(objName));
                  for (Id recId : mapLinkIdTaskList.get(relatedId)) {
                      system.debug('recId List : ' + mapLinkIdTaskList.get(relatedId));
                      newItems.get(recId).adderror(STR_ERROR_MESSAGE);
                  }
              }
          }
      }
  }

  /**
  * @author       Vaibhav Kudesia (Deloitte)
  * @description  get Object linked to document
  * @param        Map<ID, ContentVersion> newItems
  * @return       void
  */
  public
  static Map<Id, Sobject> getqueryrecords(string Objname, Set<Id> ObjectIds) {

    if (objName == 'Case') {
      return new Map<Id, Case>([Select Id, RecordtypeId from Case where Id =:ObjectIds]);
    } else if (objName == 'Contact') {
      return new Map<Id, Contact>([Select Id, RecordtypeId from Contact where Id =:ObjectIds]);
    } else if (objName == 'Account') {
      return new Map<Id, Account>(
          [Select Id, UC_activeInPath__c, RecordtypeId from Account where Id =:ObjectIds]);
    } else if (objName == 'UAC_apprehendedRelationship__c') {
      return new Map<Id, UAC_apprehendedRelationship__c>(
          [Select Id, UAC_uacLookup__c, RecordtypeId from UAC_apprehendedRelationship__c where Id
            =:ObjectIds]);
    } else if (objName == 'Asset') {
      return new Map<Id, Asset>(
          [Select Id, AccountId, RecordtypeId from Asset where Id =:ObjectIds]);
    } else if (objName == 'UAC_sir__c') {
    Map<Id, UAC_sir__c> mapSirs =
        new Map<Id, UAC_sir__c>([Select Id, RecordtypeId from UAC_sir__c where Id =:ObjectIds]);
    return mapSirs;
  } else if (objName == 'UAC_Event__c') {
    Map<Id, UAC_Event__c> mapEvent = new Map<Id, UAC_Event__c>(
        [Select Id, UAC_programID__c from UAC_Event__c where Id =:ObjectIds]);
    return mapEvent;
  } else if (objName == 'UAC_addendum__c') {
    Map<Id, UAC_addendum__c> mapAddendum = new Map<Id, UAC_addendum__c>(
        [Select Id, RecordtypeId, UAC_eventID__c from UAC_addendum__c where Id =:ObjectIds]);
    return mapAddendum;
  } else if (objName == 'UAC_referralAssessment__c') {
    Map<Id, UAC_referralAssessment__c> mapReferralAssessment = new Map<Id, UAC_referralAssessment__c>(
        [Select Id, RecordtypeId from UAC_referralAssessment__c where Id =:ObjectIds]);
    return mapReferralAssessment;
  } else if (objName == 'UAC_sirNotification__c') {
    Map<Id, UAC_sirNotification__c> mapSirNotification = new Map<Id, UAC_sirNotification__c>(
        [Select Id from UAC_sirNotification__c where Id =:ObjectIds]);
    return mapSirNotification;
  } else if (objName == 'UAC_individualsInvolvedinIncident__c') {
    Map<Id, UAC_individualsInvolvedinIncident__c> mapIndividualsInvolvedinIncident =
        new Map<Id, UAC_individualsInvolvedinIncident__c>(
            [Select Id from UAC_individualsInvolvedinIncident__c where Id =:ObjectIds]);
    return mapIndividualsInvolvedinIncident;
  } else if (objName == 'UAC_monitoring__c') {
    Map<Id, UAC_monitoring__c> mapMonitoring =
        new Map<Id, UAC_monitoring__c>(
            [Select Id from UAC_monitoring__c where Id =:ObjectIds]);
    return mapMonitoring;
  } else if (objName == 'UAC_monitoringSchedule__c') {
    Map<Id, UAC_monitoringSchedule__c> mapMonitoringSchedule =
        new Map<Id, UAC_monitoringSchedule__c>(
            [Select Id from UAC_monitoringSchedule__c where Id =:ObjectIds]);
    return mapMonitoringSchedule;
  } else if (objName == 'UAC_monitor__c') {
    Map<Id, UAC_monitor__c> mapMonitor =
        new Map<Id, UAC_monitor__c>(
            [Select Id from UAC_monitor__c where Id =:ObjectIds]);
    return mapMonitor;
  }
  else if (objName == 'UAC_healthEvaluation__c') {
    Map<Id, UAC_healthEvaluation__c> mapHealthEvaluation =
        new Map<Id, UAC_healthEvaluation__c>(
            [Select Id from UAC_healthEvaluation__c where Id =:ObjectIds]);
    return mapHealthEvaluation;
  }
  else if (objName == 'UAC_test__c') {
    Map<Id, UAC_test__c> mapTest =
        new Map<Id, UAC_test__c>(
            [Select Id from UAC_test__c where Id =:ObjectIds]);
    return mapTest;
  }
  return null;
  }
}