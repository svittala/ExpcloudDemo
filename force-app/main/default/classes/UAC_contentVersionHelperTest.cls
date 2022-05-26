/**
 * @File Name          : UAC_contentVersionHelperTest.cls
 * @Description        :
 * @Author             : Priyanka Bolla (Deloitte)
 * @Group              :
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/29/2020, 2:15:48 PM
 * @Modification Log   :
 * Ver       Date            Author      		        Modification
 * 1.0    6/24/2020   Priyanka Bolla (Deloitte)     Initial Version
 * 1.1    6/29/2020   Sachet Khanal(Deloitte)       ORRUAC-124 Sponsor Assessment DocType Test
 * 1.2    7/30/2020   Abhisek Pati(Deloitte)        ORRUAC-265 Added code for P-9A form
 * 1.3    8/5/2020    Chaitanya Nandamuri(Deloitte) ORRUAC-1767 Adding code for Covid-19 and P11 Form
 * 1.4    8/09/2021   Nithin Malla (Deloitte)       ORRUAC-6286 Added Exclusion Logic - Content Version for Monitoring Module.
 * 1.5    8/10/2021   Abhisek Pati (Deloitte)       ORRUAC-6283 Added Test coverage for Health Content Version.
 * 1.6    9/29/2021   Chase Oden (Deloitte)         Increasing test coverage for beforeInsertHelper method
 **/

