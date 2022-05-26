/**
 * @File Name         : UAC_backgoundCheckEmailService.cls
 * @Description       : This Class handles the email to apex service for handling Background check
 *records.
 * @Group             : UAC_backgoundCheckEmailService
 * @Test Class        : UAC_backgoundCheckEmailServiceTest
 * @Author            : Nithin Malla (Deloitte)
 * @Last Modified By  : Nithin Malla (Deloitte)
 * @Last Modified On  : 09-11-2020
 * Modifications Log
 * Ver       Date                Author                                  Modification
 * 1.0       09-11-2020          Nithin Malla (Deloitte)                 Initial Version
 * 2.0       09-16-2020          Nithin Malla (Deloitte)                 Added custom labels, Flag
 *logic switch 3.0       09-17-2020          Nithin Malla (Deloitte)                 Excluding Is
 *Test Running Context 4.0       09-18-2020          Nithin Malla (Deloitte)                 Updated
 *SOQL to get right back ground records 5.0       09-22-2020          Nithin Malla (Deloitte) Adding
 *substring logic for subject check 6.0       10-27-2020          Nithin Malla (Deloitte) Fixing
 *code scan changes 7.0       10-29-2020          Nithin Malla (Deloitte)                 Fixing
 *multiple attachments logic 8.0       11-05-2020          Nithin Malla (Deloitte) Code Scan fixes
 **/
