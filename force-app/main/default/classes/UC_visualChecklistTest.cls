/**
 * @File Name          : UC_visualChecklistTest.cls
 * @Description        : Main test class for UC_visualChecklistService
 * @Group              : UAC_admissionAssessment
 * */
@isTest public class UC_visualChecklistTest {
  private
  static final string strAccountRecordTypeProgram = Label.UAC_accountRecordTypeAPINameProgram;
  private
  static final string strContactRecordTypeUAC = Label.UAC_contactRecordTypeApiNameUAC;
  private
  static final string strcaseRecordTypeReferral = Label.UAC_caseRecordTypeApiNameUACReferral;
  private
  static final string strcaseRecordTypeAdmission = Label.UAC_caseRecordTypeAdmission;
  private
  static final String STR_UAC_CONTACT_A_NUMBER = '123456789';
  private
  static final String STR_PROGRAM_TYPE = 'Secure';
  private
  static final string strPendingAdmissionStatus = 'Pending Admission';
  private
  static final string strCompletedAdmissionStatus = Label.UAC_caseStatusCompleted;
  private
  static final string strCompletedTask = 'Completed';
  private
  static final string strAdmittedStatus = 'Admitted';
  private
  static final String STR_PROGRAM_TYPE_EIS = 'Emergency Intake Sites';
  private
  static final String STR_CONFIG_ADMISSION = 'Admission';

  /**
   * @description Test setup method - creates contact, account, and assets
   * @return void
   **/
  @testsetup static void setupTestData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(strContactRecordTypeUAC)
                                .buildAndSave();
    Account objProgram = new UAC_testAccountBuilder()
                             .setRecordTypeDeveloperName(strAccountRecordTypeProgram)
                             .setType(STR_PROGRAM_TYPE)
                             .buildAndSave();
    UAC_TestUtility.createAssets(objProgram.Id, 'Female', 'Available', 5, true);
  }

  /**
   * @description Tests data creation after admission case set to "Admitted" status
   * @return void
   **/
  @isTest static void testChecklistCreation() {
    Account accountProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Case caseAdmission = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                             .setUAC(UAC.id)
                             .buildAndSave();
    Test.startTest();
    caseAdmission.status = strAdmittedStatus;
    caseAdmission.UAC_programFacility__c = accountProgram.Id;
    caseAdmission.Type = 'Initial Placement';
    update caseAdmission;
    Test.stopTest();
    List<Task> listTasksQueried = [SELECT Id FROM Task WHERE WhatId =:caseAdmission.Id];
    System.assert(listTasksQueried.size() > 0);
  }

  /**
   * @description Tests aura enabled method to retrieve checklist data
   * @return void
   **/
  @isTest static void testGettingChecklistItems() {
    Account accountProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Case caseAdmission = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                             .setUAC(UAC.id)
                             .buildAndSave();
    UC_visualChecklistService.createAdmissionTasks(
        new Set<Id>{caseAdmission.Id}, STR_CONFIG_ADMISSION);
    Test.startTest();
    UC_visualChecklistService.ChecklistResponse objResponse =
        UC_visualChecklistService.getChecklistItems(caseAdmission.Id, STR_CONFIG_ADMISSION);
    Test.stopTest();
    System.assertNotEquals(null, objResponse.data);
    System.assert(objResponse.data.size() > 0);
  }

  /**
   * @description Tests aura enabled method to update checklist item/Task
   * @return void
   **/
  @isTest static void testUpdatingChecklistItems() {
    String strRecurringSubject = 'Notice of Placement in a Restrictive Setting';
    Account accountProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Case caseAdmission = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                             .setUAC(UAC.id)
                             .buildAndSave();
    UC_visualChecklistService.createAdmissionTasks(
        new Set<Id>{caseAdmission.Id}, STR_CONFIG_ADMISSION);
    Test.startTest();
    Task queriedTask = [SELECT Id FROM Task WHERE Subject =:strRecurringSubject LIMIT 1];
    UC_visualChecklistService.updateChecklistItem(caseAdmission.Id,
        queriedTask.Id,
        strRecurringSubject,
        STR_CONFIG_ADMISSION,
        strCompletedTask);
    Test.stopTest();
    Task queriedTaskForAssert =
        [SELECT Id, ActivityDate FROM Task WHERE Subject =:strRecurringSubject LIMIT 1];
    System.assert(System.Today().daysBetween(queriedTaskForAssert.ActivityDate) >= 29);
  }

  /**
   * @description Tests aura enabled method to get admission status for whether to show edit button
   * @return void
   **/
  @isTest static void testAdmissionStatus() {
    Account accountProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Case caseAdmission = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                             .setUAC(UAC.id)
                             .buildAndSave();
    Test.startTest();
    caseAdmission.status = strAdmittedStatus;
    caseAdmission.UAC_programFacility__c = accountProgram.Id;
    caseAdmission.Type = 'Initial Placement';
    update caseAdmission;
    caseAdmission.status = strCompletedAdmissionStatus;
    update caseAdmission;
    Test.stopTest();
    System.assertEquals(
        true, UC_visualChecklistService.getRecordStatus(caseAdmission.Id, STR_CONFIG_ADMISSION));
  }

  /**
   * @description Tests future method to update task statuses
   * @return void
   **/
  @isTest static void testUpdateAdmissionTasks() {
    Account accountProgram = [SELECT Id FROM Account WHERE RecordType.DeveloperName
        =:strAccountRecordTypeProgram AND UAC_withinORRNetwork__c = 'Yes' LIMIT 1];
    Contact UAC = [select id, UAC_status__c from Contact where RecordType.DeveloperName
      =:strContactRecordTypeUAC limit 1];
    Case caseAdmission = new UAC_testCaseBuilder()
                             .setStatus(strPendingAdmissionStatus)
                             .setRecordTypeDeveloperName(strcaseRecordTypeAdmission)
                             .setUAC(UAC.id)
                             .buildAndSave();
    UC_visualChecklistService.createAdmissionTasks(
        new Set<Id>{caseAdmission.Id}, STR_CONFIG_ADMISSION);
    Test.startTest();
    UAC_admissionAssessment__c assessmentNew = UAC_TestUtility.createAdmissionAssessment(
        caseAdmission.Id, Label.UAC_assessmentRecordTypeISP, true);
    UC_visualChecklistService.updateAdmissionTasks(new Set<Id>{assessmentNew.Id}, strCompletedTask);
    Test.stopTest();
    Task queriedTask =
        [SELECT Id, ActivityDate FROM Task WHERE Subject = 'Individual Service Plan'];
    System.assert(System.Today().daysBetween(queriedTask.ActivityDate) >= 29);
  }
}