/**
 * @File Name          : UAC_contentVersionTriggerHelper.cls
 * @Description        : Helper method for UAC_contentVersionTriggerHandler
 * @Author             : Ankur Aggarwal (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/29/2020, 2:16:31 PM
 * @Modification Log   :
 * Ver       Date            Author      		             Modification
 * 1.0    6/22/2020   Ankur Aggarwal (Deloitte)     Initial Version
 * 1.1    6/29/2020   Sachet Khanal (Deloitte)      ORRUAC-124 Sponsor Assessment Document Type
 * 1.2    7/8/2020    Issam Awwad (Deloitte)        ORRUAC-1342 new logic on before insert to handle
 * medical and placement auth forms 1.3    7/30/2020   Abhisek Pati(Deloitte)        ORRUAC-265
 * Added logic for P-9A form 1.4	  8/5/2020	  Chaitanya Nandamuri(Deloitte)	ORRUAC-(1767 and 1760)
 * Adding logic for COVID-19 Form and P-11 1.5	  8/25/2020	  Vaibhav Kudesia(Deloitte) ORRUAC-(2128
 * && 2357)  Adding logic correcting Docgen document title and type updated (beforeInsertHelper and
 * added STR_TITLE_SIR, STR_TYPE_PLEREPORT) 1.6    09/02/2020  Ranjith kumar (AI-Vets)       ORRUAC
 * - (1187 and 2436) Adding logic to update Title on change of Document Type
 * 1.7	  9/14/2020	  Rahul Roy(Deloitte)	          ORRUAC-2115 Adding logic correcting Docgen
 * document title for Legal 1.8    9/21/2020	  Rahul Roy(Deloitte)	          ORRUAC-2370 Adding
 * logic Post Release NOC document 1.9    10/27/2020	Rahul Roy(Deloitte)	          ORRUAC-2807
 * Adding logic Notice of Transfer to ICE document
 * 1.10   06/10/2020    Abhisek Pati (Deloitte)   ORRUAC-5858 Changed Sharing to accomodate
 * compliance forms
 * */
