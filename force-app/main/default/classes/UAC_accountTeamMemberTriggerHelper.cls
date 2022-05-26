/**
 * @File Name          : UAC_accountTeamMemberTriggerHelper.cls
 * @Description        : Handles all Account trigger logic
 * @Author             : Chaitanya Nandamuri (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    9/8/2020   Chaitanya Nandamuri(Deloitte)     Initial Implementation.
 * 2.0    10/13/2020   	Vaibhav Kudesia (Deloitte)     Added updatePreMonitoringEmailNotification to after events to update emailset on program team update.
 **/
public
without sharing class UAC_accountTeamMemberTriggerHelper {
  public
  static Boolean boolIsFirstRun = true;
  public
  static final Id idProgramRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                      .get(Label.UAC_accountRecordTypeAPINameProgram)
                                      .getRecordTypeId();
  public
  static final Id idContactUACRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                                         .get('UAC_UAC')
                                         .getRecordTypeId();

  public
  static final id idOrgRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                  .get(Label.UAC_organizationRecordTypeDevName)
                                  .getRecordTypeId();
  public
  static final List<String> listOfProgramLeadershipRoles = new List<String>{
      Label.UAC_accountTeamRoleLC, Label.UAC_accountTeamRoleLCM, Label.UAC_accountTeamRolePD};
  /**
   * @description Method to set LTFC permission sets on account team member insert
   * @author James Qian (Deloitte) | 9/21/2020
   * @param listATM List of new records
   * @return void
   **/
  public
  static void assignLTFCPermissionSet(List<AccountTeamMember> listATM) {
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    Set<Id> setUserIds = new Set<Id>();
    List<Id> listAccountIds = new List<Id>();
    for (AccountTeamMember atmCurrent : listATM) {
      if (listOfProgramLeadershipRoles.contains(atmCurrent.TeamMemberRole)) {
        listAccountIds.add(atmCurrent.AccountId);
      }
    }
    for (Account accountCurrent : [
           SELECT Id,
           Type,
           RecordTypeId FROM Account WHERE Id
           IN:listAccountIds AND Type
            =:Label.UAC_ProgramTypeLongTermFosterCare AND RecordTypeId
            =:idProgramRecordType
         ]) {
      mapAccount.put(accountCurrent.Id, accountCurrent);
    }
    for (AccountTeamMember atmCurrent : listATM) {
      if (listOfProgramLeadershipRoles.contains(atmCurrent.TeamMemberRole)
          && mapAccount.containskey(atmCurrent.AccountId)) {
        setUserIds.add(atmCurrent.UserId);
      }
    }
    if (setUserIds == null || setUserIds.isEmpty()) {
      return;
    }
    Set<Id> setUserIdsWithPermissionSet = new Set<Id>();
    for (PermissionSetAssignment currentPSA :
        [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name
             =:Label.UAC_permissionSetNameLTFC AND AssigneeId
            IN:setUserIds]) {
      setUserIdsWithPermissionSet.add(currentPSA.AssigneeId);
    }
    Set<Id> setUserIdsWithoutPermissionSet = new Set<Id>();
    for (Id userId : setUserIds) {
      if (!setUserIdsWithPermissionSet.contains(userId)) {
        setUserIdsWithoutPermissionSet.add(userId);
      }
    }
    if (!setUserIdsWithoutPermissionSet.isEmpty()) {
      createPermissionSetAssignments(setUserIdsWithoutPermissionSet);
    }
  }
  /**
   * @description Future method to avoid mixed DML errors
   * @author James Qian (Deloitte) | 9/21/2020
   * @param setUserIds Set of user IDs
   * @return void
   **/
  @future private static void createPermissionSetAssignments(Set<Id> setUserIds) {
    PermissionSet queriedPermissionSet =
        [SELECT Id FROM PermissionSet WHERE Name =:Label.UAC_permissionSetNameLTFC];
    List<PermissionSetAssignment> listPermissionSetAssignmentsToInsert =
        new List<PermissionSetAssignment>();
    for (Id userId : setUserIds) {
      listPermissionSetAssignmentsToInsert.add(new PermissionSetAssignment(
          AssigneeId = userId, PermissionSetId = queriedPermissionSet.Id));
    }
    if (!listPermissionSetAssignmentsToInsert.isEmpty()) {
      insert listPermissionSetAssignmentsToInsert;
    }
  }
  public
  static void addMembersToFamilyGroupTeam(List<AccountTeamMember> listATM) {

    Map<String, UAC_familyGroupTeamMembers__mdt> mapTeamRoleToFGMdt = queryFamilyGroupMdt();
    Map<Id, List<AccountTeamMember>> mapAccountIdToATM = new map<Id, List<AccountTeamMember>>();
    Map<Id, List<Id>> ProgramIdToFamilyGroup = new map<Id, List<Id>>();
    List<AccountTeamMember> lstFamilyGroupATM = new List<AccountTeamMember>();

    for (AccountTeamMember ATM : listATM) {

      if (!mapTeamRoleToFGMdt.containskey(ATM.TeamMemberRole)) {
        continue;
      }

      list<AccountTeamMember> lstAccountTeam;
      if (mapAccountIdToATM.containskey(ATM.AccountId)) {
        lstAccountTeam = mapAccountIdToATM.get(ATM.AccountId);
      } else {
        lstAccountTeam = new List<AccountTeamMember>();
      }
      lstAccountTeam.add(ATM);
      mapAccountIdToATM.put(ATM.AccountId, lstAccountTeam);
    }

    if (!mapAccountIdToATM.isEmpty()) {
      for (contact UAC : [
             select Id,
             UAC_program__c,
             AccountId from contact where UAC_program__c
             In:mapAccountIdToATM.keyset()and recordTypeId
              =:idContactUACRecordType
           ]) {
        List<Id> FGroupId;
        if (ProgramIdToFamilyGroup.containskey(UAC.UAC_program__c)) {
          FGroupId = ProgramIdToFamilyGroup.get(UAC.UAC_program__c);
        } else {
          FGroupId = new List<Id>();
        }
        FGroupId.add(UAC.AccountId);
        ProgramIdToFamilyGroup.put(UAC.UAC_program__c, FGroupId);
      }
    }

    if (!ProgramIdToFamilyGroup.isEmpty()) {

      for (Id ProgramId : ProgramIdToFamilyGroup.keyset()) {

        for (accountTeamMember ProATM : mapAccountIdToATM.get(ProgramId)) {

          for (Id FamilyGroupId : ProgramIdToFamilyGroup.get(ProgramId)) {

            lstFamilyGroupATM.add(
                createFamilygroupTeamMember(ProATM, FamilyGroupId, mapTeamRoleToFGMdt));
          }
        }
      }
    }
    if (!lstFamilyGroupATM.isEmpty()) {
      asyncCreateFGTeamMembers(JSON.serialize(lstFamilyGroupATM));
    }
  }

  private
  static Map<String, UAC_familyGroupTeamMembers__mdt> queryFamilyGroupMdt() {
    map<String, UAC_familyGroupTeamMembers__mdt> teamRoleToFG =
        new Map<String, UAC_familyGroupTeamMembers__mdt>();
    for (UAC_familyGroupTeamMembers__mdt FGmdt : [
           select TeamMemberRole__c,
           AccountAccessLevel__c,
           CaseAccessLevel__c,
           ContactAccessLevel__c from UAC_familyGroupTeamMembers__mdt
         ]) {
      teamRoleToFG.put(FGmdt.TeamMemberRole__c, FGmdt);
    }
    return teamRoleToFG;
  }

  Private static accountTeamMember createFamilygroupTeamMember(accountTeamMember ProATM,
      Id FamilyGroupId,
      Map<String, UAC_familyGroupTeamMembers__mdt> mapTeamRoleToFGMdt) {

    return new AccountTeamMember(TeamMemberRole = ProATM.TeamMemberRole,
        AccountId = FamilyGroupId,
        UserId = ProATM.UserId,
        AccountAccessLevel = mapTeamRoleToFGMdt.get(ProATM.TeamMemberRole).AccountAccessLevel__c,
        CaseAccessLevel = mapTeamRoleToFGMdt.get(ProATM.TeamMemberRole).CaseAccessLevel__c,
        ContactAccessLevel = mapTeamRoleToFGMdt.get(ProATM.TeamMemberRole).ContactAccessLevel__c);
  }

  Private static void InsertFamilyGroupTeamMember(List<AccountTeamMember> lstATMtoInsert) {
    if (lstATMtoInsert.isEmpty()) {
      return;
    }
    Database.SaveResult[] FGATMresult = Database.insert(lstATMtoInsert, false);

    // Iterate through each returned result
    for (Database.SaveResult sr : FGATMresult) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {

          system.debug('Error Fields :' + err.getFields() + ' Error Msg :' + err.getMessage()
              + ' Error StatusCode :' + err.getStatusCode());
          UAC_errorLog.platformEventErrorLog(err.getStatusCode() + ': ' + err.getMessage(),'',
              'Family Group Account Team',
              'Fields that Caused error : ' + err.getFields());
        }
      }
    }
  }
   /**
   * @description updates concatenated email field on Monitoring Visit in case of AccountTeammember Insert, Update and Delete.
   * @author Vaibhav Kudesia (Deloitte) | 10/12/2020
   * @param newItems List of UAC Monitor to process
   *        IsDelete check if the Trigger context is Delete
   * @return void
   **/    
