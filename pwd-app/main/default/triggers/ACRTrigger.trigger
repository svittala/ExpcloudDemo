trigger ACRTrigger on AccountContactRelation (after insert, after update, after delete) {
    
    // For every OpportunityLineItem record, add its associated pricebook entry
    // to a set so there are no duplicates.
    Set<Id> contactIds = new Set<Id>();
    for (AccountContactRelation acr : Trigger.new) 
        contactIds.add(acr.ContactId);


    Map<Id, AccountContactRelation> acrEntries = new Map<Id, AccountContactRelation>(
        [select ContactId, Account.Portal_Id__c, Roles from AccountContactRelation 
         where ContactId in :contactIds order by ContactId]);
         
	Map<Id, User> contactIdToUserMap = new Map<Id, User>([select id, Program_Entitlements__c from User where ContactId in :contactIds ]);
    
    String prevContactId = null;
    String programEntitlements = '';
    for (String acrId : acrEntries.keySet()) {
        AccountContactRelation acr = acrEntries.get(acrId);
        if (acr.ContactId != prevContactId) {
            if (prevContactId != null) {
                contactIdToUserMap.get(prevContactId).Program_Entitlements__c = programEntitlements;
            }
            programEntitlements = '';
            prevContactId = acr.ContactId;
        }
        programEntitlements += acr.Account.Portal_Id__c + ':' + acr.Roles + ';';
    }
    contactIdToUserMap.get(prevContactId).Program_Entitlements__c = programEntitlements;

}