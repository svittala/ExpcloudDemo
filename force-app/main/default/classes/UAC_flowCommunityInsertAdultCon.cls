public without sharing class UAC_flowCommunityInsertAdultCon {
  @InvocableMethod(label = 'Insert Adult Contact Relationship')
  public static List<UAC_flowCommunityManageRelationships.Response> insertAdultContactRelationship(List<AdultContactRelationship> lstRequest) {
    UAC_flowCommunityManageRelationships.Response objResponse = new UAC_flowCommunityManageRelationships.Response();
    objResponse.success = false;
    try {
      AdultContactRelationship objRequest = lstRequest[0];
      List<Case> listCase = UAC_flowCommunityManageRelationships.checkReferralStatus(objRequest.referralID);
      if (listCase == null || listCase.isEmpty() || listCase[0].Status != Label.UAC_newPendingContactStatus) {
        objResponse.errorMessage = UAC_flowCommunityManageRelationships.STR_ERROR_STATUS;
        return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
      }
      if (String.isBlank(objRequest.referralID) || String.isBlank(objRequest.strFirstName) || String.isBlank(objRequest.strLastName)
          || String.isBlank(objRequest.strRelationship) || String.isBlank(listCase[0].ContactId)) {
        objResponse.errorMessage = UAC_flowCommunityManageRelationships.STR_ERROR_REQ;
        return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
      }
      List<Contact> listContactToQuery;
      if (String.isNotBlank(objRequest.strANum)) {
        listContactToQuery = [SELECT Id,UAC_A__c FROM Contact WHERE UAC_A__c =:objRequest.strANum AND RecordType.DeveloperName =:Label.UAC_contactRecordTypeApiNameAdultContact];
      }
      UAC_adultContactRelationship__c newRelationship = createAdultContact(objRequest, listCase[0].ContactId);
      if (listContactToQuery != null && !listContactToQuery.isEmpty() && objRequest.strANum != null && objRequest.strANum != '') {
        newRelationship.UAC_adultContact__c = listContactToQuery[0].Id;
      }
      else {
        Contact newContact = UAC_flowCommunityManageRelationships.createAdultContact(objRequest,
                                 Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Label.UAC_contactRecordTypeApiNameAdultContact).getRecordTypeId());
        insert newContact;
        newRelationship.UAC_adultContact__c = newContact.Id;
      }
      insert newRelationship;
      objResponse.success = true;
      return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
    } catch (Exception e) {
      objResponse.errorMessage = e.getMessage();
      return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
    }
  }

  public without sharing class AdultContactRelationship {
    @InvocableVariable(required = true) public String referralID;
    @InvocableVariable public String strFirstName;
    @InvocableVariable public String strLastName;
    @InvocableVariable public String strPhone;
    @InvocableVariable public String strAddress;
    @InvocableVariable public String strANum;
    @InvocableVariable(required = true) public String strRelationship;
    @InvocableVariable public String recordID;
  }

  public
  static UAC_adultContactRelationship__c createAdultContact(AdultContactRelationship request, Id uacId) {
    return new UAC_adultContactRelationship__c(
        UAC_uacLookup__c = uacId,
        UAC_relationshipType__c = 'Potential Sponsor',
        UAC_relationshipToUAC__c = request.strRelationship);
  }
}