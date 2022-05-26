/**
 * @File Name          : UAC_contactTriggerHelper.cls
 * @Description        : Helper method for UAC_contactTriggerHandler
 * @Author             : Chaitanya Nandamuri (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/29/2020, 3:06:47 PM
 * @Modification Log   :
 * Ver       Date            Author      		             Modification
 * 1.0    5/13/2020   Chaitanya Nandamuri (Deloitte)     Initial Version
 * 1.1    5/29/2020   Sachet Khanal (Deloitte)           Added record type id constant for Adult
 *                                                       Contact
 * 1.2    6/5/2020	  Abhisek Pati (Deloitte)            ORRUAC-75-Added check for Account Id for
 *                                                       findUACFamilyGroup method
 * 1.3    6/22/2020	  Abhisek Pati (Deloitte)            Added new method to update A# to all 
 *                                                       child cases
 * 1.4    7/29/2020   Anupreeta Chakraborty (Deloitte)   ORRUAC-213-Added new method to create IME records on UAC status update.
 * 1.5    9/14/2020   Abhisek Pati (Deloitte)            ORRUAC-634- Added Admission date, age 
 *                                                       and discharge date to IME creation.
 * 1.6    10/06/2020   Rahul Roy (Deloitte)              ORRUAC-2913 Added new method to update 
 * 														                           values on Referral Case
 * 1.7	  11/11/2020   Satish Kota(Kvortex)				       ORRUAC-4129 Added new Method to update
 * 														                           Discharge Notification Complete field
 * 														                           Added Method to update Most Recent Program field
 * 1.8	  03/01/2021   Nithin Malla (Deloitte) 			     ORRUAC-5322 Assign Administrative Account 
 * 														                           to new Adult Contact Children
 * 1.9    06/22/2021   Abhisek Pati (Deloitte)           ORRUAC-5944 Block IME Creation for "Emergency Intake Sites" 
 **/