public
without sharing class UAC_contentVersionTriggerHelper {
  private
  static final Schema.DescribeSObjectResult OBJ_SCHEMA_TYPE = Schema.SObjectType.ContentVersion;
  public
  static final Id idPostReleaseRecordType = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
                                                .get(Label.UAC_contentVersionRecordTypePostRelease)
                                                .getRecordTypeId();
  public
  static final Id idLegalDocumentRecordType = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
                                                  .get(label.UAC_legalDocument)
                                                  .getRecordTypeId();
  public
  static final Id idCaseCoordinationRecordType = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
                                                     .get('UAC_caseCoordinationAndDischarge')
                                                     .getRecordTypeId();
  public
  final static Id ID_RECORD_TYPE_SPONSOR_ASSESSMENT =
      OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contentVersionRecordTypeApiNameSponsorAssessment)
          .getRecordTypeId();
  public
  final static Id ID_RECORD_TYPE_SIR_PLE_REPORT_DOCUMENT =
      OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contentVersionRecordTypeApiNameSIRPLEReportDocument)
          .getRecordTypeId();
  public
  final static Id ID_RECORD_TYPE_OTHER = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
                                             .get(Label.UAC_contentVersionRecordTypeApiNameOther)
                                             .getRecordTypeId();
  public
  final static Id ID_RECORD_TYPE_MEDICAL_DOCUMENT =
      OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contentVersionRecordTypeApiNamemedicaldocument)
          .getRecordTypeId();
  public
  final static Id ID_RECORD_TYPE_CASE_MANAGEMENT =
      OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contentVersionRecordTypeApiNameCM)
          .getRecordTypeId();
  public final static Id ID_RECORD_TYPE_HS_ASSESS = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName().get(Label.UC_contentVersionhSPrsAssessRecType).getRecordTypeId();          
  // ORRUAC-2997
  public
  static final Id idLegacyDocRecordTypeId = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
                                                .get('UAC_legacyDocuments')
                                                .getRecordTypeId();

  private
  final static String STR_TITLE_SPONSOR_ASSESSMENT = 'Sponsor Assessment';
  private
  final static String STR_TITLE_SIR = 'SIR';
  private
  final static String STR_TYPE_PLEREPORT = 'Program-Level Event Report';
  private
  final static String strPlacementAuthorizationDocumentType =
      Label.UAC_placementAuthorizationDocumentType;

  private
  final static String strMedicalAuthorizationDocumentType =
      Label.UAC_medicalAuthorizationDocumentType;

  private
  final static String strNoticeOfPlacementDocumentType = Label.UAC_noticeOfPlacementDocumentType;

  private
  final static String strUACAssessmentsDocumentType = Label.UAC_uacAssessmentsDocumentType;

  public
  static final String strVerificationOfRelease = 'Verification of Release';
  public
  static final String strReleaseRequest = 'Release Request';
  public
  static final String strDischargeNotification = 'Discharge Notification';
  public
  static final String strORRNoticeToICE = 'ORR Notice to ICE';
  public
  static final String strFormChangeofVenue = 'Form (Change of Venue)';
  public
  static final String strPrsEventReport = 'PRS Event Report';
  public
  static final String strFormPlacementIdentificationNotification =
      'Placement Identification Document';
  public
  static final String strLTFCMemoDoctype = 'LTFC Memo';
  public
  static final String strAdmissionAssessment = 'Admission Assessment';
  public
  static final String strInfTsFacChklst = 'Influx Transfer Facility Checklist';
  public
  static final String strHsAssess = Label.UC_contentVersionhSPrsAssessDocType;
  public
  static final String strPostLegalStatusPlanDocType = Label.UAC_postLegalStatusPlanDocumentType;
  public
  static final String strNOCDocumentType = Label.UAC_nocDocumentType;
  public
  static final String strManifestDocumentType = Label.UAC_manifestDocumentType;
  public
  static final String strPrsEventDocType = Label.UC_contentVersionPrsEventDocType;  
  public
  static final String strManifestDocumentTitle = Label.UAC_manifestDocumentTitle;
  public
  static final String strLegacyDocumentType = Label.UAC_legacyDocumentTypeName;  // ORRUAC-2997
  public
  static final String strfileNameforWave = Label.UAC_fileNameForWave;
  public
  static final String strContentVersionDocumentTypeOther =
      Label.UAC_contentVersionDocumentTypeOther;
  public
  static final String strNoticeOfTransferToICEDocumentType =
      Label.UAC_noticeOfTransferToICEDocumentType;
  // clang-format off
  private
  static Map<String, String> mapDocTypesToTimestamps =
      new Map<String, String>{'Placement Authorization' => 'UAC_uploadTimestampPlacementAuth__c',
          'Initial Education Intake Assessment' => 'UAC_uploadTimestampEdAssessment__c',
          'Form (Legal Resource Guide Part II - Admission)' => 'UAC_uploadTimestampLegResource__c',
          'Medical Authorization' => 'UAC_uploadTimestampAuthMedical__c',
          'DHS Document (NTA)' => 'UAC_uploadTimestampSuppDocRef__c'};
  // clang-format on

  public
  static void ReleaseRequestOrDischarge(List<ContentVersion> lstContentVersion) {

    for (ContentVersion cvRecs : lstContentVersion) {
      if (cvRecs.Title.contains(strVerificationOfRelease)) {
        cvRecs.recordtypeid = idCaseCoordinationRecordType;
        cvRecs.UAC_documentType__c = strVerificationOfRelease;
      } else if (cvRecs.Title.contains(strReleaseRequest)) {
        cvRecs.recordtypeid = idCaseCoordinationRecordType;
        cvRecs.UAC_documentType__c = strReleaseRequest;
      } else if (cvRecs.Title.contains(strDischargeNotification)) {
        cvRecs.recordtypeid = idCaseCoordinationRecordType;
        cvRecs.UAC_documentType__c = strDischargeNotification;
      } else if (cvRecs.Title.contains(strORRNoticeToICE)) {
        cvRecs.recordtypeid = idCaseCoordinationRecordType;
        cvRecs.UAC_documentType__c = strORRNoticeToICE;
      } else if (cvRecs.Title.contains(strNoticeOfTransferToICEDocumentType)) {
        cvRecs.recordtypeid = idCaseCoordinationRecordType;
        cvRecs.UAC_documentType__c = strNoticeOfTransferToICEDocumentType;
      }
    }
  }
  /* @author     Priyanka Bolla
    @description  Updating the title on insert of docgen content version doc
    running code
    @param        N/A
    @return       void
    */
  public
  static void beforeInsertHelper(List<ContentVersion> lstContentVersion) {
    Map<Id, Case> mapIdToCase = handleParentCaseOnInsert(lstContentVersion);
    Map<Id, Contact> mapIdToContact = handleContactOnInsert(lstContentVersion);
    List<ContentVersion> listContentVersionForTimestampUpdate = new List<ContentVersion>();
    List<ContentVersion> listContentVersionForFRP = new List<ContentVersion>();
    for (ContentVersion objContentVersion : lstContentVersion) {
      if (objContentVersion.RecordTypeId != null
          && objContentVersion.RecordTypeId != idCaseCoordinationRecordType) {
        if (objContentVersion.Title.contains('[DOCGEN]')) {
          // ORRUAC-124 Handle DocGen Sponsor Assessment Document Type
          if (objContentVersion.Title.contains(STR_TITLE_SPONSOR_ASSESSMENT)) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_SPONSOR_ASSESSMENT;
            objContentVersion.UAC_documentType__c =
                (objContentVersion.Title.contains(
                    Label.UAC_caseSponsorAssessmentGenerationVersionInitial))
                ? Label.UAC_caseSponsorAssessmentGenerationVersionInitial
                : Label.UAC_caseSponsorAssessmentGenerationVersionFinal;
          } else if (objContentVersion.Title.contains(STR_TITLE_SIR)) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_SIR_PLE_REPORT_DOCUMENT;
            if (objContentVersion.Title.contains(STR_TYPE_PLEREPORT)) {
              objContentVersion.UAC_documentType__c = Label.UAC_programLevelReportType;
            } else {
              objContentVersion.UAC_documentType__c = Label.UAC_significantIncidentReportType;
            }
            objContentVersion.Title = objContentVersion.Title.substringAfter('##');
          } else if (objContentVersion.Title.contains('Influx Transfer Facility Checklist')) {
            objContentVersion.recordtypeid = ID_RECORD_TYPE_CASE_MANAGEMENT;
            objContentVersion.UAC_documentType__c = strInfTsFacChklst;
          } else if (objContentVersion.Title.contains('Assessment for Risk')
              || objContentVersion.Title.contains('UC Assessment')
              || objContentVersion.Title.contains('Individual Service Plan')
              || objContentVersion.Title.contains('Initial Intake Assessment')
              || objContentVersion.Title.contains('UC Case Review')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_CASE_MANAGEMENT;
            objContentVersion.UAC_documentType__c = strAdmissionAssessment;
          } else if (objContentVersion.Title.contains('TAB C')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = strPlacementAuthorizationDocumentType;
          } else if (objContentVersion.Title.contains('TAB D')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = strMedicalAuthorizationDocumentType;
          } else if (objContentVersion.Title.contains('P-4')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = strNoticeOfPlacementDocumentType;
          } else if (objContentVersion.Title.contains('S-16')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = strUACAssessmentsDocumentType;
          } else if (objContentVersion.Title.contains('P-9A')
              || objContentVersion.Title.contains('P-9B')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_MEDICAL_DOCUMENT;
            objContentVersion.UAC_documentType__c = Label.UAC_medicalChecklistDocumentType;
          } else if (objContentVersion.Title.contains('Covid-19')
              || objContentVersion.Title.contains('P-11')) {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_CASE_MANAGEMENT;
            objContentVersion.UAC_documentType__c = Label.UAC_transferDocumentType;
          } else if (objContentVersion.Title.contains(strFormChangeofVenue)) {
            objContentVersion.recordtypeid = idLegalDocumentRecordType;
            objContentVersion.UAC_documentType__c = strFormChangeofVenue;
          } else if (objContentVersion.Title.contains(strPrsEventReport)) {
            objContentVersion.recordtypeid = ID_RECORD_TYPE_HS_ASSESS;
            objContentVersion.UAC_documentType__c = strPrsEventDocType;
          } else if (objContentVersion.Title.contains(strFormPlacementIdentificationNotification)) {
            objContentVersion.recordtypeid = idLegalDocumentRecordType;
            objContentVersion.UAC_documentType__c = strFormPlacementIdentificationNotification;
          } else if (objContentVersion.Title.contains(strPostLegalStatusPlanDocType)) {
            objContentVersion.recordtypeid = idLegalDocumentRecordType;
            objContentVersion.UAC_documentType__c = strPostLegalStatusPlanDocType;
          } else if (objContentVersion.Title.contains(strNOCDocumentType)) {
            objContentVersion.recordtypeid = idPostReleaseRecordType;
            objContentVersion.UAC_documentType__c = strNOCDocumentType;
          } else if (objContentVersion.Title.contains(strfileNameforWave)) {
            objContentVersion.recordtypeid = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = strContentVersionDocumentTypeOther;
          } else if (objContentVersion.Title.contains(strManifestDocumentTitle)) {
            objContentVersion.recordtypeid = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = strManifestDocumentType;
          } else if (objContentVersion.Title.contains('LTFC Memo')) {
            objContentVersion.recordtypeid = ID_RECORD_TYPE_CASE_MANAGEMENT;
            objContentVersion.UAC_documentType__c = strLTFCMemoDoctype;
          } else {
            objContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
            objContentVersion.UAC_documentType__c = Label.UAC_docgenDocumentType;
          }
          objContentVersion.UAC_otherDocumentType__c = objContentVersion.UAC_documentType__c;
          objContentVersion.Title = objContentVersion.Title.replace('[DOCGEN]','');
        } else if (objContentVersion.UAC_documentType__c == strLegacyDocumentType) {  // ORRUAC-2997
          objContentVersion.recordTypeid = idLegacyDocRecordTypeId;
          objContentVersion.UAC_originalTitle__c = objContentVersion.Title;
        } else if (objContentVersion.Title.contains(strHsAssess)) {
          objContentVersion.recordtypeid = ID_RECORD_TYPE_HS_ASSESS;
          objContentVersion.UAC_documentType__c = strHsAssess;
        }  /*else if (objContentVersion.Title.contains('Influx Transfer Facility Checklist')) {
          objContentVersion.recordtypeid = ID_RECORD_TYPE_CASE_MANAGEMENT;
          objContentVersion.UAC_documentType__c = strInfTsFacChklst;
        }*/
        else if (objContentVersion.UAC_documentType__c
            == Label.UAC_contentVersionDocumentTypeFRP2) {
          listContentVersionForFRP.add(objContentVersion);
        }
        // Added for ORRUAC-1398 - starts
        /* else if (objContentVersion.Title.contains('Assessment for Risk')) {
           objContentVersion.RecordTypeId = ID_RECORD_TYPE_CASE_MANAGEMENT;
           objContentVersion.UAC_documentType__c = 'Admission Assessment';
         }*/
        // Added for ORRUAC-1398 - ends
        else {
          objContentVersion.UAC_originalTitle__c = objContentVersion.Title;
          String uacAnum = '';
          if (mapIdToCase.containsKey(objContentVersion.FirstPublishLocationId)) {
            uacAnum = mapIdToCase.get(objContentVersion.FirstPublishLocationId).UAC_aNum__c;
          } else if (String.isNotBlank(objContentVersion.UAC_a__c)) {
            uacAnum = objContentVersion.UAC_a__c;
          } else if (mapIdToContact.containsKey(objContentVersion.FirstPublishLocationId)) {
            uacAnum = mapIdToContact.get(objContentVersion.FirstPublishLocationId).UAC_a__c;
          }
          objContentVersion.Title = objContentVersion.UAC_documentType__c + ' ' + uacAnum + ' '
              + System.now().format('MM-dd-yyyy_HH:mm:ss');
        }
      }
      if (String.isNotBlank(objContentVersion.FirstPublishLocationId)
          && objContentVersion.FirstPublishLocationId.getsObjectType().getDescribe().getName()
              == 'Case'
          && mapDocTypesToTimestamps.containsKey(objContentVersion.UAC_documentType__c)) {
        listContentVersionForTimestampUpdate.add(objContentVersion);
      }
    }
    if (!listContentVersionForTimestampUpdate.isEmpty()) {
      updateParentCaseTimestamps(listContentVersionForTimestampUpdate);
    }
    if (!listContentVersionForFRP.isEmpty()) {
      setDateARIReceieved(listContentVersionForFRP);
    }
  }

  /* @author     Ranjith kumar
    @description  Updating the title on Change of Document type
    running code
    @param        N/A
    @return       void
    */
  public
  static void beforeUpdatetHelper(
      List<ContentVersion> lstContentVersion, Map<Id, ContentVersion> mapOldContVer) {
    for (ContentVersion objContentVersion : lstContentVersion) {
      ContentVersion oldContentVersion = mapOldContVer.get(objContentVersion.Id);
      if (oldContentVersion.UAC_documentType__c != objContentVersion.UAC_documentType__c
          && oldContentVersion.Title.Contains(oldContentVersion.UAC_documentType__c)) {
        objContentVersion.Title = oldContentVersion.Title.Replace(
            oldContentVersion.UAC_documentType__c, objContentVersion.UAC_documentType__c);
      }
    }
  }

  /**
   * @author       James Qian (Deloitte)
   * @description  Adds logic to set parent lookup fields automatically
   * @param        List<ContentVersion>
   * @return       Map<Id, Case>
   */
  private
  static Map<Id, Case> handleParentCaseOnInsert(List<ContentVersion> lstContentVersion) {
    Map<Id, Case> mapIdToCase = new Map<Id, Case>();
    List<ContentVersion> listContentVersionsToProcess = new List<ContentVersion>();
    for (ContentVersion contentVersionCurrent : lstContentVersion) {
      if (String.isNotBlank(contentVersionCurrent.FirstPublishLocationId)
          && contentVersionCurrent.FirstPublishLocationId.getsObjectType().getDescribe().getName()
              == 'Case') {
        listContentVersionsToProcess.add(contentVersionCurrent);
        mapIdToCase.put(contentVersionCurrent.FirstPublishLocationId, null);
        if (String.isBlank(contentVersionCurrent.UAC_entry__c)) {
          contentVersionCurrent.UAC_entry__c = contentVersionCurrent.FirstPublishLocationId;
        }
      }
    }
    if (mapIdToCase.isEmpty()) {
      return mapIdToCase;
    }
    for (Case caseCurrent :
        [SELECT Id, UAC_aNum__c, ContactId FROM Case WHERE Id IN:mapIdToCase.keyset()]) {
      mapIdToCase.put(caseCurrent.Id, caseCurrent);
    }
    for (ContentVersion contentVersionCurrent : listContentVersionsToProcess) {
      if (String.isBlank(contentVersionCurrent.UAC_individual__c)) {
        contentVersionCurrent.UAC_individual__c =
            mapIdToCase.get(contentVersionCurrent.FirstPublishLocationId).ContactId;
      }
    }
    return mapIdToCase;
  }

  /**
   * @author       Rahul Roy (Deloitte)
   * @description  Retrieve Contact
   * @param        List<ContentVersion>
   * @return       Map<Id, Contact>
   */
  private
  static Map<Id, Contact> handleContactOnInsert(List<ContentVersion> lstContentVersion) {
    Map<Id, Contact> mapIdToContact = new Map<Id, Contact>();
    List<ContentVersion> listContentVersionsToProcess = new List<ContentVersion>();
    for (ContentVersion contentVersionCurrent : lstContentVersion) {
      if (String.isNotBlank(contentVersionCurrent.FirstPublishLocationId)
          && contentVersionCurrent.FirstPublishLocationId.getsObjectType().getDescribe().getName()
              == 'Contact') {
        listContentVersionsToProcess.add(contentVersionCurrent);
        mapIdToContact.put(contentVersionCurrent.FirstPublishLocationId, null);
      }
    }
    if (mapIdToContact.isEmpty()) {
      return mapIdToContact;
    }
    for (Contact currentContact :
        [SELECT Id, UAC_a__c FROM Contact WHERE Id IN:mapIdToContact.keyset()]) {
      mapIdToContact.put(currentContact.Id, currentContact);
    }
    return mapIdToContact;
  }
  /**
   * @author       Sarang Padhye (Deloitte)
   * @description  Check if source is an Entity
   * @param        contentVersion objContentVersion
   * @return       boolean
   */
  public
  static boolean isObjectEntity(contentVersion objContentVersion) {

    return String.isNotBlank(objContentVersion.FirstPublishLocationId)
        && objContentVersion.FirstPublishLocationId.getsObjectType().getDescribe().getName()
        == 'Account';
  }
  /**
   * @author       Sarang Padhye (Deloitte)
   * @description  Update Title for Entity doc upload
   * @param        Map<ID, ContentVersion> mapEntityDocs
   * @return       coid
   */
  public
  static void handleEntityDocuments(List<contentVersion> lstEntityDocs) {
    set<Id> setEntityIds = new set<ID>();
    String strCurGrantNumber = null;
    list<contentVersion> contentVersionsToUpdate = new list<contentVersion>();
    for (ContentVersion cv : lstEntityDocs) {
      setEntityIds.add(cv.FirstPublishLocationId);
    }
    Map<id, Account> mapAccount = new map<Id, Account>(
        [select id, UAC_Grant_Number__c from Account where id in:setEntityIds]);
    for (ContentVersion cv : lstEntityDocs) {
      strCurGrantNumber = mapAccount.get(cv.FirstPublishLocationId).UAC_Grant_Number__c;
      if (strCurGrantNumber != null) {
        cv.Title = cv.UAC_documentType__c + '_' + strCurGrantNumber + '_'
            + cv.createdDate.format('MM-dd-yyyy_HH:mm:ss');
      } else {
        cv.Title = cv.UAC_documentType__c + ' ' + cv.createdDate.format('MM-dd-yyyy_HH:mm:ss');
      }
    }
  }
  /**
   * @author       Sarang Padhye (Deloitte)
   * @description  ORRUAC-2997 Update Title before for Legacy Documents before Update
   * @param        Map<ID, ContentVersion> mapEntityDocs
   * @return       coid
   */
  public
  static void handleLegacyDocumentsBeforeUpdate(
      Map<id, ContentVersion> newItems, Map<id, ContentVersion> oldItems) {
    Set<id> setContentDocId = new set<Id>();
    Map<Id, String> mapContactToAnum = new Map<Id, String>();
    Map<id, Id> mapCntDocToContact = new Map<Id, Id>();
    List<ContentVersion> legacyDocCvs = new List<ContentVersion>();

    for (contentVersion cV : newItems.values()) {
      if (cv.recordtypeid == idLegacyDocRecordTypeId) {
        setContentDocId.add(cV.ContentDocumentId);
        legacyDocCvs.add(cv);
      }
    }
    if (legacyDocCvs == null || legacyDocCvs.isEmpty()) return;

    Map<id, ContentDocumentLink> mapCdl = new Map<id, ContentDocumentLink>([select id,
      ContentDocumentId,
      ContentDocument.LatestPublishedVersionId,
      LinkedEntityId,
      LinkedEntity.Type from ContentDocumentLink where ContentDocumentId in:setContentDocId]);
    for (ContentDocumentLink cdl : mapCdl.values()) {
      String linkedEntityId = cdl.LinkedEntityId;
      if (linkedEntityId.startsWith('003')
          && newItems.containsKey(cdl.ContentDocument.LatestPublishedVersionId)
          && newItems.get(cdl.ContentDocument.LatestPublishedVersionId) != null) {
        mapContactToAnum.put(cdl.LinkedEntityId, null);
        mapCntDocToContact.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
      }
    }
    List<Contact> lstContacts =
        [select id, UAC_a__c from contact where id =:mapContactToAnum.keyset()];

    for (Contact c : lstContacts) {
      mapContactToAnum.put(c.id, c.UAC_a__c);
    }
    for (contentVersion cv : legacyDocCvs) {
      if (cv.UAC_documentType__c != oldItems.get(cv.id).UAC_documentType__c) {
        Id idContact = mapCntDocToContact.get(cv.ContentDocumentId);
        String strUacNum = '';
        if (idContact != null) {
          strUacNum = mapContactToAnum.get(idContact);
        }
        if (strUacNum != null) {
          cv.title = cv.UAC_documentType__c + ' ' + strUacNum + ' '
              + System.now().format('MM-dd-yyyy_HH:mm:ss');
        }
      }
    }
  }

  /** @author      James Qian
   * @description  Sets timestamp fields on parent Cases during insert
   * @param        List<ContentVersion> listContentVersionForTimestampUpdate
   * @return       void
   **/
  private
  static void updateParentCaseTimestamps(
      List<ContentVersion> listContentVersionForTimestampUpdate) {
    Map<Id, Case> mapCasesToUpdate = new Map<Id, Case>();
    for (ContentVersion objContentVersion : listContentVersionForTimestampUpdate) {
      Case objCase;
      if (mapCasesToUpdate.containsKey(objContentVersion.FirstPublishLocationId)) {
        objCase = mapCasesToUpdate.get(objContentVersion.FirstPublishLocationId);
      } else {
        objCase = new Case(Id = objContentVersion.FirstPublishLocationId);
      }
      objCase.put(mapDocTypesToTimestamps.get(objContentVersion.UAC_documentType__c), System.Now());
      mapCasesToUpdate.put(objCase.Id, objCase);
    }
    if (!mapCasesToUpdate.isEmpty() && !mapCasesToUpdate.values().isEmpty()) {
      try {
        update mapCasesToUpdate.values();
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error updating Parent Entry to acknowledge upload: ' + e.getStackTraceString(),
            e.getStackTraceString());
      }
    }
  }
  /* @author     Issam Awwad
  @description  If the User changes the ARI-2 document to another record type/document type besides
  the ARI-2, blank out the "Date ARI Received" on the background check running code
  @param        N/A
  @return       void
  */
  public
  static void eraseDateARIReceieved(
      Map<Id, ContentVersion> newItems, Map<Id, ContentVersion> oldItems) {
    Set<Id> setOfSponsorApp = new Set<Id>();
    Map<Id, List<UAC_backgroundCheck__c>> mapOfSponsorToBackground =
        new Map<Id, List<UAC_backgroundCheck__c>>();
    for (ContentVersion objContentVersion : newItems.values()) {
      setOfSponsorApp.add(objContentVersion.FirstPublishLocationId);
    }
    List<UAC_backgroundCheck__c> lstOfBackgroundCheck = [
      SELECT Id,
      UAC_dateARIReceived__c,
      UAC_sponsorApplication__c FROM UAC_backgroundCheck__c WHERE UAC_sponsorApplication__c
      IN:setOfSponsorApp AND UAC_backgroundCheckType__c
       =:Label.UAC_bcgTypeFBICriminalHistory
    ];
    for (UAC_backgroundCheck__c objBackground : lstOfBackgroundCheck) {
      List<UAC_backgroundCheck__c> lstOfBackground = new List<UAC_backgroundCheck__c>();
      if (mapOfSponsorToBackground.containsKey(objBackground.UAC_sponsorApplication__c)) {
        lstOfBackground = mapOfSponsorToBackground.get(objBackground.UAC_sponsorApplication__c);
        lstOfBackground.add(objBackground);
        mapOfSponsorToBackground.put(objBackground.UAC_sponsorApplication__c, lstOfBackground);
      } else {
        lstOfBackground.add(objBackground);
        mapOfSponsorToBackground.put(objBackground.UAC_sponsorApplication__c, lstOfBackground);
      }
    }
    List<UAC_backgroundCheck__c> lstOfBackgroundCheckToUpdate = new List<UAC_backgroundCheck__c>();
    for (ContentVersion objContentVersion : newItems.values()) {
      Boolean boolUpdatedARI = false;
      ContentVersion objOldContentVersion = oldItems.get(objContentVersion.Id);
      if (objOldContentVersion.UAC_documentType__c == Label.UAC_contentVersionDocumentTypeFRP2
          && objContentVersion.UAC_documentType__c != objOldContentVersion.UAC_documentType__c) {
        boolUpdatedARI = true;
      }

      if (boolUpdatedARI) {
        for (UAC_backgroundCheck__c objBackground :
            mapOfSponsorToBackground.get(objContentVersion.FirstPublishLocationId)) {
          if (objBackground.UAC_dateARIReceived__c == objContentVersion.UAC_dateReceived__c) {
            objBackground.UAC_dateARIReceived__c = null;
            lstOfBackgroundCheckToUpdate.add(objBackground);
          }
        }
      }
    }
    if (!lstOfBackgroundCheckToUpdate.isEmpty()) {
      try {
        update lstOfBackgroundCheckToUpdate;
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error updating background check ' + e.getStackTraceString(),
            e.getStackTraceString());
      }
    }
  }
  /* @author     Issam Awwad
  @description  set date ari recieved on background check
  @param        N/A
  @return       void
  */
  public
  static void setDateARIReceieved(List<ContentVersion> lstOfFRPForms) {
    Map<Id, ContentVersion> mapOfSponsorAppToContent = new Map<Id, ContentVersion>();
    List<UAC_backgroundCheck__c> lstOfBackgroundCheckToUpdate = new List<UAC_backgroundCheck__c>();
    Set<Id> setOfSponsorApp = new Set<Id>();
    for (ContentVersion objContentVersion : lstOfFRPForms) {
      mapOfSponsorAppToContent.put(objContentVersion.FirstPublishLocationId, objContentVersion);
    }

    List<UAC_backgroundCheck__c> lstOfBackgroundCheck = [
      SELECT Id,
      UAC_dateARIReceived__c,
      UAC_sponsorApplication__c FROM UAC_backgroundCheck__c WHERE UAC_sponsorApplication__c
      IN:mapOfSponsorAppToContent.keySet() AND UAC_backgroundCheckType__c
       =:Label.UAC_bcgTypeFBICriminalHistory
    ];
    for (UAC_backgroundCheck__c objBackgroundCheck : lstOfBackgroundCheck) {
      if (mapOfSponsorAppToContent.containsKey(objBackgroundCheck.UAC_sponsorApplication__c)) {
        objBackgroundCheck.UAC_dateARIReceived__c =
            mapOfSponsorAppToContent.get(objBackgroundCheck.UAC_sponsorApplication__c)
                .UAC_dateReceived__c;
        lstOfBackgroundCheckToUpdate.add(objBackgroundCheck);
      }
    }
    if (!lstOfBackgroundCheckToUpdate.isEmpty()) {
      try {
        update lstOfBackgroundCheckToUpdate;
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error updating background check ' + e.getStackTraceString(),
            e.getStackTraceString());
      }
    }
  }
  /**
   * @author       Sudeep Chintala (Deloitte)
   * @description  Document type check for user onboarding
   * @param        Map<ID, ContentVersion> mapEntityDocs
   * @return       void
   */
  public
  static void afterInsertHelper(Map<Id, ContentVersion> newItems) {
    String strContentVersionIds = '';
    Map<Id, UAC_AccountRequestForm__c> mapARFForUpdate = new Map<Id, UAC_AccountRequestForm__c>();
    Id contentversionRecordTypeId = OBJ_SCHEMA_TYPE.getRecordTypeInfosByDeveloperName()
                                        .get('Uac_Compliance_Forms')
                                        .getRecordTypeId();
    Schema.SObjectType objType = Schema.UAC_AccountRequestForm__c.SObjectType;
    for (ContentVersion c : newItems.values()) {
      // adding content version ids to variable for platform event
      if (strContentVersionIds == '') {
        strContentVersionIds = c.Id;
      } else {
        strContentVersionIds = strContentVersionIds + ', ' + c.Id;
      }
      if (c.RecordTypeId != contentversionRecordTypeId || c.FirstPublishLocationId == null
          || c.FirstPublishLocationId.getSobjectType() != objType) {
        continue;
      }
      UAC_AccountRequestForm__c objARF;
      if (mapARFForUpdate.containsKey(c.FirstPublishLocationId)) {
        objARF = mapARFForUpdate.get(c.FirstPublishLocationId);
      } else {
        objARF = new UAC_AccountRequestForm__c(Id = c.FirstPublishLocationId);
      }
      if (c.UAC_documentType__c == 'ROB') {
        objARF.UAC_ROB_Uploaded__c = true;
      } else if (c.UAC_documentType__c == 'Cybersecurity') {
        objARF.UAC_Cyber_Security_Uploaded__c = True;
      } else if (c.UAC_documentType__c == 'Privacy 101') {
        objARF.UAC_Privacy_101_Uploaded__c = True;
      } else {
        continue;
      }
      mapARFForUpdate.put(c.FirstPublishLocationId, objARF);
    }
    if (mapARFForUpdate != null && !mapARFForUpdate.isEmpty()) {
      try {
        update mapARFForUpdate.values();
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error updating Account Request Forms: ' + e.getStackTraceString(),
            e.getStackTraceString());
      }
    }
    UC_contentPlatformEvt.platformEventContent('Insert', strContentVersionIds, 'ContentVersion');
  }

  /**
   * @author       Issam Awwad (Deloitte)
   * @description  After update helper
   * @param        Map<ID, ContentVersion> newItems
   * @return       void
   */
  public
  static void afterUpdateHelper(Map<Id, ContentVersion> newItems) {
    String strContentVersionIds = '';
    for (ContentVersion c : newItems.values()) {
      if (strContentVersionIds == '') {
        strContentVersionIds = c.Id;
      } else {
        strContentVersionIds = strContentVersionIds + ', ' + c.Id;
      }
    }
    UC_contentPlatformEvt.platformEventContent('Update', strContentVersionIds, 'ContentVersion');
  }
}