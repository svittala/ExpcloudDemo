/**
 * @File Name          : UAC_fileWrapper.cls
 * @Description        : Generic wrapper class used for holding file/attachment information.
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_wrapper
 * @Test Class         : UAC_FileServicesTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 10-07-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    5/5/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
public
inherited sharing class UAC_fileWrapper {
  @AuraEnabled public Id idParent;
  @AuraEnabled public Id idFile;
  @AuraEnabled public String strFileName;
  @AuraEnabled public String strContentType;
  @AuraEnabled public String strBase64Data;
  @AuraEnabled public String strFileType;
  @AuraEnabled public String strUrl;
}