public
without sharing class UAC_contactTriggerHelper {

  public
  static final Id IdcontactRecordType = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName()
                                      .get('UAC_UAC')
                                      .getRecordTypeId();
  public
  static final  Id IdaccountRecordType = Schema.SObjectType.account.getRecordTypeInfosByDeveloperName()
                                      .get('UAC_familyGroup')
                                      .getRecordTypeId();
  public
  static final Id ID_ADULT_CONTACT_RECORD_TYPE =
      Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contactRecordTypeApiNameAdultContact)
          .getRecordTypeId();
  public
  static final Id IdHSPRSSubcontractorRecordType = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName()
                                      .get(label.UAC_HSPRSSubcontractors)
                                      .getRecordTypeId();                                       
  public
  static final Id ID_ADULT_CONTACTS_CHILDREN_RECORD_TYPE =
      Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName()
          .get(label.UAC_adultContactsChildrenRecordType)
          .getRecordTypeId();                                     
  public
        static final String strIMERecordType = System.label.UAC_IMERectype;		  
  public
  static final String strCaseRecordTypeApiNameUACReferral = System.label.UAC_caseRecordTypeApiNameUACReferral;
  public static final String strContactAdmittedStatus = System.label.UAC_contactAdmittedStatus;
  /**
  @author       Chaitanya Nandamuri(Deloitte)
  @description  Method will check if there are any Households(Account) with matching A# number and
  Link the UAC to the Accounts found.
  @param        List of contacts
  @return       Void(None)
  */
  public
  static void findUACFamilyGroup(List<contact> lstContacts) {

    List<Contact> lstOfUACRecords = new List<Contact>();
    Set<String> setOfFamilyGroupNumber = new set<String>();
    Map<String, Id> mapOfFamilyGroupNumberToAccount = new Map<String, Id>();
    List<contact> lstofUACwithNoHouseHold = new List<contact>();

    for (Contact objContact : lstContacts) {
      if (objContact.RecordTypeId == IdcontactRecordType && objContact.AccountId == null) {
        lstOfUACRecords.add(objContact);
        if (String.isNotBlank(objContact.UAC_uipFamilyGroupNumber__c)) {
          setOfFamilyGroupNumber.add(objContact.UAC_uipFamilyGroupNumber__c);
        }
      }
    }

    for (Account objAccount : [
           SELECT Id,
           Name,
           UAC_uipFamilyGroupNumber__c FROM Account WHERE UAC_uipFamilyGroupNumber__c
           IN:setOfFamilyGroupNumber AND RecordTypeId
            =:IdaccountRecordType
         ]) {
      mapOfFamilyGroupNumberToAccount.put(objAccount.UAC_uipFamilyGroupNumber__c, objAccount.Id);
    }

    if (!mapOfFamilyGroupNumberToAccount.isEmpty()) {
      for (Contact objContact : lstOfUACRecords) {
        if (String.isNotBlank(objContact.UAC_uipFamilyGroupNumber__c)
            && mapOfFamilyGroupNumberToAccount.containsKey(
                objContact.UAC_uipFamilyGroupNumber__c)) {
          objContact.AccountId =
              mapOfFamilyGroupNumberToAccount.get(objContact.UAC_uipFamilyGroupNumber__c);
        } else {
          lstofUACwithNoHouseHold.add(objContact);
        }
      }
    }
    if (!lstOfUACRecords.isEmpty()) {
      createFamilyGroup(lstOfUACRecords);
      return;
    }
    if (!lstofUACwithNoHouseHold.isEmpty()) {
      createFamilyGroup(lstofUACwithNoHouseHold);
    }
  }

  /**
  @author       Chaitanya Nandamuri(Deloitte)
  @description  Method will create Family Group(Accounts) with Name and A# and link the UAC to the
  account.
  @param        List of Contact which has no Accounts with family group number
  @return       Void(None)
  */
  private
  static void createFamilyGroup(list<contact> lstContacts) {

    Map<String, Contact> mapOfAccNumberToContact = new Map<String, Contact>();
    List<Account> lstOfAccToInsert = new List<Account>();

    for (Contact objContact : lstContacts) {
      if (objContact.AccountId != null) {
        continue;
      }
      // Creating Account with A# number and Name from the UAC
      Account objAccount = new Account(Name = objContact.LastName + ' - Family Group',
          UAC_familyName__c = objContact.LastName.left(255),
          RecordTypeId = IdaccountRecordType,
          UAC_uipFamilyGroupNumber__c = objContact.UAC_uipFamilyGroupNumber__c,
          UAC_A__c = objContact.UAC_A__c);

      lstOfAccToInsert.add(objAccount);
      // Map of Records with KEY = A#number and values = UAC Record(Trigger.new)
      mapOfAccNumberToContact.put(objContact.UAC_A__c, objContact);
    }

    if (!lstOfAccToInsert.isEmpty()) {
      try {
        insert lstOfAccToInsert;
        // Iterate over list of created Accounts
        for (Account objAccount : lstOfAccToInsert) {
          if (mapOfAccNumberToContact.containsKey(objAccount.UAC_A__c)) {
            // Get the instance of UAC Record(Trigger.new) and Link the account based on Matching
            // A#number as Key.
            mapOfAccNumberToContact.get(objAccount.UAC_A__c).AccountId = objAccount.Id;
          }
        }
      } catch (Exception e) {
        UAC_errorLog.platformEventErrorLog(
            e.getMessage(),'', 'Contact Trigger', e.getStackTraceString());
        throw new UAC_errorLog.CustomException('Account Insertion Failed ');
      }
    }
  }
   /**
  @author       Priyanka Bolla(Deloitte)
  @description  Method to update salutation as blank value
  account.
  @param        List of contacts
  @return       Void(None)
  */
  public static void updateContactSalutation(List<Contact> lstContact) {
    for (contact objContact : lstContact) {
      objContact.Salutation = null;
    }
  }

  /**
   * @description ORRUAC-1013 - Method to Auto Populate A# on child cases
   * from Contact UAC record update
   * @author Abhisek Pati (Deloitte) | 6/22/2020
   * @param Trigger.newmap and Trigger.oldmap
   * @return void
   **/
  public
  static void populateANumOnCases(
      Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
    Set<Id> setContactIds = new Set<Id>();
    List<Case> lstCasesToUpdate = new List<Case>();

    for (Contact objContact : mapNewContacts.values()) {
      if (objContact.RecordTypeId == IdcontactRecordType
          && objContact.UAC_A__c != mapOldContacts.get(objContact.Id).UAC_A__c) {
        setContactIds.add(objContact.Id);
      }
    }
    if (setContactIds.isEmpty()) {
      return;
    }
    List<Case> LstChildCases =
        [select id, UAC_aNum__c, ContactId from case where ContactId In:setContactIds];
    if (LstChildCases != null) {
      for (case newCase : LstChildCases) {
        newCase.UAC_aNum__c = mapNewContacts.get(newCase.ContactId).UAC_A__c;
        lstCasesToUpdate.add(newCase);
      }
    }
	if(!lstCasesToUpdate.isEmpty()){
		update lstCasesToUpdate;
	}
  }

  /**
   * @description ORRUAC-5561 Logic to handle when the UAC status is "Admitted".
   * @author Nithin Malla (Deloitte) | 3/18/2021
   * @param
   * @return void
   **/
  public
  static void statusAdmittedUpdates(
      Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
          
      Set<Id> healthEvaluationSet = new Set<Id>();
      Set<Id> mentalHealthEvaluationSet = new Set<Id>();
      Set<Id> legalServiceProviderSet = new Set<Id>();

      Map<Id, String> mapContactIdtoProgramType = new Map<Id, String>();
      for (Contact con :
          [select id, UAC_program__r.Type from contact where id in:mapNewContacts.keyset()]) {
        mapContactIdtoProgramType.put(con.Id, Con.UAC_program__r.Type);
      }
      
      for (Contact objContact : mapNewContacts.values()) {
          if (objContact.UAC_status__c == Label.UAC_admittedContactStatus){
              if(objContact.RecordTypeId == IdcontactRecordType && 
                 mapOldContacts.get(objContact.Id).UAC_status__c == Label.UAC_placementDesignatedContactStatus &&
                 !(mapContactIdtoProgramType.get(objContact.Id) == Label.UAC_emergencyIntakeSiteType)) {
                  healthEvaluationSet.add(objContact.Id);
              }
              if(objContact.RecordTypeId == IdcontactRecordType && 
                      objContact.UAC_status__c != mapOldContacts.get(objContact.Id).UAC_status__c){
                  mentalHealthEvaluationSet.add(objContact.Id);
              }
              if(objContact.UAC_status__c != mapOldContacts.get(objContact.Id).UAC_status__c){
                  legalServiceProviderSet.add(objContact.Id);
              }
          }
      }
      
      UAC_asyncStatusAdmittedCreation handleStatusAdmitted = new UAC_asyncStatusAdmittedCreation(healthEvaluationSet, 
                                                                                                 mentalHealthEvaluationSet, 
                                                                                                 legalServiceProviderSet);
      system.enqueueJob(handleStatusAdmitted);
  }
  
  /**
     * @description ORRUAC-213 - Method to create Health Evaluation(IME) record when the UAC status is "Admitted".
     * @author Anupreeta Chakraborty (Deloitte) | 7/29/2020
     * @param
     * @return void
     **/
    /*public
    static void createIMEonStatusAdmitted(Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
      Set<Id> setContactIds = new Set<Id>();
      List<UAC_HealthEvaluation__c> lstIMEToInsert = new List<UAC_HealthEvaluation__c>();
      Id IMERecordTypeId = Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName().get(strIMERecordType).getRecordTypeId();
      UAC_BusinessDaysUtility bday = new UAC_BusinessDaysUtility();
      
      for (Contact objContact : [select id,
        RecordTypeId,
        UAC_status__c,
        UAC_currentAge__c,
        UAC_program__r.name,
        UAC_admissionDateforMostRecentORRStay__c,
        UAC_admissionAgeforMostRecentORRStay__c,
        UAC_dischargeDateforMostRecentORRStay__c,
        UAC_mostRecentAdmittedDateTime__c from contact where id IN:mapNewContacts.values()]){
        if(objContact.RecordTypeId == IdcontactRecordType && mapOldContacts.get(objContact.Id).UAC_status__c == Label.UAC_placementDesignatedContactStatus
         && objContact.UAC_status__c == Label.UAC_admittedContactStatus){
         //Create new IME record.
         UAC_healthEvaluation__c objIME = new UAC_healthEvaluation__c();
         objIME.recordTypeId = IMERecordTypeId;
         objIME.UAC_associatedUAC__c = objContact.id;
         objIME.UAC_IMEstatus__c = Label.UAC_statusNotStarted;         
         objIME.UAC_generalInformationStatus__c = Label.UAC_statusNotStarted;
         objIME.UAC_historyAndPhysicalAssessmentStatus__c = Label.UAC_statusNotStarted;
         objIME.UAC_statusReviewofSystemsandPhysicalExam__c = Label.UAC_statusNotStarted;
         objIME.UAC_psychosocialRiskStatus__c = Label.UAC_statusNotStarted;
         objIME.UAC_TBLabTestingStatus__c = Label.UAC_statusNotStarted;
         objIME.UAC_labTestingStatus__c = Label.UAC_statusNotStarted;
         objIME.UAC_assessmentAndPlanStatus__c = Label.UAC_statusNotStarted;
         objIME.UAC_dateReportEntered__c = System.TODAY();
         if(objContact.UAC_currentAge__c != null)         
         objIME.UAC_ageAtAdmission__c = Integer.valueOf(objContact.UAC_currentAge__c);
         objIME.UAC_lookupAssociatedProgram__c = objContact.UAC_program__c;
         if(objContact.UAC_program__c != null)
         objIME.UAC_programNameattheTimeofExam__c = objContact.UAC_program__r.name;   
         if(objContact.UAC_mostRecentAdmittedDateTime__c != null){
         DateTime dtt = bday.addDays(objContact.UAC_mostRecentAdmittedDateTime__c , Integer.valueOf(Label.UAC_daysIntervalfromAdmission)); 
         objIME.UAC_dueDate__c = dtt.dateGMT();
         }
         // Added below fields as part of ORRUC-634
        objIME.UAC_admissionDateforMostRecentORRStay__c = objContact.UAC_admissionDateforMostRecentORRStay__c;
        objIME.UAC_ageAtAdmission__c = objContact.UAC_admissionAgeforMostRecentORRStay__c;
        objIME.UAC_dischargeDateforMostRecentORRStay__c = objContact.UAC_dischargeDateforMostRecentORRStay__c;
         lstIMEToInsert.add(objIME);
}
      }
            if(!lstIMEToInsert.isEmpty()){
            try{
                insert lstIMEToInsert;
              }
              catch(Exception e){
                UAC_errorLog.logError(e.getMessage(), '', 'IME Creation failed on updating status to Admitted', e.getStackTraceString());          
              }

        } 
    }*/
  /**
   * @description ORRUAC-2133 - Method to create LSP record
   *"Admitted".
   * @author Ankur Aggarwal (Deloitte) | 8/21/2020
   * @param
   * @return void
   **/
 /*public
  static void createLegalStatusonStatusAdmitted(
      Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
    Id idLSPRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                             .get('UAC_legalServiceProviderRecord')
                             .getRecordTypeId();
    list<Case> lstLSPRecords = new list<Case>();
    list<Case> lstLSPRecordsUpdate = new list<Case>();

    map<id, Contact> mapContactLSP = new map<id, Contact>([select id,
      (select id, UAC_programFacility__c from Cases where recordtypeid =
              : idLSPRecordType) from contact where id in:mapNewContacts.keySet()]);
    for (Contact objContact : mapNewContacts.values()) {
      Contact objOldCase = mapOldContacts.get(objContact.Id);
      if (objContact.UAC_status__c != objOldCase.UAC_status__c
          && objContact.UAC_status__c == Label.UAC_admittedContactStatus) {
        Case ObjLSPRecords = new Case();
        if (mapContactLSP != null && mapContactLSP.containskey(objContact.id)
            && mapContactLSP.get(objContact.id).cases != null
            && mapContactLSP.get(objContact.id).Cases.size() > 0) {
          ObjLSPRecords = mapContactLSP.get(objContact.id).Cases[0];
          lstLSPRecordsUpdate.add(ObjLSPRecords);
        } else {
          lstLSPRecords.add(ObjLSPRecords);
        }
        ObjLSPRecords.contactid = objContact.Id;
        ObjLSPRecords.UAC_programFacility__c = objContact.UAC_program__c;
        ObjLSPRecords.recordtypeid = idLSPRecordType;
        // lstLSPRecords.add(ObjLSPRecords);
      }
    }
    system.debug(lstLSPRecords);
    system.debug(lstLSPRecordsUpdate);

    if(!lstLSPRecords.isEmpty()){
      insert lstLSPRecords;
    }
    if(!lstLSPRecordsUpdate.isEmpty()){
      update lstLSPRecordsUpdate;
	  List<String> lstUserLSP = new List<String>();
	  List<String> lstUserLSPContact = new List<String>();
	  List<String> lstUserLSPProgramFacility = new List<String>();
      map<id, case> mapLSPRecord = new map<id, case>(lstLSPRecordsUpdate);
      list<Caseteammember> lstoldCaseTeamMember =
          [select id,MemberId, parent.contactid, parent.UAC_programFacility__c  from caseteammember where parentid in:mapLSPRecord.keyset()];
	  for(Caseteammember objCaseTM: lstoldCaseTeamMember){
		 lstUserLSP.add(objCaseTM.MemberId);
		 lstUserLSPContact.add(objCaseTM.parent.contactid);
		 lstUserLSPProgramFacility.add(objCaseTM.parent.UAC_programFacility__c);
	  }
	  List<Contactshare> lstContactShareDelete= [Select id from Contactshare where contactid in : lstUserLSPContact and  UserOrGroupId in : lstUserLSP Limit 5000];
	  List<Accountshare> lstAccountShareDelete= [Select id from Accountshare where AccountId in  :lstUserLSPProgramFacility and UserOrGroupId in : lstUserLSP Limit 5000];
      if(!lstoldCaseTeamMember.isEmpty()){
        delete lstoldCaseTeamMember;
        }
	  if(!lstContactShareDelete.isEmpty()){
        delete lstContactShareDelete;
      }
	  if(!lstAccountShareDelete.isEmpty()){
        delete lstAccountShareDelete;
      }
    }
    list<case> lstfinalCases = new list<case>();

    lstfinalCases.addAll(lstLSPRecords);
    lstfinalCases.addAll(lstLSPRecordsUpdate);

    list<id> lstIdAccounts = new list<Id>();
    List<Partner> lstAccountPartner = new list<Partner>();
    map<id, id> mapAccountPartner = new map<id, id>();
    Map<id, list<Accountteammember>> mapPartnerTeamMember = new Map<id, list<Accountteammember>>();

    for (case objfinalCase : lstfinalCases) {
      if (objfinalCase.UAC_programFacility__c != null)
        lstIdAccounts.add(objfinalCase.UAC_programFacility__c);
    }
   
    if (!lstIdAccounts.isEmpty()) {
      lstAccountPartner = [select id, Accounttoid, accountfromid from Partner where accountfromid
        in:lstIdAccounts and role = : Label.UAC_LawFirm];
      for (Partner AccountPartner : lstAccountPartner) {
        mapAccountPartner.put(AccountPartner.accountfromid, AccountPartner.Accounttoid);
      }
    }

    for (case objfinalCase : lstfinalCases) {
      if (objfinalCase.UAC_programFacility__c != null
          && mapAccountPartner.containsKey(objfinalCase.UAC_programFacility__c))
        objfinalCase.accountid = mapAccountPartner.get(objfinalCase.UAC_programFacility__c);
    }
    if(!lstfinalCases.isEmpty()){
        upsert lstfinalCases;
    }
   
   	if (!mapAccountPartner.isEmpty() && mapAccountPartner.values().size() >0) {
      list<Accountteammember> lstAccountTeamMember =
          [select id, accountid, UserId, TeamMemberRole from accountteammember where accountid
            in:mapAccountPartner.values()and TeamMemberRole = :Label.UAC_Attorney];
      for (Accountteammember objAccountTeamMember : lstAccountTeamMember) {
        list<accountteammember> lstteammember = new list<accountTeamMember>();
        if (mapPartnerTeamMember.containskey(objAccountTeamMember.accountid))
          lstteammember = mapPartnerTeamMember.get(objAccountTeamMember.accountid);

        lstteammember.add(objAccountTeamMember);
        mapPartnerTeamMember.put(objAccountTeamMember.accountid, lstteammember);
      }
    }
   
    caseteamrole objAttorneyRole =
        [select id, name, AccessLevel from caseteamrole where name = :Label.UAC_Attorney];

    list<caseteammember> lstCaseTeamMember = new list<caseTeamMember>();
    list<Contactshare> lstContactShare = new list<ContactShare>();
    list<accountshare> lstAccountShare = new list<AccountShare>();
    for (case objfinalCase : lstfinalCases) {
      Id idParentId = mapAccountPartner.get(objfinalCase.UAC_programFacility__c);
      if (mapAccountPartner.containskey(objfinalCase.UAC_programFacility__c)
          && mapPartnerTeamMember.containskey(idParentId)) {
        list<accountteammember> lstteammember = mapPartnerTeamMember.get(idParentId);
        for (accountteammember objAccountteamMember : lstteammember) {
          caseteammember objCaseTeamMember = new caseteammember();
          objCaseTeamMember.MemberId = objAccountteamMember.userid;
          objCaseTeamMember.ParentId = objfinalCase.id;
          objCaseTeamMember.TeamRoleId = objAttorneyRole.id;
          lstCaseTeamMember.add(objCaseTeamMember);
		  
			Contactshare ojContactShare = new Contactshare();
			ojContactShare.contactid = objfinalCase.contactid;
			ojContactShare.ContactAccessLevel = 'Edit';
			ojContactShare.RowCause = 'Manual';
			ojContactShare.UserOrGroupId = objAccountteamMember.userid;
			lstContactShare.add(ojContactShare);

       
			Accountshare ojAccountshare = new Accountshare();
			ojAccountshare.AccountId = objfinalCase.UAC_programFacility__c;
			ojAccountshare.AccountAccessLevel = 'Read';
			ojAccountshare.CaseAccessLevel = 'None';
			ojAccountshare.ContactAccessLevel = 'None';
			ojAccountshare.OpportunityAccessLevel = 'None';
			ojAccountshare.RowCause = 'Manual';
			ojAccountshare.UserOrGroupId =  objAccountteamMember.userid;
			lstAccountShare.add(ojAccountshare);
        }
      }
    }
    
	  if(!lstCaseTeamMember.isEmpty()){ insert lstCaseTeamMember;}
	  if(!lstContactShare.isEmpty()){ insert lstContactShare;}
	  if(!lstAccountShare.isEmpty()){ insert lstAccountShare;}
  }*/
  
  /**
   * @description ORRUAC-2133 - Method to create LSP record
   *"Admitted".
   * @author Ankur Aggarwal (Deloitte) | 8/21/2020
   * @param
   * @return void
   **/
  public
  static void updateLegalStatusonProgramChange(
    Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {

      list<Case> lstLSPRecordsUpdate = new list<Case>();
      list<ID> lstIdLSPRecs = new list<id>();

      list<id> lstIdAccounts = new list<Id>();
      Set<Id> setContactsWithChangedProgram = new Set<Id>();
      for(Contact objContact : mapNewContacts.values()){
        if(objContact.UAC_program__c != mapOldContacts.get(objContact.Id).UAC_program__c && objContact.UAC_program__c != null){
            setContactsWithChangedProgram.add(objContact.Id);
        }
      }
      if (setContactsWithChangedProgram.isEmpty()) {
        return;
      }
      map<id,Contact> mapContactLSP = new map<id,Contact>([select id,(select id,UAC_programFacility__c from Cases where recordtype.DeveloperName = :Label.UAC_legalServiceProviderRecord) from contact where id in :setContactsWithChangedProgram]);
      for(Contact objContact : mapNewContacts.values()){
        if(objContact.UAC_program__c != mapOldContacts.get(objContact.Id).UAC_program__c && objContact.UAC_program__c != null){
          lstIdAccounts.add(objContact.UAC_program__c);
          for(Case objLspCase : mapContactLSP.get(objContact.id).cases){
            objLspCase.UAC_programFacility__c = objContact.UAC_program__c;
            lstIdLSPRecs.add(objLspCase.id);
            lstLSPRecordsUpdate.add(objLspCase);
          }
        }
      }
      List<Partner> lstAccountPartner = new list<Partner>();
      map<id,id> mapAccountPartner = new map<id,id>();
      Map<id,list<Accountteammember>> mapPartnerTeamMember = new Map<id,list<Accountteammember>>();  
  

      if(lstIdAccounts != null && lstIdAccounts.size() > 0){
        lstAccountPartner = [select id,Accounttoid,accountfromid from Partner where accountfromid in : lstIdAccounts and role = :  label.UAC_LawFirm];        
        for(Partner AccountPartner : lstAccountPartner){
          mapAccountPartner.put(AccountPartner.accountfromid,AccountPartner.Accounttoid);
        }
      }            
      if (!lstLSPRecordsUpdate.isEmpty()) {
        for(case objCase : lstLSPRecordsUpdate){
          if(objCase.UAC_programFacility__c != null && mapAccountPartner.containskey(objCase.UAC_programFacility__c)){
            objCase.accountid = mapAccountPartner.get(objCase.UAC_programFacility__c);
          }
          else{
            objCase.accountid = null;
          }
        }
        update lstLSPRecordsUpdate;
      }
        
      list<CaseteamMember> lstCaseTeamMemberDelete =  new list<caseteammember>();
      lstCaseTeamMemberDelete = [select id from caseteammember where parentid in :lstIdLSPRecs];
      if (!lstCaseTeamMemberDelete.isEmpty()) {
		delete lstCaseTeamMemberDelete;
	  }
    }    
/**
   * @description ORRUAC-1936
   * @author Ankur Aggarwal (Deloitte) | 8/26/2020
   * @param
   * @return void
   **/
  public
  static void assignOwnerHSPRSContractor(   list<contact> lstNewContacts){
    for(Contact objNewContact : lstNewContacts){
      if(objNewContact.recordtypeid == IdHSPRSSubcontractorRecordType)
        if(objNewContact.UAC_userName__c != null && objNewContact.UAC_userName__c != objNewContact.ownerid)
          objNewContact.ownerid = objNewContact.UAC_userName__c ;
    }
  }
   /**
   * @description ORRUAC-1936
   * @author Ankur Aggarwal (Deloitte) | 8/26/2020
   * @param
   * @return void
   **/
  public
  static void updateAcountTeamMemberSubcontractor(  Map<Id, Contact> newItems){
    map<id,Set<id>> mapAccountSubcontractor = new map<id,Set<id>>();
    
    for(Contact objNewContact : newItems.values()){
      if(objNewContact.recordtypeid == IdHSPRSSubcontractorRecordType)
        if(objNewContact.UAC_subcontractor__c != null){
          Set<id> setUserIds = new Set<id>();
          if(mapAccountSubcontractor.containskey(objNewContact.UAC_subcontractor__c))
            setUserIds = mapAccountSubcontractor.get(objNewContact.UAC_subcontractor__c);

          setUserIds.add(objNewContact.ownerid);
          mapAccountSubcontractor.put(objNewContact.UAC_subcontractor__c,setUserIds);
        }            
    }
    if (mapAccountSubcontractor.isEmpty()) {
      return;
    }
    system.debug(mapAccountSubcontractor);
    if(trigger.isupdate){
      system.debug('here');
      list<AccountTeamMember> lstAccountTeamMember = [select id,accountid,account.recordtype.developername from accountteammember where accountid in :mapAccountSubcontractor.keyset() and  account.recordtype.developername  = :label.UAC_HSPRSSubcontractors];     
      
      system.debug(lstAccountTeamMember);
      if (!lstAccountTeamMember.isEmpty()) {
        delete lstAccountTeamMember;
		}
    }
    list<Account> lstAccount = [select id,(select id,ownerid from contacts where recordtype.developername  =:label.UAC_HSPRSSubcontractors) from account where id in :mapAccountSubcontractor.keyset() and  recordtype.developername  = :label.UAC_HSPRSSubcontractors ];     
    
    system.debug(lstaccount);
    for(Account objAccount : lstAccount)
      for(Contact objContact : objAccount.contacts){
        Set<id> setUserIds = new Set<id>();
        if(mapAccountSubcontractor.containskey(objAccount.id))
          setUserIds = mapAccountSubcontractor.get(objAccount.id);

        setUserIds.add(objContact.ownerid);
        mapAccountSubcontractor.put(objAccount.id,setUserIds);
      }
      system.debug(mapAccountSubcontractor);
    list<accountteamMember> lstAccountTeamMemberInsert = new list<accountteamMember>();
    for(Id idAccount : mapAccountSubcontractor.keyset()){
      for(Id idUser : mapAccountSubcontractor.get(idAccount)){
        AccountTeamMember objNewTeamMember = new AccountTeamMember(AccountId = idAccount,
        TeamMemberRole = label.UAC_subcontractor,
        UserId = idUser);
        lstAccountTeamMemberInsert.add(objNewTeamMember);
      }
      
    }
    system.debug(lstAccountTeamMemberInsert);
    if (!lstAccountTeamMemberInsert.isEmpty()) {
		insert lstAccountTeamMemberInsert;
	}
  }
  
  /**
   * @description ORRUAC-2913 - Method to update values on UAC Referral cases
   * on Contact UAC record update
   * @author Rahul Roy (Deloitte) | 10/05/2020
   * @param
   * @return void
   **/
  
  public
  static void populateValuesOnReferralCase(
    Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
    List<Case> lstCasesToUpdate = new List<Case>();

    for (Contact objContact : mapNewContacts.values()) {
      if (objContact.RecordTypeId == IdcontactRecordType
          && (objContact.UAC_mppCase__c != mapOldContacts.get(objContact.Id).UAC_mppCase__c
		      ||objContact.UAC_separatedFromParentLegalGuardian__c != mapOldContacts.get(objContact.Id).UAC_separatedFromParentLegalGuardian__c	)
			 && objContact.UAC_techUACReferralId__c != Null ) {
        Case objCaseToUpdate = new Case(Id=objContact.UAC_techUACReferralId__c);
		 if(objContact.UAC_mppCase__c == true){
			 objCaseToUpdate.UAC_isThisAMppCase__c = 'Yes';
		 }
		 else{
			 objCaseToUpdate.UAC_isThisAMppCase__c = 'No';
		 }
		 if(objContact.UAC_separatedFromParentLegalGuardian__c == true){
			 objCaseToUpdate.UAC_parentalLegalGuardianSeparation__c = 'Yes';
		 }
		 else{
			 objCaseToUpdate.UAC_parentalLegalGuardianSeparation__c = 'No';
		 }
		lstCasesToUpdate.add(objCaseToUpdate);
      }
    }
	
    if(!lstCasesToUpdate.isEmpty()){
		update lstCasesToUpdate;
	}
  }
  
      /**
   * @description ORRUAC-213 - Method to create initial Mental Health Evaluation(IMHE) record when the UAC status is
   *"Admitted".
   * @author Anupreeta Chakraborty (Deloitte) | 10/08/2020
   * @param
   * @return void
   **/
   
  /*public
  static void createInitialMentalHEonStatusAdmitted(
    Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
    String strIMHERecordType = System.label.UAC_healthEvaluationRecordTypeApiNameInitialMental;
    List<UAC_HealthEvaluation__c> lstIMHEToInsert = new List<UAC_HealthEvaluation__c>();
    Id IMHERecordTypeId =
        Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
            .get(strIMHERecordType)
            .getRecordTypeId();

    for (Contact objContact : [select id,
           RecordTypeId,
           UAC_status__c,
           UAC_currentAge__c,
           UAC_program__r.name,
           UAC_admissionDateforMostRecentORRStay__c,
           UAC_admissionAgeforMostRecentORRStay__c,
           UAC_dischargeDateforMostRecentORRStay__c,
           UAC_mostRecentAdmittedDateTime__c from contact where id IN:mapNewContacts.values()]) {
      if (objContact.RecordTypeId == IdcontactRecordType
          && objContact.UAC_status__c == Label.UAC_admittedContactStatus
          && objContact.UAC_status__c != mapOldContacts.get(objContact.Id).UAC_status__c) {
        // Create new initial Mental Health Evaluation record.
        UAC_healthEvaluation__c objIMHE = new UAC_healthEvaluation__c();
        objIMHE.recordTypeId = IMHERecordTypeId; 
        objIMHE.UAC_associatedUAC__c = objContact.id;  
        if (objContact.UAC_program__c != null)
          objIMHE.UAC_programNameattheTimeofExam__c = objContact.UAC_program__r.name; 
        if (objContact.UAC_mostRecentAdmittedDateTime__c != null) {
          DateTime dtt = objContact.UAC_mostRecentAdmittedDateTime__c +5;
          objIMHE.UAC_dueDate__c = dtt.dateGMT();
        }
        objIMHE.UAC_admissionDateforMostRecentORRStay__c = objContact.UAC_admissionDateforMostRecentORRStay__c;
        objIMHE.UAC_ageAtAdmission__c = objContact.UAC_admissionAgeforMostRecentORRStay__c;  
        objIMHE.UAC_dischargeDateforMostRecentORRStay__c = objContact.UAC_dischargeDateforMostRecentORRStay__c;  
        lstIMHEToInsert.add(objIMHE);
      }
    }
    if(!lstIMHEToInsert.isEmpty()){
      try {
        insert lstIMHEToInsert;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Initial Mental Health record creation failed on updating status to Admitted',
            e.getStackTraceString());
      }
    }
   
   }*/

  /**
   * @description Method to update child case AccountId when parent Contact changes
   * @author James Qian (Deloitte) | 10/08/2020
   * @param
   * @return void
   **/
  public
  static void updateChildCasesOnAccountChange(
      Map<Id, contact> mapNewContacts, Map<Id, contact> mapOldContacts) {
    Set<Id> setContactIds = new Set<Id>();
    for (Contact objContact : mapNewContacts.values()) {
      if (objContact.RecordTypeId == IdcontactRecordType
          && objContact.AccountId != mapOldContacts.get(objContact.Id).AccountId
          && String.isNotBlank(objContact.AccountId)) {
        setContactIds.add(objContact.Id);
      }
    }
    if (setContactIds.isEmpty()) {
      return;
    }
    List<Case> listCasesToUpdate = new List<Case>();
    for (Case caseCurrent :
        [SELECT Id, AccountId, ContactId FROM Case WHERE ContactId IN:setContactIds]) {
      if (caseCurrent.AccountId != mapNewContacts.get(caseCurrent.ContactId).AccountId) {
        caseCurrent.AccountId = mapNewContacts.get(caseCurrent.ContactId).AccountId;
        listCasesToUpdate.add(caseCurrent);
      }
    }
    if (!listCasesToUpdate.isEmpty()) {
      try {
        update listCasesToUpdate;
      } catch (Exception e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error updating child Entries, please correct this error message before changing the Entity of this UC '
                + e.getMessage(),
            e.getStackTraceString());
      }
    }
  }

  /**
   * @description Method to update Discharge Notification Field when Contact is in Admitted Status
   * @author Satish Kota (Kvortex) | 11/11/2020
   * @param contact List and Map from trigger
   * @return void
   * User Story ::  ORRUAC-4129
   **/
  public
  static void updateDischargeNotificationField(List<Contact> newContactList,Map<Id,Contact> oldContactMap){
    for(Contact con: newContactList){
      if(con.RecordTypeId == IdcontactRecordType && oldContactMap != null &&
          con.UAC_status__c != oldContactMap.get(con.Id).UAC_status__c &&
          con.UAC_status__c == strContactAdmittedStatus) {
        con.UAC_dischargeNotificationCompleted__c = false;
      }
    }
   }

  /**
   * @description Method to update Most Recent Program When Contact is inserted or Program is changed
   * @author Satish Kota (Kvortex) | 11/11/2020
   * @param contact List and Map from trigger
   * @return void
   * User Story ::  ORRUAC-4129
   **/    
  public
  static void updateMostRecentProgram(List<Contact> newContactList,Map<Id,Contact> oldContactMap){
      for (Contact con: newContactList) {
          if (con.RecordTypeId != IdcontactRecordType) {
            continue;
          }
          if (oldContactMap == null && con.UAC_program__c != null) {
            con.UAC_mostRecentProgram__c = con.UAC_program__c;
          } else if (oldContactMap != null && con.UAC_program__c != oldContactMap.get(con.Id).UAC_program__c && String.isNotBlank(con.UAC_program__c)) {
            con.UAC_mostRecentProgram__c = con.UAC_program__c;
          }
      }
   }

   /**
   * @author       James Qian (Deloitte)
   * @description  Return map of contacts with status changed to Admitted
   * @param        Map<Id, Contact> mapNewContacts
   * @param        Map<Id, Contact> mapOldContacts
   * @return       Map<Id, Contact>
   */
  public
  static Map<Id, Contact> getAdmittedContacts(
      Map<Id, Contact> mapNewContacts, Map<Id, Contact> mapOldContacts) {
    Map<Id, Contact> mapContactsToReturn = new Map<Id, Contact>();
    for (Contact contactCurrent : mapNewContacts.values()) {
      if (contactCurrent.RecordTypeId == IdcontactRecordType
          && mapOldContacts.get(contactCurrent.Id).UAC_status__c != strContactAdmittedStatus
          && contactCurrent.UAC_status__c == Label.UAC_admittedContactStatus) {
        mapContactsToReturn.put(contactCurrent.Id, contactCurrent);
      }
    }
    return mapContactsToReturn;
  }
}