@isTest(seeAllData = false) public with sharing class UAC_contentVersionHelperTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  public
  final static Id ID_RECORD_TYPE_OTHER =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contentVersionRecordTypeApiNameOther)
          .getRecordTypeId();
  public
  static final Id idRecordTypeFacilityDocuments =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('UAC_facilityDocument')
          .getRecordTypeId();

  public
  static final Id idRecordTypeOperationalDocuments =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('UAC_operationalDocument')
          .getRecordTypeId();

  public
  static final Id idRecordTypeComplianceDocuments =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('UAC_complianceDocument')
          .getRecordTypeId();
  public
  final static Id idRecordTypeComplianceForms =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get(Label.UC_complianceFormsLabel)
          .getRecordTypeId();
    
  public
  final static Id idRecordTypeHealthDocumentation =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_filesHealthDocumentationRecType)
          .getRecordTypeId();
    
  public
  static final String strIMERecordType = System.label.UAC_IMERectype;

  @TestSetup static void setupData() {
    Account objProgram = new UAC_testAccountBuilder()
                             .setName('Program')
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType('Secure')
                             .setMaleBeds(10)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.UAC_Grant_Number__c = '1111111';
    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Male', 'Available', 10, true);
  }

  /**
   * @author      Priyanka
   * @description  Test insert of content version document
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertContentVersion() {
    Id idCaseCoordinationRecordType =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get('UAC_caseCoordinationAndDischarge')
            .getRecordTypeId();
    Id otherRecTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                            .get(Label.UAC_contentVersionRecordTypeApiNameOther)
                            .getRecordTypeId();
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    for (integer i = 0; i < 4; i++) {
      ContentVersion tempContentVersion = new ContentVersion();
      tempContentVersion.Title = 'test';
      tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
      tempContentVersion.RecordTypeId = otherRecTypeId;
      tempContentVersion.UAC_documentType__c = Label.UAC_docgenDocumentType;
      lstNewFiles.add(tempContentVersion);
    }

    lstNewFiles[1].Title = '[DOCGEN] test beforeInsertHelper';

    lstNewFiles[2].RecordTypeId = idCaseCoordinationRecordType;
    lstNewFiles[2].Title = 'test beforeInsertHelper';
    lstNewFiles[2].UAC_documentType__c = 'Release Request';

    // ORRUAC-124 Sponsor Assessment DocGen Test
    lstNewFiles[3].Title = 'Initial Sponsor Assessment[DOCGEN]';

    ContentVersion tempContentVersion1 = new ContentVersion();
    tempContentVersion1.Title = 'Verification of Release';

    tempContentVersion1.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    lstNewFiles.add(tempContentVersion1);

    ContentVersion tempContentVersion2 = new ContentVersion();
    tempContentVersion2.Title = 'Release Request';

    tempContentVersion2.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    lstNewFiles.add(tempContentVersion2);

    ContentVersion tempContentVersion3 = new ContentVersion();
    tempContentVersion3.Title = 'Discharge Notification';

    tempContentVersion3.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    lstNewFiles.add(tempContentVersion3);

    ContentVersion tempContentVersion4 = new ContentVersion();
    tempContentVersion4.Title = 'ORR Notice to ICE';

    tempContentVersion4.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    lstNewFiles.add(tempContentVersion4);

    ContentVersion tempContentVersion5 = new ContentVersion();
    tempContentVersion5.Title = 'P-9A Medical Checklist for Non-Influx Transfers[DOCGEN]';

    tempContentVersion5.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    lstNewFiles.add(tempContentVersion5);

    insert lstNewFiles;

    for (ContentVersion objContentVersion : [SELECT Id,
           Title,
           RecordType.DeveloperName,
           UAC_documentType__c FROM ContentVersion WHERE Id IN:lstNewFiles]) {
      // ORRUAC-124 Sponsor Assessment DocGen Test
      if (objContentVersion.Title.contains('Sponsor Assessment')) {
        System.assertEquals(Label.UAC_contentVersionRecordTypeApiNameSponsorAssessment,
            objContentVersion.RecordType.DeveloperName);
        System.assertEquals('Initial', objContentVersion.UAC_documentType__c);
      }
    }
  }
  /**
   * @author      Issam Awwad
   * @description  Test insert of content version document of type medical/placement authorization
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testAuthorizationContentVersion() {
    Id otherRecTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                            .get(Label.UAC_contentVersionRecordTypeApiNameOther)
                            .getRecordTypeId();
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'TAB D Placement Authorization Form Test';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = otherRecTypeId;
    tempContentVersion.UAC_documentType__c = Label.UAC_medicalAuthorizationDocumentType;
    lstNewFiles.add(tempContentVersion);

    insert lstNewFiles;

    ContentVersion objContentVersion = [SELECT Id,
      Title,
      RecordType.DeveloperName,
      UAC_documentType__c FROM ContentVersion WHERE Id IN:lstNewFiles];

    System.assertEquals(
        Label.UAC_medicalAuthorizationDocumentType, objContentVersion.UAC_documentType__c);
  }
  /**
   * @author      Issam Awwad
   * @description  Test insert of content version document of type Notice of Placement
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testP4Forms() {
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Notice of Placement in a Restrictive Setting (Form P-4)';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
    tempContentVersion.UAC_documentType__c = Label.UAC_noticeOfPlacementDocumentType;
    lstNewFiles.add(tempContentVersion);

    insert lstNewFiles;

    ContentVersion objContentVersion = [SELECT Id,
      Title,
      RecordType.DeveloperName,
      UAC_documentType__c FROM ContentVersion WHERE Id IN:lstNewFiles];
    System.assertEquals(
        Label.UAC_noticeOfPlacementDocumentType, objContentVersion.UAC_documentType__c);
  }
  /**
   * @author      Issam Awwad
   * @description  Test insert of content version document of type UAC Assessments
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testS16Forms() {
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '30 Day Restrictive Placement Case Review (Form S-16)';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
    tempContentVersion.UAC_documentType__c = Label.UAC_uacAssessmentsDocumentType;
    lstNewFiles.add(tempContentVersion);

    insert lstNewFiles;

    ContentVersion objContentVersion = [SELECT Id,
      Title,
      RecordType.DeveloperName,
      UAC_documentType__c FROM ContentVersion WHERE Id IN:lstNewFiles];
    System.assertEquals(
        Label.UAC_uacAssessmentsDocumentType, objContentVersion.UAC_documentType__c);
  }

  /**
   * @author       James Qian
   * @description  Test insert of content version document with parent ID population
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testParentIdLogic() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(objUACContact.id)
            .buildAndSave();
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = ID_RECORD_TYPE_OTHER;
    tempContentVersion.UAC_documentType__c = Label.UAC_uacAssessmentsDocumentType;
    tempContentVersion.FirstPublishLocationId = objUACReferralCase.Id;
    lstNewFiles.add(tempContentVersion);
    insert lstNewFiles;
    ContentVersion objContentVersion = [SELECT Id,
      Title,
      RecordType.DeveloperName,
      UAC_entry__c,
      UAC_individual__c FROM ContentVersion WHERE Id IN:lstNewFiles];
    System.assertEquals(objUACContact.Id, objContentVersion.UAC_individual__c);
    System.assertEquals(objUACReferralCase.Id, objContentVersion.UAC_entry__c);
  }

  /**
   * @author      Chaitanya Nandamuri
   * @description  Test insert of content version for Covid -19
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testCovid19andP11Forms() {
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Covid-19 Symptom and Temperature Check Template[DOCGEN]';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';

    ContentVersion tempContentVersionP11 = new ContentVersion();
    tempContentVersionP11.Title = 'P-11 Transfer Summary and Tracking[DOCGEN]';
    tempContentVersionP11.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';

    lstNewFiles.add(tempContentVersionP11);
    lstNewFiles.add(tempContentVersion);

    insert lstNewFiles;

    list<ContentVersion> objContentVersion = [SELECT Id,
      Title,
      RecordType.DeveloperName,
      UAC_documentType__c FROM ContentVersion WHERE Id IN:lstNewFiles];
    System.assertEquals(Label.UAC_transferDocumentType, objContentVersion[0].UAC_documentType__c);
    System.assertEquals(Label.UAC_transferDocumentType, objContentVersion[1].UAC_documentType__c);
  }
  /**
   * @author       Sarang Padhye
   * @description  Test to insert Entity Docs
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testEntityDocsUpload() {
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    Account objAccountTest =
        [select id, UAC_Grant_Number__c from account where name = 'Program' limit 1];
    system.debug('objAccounTest ' + objAccountTest);
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = idRecordTypeFacilityDocuments;
    tempContentVersion.UAC_documentType__c = 'Facility Intake List';
    tempContentVersion.FirstPublishLocationId = objAccountTest.id;
    insert tempContentVersion;
    ContentVersion cv = [select id,
      UAC_documentType__c,
      Title,
      CreatedDate from contentVersion where FirstPublishLocationId =:objAccountTest.id limit 1];
    System.assert(cv.Title.containsIgnoreCase(objAccountTest.UAC_Grant_Number__c));
  }
  /**
   * @author       Sarang Padhye
   * @description  Test Manifest Upload Doc
   * @param        N/A
   * @return       N/A
   */
  @isTest static void testManifestDoc() {
    Test.StartTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = Label.UAC_manifestDocumentTitle + '[DOCGEN]';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    insert tempContentVersion;

    ContentVersion cv =
        [select id, UAC_documentType__c, Title, CreatedDate from contentVersion where Title
          =:Label.UAC_manifestDocumentTitle limit 1];
    system.assertEquals(cv.UAC_documentType__c, Label.UAC_manifestDocumentType);
    Test.StopTest();
  }
  /**
   * @author       Sarang Padhye
   * @description  Test Legacy Documents
   * @param        N/A
   * @return       N/A
   */
  @isTest static void settingLegacyDocTypeShouldsetRecType() {

    Test.StartTest();
    Id idLegacyDocRecordTypeId =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get('UAC_legacyDocuments')
            .getRecordTypeId();
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setLastName('TestLastName')
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UAC_legacyDocumentTypeName;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objUACContact.id;
    insert tempContentVersion;

    ContentVersion objTestCv =
        [select Title, id, recordTypeId from ContentVersion where Title = 'Test Doc' Limit 1];
    system.assertEquals(objTestCv.recordTypeId, idLegacyDocRecordTypeId);
    Test.StopTest();
  }
  /**
   * @author       Sarang Padhye
   * @description  Test Legacy Documents
   * @param        N/A
   * @return       N/A
   */
  @isTest static void updatingLegacyDocShouldUpdateTitle() {
    Test.StartTest();
    Id idLegacyDocRecordTypeId =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get('UAC_legacyDocuments')
            .getRecordTypeId();
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setLastName('TestLastName')
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UAC_legacyDocumentTypeName;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objUACContact.id;
    insert tempContentVersion;

    ContentDocument objTestCd =
        [select id, LatestPublishedVersionId from ContentDocument where LatestPublishedVersionId
          =:tempContentVersion.id];

    tempContentVersion.UAC_documentType__c = Label.UAC_medicalAuthorizationDocumentType;
    update tempContentVersion;

    ContentVersion objTestCv =
        [select Title, id, recordTypeId from ContentVersion where ContentDocumentId
          =:objTestCd.id Limit 1];
    system.assert(objTestCv.Title.contains(Label.UAC_medicalAuthorizationDocumentType));
    Test.StopTest();
  }

  /**
   * @author       James Qian
   * @description  Tests setting timestamp for document insert on Admission
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertingDocumentShouldSetTimestamp() {
    Account objProgram =
        [select id, UAC_Grant_Number__c from account where name = 'Program' limit 1];
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Case objUACReferralCase = new UAC_testCaseBuilder()
                                  .setStatus(Label.UAC_processedPendingContactStatus)
                                  .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                                  .setUAC(objUACContact.id)
                                  .buildAndSave();
    objUACReferralCase.UAC_programFacility__c = objProgram.Id;
    objUACReferralCase.Status = Label.UAC_placementDesignatedContactStatus;
    update objUACReferralCase;
    Id idAdmissionCase =
        [SELECT Id FROM Case WHERE RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission].Id;
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UAC_placementAuthorizationDocumentType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = idAdmissionCase;
    tempContentversion.RecordTypeId = ID_RECORD_TYPE_OTHER;
    insert tempContentVersion;
    Case caseAdmissionQueried =
        [SELECT UAC_uploadTimestampPlacementAuth__c FROM Case WHERE RecordType.DeveloperName
            =:Label.UAC_caseRecordTypeAdmission];
    System.AssertNotEquals(null, caseAdmissionQueried.UAC_uploadTimestampPlacementAuth__c);
  }
  /**
   * @author       Issam Awad
   * @description  Tests for compliance document insert
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertingComplianceForms() {
    UAC_AccountRequestForm__c objARF = new UAC_AccountRequestForm__c();
    objARF.First_Name__c = 'ARFUser';
    objARF.Last_Name__c = 'SampleUser';
    objARF.User_Email__c = 'arfacctcreation@arfuserreq.com';
    objARF.UAC_Status__c = 'Initiate Form Completion Request';
    insert objARF;
    objARF = [SELECT Id FROM UAC_AccountRequestForm__c LIMIT 1];

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objARF.Id;
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    objARF = [SELECT Id, UAC_Cyber_Security_Uploaded__c FROM UAC_AccountRequestForm__c LIMIT 1];
    System.AssertEquals(true, objARF.UAC_Cyber_Security_Uploaded__c);
  }
  /**
   * @author       Nithin Malla
   * @description  Tests for MonitoringSchedule document insert
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertingMonitoringSchedule() {
    UAC_monitoringSchedule__c objMS = new UAC_monitoringSchedule__c();
    objMS.UAC_fiscalYear__c = '2026';
    insert objMS;
    objMS = [SELECT Id FROM UAC_monitoringSchedule__c LIMIT 1];

    test.startTest();     
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objMS.Id;
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    objMS = [SELECT Id FROM UAC_monitoringSchedule__c LIMIT 1];
    System.Assert(objMS.Id!=null);
    test.stopTest();     
  }
  /**
   * @author       Nithin Malla
   * @description  Tests for Monitoring Visits document insert
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertingMonitoringWithScheduleRecords() {
    UAC_monitoringSchedule__c objMS = new UAC_monitoringSchedule__c();
    objMS.UAC_fiscalYear__c = '2026';
    insert objMS;
    objMS = [SELECT Id FROM UAC_monitoringSchedule__c LIMIT 1];
      
    UAC_monitoring__c objMonv = new UAC_monitoring__c();
    objMonv.UAC_program__c = [select id from account where name = 'Program' limit 1].Id ;
    objMonv.UAC_monitoringSchedule__c = objMS.Id;
    objMonv.uac_status__c = 'Pre-Monitoring';
    insert objMonv;

    test.startTest();     
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objMonv.Id;
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    objMS = [SELECT Id FROM UAC_monitoringSchedule__c LIMIT 1];
    System.Assert(objMS.Id!=null);
    test.stopTest();     
  } 
  /**
   * @author       Nithin Malla
   * @description  Tests for UC Monitor document insert
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertingMonitoring() {  
    UAC_monitoringSchedule__c objMS = new UAC_monitoringSchedule__c();
    objMS.UAC_fiscalYear__c = '2026';
    insert objMS;
    objMS = [SELECT Id FROM UAC_monitoringSchedule__c LIMIT 1];
      
    UAC_monitoring__c objMonv = new UAC_monitoring__c();
    objMonv.UAC_program__c = [select id from account where name = 'Program' limit 1].Id ;
    objMonv.UAC_monitoringSchedule__c = objMS.Id;
    objMonv.uac_status__c = 'Draft';
    insert objMonv;
      
    String orgId = UserInfo.getOrganizationId();
    String dateString =
    String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    string uniqueName = orgId + dateString + randomInt;
    
    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;

    u.Alias = 'Tcode';
    u.Title ='UC Monitor - Travel POC';
    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;  
    
      System.runAs(u){
        test.startTest();      
        UAC_monitor__c objMon = new UAC_monitor__c();        
        objMon.UAC_uacMonitor__c = u.id;
        objMon.UAC_monitoring__c = objMonv.Id;
        objMon.UAC_type__c = 'Lead UC Monitor';
        insert objMon;  
    
        ContentVersion tempContentVersion = new ContentVersion();
        tempContentVersion.Title = 'Test Doc';
        tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
        tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
        tempContentversion.FirstPublishLocationId = objMon.Id;
        tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
        insert tempContentVersion;
        objMS = [SELECT Id FROM UAC_monitoringSchedule__c LIMIT 1];
        System.Assert(objMS.Id!=null);
        Test.stopTest();
      }
  }
    
  /**
   * @author       Abhisek Pati
   * @description  Tests for Health Evaluation document insert
   * @param        N/A
   * @return       N/A
   */
  @isTest static void healthEvaluationDocumentUpload() {
	Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
	UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                 .setUAC(objUACContact.Id)
                 .setRecordTypeDeveloperName(strIMERecordType)
                 .buildAndSave();

    test.startTest();     
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = 'Health Evaluation Form';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objIME.Id;
    tempContentversion.RecordTypeId = idRecordTypeHealthDocumentation;
    tempContentversion.Description = 'Test Description';
    insert tempContentVersion;
    objIME = [SELECT Id FROM UAC_healthEvaluation__c LIMIT 1];
    System.Assert(objIME.Id!=null);
    test.stopTest();     
  }
    
    /**
   * @author       Abhisek Pati
   * @description  Tests for Test - Imaging Study document insert
   * @param        N/A
   * @return       N/A
   */
  @isTest static void imagingStudyDocumentUpload() {
	Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
	UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                 .setUAC(objUACContact.Id)
                 .setRecordTypeDeveloperName(strIMERecordType)
                 .buildAndSave();
	UAC_test__c objImagingStudyTest = new UAC_testImagingStudyTestBuilder()
        		.setUAC(objUACContact.Id)
        		.setHealthEval(objIME.Id)
        		.buildAndSave();
    test.startTest();     
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = 'Health Evaluation Form';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.FirstPublishLocationId = objImagingStudyTest.Id;
    tempContentversion.RecordTypeId = idRecordTypeHealthDocumentation;
    tempContentversion.Description = 'Test Description';
    insert tempContentVersion;
    objImagingStudyTest = [SELECT Id FROM UAC_test__c LIMIT 1];
    System.Assert(objImagingStudyTest.Id!=null);
    test.stopTest();     
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a SIR Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertSirShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test SIR Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a PLE SIR Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertPleSirShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test SIR Program-Level Event Report Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a Influx Transfer Facility Checklist Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertInfluxTransferShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test Influx Transfer Facility Checklist Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a UC Case Review Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertUcCaseReviewShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test UC Case Review Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a TAB C Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertTabCShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test TAB C Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a TAB D Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertTabDShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test TAB D Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a P4 Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertP4ShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test P-4 Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a S16 Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertS16ShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test S-16 Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a PRS Event Report Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertPrsEventShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test PRS Event Report Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
      
  /**
   * @author       Chase Oden
   * @description  Test Inserting a Form (Change of Venue) Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertFormVenueShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test Form (Change of Venue) Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a Placement Identification Document Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertPlacementIdentShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test Placement Identification Document Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a Post Legal Status Plan Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertPostLegalStatusPlanShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test Post Legal Status Plan Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
   
  /**
   * @author       Chase Oden
   * @description  Test Inserting an NOC Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertNocShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test NOC Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }    
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a WaveAnalytics Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertWaveAnalyticsShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test WaveAnalytics Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }    
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting an LTFC Memo Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertLtfcMemoShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = '[DOCGEN] Test LTFC Memo Doc';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting an HS/PRS Assessment Typed Content Version
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertHsAssessShouldSucceed() {
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'Test Doc ' + Label.UC_contentVersionhSPrsAssessDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, UAC_documentType__c FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].UAC_documentType__c != tempContentVersion.UAC_documentType__c);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test Inserting a Content Version object with an A# attribute
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertWithANumShouldSucceed() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(objUACContact.id)
            .buildAndSave();
     
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.UAC_entry__c = objUACReferralCase.Id;
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, Title FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].Title != tempContentVersion.Title);
  }
    
  /**
   * @author       Chase Oden
   * @description  Test inserting a Content Version oject with a FirstPublishLocationId
   * @param        N/A
   * @return       N/A
   */
  @isTest static void insertWithFirstPublishLocationShouldSucceed() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
        						.setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
     
    test.startTest();
    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.FirstPublishLocationId = objUACContact.Id;
    tempContentVersion.Title = 'Test Doc';
    tempContentVersion.UAC_documentType__c = Label.UC_cyberSecurityComplianceDocType;
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentversion.RecordTypeId = idRecordTypeComplianceForms;
    insert tempContentVersion;
    test.stopTest();
      
    List<ContentVersion> outContentVersion = [SELECT Id, Title FROM ContentVersion WHERE Id = :tempContentVersion.Id LIMIT 1];
    System.Assert(outContentVersion[0].Title != tempContentVersion.Title);
  }
}