public
without sharing class UAC_flowCommunityManageRelationships {
  public
  static final String STR_ERROR_STATUS =
      'You do not have the permission to update relationships for a referral that is not in pending status.';
  public
  static final String STR_ERROR_REQ = 'Required field missing.';

  @InvocableMethod(label = 'Insert Apprehended UAC Relationship') public static List<
      Response> insertApprehendedUAC(List<ApprehendedUACRelationship> lstRequest) {
    Response objResponse = new Response();
    objResponse.success = false;
    try {
      ApprehendedUACRelationship objRequest = lstRequest[0];
      List<Case> listCase = checkReferralStatus(objRequest.referralID);
      if (listCase == null || listCase.isEmpty()
          || listCase[0].Status != Label.UAC_newPendingContactStatus) {
        objResponse.errorMessage = STR_ERROR_STATUS;
        return new List<Response>{objResponse};
      }
      if (String.isBlank(objRequest.referralID) || String.isBlank(objRequest.strANum)
          || String.isBlank(objRequest.strRelationship) || String.isBlank(listCase[0].ContactId)) {
        objResponse.errorMessage = STR_ERROR_REQ;
        return new List<Response>{objResponse};
      }
      List<Contact> listContactToQuery = [
        SELECT Id,
        UAC_A__c FROM Contact WHERE UAC_A__c =:objRequest.strANum AND RecordType.DeveloperName
                                             =:Label.UAC_contactRecordTypeApiNameUAC
      ];
      UAC_apprehendedRelationship__c newRelationship = createApprehendedUAC(objRequest);
      if (listContactToQuery != null && !listContactToQuery.isEmpty()) {
        newRelationship.UAC_relatedUAC__c = listContactToQuery[0].Id;
      } else {
        Contact newContact = createUACContact(objRequest,
            Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get(Label.UAC_contactRecordTypeApiNameUAC)
                .getRecordTypeId());
        insert newContact;
        newRelationship.UAC_relatedUAC__c = newContact.Id;
      }
      newRelationship.UAC_uacLookup__c = listCase[0].ContactId;
      insert newRelationship;
      objResponse.success = true;
      return new List<Response>{objResponse};
    } catch (Exception e) {
      objResponse.errorMessage = e.getMessage();
      return new List<Response>{objResponse};
    }
  }

  public
  static List<Case> checkReferralStatus(Id referralId) {
    if(String.isBlank(referralID)) {
        return null;
    }
    return [
      SELECT Id,
      ContactId,
      Status FROM Case WHERE RecordType.DeveloperName =:Label.UAC_referralRecordTypeName AND Id
                                                      =:referralId
    ];
  }

  public
  static UAC_apprehendedRelationship__c createApprehendedUAC(ApprehendedUACRelationship request) {
    UAC_apprehendedRelationship__c newRelationship = new UAC_apprehendedRelationship__c(
        UAC_firstName__c = parseString(request.strFirstName, 255),
        UAC_lastName__c = parseString(request.strLastName, 255),
        UAC_country__c = request.strCOB,
        UAC_childDOB__c = parseString(String.valueOf(request.dateDOB), 255),
        UAC_alienNumber__c = parseString(request.strANum, 10),
        UAC_entry__c = request.referralID,
        UAC_relationshipToUAC__c = request.strRelationship);
    if (String.isNotBlank(request.recordID)) {
      newRelationship.Id = request.recordID;
    } else {
      newRelationship.RecordTypeId = Schema.SObjectType.UAC_apprehendedRelationship__c.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_apprehendedUACRecordType)
          .getRecordTypeId();
    }
    return newRelationship;
  }

  public
  static UAC_apprehendedRelationship__c createApprehendedPerson(ApprehendedUACRelationship request) {
    UAC_apprehendedRelationship__c newRelationship = new UAC_apprehendedRelationship__c(
        UAC_firstName__c = parseString(request.strFirstName, 255),
        UAC_lastName__c = parseString(request.strLastName, 255),
        UAC_country__c = request.strCOB,
        UAC_childDOB__c = parseString(String.valueOf(request.dateDOB), 255),
        UAC_alienNumber__c = parseString(request.strANum, 10),
        UAC_entry__c = request.referralID,
        UAC_relationshipToUAC__c = request.strRelationship);
    if (String.isNotBlank(request.recordID)) {
      newRelationship.Id = request.recordID;
    } else {
      newRelationship.RecordTypeId = Schema.SObjectType.UAC_apprehendedRelationship__c.getRecordTypeInfosByDeveloperName()
          .get('UAC_apprehendedAdult')
          .getRecordTypeId();
    }
    System.debug('firstname :' +newRelationship.UAC_firstName__c);
    System.debug('lastname :' +newRelationship.UAC_lastName__c);
    return newRelationship;
  }

  public
  static Contact createUACContact(ApprehendedUACRelationship request, Id idRecordType) {
    System.debug('recordtypeId: ' + idRecordType);
    System.debug('FirstName: ' + request.strFirstName);
    System.debug('LastName: ' + request.strLastName);
    System.debug('UAC_gender__c: ' + request.strGender);
    System.debug('BirthDate: ' + request.dateDOB);
    System.debug('UAC_COB__c: ' + request.strCOB);
    System.debug('UAC_A__c: ' + request.strANum);
    return new Contact(RecordTypeId = idRecordType,
        FirstName = parseString(request.strFirstName, 40),
        LastName = parseString(request.strLastName, 80),
        UAC_gender__c = request.strGender,
        BirthDate = request.dateDOB,
        UAC_COB__c = request.strCOB,
        UAC_A__c = request.strANum,
        UAC_relatedToOtherUAC__c = 'Yes');
  }

  public
  static Contact createAdultContact(UAC_flowCommunityInsertAdultCon.AdultContactRelationship request, Id idRecordType) {
    String strAddress = '';
    if(String.isNotBlank(request.strAddress)) {
      strAddress = 'Address provided by other agency: ' + request.strAddress;
    }
    return new Contact(RecordTypeId = idRecordType,
        FirstName = parseString(request.strFirstName, 40),
        LastName = parseString(request.strLastName, 80),
        Phone = request.strPhone,
        UAC_A__c = parseString(request.strANum, 10),
        UAC_comment__c = parseString(strAddress, 10000));
  }

  public
  static String parseString(String strInput, Integer maxLength) {
    if (String.isBlank(strInput)) {
      return strInput;
    }
    return strInput.left(maxLength);
  }

  public without sharing class ApprehendedUACRelationship {
    @InvocableVariable(required = true) public String referralID;
    @InvocableVariable public String strFirstName;
    @InvocableVariable public String strLastName;
    @InvocableVariable public String strCOB;
    @InvocableVariable public String strGender;
    @InvocableVariable public Date dateDOB;
    @InvocableVariable public String strANum;
    @InvocableVariable(required = true) public String strRelationship;
    @InvocableVariable public String recordID;
  }

  public without sharing class Response {
    @InvocableVariable public Boolean success;
    @InvocableVariable public String errorMessage;
  }
}