global without sharing class UAC_backgoundCheckEmailService implements
    Messaging.InboundEmailHandler {

  private
  Static final String ERROR = 'ERROR';

  private
  Static final String ERROR2 = 'ERROR2';

  private
  Static final String BACKGROUND_CHECK_RESULTS = 'BackGround Check Results';

  private
  Static final String BACKGROUND_CHECK = Label.UAC_backgroundCheck;

  /**
   * @description Method to handle email trigger on banckground check
   * @author Nithin Malla (Deloitte) | 9/11/2020
   * @param Messaging.inboundEmail email Messaging.InboundEnvelope env
   * @return Messaging.InboundEnvelope result status
   **/
  global Messaging.InboundEmailResult handleInboundEmail(
      Messaging.inboundEmail email, Messaging.InboundEnvelope env) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    try {
      //<UAC A#>_<SponsorLastName>_<SponsorFirstName>_<ResultCode>
      // 123456789_LastName_FirstName_NGIResponseCode
      List<String> inputString = email.subject.split(Label.UAC_backgroundCheckSplit);
      String alienNumber = inputString.get(0).substringAfter(label.UAC_emailSubjectPrefix).trim();
      String lastName = inputString.get(1);
      String firstName = inputString.get(2);
      String nGIRCode = inputString.get(3);
      String strDateResultTransmittedtoFBICJIS = inputString.get(4);
      String strDateResultReceivedfromFBICJIS = inputString.get(5);
      List<UAC_backgroundCheck__c> exisitngBC = [
        SELECT Id,
        UAC_adultContact__r.UAC_backgroundResultFlag__c,
        UAC_results__c,
        UAC_dateResultsReceived__c,
        UAC_dateRequested__c,
        UAC_adultContact__r.UAC_program__c,
        UAC_adultContact__c,
        UAC_dateResultReceivedFromFBICJIS__c,
        UAC_dateResultTransmittedToFBICJIS__c From UAC_backgroundCheck__c WHERE
            UAC_sponsorApplication__r.Contact.UAC_A__c
        =:alienNumber AND UAC_adultContact__r.FirstName
        =:firstName AND UAC_adultContact__r.LastName
        =:lastName AND UAC_backgroundCheckType__c
        =:Label.UAC_docTypeFBICriminalHistory and UAC_results__c = null LIMIT 1
      ];

      if (exisitngBC.size() > 0) {

        UAC_backgroundCheck__c bGCheckToUpdate = exisitngBC.get(0);

        // Handling Documents attached to the email
        if (email.binaryAttachments.size() > 0)
          handleInboundEmailAttachments(email.binaryAttachments, bGCheckToUpdate);

        // Updating BG Check Record with email information
        bGCheckToUpdate.UAC_results__c = getResultValue(
            bGCheckToUpdate.UAC_adultContact__r.UAC_backgroundResultFlag__c, nGIRCode);
        bGCheckToUpdate.UAC_dateResultsReceived__c = system.today();
        if (strDateResultTransmittedtoFBICJIS != null && strDateResultTransmittedtoFBICJIS != '') {
          String strYear = strDateResultTransmittedtoFBICJIS.substring(0, 4);
          String strMonth = strDateResultTransmittedtoFBICJIS.substring(4, 6);
          String strDay = strDateResultTransmittedtoFBICJIS.substring(6, 8);
          String strDate = strYear + '-' + strMonth + '-' + strDay;
          bGCheckToUpdate.UAC_dateResultTransmittedToFBICJIS__c = Date.valueOf(strDate);
        }
        if (strDateResultReceivedfromFBICJIS != null && strDateResultReceivedfromFBICJIS != '') {
          String strYear = strDateResultReceivedfromFBICJIS.substring(0, 4);
          String strMonth = strDateResultReceivedfromFBICJIS.substring(4, 6);
          String strDay = strDateResultReceivedfromFBICJIS.substring(6, 8);
          String strDate = strYear + '-' + strMonth + '-' + strDay;
          bGCheckToUpdate.UAC_dateResultReceivedFromFBICJIS__c = Date.valueOf(strDate);
        }
        if (bGCheckToUpdate.UAC_dateRequested__c == null)
          bGCheckToUpdate.UAC_dateRequested__c = system.today();

        if (bGCheckToUpdate != null) {
          update bGCheckToUpdate;
        }

        // Populating the flag on Contact for Validation on Error Flag to Update/Reset
        handleContactUpdate(bGCheckToUpdate.UAC_adultContact__c,
            bGCheckToUpdate.UAC_adultContact__r.UAC_backgroundResultFlag__c,
            nGIRCode);

      } else {
        UAC_errorLog.platformEventErrorLog(
            'No Back Ground Results found for this subject: ' + email.subject,'', 'UAC_backgoundCheckEmailService', '');
      }

      result.success = true;

    } catch (Exception e) {
      result.success = false;
      UAC_errorLog.platformEventErrorLog('Email Sub: ' + email.subject + e.getMessage(),'',
          'UAC_backgoundCheckEmailService',
          e.getStackTraceString());
    }

    // Return the result for the Apex Email Service
    return result;
  }

  Private void handleContactUpdate(Id conId, boolean resultFlag, String nGIRCode) {
    Contact con = new contact(id = conId);
    if (nGIRCode == ERROR) {
      if (resultFlag) {
        con.UAC_backgroundResultFlag__c = false;
      } else {
        con.UAC_backgroundResultFlag__c = true;
      }
    } else {
      con.UAC_backgroundResultFlag__c = false;
    }
    if (con != null) {
      update con;
    }
  }

  Private String getResultValue(boolean result, String nGICode) {

    List<UAC_backgroundCheckUpdate__mdt> backGroundMeta =
        [SELECT Id, Label, UAC_results__c, UAC_nGICode__c FROM UAC_backgroundCheckUpdate__mdt];
    Map<String, String> nGIRToResultMap = new Map<String, String>();

    for (UAC_backgroundCheckUpdate__mdt meta : backGroundMeta) {
      nGIRToResultMap.put(meta.Label, meta.UAC_results__c);
    }

    if (nGICode == ERROR) {
      if (result) {
        nGICode = ERROR2;
      } else {
        nGICode = ERROR;
      }
    }

    return nGIRToResultMap.get(nGICode);
  }

  private
  void handleInboundEmailAttachments(
      List<Messaging.Inboundemail.BinaryAttachment> email, UAC_backgroundCheck__c backGround) {
    List<Attachment> attList = new List<Attachment>();
    List<ContentVersion> conVerListToInsert = new List<ContentVersion>();
    List<ContentWorkspace> firstPublishLocationId =
        [select Id from ContentWorkspace where Name =:BACKGROUND_CHECK_RESULTS limit 1];

    for (Messaging.Inboundemail.BinaryAttachment file : email) {

      ContentVersion cv = new ContentVersion();
      cv.VersionData = file.body;
      cv.Title = file.fileName;
      cv.PathOnClient = file.fileName;
      cv.UAC_documentType__c = Label.UAC_docTypeFBICriminalHistory;
      cv.UAC_dateReceived__c = system.today();
      cv.UAC_backgroundCheck__c = backGround.Id;
      cv.UAC_individual__c = backGround.UAC_adultContact__c;
      cv.RecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                            .get(BACKGROUND_CHECK)
                            .getRecordTypeId();
      if (!Test.isRunningTest() && !firstPublishLocationId.IsEmpty()) {
        cv.FirstPublishLocationId = firstPublishLocationId[0].Id;
      }

      conVerListToInsert.add(cv);
    }

    if (!conVerListToInsert.isEmpty()) {
      insert conVerListToInsert;

      conVerListToInsert =
          [select ContentDocumentId from ContentVersion where id IN:conVerListToInsert];
      List<ContentDocumentLink> conDocLinkToInsert = new List<ContentDocumentLink>();

      for (ContentVersion conVer : conVerListToInsert) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = backGround.id;
        cdl.ContentDocumentId = conVer.ContentDocumentId;
        cdl.ShareType = 'V';
        conDocLinkToInsert.add(cdl);
      }

      if (!conDocLinkToInsert.isEmpty()) {
        insert conDocLinkToInsert;
      }
    }
  }
}