public
    static void updatePreMonitoringEmailNotification(List<AccountTeamMember> newItems){
        list<Id> lstAccountId = new List<Id>();   
        for (AccountTeamMember atmCurrent : newItems) {
            lstAccountId.add(atmCurrent.AccountId);       			
    	}
        list<UAC_monitoring__c> lstMonitoringVisit = [Select Id, UAC_program__c,UAC_preMonitoringEmailSet__c from UAC_monitoring__c where UAC_program__c =: lstAccountId AND UAC_status__c != 'Complete'];
        UAC_monitoringTriggerHelper.updatePreMonitoringEmailNotification(lstMonitoringVisit,True,null,null);
    }    

  /**
   * @description Future method to split transaction to avoid unexpected DML errors
   * @author James Qian (Deloitte) | 10/9/2020
   * @param strSerializedList List of new records
   * @return void
   **/
  @future private static void asyncCreateFGTeamMembers(String strSerializedList) {
    boolIsFirstRun = false;
    List<AccountTeamMember> listDeserialized = (List<AccountTeamMember>) JSON.deserialize(
        strSerializedList, List<AccountTeamMember>.class);
    InsertFamilyGroupTeamMember(listDeserialized);
  }
  /**
   * @description ORRUAC -2945 insert Account Share Records for Organizations
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param newItems map<id, Sobject>
   * @return void
   **/
  public
  static void insertAccountSharesForOrg(map<id, Sobject> newItems) {
    set<id> accountIds = new Set<id>();
    List<AccountShare> lstAccountShareToInsert = new list<AccountShare>();
    map<id, id> mapAccountToParent = new map<id, id>();
    // requery Account Team Members to get parent info
    list<AccountTeamMember> lstAccountTeamMems =
        queriedAccountTeamMembers(newItems, idOrgRecordType);
    map<String, String> mapUserParentIncomingAccessLevel = new map<String, String>();
    set<id> setParentAccountIds = new set<id>();
    set<id> setUserIds = new set<id>();
    if (lstAccountTeamMems != null && !lstAccountTeamMems.isEmpty()) {
      for (AccountTeamMember aTm : lstAccountTeamMems) {
        setParentAccountIds.add(aTm.Account.Parentid);
        setUserIds.add(aTm.UserId);
        mapAccountToParent.put(aTm.AccountId, aTm.Account.parentid);
        mapUserParentIncomingAccessLevel.put(
            aTm.UserId + '_' + aTm.Account.Parentid, aTm.AccountAccessLevel);
      }
      // Query existing share records
      list<AccountShare> lstAccountShareRecords =
          queriedAccountShares(setParentAccountIds, idOrgRecordType, setUserIds);
      map<String, String> mapExistingAccessLevels = new map<String, String>();
      if (lstAccountShareRecords != null && !lstAccountShareRecords.isEmpty()) {
        for (AccountShare objAccountShare : lstAccountShareRecords) {
          mapExistingAccessLevels.put(
              objAccountShare.UserOrGroupId + '_' + objAccountShare.Accountid,
              objAccountShare.AccountAccessLevel);
        }
      }
      for (AccountTeamMember aT : lstAccountTeamMems) {
        if (mapExistingAccessLevels.containsKey(aT.UserId + '_' + aT.Account.Parentid)
            && mapExistingAccessLevels.get(aT.UserId + '_' + aT.Account.Parentid) != null) {
          String existingAccessLevel =
              mapExistingAccessLevels.get(aT.UserId + '_' + aT.Account.Parentid);
          String currentAccessLevel =
              mapUserParentIncomingAccessLevel.get(aT.UserId + '_' + aT.Account.Parentid);
          // if exisiting access is higher/same do not create share records
          if ((existingAccessLevel.equals('Edit') && currentAccessLevel.equals('Read'))
              || (existingAccessLevel.equals(currentAccessLevel))) {
            continue;
          }
        }
        if (mapAccountToParent.containsKey(aT.AccountId)
            && mapAccountToParent.get(aT.AccountId) != null) {
          AccountShare objAccountShare = getAccountShareRecord(mapAccountToParent.get(aT.AccountId),
              aT.UserId,
              aT.AccountAccessLevel,
              aT.CaseAccessLevel,
              aT.ContactAccessLevel,
              'Manual');
          lstAccountShareToInsert.add(objAccountShare);
        }
      }
      // call future method to create share records
      if (!lstAccountShareToInsert.isEmpty()) {
        asyncCreateAccountShareRecs(JSON.serialize(lstAccountShareToInsert));
      }
    }
  }
  /**
   * @description ORRUAC -2945 Future method to insert Account Share records
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param strSerializedList List of new records
   * @return void
   **/
  @Testvisible @future private static void asyncCreateAccountShareRecs(String strSerializedList) {
    List<AccountShare> listDeserialized =
        (List<AccountShare>) JSON.deserialize(strSerializedList, List<AccountShare>.class);
    try {
      if(!listDeserialized.isEmpty()) {
        insert listDeserialized;
      }
    } catch (DMLException e) {
      system.debug('Exception ' + e.getMessage());
      UAC_errorLog.platformEventErrorLog(
          e.getMessage(),'', 'asyncCreateAccountShareRecs', e.getStackTraceString());
      throw new UAC_errorLog.CustomException('Account Share Creation Failed ');
    }
  }
  /**
   * @description ORRUAC -2945 Method to get AccountShare construct
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param Id accountId
   * @param Id userId
   * @param String accountAccessLevel
   * @param String caseAccessLevel
   * @param String contactAccessLevel
   * @param String rowCause
   * @return void
   **/
  @Testvisible private static AccountShare getAccountShareRecord(Id accountId,
      Id userId,
      String accountAccessLevel,
      String caseAccessLevel,
      String contactAccessLevel,
      String rowCause) {
    AccountShare objAccountShare = new AccountShare();
    objAccountShare.AccountId = accountId;
    objAccountShare.UserOrGroupId = userId;
    objAccountShare.AccountAccessLevel = accountAccessLevel;
    objAccountShare.CaseAccessLevel = caseAccessLevel;
    objAccountShare.ContactAccessLevel = contactAccessLevel;
    objAccountShare.OpportunityAccessLevel = 'None';
    objAccountShare.RowCause = rowCause;

    return objAccountShare;
  }
  /**
   * @description ORRUAC -2945 Delete Account Share Records for Organizations
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param oldItems map<id, Sobject>
   * @return void
   **/
  public
  static void deleteAccountSharesForOrg(Map<Id, Sobject> oldItems) {
    set<id> setAccountIds = new set<id>();
    set<id> setUserIds = new set<id>();
    Map<String, String> mapUserAccountKeyMap = new map<String, String>();
    list<AccountTeamMember> lstAccountTeamMems =
        queriedAccountTeamMembers(oldItems, idOrgRecordType);
    set<id> setParentAccountIds = new set<id>();
    if (lstAccountTeamMems != null && !lstAccountTeamMems.isEmpty()) {
      for (AccountTeamMember aTm : lstAccountTeamMems) {
        setParentAccountIds.add(aTm.Account.Parentid);
        setUserIds.add(aTm.UserId);
      }
      list<AccountShare> lstAccountShareRecordsToBeDeleted =
          queriedAccountShares(setParentAccountIds, idOrgRecordType, setUserIds);
      if (lstAccountShareRecordsToBeDeleted != null
          && !lstAccountShareRecordsToBeDeleted.isEmpty()) {
        asyncDeleteAccountShareRecs(JSON.serialize(lstAccountShareRecordsToBeDeleted));
      }
    }
  }
  /**
   * @description ORRUAC -2945 Future method to delete Account Shares
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param strSerializedList List of new records
   * @return void
   **/
  @Testvisible @future private static void asyncDeleteAccountShareRecs(String strSerializedList) {
    List<AccountShare> listDeserialized =
        (List<AccountShare>) JSON.deserialize(strSerializedList, List<AccountShare>.class);
    try {
      if(!listDeserialized.isEmpty()) {
        delete listDeserialized;
      }
    } catch (DMLException e) {
      system.debug('Exception ' + e.getMessage());
      UAC_errorLog.platformEventErrorLog(
          e.getMessage(),'', 'asyncDeleteAccountShareRecs', e.getStackTraceString());
      throw new UAC_errorLog.CustomException('Account Share Deletion Failed ');
    }
  }
  /**
   * @description ORRUAC -2945 query Account Team Members
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param strSerializedList List of new records
   * @return void
   **/
  @Testvisible private static List<AccountTeamMember> queriedAccountTeamMembers(
      Map<id, Sobject> items, Id idRecordType) {
    return [
      select id,
      AccountId,
      UserId,
      AccountAccessLevel,
      CaseAccessLevel,
      ContactAccessLevel,
      Account.ParentId,
      Account.Parent.RecordTypeId from AccountTeamMember where Account.ParentId != null
          and Account.Parent.RecordTypeId =:idRecordType and id
                                         in:items.keyset()
    ];
  }
  /**
   * @description ORRUAC -2945 query Account Share Records
   * @author Sarang Padhye (Deloitte) | 10/20/2020
   * @param strSerializedList List of new records
   * @return void
   **/
  @Testvisible private static List<AccountShare> queriedAccountShares(
      set<Id> setAccountIds, Id idRecordType, set<id> setUserIds) {
    return [
      select id,
      Account.RecordType.DeveloperName,
      Accountid,
      AccountAccessLevel,
      UserOrGroupId from AccountShare where Accountid
      in:setAccountIds and UserOrGroupId
       =:setUserIds and RowCause = 'Manual' and Account.RecordTypeId
       =:idRecordType
    ];
  }
   /**
   * @description ORRUAC - 5786 method to delete SIR Share records whwne accountteam members are deleted
   * @author Vaibhav Kudesia (Deloitte) | 04/16/2021
   * @param List<AccountTeamMember> List of records deleted
   * @return void
   **/    
    public
    static void deleteSIRShareRecs(List<AccountTeamMember> newItems){
        list<Id> lstTeamMemberId = new List<Id>(); 
        list<Id> lstAccountId = new List<Id>();
        for (AccountTeamMember atmCurrent : newItems) {
            lstTeamMemberId.add(atmCurrent.UserId);
            lstAccountId.add(atmCurrent.AccountId);
    	}
        Map<Id,UAC_sir__c> mapSIR = new Map<ID, UAC_sir__c>([Select Id, OwnerId from UAC_sir__c where UAC_uaclookup__r.UAC_program__c =: lstAccountId]);
        list<UAC_sir__Share> lstSIRShare = [Select Id, ParentId from UAC_sir__Share where ParentId =: mapSIR.keySet() AND UserOrGroupId =: lstTeamMemberId AND RowCause = 'Manual'];
        if (lstSIRShare != null && !lstSIRShare.isEmpty()) {
        	asyncDeleteSIRShareRecs(JSON.serialize(lstSIRShare));
        }
    } 
   /**
   * @description ORRUAC - 5786 Future method to delete SIR Share records
   * @author Vaibhav Kudesia (Deloitte) | 04/16/2021
   * @param strSerializedList List of new records
   * @return void
   **/
      @Testvisible @future private static void asyncDeleteSIRShareRecs(String strSerializedList) {
        List<UAC_sir__Share> listDeserialized =
            (List<UAC_sir__Share>) JSON.deserialize(strSerializedList, List<UAC_sir__Share>.class);
        try {
          if(!listDeserialized.isEmpty()) {
            delete listDeserialized;
          }
        } catch (DMLException e) {
          system.debug('Exception ' + e.getMessage());
          UAC_errorLog.platformEventErrorLog(
              e.getMessage(),'', 'asyncDeleteSIRShareRecs', e.getStackTraceString());
          throw new UAC_errorLog.CustomException('SIT Share Deletion Failed ');
        }
      }
   /**
   * @description Invocable method to create SIR Share related to Program
   * @author Vaibhav Kudesia (Deloitte) | 04/20/2021
   * @param List<String>
   * @return List<List<UAC_sir__c>>
   **/  
    @InvocableMethod(label = 'Create SIR Share') 
    public static List<List<UAC_sir__share>> querySIRList(List<FlowInputs> flowinput) {
      List<List<UAC_sir__share>> itemListList = new List<List<UAC_sir__share>>();    
      Map<String,List<UAC_sir__share>> mapSIRList = new Map<String,List<UAC_sir__share>>();
      Map<String,List<String>> Flowinputmap = new Map<String,List<String>>();   
        //system.debug('####'+flowinput);
      for(FlowInputs flIN  : flowinput){            
          Flowinputmap.put(flIN.listInputString,flIN.shareContactIds);
      }
        //system.debug('####@@@@'+Flowinputmap.keyset());
      for(UAC_sir__c objSIR : [Select Id, OwnerId, UAC_uaclookup__r.UAC_program__c, UAC_status__c from UAC_sir__c where UAC_uaclookup__r.UAC_program__c =: Flowinputmap.keyset() AND UAC_status__c =: Label.UAC_sirSubmitStatuses.split(',')]){
          List<UAC_sir__share> lstSIR = new List<UAC_sir__share>();
          if(mapSIRList.keyset().contains(objSIR.UAC_uaclookup__r.UAC_program__c)){
             lstSIR = mapSIRList.get(objSIR.UAC_uaclookup__r.UAC_program__c);
          }                 
             for(String UserId : Flowinputmap.get(objSIR.UAC_uaclookup__r.UAC_program__c)){
                 UAC_sir__Share ObjSIRShare = new UAC_sir__Share();
                 ObjSIRShare.AccessLevel = 'Read';
                 ObjSIRShare.RowCause = 'Manual';
                 ObjSIRShare.ParentId = objSIR.Id;
                 ObjSIRShare.UserOrGroupId = UserId;
                 lstSIR.add(ObjSIRShare); 
              }          
          mapSIRList.put(objSIR.UAC_uaclookup__r.UAC_program__c,lstSIR);
       }
      List<UAC_sir__share> finalSIRshareList = new List<UAC_sir__share>();
      for(FlowInputs flIN  : flowinput){          
        itemListList.add(mapSIRList.get(flIN.listInputString));
          if(mapSIRList.keyset().contains(flIN.listInputString)){  
        	finalSIRshareList.addAll(mapSIRList.get(flIN.listInputString));  
          }
      }    
    	Database.SaveResult[] listSr = Database.insert(finalSIRshareList, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : listSr) {
          if (!sr.isSuccess()) {
            // Operation failed, so get all errors
            for (Database.Error err : sr.getErrors()) {
              system.debug('Error Fields :' + err.getFields() + ' Error Msg :' + err.getMessage()
                  + ' Error StatusCode :' + err.getStatusCode());  
                UAC_errorLog.platformEventErrorLog(
                  err.getStatusCode() + ': ' + err.getMessage(),'',
                  'SIR Share',
                  'Fields that Caused error : ' + err.getFields());
            }
          }
        }
               
      return itemListList;
	}
    public class FlowInputs{    
        @InvocableVariable
        public string listInputString;
        
        @InvocableVariable
        public List<string> shareContactIds;        
    }
}