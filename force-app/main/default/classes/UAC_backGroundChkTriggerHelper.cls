/**
 * @File Name          : UAC_backGroundChkTriggerHelper.cls
 * @Description        : Handles all Background Check trigger logic
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/7/2020   Karthi Subramanian (Deloitte)     Initial Implementation.
 * 2.0    	10/28/2020   	Nithin Malla (Deloitte)     		Adding With Sharing keyword.
 **/
public
with sharing class UAC_backGroundChkTriggerHelper {
  static final String STR_ERROR_CANNOT_DELETE_RECORD = Label.UAC_backGroundChkError;
  static final String errorMessage = 'Error';
  /**
   * @description ORRUAC-789 - Validate background check record whether Results Entered
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param mapBackGroundchk
   * @return void
   **/
  public
  static void validateResultsUpdate(Map<Id, UAC_backgroundCheck__c> mapBackGroundchk) {

    for (UAC_backgroundCheck__c objBackGroundChk : mapBackGroundchk.values()) {
      if ((objBackGroundChk.UAC_results__c != null)
          || (objBackGroundChk.UAC_systemGeneratedRec__c)) {  // System Generated and/or results
                                                              // entered, then can't delete error
        objBackGroundChk.addError(STR_ERROR_CANNOT_DELETE_RECORD);
      }
    }
  }
  /**
   * @description ORRUAC-437/469 - Validate background check record whether Adult Contact is Sponsor
   *or HHM or AACG *CHANGE* US - 3798 Since BAckground check - Application is now mamy to many
   *relationship the below methos is not required.
   * @author Vaibhav Kudesia (Deloitte) | 6/25/2020
   * @param listBackGroundChkRecs
   * @return void
   **/
  /*  public static void canCreateBGRecords(List<UAC_backgroundCheck__c> listBackGroundChkRecs){

    Map<Id,Id> mapBgIdCaseId = new Map<Id,Id>();
    Map<Id,Case> mapCaseIdCase = new Map<Id,Case>();
    Map<Id,Boolean> mapBgValidCHeck = new Map<Id,Boolean>();
    for(UAC_backgroundCheck__c bgRecs: listBackGroundChkRecs)
    {
        mapBgIdCaseId.put(bgRecs.Id,bgRecs.UAC_sponsorApplication__c);
        mapBgValidCHeck.put(bgRecs.Id,False);
    }

    for(case acrRecs: [Select id,
UAC_relationshipToUAC__c,UAC_relationshipToUAC__r.UAC_adultContact__c,UAC_relationshipToUAC__r.UAC_relationshipType__c,
UAC_sponsor__c,(Select id,UAC_contact__c,UAC_alternateAdultCaregiver__c,UAC_householdMember__c from
UAC_associatedContacts__r where UAC_householdMember__c = true or UAC_alternateAdultCaregiver__c =
true) from case where id in: mapBgIdCaseId.values()]){ mapCaseIdCase.put(acrRecs.Id,acrRecs);
    }
    for(UAC_backgroundCheck__c bgRecs: listBackGroundChkRecs)
    {
        if(bgRecs.UAC_adultContact__c ==
mapCaseIdCase.get(bgRecs.UAC_sponsorApplication__c).UAC_relationshipToUAC__r.UAC_adultContact__c &&
mapCaseIdCase.get(bgRecs.UAC_sponsorApplication__c).UAC_relationshipToUAC__r.UAC_relationshipType__c
== Label.UAC_relationshipTypePrimarySponsor){ mapBgValidCHeck.put(bgRecs.Id,True);
        }
        for(UAC_associatedContact__c objAC :
mapCaseIdCase.get(bgRecs.UAC_sponsorApplication__c).UAC_associatedContacts__r){
            if(bgRecs.UAC_adultContact__c == objAC.UAC_contact__c){
                mapBgValidCHeck.put(bgRecs.Id,True);
            }
        }
    }
    for(UAC_backgroundCheck__c bgRecs: listBackGroundChkRecs)
    {
        if(!mapBgValidCHeck.get(bgRecs.Id)){
           bgRecs.adderror(Label.UAC_backGroundChkContactTypeError);
        }
    }
}
      */
  /**
   * @description Query the Sponsor Application Files for an ARI form related to the same contact
   *and populate Date ARI Receieved
   * @author Issam Awwad (Deloitte) | 1/19/2021
   * @param newItems
   * @return void
   **/
  public
  static void populateDateARIReceived(List<UAC_backgroundCheck__c> newItems) {
    Map<Id, UAC_backgroundCheck__c> mapOfSponsorToBackground =
        new Map<Id, UAC_backgroundCheck__c>();
    Map<Id, Id> mapOfSponsorAppToSponsor = new Map<Id, Id>();
    Set<Id> setOfSponsorApp = new Set<Id>();
    for (UAC_backgroundCheck__c objBackGroundChk : newItems) {
      mapOfSponsorToBackground.put(objBackGroundChk.UAC_adultContact__c, objBackGroundChk);
    }
    List<Case> lstOfSponsorApp = [SELECT Id, UAC_sponsor__c FROM Case WHERE UAC_sponsor__c
      IN:mapOfSponsorToBackground.keySet()];
    for (Case objCase : lstOfSponsorApp) {
      setOfSponsorApp.add(objCase.Id);
      mapOfSponsorAppToSponsor.put(objCase.Id, objCase.UAC_sponsor__c);
    }
    List<ContentVersion> lstOfFiles = [SELECT Id,
      UAC_documentType__c,
      UAC_dateReceived__c,
      FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId IN:setOfSponsorApp];
    for (ContentVersion objContentVersion : lstOfFiles) {
      if (objContentVersion.UAC_documentType__c == Label.UAC_contentVersionDocumentTypeFRP2) {
        mapOfSponsorToBackground
            .get(mapOfSponsorAppToSponsor.get(objContentVersion.FirstPublishLocationId))
            .UAC_dateARIReceived__c = objContentVersion.UAC_dateReceived__c;
      }
    }
  }
  /**
   * @description Set role of background check based on associated contact
   * @author Issam Awwad (Deloitte) | 1/19/2021
   * @param newItems
   * @return void
   **/
  public
  static void populateSponsorRole(List<UAC_backgroundCheck__c> newItems) {
    Map<Id, Id> mapOfAdultToSponsorApp = new Map<Id, Id>();
    Map<Id, UAC_associatedContact__c> mapOfContact = new Map<Id, UAC_associatedContact__c>();
    for (UAC_backgroundCheck__c objBackGroundChk : newItems) {
      mapOfAdultToSponsorApp.put(
          objBackGroundChk.UAC_adultContact__c, objBackGroundChk.UAC_sponsorApplication__c);
    }
    List<UAC_associatedContact__c> lstAssociatedContact = [
      SELECT Id,
      UAC_alternateAdultCaregiver__c,
      UAC_familyAndFriends__c,
      UAC_supervisionPlanPerson__c,
      UAC_householdMember__c,
      UAC_contact__c FROM UAC_associatedContact__c WHERE UAC_contact__c
      IN:mapOfAdultToSponsorApp.keySet() AND UAC_case__c
      IN:mapOfAdultToSponsorApp.values()
    ];
    for (UAC_associatedContact__c objContact : lstAssociatedContact) {
      mapOfContact.put(objContact.UAC_contact__c, objContact);
    }
    for (UAC_backgroundCheck__c objBackGroundChk : newItems) {
      UAC_associatedContact__c objAssociatedContact =
          mapOfContact.get(objBackGroundChk.UAC_adultContact__c);
      if (objAssociatedContact != null
          && mapOfAdultToSponsorApp.get(objBackGroundChk.UAC_adultContact__c)
              == objBackGroundChk.UAC_sponsorApplication__c) {
        if (objAssociatedContact.UAC_alternateAdultCaregiver__c
            || objAssociatedContact.UAC_familyAndFriends__c
            || objAssociatedContact.UAC_supervisionPlanPerson__c
            || objAssociatedContact.UAC_householdMember__c) {
          objBackGroundChk.UAC_role__c = objAssociatedContact.UAC_alternateAdultCaregiver__c == true
              ? Label.UAC_backgroundCheckRoleAlternate + ','
              : '';
          objBackGroundChk.UAC_role__c += objAssociatedContact.UAC_familyAndFriends__c == true
              ? Label.UAC_backgroundCheckRoleFamilyFriend + ','
              : '';
          objBackGroundChk.UAC_role__c += objAssociatedContact.UAC_supervisionPlanPerson__c == true
              ? Label.UAC_backgroundCheckRoleSupervision + ','
              : '';
          objBackGroundChk.UAC_role__c += objAssociatedContact.UAC_householdMember__c == true
              ? Label.UAC_backgroundCheckRoleHouseholdMember
              : '';
        }
      } else {
        objBackGroundChk.UAC_role__c = Label.UAC_backgroundCheckRoleSponsor;
      }
    }
  }
}