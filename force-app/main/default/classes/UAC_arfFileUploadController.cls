/**
 * @File Name         : UAC_arfFileUploadController.cls
 * @Description       : Controller for uacComplianceTrainingForm LWC
 * @Group             : UAC_arfFileUploadController
 * @Test Class        : UAC_arfFileUploadControllerTest
 * @Author            : Abhisek Pati (Deloitte)
 * @Last Modified By  : 
 * @Last Modified On  : 
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   03-01-2021   Abhisek Pati (Deloitte)   Initial Version
 * 1.1   03-16-2021   Abhisek Pati (Deloitte)   ORRUAC-5469 Added code to Validate Email
 * 1.2   06-10-2021   Abhisek Pati (Deloitte)   ORRUAC-5858 removed old logic and added new
 **/
public
without sharing class UAC_arfFileUploadController {
  
    /**
   * @description Method to validate email
   * @author Abhisek Pati (Deloitte) | 03-16-2021
   * @param email
   * @return boolean
   **/
  @AuraEnabled public static Id validateEmail(String email) {
      id objResponse;
      try {
      	UAC_AccountRequestForm__c arf = [SELECT Id FROM UAC_AccountRequestForm__c WHERE User_Email__c =:email LIMIT 1];
        if(arf.Id != null || arf.id != ''){
            objResponse = arf.id;
          }
      }
      catch (Exception ex) {
      UAC_errorLog.logError(
          ex.getMessage(), null, 'Email Invalid', ex.getStackTraceString());
    }
    return objResponse;
  }

    /**
   * @description Method to save file 
   * @author Abhisek Pati (Deloitte) | 06-10-2021
   * @param parentid, file name, base64data, form type
   * @return content version
   **/
    @AuraEnabled
    public static ContentVersion saveFile(Id idParent, String strFileName, String base64Data, String formType) {
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Id idComplianceForm =
      	Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get('Uac_Compliance_Forms')
          .getRecordTypeId();
        // inserting file
        ContentVersion conVer = new ContentVersion();
        conVer.Title = strFileName;
        conVer.PathOnClient = '/' + strFileName;
        conVer.FirstPublishLocationId = idParent;
        conVer.VersionData = EncodingUtil.base64Decode(base64Data);
        conVer.IsMajorVersion = true;
        conVer.RecordTypeId = idComplianceForm;
        conVer.UAC_documentType__c = formType;
        Insert conVer;
        return conVer;
    }   
}