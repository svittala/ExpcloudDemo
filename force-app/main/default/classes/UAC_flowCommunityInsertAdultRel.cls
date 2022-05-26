public without sharing class UAC_flowCommunityInsertAdultRel {
  @InvocableMethod(label = 'Insert Apprehended Adult Relationship')
  public static List<UAC_flowCommunityManageRelationships.Response> insertApprehendedAdult(List<UAC_flowCommunityManageRelationships.ApprehendedUACRelationship> lstRequest){
    UAC_flowCommunityManageRelationships.Response objResponse = new UAC_flowCommunityManageRelationships.Response();
    objResponse.success = false;
    try {
      UAC_flowCommunityManageRelationships.ApprehendedUACRelationship objRequest = lstRequest[0];
      List<Case> listCase = UAC_flowCommunityManageRelationships.checkReferralStatus(objRequest.referralID);
      if(listCase == null || listCase.isEmpty() || listCase[0].Status != Label.UAC_newPendingContactStatus){
        objResponse.errorMessage = UAC_flowCommunityManageRelationships.STR_ERROR_STATUS;
        return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
      }
      if(String.isBlank(objRequest.referralID) || String.isBlank(objRequest.strRelationship) || String.isBlank(listCase[0].ContactId)){
        objResponse.errorMessage = UAC_flowCommunityManageRelationships.STR_ERROR_REQ;
        return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
      }
      System.debug('request.firstname relclass:' +objRequest.strFirstName);
      System.debug('request.Lastname rel class:' +objRequest.strLastName);
      UAC_apprehendedRelationship__c newRelationship = UAC_flowCommunityManageRelationships.createApprehendedPerson(objRequest);
      newRelationship.UAC_uacLookup__c = listCase[0].ContactId;
      insert newRelationship;
      objResponse.success = true;
      return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
    } 
    catch (Exception e) {
      objResponse.errorMessage = e.getMessage();
      return new List<UAC_flowCommunityManageRelationships.Response>{objResponse};
    }
  }
}