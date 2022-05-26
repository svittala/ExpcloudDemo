/**
 * @File Name          : UAC_callLogContactList.cls
 * @Description        : ORRUAC-1996: Provides logic for the LWC uacAuthorizedContactTable
 * @Author             : Chaitanya Nandamuri (Deloitte)

 */
public
with sharing class UAC_callLogContactList {
  public
  static final List<string> lstCallListStatus = new List<string>{'Authorized', 'Restricted'};
  public
  static final string strTaskCallLog = Label.UAC_taskTypeCallLog;

  /**
   * @description Queries adultContactRelation and apprehended Relation for a given Contact
   * @author Chaitaya Nandamuri (Deloitte) | 10/02/2020
   * @param Id ContactId (UACId)
   * @return List<sobject>
   **/
  @AuraEnabled public static List<sobject> getContactList(Id UACId) {
    List<sobject> callLogContactList = new List<sobject>();
    for (UAC_apprehendedRelationship__c Relation : [
           select id,
           UAC_uacLookup__r.Name,
           UAC_relationshipToUAC__c,
           UAC_proofOfRelationship__c,
           UAC_phone__c,
           UAC_contactApprovedDate__c,
           UAC_contactDiscontinuedDate__c,
           UAC_contactRestrictedDate__c,
           UAC_contactFullName__c,
           UAC_contactType__c from UAC_apprehendedRelationship__c where UAC_contactType__c
           IN:lstCallListStatus and UAC_uacLookup__c
            =:UACId
         ]) {
      callLogContactList.add((sobject) Relation);
    }

    for (UAC_adultContactRelationship__c ACR : [
           select id,
           UAC_uacLookup__r.Name,
           UAC_relationshipToUAC__c,
           UAC_proofOfRelationship__c,
           UAC_phone__c,
           UAC_contactApprovedDate__c,
           UAC_contactDiscontinuedDate__c,
           UAC_contactRestrictedDate__c,
           UAC_contactFullName__c,
           UAC_contactType__c from UAC_adultContactRelationship__c where UAC_contactType__c
           IN:lstCallListStatus and UAC_uacLookup__c
            =:UACId
         ]) {
      callLogContactList.add((sobject) ACR);
    }
    return callLogContactList;
  }

  /**
   * @description returns CallLogRecordTypeId and PrimaryLanguage for a given Contact
   * @author Chaitaya Nandamuri (Deloitte) | 10/02/2020
   * @param Id ContactId (UACId)
   **/
  @AuraEnabled(cacheable = true) public static UAC_callLogWrapper
      getCallLogTaskRecordIdandPrimeLan(string recordId) {
    UAC_callLogWrapper clWrap =
        new UAC_callLogWrapper(Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                   .get(strTaskCallLog)
                                   .getRecordTypeId(),
            [select UAC_primaryLanguageSpoken__c from contact where id =:recordId limit 1]
                .UAC_primaryLanguageSpoken__c);
    return clWrap;
  }

  /**
   * @description Wrapper Class which returns CallLogRecordTypeId and PrimaryLanguage
   * @author Chaitaya Nandamuri (Deloitte) | 10/02/2020
   **/
  public
  without sharing class UAC_callLogWrapper {
    @AuraEnabled public Id TaskCallLogRecordId;
    @AuraEnabled public String strPrimaryLanguageSpoken;
    private
    UAC_callLogWrapper(Id TaskCallLogRecordIdInput, String strPrimaryLanguageSpokenInput) {
      TaskCallLogRecordId = TaskCallLogRecordIdInput;
      strPrimaryLanguageSpoken = strPrimaryLanguageSpokenInput;
    }
  }
}