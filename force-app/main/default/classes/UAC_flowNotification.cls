/**
 * @File Name         : UAC_flowNotification.cls
 * @Description       : Wrapper class used as an Apex data type for an autolaunched flow to send notifications
 * @Group             : UAC_flowNotification
 * @Author            : James Qian (Deloitte)
 **/
public
without sharing class UAC_flowNotification {
  @AuraEnabled public String strType;
  @AuraEnabled public String strNotificationBody;
  @AuraEnabled public String strTitle;
  @AuraEnabled public List<String> listRecipientIds;
  @AuraEnabled public String strTarget;

  /**
   * @description Generic constructor
   * @author James Qian (Deloitte)
   **/
  public
  UAC_flowNotification() {
  }

  /**
   * @description Overloaded constructor
   * @author James Qian (Deloitte)
   * @param String strTypeInput
   * @param String strNotificationBodyInput
   * @param String strTitleInput
   * @param List<String> listRecipientIdsInput
   * @param String strTargetInput
   **/
  public
  UAC_flowNotification(String strTypeInput,
      String strNotificationBodyInput,
      String strTitleInput,
      List<String> listRecipientIdsInput,
      String strTargetInput) {
    strType = strTypeInput;
    strNotificationBody = strNotificationBodyInput;
    strTitle = strTitleInput;
    listRecipientIds = listRecipientIdsInput;
    strTarget = strTargetInput;
  }
}