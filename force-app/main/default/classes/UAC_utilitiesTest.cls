/**
 * @File Name          : UAC_utilitiesTest.cls
 * @Description        : Provides test coverage for utility code
 * @Author             : James Qian (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    10/7/2020    James Qian (Deloitte)     Initial Implementation.
 **/
@isTest public class UAC_utilitiesTest {
  /**
   * @description Calls setAppSettings method for testing
   * @author James Qian (Deloitte) | 10/7/2020
   * @return void
   **/
  @isTest static void testSetAppSettings() {
    Test.startTest();
    UAC_appSettingsService.setAppSettings();
    Test.stopTest();
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_notificationTypeID__c != null);
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_intakesTeamId__c != null);
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_pathAppId__c != null);
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_healthAppId__c != null);
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_mentalHealthAppId__c != null);
  }

  /**
   * @description Calls UAC_sandboxPostCreation class for testing
   * @author James Qian (Deloitte) | 10/7/2020
   * @return void
   **/
  @isTest static void testPostSandboxCopyScript() {
    Test.startTest();
    Test.testSandboxPostCopyScript(new UAC_sandboxPostCreation(),
        UserInfo.getOrganizationId(),
        UserInfo.getOrganizationId(),
        UserInfo.getOrganizationName());
    Test.stopTest();
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_notificationTypeID__c != null);
    System.assert(UAC_appSettings__c.getOrgDefaults().UAC_intakesTeamId__c != null);
  }
}