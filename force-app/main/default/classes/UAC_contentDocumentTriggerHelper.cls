/**
 * @File Name          : UAC_contentDocumentTriggerHelper.cls
 * @Description        : Helper method for UAC_contentDocumentTriggerHandler
 * @Author             : Piyush(Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author                Modification
 * 1.0    7/21/2020      Piyush(Deloitte)     Initial Version
 **/
public
with sharing class UAC_contentDocumentTriggerHelper {
  public
  static final Id idHSPRSDocRecType =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('UAC_hsPrsDocumentsRecType')
          .getRecordTypeId();
  public
  static final String strCustomPermissionHSPRSProvider = Label.UAC_CustomPermissionHSPRSProvider;
  public
  static final String strCaseStatusCompleted = Label.UAC_caseStatusCompleted;
  public
  static final String strCaseStatusDnfGen = Label.UAC_caseStatusDnfGen;
  public
  static final string strcaseRecordTypeReleaseRequest = Label.UAC_caseRecordTypeReleaseRequest;
  public
  static final List<String> lstCaseStatus =
      New List<String>{strCaseStatusCompleted, strCaseStatusDnfGen};

  /*@author    Piyush
  @description:ORRUAC-865 before Delete trigger validation to prevent document delete after 60 days
  @param        N/A
  @return       void
  */
  public
  static void preventHSPRSDocDel(Map<Id, ContentDocument> mapOldContVer) {
    Set<Id> setLnkEntIds = new Set<Id>();
    Map<Id, ContentDocumentLink> mapCntDocIdToLnk = new Map<Id, ContentDocumentLink>();
    List<ContentDocumentLink> lstCntDocLnk = [Select Id,
      LinkedEntityId,
      ContentDocumentId from ContentDocumentLink where ContentDocumentId in:mapOldContVer.keyset()];
    for (ContentDocumentLink objCntlnk : lstCntDocLnk) {
      if (objCntlnk.LinkedEntityId != null) {
        mapCntDocIdToLnk.put(objCntlnk.ContentDocumentId, objCntlnk);
        setLnkEntIds.add(objCntlnk.LinkedEntityId);
      }
    }
    if (!setLnkEntIds.isEmpty()) {
      Map<Id, Case> mapReleaseRequestCase = New Map<Id, Case>([
        Select Id,
        Status from Case Where Id in:setLnkEntIds and Status
                                  in:lstCaseStatus and RecordType.DeveloperName
                                   =:strcaseRecordTypeReleaseRequest
      ]);
      Map<Id, Case> mapHsPrsCase = new Map<Id, Case>(
          [Select Id, UAC_techHsPrsClosedDateTime__c from Case where Id in:setLnkEntIds]);
      for (ContentDocument objCVer : mapOldContVer.values()) {
        // if(objCVer.recordTypeId == idHSPRSDocRecType &&
        // FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)){

        if (mapCntDocIdToLnk.containsKey(objCVer.Id)
            && mapHsPrsCase.containsKey(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId)
            && mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId
                == mapHsPrsCase.get(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId).Id
            && mapHsPrsCase.get(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId)
                    .UAC_techHsPrsClosedDateTime__c
                != null) {
          System.debug('match found & case was closed on '
              + mapHsPrsCase.get(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId)
                    .UAC_techHsPrsClosedDateTime__c.addDays(60));
          if (System.Now() > mapHsPrsCase.get(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId)
                                 .UAC_techHsPrsClosedDateTime__c.addDays(60)) {
            objCVer.addError(Label.UAC_documentHSReferralDeleteErrorMessage);
          }
        }
        if (mapCntDocIdToLnk.containsKey(objCVer.Id)
            && mapReleaseRequestCase.containsKey(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId)
            && mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId
                == mapReleaseRequestCase.get(mapCntDocIdToLnk.get(objCVer.Id).LinkedEntityId).Id) {

          objCVer.addError(Label.UAC_documentReleaseRequestDeleteErrorMessage);
        }

        //}
      }
    }
  }
  /**
   * @description ORRUAC-1805 - Empties out related IDs in contacts after deletion
   * @author James Qian (Deloitte) | 9/24/2020
   * @return void
   **/
  public
  static void deleteContactLinksForPhotos(Map<Id, ContentDocument> mapOldContentDocuments) {
    Map<Id, List<Contact>> mapContentDocumentToContact = new Map<Id, List<Contact>>();
    for (ContentDocument currentContentDocument : mapOldContentDocuments.values()) {
      mapContentDocumentToContact.put(currentContentDocument.Id, new List<Contact>());
    }
    Set<Id> setLinkedEntityIds = new Set<Id>();
    Map<Id, Set<Id>> mapLinkedEntityToContentDocument = new Map<Id, Set<Id>>();
    for (ContentDocumentLink currentCDL :
        [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId
          IN:mapContentDocumentToContact.keyset()]) {
      if (String.valueOf(currentCDL.LinkedEntityId).startsWith('003')) {
        Set<Id> setIdsLinked;
        if (mapLinkedEntityToContentDocument.containsKey(currentCDL.LinkedEntityId)) {
          setIdsLinked = mapLinkedEntityToContentDocument.get(currentCDL.LinkedEntityId);
        } else {
          setIdsLinked = new Set<Id>();
        }
        setIdsLinked.add(currentCDL.ContentDocumentId);
        mapLinkedEntityToContentDocument.put(currentCDL.LinkedEntityId, setIdsLinked);
      }
    }
    if (mapLinkedEntityToContentDocument.isEmpty()) {
      return;
    }
    for (Contact currentContact :
        [SELECT Id, UAC_Profile_pic_Id__c, UAC_jsonFileMap__c FROM Contact WHERE Id
          IN:mapLinkedEntityToContentDocument.keyset()]) {
      for (Id idCD : mapLinkedEntityToContentDocument.get(currentContact.Id)) {
        List<Contact> listContact = mapContentDocumentToContact.get(idCD);
        listContact.add(currentContact);
        mapContentDocumentToContact.put(idCD, listContact);
      }
    }

    Set<Contact> setContacts = new Set<Contact>();
    for (ContentVersion currentContentVersion :
        [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId
          IN:mapContentDocumentToContact.keyset()]) {
      if (mapContentDocumentToContact.get(currentContentVersion.ContentDocumentId).isEmpty()) {
        continue;
      }
      for (Contact currentContact :
          mapContentDocumentToContact.get(currentContentVersion.ContentDocumentId)) {
        if (String.isNotBlank(currentContact.UAC_jsonFileMap__c)
            && currentContact.UAC_jsonFileMap__c.contains(currentContentVersion.Id)) {
          currentContact.UAC_jsonFileMap__c = null;
          currentContact.UAC_Profile_pic_Id__c = null;
          setContacts.add(currentContact);
        }
      }
    }
    if (!setContacts.isEmpty()) {
      List<Contact> listContactsToUpdate = new List<Contact>(setContacts);
      update listContactsToUpdate;
    }
  }
  /* @author     Issam Awwad
 @description  If the User deletes the ARI-2 document to another record type/document type besides
 the ARI-2, blank out the "Date ARI Received" on the background check running code
 @param        N/A
 @return       void
 */
  public
  static void eraseDateARIReceievedOnDelete(Map<Id, ContentDocument> oldItems) {
    List<ContentVersion> lstContentVersion = [SELECT Id,
      ContentDocumentId,
      FirstPublishLocationId,
      UAC_documentType__c,
      UAC_dateReceived__c FROM ContentVersion WHERE ContentDocumentId IN:oldItems.keyset()];
    Set<Id> setOfSponsorApp = new Set<Id>();
    Map<Id, List<UAC_backgroundCheck__c>> mapOfSponsorToBackground =
        new Map<Id, List<UAC_backgroundCheck__c>>();
    for (ContentVersion objContentVersion : lstContentVersion) {
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
    for (ContentVersion objContentVersion : lstContentVersion) {
      if (objContentVersion.UAC_documentType__c == Label.UAC_contentVersionDocumentTypeFRP2) {
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
  /**
   * @author       Issam Awwad (Deloitte)
   * @description  Before delete helper
   * @param        Map<ID, ContentVersion> oldItems
   * @return       void
   */
  public
  static void afterDeleteHelper(Map<Id, ContentDocument> oldItems) {
    String strContentDocumentIds = '';
    for (ContentDocument c : oldItems.values()) {
      if (strContentDocumentIds == '') {
        strContentDocumentIds = c.Id;
      } else {
        strContentDocumentIds = strContentDocumentIds + ', ' + c.Id;
      }
    }
    UC_contentPlatformEvt.platformEventContent('Delete', strContentDocumentIds, 'ContentDocument');
  }
}