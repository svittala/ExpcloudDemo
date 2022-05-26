/**
 * @File Name          : UAC_profilePictureController.cls
 * @Description        : ORRUAC-107 - Controller for uacProfilePicture LWC to show profile picture
 *on Contact object detail page.
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_profilePicture
 * @Test Class         : UAC_profilePictureTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/14/2020, 2:38:33 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    5/5/2020   Sachet Khanal (Deloitte)     Initial Version
 * 1.1    7/9/2020   Abhisek Pati (Deloitte)      Added method for story 207
 **/
public
without sharing class UAC_profilePictureController {

  private
  static final String STR_FILE_TYPE_NAME = 'Profile Picture';

  /**
   * @description Method to query File type settings for Profile Picture
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return List<UAC_fileTypeSetting__mdt>
   **/
  @AuraEnabled(
      cacheable = true) public static List<UAC_fileTypeSetting__mdt> getFileTypeSettings() {
    // Get list of File Type Settings for profile picture to be used for file validation
    return UAC_fileServices.getFileTypeSettings(new Set<String>{STR_FILE_TYPE_NAME});
  }

  /**
   * @description Method to get profile picture file for contact
   * @author Sachet Khanal (Deloitte) | 5/5/2020
   * @param idContact ID of contact record
   * @return FileWrapper Wrapper object containing details about profile picture
   **/
  @AuraEnabled public static UAC_fileWrapper getProfilePicture(Id idContact) {
    // Check for read permission on parent object to read attachment
    if (!idContact.getSObjectType().getDescribe().isAccessible()) {
      throw new System.NoAccessException();
    }
    // Begin- Code added for Story 207
    if (idContact.getSObjectType().getDescribe().getName() == 'UAC_admissionAssessment__c') {
      string contactId =
          [select UAC_uac__c from UAC_admissionAssessment__c where id =:idContact LIMIT 1]
              .UAC_uac__c;
      idContact = contactId;
    }
    // Code Ends here
    //Begin- Code added for Story 1217 -AC1  
    if (idContact.getSObjectType().getDescribe().getName() == 'Case') {
      string contactId = [select ContactId from Case where id = :idContact LIMIT 1].ContactId;
      idContact = contactId;
    }
    //Code Ends here
    // Get list of file wrapper containing the profile picture details from Contact
    List<UAC_fileWrapper> lstFileWrapper =
        UAC_fileServices.getFilesFromSObject(idContact, new Set<String>{STR_FILE_TYPE_NAME});
    if (lstFileWrapper.isEmpty()) {
      return null;
    }
    // Return 1st item from the list as we will only have one profile picture on Contact
    return lstFileWrapper[0];
  }

  /**
   * @description Method to save profile picture
   * @author Sachet Khanal (Deloitte) | 5/5/2020
   * @param strFile String JSON serialized FileWrapper object containing file details
   * @return FileWrapper Update file wrapper object
   **/
  @AuraEnabled public static UAC_fileWrapper saveProfilePicture(String strFile) {
    // Deserialize file wrapper JSON string to UAC_fileWrapper object
    UAC_fileWrapper objFile = (UAC_fileWrapper) JSON.deserialize(strFile, UAC_fileWrapper.class);
    // Check for edit permission on parent object to add attachments
    if (!objFile.idParent.getSObjectType().getDescribe().isUpdateable()) {
      throw new System.NoAccessException();
    }
    // Create new file and return updated file wrapper at index 0 as we are only inserting one file
    return UAC_fileServices.generateSObjectFiles(
        objFile.idParent, new List<UAC_fileWrapper>{objFile}, true)[0];
  }

  /**
   * @description Method to get the record type story 207
   * @author Abhisek Pati (Deloitte) | 7/9/2020
   * @param idContact ID of contact record
   * @return record type
   **/
  @AuraEnabled public static string getRecordTypeName(Id idContact) {     
    string recordType = [SELECT Id, RecordtypeId, RecordType.DeveloperName 
                  FROM Contact where Id = :idContact LIMIT 1].RecordType.DeveloperName;
      return recordType;
  }
}