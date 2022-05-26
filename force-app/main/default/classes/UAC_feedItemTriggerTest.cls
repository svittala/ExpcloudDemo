/**
 * @File Name          : UAC_feedItemTriggerTest.cls
 * @Description        : Provides test coverage for FeedItem trigger logic
 * @Author             : James Qian (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author                           Modification
 * 1.0    9/29/2020      James Qian (Deloitte)             Initial Implementation
 **/
@isTest public without sharing class UAC_feedItemTriggerTest {

  /**
   * @description ORRUAC-1774 - Tests preventing file upload on Chatter
   * @author James Qian (Deloitte) | 9/29/2020
   **/
  @isTest static void insertingContentChatterPostShouldFail() {
    Account objAdministrativeAccount = new UAC_testAccountBuilder()
                                           .setRecordTypeDeveloperName('UAC_HSPRSSubcontractors')
                                           .buildAndSave();
    objAdministrativeAccount.UAC_techSubcontractorApproved__c = 'True';
    objAdministrativeAccount.UAC_approvalStatus__c = 'Approved';
    update objAdministrativeAccount;
    Contact objAdultContact = new UAC_testContactBuilder()
                                  .setRecordTypeDeveloperName(Label.UAC_HSPRSSubcontractors)
                                  .build();
    objAdultContact.UAC_subcontractor__c = objAdministrativeAccount.id;
    objAdultContact.UAC_userName__c = userinfo.getUserId();
    insert objAdultContact;
    Test.startTest();
    FeedItem objNewFeedItem = new FeedItem(
        ParentId = objAdultContact.id, Type = Label.UAC_chatterFileUploadType, Body = 'Test');
    String strErrorMessage = '';
    try {
      insert objNewFeedItem;
    } catch (DMLException e) {
      strErrorMessage = e.getMessage();
    }
    Test.stopTest();
    System.assertNotEquals('', strErrorMessage);
    System.assert(strErrorMessage.containsIgnoreCase(Label.UAC_chatterFileUploadMessage));
  }

  /**
   * @description ORRUAC-1774 - Tests preventing file upload on Chatter Comments
   * @author James Qian (Deloitte) | 9/30/2020
   **/
  @isTest static void insertingContentChatterCommentShouldFail() {
    Account objAdministrativeAccount = new UAC_testAccountBuilder()
                                           .setRecordTypeDeveloperName('UAC_HSPRSSubcontractors')
                                           .buildAndSave();
    objAdministrativeAccount.UAC_techSubcontractorApproved__c = 'True';
    objAdministrativeAccount.UAC_approvalStatus__c = 'Approved';
    update objAdministrativeAccount;
    Contact objAdultContact = new UAC_testContactBuilder()
                                  .setRecordTypeDeveloperName(Label.UAC_HSPRSSubcontractors)
                                  .build();
    objAdultContact.UAC_subcontractor__c = objAdministrativeAccount.id;
    objAdultContact.UAC_userName__c = userinfo.getUserId();
    insert objAdultContact;
    Test.startTest();
    FeedItem objNewFeedItem =
        new FeedItem(ParentId = objAdultContact.id, Type = 'TextPost', Body = 'Test');
    insert objNewFeedItem;
    FeedComment objNewFeedComment = new FeedComment(
        FeedItemId = objNewFeedItem.id, CommentType = 'ContentComment', CommentBody = 'Test');
    String strErrorMessage = '';
    try {
      insert objNewFeedComment;
    } catch (DMLException e) {
      strErrorMessage = e.getMessage();
    }
    Test.stopTest();
    System.assertNotEquals('', strErrorMessage);
    System.assert(strErrorMessage.containsIgnoreCase(Label.UAC_chatterFileUploadMessage));
  }

  /**
   * @description ORRUAC-1774 - Tests positive scenarios of updating/deleting chatter posts and
   * comments
   * @author James Qian (Deloitte) | 11/13/2020
   **/
  @isTest static void updatingDeletingChatterPostsShouldBeSuccessful() {
    Account objAdministrativeAccount = new UAC_testAccountBuilder()
                                           .setRecordTypeDeveloperName('UAC_HSPRSSubcontractors')
                                           .buildAndSave();
    objAdministrativeAccount.UAC_techSubcontractorApproved__c = 'True';
    objAdministrativeAccount.UAC_approvalStatus__c = 'Approved';
    update objAdministrativeAccount;
    Contact objAdultContact = new UAC_testContactBuilder()
                                  .setRecordTypeDeveloperName(Label.UAC_HSPRSSubcontractors)
                                  .build();
    objAdultContact.UAC_subcontractor__c = objAdministrativeAccount.id;
    objAdultContact.UAC_userName__c = userinfo.getUserId();
    insert objAdultContact;
    Test.startTest();
    FeedItem objNewFeedItem =
        new FeedItem(ParentId = objAdultContact.id, Type = 'TextPost', Body = 'Test');
    insert objNewFeedItem;
    FeedComment objNewFeedComment = new FeedComment(
        FeedItemId = objNewFeedItem.id, CommentType = 'TextComment', CommentBody = 'Test');
    insert objNewFeedComment;
    Boolean boolSuccess = false;
    try {
      update objNewFeedComment;
      delete objNewFeedComment;
      update objNewFeedItem;
      delete objNewFeedItem;
      boolSuccess = true;
    } catch (Exception e) {
      boolSuccess = false;
    }
    System.assertEquals(true, boolSuccess);
  }
}