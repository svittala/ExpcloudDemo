/**
 * @File Name          : UAC_caseTeamMemberHelper.cls
 * @Description        : ORRUAC-2022: Provides logic for the LWC uacEntryTeamMemberRelatedList
 * @Author             : James Qian (Deloitte)
 * @Group              : UAC_caseTeamMemberHelper
 */
public
without sharing class UAC_caseTeamMemberHelper {

  /**
   * @description Queries existing case team members for a given case
   * @author James Qian (Deloitte) | 08/20/2020
   * @param Id idCase
   * @return List<CaseTeamMemberWrapper>
   **/
  @AuraEnabled public static List<CaseTeamMemberWrapper> getCaseTeamMembers(Id idCase) {
    List<CaseTeamMemberWrapper> listWrapper = new List<CaseTeamMemberWrapper>();
    for (CaseTeamMember caseTeamMemberQueried : [SELECT Id,
           MemberId,
           Member.Name,
           TeamRole.Name,
           TeamRole.AccessLevel FROM CaseTeamMember WHERE ParentId =:idCase]) {
      listWrapper.add(new CaseTeamMemberWrapper(caseTeamMemberQueried.Id,
          caseTeamMemberQueried.Member.Name,
          '/' + caseTeamMemberQueried.MemberId,
          caseTeamMemberQueried.TeamRole.Name,
          caseTeamMemberQueried.TeamRole.AccessLevel == 'Edit' ? 'Read/Write' : 'Read Only'));
    }
    return listWrapper;
  }

  /**
   * @description Queries all Case Team Roles and respective IDs
   * @author James Qian (Deloitte) | 08/20/2020
   * @return List<CaseTeamRole>
   **/
  @AuraEnabled public static List<CaseTeamRole> getCaseTeamRoles() {
    return [SELECT Name, Id FROM CaseTeamRole Order by Name LIMIT 10000];
  }

  /**
   * @description Creates new Case Team Member and runs extra logic
   * @author James Qian (Deloitte) | 08/20/2020
   * @param Id idUser
   * @param Id idCase
   * @param Id idRole
   * @return CaseTeamMemberRequest
   * updated for ORRUAC-2377 AC2 Piyush - 09212020
   **/
  @AuraEnabled public static CaseTeamMemberRequest createCaseTeamMember(Id idUser, Id idCase, Id idRole){
    Map<Id,CaseTeamMember> mapUserToCseTm = new map<Id,CaseTeamMember>();     
    CaseTeamMemberRequest newRequest = new CaseTeamMemberRequest();
    Id loggedSubUser = UserInfo.getUserId();
    newRequest.success = true;
    newRequest.message = 'Success';
    case objCase = [select id,recordtype.developername,recordtype.name,contactid,contact.accountid,Contact.uac_program__c,UAC_sponsor__c from Case where id =: idCase];
     Map<Id,CaseTeamRole> mapRoleIdToObj = new Map<Id,CaseTeamRole>([SELECT Id, Name, PreferencesVisibleInCSP from CaseTeamRole Limit 1000]);
    //Added by Ankur - ORRUAC-2524 - Start
    
  
        if((mapRoleIdToObj.get(idRole).Name == 'Supervisor' || mapRoleIdToObj.get(idRole).Name == 'Direct Care Worker') && objCase.recordtype.developername == Label.UAC_caseRecordTypeHSPRSReferral){
            
        Contactshare ojContactShare = new Contactshare();
        ojContactShare.contactid = objCase.UAC_sponsor__c;
        ojContactShare.ContactAccessLevel   = 'Edit' ;
        ojContactShare.RowCause = 'Manual';
        ojContactShare.UserOrGroupId = idUser ;

        //Contact objContact = mapContact.get(objcase.contactid);
        Accountshare ojAccountshare = new Accountshare();
        if(objcase.contact.uac_program__c != null){
          ojAccountshare.AccountId = objcase.contact.uac_program__c;
          ojAccountshare.AccountAccessLevel = 'Read';
          ojAccountshare.CaseAccessLevel = 'None';
          ojAccountshare.ContactAccessLevel = 'None';
          ojAccountshare.OpportunityAccessLevel = 'None';
          ojAccountshare.RowCause = 'Manual';
          ojAccountshare.UserOrGroupId = iduser;
        } 
        AccountTeamMember acctTM = new AccountTeamMember();
        if(objcase.contact.Accountid != null){
          acctTM.AccountId = objcase.contact.Accountid;
          acctTM.userId = iduser;
          acctTM.AccountAccessLevel = 'Read';
          acctTM.CaseAccessLevel = 'Read';
          acctTM.ContactAccessLevel = 'Read';
          acctTM.TeamMemberRole = 'HS/PRS Primary Providers';
        }
        if(acctTM.AccountId != null) {
          insert acctTM;
        }
        if(ojAccountshare.AccountId != null){
          insert ojAccountshare;
        }
        if(ojContactShare.contactid != null)
            insert ojContactShare;
        }
        
      
      //Added by Ankur - ORRUAC-2524 - Ends      
        
    // ORRUAC-2377 AC2 - Start
    if(FeatureManagement.checkPermission('UAC_directCareWorkers') || FeatureManagement.checkPermission('UAC_supervisor')){
        system.debug('here');
      List<CaseTeamMember> lstCseTm = [Select MemberId,ParentId,TeamRoleId from CaseTeamMember where ParentId =:idCase];
     
      
      if(!lstCseTm.IsEmpty()){
        for(CaseTeamMember ctm:lstCseTm){
          mapUserToCseTm.put(ctm.MemberId,ctm);
        }        
      }
      if(!mapUserToCseTm.containsKey(idUser) && mapRoleIdToObj.get(idRole).Name != 'Supervisor' && mapRoleIdToObj.get(idRole).Name != 'Direct Care Worker' && mapUserToCseTm.containsKey(loggedSubUser)){
       
          newRequest.success = false;
          newRequest.message = String.valueOf(Label.UAC_caseTeamsPermissionError);
          return newRequest;
       
      }
      else if(!mapUserToCseTm.containsKey(idUser) && (mapRoleIdToObj.get(idRole).Name == 'Supervisor' || mapRoleIdToObj.get(idRole).Name == 'Direct Care Worker')){
        if(mapUserToCseTm.containsKey(loggedSubUser)){
          
            List<Contact> lstContactlogged = [Select UAC_subcontractor__c from Contact where UAC_userName__c =:loggedSubUser and
                                  RecordType.DeveloperName = 'UAC_HSPRSSubcontractors' limit 1];
            if(lstContactlogged.isEmpty()){
                newRequest.success = false;
                newRequest.message = String.valueOf(Label.UAC_caseTeamsPermissionError);
                return newRequest;
            }
            Map<Id,Contact> mapUserContact= new Map<Id,Contact>();
            for(Contact objContact: [Select Id,Name,UAC_subcontractor__c,UAC_userName__c from Contact where  RecordType.DeveloperName = 'UAC_HSPRSSubcontractors' and UAC_subcontractor__c = :lstContactlogged[0].UAC_subcontractor__c]){
                mapUserContact.put(objContact.UAC_userName__c,objContact);
            }
            if(!mapUserContact.containsKey(idUser)){
                newRequest.success = false;
                newRequest.message = String.valueOf(Label.UAC_caseTeamsPermissionError);
                return newRequest;
            }
          
       
        }
      }
    }
    // ORRUAC-2377 AC2 End
    else if(!FeatureManagement.checkPermission('UAC_manageCaseTeams') || !checkRecordAccess('Edit', idCase)){
      newRequest.success = false;
      newRequest.message = Label.UAC_caseTeamsPermissionError;
      return newRequest;
    }
    Savepoint savepointNew = Database.setSavepoint();
    try{
      if(objCase.recordtype.developername != Label.UAC_caseRecordTypeHSPRSReferral)
        checkForParentAccountTeamMembership(idUser, idCase, mapRoleIdToObj.get(idRole).Name);
      //if(objCase.recordtype.developername != Label.UAC_caseRecordTypeHSPRSReferral) // Commented by Manoj
      insert new CaseTeamMember(MemberId = idUser, ParentId = idCase, TeamRoleId = idRole);
    } catch(DMLException e){
      Database.rollback(savepointNew);
      newRequest.success = false;
      newRequest.message = e.getMessage().substringAfter('first error: ');
    }
    return newRequest;
  }

  /**
   * @description Deletes Case Team Member
   * @author James Qian (Deloitte) | 08/20/2020
   * @param Id idCaseTeamMember
   * @return CaseTeamMemberRequest
   **/
  @AuraEnabled public static CaseTeamMemberRequest deleteCaseTeamMember(Id idCaseTeamMember, Id idCase) {
    CaseTeamMemberRequest newRequest = new CaseTeamMemberRequest();
    newRequest.success = true;
    newRequest.message = 'Success';
    if (!FeatureManagement.checkPermission('UAC_manageCaseTeams') || !checkRecordAccess('Edit', idCase)) {
      newRequest.success = false;
      newRequest.message = Label.UAC_caseTeamsPermissionError;
      return newRequest;
    }
    try {
      delete new CaseTeamMember(Id = idCaseTeamMember);
    } catch (DMLException e) {
      newRequest.success = false;
      newRequest.message = e.getMessage().substringAfter('first error: ');
    }
    return newRequest;
  }

  /**
   * @description Creates an Account Team Member if one does not already exist
   * @author James Qian (Deloitte) | 08/20/2020
   * @param Id idUser
   * @param Id idCase
   * @param String strRole
   * @return void
   **/
  private
  static void checkForParentAccountTeamMembership(Id idUser, Id idCase, String strRole) {
    Case queriedCase =
        [SELECT Contact.AccountId, RecordType.DeveloperName FROM Case WHERE Id =:idCase];
    Id idAccount;
    if (String.isBlank(queriedCase.Contact.AccountId)) {
      return;
    } else {
      idAccount = queriedCase.Contact.AccountId;
    }
    List<AccountTeamMember> listQueriedAccountTeamMembers = [
      SELECT Id,
      ContactAccessLevel,
      CaseAccessLevel FROM AccountTeamMember WHERE AccountId =:idAccount AND UserId
                                                                =:idUser
    ];
    if (listQueriedAccountTeamMembers != null && !listQueriedAccountTeamMembers.isEmpty()) {
      AccountTeamMember teamMemberToUpdate = listQueriedAccountTeamMembers[0];
      Boolean boolUpdate = false;
      if (queriedCase.RecordType.DeveloperName == Label.UAC_caseRecordTypeAdmission) {
        if (teamMemberToUpdate.ContactAccessLevel != 'Edit') {
          teamMemberToUpdate.ContactAccessLevel = 'Edit';
          boolUpdate = true;
        }
        if (strRole == Label.UAC_caseTeamRoleNameCM
            && teamMemberToUpdate.CaseAccessLevel != 'Edit') {
          teamMemberToUpdate.CaseAccessLevel = 'Edit';
          boolUpdate = true;
        }
      } else if (teamMemberToUpdate.ContactAccessLevel != 'Read'
          && teamMemberToUpdate.ContactAccessLevel != 'Edit') {
        teamMemberToUpdate.ContactAccessLevel = 'Read';
        boolUpdate = true;
      }
      if (boolUpdate && teamMemberToUpdate != null) {
        update teamMemberToUpdate;
      }
    } else {
      String strCaseAccessLevel = 'None';
      String strContactAccessLevel = 'Read';
      if (queriedCase.RecordType.DeveloperName == Label.UAC_caseRecordTypeAdmission) {
        strContactAccessLevel = 'Edit';
        if (strRole == Label.UAC_caseTeamRoleNameCM) {
          strCaseAccessLevel = 'Edit';
        }
      }
      insert new AccountTeamMember(AccountId = idAccount,
          UserId = idUser,
          AccountAccessLevel = 'Read',
          ContactAccessLevel = strContactAccessLevel,
          CaseAccessLevel = strCaseAccessLevel,
          TeamMemberRole = Label.UAC_caseTeamRoleNameRead);
    }
  }  
  /**
   * @description Checks permissions on the parent record before carrying out operations
   * @author Chaitanya nandamuri (Deloitte) | 11/24/2020
   * @param String strOperation
   * @param Id idRecord
   * @return Boolean
   **/
  private
  static Boolean checkRecordAccess(String strOperation, Id idRecord) {
    UserRecordAccess objAccessLevel = [
      select RecordId,
      HasEditaccess,
      HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId
                                                       =:idRecord
    ];
    Case objCase = [SELECT RecordType.DeveloperName FROM case WHERE Id =:idRecord];
    if (strOperation == 'Edit' && objAccessLevel.HasEditaccess) {
      return true;
    }
    return false;
  }


  /**
   * @description Inner class for displaying URLs in datatable
   * @author James Qian (Deloitte) | 08/20/2020
   **/
  @TestVisible private without sharing class CaseTeamMemberWrapper {
    @AuraEnabled public Id idRecord;
    @AuraEnabled public String strMemberName;
    @AuraEnabled public String strMemberURL;
    @AuraEnabled public String strRole;
    @AuraEnabled public String strAccessLevel;

    private
    CaseTeamMemberWrapper(Id idRecordInput,
        String strMemberNameInput,
        String strMemberURLInput,
        String strRoleInput,
        String strAccessLevelInput) {
      idRecord = idRecordInput;
      strMemberName = strMemberNameInput;
      strMemberURL = strMemberURLInput;
      strRole = strRoleInput;
      strAccessLevel = strAccessLevelInput;
    }
  }

  /**
   * @description Inner class for handling errors and returning to LWC
   * @author James Qian (Deloitte) | 08/20/2020
   **/
  @TestVisible private without sharing class CaseTeamMemberRequest {
    @AuraEnabled public String message;
    @AuraEnabled public Boolean success;
  }
}