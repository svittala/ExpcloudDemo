/**
 * @File Name          : UAC_assetServiceTest.cls
 * @Description        : Test class for UAC_assetService class
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_assetService
 * @Last Modified By   : James Qian (Deloitte)
 * @Last Modified On   : 3/17/2021
 * @Modification Log   :
 * Ver       Date            Author      		            Modification
 * 1.0     3/17/2021         James Qian (Deloitte)      Initial Version
 **/
@isTest public class UAC_assetServiceTest {
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';

  /*
   * @description Test setup method
   **/
  @testSetup static void setupTestData() {
    UAC_appSettingsService.setAppSettings();
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .build();
    objUACContact.Birthdate = System.today().addDays(-5500);
    insert objUACContact;
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .build();
    objProgram.UAC_withinORRNetwork__c = 'Yes';
    insert objProgram;
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 5, true);
  }

  /*
   * @description Tests positive scenarios of designating referral and asset updates
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  @isTest static void placingReferralShouldUpdateBeds() {
    Contact UAC = getUAC();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(UAC.id)
            .buildAndSave();
    objUACReferralCase.UAC_caseManager__c = Userinfo.getUserId();
    objUACReferralCase.UAC_programFacility__c = getProgramId();
    List<Asset> listAsset = UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 5, false);
    for (Asset assetCurrent : listAsset) {
      assetCurrent.UC_Type__c = 'Teen';
    }
    insert listAsset;
    objUACReferralCase.Status = 'Placement Designated';
    Test.startTest();
    update objUACReferralCase;
    Test.stopTest();
    List<Asset> listAssetForQuerying =
        [SELECT Id, ContactId, Status FROM Asset WHERE Status != 'Available'];
    System.assertEquals(1, listAssetForQuerying.size());
    System.assertEquals(UAC.Id, listAssetForQuerying[0].ContactId);
    System.assertEquals('Occupied', listAssetForQuerying[0].Status);
  }
  /*
   * @description Tests positive scenarios of requesting referral and asset updates
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  @isTest static void requestingReferralShouldUpdateBeds() {
    Contact UAC = getUAC();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Processed Pending')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(UAC.id)
            .buildAndSave();
    objUACReferralCase.UAC_caseManager__c = Userinfo.getUserId();
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_programFacility__c = getProgramId();
    List<Asset> listAsset = UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 5, false);
    for (Asset assetCurrent : listAsset) {
      assetCurrent.UC_Type__c = 'Teen';
    }
    insert listAsset;
    objUACReferralCase.Status = 'Placement Requested';
    Test.startTest();
    update objUACReferralCase;
    Test.stopTest();
    List<Asset> listAssetForQuerying =
        [SELECT Id, ContactId, Status FROM Asset WHERE Status != 'Available'];
    System.assertEquals(1, listAssetForQuerying.size());
    System.assertEquals(UAC.Id, listAssetForQuerying[0].ContactId);
    System.assertEquals('On-Hold', listAssetForQuerying[0].Status);
  }
  /*
   * @description Tests positive scenarios of accepting referral and asset updates
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  @isTest static void acceptingReferralShouldUpdateBeds() {
    Contact UAC = getUAC();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Placement Requested')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(UAC.id)
            .buildAndSave();
    objUACReferralCase.UAC_caseManager__c = Userinfo.getUserId();
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_programFacility__c = getProgramId();
    List<Asset> listAsset = UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'Available', 4, false);
    List<Asset> listAssetOnHold = UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'On-Hold', 1, false);
    for (Asset assetCurrent : listAsset) {
      assetCurrent.UC_Type__c = 'Teen';
    }
    for (Asset assetCurrent : listAssetOnHold) {
      assetCurrent.UC_Type__c = 'Teen';
      assetCurrent.ContactId = UAC.Id;
    }
    listAsset.addAll(listAssetOnHold);
    insert listAsset;
    objUACReferralCase.Status = 'Placement Designated';
    Test.startTest();
    update objUACReferralCase;
    Test.stopTest();
    List<Asset> listAssetForQuerying =
        [SELECT Id, ContactId, Status FROM Asset WHERE Status != 'Available'];
    System.assertEquals(1, listAssetForQuerying.size());
    System.assertEquals(UAC.Id, listAssetForQuerying[0].ContactId);
    System.assertEquals('Occupied', listAssetForQuerying[0].Status);
  }
  /*
   * @description Tests positive scenarios of declining referral and asset updates
   * @author James Qian (Deloitte) | 3/17/2021
   * @return
   **/
  @isTest static void decliningReferralShouldUpdateBeds() {
    Contact UAC = getUAC();
    Case objUACReferralCase =
        new UAC_testCaseBuilder()
            .setStatus('Placement Requested')
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameUACReferral)
            .setUAC(UAC.id)
            .buildAndSave();
    objUACReferralCase.UAC_caseManager__c = Userinfo.getUserId();
    objUACReferralCase.UAC_requiresPlacementRequest__c = true;
    objUACReferralCase.UAC_programFacility__c = getProgramId();
    List<Asset> listAssetOnHold = UAC_TestUtility.createAssets(
        objUACReferralCase.UAC_programFacility__c, 'Female', 'On-Hold', 1, false);
    for (Asset assetCurrent : listAssetOnHold) {
      assetCurrent.UC_Type__c = 'Teen';
      assetCurrent.ContactId = UAC.Id;
    }
    insert listAssetOnHold;
    objUACReferralCase.Status = 'Placement Not Accepted';
    objUACReferralCase.UAC_NotAcceptedReason__c = 'Licensing issues';
    Test.startTest();
    update objUACReferralCase;
    Test.stopTest();
    List<Asset> listAssetForQuerying =
        [SELECT Id, ContactId, Status FROM Asset WHERE Status = 'Available'];
    System.assertEquals(6, listAssetForQuerying.size());
    System.assertEquals(null, listAssetForQuerying[0].ContactId);
  }

  /*
   * @description Returns program ID
   * @author James Qian (Deloitte) | 3/17/2021
   * @return Id
   **/
  private
  static Id getProgramId() {
    return [
      // clang-format off
      SELECT
        Id
      FROM
        Account
      WHERE
        UAC_withinORRNetwork__c = 'Yes' AND
        RecordType.DeveloperName = :Label.UAC_accountRecordTypeAPINameProgram
      LIMIT 1
        // clang-format on
        ].Id;
  }

  /*
   * @description Returns UAC
   * @author James Qian (Deloitte) | 3/17/2021
   * @return Contact
   **/
  private
  static Contact getUAC() {
    return [
      // clang-format off
        SELECT
          Id,
          UAC_status__c
        FROM
          Contact
        WHERE
          RecordType.DeveloperName = :Label.UAC_contactRecordTypeApiNameUAC
        LIMIT 1
      // clang-format on
    ];
  }
}