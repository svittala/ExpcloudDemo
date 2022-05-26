/**
 * @File Name         : UAC_genericResponse.cls
 * @Description       : Generic response wrapper class to send AuraEnabled complex response
 * @Group             : UAC_genericResponse
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-07-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-23-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
inherited sharing class UAC_genericResponse {
  @AuraEnabled public Boolean isSuccess = false;
  @AuraEnabled public String error;
  @AuraEnabled public Map<String, Object> data = new Map<String, Object>();
}