public without sharing class ViewRulesOfBehavior {
    public String message{get;set;}
    public Document att {
        get {
            if (att == null) {
                att = [SELECT Body, ContentType, Name FROM Document WHERE Name = 'RulesOfBehavior'];
            }
            return att;
        }
        private set;
    }
    public String pdf {
        get {
            return EncodingUtil.Base64Encode(att.body);
        }
    }
    public PageReference Save() {
        message = 'ROB Acknowledged by ' + UserInfo.getUserName();
        User currentUser = [select id, ROB_Accepted_Date__c from User where Id = :UserInfo.getUserId()];
        if (currentUser != null) {
            currentUser.ROB_Accepted_Date__c = Date.today();
            update currentUser;
        }
        return null;
    }
    public PageReference Cancel() {
        message = 'Canceled ROB Acknowledgement';
        return null;
    }
}