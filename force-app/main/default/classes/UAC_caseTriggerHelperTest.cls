// clang-format off
/**
 * @File Name          : UAC_caseTriggerHelperTest.cls
 * @Description        : Test class for UAC_caseTriggerHandler, UAC_caseTriggerHelper
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/3/2020, 2:09:14 PM
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    5/15/2020   Sachet Khanal (Deloitte)     Initial Version
 * 1.1    6/2/2020    Sachet Khanal (Deloitte)     ORRUAC-125 FRP Date Sent to Sponsor test
 * 1.2    6/6/2020    Karthi Subramanian (Deloitte) ORRUAC-435 Application Completion Date test
 * 1.3    6/22/2020   Rahul Roy (Deloitte)          ORRUAC-187 Changes to Release Request test
 * 1.4    6/24/2020   Abhisek Pati (Deloitte)       ORRUAC-39 Changes to IHI create record test
 * 1.5    7/9/2020    Chaitanya Nandamuri(Deloitte) ORRUAC-1251 Test Process to check created Admission Entry Case
 * 1.6    7/21/2020   Abhisek Pati (Deloitte)       ORRUAC-206 - Added test method for Admitted date
 * 1.7	  8/3/2020    Chaitanya Nandamuri(Deloitte) ORRUAC-254 - Duplicate Transfer Request check
 * 1.8    8/6/2020    Abhisek Pati (Deloitte)       ORRUAC-285 - LCM and CC populate check
 * 1.9	  8/6/2020    James Qian (Deloitte)         ORRUAC-1094 - Case and Contact Status Sync
 * 1.10   8/18/2020	  Chaitanya Nandamuri(Deloitte) ORRUAC-1849 - Create Admission for Transfer/ Influx Transfer Request.
 * 1.11   8/18/2020	  Chaitanya Nandamuri(Deloitte) ORRUAC-1846 - Create Influx Transfer Request for LNO Rec Accepted.
 * 1.12   4/11/2021	  Nithin Malla(Deloitte)        Code Coverage for User Email Methods
 **/
