/**
 * @File Name          : UAC_appSettingsService.cls
 * @Description        : Sets custom settings for UAC Path
 * @Author             : James Qian (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    10/7/2020    James Qian (Deloitte)     Initial Implementation.
 * 1.1    1/14/2021    James Qian (Deloitte)     Adding account settings
 **/
public
without sharing class UAC_appSettingsService {
  private
  static final String strAdminAccountRT = Label.UAC_accountRecordTypeApiNameAdministrativeAccount;
  private
  static final String strNOCAccountRT = Label.UAC_accountRecordTypeApiNameNOC;

  // clang-format off
  static final Map<String,String> MAP_APP_SETTINGS = new Map<String, String>{
    'UAC_Path' => 'UAC_pathAppId__c',
    'UAC_health' => 'UAC_healthAppId__c',
    'UAC_MentalHealth' => 'UAC_mentalHealthAppId__c'
  };
  // clang-format on

  /**
   * @description Sets UAC_appSettings__c field
   * @author James Qian (Deloitte) | 10/7/2020
   * @return void
   **/
  public
  static void setAppSettings() {
    Id idIntakesTeamGroup;
    Id idNOCQueue;
    Id idNOCShareGroup;
    for (Group currentGroup : [
           SELECT DeveloperName,
           Id FROM Group WHERE DeveloperName IN(
               :Label.UAC_intakesTeamGroupName,
               :Label.UAC_NOCQueueName,
               :Label.UAC_nocShareGroupName)
         ]) {
      if (currentGroup.DeveloperName == Label.UAC_intakesTeamGroupName) {
        idIntakesTeamGroup = currentGroup.Id;
      } else if (currentGroup.DeveloperName == Label.UAC_NOCQueueName) {
        idNOCQueue = currentGroup.Id;
      } else if (currentGroup.DeveloperName == Label.UAC_nocShareGroupName) {
        idNOCShareGroup = currentGroup.Id;
      }
    }
    Id idUACNotificationType = [SELECT Id FROM
            CustomNotificationType WHERE DeveloperName =:Label.UAC_pathNotificationType][0].Id;
    UAC_appSettings__c objAppSettings = UAC_appSettings__c.getOrgDefaults();
    objAppSettings.UAC_notificationTypeID__c = idUACNotificationType;
    objAppSettings.UAC_intakesTeamId__c = idIntakesTeamGroup;
    objAppSettings.UAC_NOCQueueID__c = idNOCQueue;
    objAppSettings.UAC_NOCSharingGroupID__c = idNOCShareGroup;
    for (AppDefinition objAppDef : [
           // clang-format off
           SELECT DurableId, DeveloperName
           FROM AppDefinition
           WHERE DeveloperName IN:MAP_APP_SETTINGS.keySet()
           // clang-format on
         ]) {
      objAppSettings.put(MAP_APP_SETTINGS.get(objAppDef.DeveloperName), objAppDef.DurableId);
    }
    if (objAppSettings != null) {
      upsert objAppSettings;
    }
    checkForAccountSettings();
  }

  /**
   * @description Checks for admin/NOC accounts
   * @author James Qian (Deloitte) | 1/14/2021
   * @return void
   **/
  private
  static void checkForAccountSettings() {
    Boolean adminAccountExists = false;
    Boolean nocAccountExists = false;
    for (AggregateResult objResult : [
           SELECT Count(Id),
           RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName IN(
                   : strAdminAccountRT,
                   : strNOCAccountRT) GROUP BY RecordType.DeveloperName
         ]) {
      System.debug(objResult);
      if (objResult.get('DeveloperName') == strAdminAccountRT) {
        adminAccountExists = true;
      } else if (objResult.get('DeveloperName') == nocAccountExists) {
        nocAccountExists = true;
      }
    }

    if (adminAccountExists && nocAccountExists) {
      return;
    } else {
      insertNewAccountSettings();
    }
  }

  /**
   * @description Sets UAC_accountSettings__c fields
   * @author James Qian (Deloitte) | 1/14/2021
   * @return void
   **/
  private
  static void insertNewAccountSettings() {
    UAC_accountSettings__c objAccountSettings = UAC_accountSettings__c.getOrgDefaults();
    Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    List<Account> listAccountsToInsert = new List<Account>();
    listAccountsToInsert.add(
        new Account(RecordTypeId = mapAccountRecordTypes.get(strAdminAccountRT).getRecordTypeId(),
            Name = 'Admin Account'));
    listAccountsToInsert.add(
        new Account(RecordTypeId = mapAccountRecordTypes.get(strNOCAccountRT).getRecordTypeId(),
            Name = 'NOC Account'));
    if (!listAccountsToInsert.isEmpty()) {
      insert listAccountsToInsert;
      objAccountSettings.UAC_administrativeAccountId__c = listAccountsToInsert[0].Id;
      objAccountSettings.UAC_NOCAccountId__c = listAccountsToInsert[1].Id;
      objAccountSettings.UAC_administrativeAccountThreshold__c = 5000;
      objAccountSettings.UAC_NOCAccountThreshold__c = 5000;
      if (objAccountSettings != null) {
        upsert objAccountSettings;
      }
    }
  }
}