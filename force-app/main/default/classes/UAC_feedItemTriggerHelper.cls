public
without sharing class UAC_feedItemTriggerHelper {
  private
  static final String strContentType = Label.UAC_chatterFileUploadType;
  private
  static final String strCommentType = Label.UAC_chatterFileCommentType;
  private
  static final String strContentErrorMessage = Label.UAC_chatterFileUploadMessage;

  /**
   * @description ORRUAC-1774 - Prevents file upload to Chatter
   * @author James Qian (Deloitte) | 9/29/2020
   * @param List<FeedItem> listFeedItems
   * @return void
   **/
  public
  static void preventFileUploadOnChatter(List<FeedItem> listFeedItems) {
    for (FeedItem feedItemCurrent : listFeedItems) {
      if (feedItemCurrent.Type == strContentType) {
        feedItemCurrent.addError(strContentErrorMessage);
      }
    }
  }

  /**
   * @description ORRUAC-1774 - Prevents file upload to Chatter Comments
   * @author James Qian (Deloitte) | 9/30/2020
   * @param List<FeedComment> listFeedComments
   * @return void
   **/
  public
  static void preventFileUploadOnChatterComments(List<FeedComment> listFeedComments) {
    for (FeedComment feedCommentCurrent : listFeedComments) {
      if (feedCommentCurrent.CommentType == strCommentType) {
        feedCommentCurrent.addError(strContentErrorMessage);
      }
    }
  }
}