// clang-format on
@isTest(seeAllData = false) public without sharing class UAC_caseTriggerHelperTest {
  private
  static final String strApproveWithPostReleaseOnlyServices =
      Label.UAC_approveWithPostReleaseOnlyServices;
  private
  static final String strReleaseRequestStatusCCReview = Label.UAC_ReleaseRequestStatusCCReview;
  private
  static final String strReleaseRequestStatusFFSReview = Label.UAC_ReleaseRequestStatusFFSReview;
  private
  static final String strSupervisorApprovalRequestedStatus =
      Label.UAC_supervisorApprovalRequestedStatus;
  private
  static final String strSupervisorApprovalRequestedError =
      Label.UAC_supervisorApprovalRequestedErrorMessage;
  private
  static final String strSupervisorApprovedError = Label.UAC_supervisorApprovedErrorMessage;
  private
  static final String STR_ADULT_CONTACT_A_NUMBER = '987654321';
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  private
  static Contact objUACContact;
  private
  static Contact objAdultContact;
  private
  static Account objProgram;
  private
  static Case objUACReferralCase;
  private
  static Case objHsPrsReferralCase;
  private
  static Case objUACDNFCase;
  private
  static Case objUACReleaseRequestCase;
  private
  static Case objSponsorApplicationCase;
  private
  static final string strcaseRecordTypeAdmission = Label.UAC_caseRecordTypeAdmission;
  private
  static final string strcaseRecordTypeReferral = Label.UAC_caseRecordTypeApiNameUACReferral;
  private
  static final string strcaseRecordTypeReleaseRequest = Label.UAC_caseRecordTypeReleaseRequest;
  private
  static final string strAccountRecordTypeProgram = Label.UAC_accountRecordTypeAPINameProgram;
  private
  static final string strContactRecordTypeUAC = Label.UAC_contactRecordTypeApiNameUAC;
  private
  static final string strPendingAdmissionStatus = 'Pending Admission';
  private
  static final string strAdmittedStatus = 'Admitted';
  private
  static final String UAC_RELATIONSHIP_API_NAME = 'UAC_apprehendedRelationship__c';
  private
  static final String UAC_RELATIONSHIP_RECORD_TYPE = 'Apprehended UC';
  private
  static final string Tier_2_Helpdesk_Queue = Label.UAC_Tier2_Helpdesk_Queue;
  private
  static Case objUACNOCCase;
  /**
   * @description Method to setup data used in test instance.
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @return void
   **/
  @TestSetup static void setupData() {
    UAC_appSettingsService.setAppSettings();
    // Create an UAC contact
    objUACContact = new UAC_testContactBuilder()
                        .setANumber(STR_UAC_CONTACT_A_NUMBER)
                        .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                        .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                        .build();
    // Create an Adult Contact
    objAdultContact =
        new UAC_testContactBuilder()
            .setANumber(STR_ADULT_CONTACT_A_NUMBER)
            .setEmail(STR_ADULT_CONTACT_A_NUMBER + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .build();
    List<Contact> listContactsToInsert = new List<Contact>{objUACContact, objAdultContact};
    insert listContactsToInsert;
    UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c(UAC_adultContact__c = listContactsToInsert[1].Id,
            UAC_relationshipType__c = 'Primary Sponsor',
            UAC_relationshipToUAC__c = 'Father',
            UAC_uacLookup__c = listContactsToInsert[0].Id);
    // Create a Program Accountf
    List<Account> listAccount = new List<Account>();
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    listAccount.add(objProgram);
    Account objProgram2 = new UAC_testAccountBuilder()
                              .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                              .setType(STR_PROGRAM_TYPE)
                              .build();
    objProgram2.UAC_withinORRNetwork__c = 'No';
    listAccount.add(objProgram2);
    insert listAccount;
    List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
    accTeamList.add(new AccountTeamMember(AccountId = listAccount[0].Id,
        UserId = userinfo.getUserId(),
        TeamMemberRole = 'Lead Case Manager'));
    accTeamList.add(new AccountTeamMember(AccountId = listAccount[0].Id,
        UserId = userinfo.getUserId(),
        TeamMemberRole = 'Case Manager'));
    insert accTeamList;
    UAC_TestUtility.createAssets(listAccount[0].Id, 'Female', 'Available', 5, true);
    insert objAdultContactRelationship;
  }

  /**
   * @description ORRUAC-320 & 398: Method to test update of Active Sponsor Application flag
   * @author Ankur Aggarwal (Deloitte) | 6/04/2020
   * @return void
   **/
  @isTest static void createNotificationTask() {
    test.startTest();
    String orgId = UserInfo.getOrganizationId();
    String dateString =
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;

    u.Alias = 'Tcode';

    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'Case Manager'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;
    // system.runAs(u){
    system.debug([select id, UAC_A__c from contact]);

    Set<String> setFieldsToQuery =
        new Set<String>{'Id', 'UAC_activeSponsorApplication__c', 'UAC_A__c'};

    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    Case objReleaseRequestCase = new UAC_testCaseBuilder().setUAC(objUACContact.Id).build();
    objReleaseRequestCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                                             .get(strcaseRecordTypeReleaseRequest)
                                             .getRecordTypeId();
    objReleaseRequestCase.status = 'CM Initiated';
    objReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objReleaseRequestCase.UAC_remandForFurtherInformation__c = 'Yes';
    objReleaseRequestCase.UAC_orrComment__c = 'Test1';
    insert objReleaseRequestCase;

    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();

    objProgram.UAC_bedCountAvailableMale__c = 5;
    objProgram.UAC_bedCountAvailableFemale__c = 6;
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    objReleaseRequestCase.UAC_programFacility__c = objProgram.id;
    objReleaseRequestCase.status = 'CC Review';
    update objReleaseRequestCase;

    objReleaseRequestCase.status = 'FFS Review';
    update objReleaseRequestCase;

    objReleaseRequestCase.status = 'Completed';
    objReleaseRequestCase.UAC_pendingInformation__c = 'No';
    objReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objReleaseRequestCase.UAC_orrDecision__c = strApproveWithPostReleaseOnlyServices;
    objReleaseRequestCase.UAC_orrComment__c = 'Comments';
    update objReleaseRequestCase;
    System.assertEquals('No', objReleaseRequestCase.UAC_remandForFurtherInformation__c);
    test.stopTest();
    // }
  }

  /**
   * @description ORRUAC-362: Method to test update of Active Sponsor Application flag
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @return void
   **/
  @isTest static void activeSponsorCaseChangeShouldUpdateActiveSponsorAppFlag() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_activeSponsorApplication__c'};
    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    // Create new Active Sponsor Case for adult contact
    Case objActiveSponsorCase =
        new UAC_testCaseBuilder().setUAC(objUACContact.Id).setSponsor(objAdultContact.Id).build();
    Test.startTest();

    // Insert new active sponsor Case and verify Active Sponsor App flag is set
    objActiveSponsorCase.UAC_relationshipToUAC__c = getAdultContactRelationship().Id;
    insert objActiveSponsorCase;
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    System.assertEquals(true,
        objAdultContact.UAC_activeSponsorApplication__c,
        'Failed on set Active Sponsor Application on new Case creation. '
            + 'Test method: activeSponsorCaseChangeShouldUpdateActiveSponsorAppFlag() failed.');

    // Update Case sponsor to a new adult contact and verify active sponsor flag is updated
    String strNewANumber = '999999999';
    Contact objNewAdultContact =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .buildAndSave();
    objActiveSponsorCase.UAC_sponsor__c = objNewAdultContact.Id;
    update objActiveSponsorCase;
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    System.assertEquals(false,
        objAdultContact.UAC_activeSponsorApplication__c,
        'Failed on unset Active Sponsor Application on Case sponsor change. '
            + 'Test method: activeSponsorCaseChangeShouldUpdateActiveSponsorAppFlag() failed.');
    Test.stopTest();
  }

  @isTest static void rejectDuplicatePendingReleaseRequest() {
    Set<String> setFieldsToQuery =
        new Set<String>{'Id', 'UAC_activeSponsorApplication__c', 'UAC_A__c'};

    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Case objReleaseRequestCase =
        new UAC_testCaseBuilder().setUAC(objUACContact.Id).setSponsor(objAdultContact.Id).build();
    objReleaseRequestCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                                             .get(strcaseRecordTypeReleaseRequest)
                                             .getRecordTypeId();
    objReleaseRequestCase.status = 'CC Review';
    objReleaseRequestCase.UAC_remandForFurtherInformation__c = 'Yes';
    objReleaseRequestCase.UAC_orrComment__c = 'Test1';
    insert objReleaseRequestCase;
    Case objReleaseRequestCase2 = new UAC_testCaseBuilder().setUAC(objUACContact.Id).build();
    objReleaseRequestCase2.recordtypeid =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get(strcaseRecordTypeReleaseRequest)
            .getRecordTypeId();
    objReleaseRequestCase2.status = 'CC Review';
    Case objReleaseRequestCase3 = new UAC_testCaseBuilder().setUAC(objUACContact.Id).build();
    objReleaseRequestCase3.recordtypeid =
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get(strcaseRecordTypeReleaseRequest)
            .getRecordTypeId();
    objReleaseRequestCase3.status = 'CC Review';
    try {
      list<Case> lstCase = new list<Case>();
      lstcase.add(objReleaseRequestCase3);
      lstcase.add(objReleaseRequestCase2);
      insert lstCase;
    } catch (Exception e) {
      System.assert(e.getMessage().contains(Label.uac_ReleaseRequestExist));
    }
  }
  /**
   * @description Method to test rejecting duplicate pending referrals
   * @author Issam Awwad (Deloitte) | 5/15/2020
   * @return
   **/
  @isTest static void rejectDuplicatePendingReferralsTest() {
    Set<String> setFieldsToQuery =
        new Set<String>{'Id', 'UAC_activeSponsorApplication__c', 'UAC_A__c'};

    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Case objActiveSponsorCase =
        new UAC_testCaseBuilder().setUAC(objUACContact.Id).setSponsor(objAdultContact.Id).build();
    objActiveSponsorCase.UAC_aNum__c = objUACContact.UAC_A__c;
    objActiveSponsorCase.UAC_relationshipToUAC__c = getAdultContactRelationship().Id;
    objUACContact.UAC_status__c = 'New Pending';
    update objUACContact;
    insert objActiveSponsorCase;

    Case objActiveSponsorCase2 = new UAC_testCaseBuilder()
                                     .setUAC(objUACContact.Id)
                                     .setSponsor(objAdultContact.Id)
                                     .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                                     .build();
    objActiveSponsorCase2.UAC_aNum__c = objUACContact.UAC_A__c;
    objActiveSponsorCase2.UAC_relationshipToUAC__c = getAdultContactRelationship().Id;
    Test.startTest();
    try {

      insert objActiveSponsorCase2;
    } catch (Exception e) {
      System.assert(e.getMessage().contains(Label.UAC_duplicatePendingReferralErrorMessage));
    }
    Test.stopTest();
  }

  /**
   * @description Method to test rejecting duplicate pending referrals
   * @author Issam Awwad (Deloitte) | 5/15/2020
   * @return
   **/
  @isTest static void processReturningUACReferralsTest() {
    Set<String> setFieldsToQuery =
        new Set<String>{'Id', 'UAC_activeSponsorApplication__c', 'UAC_A__c'};

    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Case objActiveSponsorCase =
        new UAC_testCaseBuilder().setUAC(objUACContact.Id).setSponsor(objAdultContact.Id).build();
    objActiveSponsorCase.UAC_aNum__c = objUACContact.UAC_A__c;
    objActiveSponsorCase.UAC_relationshipToUAC__c = getAdultContactRelationship().Id;
    objUACContact.UAC_status__c = 'Referral Cancelled';
    update objUACContact;
    insert objActiveSponsorCase;

    Case objActiveSponsorCase2 = new UAC_testCaseBuilder()
                                     .setUAC(objUACContact.Id)
                                     .setSponsor(objAdultContact.Id)
                                     .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                                     .build();
    objActiveSponsorCase2.UAC_aNum__c = objUACContact.UAC_A__c;
    objActiveSponsorCase2.UAC_relationshipToUAC__c = getAdultContactRelationship().Id;
    Test.startTest();
    try {
      insert objActiveSponsorCase2;
    } catch (Exception e) {
      System.assertEquals(Label.UAC_duplicatePendingReferralErrorMessage, e.getMessage());
    }
    Test.stopTest();
  }

  /*
   * @description Method to test new Admission Entry
   * @author Chaitanya Nandamuri (Deloitte) | 7/8/2020
   * @return
   **/
  @isTest static void newAdmissionEntry() {

    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    UAC.UAC_relatedToOtherUAC__c = 'Yes';
    update UAC;

    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER + 'T')
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                                .buildAndSave();

    objUACContact.UAC_relatedToOtherUAC__c = 'Yes';
    update objUACContact;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    objUACReferralCase.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
    update objUACReferralCase;

    objUACReferralCase.UAC_programFacility__c = queryProgram(null).id;

    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            UAC.Id, objUACContact.Id, recordTypeId, 'Brother', true);
    newRelationship.UAC_relatedUAC__c = UAC.id;
    update newRelationship;

    Case objUACReferralCaseSecond = new UAC_testCaseBuilder()
                                        .setStatus('Processed Pending')
                                        .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                                        .setUAC(objUACContact.id)
                                        .buildAndSave();
    objUACReferralCaseSecond.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
    update objUACReferralCaseSecond;

    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, true);
    test.startTest();
    objUACReferralCase.Status = 'Placement Designated';
    update objUACReferralCase;
    objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];
    test.stopTest();

    system.assertEquals(objUACReferralCase.id,
        [select parentId from Case where recordtype.developerName = 'UAC_admission' limit 1]
            .parentId);
  }

  /*
   * @description Tests referral reversal (No longer designated)
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  @isTest static void designationReversalShouldEmptyContactFields() {

    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Account objSecondProgram = new UAC_testAccountBuilder()
                                   .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                   .setType(STR_PROGRAM_TYPE)
                                   .build();
    objSecondProgram.Type = 'Shelter';
    objSecondProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objSecondProgram;
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    objUACReferralCase.UAC_programFacility__c = queryProgram(null).id;

    List<Asset> listAssetsProgram = UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, false);
    listAssetsProgram.addAll(
        UAC_TestUtility.createAssets(objSecondProgram.Id, 'Female', 'Available', 1, false));
    insert listAssetsProgram;
    Test.startTest();
    objUACReferralCase.Status = 'Placement Designated';
    update objUACReferralCase;
    Contact queriedContact1 =
        [SELECT UAC_status__c, UAC_program__c, UAC_programType__c FROM Contact WHERE Id =:UAC.Id];
    objUACReferralCase.Status = 'Placement Match Under Review';
    update objUACReferralCase;
    Contact queriedContact2 =
        [SELECT UAC_status__c, UAC_program__c, UAC_programType__c FROM Contact WHERE Id =:UAC.Id];
    objUACReferralCase.Status = 'Placement Designated';
    objUACReferralCase.UAC_programFacility__c = objSecondProgram.Id;
    update objUACReferralCase;
    Contact queriedContact3 =
        [SELECT UAC_status__c, UAC_program__c, UAC_programType__c FROM Contact WHERE Id =:UAC.Id];
    Test.stopTest();

    System.assertEquals('Placement Designated', queriedContact1.UAC_status__c);
    System.assertEquals('Processed Pending', queriedContact2.UAC_status__c);
    System.assertEquals('Placement Designated', queriedContact3.UAC_status__c);
  }

  /*
   * @description Method to test new Admission Entry
   * @author Chaitanya Nandamuri (Deloitte) | 7/8/2020
   * @return
   **/
  @isTest static void newCaseTeamforAdmissionEntry() {
    // Soql Program Id
    Id ProgramId = queryProgram(null).id;

    UAC_TestUtility.createAssets(ProgramId, 'Male', 'Available', 7, true);

    // creating AccountTeamMember
    AccountTeamMember ATM = new AccountTeamMember();
    ATM.AccountId = ProgramId;
    ATM.TeamMemberRole = 'Lead Case Manager';
    ATM.UserId = UserInfo.getUserId();
    insert ATM;

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    UAC_TestUtility.createAssets(ProgramId, 'Female', 'Available', 1, true);
    objUACReferralCase.UAC_programFacility__c = ProgramId;

    test.startTest();
    objUACReferralCase.Status = 'Placement Designated';
    update objUACReferralCase;
    test.stopTest();
    // Soql for Created Admission Entry Record Id
    Id AdmissionEntryId =
        [select Id from Case where recordtype.developerName = 'UAC_admission' limit 1].Id;

    caseTeamMember CTMAdmissionEntry =
        [select MemberId from CaseTeamMember where ParentId =:AdmissionEntryId limit 1];
    system.assertEquals(ATM.UserId, CTMAdmissionEntry.MemberId);
  }

  /*
   * @description Method to test Standard Placement
   * @author Chaitanya Nandamuri (Deloitte) | 6/2/2020
   * @return
   **/
  @isTest static void standardPlacementsRequirePlacementfalse() {

    //  Id UACContactRecordTypeID =
    //  Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get(
    //  strContactRecordTypeUAC).getRecordTypeId();
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    objUACReferralCase.UAC_programFacility__c = queryProgram(null).id;

    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, true);
    Test.startTest();
    update objUACReferralCase;
    objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];
    Test.stopTest();
    system.assertEquals('Placement Match Under Review', objUACReferralCase.Status);
  }

  /*
   * @description Method to test Standard Placement
   * @author Chaitanya Nandamuri (Deloitte) | 6/2/2020
   * @return
   **/
  @isTest static void standardPlacementsRequirePlacementTrue() {

    // Id UACContactRecordTypeID =
    // Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get(
    // strContactRecordTypeUAC).getRecordTypeId();
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    Account objProgram = queryProgram(null);
    objProgram.UAC_IntakesPrimaryContactEmail__c = 'fake@fake.com';
    objProgram.UAC_intakesSecondaryContactUser__c = UserInfo.getUserId();
    update objProgram;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_programFacility__c = objProgram.id;

    AccountTeamMember ATM = new AccountTeamMember();
    ATM.AccountId = objProgram.id;
    ATM.TeamMemberRole = Label.UAC_caseTeamRoleNameLCM;
    ATM.UserId = UserInfo.getUserId();
    insert ATM;

    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, true);

    update objUACReferralCase;
    objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];

    system.assertEquals('Placement Requested', objUACReferralCase.Status);
  }

  /*
   * @description Method to test caseTeamforPlacementRequestedTest
   * @author Issam Awwad (Deloitte) | 4/8/2021
   * @return
   **/
  @isTest static void caseTeamforPlacementRequestedTest() {

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    Id idProgram = [select id from account where UAC_withinORRNetwork__c =
                        'Yes' AND RecordType.DeveloperName =:strAccountRecordTypeProgram limit 1]
                       .id;
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_programFacility__c = idProgram;
    AccountTeamMember ATM = new AccountTeamMember();
    ATM.AccountId = idProgram;
    ATM.TeamMemberRole = Label.UAC_caseTeamRoleNameCM;
    ATM.UserId = UserInfo.getUserId();
    insert ATM;

    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, true);

    update objUACReferralCase;
    objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];

    system.assertEquals('Placement Requested', objUACReferralCase.Status);
  }

  /*
   * @description Method to test Duplicate Check on Transfer Request
   * @author Chaitanya Nandamuri (Deloitte) | 8/3/2020
   * @return
   **/
  @isTest static void transferRequestDuplicateCheck() {
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    UAC_healthEvaluation__c healthEvaluation = new UAC_healthEvaluation__c();
    healthEvaluation.UAC_associatedUAC__c = UAC.id;
    insert healthEvaluation;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    Case oldTransferCase = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                               .setUAC(UAC.id)
                               .build();
    oldTransferCase.ParentId = objUACReferralCase.Id;
    oldTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    oldTransferCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    oldTransferCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    insert oldTransferCase;

    oldTransferCase.UAC_caseCoordinatorRecommendation__c = 'Transfer Concurred';
    oldTransferCase.UAC_caseManagerRecommendation__c = 'Transfer Recommended';
    oldTransferCase.UAC_orrDecision__c = 'Transfer Approved';
    update oldTransferCase;

    Case newTransferCase = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                               .setUAC(UAC.id)
                               .build();
    newTransferCase.ParentId = objUACReferralCase.id;
    newTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    try {
      insert newTransferCase;
    } catch (Exception e) {
      system.assert(e.getMessage().contains('new Transfer Request'));
    }
  }

  /*
   * @description ORRUAC-1849- Method to test new Admission Entry On Transfer / Influx Request
   * @author Chaitanya Nandamuri (Deloitte) | 8/18/2020
   * @return
   **/
  @isTest static void newAdmissionInfluxTransfer() {
    List<case> lstTransferCase = new List<Case>();
    test.startTest();
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    case objUACTransferCase = new UAC_testCaseBuilder()
                         .setStatus('CM Initiated')
                         .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                         .setUAC(UAC.id)
                         .build();
     objUACTransferCase.parentId = objUACReferralCase.id;
     objUACTransferCase.UAC_standardProgramType__c='Flight Risk';
     objUACTransferCase.UAC_leadCaseManager__c = UserInfo.getUserId();
     objUACTransferCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    lstTransferCase.add(objUACTransferCase);
   
     case objUACInfluxTransferCase =  new UAC_testCaseBuilder()
                         .setStatus('CM Initiated')
                         .setRecordTypeDeveloperName(Label.UAC_TransferRequestInflux)
                         .setUAC(UAC.id)
                         .build();
    lstTransferCase.add(objUACInfluxTransferCase);
    insert lstTransferCase;
   
    for(case TransferC : lstTransferCase ){
        TransferC.UAC_orrDecision__c = Label.UAC_transferApprovedORRDecision;
      }

      update lstTransferCase;
      test.stopTest();
      for (case TAcase : [select id, parent.recordtype.developername, type from case where parentid
             In:lstTransferCase]) {
        string rtDevName = TAcase.parent.recordtype.developername;
        if (rtDevName == Label.UAC_caseTransferRequest) {
          system.assertEquals(TAcase.type, 'Regular Transfer');
        }
        if (rtDevName == Label.UAC_TransferRequestInflux) {
          system.assertEquals(TAcase.type, 'Influx Transfer');
        }
      }
  }

  /*
   * @description ORRUAC-1846- Method to test new Influx Tranfer on Admission
   * @author Chaitanya Nandamuri (Deloitte) | 8/20/2020
   * @return
   **/
  @isTest static void newInfluxTransferOnLNORec() {
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();

    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 5, true);
    Case objManifest = new UAC_testCaseBuilder()
                           .setStatus('Initiated')
                           .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeManifest)
                           .buildandSave();
    Case objUACAdmission = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                               .setUAC(UAC.id)
                               .buildandSave();
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACAdmission.Id, UserInfo.getUserId(), idCaseTeamRole);
    objUACAdmission.UAC_programFacility__c = objProgram.id;
    objUACAdmission.UAC_InfluxProgram__c = objProgram.id;
    objUACAdmission.UAC_LNORecommendation__c = 'Accepted';
    objUACAdmission.UAC_transferMatch__c = 'Eligible';
    objUACAdmission.UAC_manifest__c = objManifest.Id;
    update objUACAdmission;
    Case ObjInfluxTransfer = [select id,
      UAC_manifest__c,
      UAC_caseManager__c,
      UAC_assignedClinician__c,
      recordtype.developername from case where parentId =:objUACAdmission.id];
    System.assertEquals(
        Label.UAC_TransferRequestInflux, ObjInfluxTransfer.recordtype.developername);
    System.assertEquals(UserInfo.getUserId(), ObjInfluxTransfer.UAC_caseManager__c);
    System.assertEquals(objManifest.Id, ObjInfluxTransfer.UAC_manifest__c);
  }

  /*
   * @description ORRUAC-1840- Method to test bed update for Influx transfer
   * @author James Qian (Deloitte) | 9/1/2020
   * @return
   **/
  @isTest static void influxTransferShouldUpdateBeds() {
    test.startTest();
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    insert objProgram;
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    List<Asset> listAssets =
        UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'On-Hold', 5, false);
    listAssets[0].ContactId = UAC.Id;
    insert listAssets;
    Case objUACInfluxTransferCase = new UAC_testCaseBuilder()
                                        .setStatus(Label.UAC_ReleaseRequestStatusFFSReview)
                                        .setRecordTypeDeveloperName(Label.UAC_TransferRequestInflux)
                                        .setUAC(UAC.id)
                                        .build();
    objUACInfluxTransferCase.UAC_programFacility__c = objProgram.Id;
    insert objUACInfluxTransferCase;
    objUACInfluxTransferCase.UAC_orrDecision__c = Label.UAC_transferNotApprovedORRDecision;
    update objUACInfluxTransferCase;
    test.stopTest();

    Account objProgramQueried = queryProgram(objProgram.Id);
    System.assertEquals(4, objProgramQueried.UAC_bedCountOnHoldFemale__c);
    System.assertEquals(1, objProgramQueried.UAC_bedCountAvailableFemale__c);
  }

  /*
   * @description Method to test syncing transfer status with UAC status
   * @author James Qian (Deloitte) | 8/6/2020
   * @return
   **/
  @isTest static void transferRequestStatusSync() {
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    Case newTransferCase = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                               .setUAC(UAC.id)
                               .build();
    newTransferCase.ParentId = objUACReferralCase.Id;
    newTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    newTransferCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    newTransferCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    insert newTransferCase;

    Test.startTest();
    newTransferCase.UAC_caseCoordinatorRecommendation__c = 'Transfer Concurred';
    newTransferCase.UAC_caseManagerRecommendation__c = 'Transfer Recommended';
    newTransferCase.UAC_orrDecision__c = Label.UAC_orrDecisionTransferApproved;
    newTransferCase.Status = Label.UAC_caseStatusCompleted;
    update newTransferCase;
    Test.stopTest();
    contact queriedUAC = [SELECT id, UAC_status__c FROM contact WHERE RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    System.assertEquals(Label.UAC_inTransferContactStatus, queriedUAC.UAC_status__c);
  }

  /*
   * @description Tests positive scenarios of group email record creation
   * @author James Qian (Deloitte) | 6/18/2020
   * @return
   **/
  @isTest static void placingReferralShouldTriggerGroupEmail() {
    Contact UAC = [
      // clang-format off
        SELECT
          Id,
          UAC_status__c
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :strContactRecordTypeUAC
        LIMIT 1
      // clang-format on
    ];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase.UAC_caseManager__c = Userinfo.getUserId();
    objUACReferralCase.UAC_programFacility__c =
          [
            // clang-format off
            SELECT
              Id
            FROM
              Account
            WHERE
              UAC_withinORRNetwork__c='Yes' AND
              RecordType.DeveloperName = :strAccountRecordTypeProgram
            LIMIT 1
              // clang-format on
              ].id;
    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 2, true);
    objUACReferralCase.Status = 'Placement Designated';
    Test.startTest();
    update objUACReferralCase;
    Test.stopTest();
    List<UAC_groupEmail__c> lstGroupEmails = [
        // clang-format off
        SELECT
          Id
        FROM
          UAC_groupEmail__c
        // clang-format on
      ];
    System.AssertEquals(1, lstGroupEmails.size());
  }

  /*
   * @description Tests positive scenarios of setting referral date to match DOB
   * @author James Qian (Deloitte) | 6/25/2020
   * @return
   **/
  @isTest static void creatingReferralShouldDefaultReferralDate() {
    Contact UAC = [
      // clang-format off
        SELECT
          Id,
          UAC_status__c
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :strContactRecordTypeUAC
        LIMIT 1
      // clang-format on
    ];
    UAC.UAC_a__c = '123456789A';
    UAC.Birthdate = System.Today().addDays(-20);
    update UAC;
    Test.startTest();
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    Test.stopTest();
    Case referralQueried = [
      // clang-format off
        SELECT
          Id,
          UAC_referralDateTime__c
        FROM
          Case
        WHERE
          Id = :objUACReferralCase.Id
      // clang-format on
    ];
    System.AssertEquals(
        System.Today().addDays(-20), referralQueried.UAC_referralDateTime__c.date());
  }

  /*
   * @description Method to test Standard Placement
   * @author Chaitanya Nandamuri (Deloitte) | 6/5/2020
   * @return
   **/
  @isTest static void UACReferraldoNotAcceptPlacementsCase() {
    Contact UAC = [
      // clang-format off
        SELECT
          Id,
          UAC_status__c
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :strContactRecordTypeUAC
        LIMIT 1
      // clang-format on
    ];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setUAC(UAC.Id)
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .build();
    objUACReferralCase.UAC_programFacility__c =
        [
          // clang-format off
          SELECT
            Id
          FROM
            Account
          WHERE
            UAC_withinORRNetwork__c='Yes' AND
            RecordType.DeveloperName = :strAccountRecordTypeProgram
          LIMIT 1
            // clang-format on
        ].id;
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_NotAcceptedReason__c = 'No Capacity for Age';
    insert objUACReferralCase;
    objUACReferralCase.UAC_NotAcceptedReason__c = null;
    objUACReferralCase.Status = 'Placement Not Accepted';
    test.startTest();
    try {
      update objUACReferralCase;
    } catch (DmlException e) {
      system.debug('Error Msg ' + e.getMessage());
      system.assert(e.getMessage().contains(
          'Please select at least one reason under Not Accepted Reason for not accepting placement'));
    }
    test.stopTest();
  }

  /*
   * @description Method to test Standard Placement
   * @author Abhisek Pati (Deloitte) | 4/6/2021
   * @return
   **/
  @isTest static void UACReferraldoNotAcceptPlacementsNegativeCase() {
    Contact UAC = [
      // clang-format off
        SELECT
          Id,
          UAC_status__c,AccountId
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :strContactRecordTypeUAC
        LIMIT 1
      // clang-format on
    ];
    Id idProgram = queryProgram(null).id;
    UAC.AccountId = idProgram;
    update UAC;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setUAC(UAC.Id)
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .build();
    objUACReferralCase.UAC_programFacility__c = idProgram;
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_NotAcceptedReason__c = 'No Capacity for Age';
    insert objUACReferralCase;
    objUACReferralCase.Status = 'Placement Not Accepted';
    AccountTeamMember ATM = new AccountTeamMember();
    ATM.AccountId = idProgram;
    ATM.TeamMemberRole = Label.UAC_caseTeamRoleNameLCM;
    ATM.UserId = UserInfo.getUserId();
    insert ATM;
    ATM = [select UserId from AccountTeamMember limit 1];
    CaseTeamMember CTM = new CaseTeamMember();
    CTM.ParentId = [select id from Case limit 1].id;
    CTM.MemberId = ATM.UserId;
    CTM.TeamRoleId = [select id from CaseTeamRole where name =:Label.UAC_caseTeamRoleNameLCM][0].id;
    insert CTM;
    test.startTest();
    try {
      update objUACReferralCase;
      system.assertNotEquals(
          null, [Select UAC_programFacility__c from case where Id =:objUACReferralCase.id]);
    } catch (DmlException e) {
      system.debug('Error Msg ' + e.getMessage());
    }
    test.stopTest();
  }

  /*
   * @description Method to test Standard Placement
   * @author Abhisek Pati (Deloitte) | 4/5/2021
   * @return
   **/
  @isTest static void UACReferralAcceptPlacementsPositiveCase() {
    Contact UAC = [
      // clang-format off
        SELECT
          Id,
          UAC_status__c
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :strContactRecordTypeUAC
        LIMIT 1
      // clang-format on
    ];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setUAC(UAC.Id)
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .build();
    objUACReferralCase.UAC_programFacility__c =
          [
            // clang-format off
            SELECT
              Id
            FROM
              Account
            WHERE
              UAC_withinORRNetwork__c='Yes' AND
              RecordType.DeveloperName = :strAccountRecordTypeProgram
            LIMIT 1
              // clang-format on
              ].id;
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    insert objUACReferralCase;

    test.startTest();
    try {
      objUACReferralCase.Status = 'Placement Designated';
      update objUACReferralCase;
      system.assertNotEquals(null,
          [Select UAC_placementDecisionDateTime__c from case where Id =:objUACReferralCase.id]);
    } catch (DmlException e) {
      system.debug('Error Msg ' + e.getMessage());
    }
    test.stopTest();
  }

  /*
   * @description Method to test Standard Placement
   * @author Chaitanya Nandamuri (Deloitte) | 6/5/2020
   * @return
   **/
  @isTest static void UACReferralAcceptPlacementCase() {
    Contact UAC = [
      // clang-format off
        SELECT
          Id,
          UAC_status__c
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :strContactRecordTypeUAC
        LIMIT 1
      // clang-format on
    ];
    user Intakesuser = new user();
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      objUACReferralCase = new UAC_testCaseBuilder()
                               .setStatus('Processed Pending')
                               .setUAC(UAC.Id)
                               .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                               .buildAndSave();
      objUACReferralCase.UAC_caseManager__c = Userinfo.getUserId();
      objUACReferralCase.Status = 'Placement Designated';
    }
    test.startTest();
    Intakesuser = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    Intakesuser.ProfileID = [select id from profile where name = 'Intakes Team'].id;
    user u = [select id from user where Id =:UserInfo.getUserId()];
    system.runAs(u) {
      update Intakesuser;
    }
    system.runAs(Intakesuser) {
      system.debug('Profiles Id' + Intakesuser.ProfileID);

      try {
        update objUACReferralCase;
        Case objUACReferralCaseUpdated =
            [SELECT Id, Status FROM Case WHERE Id =:objUACReferralCase.Id LIMIT 1];
        System.assertEquals('Placement Designated', objUACReferralCaseUpdated.Status);
      } catch (DmlException e) {

        system.debug('Error Msg ' + e.getMessage());
      }

      test.stopTest();
    }
  }

  /*
   * @description Method to create User
   * @author Chaitanya Nandamuri (Deloitte) | 6/5/2020
   * @return
   **/
  static User CreateUser() {

    String orgId = UserInfo.getOrganizationId();
    String dateString =
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;
    u.Alias = 'Tcode';

    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;

    return u;
  }

  /**
   * @description Method to test ORRUAC-125 (auto-population of FRP Date Sent to Sponsor)
   * @author Sachet Khanal (Deloitte) | 6/3/2020
   * @return void
   **/
  @isTest static void frpDeliveryMethodUpdateShouldPopulateFRPDateSentToSponsor() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Case objCase =
        new UAC_testCaseBuilder()
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.Id)
            .setSponsor(objAdultContact.Id)
            .setRelationshipToUAC(getAdultContactRelationship().Id)
            .buildAndSave();
    Test.startTest();
    objCase.UAC_frpDeliveryMethod__c = Label.UAC_caseFRPDeliveryMethodInPerson;
    update objCase;
    Test.stopTest();
    objCase = [SELECT Id, UAC_frpDateSentToSponsor__c FROM Case WHERE Id =:objCase.Id];
    System.assertEquals(Date.today(),
        objCase.UAC_frpDateSentToSponsor__c,
        'Test method: frpDeliveryMethodUpdateShouldPopulateFRPDateSentToSponsor() failed.');
  }

  /**
   * @description Method to query Adult Contact Relationship record created in test instance;
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @return UAC_adultContactRelationship__c
   **/
  public
  static UAC_adultContactRelationship__c getAdultContactRelationship() {
    return [SELECT Id FROM UAC_adultContactRelationship__c LIMIT 1];
  }

  /**
   * @description Method to test Case Owner and Status update on insert
   * @author Rahul Roy (Deloitte) | 6/3/2020
   * @return void
   **/
  @isTest static void testUpdateCaseOwner() {

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    User CM;
    User FFS;
    User CC;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      CM = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
      CC = UAC_TestUtility.createUser('Case Coordinator', Label.UAC_userRoleCaseCoordinator);
    }

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(UAC.id)
                             .build();
    objUACReferralCase.UAC_pendingInformation__c = 'No';
    objUACReferralCase.UAC_caseManager__c = CM.Id;
    objUACReferralCase.UAC_leadCaseManager__c = CM.Id;
    objUACReferralCase.UAC_ffsName__c = FFS.Id;
    objUACReferralCase.UAC_caseCoordinator__c = CC.Id;
    objUACReferralCase.UAC_cfsName__c = FFS.Id;
    objUACReferralCase.UAC_caseCoordinatorRecommendationComment__c = 'Comments';
    // objUACReferralCase.UAC_remandForFurtherInformation__c = 'No';
    // objUACReferralCase.UAC_orrComment__c = 'Comments';
    Insert objUACReferralCase;

    System.runAs(CC) {
      Test.startTest();
      objUACReferralCase.UAC_pendingInformation__c = 'Yes';
      objUACReferralCase.UAC_remandForFurtherInformation__c = 'Yes';
      update objUACReferralCase;
      objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];

      system.assertEquals('CM Initiated', objUACReferralCase.Status);
      Test.stopTest();
    }
  }

  /*
   * @description Method to test Case Owner and Status update on Update
   * @author Rahul Roy (Deloitte) | 6/3/2020
   * @return void
   **/
  @isTest static void testUpdateCaseOwnerOnUpdate() {

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    User CM;
    User FFS;
    User CC;
    System.runAs(altAdminUser) {
      CM = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
      CC = UAC_TestUtility.createUser('Case Coordinator', Label.UAC_userRoleCaseCoordinator);
    }

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(UAC.id)
                             .buildAndSave();
    Id idAccount = [SELECT AccountId FROM Case WHERE Id =:objUACReferralCase.Id][0].AccountId;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReferralCase.Id, CC.Id, idCaseTeamRole);
    update new Account(Id = idAccount, OwnerId = CM.Id);
    System.runAs(CC) {
      Test.startTest();
      objUACReferralCase.UAC_caseManager__c = CM.Id;
      objUACReferralCase.UAC_leadCaseManager__c = CM.Id;
      objUACReferralCase.UAC_ffsName__c = FFS.Id;
      objUACReferralCase.UAC_caseCoordinator__c = CC.Id;
      objUACReferralCase.UAC_cfsName__c = FFS.Id;
      objUACReferralCase.UAC_pendingInformation__c = 'Yes';
      objUACReferralCase.UAC_caseCoordinatorRecommendationComment__c = 'Comments';
      objUACReferralCase.UAC_remandForFurtherInformation__c = 'Yes';
      objUACReferralCase.UAC_orrComment__c = 'Comments';
      update objUACReferralCase;
      objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];

      system.assertEquals('CM Initiated', objUACReferralCase.Status);
      Test.stopTest();
    }
  }
  /*
   * @description Method to test existing Applications
   * @author Vaibhav Kudesia (Deloitte) | 6/3/2020
   * @return
   **/
  @isTest static void checkPreviousApplicationsTest() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objAdult =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdult.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    Case objUACSponsorCase =
        new UAC_testCaseBuilder()
            .setStatus('New')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.Id)
            .build();
    objUACSponsorCase.UAC_requiresPlacementRequest__c = true;
    objUACSponsorCase.UAC_sponsor__c = objAdult.Id;
    objUACSponsorCase.UAC_relationshipToUAC__c = objAdultContactRelationship.Id;
    insert objUACSponsorCase;
    Test.startTest();
    try {
      Case objUACSponsorCaseTwo =
          new UAC_testCaseBuilder()
              .setStatus('New')
              .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
              .setUAC(objUAC.Id)
              .build();
      objUACSponsorCaseTwo.UAC_requiresPlacementRequest__c = true;
      objUACSponsorCaseTwo.UAC_sponsor__c = objAdultContactRelationship.UAC_adultContact__c;
      objUACSponsorCaseTwo.UAC_relationshipToUAC__c = objAdultContactRelationship.Id;
      insert objUACSponsorCaseTwo;
    }
    Catch(Exception e) {
      system.assertEquals(True, e.getMessage().contains(Label.UAC_activeCaseExists));
    }
  }
  /*
   * @description Method to test Case closure process
   * @author Vaibhav Kudesia (Deloitte) | 6/10/2020
   * @return
   **/
  @isTest static void checkApplicationClosureandUpdateTest() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objAdult =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdult.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    Case objUACSponsorCase =
        new UAC_testCaseBuilder()
            .setStatus('Open')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.Id)
            .build();
    objUACSponsorCase.UAC_requiresPlacementRequest__c = true;
    objUACSponsorCase.UAC_sponsor__c = objAdult.Id;
    objUACSponsorCase.UAC_relationshipToUAC__c = objAdultContactRelationship.Id;
    insert objUACSponsorCase;
    Test.startTest();
    try {
      objUACSponsorCase.Status = Label.UAC_caseStatusSponsorWithdrew;
      objUACSponsorCase.UAC_statusDecisionNotes__c = 'Test Notes';
      objUACSponsorCase.UAC_withdrawalReason__c = 'No Interest';
      update objUACSponsorCase;

      objAdultContactRelationship =
          [Select Id, UAC_relationshipType__c from UAC_adultContactRelationship__c where Id
            =:objUACSponsorCase.UAC_relationshipToUAC__c];
      system.assertEquals(Label.UAC_relationshipTypePreviousSponsor,
          objAdultContactRelationship.UAC_relationshipType__c);
    }
    Catch(Exception e) {
      system.debug(e.getMessage());
    }
    Test.stopTest();
  }

  /*
   * @description Method to test Case Owner and Status update on Update
   * @author Rahul Roy (Deloitte) | 6/3/2020
   * updated coverage for ORRUAC-1944 AC2,AC3 -Piyush 08252020
   * @return void
   **/
  @isTest static void testUpdateCMCCRecommendationDate() {
    User Manager;
    User CC;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Manager = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
      CC = UAC_TestUtility.createUser('Case Coordinator', Label.UAC_userRoleCaseCoordinator);
    }
    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();

    objProgram.UAC_bedCountAvailableMale__c = 5;
    objProgram.UAC_bedCountAvailableFemale__c = 6;
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(UAC.id)
                             .buildAndSave();

    objUACReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReferralCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objUACReferralCase.UAC_programFacility__c = objProgram.id;
    update objUACReferralCase;

    Test.startTest();
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
    listCaseTeamMembers.add(
        createCaseTeamMember(objUACReferralCase.Id, Manager.Id, idCaseTeamRole));
    listCaseTeamMembers.add(createCaseTeamMember(objUACReferralCase.Id, CC.Id, idCaseTeamRole));
    insert listCaseTeamMembers;
    System.runAs(Manager) {
      objUACReferralCase.Status = strReleaseRequestStatusCCReview;
      objUACReferralCase.UAC_caseManagerRecommendationHS__c = 'Deny Release';
      objUACReferralCase.UAC_caseManagerRecommendation__c =
          'Deny Release';  // added for ORRUAC-1944 AC2,AC3 coverage
      update objUACReferralCase;

      objUACReferralCase =
          [select id, Status, UAC_caseManagerRecommendationDate__c from Case where Id
            =:objUACReferralCase.Id limit 1];
      Date modifiedDate1 = objUACReferralCase.UAC_caseManagerRecommendationDate__c.Date();
      System.AssertEquals(modifiedDate1, system.today());
    }
    System.runAs(CC) {
      objUACReferralCase.Status = strReleaseRequestStatusFFSReview;
      objUACReferralCase.UAC_pendingInformation__c = 'No';
      objUACReferralCase.UAC_caseCoordinatorRecommendation__c = 'Conduct Home Study-TVPRA';
      update objUACReferralCase;

      objUACReferralCase = [select id,
        Status,
        UAC_caseManagerRecommendationDate__c,
        UAC_caseCoordinatorRecommendationDate__c from Case where Id
        =:objUACReferralCase.Id limit 1];
      Date modifiedDate2 = objUACReferralCase.UAC_caseCoordinatorRecommendationDate__c.Date();
      System.AssertEquals(modifiedDate2, system.today());
    }
    // Start - added for ORRUAC-1944 AC2,AC3 coverage
    System.runAs(Manager) {
      objUACReferralCase.Status = Label.UAC_caseStatusHSCompletedCMReview;
      update objUACReferralCase;
    }
    System.runAs(Manager) {
      objUACReferralCase.Status = label.UAC_caseStatusHSCompletedCCReview;
      objUACReferralCase.UAC_caseManagerRecommendationHS__c = 'Deny Release';
      update objUACReferralCase;

      objUACReferralCase =
          [select id, Status, UAC_rrCaseManagerRecommendationDateHs__c from Case where Id
            =:objUACReferralCase.Id limit 1];
      Date modifiedDate3 = objUACReferralCase.UAC_rrCaseManagerRecommendationDateHs__c.Date();
      System.AssertEquals(modifiedDate3, system.today());
    }
    System.runAs(CC) {
      objUACReferralCase.Status = Label.UAC_caseStatusHSCompletedFFSReview;
      objUACReferralCase.UAC_caseCoordinatorRecommendationHS__c = 'Deny Release';
      update objUACReferralCase;

      objUACReferralCase = [select id, Status, UAC_rrCaseCoordinatorRecomDtHs__c from Case where Id
        =:objUACReferralCase.Id limit 1];
      Date modifiedDate4 = objUACReferralCase.UAC_rrCaseCoordinatorRecomDtHs__c.Date();
      System.AssertEquals(modifiedDate4, system.today());
    }
    // End - added for ORRUAC-1944 AC2,AC3 coverage
    Test.stopTest();
  }

  /*
   * @description - Test class coverage for ORRUAC-1179
   * @author James Qian (Deloitte) | 4/22/2021
   * @return void
   **/
  @isTest static void testCaseTeamAssignmentAndDeletion() {
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    List<User> listUsers = new List<User>();
    System.runAs(altAdminUser) {
      listUsers.add(UAC_TestUtility.generateUser('Case Manager'));
      listUsers.add(UAC_TestUtility.generateUser('Lead Case Manager'));
      listUsers.add(UAC_TestUtility.generateUser('Case Coordinator'));
      listUsers.add(UAC_TestUtility.generateUser('Case Coordinator'));
      listUsers.add(UAC_TestUtility.generateUser('FFS'));
      listUsers.add(UAC_TestUtility.generateUser('FFS Supervisor'));
      listUsers.add(UAC_TestUtility.generateUser('CFS'));
      insert listUsers;
    }
    Contact UAC = [SELECT Id, UAC_status__c FROM Contact WHERE RecordType.DeveloperName
      =:Label.UAC_contactRecordTypeApiNameUAC LIMIT 1];
    List<Account> prgid = new List<Account>{queryProgram(null)};

    Test.startTest();

    Case objReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('CM Initiated')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeReleaseRequest)
            .setUAC(UAC.id)
            .build();
    objReleaseRequestCase.UAC_caseManager__c = listUsers[0].Id;
    objReleaseRequestCase.UAC_ffsName__c = listUsers[4].Id;
    objReleaseRequestCase.UAC_leadCaseManager__c = listUsers[1].Id;
    objReleaseRequestCase.UAC_caseCoordinator__c = listUsers[2].Id;
    objReleaseRequestCase.UAC_directOperationsCoordinator__c = listUsers[3].Id;
    objReleaseRequestCase.UAC_cfsName__c = listUsers[6].Id;
    objReleaseRequestCase.UAC_ffsSupervisor__c = listUsers[5].Id;
    objReleaseRequestCase.UAC_programFacility__c = prgid[0].Id;
    objReleaseRequestCase.UAC_remandForFurtherInformation__c = 'Yes';
    objReleaseRequestCase.UAC_orrComment__c = 'Test1';
    insert objReleaseRequestCase;

    List<CaseTeamMember> listCTM1 =
        [SELECT Id FROM CaseTeamMember WHERE ParentId =:objReleaseRequestCase.Id];

    objReleaseRequestCase.UAC_caseManager__c = UserInfo.getUserId();
    objReleaseRequestCase.UAC_ffsName__c = UserInfo.getUserId();
    objReleaseRequestCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    objReleaseRequestCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    objReleaseRequestCase.UAC_directOperationsCoordinator__c = UserInfo.getUserId();
    objReleaseRequestCase.UAC_cfsName__c = UserInfo.getUserId();
    objReleaseRequestCase.UAC_ffsSupervisor__c = UserInfo.getUserId();
    update objReleaseRequestCase;
    Test.stopTest();

    List<CaseTeamMember> listCTM2 =
        [SELECT Id FROM CaseTeamMember WHERE ParentId =:objReleaseRequestCase.Id];
    System.assert(listCTM1.size() >= 5);
    System.assertEquals(1, listCTM2.size());
  }

  /**
   * @description Method to test  ORRUAC-405 -  Auto Populate Sponsor related Fields
   * @author Manoj Sharma (Deloitte) | 6/6/2020
   * @return void
   **/
  @isTest static void testcreateDNFNegative() {
    String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
    String strCourtOrderedReleaseYes = Label.UAC_courtOrderedReleaseYes;
    String strCaseRecordTypeDischargeNotification = Label.UAC_caseRecordTypeDischargeNotification;
    String strTypeOfReleaseReleasetoSponsor = Label.UAC_typeOfReleaseReleasetoSponsor;
    String strCaseStatusCompleted = Label.UAC_caseStatusCompleted;
    String strCustomPermissionFFSS = Label.UAC_CustomPermissionFFSS;
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    }
    String strNewANumber = '999999999';
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(objUAC.id)
                             .build();
    objUACReferralCase.UAC_typeOfRelease__c = strTypeOfReleaseReleasetoSponsor;
    objUACReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReferralCase.UAC_ffsName__c = userinfo.getuserid();
    // objUACReferralCase.UAC_programFacility__c  = objProgram.id;
    objUACReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReferralCase;
    objUACReferralCase.UAC_pendingInformation__c = 'No';
    objUACReferralCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReferralCase.UAC_orrDecision__c = 'Deny Release';
    objUACReferralCase.UAC_reasonForDenial__c = 'Other';
    update objUACReferralCase;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReferralCase.Id, FFS.Id, idCaseTeamRole);
    System.runAs(FFS) {
      Test.startTest();
      objUACReferralCase.Status = strCaseStatusCompleted;
      objUACReferralCase.UAC_orrDecision__c = strORRDecisionDenyRelease;
      objUACReferralCase.UAC_typeOfRelease__c = strTypeOfReleaseReleasetoSponsor;
      objUACReferralCase.UAC_courtOrderedRelease__c = strCourtOrderedReleaseYes;
      objUACReferralCase.UAC_orrComment__c = strORRDecisionDenyRelease;

      objUACReferralCase.UAC_reasonForDenial__c = 'Other';
      Update objUACReferralCase;
      List<Case> lstCaseDNF = [Select Id from Case Where ParentId =:objUACReferralCase.Id];
      System.AssertEquals(0, lstCaseDNF.Size());
      Test.stopTest();
    }
  }

  @isTest static void testCreateDNFPositive() {
    String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
    String strCourtOrderedReleaseYes = Label.UAC_courtOrderedReleaseYes;
    String strCaseRecordTypeDischargeNotification = Label.UAC_caseRecordTypeDischargeNotification;
    String strTypeOfReleaseReleasetoSponsor = Label.UAC_typeOfReleaseReleasetoSponsor;
    String strCaseStatusDnfGen = Label.UAC_caseStatusDnfGen;
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    }
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(objUAC.id)
                             .build();
    objUACReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReferralCase.UAC_ffsName__c = userinfo.getuserid();
    // objUACReferralCase.UAC_programFacility__c  = objProgram.id;
    objUACReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objUACReferralCase.UAC_orrDecision__c = strORRDecisionDenyRelease;
    objUACReferralCase.UAC_typeOfRelease__c = strTypeOfReleaseReleasetoSponsor;
    objUACReferralCase.UAC_sponsor__c = objAdultContact.Id;
    objUACReferralCase.UAC_pendingInformation__c = 'No';
    objUACReferralCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReferralCase.UAC_orrComment__c = 'Test3';
    Insert objUACReferralCase;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReferralCase.Id, FFS.Id, idCaseTeamRole);
    System.runAs(FFS) {
      Test.startTest();
      objUACReferralCase.ContactId = objUAC.Id;
      objUACReferralCase.UAC_courtOrderedRelease__c = strCourtOrderedReleaseYes;
      objUACReferralCase.Status = strCaseStatusDnfGen;
      objUACReferralCase.UAC_reasonForDenial__c = 'Other';
      Update objUACReferralCase;
      objUACReferralCase = [select id, UAC_sponsor__c from Case where id =:objUACReferralCase.Id];
      // System.AssertEquals(objAdultContact.Id, objUACReferralCase.UAC_sponsor__c);
      List<Case> lstCaseDNF = [Select Id from Case Where ParentId =:objUACReferralCase.Id];
      System.AssertEquals(1, lstCaseDNF.Size());
      Test.stopTest();
    }
  }
  /**
   * @description Method to test DNF generation for Court Ordered Release "No"
   * @author James Qian (Deloitte) | 4-21-2021
   * @return void
   **/
  @isTest static void testcreateDNFCourtNo() {
    String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
    String strCaseRecordTypeDischargeNotification = Label.UAC_caseRecordTypeDischargeNotification;
    String strTypeOfReleaseReleasetoSponsor = Label.UAC_typeOfReleaseReleasetoSponsor;
    String strCaseStatusDnfGen = Label.UAC_caseStatusDnfGen;
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    }
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];
    Case objCaseReleaseRequest = new UAC_testCaseBuilder()
                                     .setStatus('CM Initiated')
                                     .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                     .setUAC(objUAC.id)
                                     .build();
    objCaseReleaseRequest.UAC_caseManager__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_cfsName__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_ffsName__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_leadCaseManager__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_caseCoordinator__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_orrDecision__c = strORRDecisionDenyRelease;
    objCaseReleaseRequest.UAC_typeOfRelease__c = strTypeOfReleaseReleasetoSponsor;
    objCaseReleaseRequest.UAC_sponsor__c = objAdultContact.Id;
    objCaseReleaseRequest.UAC_pendingInformation__c = 'No';
    objCaseReleaseRequest.UAC_remandForFurtherInformation__c = 'No';
    objCaseReleaseRequest.UAC_orrComment__c = 'Test3';
    Insert objCaseReleaseRequest;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objCaseReleaseRequest.Id, FFS.Id, idCaseTeamRole);
    System.runAs(FFS) {
      Test.startTest();
      objCaseReleaseRequest.ContactId = objUAC.Id;
      objCaseReleaseRequest.UAC_courtOrderedRelease__c = 'No';
      objCaseReleaseRequest.Status = strCaseStatusDnfGen;
      objCaseReleaseRequest.UAC_reasonForDenial__c = 'Other';
      Update objCaseReleaseRequest;
      objCaseReleaseRequest =
          [select id, UAC_sponsor__c from Case where id =:objCaseReleaseRequest.Id];
      // System.AssertEquals(objAdultContact.Id, objCaseReleaseRequest.UAC_sponsor__c);
      List<Case> lstCaseDNF = [Select Id from Case Where ParentId =:objCaseReleaseRequest.Id];
      System.AssertEquals(1, lstCaseDNF.Size());
      Test.stopTest();
    }
  }
  /**
   * @description Method to test DNF generation for Release to Program
   * @author James Qian (Deloitte) | 4-21-2021
   * @return void
   **/
  @isTest static void testcreateDNFReleaseToProgram() {
    String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
    String strCaseStatusDnfGen = Label.UAC_caseStatusDnfGen;
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    }
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    Account objProgram = queryProgram(null);
    Account objExtProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'No'];
    List<AccountShare> listAccShare = new List<AccountShare>();
    listAccShare.add(new AccountShare(AccountAccessLevel = 'Edit',
        OpportunityAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        AccountId = objExtProgram.Id,
        UserOrGroupId = FFS.Id));
    listAccShare.add(new AccountShare(AccountAccessLevel = 'Edit',
        OpportunityAccessLevel = 'Edit',
        ContactAccessLevel = 'Edit',
        CaseAccessLevel = 'Edit',
        AccountId = objProgram.Id,
        UserOrGroupId = FFS.Id));
    insert listAccShare;
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];
    Case objCaseReleaseRequest = new UAC_testCaseBuilder()
                                     .setStatus('CM Initiated')
                                     .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                     .setUAC(objUAC.id)
                                     .build();
    objCaseReleaseRequest.UAC_caseManager__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_cfsName__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_ffsName__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_leadCaseManager__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_caseCoordinator__c = userinfo.getuserid();
    objCaseReleaseRequest.UAC_orrDecision__c = strORRDecisionDenyRelease;
    objCaseReleaseRequest.UAC_typeOfRelease__c = Label.UAC_typeOfReleaseReleasetoProgram;
    objCaseReleaseRequest.UAC_programFacility__c = objProgram.id;
    objCaseReleaseRequest.UAC_sponsor__c = objAdultContact.Id;
    objCaseReleaseRequest.UAC_pendingInformation__c = 'No';
    objCaseReleaseRequest.UAC_remandForFurtherInformation__c = 'No';
    objCaseReleaseRequest.UAC_orrComment__c = 'Test3';
    objCaseReleaseRequest.UAC_dischargeProgramName__c = objExtProgram.Id;
    objCaseReleaseRequest.UAC_programAcceptsGuardianship__c = 'Yes';
    objCaseReleaseRequest.UAC_howWhyProgramWasIdentified__c = 'Test4';
    objCaseReleaseRequest.UAC_dateOfReferralToTheProgram__c = System.Today().addDays(-1);
    objCaseReleaseRequest.UAC_dateOfAcceptance__c = System.Today();
    objCaseReleaseRequest.UAC_ProgramAgreedToConditionOfRelease__c = 'Yes';
    Insert objCaseReleaseRequest;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objCaseReleaseRequest.Id, FFS.Id, idCaseTeamRole);
    System.runAs(FFS) {
      Test.startTest();
      objCaseReleaseRequest.ContactId = objUAC.Id;
      objCaseReleaseRequest.UAC_courtOrderedRelease__c = 'No';
      objCaseReleaseRequest.Status = strCaseStatusDnfGen;
      objCaseReleaseRequest.UAC_reasonForDenial__c = 'Other';
      Update objCaseReleaseRequest;
      objCaseReleaseRequest =
          [select id, UAC_sponsor__c from Case where id =:objCaseReleaseRequest.Id];
      // System.AssertEquals(objAdultContact.Id, objCaseReleaseRequest.UAC_sponsor__c);
      List<Case> lstCaseDNF = [Select Id from Case Where ParentId =:objCaseReleaseRequest.Id];
      System.AssertEquals(1, lstCaseDNF.Size());
      Test.stopTest();
    }
  }
  /**
   * @description Method to test ORRUAC-309 -  Auto Populate Sponsor related Fields
   * @author Manoj Sharma (Deloitte) | 6/6/2020
   * @return void
   **/
  @isTest static void testSetSponsor() {
    String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
    String strCourtOrderedReleaseYes = Label.UAC_courtOrderedReleaseYes;
    String strCaseRecordTypeDischargeNotification = Label.UAC_caseRecordTypeDischargeNotification;
    String strTypeOfReleaseReleasetoSponsor = Label.UAC_typeOfReleaseReleasetoSponsor;
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(objUAC.id)
                             .build();
    objUACReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReferralCase.UAC_ffsName__c = userinfo.getuserid();
    // objUACReferralCase.UAC_programFacility__c  = objProgram.id;
    objUACReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objUACReferralCase.UAC_remandForFurtherInformation__c = 'Yes';
    objUACReferralCase.UAC_orrComment__c = 'Test11';
    Insert objUACReferralCase;

    Test.startTest();
    objUACReferralCase.ContactId = objUAC.Id;
    objUACReferralCase.UAC_typeOfRelease__c = strTypeOfReleaseReleasetoSponsor;
    Update objUACReferralCase;
    objUACReferralCase = [select id, UAC_sponsor__c from Case where id =:objUACReferralCase.Id];
    System.AssertEquals(objAdultContact.Id, objUACReferralCase.UAC_sponsor__c);
    Test.stopTest();
  }

  /* @description Method to test ORRUAC-435 (auto-population of Sponsor Application Completion Date)
   *- Insert Operation
   * @author Karthi Subramanian (Deloitte) | 6/6/2020
   * @return void
   **/
  @isTest static void testpopulateAppCompletionDateOnInsert() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    Case objCase =
        new UAC_testCaseBuilder()
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.Id)
            .setSponsor(objAdultContact.Id)
            .setRelationshipToUAC(objAdultContactRelationship.Id)
            .build();
    Test.startTest();
    objCase.UAC_FRPDateSponsorReturnCompleted__c = Date.today() - 5;
    objCase.UAC_initalAssessmentDateComplete__c = Date.today() - 3;
    objCase.UAC_initialSponsorAssessmentDateComplete__c = Date.today() - 3;
    objCase.UAC_proofOfImmigrationUSCitizen__c = 'Complete';
    objCase.UAC_proofOfAddress__c = 'Complete';
    objCase.UAC_proofOfIdentity__c = 'Complete';
    objCase.UAC_proofOfRelationship__c = 'Complete';
    objCase.UAC_proofOfStability__c = 'Complete';
    objCase.Status = Label.UAC_sponsorAppCompletionStatus;
    insert objCase;
    Test.stopTest();
    objCase = [SELECT Id, UAC_applCompletionDate__c FROM Case WHERE Id =:objCase.Id];
    System.assertEquals(Date.today(),
        objCase.UAC_applCompletionDate__c,
        'Test method: testpopulateAppCompletionDateOnInsert() failed.');
  }

  /**
   * @description Method to test ORRUAC-435 (auto-population of Sponsor Application Completion Date)
   *- Update Operation
   * @author Karthi Subramanian (Deloitte) | 6/6/2020
   * @return void
   **/
  @isTest static void testpopulateAppCompletionDateOnUpdate() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    Case objCase =
        new UAC_testCaseBuilder()
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.Id)
            .setSponsor(objAdultContact.Id)
            .setRelationshipToUAC(objAdultContactRelationship.Id)
            .buildAndSave();
    Test.startTest();
    objCase.UAC_FRPDateSponsorReturnCompleted__c = Date.today() - 5;
    objCase.UAC_initalAssessmentDateComplete__c = Date.today() - 3;
    objCase.UAC_initialSponsorAssessmentDateComplete__c = Date.today() - 3;
    objCase.UAC_proofOfImmigrationUSCitizen__c = 'Complete';
    objCase.UAC_proofOfAddress__c = 'Complete';
    objCase.UAC_proofOfIdentity__c = 'Complete';
    objCase.UAC_proofOfRelationship__c = 'Complete';
    objCase.UAC_proofOfStability__c = 'Complete';
    objCase.Status = Label.UAC_sponsorAppCompletionStatus;
    update objCase;
    Test.stopTest();
    objCase = [SELECT Id, UAC_applCompletionDate__c FROM Case WHERE Id =:objCase.Id];
    System.assertEquals(Date.today(),
        objCase.UAC_applCompletionDate__c,
        'Test method: testpopulateAppCompletionDateOnUpdate() failed.');
  }

  /*
   * @description Method to test Release Request Case Status when created by FFS
   * @author Piyush (Deloitte) | 6/7/2020
   * @return void
   **/
  @isTest static void testUpdateCaseStatusORRInitiated() {

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    User Manager;
    User FFS;
    User ffsS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Manager = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
      ffsS = UAC_TestUtility.createUser('FFS Supervisor', Label.UAC_userRoleFFSSupervisor);
    }
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(UAC.id)
                             .build();
    insert new ContactShare(
        ContactId = UAC.Id, ContactAccessLevel = 'Edit', UserOrGroupId = ffsS.Id);
    System.runAs(ffsS) {
      Test.startTest();
      Insert objUACReferralCase;
      objUACReferralCase = [select id, Status from Case where Id =:objUACReferralCase.Id limit 1];
      system.assertEquals(objUACReferralCase.Status, 'ORR Initiated');
      Test.stopTest();
    }
  }

  /*
   * @description - ORRUAC-1099 method to test autopopulation of CFS DOC & FFS Sup
   * @author Piyush (Deloitte) | 6/17/2020
   * @return void
   **/
  @isTest static void testupdateDocCfsFfs() {
    List<Case> caselst;
    User Manager;
    User cseMngr;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Manager = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
      cseMngr = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    }
    String strNewANumber = '999999999';

    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .build();
    UAC.UAC_isUACaMaterialWitness__c = true;
    UAC.UAC_finalOrderofRemoval__c = true;
    UAC.UAC_mppCase__c = true;
    UAC.UAC_separatedFromParentLegalGuardian__c = true;
    insert UAC;

    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_bedCountAvailableMale__c = 5;
    objProgram.UAC_bedCountAvailableFemale__c = 6;
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    List<Account> prgid = new List<Account>{queryProgram(null)};
    UAC_assignmentMapping__c asgRec = new UAC_assignmentMapping__c();
    asgRec.UAC_facilityName__c = prgid[0].Id;
    asgRec.UAC_mappingCC__c = userinfo.getuserid();
    asgRec.UAC_mappingcfs__c = userinfo.getuserid();
    asgRec.UAC_mappingCM__c = userinfo.getuserid();
    asgRec.UAC_mappingDOC__c = userinfo.getuserid();
    asgRec.UAC_mappingFFS__c = userinfo.getuserid();
    asgRec.UAC_mappingFFSSupervisor__c = userinfo.getuserid();
    asgRec.UAC_mappingLCM__c = userinfo.getuserid();
    insert asgRec;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('CM Initiated')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                             .setUAC(UAC.id)
                             .build();
    objUACReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReferralCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objUACReferralCase.UAC_programFacility__c = prgid[0].Id;
    objUACReferralCase.UAC_remandForFurtherInformation__c = 'Yes';
    objUACReferralCase.UAC_orrComment__c = 'Test1';
    insert objUACReferralCase;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReferralCase.Id, cseMngr.Id, idCaseTeamRole);
    objUACReferralCase = [select id, Status, UAC_orrComment__c, UAC_cfsName__c from Case where Id
      =:objUACReferralCase.Id limit 1];
    insert new AccountTeamMember(AccountId = prgid[0].Id,
        UserId = cseMngr.Id,
        AccountAccessLevel = 'Read',
        ContactAccessLevel = 'None',
        CaseAccessLevel = 'None',
        TeamMemberRole = Label.UAC_caseTeamRoleNameRead);
    System.runAs(cseMngr) {
      Test.startTest();
      objUACReferralCase.UAC_orrComment__c = 'Comm1';
      objUACReferralCase.UAC_programFacility__c = prgid[0].Id;
      update objUACReferralCase;
      Test.stopTest();
    }
    caselst = [select id, Status, UAC_cfsName__c, UAC_isThisAMppCase__c from Case where Id
      =:objUACReferralCase.Id and UAC_cfsName__c != null];
    System.assert(caselst.size() > 0);
    System.assertEquals(Caselst[0].UAC_isThisAMppCase__c, 'Yes');
  }

  /*
   * @description Method to test changes on a release request
   * @author Rahul Roy (Deloitte) | 6/21/2020
   * @return void
   **/
  @isTest static void testChangesToReleaseRequest() {
    User Manager;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Manager = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    }
    String strNewANumber = '999999999';
    Account Program = queryProgram(null);
    Program.UAC_bedCountAvailableFemale__c = 0;
    Program.UAC_bedCountUnavailableFemale__c = 0;
    update Program;

    UAC_TestUtility.createAssets(Program.Id, 'Female', 'Unavailable', 7, true);
    UAC_TestUtility.createAssets(Program.Id, 'Male', 'Unavailable', 7, true);
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objUACReleaseRequestCase = new UAC_testCaseBuilder()
                                   .setStatus('CM Initiated')
                                   .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                   .setUAC(UAC.id)
                                   .build();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReleaseRequestCase;

    objUACDNFCase = new UAC_testCaseBuilder()
                        .setStatus('Discharge-(Initiated)')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeDischarge)
                        .setUAC(UAC.id)
                        .build();

    objUACDNFCase.Status = Label.UAC_caseStatusDischargeCompleted;
    objUACDNFCase.ParentId = objUACReleaseRequestCase.Id;
    objUACDNFCase.UAC_programFacility__c = Program.Id;
    insert objUACDNFCase;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReleaseRequestCase.Id, Manager.Id, idCaseTeamRole);
    System.runAs(Manager) {
      Test.startTest();
      objUACReleaseRequestCase.UAC_sponsorComment__c = 'Test';
      try {
        update objUACReleaseRequestCase;
      }
      Catch(Exception e) {
        system.debug(e.getMessage());
        system.assertEquals(True, e.getMessage().contains(Label.UAC_dischargedError));
      }
      Test.stopTest();
    }
  }

  /**
   * @description Method to test ORRUAC-39 -  Auto Create IHI record
   * @author Abhisek Pati (Deloitte) | 6/19/2020
   * @return void
   **/
  @isTest static void testCreateInitialHealthInformation() {

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Test.startTest();
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('New Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    Test.stopTest();
    List<UAC_referralRelatedRecord__c> lstIHI =
        [select id from UAC_referralRelatedRecord__c where UAC_referral__c =:objUACReferralCase.id];
    system.assertEquals(1, lstIHI.size());
  }

  /**
   * @description Method to test ORRUAC-80 -  Test special placement request
   * @author Issam Awwad (Deloitte) | 6/19/2020
   * @return void
   **/
  @isTest static void testRequestSpecialPlacementWithFFS() {

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Test.startTest();
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    objUACReferralCase.UAC_RequiresPlacementChecklist__c = true;
    objUACReferralCase.Status = 'Supervisor Approval Requested';
    try {
      update objUACReferralCase;
    } catch (Exception e) {
      system.assert(e.getMessage().contains(strSupervisorApprovalRequestedError));
    }
    Test.stopTest();
  }

  /**
   * @description Method to test ORRUAC-82 -  Test Approve special placement
   * @author Issam Awwad (Deloitte) | 6/29/2020
   * @return void
   **/
  @isTest static void testApproveSpecialPlacement() {
    String strExceptionMessage = '';
    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Test.startTest();
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    User intakesUser = UAC_TestUtility.CreateUser('Intakes Team');
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReferralCase.Id, intakesUser.Id, idCaseTeamRole);
    System.runAs(Intakesuser) {
      objUACReferralCase.UAC_RequiresPlacementChecklist__c = true;
      objUACReferralCase.Status = 'Supervisor Approved';
      try {
        update objUACReferralCase;
      } catch (Exception e) {
        strExceptionMessage = e.getMessage();
      }
    }
    Test.stopTest();
    system.assert(strExceptionMessage.contains(strSupervisorApprovedError));
  }
  /*
   * @description Method to test update on Case Teams
   * @author Rahul Roy (Deloitte) | 6/30/2020
   * @return void
   **/
  /*
  @isTest static void testUpdateCaseTeam() {

    User Manager = [
      SELECT Id,
      profile.name FROM User WHERE profile.name = 'Case Manager' AND IsActive = true limit 1
    ];
    User LCM = [
      SELECT Id,
      profile.name FROM User WHERE profile.name = 'Lead Case Manager' AND IsActive = true limit 1
    ];
    User FFS =
        [SELECT Id, profile.name FROM User WHERE profile.name = 'FFS' AND IsActive = true limit 1];
    User FFSS = [
      SELECT Id,
      profile.name FROM User WHERE profile.name = 'FFS Supervisor' AND IsActive = true limit 1
    ];
    User CC = [
      SELECT Id,
      profile.name FROM User WHERE profile.name = 'Case Coordinator' AND IsActive = true limit 1
    ];

    User DOC = [
      SELECT Id,
      profile.name FROM User WHERE profile.name = 'Direct Operations Coordinator' AND IsActive =
          true limit 1
    ];

    User CFS =
        [SELECT Id, profile.name FROM User WHERE profile.name = 'CFS' AND IsActive = true limit 1];

    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objUACReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('CM Initiated')
            .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
            .setUAC(UAC.id)
            .buildAndSave();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    update objUACReleaseRequestCase;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReleaseRequestCase.Id, Manager.Id, idCaseTeamRole);
    System.runAs(Manager) {
      Test.startTest();
      objUACReleaseRequestCase.UAC_caseManager__c = Manager.Id;
      update objUACReleaseRequestCase;

      objUACReleaseRequestCase =
          [select id, UAC_caseManager__c from Case where id =:objUACReleaseRequestCase.Id];
      CaseTeamMember objUACReleaseRequestCaseTeam =
          [SELECT Id, MemberId, ParentId, TeamRoleId FROM CaseTeamMember where ParentId
            =:objUACReleaseRequestCase.Id];
      System.AssertEquals(
          objUACReleaseRequestCase.UAC_caseManager__c, objUACReleaseRequestCaseTeam.MemberId);

      objUACReleaseRequestCase.UAC_leadCaseManager__c = LCM.Id;
      objUACReleaseRequestCase.UAC_ffsName__c = FFS.Id;
      objUACReleaseRequestCase.UAC_ffsSupervisor__c = FFSS.Id;
      //objUACReleaseRequestCase.UAC_directOperationsCoordinator__c = DOC.Id;
      objUACReleaseRequestCase.UAC_caseCoordinator__c = CC.Id;
      objUACReleaseRequestCase.UAC_cfsName__c = CFS.Id;
      update objUACReleaseRequestCase;

      objUACReleaseRequestCase = [select id,
        UAC_leadCaseManager__c,
        UAC_ffsName__c,
        UAC_ffsSupervisor__c,
        UAC_directOperationsCoordinator__c,
        UAC_caseCoordinator__c,
        UAC_cfsName__c from Case where id =:objUACReleaseRequestCase.Id];
      CaseTeamMember objUACReleaseRequestCaseTeamLCM = [
        SELECT Id,
        MemberId,
        ParentId,
        TeamRoleId FROM CaseTeamMember where ParentId
        =:objUACReleaseRequestCase.Id AND MemberId
        =:objUACReleaseRequestCase.UAC_leadCaseManager__c
      ];
      CaseTeamMember objUACReleaseRequestCaseTeamFFS = [
        SELECT Id,
        MemberId,
        ParentId,
        TeamRoleId FROM CaseTeamMember where ParentId =:objUACReleaseRequestCase.Id AND MemberId
                                                      =:objUACReleaseRequestCase.UAC_ffsName__c
      ];
      CaseTeamMember objUACReleaseRequestCaseTeamFFSS = [
        SELECT Id,
        MemberId,
        ParentId,
        TeamRoleId FROM CaseTeamMember where ParentId
        =:objUACReleaseRequestCase.Id AND MemberId
        =:objUACReleaseRequestCase.UAC_ffsSupervisor__c
      ];
      CaseTeamMember objUACReleaseRequestCaseTeamDOC = [
        SELECT Id,
        MemberId,
        ParentId,
        TeamRoleId FROM CaseTeamMember where ParentId
        =:objUACReleaseRequestCase.Id AND MemberId
        =:objUACReleaseRequestCase.UAC_directOperationsCoordinator__c
      ];
      CaseTeamMember objUACReleaseRequestCaseTeamCC = [
        SELECT Id,
        MemberId,
        ParentId,
        TeamRoleId FROM CaseTeamMember where ParentId
        =:objUACReleaseRequestCase.Id AND MemberId
        =:objUACReleaseRequestCase.UAC_caseCoordinator__c
      ];
      CaseTeamMember objUACReleaseRequestCaseTeamCFS = [
        SELECT Id,
        MemberId,
        ParentId,
        TeamRoleId FROM CaseTeamMember where ParentId =:objUACReleaseRequestCase.Id AND MemberId
                                                      =:objUACReleaseRequestCase.UAC_cfsName__c
      ];

      System.AssertEquals(objUACReleaseRequestCase.UAC_leadCaseManager__c,
          objUACReleaseRequestCaseTeamLCM.MemberId);
      System.AssertEquals(
          objUACReleaseRequestCase.UAC_ffsName__c, objUACReleaseRequestCaseTeamFFS.MemberId);
      System.AssertEquals(
          objUACReleaseRequestCase.UAC_ffsSupervisor__c, objUACReleaseRequestCaseTeamFFSS.MemberId);
      System.AssertEquals(objUACReleaseRequestCase.UAC_directOperationsCoordinator__c,
          objUACReleaseRequestCaseTeamDOC.MemberId);
      System.AssertEquals(
          objUACReleaseRequestCase.UAC_caseCoordinator__c, objUACReleaseRequestCaseTeamCC.MemberId);
      System.AssertEquals(
          objUACReleaseRequestCase.UAC_cfsName__c, objUACReleaseRequestCaseTeamCFS.MemberId);
      Test.stopTest();
    }
  }
  */

  /*
   * @description Method to update Pending Information and
   *              Remand For Further Information fields to Null
   * @author Rahul Roy (Deloitte) | 7/1/2020
   * @return void
   **/
  @isTest static void testUpdatePendingInfoAndRemandInfoToNull() {
    User Manager;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Manager = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    }
    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objUACReleaseRequestCase = new UAC_testCaseBuilder()
                                   .setStatus('CM to Provide Further Information')
                                   .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                   .setUAC(UAC.id)
                                   .build();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReleaseRequestCase;
    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    insert createCaseTeamMember(objUACReleaseRequestCase.Id, Manager.Id, idCaseTeamRole);
    System.runAs(Manager) {
      Test.startTest();
      objUACReleaseRequestCase.Status = 'CC Review';
      update objUACReleaseRequestCase;
      System.AssertEquals(objUACReleaseRequestCase.UAC_pendingInformation__c, Null);
      objUACReleaseRequestCase.Status = 'CM to Provide Further Information';
      update objUACReleaseRequestCase;
      objUACReleaseRequestCase.Status = 'FFS Review';
      update objUACReleaseRequestCase;
      Test.stopTest();
      List<Case> cslst = [Select Id, UAC_remandForFurtherInformation__c from Case where Id
        =:objUACReleaseRequestCase.Id];
      System.AssertEquals(Null, cslst[0].UAC_remandForFurtherInformation__c);
    }
  }
  /*
   * @description Method to test Owner Update
   * @author Rahul Roy (Deloitte) | 7/15/2020
   * @return void
   **/
  @isTest static void testUpdateOwnertoQueueHS() {
    Group objGroup = [
      SELECT DeveloperName,
      Id,
      Name,
      Type FROM Group Where DeveloperName in('UAC_PRS')and Type = 'Queue' limit 1
    ];
    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objUACReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('HS/PRS Referral Initiation')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
            .setUAC(UAC.id)
            .build();

    objUACReleaseRequestCase.UAC_hsPrsQueue__c = 'PRS';
    objUACReleaseRequestCase.Type = 'PRS -Only';
    insert objUACReleaseRequestCase;

    Test.startTest();
    objUACReleaseRequestCase.Status = Label.UAC_pending;
    update objUACReleaseRequestCase;
    System.AssertEquals(
        [Select OwnerId from Case where Id =:objUACReleaseRequestCase.Id].ownerId, objGroup.Id);
    Test.stopTest();
  }

  /*
   * @description Method to statusUpdatesHSPRSReferral
   * @author Abhisek Pati (Deloitte) | 4/6/2021
   * @return void
   **/
  @isTest static void statusUpdatesHSPRSReferralTest() {
    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber + '11')  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();
    objUACReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('HS/PRS Referral Initiation')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
            .setUAC(UAC.id)
            .build();
    user Testuser = new user();
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Testuser = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    }
    objUACReleaseRequestCase.OwnerId = UserInfo.getUserId();
    objUACReleaseRequestCase.UAC_hsPrsQueue__c = 'PRS';
    objUACReleaseRequestCase.Type = 'PRS -Only';
    insert objUACReleaseRequestCase;

    Test.startTest();
    objUACReleaseRequestCase.Status = 'Closed';
    objUACReleaseRequestCase.OwnerId = Testuser.Id;
    update objUACReleaseRequestCase;
    System.AssertEquals(
        [Select UAC_hsPrsAcceptanceDateHS__c from Case where Id =:objUACReleaseRequestCase.Id]
            .UAC_hsPrsAcceptanceDateHS__c,
        system.today());
    Test.stopTest();
  }

  /*
   * @description Method to test Auto generation of HSPRS Referral
   * @author Rahul Roy (Deloitte) | 7/15/2020
   * @return void
   **/
  @isTest static void testCreateHSPRSReferral() {

    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objUACReleaseRequestCase = new UAC_testCaseBuilder()
                                   .setStatus('CM to Provide Further Information')
                                   .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                   .setUAC(UAC.id)
                                   .build();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReleaseRequestCase;

    Test.startTest();
    objUACReleaseRequestCase.Status = Label.UAC_caseStatusHSRequested;
    objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_conductHomeStudyTVPRA;
    objUACReleaseRequestCase.UAC_orrComment__c = 'Test1';
    update objUACReleaseRequestCase;
    System.AssertNotEquals(
        [Select count() from Case where parentID =:objUACReleaseRequestCase.Id], null);
    Test.stopTest();
  }
  /*
   * @description Method to test prevent duplicate HSPRS Referral
   * @author Rahul Roy (Deloitte) | 7/17/2020
   * @return void
   **/
  @isTest static void testPreventduplicateHSPRSReferral() {
    Group objGroup = [
      SELECT DeveloperName,
      Id,
      Name,
      Type FROM Group Where DeveloperName in('UAC_PRS')and Type = 'Queue' limit 1
    ];
    String strNewANumber = '999999999';
    Contact UAC =
        new UAC_testContactBuilder()
            .setANumber(strNewANumber)
            .setLastName(strNewANumber)  // Update last name to avoid Duplicate Contact error
            .setRecordTypeDeveloperName(strContactRecordTypeUAC)
            .buildAndSave();

    objUACReleaseRequestCase =
        new UAC_testCaseBuilder()
            .setStatus('HS/PRS Referral Initiation')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
            .setUAC(UAC.id)
            .build();

    Case objUACReleaseRequestCase2 =
        new UAC_testCaseBuilder()
            .setStatus('HS/PRS Referral Initiation')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
            .setUAC(UAC.id)
            .build();
    objUACReleaseRequestCase.UAC_hsPrsQueue__c = 'PRS';
    objUACReleaseRequestCase.Type = 'PRS -Only';
    insert objUACReleaseRequestCase;

    Test.startTest();
    objUACReleaseRequestCase2.UAC_hsPrsQueue__c = 'PRS';
    objUACReleaseRequestCase2.Type = 'PRS -Only';
    try {
      insert objUACReleaseRequestCase2;
    } catch (Exception e) {
      system.debug(e.getMessage());
      System.assert(e.getMessage().contains(Label.UAC_hsprsReferralExists));
    }
    Test.stopTest();
  }

  /*
   * @description Method to test Admission Entry and Contact Admitted Date
   * @author Abhisek Pati (Deloitte) | 7/21/2020
   * @return
   **/
  @isTest static void admissionAdmittedDateTest() {

    contact UAC = [select id,
      UAC_status__c,
      UAC_mostRecentAdmittedDateTime__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    UAC.Birthdate = System.today();
    Update UAC;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase.status = strAdmittedStatus;
    objUACReferralCase.Type = 'Initial Placement';
    test.startTest();
    update objUACReferralCase;
    objUACReferralCase.UAC_dateTimeOfDischarge__c = System.now() + 4;
    update objUACReferralCase;
    objUACReferralCase = [select id, Status, UAC_admittedDateTime__c from Case where Id
      =:objUACReferralCase.Id limit 1];
    UAC = [select id, UAC_mostRecentAdmittedDateTime__c from contact where Id =:UAC.Id limit 1];
    system.assertNotEquals(objUACReferralCase.UAC_admittedDateTime__c, null);
    system.assertEquals(UAC.UAC_mostRecentAdmittedDateTime__c, null);
    test.stopTest();
  }

  /*
   * @description Method to test Admission Entry status sync with Contact
   * @author James Qian (Deloitte) | 08/06/2020
   * @return
   **/
  @isTest static void admissionContactSyncStatus() {
    contact UAC = [select id,
      UAC_status__c,
      UAC_mostRecentAdmittedDateTime__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    UAC.Birthdate = System.today();
    Update UAC;
    Case objAdmissionCase = new UAC_testCaseBuilder()
                                .setStatus(strPendingAdmissionStatus)
                                .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                                .setUAC(UAC.id)
                                .buildAndSave();
    objAdmissionCase.status = strAdmittedStatus;
    Test.startTest();
    update objAdmissionCase;
    Contact queriedUAC = [select id, UAC_status__c from contact where Id =:UAC.Id limit 1];
    Test.stopTest();
    System.assertEquals(strAdmittedStatus, queriedUAC.UAC_status__c);
  }

  /*
   * @description Method to test newly inserted referrals to set
   * In ORR Care field
   * @author Issam Awwad (Deloitte) | 7/29/2020
   * @return
   **/
  @isTest static void processNewUACReferralsTest() {
    contact UAC = [select id,
      UAC_status__c,
      UAC_mostRecentAdmittedDateTime__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    test.startTest();
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase =
        [select id, status, ContactId, UAC_referralCancellationReason__c from Case limit 1];

    Contact objContact = [select id, UAC_inORRCare__c from contact limit 1];
    system.assertEquals(objContact.UAC_inORRCare__c, 'Yes');
    test.stopTest();
  }
  /*
   * @description Method to test updated referrals to set
   * In ORR Care field
   * @author Issam Awwad (Deloitte) | 7/29/2020
   * @return
   **/
  @isTest static void processUpdatedUACReferralsTest() {
    contact UAC = [select id,
      UAC_status__c,
      UAC_mostRecentAdmittedDateTime__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    test.startTest();
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase =
        [select id, status, ContactId, UAC_referralCancellationReason__c from Case limit 1];

    Contact objContact = [select id, UAC_inORRCare__c from contact limit 1];
    objUACReferralCase.UAC_referralCancellationReason__c = 'Cancel Test';
    objUACReferralCase.status = 'Referral Cancelled';
    update objUACReferralCase;
    objContact = [select id, UAC_inORRCare__c from contact limit 1];
    system.assertEquals(objContact.UAC_inORRCare__c, 'No');
    test.stopTest();
  }

  /**
   * @description Method to test ORRUAC-1686 -  Auto Populate Sponsor related
   *Fields
   * @author Piyush Pranav (Deloitte) | 7/30/2020
   * update coverage for ORRUAC-1944 AC5 (markRRHSComplete method) 08252020
   * @return void
   **/
  @isTest static void testSetHsPrSponsor() {
    String strORRDecisionDenyRelease = Label.UAC_orrDecisionDenyRelease;
    String strCourtOrderedReleaseYes = Label.UAC_courtOrderedReleaseYes;
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];
    objUACReleaseRequestCase = new UAC_testCaseBuilder()
                                   .setStatus('CM Initiated')
                                   .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                   .setUAC(objUAC.id)
                                   .build();
    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReleaseRequestCase;
    objHsPrsReferralCase = new UAC_testCaseBuilder()
                               .setStatus('HS/PRS Referral Initiation')
                               .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
                               .setUAC(objUAC.id)
                               .build();
    objHsPrsReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objHsPrsReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objHsPrsReferralCase.UAC_hsPrsQueue__c = 'PRS';
    objHsPrsReferralCase.Type = 'PRS -Only';
    objHsPrsReferralCase.ContactId = objUAC.Id;
    objHsPrsReferralCase.ParentId = objUACReleaseRequestCase.Id;
    insert objHsPrsReferralCase;

    Test.startTest();
    objHsPrsReferralCase =
        [select id, UAC_sponsor__c, UAC_hsPrsOutcomeOfHomeStudy__c from Case where id
          =:objHsPrsReferralCase.Id];
    System.AssertEquals(objAdultContact.Id, objHsPrsReferralCase.UAC_sponsor__c);
    objHsPrsReferralCase.UAC_hsPrsOutcomeOfHomeStudy__c =
        'Negative';  // ORRUAC-1944 AC5 assertion set
    update objHsPrsReferralCase;
    objUACReleaseRequestCase = [Select Id, UAC_hsPrsOutcomeOfHomeStudy__c from Case where id
      =:objUACReleaseRequestCase.Id];
    System.AssertEquals(objHsPrsReferralCase.UAC_hsPrsOutcomeOfHomeStudy__c,
        'Negative');  // ORRUAC-1944 AC5 assertion
    Test.stopTest();
  }

  /*
   * @description Method to test LCM and CC for Transfer Request
   * @author Abhisek Pati (Deloitte) | 8/6/2020
   * @return
   **/
  @isTest static void setTransferRequestLCMandCCTest() {

    Id ProgramId = queryProgram(null).id;
    // creating AccountTeamMember
    AccountTeamMember LCM = new AccountTeamMember();
    LCM.AccountId = ProgramId;
    LCM.TeamMemberRole = 'Lead Case Manager';
    LCM.UserId = UserInfo.getUserId();
    insert LCM;

    contact UAC = [select id, UAC_status__c from contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase.UAC_programFacility__c = ProgramId;
    update objUACReferralCase;

    Case objTransferCase = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                               .setUAC(UAC.id)
                               .build();
    objTransferCase.ParentId = objUACReferralCase.Id;
    objTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    objTransferCase.UAC_currentProgram__c = ProgramId;

    Test.startTest();
    insert objTransferCase;
    Test.stopTest();

    objTransferCase = [select id, UAC_leadCaseManager__c from Case where id =:objTransferCase.Id];
    System.AssertEquals(objTransferCase.UAC_leadCaseManager__c, LCM.UserId);
  }
  /**
   * @description Method to test ORRUAC-1686 -  Auto Populate Sponsor related Fields
   * @author James Qian (Deloitte) | 8/4/2020
   * @return CaseTeamMember
   **/
  private
  static CaseTeamMember createCaseTeamMember(Id idCase, Id idUser, Id idRole) {
    return new CaseTeamMember(MemberId = idUser, ParentId = idCase, TeamRoleId = idRole);
  }
  /*
   * @description Method to test population of NOC values
   * @author Rahul Roy (Deloitte) | 08/09/2020
   * @return void
   **/
  @isTest static void testPopulateNOCVaues() {

    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_bedCountAvailableMale__c = 5;
    objProgram.UAC_bedCountAvailableFemale__c = 6;
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    List<Account> prgid = new List<Account>{queryProgram(null)};

    String strNewANumber = '999999999';
    Contact UAC = new UAC_testContactBuilder()
                      .setANumber(strNewANumber)
                      .setLastName(strNewANumber)
                      .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                      .buildAndSave();
    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    }
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUAC.UAC_program__c = prgid[0].Id;
    Update objUAC;
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c,
      UAC_uacLookup__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    objUACDNFCase = new UAC_testCaseBuilder()
                        .setStatus('Discharge-(Initiated)')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeDischargeNotification)
                        .setUAC(UAC.id)
                        .buildAndSave();

    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Draft')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(UAC.id)
                        .build();
    objUACNOCCase.UAC_sponsor__c = objAdultContact.Id;
    Insert objUACNOCCase;
    Test.startTest();
    objUACNOCCase.ContactId = objUAC.Id;
    Update objUACNOCCase;
    System.AssertEquals(objUACDNFCase.UAC_programFacility__c, objUACNOCCase.UAC_programFacility__c);
    Test.stopTest();
  }

  /*
   * @description Method to test population of NOC values
   * @author Rahul Roy (Deloitte) | 08/09/2020
   * @return void
   **/
  @isTest static void testPopulateNOCVaues2() {

    String strNewANumber = '999999999';
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_bedCountAvailableMale__c = 5;
    objProgram.UAC_bedCountAvailableFemale__c = 6;
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    Contact UAC = new UAC_testContactBuilder()
                      .setANumber(strNewANumber)
                      .setLastName(strNewANumber)
                      .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                      .buildAndSave();

    List<Account> prgid = new List<Account>{queryProgram(null)};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    objUACDNFCase = new UAC_testCaseBuilder()
                        .setStatus('Discharge-(Initiated)')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeDischargeNotification)
                        .setUAC(objUAC.id)
                        .build();

    Test.startTest();
    objUACDNFCase.UAC_programFacility__c = prgid[0].Id;
    objUACDNFCase.UAC_sponsor__c = objAdultContact.Id;
    Insert objUACDNFCase;

    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Draft')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(UAC.id)
                        .buildAndSave();
    objUACNOCCase.ContactId = objUAC.Id;
    Update objUACNOCCase;

    objUACDNFCase = [select id, UAC_programFacility__c from Case where id =:objUACDNFCase.Id];
    objUACNOCCase = [select id, UAC_programFacility__c from Case where id =:objUACNOCCase.Id];
    System.AssertEquals(objUACDNFCase.UAC_programFacility__c, objUACNOCCase.UAC_programFacility__c);
    Test.stopTest();
  }

  /*
   * @description Method to test population of NOC share records after insert
   * @author James Qian (Deloitte) | 02/02/2021
   * @return void
   */
  @isTest static void testShareNOCOnInsert() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Test.startTest();
    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Draft')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(objUAC.id)
                        .build();
    objUACNOCCase.UAC_nocAllegedPerpertrator__c = 'Program Staff';
    objUACNOCCase.UAC_notificationOfConcernCategory__c = 'Abuse or Neglect';
    objUACNOCCase.UAC_nocCategoryOfAbuseOrNeglect__c = 'Emotional Abuse';
    objUACNOCCase.UAC_nocHowWasThisUACInvolved__c = 'Victim';
    insert objUACNOCCase;
    Test.stopTest();
    List<CaseShare> listCaseShareManual =
        [SELECT Id FROM CaseShare WHERE CaseId =:objUACNOCCase.Id AND RowCause = 'Manual'];
    System.assertEquals(2, listCaseShareManual.size());
  }

  /*
   * @description Method to test population of NOC share records after update
   * @author James Qian (Deloitte) | 03/08/2021
   * @return void
   */
  @isTest static void testShareNOCOnUpdate() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Test.startTest();
    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Draft')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(objUAC.id)
                        .build();
    objUACNOCCase.UAC_nocAllegedPerpertrator__c = 'Non-Staff Adult';
    objUACNOCCase.UAC_notificationOfConcernCategory__c = 'Abuse or Neglect';
    objUACNOCCase.UAC_nocCategoryOfAbuseOrNeglect__c = 'Emotional Abuse';
    objUACNOCCase.UAC_nocHowWasThisUACInvolved__c = 'Victim';
    insert objUACNOCCase;
    objUACNOCCase.UAC_nocAllegedPerpertrator__c = 'Program Staff';
    update objUACNOCCase;
    List<CaseShare> listCaseShareManual =
        [SELECT Id FROM CaseShare WHERE CaseId =:objUACNOCCase.Id AND RowCause = 'Manual'];
    System.assertEquals(2, listCaseShareManual.size());
    objUACNOCCase.Status = 'Submitted';
    update objUACNOCCase;
    Test.stopTest();
    List<CaseShare> listCaseShareManual2 =
        [SELECT Id FROM CaseShare WHERE CaseId =:objUACNOCCase.Id AND RowCause = 'Manual'];
    System.assertEquals(1, listCaseShareManual2.size());
  }

  /*
   * @description Method to test deletion of NOC
   * @author Rahul Roy (Deloitte) | 08/09/2020
   * @return void
   **/
  @isTest static void testCheckCaseNOCDelete() {

    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Draft')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(objUAC.id)
                        .buildAndSave();
    objUACNOCCase.Status = 'Submitted';
    Update objUACNOCCase;

    Test.startTest();
    try {
      Delete objUACNOCCase;
    } catch (Exception e) {
      System.assert(e.getMessage().contains(Label.UAC_CaseNOCStatusSubmitted));
    }
    Test.stopTest();
  }

  /*
   * @description Method to test NOC Email US-2428 AC1
   * @author Piyush | 09/09/2020
   * @return void
   **/

  @isTest static void testNOCEmailToHSPrsProv() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objHsPrsReferralCase = new UAC_testCaseBuilder()
                               .setStatus('HS/PRS Referral Initiation')
                               .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral)
                               .setUAC(objUAC.id)
                               .build();
    objHsPrsReferralCase.UAC_caseManager__c = userinfo.getuserid();
    objHsPrsReferralCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objHsPrsReferralCase.UAC_hsPrsQueue__c = 'PRS';
    objHsPrsReferralCase.Type = 'PRS -Only';
    objHsPrsReferralCase.Status = 'Active';
    objHsPrsReferralCase.UAC_hSPRSPrimaryProviderName__c = userinfo.getuserid();
    insert objHsPrsReferralCase;

    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Draft')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(objUAC.id)
                        .build();
    Test.startTest();
    objUACNOCCase.ParentId = objHsPrsReferralCase.Id;
    objUACNOCCase.UAC_notificationOfConcernCategory__c = 'Abuse or Neglect';
    objUACNOCCase.UAC_nocCategoryOfAbuseOrNeglect__c = 'Sexual Abuse';
    objUACNOCCase.UAC_nocTypeOfSexualAbuse__c = 'Sexual Abuse';
    objUACNOCCase.UAC_notifyPSATeam__c = 'Yes';
    objUACNOCCase.UAC_nocAllegedPerpertrator__c = 'Non-UC Child';
    objUACNOCCase.UAC_nocHowWasThisUACInvolved__c = 'Victim';
    insert objUACNOCCase;
    System.assertEquals('Sexual Abuse', objUACNOCCase.UAC_nocTypeOfSexualAbuse__c);
    Test.stopTest();
  }

  /*
   * @description Method to test NOC Email US-2428 AC1
   * @author Piyush | 09/09/2020
   * @return void
   **/

  @isTest static void testNOCEmailToACFPrgDir() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Account objProgramCase = new UAC_testAccountBuilder()
                                 .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                 .setType(STR_PROGRAM_TYPE)
                                 .build();
    objProgramCase.Type = 'Shelter';
    objProgramCase.UAC_withinORRNetwork__c = 'Yes';
    insert objProgramCase;
    UAC_TestUtility.createAssets(objProgramCase.Id, 'Male', 'Available', 7, true);
    List<Account> prgid = new List<Account>{queryProgram(null)};

    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUAC.UAC_program__c = prgid[0].Id;
    update objUAC;

    UAC_Event__c evt = new UAC_Event__c();
    evt.UAC_eventType__c = 'UC Level Event';
    evt.UAC_programID__c = objProgramCase.Id;
    evt.UAC_eventOccurredInORRCare__c = 'Yes';
    evt.UAC_locationofEvent__c = 'Foster Home';
    evt.UAC_synopsisofEvent__c = 'Test1';
    evt.UAC_eventStartDateTime__c = System.Now();
    evt.UAC_dateTimeReportedToCareProvider__c = System.Now();
    insert evt;

    String orgId = UserInfo.getOrganizationId();
    String dateString =
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;
    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;
    u.Alias = 'Tcode';
    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;

    Integer randomInt1 = Integer.valueOf(math.rint(math.random() * 1000001));
    String uniqueName1 = orgId + dateString + randomInt1;
    User u1 = new user();
    u1.LastName = 'Test Code1';
    u1.email = uniqueName1 + '@test' + orgId + '.org';
    u1.Username = uniqueName1 + '@test' + '.org' + orgId;
    u1.Alias = 'Tcode1';
    u1.CommunityNickname = 'test121';
    u1.LocaleSidKey = 'en_US';
    u1.TimeZoneSidKey = 'GMT';
    u1.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u1.LanguageLocaleKey = 'en_US';
    u1.EmailEncodingKey = 'UTF-8';
    insert u1;

    Integer randomInt2 = Integer.valueOf(math.rint(math.random() * 1000002));
    String uniqueName2 = orgId + dateString + randomInt2;
    User u2 = new user();
    u2.LastName = 'Test Code2';
    u2.email = uniqueName2 + '@test' + orgId + '.org';
    u2.Username = uniqueName2 + '@test' + '.org' + orgId;
    u2.Alias = 'Tcode2';
    u2.CommunityNickname = 'test122';
    u2.LocaleSidKey = 'en_US';
    u2.TimeZoneSidKey = 'GMT';
    u2.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u2.LanguageLocaleKey = 'en_US';
    u2.EmailEncodingKey = 'UTF-8';
    insert u2;

    AccountTeamMember ATM1 = new AccountTeamMember();
    ATM1.AccountId = prgid[0].Id;
    ATM1.TeamMemberRole = 'Federal Field Specialist';
    ATM1.UserId = UserInfo.getUserId();
    insert ATM1;

    AccountTeamMember ATM2 = new AccountTeamMember();
    ATM2.AccountId = prgid[0].Id;
    ATM2.TeamMemberRole = 'Program Director';
    ATM2.UserId = u.id;
    insert ATM2;

    AccountTeamMember ATM3 = new AccountTeamMember();
    ATM3.AccountId = prgid[0].Id;
    ATM3.TeamMemberRole = 'Project Officer';
    ATM3.UserId = u1.id;
    insert ATM3;

    AccountTeamMember ATM4 = new AccountTeamMember();
    ATM4.AccountId = prgid[0].Id;
    ATM4.TeamMemberRole = 'Federal Field Specialist Supervisor';
    ATM4.UserId = u2.id;
    insert ATM4;

    List<AccountTeamMember> lstatm =
        [Select UserId, TeamMemberRole, AccountId from AccountTeamMember where AccountId
          =:objProgramCase.Id];

    Test.startTest();
    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Submitted')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(objUAC.id)
                        .build();
    objUACNOCCase.UAC_notificationOfConcernCategory__c = Label.UAC_notifOfConcAbuseNeg;
    objUACNOCCase.UAC_programFacility__c = prgid[0].Id;
    objUACNOCCase.UAC_nocCategoryOfAbuseOrNeglect__c = 'Sexual Abuse';
    objUACNOCCase.UAC_nocTypeOfSexualAbuse__c = 'Sexual Abuse';
    objUACNOCCase.UAC_notifyPSATeam__c = 'Yes';
    objUACNOCCase.UAC_nocAllegedPerpertrator__c = 'Non-UC Child';
    objUACNOCCase.UAC_nocHowWasThisUACInvolved__c = 'Victim';
    objUACNOCCase.UAC_eventID__c = evt.Id;
    objUACNOCCase.ContactId = objUAC.Id;
    insert objUACNOCCase;
    System.assertEquals('Sexual Abuse', objUACNOCCase.UAC_nocTypeOfSexualAbuse__c);
    Test.stopTest();
  }

  /*
   * @description Method to test NOC Email US-2428 AC3.2
   * @author Piyush | 09/09/2020
   * @return void
   **/

  @isTest static void testNOCEmailToACFPrgDir1() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    Account objProgramCase = new UAC_testAccountBuilder()
                                 .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                 .setType(STR_PROGRAM_TYPE)
                                 .build();
    objProgramCase.Type = 'Shelter';
    objProgramCase.UAC_withinORRNetwork__c = 'Yes';
    insert objProgramCase;
    UAC_TestUtility.createAssets(objProgramCase.Id, 'Male', 'Available', 7, true);
    List<Account> prgid = new List<Account>{queryProgram(objProgramCase.Id)};

    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUAC.UAC_program__c = prgid[0].Id;
    update objUAC;

    String orgId = UserInfo.getOrganizationId();
    String dateString =
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;
    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@test' + orgId + '.org';
    u.Username = uniqueName + '@test' + '.org' + orgId;
    u.Alias = 'Tcode';
    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    insert u;

    Integer randomInt1 = Integer.valueOf(math.rint(math.random() * 1000001));
    String uniqueName1 = orgId + dateString + randomInt1;
    User u1 = new user();
    u1.LastName = 'Test Code1';
    u1.email = uniqueName1 + '@test' + orgId + '.org';
    u1.Username = uniqueName1 + '@test' + '.org' + orgId;
    u1.Alias = 'Tcode1';
    u1.CommunityNickname = 'test121';
    u1.LocaleSidKey = 'en_US';
    u1.TimeZoneSidKey = 'GMT';
    u1.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u1.LanguageLocaleKey = 'en_US';
    u1.EmailEncodingKey = 'UTF-8';
    insert u1;

    Integer randomInt2 = Integer.valueOf(math.rint(math.random() * 1000002));
    String uniqueName2 = orgId + dateString + randomInt2;
    User u2 = new user();
    u2.LastName = 'Test Code2';
    u2.email = uniqueName2 + '@test' + orgId + '.org';
    u2.Username = uniqueName2 + '@test' + '.org' + orgId;
    u2.Alias = 'Tcode2';
    u2.CommunityNickname = 'test122';
    u2.LocaleSidKey = 'en_US';
    u2.TimeZoneSidKey = 'GMT';
    u2.ProfileID = [select id from profile where name = 'System Administrator'].id;
    u2.LanguageLocaleKey = 'en_US';
    u2.EmailEncodingKey = 'UTF-8';
    insert u2;

    AccountTeamMember ATM1 = new AccountTeamMember();
    ATM1.AccountId = prgid[0].Id;
    ATM1.TeamMemberRole = 'Federal Field Specialist';
    ATM1.UserId = UserInfo.getUserId();
    insert ATM1;

    AccountTeamMember ATM2 = new AccountTeamMember();
    ATM2.AccountId = prgid[0].Id;
    ATM2.TeamMemberRole = 'Program Director';
    ATM2.UserId = u.id;
    insert ATM2;

    AccountTeamMember ATM3 = new AccountTeamMember();
    ATM3.AccountId = prgid[0].Id;
    ATM3.TeamMemberRole = 'Project Officer';
    ATM3.UserId = u1.id;
    insert ATM3;

    AccountTeamMember ATM4 = new AccountTeamMember();
    ATM4.AccountId = prgid[0].Id;
    ATM4.TeamMemberRole = 'Federal Field Specialist Supervisor';
    ATM4.UserId = u2.id;
    insert ATM4;

    objUACNOCCase = new UAC_testCaseBuilder()
                        .setStatus('Submitted')
                        .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeNOC)
                        .setUAC(objUAC.id)
                        .build();
    Test.startTest();
    objUACNOCCase.UAC_notificationOfConcernCategory__c = Label.UAC_notifOfConcDeathOfUAC;
    objUACNOCCase.UAC_programFacility__c = prgid[0].Id;
    objUACNOCCase.UAC_nocCategoryOfAbuseOrNeglect__c = 'Sexual Abuse';
    objUACNOCCase.UAC_nocTypeOfSexualAbuse__c = 'Sexual Abuse';
    objUACNOCCase.UAC_notifyPSATeam__c = 'Yes';
    objUACNOCCase.UAC_nocAllegedPerpertrator__c = 'Non-UC Child';
    objUACNOCCase.UAC_nocHowWasThisUACInvolved__c = 'Victim';
    objUACNOCCase.ContactId = objUAC.Id;
    insert objUACNOCCase;
    System.assertEquals('Sexual Abuse', objUACNOCCase.UAC_nocTypeOfSexualAbuse__c);
    Test.stopTest();
  }

  @isTest static void testPRStests() {
    String strReferralAssessmentRecordTypePRSEvent = Label.UAC_prsEventRecordType;
    Id idPRSEventRecType =
        Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
            .get(strReferralAssessmentRecordTypePRSEvent)
            .getRecordTypeId();
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, new Set<String>{'Id'});
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;

    objUACReleaseRequestCase = new UAC_testCaseBuilder()
                                   .setStatus('CM to Provide Further Information')
                                   .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                   .setUAC(objUACContact.id)
                                   .build();

    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    insert objUACReleaseRequestCase;
    Test.startTest();
    objUACReleaseRequestCase.Status = Label.UAC_caseStatusHSRequested;
    objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'No';
    objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_conductHomeStudyTVPRA;
    objUACReleaseRequestCase.UAC_orrComment__c = 'Test2';
    update objUACReleaseRequestCase;

    Id idhsRef = [SELECT Id FROM Case WHERE parentID =:objUACReleaseRequestCase.Id].Id;

    System.debug('hs ref id is ' + idhsRef);
    Case hsRef = [SELECT Id, Status, Type, UAC_hsPrsQueue__c FROM Case WHERE parentID
      =:objUACReleaseRequestCase.Id limit 1];
    System.debug('hs ref case type is ' + hsRef.Type);
    System.debug('hs ref case status is ' + hsRef.Status);
    hsRef.Status = 'Active';
    hsRef.Type = 'PRS-TVPRA';
    update hsRef;

    UAC_referralAssessment__c objReferralAssessment = new UAC_referralAssessment__c();
    objReferralAssessment.recordtypeid = idPRSEventRecType;
    objReferralAssessment.UAC_entry__c = idhsRef;
    insert objReferralAssessment;
    objReferralAssessment.UAC_status__c = Label.UAC_referralAssessmentStatusDraft;
    objReferralAssessment.UAC_hsprsWorkerPrintedName__c = 'ABC';
    objReferralAssessment.UAC_hsprsSupervisorPrintedName__c = 'ABC';
    objReferralAssessment.UAC_hsprsSupervisor__c = userinfo.getUserId();
    update objReferralAssessment;
    System.AssertNotEquals(
        [Select UAC_hsprsWorkerCompletedDate__c from UAC_referralAssessment__c where Id
            =:objReferralAssessment.Id LIMIT 1],
        Null);
    // System.assertEquals('Test1',objReferralAssessment.UAC_sponsorsReasonsForWantingToSponsor__c);
    objReferralAssessment.UAC_status__c =
        Label.UAC_referralAssessmentStatusDraftApprovedBySupervisor;
    objReferralAssessment.UAC_hsprsSupervisorPrintedName__c = 'CBA';
    objReferralAssessment.UAC_assignedProviderName__c = userinfo.getUserId();
    update objReferralAssessment;
    try {
      delete objReferralAssessment;
    } catch (Exception ex) {
      System.AssertNotEquals('', ex.getMessage());
    }
    UAC_referralAssessment__c objReferralAssessment2 = new UAC_referralAssessment__c();
    objReferralAssessment2.recordtypeid = idPRSEventRecType;
    objReferralAssessment2.UAC_entry__c = idhsRef;
    objReferralAssessment2.UAC_status__c = 'Draft';
    insert objReferralAssessment2;
    delete objReferralAssessment2;
    Test.stopTest();
    hsRef.Status = 'Closed';
    hsRef.UAC_hsPrsReasonForClosure__c = 'UC Arrested';
    update hsRef;
  }
  /*
   * @description Method to test bed update on transfer referrals
   * @author Issam Awwad (Deloitte) | 08/12/2020
   * @return void
   **/
  @isTest static void testTransferReferrals() {

    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    Account Program = queryProgram(null);
    Program.UAC_bedCountAvailableFemale__c = 0;
    Program.UAC_bedCountUnavailableFemale__c = 0;
    update Program;
    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(objUACContact.id)
                             .buildAndSave();

    Case oldTransferCase = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                               .setUAC(objUACContact.id)
                               .build();
    oldTransferCase.UAC_standardProgramType__c = 'Flight Risk';
    oldTransferCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    oldTransferCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    oldTransferCase.UAC_programFacility__c = Program.Id;
    oldTransferCase.ParentId = objUACReferralCase.Id;

    insert oldTransferCase;

    List<Asset> listAssets =
        UAC_TestUtility.createAssets(Program.Id, 'Female', 'Available', 7, false);
    listAssets[0].Status = 'On-Hold';
    listAssets[0].ContactId = objUACContact.Id;
    insert listAssets;
    Test.startTest();
    oldTransferCase.status = 'FFS Review';
    oldTransferCase.UAC_caseCoordinatorRecommendation__c = 'Transfer Concurred';
    oldTransferCase.UAC_caseManagerRecommendation__c = 'Transfer Recommended';
    oldTransferCase.UAC_orrDecision__c = 'Transfer Approved';
    update oldTransferCase;
    Program = queryProgram(null);
    Test.stopTest();
    System.assertEquals(6, Program.UAC_bedCountAvailableFemale__c);
    System.assertEquals(1, Program.UAC_bedCountUnavailableFemale__c);
  }

  /*
   * @description Method to test Contact Update on
   * Status Change (Discharge-(Completed))
   * @author Sarang Padhye (Deloitte) | 08/20/2020
   * @return void
   **/
  @isTest static void testUpdateContactProgramDNF() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_program__c'};

    Account objProgramCase = new UAC_testAccountBuilder()
                                 .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                 .setType(STR_PROGRAM_TYPE)
                                 .build();
    insert objProgramCase;
    UAC_TestUtility.createAssets(objProgramCase.Id, 'Female', 'Occupied', 1, true);

    Account objProgramContact = new UAC_testAccountBuilder()
                                    .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                    .setType(STR_PROGRAM_TYPE)
                                    .build();
    insert objProgramContact;
    UAC_TestUtility.createAssets(objProgramContact.Id, 'Female', 'Occupied', 1, true);

    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUAC.UAC_program__c = objProgramContact.id;
    update objUAC;

    Case objCase = new UAC_testCaseBuilder()
                       .setStatus('New Pending')
                       .setUAC(objUAC.Id)
                       .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeDischargeNotification)
                       .build();

    objCase.UAC_programFacility__c = objProgramCase.Id;

    insert objCase;

    Test.startTest();
    objCase.status = 'Discharge-(Completed)';
    update objCase;

    Contact con = [select id, UAC_program__c from contact where id =:objUAC.id];
    system.assertEquals(null, con.UAC_program__c);
    Test.stopTest();
  }

  /*
   * @description Method to test contact Program Update
   * on Status Change (Placement Designated)
   * @author Sarang Padhye (Deloitte) | 08/20/2020
   * @return void
   **/
  @isTest static void testUpdateContactProgramUAC() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_program__c'};

    Account objProgramCase = new UAC_testAccountBuilder()
                                 .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                 .setType(STR_PROGRAM_TYPE)
                                 .build();
    objProgramCase.UAC_bedCountAvailableMale__c = 7;
    objProgramCase.UAC_bedCountAvailableFemale__c = 0;
    insert objProgramCase;

    UAC_TestUtility.createAssets(objProgramCase.Id, 'Female', 'Available', 7, true);

    Account objProgramContact = new UAC_testAccountBuilder()
                                    .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                    .setType(STR_PROGRAM_TYPE)
                                    .build();
    objProgramContact.UAC_bedCountAvailableMale__c = 7;
    objProgramContact.UAC_bedCountAvailableFemale__c = 0;
    insert objProgramContact;

    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUAC.UAC_program__c = objProgramContact.id;
    update objUAC;
    UAC_TestUtility.createAssets(objProgramContact.Id, 'Male', 'Available', 7, true);
    Case objCase = new UAC_testCaseBuilder()
                       .setStatus('New Pending')
                       .setUAC(objUAC.Id)
                       .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                       .build();

    objCase.UAC_programFacility__c = objProgramCase.Id;
    insert objCase;

    Test.startTest();
    objCase.status = 'Placement Designated';
    update objCase;
    Contact con = [select id, UAC_program__c from contact where id =:objUAC.id];
    system.assertEquals(objProgramCase.Id, con.UAC_program__c);
    Test.stopTest();
  }
  /*
   * @description test Method to update contact Program
   * on ORR Decision
   * @author Sarang Padhye (Deloitte) | 08/20/2020
   * @return void
   **/
  @isTest static void testUpdateContactProgramTransferReq() {
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_program__c'};

    Account objProgramCase = new UAC_testAccountBuilder()
                                 .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                 .setType(STR_PROGRAM_TYPE)
                                 .build();
    objProgramCase.UAC_bedCountAvailableMale__c = 7;
    objProgramCase.UAC_bedCountAvailableFemale__c = 0;
    insert objProgramCase;

    UAC_TestUtility.createAssets(objProgramCase.Id, 'Male', 'Available', 7, true);

    Account objProgramContact = new UAC_testAccountBuilder()
                                    .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                                    .setType(STR_PROGRAM_TYPE)
                                    .build();
    objProgramContact.UAC_bedCountAvailableMale__c = 7;
    objProgramContact.UAC_bedCountAvailableFemale__c = 0;
    insert objProgramContact;

    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    objUAC.UAC_program__c = objProgramContact.id;
    objUAC.Birthdate = Date.newInstance(2001, 12, 9);
    update objUAC;
    // Insert Health Eval records
    UAC_healthEvaluation__c healthEvaluation = new UAC_healthEvaluation__c();
    healthEvaluation.UAC_associatedUAC__c = objUAC.id;
    insert healthEvaluation;

    Case objCase2 = new UAC_testCaseBuilder()
                        .setStatus(strPendingAdmissionStatus)
                        .setUAC(objUAC.Id)
                        .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                        .build();
    objCase2.UAC_programFacility__c = objProgramCase.Id;
    insert objCase2;

    UAC_TestUtility.createAssets(objProgramContact.Id, 'Male', 'Available', 7, true);
    Case objCase = new UAC_testCaseBuilder()
                       .setStatus('New Pending')
                       .setUAC(objUAC.Id)
                       .setRecordTypeDeveloperName(Label.UAC_caseTransferRequest)
                       .build();

    objCase.UAC_programFacility__c = objProgramCase.Id;
    objCase.UAC_orrDecision__c = 'Transfer Not Approved';
    objCase.UAC_standardProgramType__c = 'Flight Risk';
    objCase.UAC_leadCaseManager__c = UserInfo.getUserId();
    objCase.UAC_caseCoordinator__c = UserInfo.getUserId();
    objCase.ParentId = objCase2.id;
    objCase.contactid = objUAC.id;
    insert objCase;

    objCase.UAC_orrDecision__c = 'Transfer Approved';
    update objCase;

    Case admittedCase =
        [select id, UAC_programFacility__c, status from case where parentid =:objCase.id limit 1];
    System.assertEquals('Pending Admission', admittedCase.status);
    System.assertEquals(objProgramCase.Id, admittedCase.UAC_programFacility__c);
    Test.startTest();
    admittedCase.status = strAdmittedStatus;
    try {
      update admittedCase;
    } catch (exception ex) {
      system.assert(ex.getMessage().contains('Admitted cannot be selected'));
    }
    Test.stopTest();
    Contact objUACTest =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    // System.assertEquals(objProgramCase.Id, objUACTest.UAC_program__c);
  }
  /*
   * @description Method to test positive cases of creating case team members
   * @author James Qian (Deloitte) | 8/28/2020
   * @return
   **/
  @isTest static void insertManifestShouldCreateCaseTeamMember() {
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Account accountProgram = queryProgram(null);
    insert new AccountTeamMember(UserId = UserInfo.getUserId(),
        AccountId = accountProgram.Id,
        TeamMemberRole = Label.UAC_accountTeamRoleLCM);
    Test.startTest();
    Case objManifest = new UAC_testCaseBuilder()
                           .setStatus('Initiated')
                           .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeManifest)
                           .build();
    objManifest.UAC_currentProgram__c = accountProgram.Id;
    insert objManifest;
    Test.stopTest();
    CaseTeamMember queriedCaseTeamMember = [
      SELECT Id,
      TeamRole.Name FROM CaseTeamMember WHERE ParentId =:objManifest.Id AND MemberId
                                                       =:UserInfo.getUserId()
    ];
    System.assertEquals(queriedCaseTeamMember.TeamRole.Name, Label.UAC_caseTeamRoleNameLCM);
  }

  /*
   * @description ORRUAC-1848- Method to test removing influx transfer from manifest
   * @author James Qian (Deloitte) | 9/2/2020
   * @return
   **/
  @isTest static void influxTransferShouldNotBeRemovedFromFinalManifest() {
    Test.startTest();
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    insert objProgram;
    Case objManifest = new UAC_testCaseBuilder()
                           .setStatus(Label.UAC_caseStatusFinalManifest)
                           .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeManifest)
                           .build();
    objManifest.UAC_currentProgram__c = objProgram.Id;
    insert objManifest;
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Case objUACInfluxTransferCase = new UAC_testCaseBuilder()
                                        .setStatus(Label.UAC_ReleaseRequestStatusFFSReview)
                                        .setRecordTypeDeveloperName(Label.UAC_TransferRequestInflux)
                                        .setUAC(UAC.id)
                                        .build();
    objUACInfluxTransferCase.UAC_programFacility__c = objProgram.Id;
    objUACInfluxTransferCase.UAC_manifest__c = objManifest.Id;
    insert objUACInfluxTransferCase;
    objUACInfluxTransferCase.UAC_manifestStatus__c = Label.UAC_caseManifestStatusRemoved;
    String strErrorMessage;
    try {
      update objUACInfluxTransferCase;
    } catch (Exception e) {
      strErrorMessage = e.getMessage();
    }
    Test.stopTest();
    System.assertNotEquals(null, strErrorMessage);
  }

  /*
   * @description ORRUAC-2698 AC5
   * @author Piyush(Deloitte) | 10/4/2020
   * @return
   **/
  @isTest static void testpopulateSWB() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    User Manager;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      Manager = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    }
    String strNewANumber = '999999999';
    Contact UAC = new UAC_testContactBuilder()
                      .setANumber(strNewANumber)
                      .setLastName(strNewANumber)
                      .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                      .buildAndSave();
    Case objSWBRecType = new UAC_testCaseBuilder()
                             .setStatus('Draft')
                             .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeSWB)
                             .setUAC(UAC.id)
                             .buildAndSave();
    test.startTest();
    objSWBRecType.UAC_staffSignature__c = Manager.Id;
    objSWBRecType.Status = 'Submitted';
    update objSWBRecType;
    Case updatedSWB = [Select Id, UAC_dateTime__c from Case where id =:objSWBRecType.Id];
    System.assert(updatedSWB.UAC_dateTime__c != null);
    test.stopTest();
  }
  /*
   * @description ORRUAC-2416
   * @author Sarang Padhye (Deloitte) | 10/1/2020
   * @return
   **/
  @isTest static void testLtfcLcmAssoociation() {

    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    objProgram.UAC_bedCountAvailableMale__c = 2;
    insert objProgram;
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    Case objUACAdmission = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                               .setUAC(UAC.id)
                               .build();
    objUACAdmission.UAC_programFacility__c = objProgram.id;
    insert objUACAdmission;

    Case objUACLtfcTravelCase = new UAC_testCaseBuilder()
                                    .setRecordTypeDeveloperName(Label.UAC_LtfcTravelRequest)
                                    .setUAC(UAC.id)
                                    .build();
    objUACLtfcTravelCase.UAC_requesterName__c = UserInfo.getUserId();
    objUACLtfcTravelCase.UAC_travelBeginDate__c = Date.Today();
    objUACLtfcTravelCase.UAC_travelRequestDate__c = Date.Today();
    objUACLtfcTravelCase.parentid = objUACAdmission.id;

    AccountTeamMember lcmAtm = new AccountTeamMember();
    lcmAtm.userid = UserInfo.getUserId();
    lcmAtm.TeamMemberRole = 'Lead Case Manager';
    lcmAtm.AccountId = objProgram.id;
    insert lcmAtm;
    Test.startTest();
    insert objUACLtfcTravelCase;
    Test.stopTest();
    Case objLtfcCase = [select id, UAC_leadCaseManager__c from case where recordType.developername
      =:Label.UAC_LtfcTravelRequest];
    system.assertEquals(UserInfo.getUserId(), objLtfcCase.UAC_leadCaseManager__c);
  }
  /*
   * @description ORRUAC-2416
   * @author Sarang Padhye (Deloitte) | 10/1/2020
   * @return
   **/
  @isTest static void testCopyCaseTeamMembersToLtfc() {
    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    }
    id idFFSRole = [select id from CaseTeamRole where name =:Label.UAC_CaseTeamRoleNameFFS][0].id;
    objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    objProgram.UAC_bedCountAvailableMale__c = 2;
    insert objProgram;
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

    Case objUACAdmission = new UAC_testCaseBuilder()
                               .setStatus('CM Initiated')
                               .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                               .setUAC(UAC.id)
                               .build();
    objUACAdmission.UAC_programFacility__c = objProgram.id;
    insert objUACAdmission;

    Case objUACLtfcTravelCase = new UAC_testCaseBuilder()
                                    .setRecordTypeDeveloperName(Label.UAC_LtfcTravelRequest)
                                    .setUAC(UAC.id)
                                    .build();
    objUACLtfcTravelCase.UAC_requesterName__c = UserInfo.getUserId();
    objUACLtfcTravelCase.UAC_travelBeginDate__c = Date.Today();
    objUACLtfcTravelCase.UAC_travelRequestDate__c = Date.Today();
    objUACLtfcTravelCase.parentid = objUACAdmission.id;

    AccountTeamMember lcmAtm = new AccountTeamMember();
    lcmAtm.userid = UserInfo.getUserId();
    lcmAtm.TeamMemberRole = 'Lead Case Manager';
    lcmAtm.AccountId = objProgram.id;
    insert lcmAtm;

    CaseTeamMember cTm = new CaseTeamMember();
    cTm.memberId = FFS.id;
    cTM.TeamRoleId = idFFSRole;
    cTM.ParentId = objUACAdmission.id;
    insert cTm;
    Test.startTest();
    insert objUACLtfcTravelCase;
    Test.stopTest();
    Case objLtfcCase = [select id, UAC_leadCaseManager__c from case where recordType.developername
      =:Label.UAC_LtfcTravelRequest];
    CaseTeamMember objCaseTeamMem =
        [select teamRole.name, parentid from caseTeammember where parentid =:objLtfcCase.id];
    system.assertEquals(objCaseTeamMem.TeamRole.Name, 'Read Only');
  }
  /*
   * @description Method to test Update of ORR Decision on Sponosr Applicaiton
   * @author Rahul Roy (Deloitte) | 10/11/2020
   * @return void
   **/
  @isTest static void testUpdateORRDecisionOnSponsorApplication() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    objSponsorApplicationCase =
        new UAC_testCaseBuilder()
            .setStatus('Open')
            .setRecordTypeDeveloperName(Label.UAC_CaseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.id)
            .build();
    objSponsorApplicationCase.ContactId = objUAC.Id;
    objSponsorApplicationCase.UAC_sponsor__c = objAdultContact.Id;
    objSponsorApplicationCase.UAC_relationshipToUAC__c = objAdultContactRelationship.Id;
    insert objSponsorApplicationCase;

    objUACReleaseRequestCase = new UAC_testCaseBuilder()
                                   .setStatus('CM Initiated')
                                   .setRecordTypeDeveloperName(strcaseRecordTypeReleaseRequest)
                                   .setUAC(objUAC.id)
                                   .build();
    objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
    objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
    objUACReleaseRequestCase.ParentId = objSponsorApplicationCase.Id;
    insert objUACReleaseRequestCase;

    Test.startTest();
    objUACReleaseRequestCase.UAC_orrDecision__c = 'Approve Straight Release';
    update objUACReleaseRequestCase;
    objSponsorApplicationCase =
        [select id, UAC_legacyCaseORRDecision__c from Case where id =:objSponsorApplicationCase.Id];
    System.AssertEquals(objUACReleaseRequestCase.UAC_orrDecision__c,
        objSponsorApplicationCase.UAC_legacyCaseORRDecision__c);
    Test.stopTest();
  }

  /*
   * @description Method to test Field Update On Adult Contact
   * @author Rahul Roy (Deloitte) | 11/12/2020
   * @return void
   **/
  @isTest static void testPopulateFieldOnAdultContact() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    UAC_adultContactRelationship__c objAdultContactRelationship = [
      select id,
      UAC_adultContact__c from UAC_adultContactRelationship__c where UAC_adultContact__c
      =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c
      =:objUAC.Id
    ];

    objSponsorApplicationCase =
        new UAC_testCaseBuilder()
            .setStatus('Open')
            .setRecordTypeDeveloperName(Label.UAC_CaseRecordTypeApiNameSponsorApplication)
            .setUAC(objUAC.id)
            .build();
    objSponsorApplicationCase.ContactId = objUAC.Id;
    objSponsorApplicationCase.UAC_sponsor__c = objAdultContact.Id;
    objSponsorApplicationCase.UAC_relationshipToUAC__c = objAdultContactRelationship.Id;
    insert objSponsorApplicationCase;

    User FFS;
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    System.runAs(altAdminUser) {
      FFS = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
      update new case (id = objSponsorApplicationCase.ID, ownerId = FFS.Id);
      Id idCaseTeamRole =
          [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
      insert createCaseTeamMember(objSponsorApplicationCase.Id, FFS.Id, idCaseTeamRole);
    }

    System.runAs(FFS) {
      Test.startTest();
      objSponsorApplicationCase.Status = 'FFS Decision - Do not Proceed';
      objSponsorApplicationCase.UAC_statusDecisionNotes__c = 'Test';
      update objSponsorApplicationCase;
      objSponsorApplicationCase =
          [Select id, Status, UAC_sponsor__c from Case where id =:objSponsorApplicationCase.Id];
      System.AssertEquals('FFS Decision - Do not Proceed', objSponsorApplicationCase.Status);
      Test.stopTest();
    }
  }

  /*
   * @description Method to test Auto populate Legal fields on UAC Contact
   * @author Rahul Roy (Deloitte) | 11/13/2020
   * @return void
   **/
  @isTest static void testAutoPopulateLegalFieldsOnUACContact() {
    Set<String> setFieldsToQuery = new Set<String>{'Id'};
    String strNewANumber = '999999999';
    Contact objUAC =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(objUAC.id)
                             .buildAndSave();
    objUACReferralCase.UAC_programFacility__c = queryProgram(null).id;

    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, true);

    Test.startTest();
    objUACReferralCase.UAC_separatedFromParentsLegalGuardian__c = 'Yes';
    objUACReferralCase.UAC_reasonForSeparation__c = 'Parent criminal history';
    objUACReferralCase.Status = 'Placement Designated';
    update objUACReferralCase;
    objUAC = [select id, UAC_separatedFromParentLegalGuardian__c from Contact where id =:objUAC.Id];
    System.AssertEquals(true, objUAC.UAC_separatedFromParentLegalGuardian__c);
    Test.stopTest();
  }

  /*
   * @description Method to test User Email Validation
   * @author Nithin Malla (Deloitte) | 04/11/2021
   * @return void
   **/
  @isTest static void testUserEmail() {
    List<Id> lstUserId = new List<Id>{userinfo.getUserId()};
    Test.startTest();
    Map<Id, String> getUserEmail = UAC_caseTriggerHelper.getUserEmail(lstUserId);
    system.assert(getUserEmail != null);
    AccountTeamMember accT = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember];
    Map<String, list<String>> getUserEmailWithProgram =
        UAC_caseTriggerHelper.getUserDetailsonProgram(
            new set<Id>{accT.AccountId}, new List<string>{accT.TeamMemberRole});
    system.assert(getUserEmailWithProgram != null);
    Test.stopTest();
  }
  /*
   * @description Method to retrieve program ID
   * @author James Qian (Deloitte) | 04/21/2021
   * @return Account
   **/
  private
  static Account queryProgram(Id idProgram) {
    if (idProgram == null) {
      return [SELECT Id,
        UAC_bedCountOnHoldFemale__c,
        UAC_bedCountAvailableFemale__c,
        UAC_bedCountUnavailableFemale__c FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    } else {
      return [SELECT Id,
        UAC_bedCountOnHoldFemale__c,
        UAC_bedCountAvailableFemale__c,
        UAC_bedCountUnavailableFemale__c FROM Account WHERE Id
        =:idProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    }
  }
  /*
   * @description Method to Assign Escalated to tier2 to true when owner is helpdesk tier2 queue
   * @author Anudeep (Deloitte) | 08/18/2021
   * @return void
   **/
  @isTest static void assignEscalateToTier2() {
    Group helpdeskTier2Queue = [Select Id from Group where type = 'Queue' and developername
        =:Tier_2_Helpdesk_Queue limit 1];
    Case caseRec = new UAC_testCaseBuilder()
                       .setStatus(Label.UAC_caseStatusFinalManifest)
                       .setRecordTypeDeveloperName(Label.UC_helpdeskTicket)
                       .build();
    insert caseRec;
    Test.startTest();
    caseRec.ownerId = helpdeskTier2Queue.Id;
    update caseRec;
    Test.stopTest();
    Case caseUpdatedRec =
        [select Id, UC_escalatedToTier2__c from case where Id =:caseRec.Id limit 1];
    System.assertEquals(caseUpdatedRec.UC_escalatedToTier2__c, true);
  }
  /**
   * @description ORRUAC-362: Method to test update of Concurrent Sponsor Application flag
   * @author Issam Awwad (Deloitte) | 9/16/2021
   * @return void
   **/
  @isTest static void testConcurrentSponsorApplication() {
      /*
    Set<String> setFieldsToQuery = new Set<String>{'Id', 'UAC_activeSponsorApplication__c'};
    objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_UAC_CONTACT_A_NUMBER, setFieldsToQuery);
    Contact objSecondUACContact = new UAC_testContactBuilder()
                                      .setANumber('124356789')
                                      .setEmail('124356789' + '@example.invalid')
                                      .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                                      .build();
    objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_ADULT_CONTACT_A_NUMBER, setFieldsToQuery);
    // Create new Active Sponsor Case for adult contact
    Case objActiveSponsorCase =
        new UAC_testCaseBuilder().setUAC(objUACContact.Id).setSponsor(objAdultContact.Id).buildAndSave();
    Test.startTest();

    Case objSecondActiveSponsorCase = new UAC_testCaseBuilder()
                                          .setUAC(objSecondUACContact.Id)
                                          .setSponsor(objAdultContact.Id)
                                          .buildAndSave();


    objAdultContact =
        [SELECT Id, UC_concurrentSponsorApplications__c FROM Contact WHERE Id =:objAdultContact.Id];
   // System.assertEquals(True, objAdultContact.UC_concurrentSponsorApplications__c);

    Test.stopTest();
*/
  }

  /*
   * @description Tests referral reprocessed to processed pending from placement designated
   * @author Issam Awwad (Deloitte) | 9/21/2021
   * @return
   **/
  @isTest static void referralReProcessed() {

    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    UAC.UAC_relatedToOtherUAC__c = 'Yes';
    update UAC;

    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER + 'T')
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                                .buildAndSave();

    objUACContact.UAC_relatedToOtherUAC__c = 'Yes';
    update objUACContact;

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();

    objUACReferralCase.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
    update objUACReferralCase;

    objUACReferralCase.UAC_programFacility__c = queryProgram(null).id;

    Id recordTypeId =
        UAC_TestUtility.getRecordTypeId(UAC_RELATIONSHIP_RECORD_TYPE, UAC_RELATIONSHIP_API_NAME);
    UAC_apprehendedRelationship__c newRelationship =
        UAC_TestUtility.createApprehendedRelationshipRecord(
            UAC.Id, objUACContact.Id, recordTypeId, 'Brother', true);
    newRelationship.UAC_relatedUAC__c = UAC.id;
    update newRelationship;

    Case objUACReferralCaseSecond = new UAC_testCaseBuilder()
                                        .setStatus('Processed Pending')
                                        .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                                        .setUAC(objUACContact.id)
                                        .buildAndSave();
    objUACReferralCaseSecond.UAC_relatedUACsPlacedTogetherHelper__c = 'Yes';
    update objUACReferralCaseSecond;

    UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 1, true);
    test.startTest();
    objUACReferralCase.Status = 'Placement Designated';
    update objUACReferralCase;
    Test.stopTest();

    Contact queriedContact1 =
        [SELECT UAC_status__c, UAC_program__c, UAC_programType__c FROM Contact WHERE Id
          =:objUACContact.Id];
    queriedContact1.UAC_status__c = 'Placement Designated';
    update queriedContact1;
    objUACReferralCase.Status = 'Processed Pending';
    update objUACReferralCase;

    queriedContact1 =
        [SELECT UAC_status__c, UAC_program__c, UAC_programType__c FROM Contact WHERE Id =:UAC.Id];
    objUACReferralCase = [SELECT Id,
      Status,
      UAC_programFacility__c,
      UAC_programType__c,
      UAC_placementDesignationDateTime__c FROM Case WHERE Id =:objUACReferralCase.Id];
    Case objAdmissionCase = [
      SELECT Id,
      Status,
      UAC_programFacility__c,
      UAC_programType__c,
      UAC_admittedDateTime__c FROM Case WHERE ContactId
      =:queriedContact1.Id AND RecordType.DeveloperName
      =:Label.UAC_caseRecordTypeAdmission
    ];

    System.assertEquals('Processed Pending', queriedContact1.UAC_status__c);
    System.assertEquals(null, objUACReferralCase.UAC_programFacility__c);
    System.assertEquals(null, objAdmissionCase.UAC_admittedDateTime__c);
  }
  /*
   * @description Method to test updating admission on placement designated
   * @author Issam Awwad (Deloitte) | 9/30/2021
   * @return void
   **/
  @isTest static void testUpdateAdmissions() {
Test.startTest();
    Account objNewProgram = [Select id from Account LIMIT 1];
    Account objProgram = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .buildAndSave();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    objProgram.UAC_bedCountAvailableFemale__c = 2;
    update objProgram;
    Account objProgramSecond = new UAC_testAccountBuilder()
                     .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                     .setType(STR_PROGRAM_TYPE)
                     .buildAndSave();
    objProgramSecond.UAC_withinORRNetwork__c = 'Yes';
    objProgramSecond.Type = 'Shelter';
    objProgramSecond.UAC_bedCountAvailableFemale__c = 2;
    update objProgramSecond;
    
    Contact UAC = [select id, UAC_status__c, UAC_A__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    update UAC;
      
   UAC_TestUtility.createAssets(
        objProgramSecond.Id, 'Female', 'Available', 1, true);
      
    Case objReferralOne = new UAC_testCaseBuilder()
                                     .setUAC(UAC.Id)
        							 .setStatus('Processed Pending')
                                     .setRecordTypeDeveloperName(label.UAC_referralRecordTypeName)
                                     .buildAndSave();
   objReferralOne = [SELECT Id,Status,UAC_referralCancellationReason__c,UAC_programFacility__c,ParentId,UAC_admission__c FROM Case WHERE UAC_aNum__c = :UAC.UAC_A__c LIMIT 1];
   objReferralOne.UAC_programFacility__c = objProgramSecond.Id; 
   objReferralOne.Status = 'Placement Designated';
   update objReferralOne;

    Case objUACAdmission = new UAC_testCaseBuilder()
                               .setStatus('Completed')
                               .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                               .setUAC(UAC.id)
                               .build();
    objUACAdmission.ParentId = objReferralOne.Id;
    insert objUACAdmission;
      
   /* Case objUACReferralCase = [SELECT Id,Status,UAC_referralCancellationReason__c,UAC_programFacility__c,ParentId,UAC_admission__c FROM Case WHERE UAC_aNum__c = :UAC.UAC_A__c LIMIT 1];
    objUACReferralCase.Status = 'Referral Cancelled';
    objUACReferralCase.UAC_referralCancellationReason__c = 'Referral Cancelled';
    objUACReferralCase.ParentId = null;
    objUACReferralCase.UAC_admission__c = null;
    update objUACReferralCase;*/
      
    

      
    objUACAdmission = [SELECT Id, UAC_programFacility__c,ParentId,UAC_referral__c FROM Case WHERE RecordType.DeveloperName = :Label.UAC_caseRecordTypeAdmission LIMIT 1];
    UAC_TestUtility.createAssets(
        objProgram.Id, 'Female', 'Available', 1, true);
   
	objReferralOne.Status = 'Processed Pending';
    update objReferralOne;
    System.debug('referrals parent: '+ [Select ParentId FROM Case WHERE Id = :objReferralOne.Id].ParentId);
    System.debug('Admissions parent: '+ [Select ParentId FROM Case WHERE Id = :objUACAdmission.Id].ParentId);
    System.debug('referral: '+ objReferralOne.Id);
    System.debug('Admission: '+ objUACAdmission.Id);
    objReferralOne.UAC_programFacility__c = objProgram.id;
    objReferralOne.Status = 'Placement Designated';
    update objReferralOne;
    

    Test.stopTest();
    objUACAdmission = [SELECT Id, UAC_programFacility__c FROM Case WHERE RecordType.DeveloperName = :Label.UAC_caseRecordTypeAdmission LIMIT 1];

    System.assertEquals(objProgram.Id, objUACAdmission.UAC_programFacility__c);

  }
  /*
   * @description Method to test placement notes error
   * @author Issam Awwad (Deloitte) | 9/30/2021
   * @return void
   **/
  @isTest static void testPlacementNotes() {
      
    User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
    User Intakesuser;
    System.runAs(altAdminUser) {
       Intakesuser = UAC_TestUtility.createUser('Case Manager', Label.UAC_userRoleProgramStaff);
    Intakesuser.ProfileID = [select id from profile where name = 'Intakes Team'].id;
        update Intakesuser;
    }
      
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    objProgram.Type = 'Shelter';
    objProgram.UAC_bedCountAvailableFemale__c = 2;
    insert objProgram;

    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];

      UAC_TestUtility.createAssets(
        objProgram.Id, 'Female', 'Available', 1, true);

    objUACReferralCase = new UAC_testCaseBuilder()
                             .setStatus('Processed Pending')
                             .setRecordTypeDeveloperName(strcaseRecordTypeReferral)
                             .setUAC(UAC.id)
                             .buildAndSave();
    objUACReferralCase.Status = 'Placement Requested';                      
    objUACReferralCase.UAC_programFacility__c = objProgram.id;
    update objUACReferralCase;

    Id idCaseTeamRole =
        [SELECT Id FROM CaseTeamRole WHERE Name =:Label.UAC_caseTeamRoleNameCM][0].Id;
    CaseTeamMember cTm = new CaseTeamMember();
    cTm.memberId = Intakesuser.id;
    cTM.TeamRoleId = idCaseTeamRole;
    cTM.ParentId = objUACReferralCase.id;
    insert cTm;
    
    String strErrorMessage;
    Test.startTest();
    try {
      system.runAs(Intakesuser) {
        objUACReferralCase.Status = 'Placement Designated';
        update objUACReferralCase;
      }
    } catch (Exception e) {
      strErrorMessage = e.getMessage();
    }
    Test.stopTest();
    System.debug('strErrorMessage: '+strErrorMessage);
    System.assertNotEquals(null, strErrorMessage);
  }
}