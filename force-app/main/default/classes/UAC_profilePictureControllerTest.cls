/**
 * @File Name          : UAC_profilePictureControllerTest.cls
 * @Description        : Test class for UAC_profilePictureController
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_profilePicture
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/12/2020, 11:36:40 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    5/8/2020   Sachet Khanal (Deloitte)     Initial Version
 * 1.1    7/9/2020   Abhisek Pati (Deloitte)      Added Method to get record type
 * 1.3    7/22/2020  Abhisek Pati (Deloitte)      Added test coverage for profile 
 *                                                and case profile pictures
 **/
@isTest public without sharing class UAC_profilePictureControllerTest {

  private
  static final String STR_FILE_TYPE_NAME = 'Profile Picture';
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';

  /**
   * @description Test Setup method to generate test data
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return void
   **/
  @TestSetup static void setupData() {
    Contact objContact =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .buildAndSave();
  }

  /**
   * @description Method to test functionality to get file type settings list
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return void
   **/
  @isTest static void getFileTypeSettingsShouldReturnProfilePictureSettings() {
    Test.startTest();
    List<UAC_fileTypeSetting__mdt> lstFileTypeSettings =
        UAC_profilePictureController.getFileTypeSettings();
    Test.stopTest();
    System.assertEquals(STR_FILE_TYPE_NAME,
        lstFileTypeSettings[0].Label,
        'Test Method: getFileTypeSettingsShouldReturnProfilePictureSettings() failed.');
  }

  /**
   * @description Method to test functionality to get profile picture
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return void
   **/
  @isTest static void getProfilePictureShouldReturnNull() {
    Contact objContact = UAC_testContactBuilder.getContact(new Set<String>{'Id'});
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
    Case objUACReferralCase = new UAC_testCaseBuilder()
                                  .setStatus('Pending')
                                  .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission)
                                  .setUAC(objUACContact.id)
                                  .buildAndSave();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        objUACReferralCase.id, Label.UAC_assessmentRecordTypeAssessment, true);

    Test.startTest();
    UAC_fileWrapper objFileWrapperAssessment =
        UAC_profilePictureController.getProfilePicture(assessmentNew.Id);
    UAC_fileWrapper objFileWrapperCase =
        UAC_profilePictureController.getProfilePicture(objUACReferralCase.Id);
    UAC_fileWrapper objFileWrapper = UAC_profilePictureController.getProfilePicture(objContact.Id);
    Test.stopTest();
    System.assertEquals(
        null, objFileWrapper, 'Test Method: getProfilePictureShouldReturnNull() failed.');
    System.assertEquals(
        null, objFileWrapperAssessment, 'Test Method: getProfilePictureShouldReturnNull() failed.');
    System.assertEquals(
        null, objFileWrapperCase, 'Test Method: getProfilePictureShouldReturnNull() failed.');
  }

  /**
   * @description Method to test save profile picture functionality
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return void
   **/
  @isTest static void saveProfilePictureShouldCreateNewAttachment() {
    Contact objContact = UAC_testContactBuilder.getContact(new Set<String>{'Id'});
    UAC_fileWrapper objFileWrapper = new UAC_fileWrapper();
    objFileWrapper.idParent = objContact.Id;
    objFileWrapper.strFileName = 'Test.txt';
    objFileWrapper.strContentType = 'text/plain';
    objFileWrapper.strBase64Data = EncodingUtil.base64Encode(Blob.valueOf('Test'));
    objFileWrapper.strFileType = STR_FILE_TYPE_NAME;
    String strFileWrapper = JSON.serialize(objFileWrapper);
    Test.startTest();
    objFileWrapper = UAC_profilePictureController.saveProfilePicture(strFileWrapper);
    UAC_fileWrapper newFileWrapper = UAC_profilePictureController.getProfilePicture(objContact.Id);
    Test.stopTest();
    System.assertEquals(objFileWrapper.idFile,
        newFileWrapper.idFile,
        'Test Method: saveProfilePictureShouldCreateNewAttachment() failed.');
  }

  /**
   * @description Method to test functionality to get record Type
   * @author Abhisek Pati (Deloitte) | 7/9/2020
   * @return void
   **/
  @isTest static void getRecordTypeNameTest() {
    Contact objContact = UAC_testContactBuilder.getContact(new Set<String>{'Id'});
    Test.startTest();
    String recordTypeName = UAC_profilePictureController.getRecordTypeName(objContact.Id);
    Test.stopTest();
    System.assertEquals(recordTypeName,Label.UAC_contactRecordTypeApiNameAdultContact);
        
  }
}