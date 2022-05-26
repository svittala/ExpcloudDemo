/**
 * @File Name          : UAC_TestUtility.cls
 * @Description        : Test utility class for building basic object records and holding utility
 *                       methods.
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_TestBuilder
 * @Last Modified By   : James Qian (Deloitte)
 * @Last Modified On   : 5/13/2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0     5/13/2020         James Qian (Deloitte)      Initial Version
 **/
@isTest public class UAC_TestUtility {
  private
  static final String STRING_ASSET_RECORD_TYPE = 'UAC_bed';
  public
  static UAC_apprehendedRelationship__c createApprehendedRelationshipRecord(
      Id idUAC, Id idRelatedUAC, Id idRecordType, String strRelationship, Boolean boolInsert) {
    UAC_apprehendedRelationship__c newRelationship =
        new UAC_apprehendedRelationship__c(UAC_uacLookup__c = idUAC,
            UAC_relatedUAC__c = idRelatedUAC,
            UAC_relationshipToUAC__c = strRelationship,
            RecordTypeId = idRecordType);
    if (boolInsert) {
      insert newRelationship;
    }
    return newRelationship;
  }

  public
  static List<Asset> createAssets(
      Id idProgram, String strGender, String strStatus, Integer intToCreate, Boolean boolInsert) {
    Id idBedRecordType = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
                             .get(STRING_ASSET_RECORD_TYPE)
                             .getRecordTypeId();
    List<Asset> listAsset = new List<Asset>();
    for (Integer i = 0; i < intToCreate; i++) {
      listAsset.add(new Asset(AccountId = idProgram,
          UAC_gender__c = strGender,
          RecordTypeId = idBedRecordType,
          Status = strStatus,
          UC_Type__c = 'Teen',
          UAC_minimumAge__c = 0,
          UAC_maximumAge__c = 17,
          UAC_overallStatus__c = 'Delivered',
          Name = 'Test'));
    }
    if (boolInsert) {
      insert listAsset;
    }
    return listAsset;
  }

  public
  static UAC_admissionAssessment__c createAdmissionAssessment(
      Id idCaseId, String strRecordTypeDevName, Boolean boolInsert) {
    UAC_admissionAssessment__c assessmentNew =
        new UAC_admissionAssessment__c(UAC_entry__c = idCaseId,
            UAC_assessmentStatus__c = Label.UAC_assessmentStatusPending,
            UAC_confirmCM__c = true,
            UAC_listTeamMembersContributedISPLong__c = 'None',
            UAC_printedNameCM__c = UserInfo.getUserId(),
            UAC_translatorNameCM__c = UserInfo.getName() + 'CM',
            UAC_languageCM__c = userInfo.getLanguage() + 'EN',
            RecordTypeId =
                getRecordTypeIdByDevName(strRecordTypeDevName, 'UAC_admissionAssessment__c'));
    if (boolInsert) {
      insert assessmentNew;
    }
    return assessmentNew;
  }

  public
  static Map<String, Id> getCaseTeamRoleMap() {
    Map<String, Id> mapCaseTeamRoles = new Map<String, Id>();
    for (CaseTeamRole roleCurrent : [SELECT Id, Name FROM CaseTeamRole]) {
      mapCaseTeamRoles.put(roleCurrent.Name, roleCurrent.Id);
    }
    return mapCaseTeamRoles;
  }

  public
  static CaseTeamMember createCaseTeamMember(Id idUser, Id idRole, Id idCase, Boolean boolInsert) {
    CaseTeamMember memberNew =
        new CaseTeamMember(MemberId = idUser, TeamRoleId = idRole, ParentId = idCase);
    if (boolInsert) {
      insert memberNew;
    }
    return memberNew;
  }

  public
  static Id getRecordTypeId(String strRecordTypeLabel, String strObjectAPIName) {
    return Schema.getGlobalDescribe()
        .get(strObjectAPIName)
        .getDescribe()
        .getRecordTypeInfosByName()
        .get(strRecordTypeLabel)
        .getRecordTypeId();
  }

  public
  static Id getRecordTypeIdByDevName(String strRecordTypeDevName, String strObjectAPIName) {
    return Schema.getGlobalDescribe()
        .get(strObjectAPIName)
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get(strRecordTypeDevName)
        .getRecordTypeId();
  }

  /*
   * @description Method to create User
   * @author Issam Awwad (Deloitte) | 6/29/2020
   * @return
   **/
  public
  static User createUser(string strProfileName) {
    User u = generateUser(strProfileName);
    insert u;
    return u;
  }

  /*
   * @description Method to create User with Role
   * @author James Qian (Deloitte) | 10/1/2020
   * @return
   **/
  public
  static User createUser(string strProfileName, String strRoleName) {
    User u = generateUser(strProfileName);
    Id idUserRole = [SELECT Id FROM UserRole WHERE DeveloperName =:strRoleName][0].Id;
    u.UserRoleId = idUserRole;
    insert u;
    return u;
  }

  /*
   * @description Private method to create User
   * @author James Qian (Deloitte) | 10/1/2020
   * @return
   **/
  public
  static User generateUser(string strProfileName) {
    String orgId = UserInfo.getOrganizationId();
    String dateString =
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;
    User u = new user();
    u.LastName = 'Test Code';
    u.email = uniqueName + '@hhs' + orgId + '.gov';
    u.Username = uniqueName + '@hhs' + '.gov' + orgId;
    u.Alias = 'Tcode';
    u.CommunityNickname = uniqueName;
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = [SELECT Id FROM Profile WHERE Name =:strProfileName].Id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    return u;
  }

  /*
   * @description Method to query 
   * @author James Qian (Deloitte) | 10/1/2020
   * @return
   **/
  public
  static User getAlternateAdminUser() {
    User queriedUser =
        [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Id
            !=:UserInfo.getUserId() LIMIT 1];
    if (queriedUser != null) {
      return queriedUser;
    }
    System.runAs(new User(Id = UserInfo.getUserId())) {
      queriedUser = createUser('System Administrator');
    }
    return queriedUser;
  }
}