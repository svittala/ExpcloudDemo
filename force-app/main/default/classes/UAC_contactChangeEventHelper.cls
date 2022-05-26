/**
 * @File Name          : UAC_contactChangeEventHelper.cls
 * @Description        : Helper method for UAC_contactChangeEventTrigger
 *
 * @Author             : Sarang Padhye (Deloitte)
 * @Modification Log   :
 * Ver      	Date           	Author      		       		Modification
 * 1.0    		8/20/2020  		Sarang Padhye (Deloitte)     	Initial Version- ORRUAC-2020
 * 2.0    		9/04/2020  		Nithin Malla (Deloitte)     	Adding SIR Sharing Visibility on Contact Change
 **/

public
without sharing class UAC_contactChangeEventHelper {
  private
  static final String strProgramContactApiName = 'UAC_program__c';
  static final String strStatusContactApiName = 'UAC_status__c';
  private
  static final String strLeadCaseManagerRoleName = label.UAC_accountTeamRoleLCM;
  static final String strLeadClinicianRoleName = label.UAC_accountTeamRoleLC;
  static final String strProgramDirectorRoleName = label.UAC_accountTeamRolePD;
  static final String strMedicalCoordinatorRoleName = label.UAC_accountTeamRoleMC;
  static final String strVolagUserRoleName = 'VOLAG User';
  private
  static final String STR_NOC_RECORD_TYPE = Label.UAC_caseRecordTypeNOC;
  private
  static final String STR_NOC_SA_TYPE = 'Sexual Abuse Hotline';
  private
  static final String STR_Referral_RECORD_TYPE = Label.UAC_caseRecordTypeApiNameUACReferral;

  /**
   * @description Method to handle UPDATE event .
   * @author Sarang Padhye (Deloitte) | 8/20/2020
   * @return void
   **/
 public
  static void handleUpdateChangeEvent(
      List<ContactChangeEvent> updateEventChanges) {
      handlecontactChangeEvent(updateEventChanges);
  }
  /**
   * @description Method to process Account Teams
   * @author Vaibhav Kudesia (Deloitte) | 8/28/2020
   * @return void
   **/
  public
  static void handlecontactChangeEvent(List<ContactChangeEvent> updateEventChanges) {      
      Map<String, String> contactProgramMap = new Map<String, String>();
      Map<String, String> contactStatusMap = new Map<String, String>();
      for (ContactChangeEvent change : updateEventChanges) {
      EventBus.ChangeEventHeader header = change.ChangeEventHeader;
      // Detect the change
      String programValue = (String) change.get(strProgramContactApiName);
      String statusValue = (String) change.get(strStatusContactApiName);

      if (programValue != null) {
        List<String> recordIds = header.getRecordIds();
        for (String contactId : recordIds) {
          // Populate map
          contactProgramMap.put(contactId, programValue);
        }
      }
        if (statusValue != null) {
        List<String> recordIds = header.getRecordIds();
        for (String contactId : recordIds) {
          // Populate map
          contactStatusMap.put(contactId, statusValue);
        }
        }
    }
      if (!contactProgramMap.isEmpty() && contactProgramMap != null) {
        handleAccountTeams(contactProgramMap);
        try {
          handleSIRShareOnUACProgramChange(contactProgramMap);
        } catch (Exception e) {
          UAC_errorLog.platformEventErrorLog(
              e.getMessage(),'', 'Contact Change Event Trigger', e.getStackTraceString());
        }
    }
    if (!contactStatusMap.isEmpty() && contactStatusMap != null) {
      handleContactStatusChange(contactStatusMap);      
      }
  }
   /**
   * @description Method to process Account Teams
   * @author Vaibhav Kudesia (Deloitte) | 8/28/2020
   * @return void
   **/
  public
  static void handleSIRShareOnUACProgramChange(Map<String, String> contactProgramMap) {   
      list<String> lstProgramStaffRole = Label.UAC_programStaffRoleList.split(',');
      list<String> lstProgramStaffRoleforPerpetrator = Label.UAC_programStaffRoleListforPerpetrator.split(',');
      Set<String> programIdSet = new set<String>();
      // Get Program(Account) ids
      for (String s : contactProgramMap.keySet()) {
        programIdSet.add(contactProgramMap.get(s));
      }

      Map<String, List<AccountTeamMember>> programToAccountTeamMemberMap =
          new Map<String, List<AccountTeamMember>>();

      // Query Account Team Members
      Map<Id, AccountTeamMember> accountTeamMembersMap = new Map<Id, AccountTeamMember>([select id, AccountId, AccountAccessLevel, CaseAccessLevel, 
                                                                                         OpportunityAccessLevel, ContactAccessLevel, TeamMemberRole, UserId 
                                                                                         from AccountTeamMember where AccountId =: programIdSet AND TeamMemberRole =: lstProgramStaffRole]);
      
       // Populate Map Program = Account Team Members
      if (!accountTeamMembersMap.isEmpty() && accountTeamMembersMap != null) {
        for (Id aT : accountTeamMembersMap.keySet()) {
          if (programToAccountTeamMemberMap.containsKey(accountTeamMembersMap.get(aT).AccountId)) {
            List<AccountTeamMember> accTeamMem =
                programToAccountTeamMemberMap.get(accountTeamMembersMap.get(aT).AccountId);
            accTeamMem.add(accountTeamMembersMap.get(aT));
            programToAccountTeamMemberMap.put(accountTeamMembersMap.get(aT).AccountId, accTeamMem);
          } else {
            programToAccountTeamMemberMap.put(accountTeamMembersMap.get(aT).AccountId,
                new List<AccountTeamMember>{accountTeamMembersMap.get(aT)});
          }
        }
      }
      
    set<Id> setSIRforDeleteShare = new set<Id>();   
	Map<Id,UAC_sir__c> mapOFSIRToCreate = new Map<Id,UAC_sir__c>();
    list<UAC_sir__Share> lstSIRSharetoCreate = new list<UAC_sir__Share>();
	for(UAC_sir__c ObjSIR : [Select id, UAC_allegedPerpetrator__c, UAC_uaclookup__r.UAC_program__c from UAC_sir__c where UAC_uaclookup__r.UAC_program__c =: programToAccountTeamMemberMap.keyset() 
                             AND UAC_uaclookup__c =: contactProgramMap.keySet() AND UAC_status__c =: Label.UAC_sirSubmitStatuses.split(',')]){
		//Add SIR to set to search for existing Share records and remove them
        	setSIRforDeleteShare.add(ObjSIR.Id);

        //Collect new Share records to create for each SIR
        for(AccountTeamMember ObjATM : programToAccountTeamMemberMap.get(ObjSIR.UAC_uaclookup__r.UAC_program__c)){
            if(ObjSIR.UAC_allegedPerpetrator__c != null && ObjSIR.UAC_allegedPerpetrator__c.contains(Label.UAC_programStaff) && lstProgramStaffRoleforPerpetrator.contains(ObjATM.TeamMemberRole)){
                lstSIRSharetoCreate.add(createSIRShareRecord(ObjSIR.Id,ObjATM.UserId,'Read'));
        }
            else if((ObjSIR.UAC_allegedPerpetrator__c != null && !ObjSIR.UAC_allegedPerpetrator__c.contains(Label.UAC_programStaff)) || ObjSIR.UAC_allegedPerpetrator__c == null){
                lstSIRSharetoCreate.add(createSIRShareRecord(ObjSIR.Id,ObjATM.UserId,'Read'));
            }
			
			if(ObjATM.TeamMemberRole=='Program Director' && !mapOFSIRToCreate.containsKey(ObjSIR.Id)){
                mapOFSIRToCreate.put(ObjSIR.Id, new UAC_sir__c(Id=ObjSIR.Id, OwnerId=ObjATM.UserId));
            }
        }
     } 
          
	List<UAC_sir__Share> lstSIRSharetoDelete = [Select Id,AccessLevel,RowCause,ParentId,UserOrGroupId from UAC_sir__Share where ParentId =: setSIRforDeleteShare AND RowCause = 'Manual'];
    
      try {
      	//Delete Existing Share Records
          if(!lstSIRSharetoDelete.isEmpty()){
              delete lstSIRSharetoDelete;
          } 
		  
		  //Updating SIR Ownership to Program Director's associated to that Program
          if(!mapOFSIRToCreate.values().isEmpty()){
              update mapOFSIRToCreate.values();
          }
		  
		  
    	//Create New Share Records  
          if(!lstSIRSharetoCreate.isEmpty()){
              List<Database.SaveResult> lstSaveResult = Database.insert(lstSIRSharetoCreate,false);
              // Inspect Share result 
              for (Database.SaveResult objSaveResult : lstSaveResult) {
              	if (!objSaveResult.isSuccess()) {
              		for(Database.Error objError : objSaveResult.getErrors()) {                        
              			if(objError.getMessage() != 'insufficient access rights on cross-reference id'){
                        	UAC_errorLog.platformEventErrorLog(objError.getMessage(),'', 'Contact Change Event Trigger','');  
                        }
                    }
                }
              }            
          } 
    } catch (DMLException e) {
      UAC_errorLog.platformEventErrorLog(
          e.getMessage(),'', 'Contact Change Event Trigger', e.getStackTraceString());
      throw new UAC_errorLog.CustomException('SIR Share Records Insert/Delete Failed');
    }
  }
  /**
   * @description Method to create SIR share for Account Teams
   * @author Vaibhav Kudesia (Deloitte) | 8/28/2020
   * @return void
   **/
  public
  static UAC_sir__Share createSIRShareRecord(Id SIRID, Id USERGROUPID, String ACCESSLEVEL){
      UAC_sir__Share ObjSIRShare = new UAC_sir__Share();
      	ObjSIRShare.AccessLevel = ACCESSLEVEL;
        ObjSIRShare.RowCause = 'Manual';
        ObjSIRShare.ParentId = SIRID;
        ObjSIRShare.UserOrGroupId = USERGROUPID;
      return ObjSIRShare;
  }
  /**
   * @description Method to process Account Teams
   * @author Sarang Padhye (Deloitte) | 8/20/2020
   * @return void
   **/
 public
  static void handleAccountTeams(Map<String, String> contactProgramMap) {
    Set<String> contactIds = new Set<String>();
    // populate contact = Program Map
    if (!contactProgramMap.isEmpty() && contactProgramMap != null) {
      contactIds = contactProgramMap.keySet();

      // query Family Group
      Map<ID, Contact> contactMap = new Map<ID, Contact>([SELECT Id,
        AccountId,
        (SELECT Id,
            OwnerId FROM Cases WHERE((RecordType.DeveloperName =
                                          : STR_NOC_RECORD_TYPE AND UAC_allowNOCTeamMembers__c =
                                                true) OR(RecordType.DeveloperName !=
                                                         : STR_NOC_RECORD_TYPE)))
            FROM Contact WHERE Id IN:contactIds]);

      Map<String, String> contactToEntityMap = new Map<String, String>();

      // Populate contact = Family Group Map
      for (Id cId : contactMap.keySet()) {
        contactToEntityMap.put(cId, contactMap.get(cId).AccountId);
      }

      Set<String> programIdSet = new set<String>();

      // Get Program(Account) ids
      for (String s : contactProgramMap.keySet()) {
        programIdSet.add(contactProgramMap.get(s));
      }

      Map<String, List<AccountTeamMember>> programToAccountTeamMemberMap =
          new Map<String, List<AccountTeamMember>>();

      // Fetch Team Member Role dynamically from family Group metadata records
      List<String> rolelst = new List<String>();
      for(UAC_familyGroupTeamMembers__mdt fmgmdt:[Select Id,TeamMemberRole__c from UAC_familyGroupTeamMembers__mdt]){
        rolelst.add(fmgmdt.TeamMemberRole__c);
      }      

      // Query Account Team Members
      Map<Id, AccountTeamMember> accountTeamMembersMap = new Map<Id, AccountTeamMember>([select id,
        AccountId,
        AccountAccessLevel,
        CaseAccessLevel,
        OpportunityAccessLevel,
        ContactAccessLevel,
        TeamMemberRole,
        UserId from AccountTeamMember where AccountId =:programIdSet and TeamMemberRole IN :rolelst]);

      // Populate Map Program = Account Team Members
      if (!accountTeamMembersMap.isEmpty() && accountTeamMembersMap != null) {
        for (Id aT : accountTeamMembersMap.keySet()) {
          if (programToAccountTeamMemberMap.containsKey(
                  accountTeamMembersMap.get(aT).AccountId)) {
            List<AccountTeamMember> accTeamMem =
                programToAccountTeamMemberMap.get(
                    accountTeamMembersMap.get(aT).AccountId);
            accTeamMem.add(accountTeamMembersMap.get(aT));
            programToAccountTeamMemberMap.put(accountTeamMembersMap.get(aT).AccountId, accTeamMem);
          } else {
            programToAccountTeamMemberMap.put(
                accountTeamMembersMap.get(aT).AccountId,
                new List<AccountTeamMember>{accountTeamMembersMap.get(aT)});
          }
        }
      }

      // Transfer Account Team Members
      try {
        transferOwnershipToLCM(contactIds, contactProgramMap,
                              programToAccountTeamMemberMap, contactToEntityMap,
                              contactMap);
      } catch (Exception e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Contact Change Event Error - LCM Ownership Transfer: ', e.getStackTraceString());
      }
      
      // Transfer Account Team Members
      try {
        transferAccountTeamMembers(contactIds, contactProgramMap,
                                  programToAccountTeamMemberMap,
                                  contactToEntityMap);
      } catch (Exception e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Contact Change Event Error - Account Team Members: ', e.getStackTraceString());
      }
    }
  }

  /**
   * @description Method to transfer Ownership of Family Group ,
   * Child Cases, Contact to a Lead Case Manager
   * @author Sarang Padhye (Deloitte) | 8/20/2020
   * @return void
   **/
 public
  static void transferOwnershipToLCM(
      Set<String> contactIds, Map<String, String> contactProgramMap,
      Map<String, List<AccountTeamMember>> programToAccountTeamMemberMap,
      Map<String, String> contactToEntityMap, Map<ID, Contact> contactMap) {
    List<contact> lstContactOwnerUpdate = new List<contact>();
    List<account> lstFamGroupOwnerUpdate = new List<account>();
    List<case> lstCasesOwnerUpdate = new List<case>();
    Set<Id> setIdsToCheck = new Set<Id>();
    String targetOwnerId = '';
    Boolean flag = true;

    if (contactids == null) return;

    Map<String, String> programsToOwnerId = new Map<String, String>();

    // get map program = LCM owner
    for (String accId : programToAccountTeamMemberMap.keySet()) {
      List<AccountTeamMember> accTeamMems =
          programToAccountTeamMemberMap.get(accId);
      for (AccountTeamMember accTeamMem : accTeamMems) {
        if (accTeamMem.TeamMemberRole == strLeadCaseManagerRoleName && flag) {
          flag = false;
          programsToOwnerId.put(accId, accTeamMem.UserId);
        }
        if (!flag) break;
      }
      flag = true;
    }

    for (String contactId : contactIds) {
      // Insert new account Team members
      String programId = contactProgramMap.get(contactId);
      targetOwnerId = programsToOwnerId.get(programId);
      String EntityId = contactToEntityMap.get(contactId);
      if (String.isBlank(targetOwnerId)) {
        continue;
      }
      // Update Owner of the contact to LCM
      if (!setIdsToCheck.contains(contactId)) {
        setIdsToCheck.add(contactId);
        lstContactOwnerUpdate.add(new Contact(Id = contactId, OwnerId = targetOwnerId));
      }

      // Update Owner of the Family Group Account
      if (!setIdsToCheck.contains(EntityId)) {
        setIdsToCheck.add(EntityId);
        lstFamGroupOwnerUpdate.add(new Account(Id = EntityId, OwnerId = targetOwnerId));
      }

      // Update the child cases

      for (case c : contactMap.get(contactId).cases) {
        if (!setIdsToCheck.contains(c.Id)) {
          setIdsToCheck.add(c.Id);
          lstCasesOwnerUpdate.add(new Case(Id = c.Id, OwnerId = targetOwnerId));
        }
      }
    }
      if (!lstContactOwnerUpdate.isEmpty()) {
        updateContactOwner(lstContactOwnerUpdate);
      }

      if (!lstFamGroupOwnerUpdate.isEmpty()) {
        updateFamGroupOwner(lstFamGroupOwnerUpdate);
      }

      if (!lstCasesOwnerUpdate.isEmpty()) {
        updateCaseOwner(lstCasesOwnerUpdate);
      }
  }
  /**
   * @description Method to update Profile Owner
   * @author Sarang Padhye (Deloitte) | 8/22/2020
   * @return void
   **/
  public
  static void updateContactOwner(List<contact> lstContactOwnerUpdate) {
    if (lstContactOwnerUpdate.isEmpty()) {
      return;
    }
    Database.SaveResult[] listSr = Database.update(lstContactOwnerUpdate, false);

    // Iterate through each returned result
    for (Database.SaveResult sr : listSr) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          system.debug('Error Fields :' + err.getFields() + ' Error Msg :' + err.getMessage()
              + ' Error StatusCode :' + err.getStatusCode());
          UAC_errorLog.platformEventErrorLog(

              err.getStatusCode() + ': ' + err.getMessage(),'',
              'Contact',
              'Fields that Caused error : ' + err.getFields());
        }
      }
    }
  }
  /**
   * @description Method to process Contact Status Change
   * @author Vaibhav Kudesia (Deloitte) | 02/16/2021
   * @return void
   **/
  public
  static void handleContactStatusChange(Map<String, String> contactProgramMap) {
    Set<String> contactIds = new Set<String>();
    List<case> lstCasesOwnerUpdate = new List<case>();
    // populate contact = Program Map
    if (!contactProgramMap.isEmpty() && contactProgramMap != null) {
      contactIds = contactProgramMap.keySet();
    }
    for (Contact objContact : [SELECT Id, AccountId, UAC_status__c, (SELECT Id,
            				OwnerId, CreatedDate, RecordType.DeveloperName FROM Cases 
                            WHERE RecordType.DeveloperName =: STR_Referral_RECORD_TYPE Order by CreatedDate DESC limit 1)
            				FROM Contact WHERE Id IN:contactIds]) { 
            if(!objContact.Cases.isEmpty()){                    
    			lstCasesOwnerUpdate.add(new Case(Id = objContact.Cases[0].Id, UAC_uacStatusOfReferral__c = objContact.UAC_status__c));
            }
    }      
    if (!lstCasesOwnerUpdate.isEmpty()) {
      // update lstCasesOwnerUpdate;
      updateCaseOwner(lstCasesOwnerUpdate);
    }
}
  /**
   * @description Method to update Family Group Owner
   * @author Sarang Padhye (Deloitte) | 8/22/2020
   * @return void
   **/
  public
  static void updateFamGroupOwner(List<Account> lstFamGroupOwnerUpdate) {
    if (lstFamGroupOwnerUpdate.isEmpty()) {
      return;
    }
    Database.SaveResult[] listSr = Database.update(lstFamGroupOwnerUpdate, false);

    // Iterate through each returned result
    for (Database.SaveResult sr : listSr) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          system.debug('Error Fields :' + err.getFields() + ' Error Msg :' + err.getMessage()
              + ' Error StatusCode :' + err.getStatusCode());
          UAC_errorLog.platformEventErrorLog(

              err.getStatusCode() + ': ' + err.getMessage(),'',
              'Family Group',
              'Fields that Caused error : ' + err.getFields());
        }
      }
    }
  }
  /**
   * @description Method to update Case Owner
   * @author Sarang Padhye (Deloitte) | 8/22/2020
   * @return void
   **/
  public
  static void updateCaseOwner(List<Case> lstCasesOwnerUpdate) {
    if (lstCasesOwnerUpdate.isEmpty()) {
      return;
    }
    Database.SaveResult[] listSr = Database.update(lstCasesOwnerUpdate, false);

    // Iterate through each returned result
    for (Database.SaveResult sr : listSr) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          system.debug('Error Fields :' + err.getFields() + ' Error Msg :' + err.getMessage()
              + ' Error StatusCode :' + err.getStatusCode());
          UAC_errorLog.platformEventErrorLog(

              err.getStatusCode() + ': ' + err.getMessage(),'',
              'Case',
              'Fields that Caused error : ' + err.getFields());
        }
      }
    }
  }
  /**
   * @description Method to insert Account Team Members
   * @author Sarang Padhye (Deloitte) | 8/22/2020
   * @return void
   **/
  public
  static void createAccTeamMembers(list<AccountTeamMember> lstAccountTeamMemberToInsert) {
    if (lstAccountTeamMemberToInsert.isEmpty()) {
      return;
    }
    Database.SaveResult[] listSr = Database.insert(lstAccountTeamMemberToInsert, false);

    // Iterate through each returned result
    for (Database.SaveResult sr : listSr) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          system.debug('Error Fields :' + err.getFields() + ' Error Msg :' + err.getMessage()
              + ' Error StatusCode :' + err.getStatusCode());
          UAC_errorLog.platformEventErrorLog(

              err.getStatusCode() + ': ' + err.getMessage(),'',
              'Account Team Member',
              'Fields that Caused error : ' + err.getFields());
        }
      }
    }
  }
  /**
   * @description Method to transfer Account Team members from
   * Update Program to the Contacts Family Group Account
   * @author Sarang Padhye (Deloitte) | 8/20/2020
   * @return void
   **/
  public
  static void transferAccountTeamMembers(Set<String> contactIds,
      Map<String, String> contactProgramMap,
      Map<String, List<AccountTeamMember>> programToAccountTeamMemberMap,
      Map<String, String> contactToEntityMap) {
    List<AccountTeamMember> lstAccountTeamMemberToInsert = new List<AccountTeamMember>();
    Map<String, UAC_familyGroupTeamMembers__mdt> mapTeamRoleToFGMdt = queryFamilyGroupMdt();
    if (contactProgramMap == null && contactProgramMap.isEmpty()) return;

    for (String contactId : contactIds) {
      // Insert new account Team members
      String programId = contactProgramMap.get(contactId);
      List<AccountTeamMember> accTeamMems = programToAccountTeamMemberMap.get(programId);
      String EntityId = contactToEntityMap.get(contactId);
      if (accTeamMems == null || accTeamMems.isEmpty()) {
        continue;
      }
      for (AccountTeamMember aT : accTeamMems) {
        AccountTeamMember newTeamMember = new AccountTeamMember();
        newTeamMember.TeamMemberRole = aT.TeamMemberRole;
        newTeamMember.AccountId = EntityId;
        newTeamMember.UserId = aT.UserId;
        if (mapTeamRoleToFGMdt.containsKey(newTeamMember.TeamMemberRole)) {
          newTeamMember.AccountAccessLevel =
              mapTeamRoleToFGMdt.get(aT.TeamMemberRole).AccountAccessLevel__c;
          newTeamMember.CaseAccessLevel =
              mapTeamRoleToFGMdt.get(aT.TeamMemberRole).CaseAccessLevel__c;
          newTeamMember.ContactAccessLevel =
              mapTeamRoleToFGMdt.get(aT.TeamMemberRole).ContactAccessLevel__c;
        }
        System.debug(newTeamMember);
        lstAccountTeamMemberToInsert.add(newTeamMember);
      }
    }
      if (!lstAccountTeamMemberToInsert.isEmpty()) {
        createAccTeamMembers(lstAccountTeamMemberToInsert);
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
}