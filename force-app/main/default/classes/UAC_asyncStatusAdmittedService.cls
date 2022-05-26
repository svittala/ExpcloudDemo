/**
* @File Name          : UAC_asyncStatusAdmittedService.cls
* @Description        : This class is used for Status Admitted Services.
* @Author             : Nithin Malla (Deloitte)
* @Group              : 
* @Test Class         : 
* @Last Modified By   : Nithin Malla (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/17/2021	   Nithin Malla (Deloitte)  	Initial version.
* 1.2       09-15-2021     Abhisek Pati (Deloitte)      ORRUAC-6552 Added logic for Updating IME Status and Due date.
**/
public
without sharing class UAC_asyncStatusAdmittedService {
    
    public
    static final String strIMERecordType = System.label.UAC_IMERectype;
    
    /**
   * @description handling Status Admitted Updates
   * @author Nithin Malla (Deloitte) | 3/17/2021
   * @param healthEvaluationSet, mentalHealthEvaluationSet, legalServiceProviderSet
   * @return void
   **/   
    Public static void handleStatusUpdates(Set<Id> healthEvaluationSet, Set<Id> mentalHealthEvaluationSet, Set<Id> legalServiceProviderSet){
        
        //Creating of Initial Medical Exam
        if(!healthEvaluationSet.isEmpty()){
        	createIMEonStatusAdmitted(healthEvaluationSet);
        	//Update Contact with IME Status and Due date
        	updateIMEStatusAndDueDate(healthEvaluationSet);
        }
        
        //Creating of Initial Mental Health Evaluation
        if(!mentalHealthEvaluationSet.isEmpty())
        	createInitialMentalHEonStatusAdmitted(mentalHealthEvaluationSet);
        
        //Creating of Legal Status
        if(!legalServiceProviderSet.isEmpty())
        	createLegalStatusonStatusAdmitted(legalServiceProviderSet);
    }
    
    /**
   * @description handling Creation of Initial Medical Exam
   * @author Nithin Malla (Deloitte) | 3/17/2021
   * @param healthEvaluationSet
   * @return void
   **/   
    Private Static Void createIMEonStatusAdmitted(Set<Id> healthEvaluationSet){
        List<UAC_HealthEvaluation__c> lstIMEToInsert = new List<UAC_HealthEvaluation__c>();
        Id IMERecordTypeId =
            Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
            .get(strIMERecordType)
            .getRecordTypeId();
        UAC_BusinessDaysUtility bday = new UAC_BusinessDaysUtility();
        
        for (Contact objContact : [select id,
                                   RecordTypeId,
                                   UAC_status__c,
                                   UAC_currentAge__c,
                                   UAC_program__r.name,
                                   UAC_admissionDateforMostRecentORRStay__c,
                                   UAC_admissionAgeforMostRecentORRStay__c,
                                   UAC_dischargeDateforMostRecentORRStay__c,
                                   UAC_mostRecentAdmittedDateTime__c from contact where id IN:healthEvaluationSet]){
                                       
        // Create new IME record.
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
        if (objContact.UAC_currentAge__c != null)
          objIME.UAC_ageAtAdmission__c = Integer.valueOf(objContact.UAC_currentAge__c);
        objIME.UAC_lookupAssociatedProgram__c = objContact.UAC_program__c;
        if (objContact.UAC_program__c != null)
          objIME.UAC_programNameattheTimeofExam__c = objContact.UAC_program__r.name;
        if (objContact.UAC_mostRecentAdmittedDateTime__c != null) {
          DateTime dtt = bday.addDays(objContact.UAC_mostRecentAdmittedDateTime__c,
              Integer.valueOf(Label.UAC_daysIntervalfromAdmission));
          objIME.UAC_dueDate__c = dtt.dateGMT();
        }
        // Added below fields as part of ORRUC-634
        objIME.UAC_admissionDateforMostRecentORRStay__c =
            objContact.UAC_admissionDateforMostRecentORRStay__c;
        objIME.UAC_ageAtAdmission__c = objContact.UAC_admissionAgeforMostRecentORRStay__c;
        objIME.UAC_dischargeDateforMostRecentORRStay__c =
            objContact.UAC_dischargeDateforMostRecentORRStay__c;
        lstIMEToInsert.add(objIME);
        }
        
        List<sObject> objects = new List<sObject>();
        objects.addAll((List<sObject>)(lstIMEToInsert));
        insertStatusAdmittedUpdates(objects, 'IME Creation failed on updating status to Admitted');
    }

    /**
   * @description handling update IME status and Due date on profile
   * @author Abhisek Pati (Deloitte) | 9/15/2021
   * @param healthEvaluationSet
   * @return void
   **/   
  Private Static Void updateIMEStatusAndDueDate(Set<Id> healthEvaluationSet){
    UAC_asyncIMEStatusAndDueDateService.updateIMEStatusAndDueDate(healthEvaluationSet);
}
    
    /**
   * @description handling Creation of Initial Mental Health Evaluation
   * @author Nithin Malla (Deloitte) | 3/17/2021
   * @param mentalHealthEvaluationSet
   * @return void
   **/   
    Private Static Void createInitialMentalHEonStatusAdmitted(Set<Id> mentalHealthEvaluationSet){
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
                                   UAC_mostRecentAdmittedDateTime__c from contact where id IN:mentalHealthEvaluationSet]) {
       
        // Create new initial Mental Health Evaluation record.
        UAC_healthEvaluation__c objIMHE = new UAC_healthEvaluation__c();
        objIMHE.recordTypeId = IMHERecordTypeId;
        objIMHE.UAC_associatedUAC__c = objContact.id;
        if (objContact.UAC_program__c != null)
            objIMHE.UAC_programNameattheTimeofExam__c = objContact.UAC_program__r.name;
        if (objContact.UAC_mostRecentAdmittedDateTime__c != null) {
            DateTime dtt = objContact.UAC_mostRecentAdmittedDateTime__c + 5;
            objIMHE.UAC_dueDate__c = dtt.dateGMT();
        }
        objIMHE.UAC_admissionDateforMostRecentORRStay__c =
            objContact.UAC_admissionDateforMostRecentORRStay__c;
        objIMHE.UAC_ageAtAdmission__c = objContact.UAC_admissionAgeforMostRecentORRStay__c;
        objIMHE.UAC_dischargeDateforMostRecentORRStay__c =
            objContact.UAC_dischargeDateforMostRecentORRStay__c;
        lstIMHEToInsert.add(objIMHE);
      }
        
        List<sObject> objects = new List<sObject>();
        objects.addAll((List<sObject>)(lstIMHEToInsert));
        insertStatusAdmittedUpdates(objects,'Initial Mental Health record creation failed on updating status to Admitted');
    }
    
    /**
   * @description handling Insert Statements with Empty Check
   * @author Nithin Malla (Deloitte) | 3/17/2021
   * @param sObjectListToInsert, errorMsg
   * @return void
   **/   
    Private Static Void insertStatusAdmittedUpdates(List<sObject> sObjectListToInsert, String errorMsg){
       
        if (!sObjectListToInsert.isEmpty()) {
            try {
                insert sObjectListToInsert;
            } catch (Exception e) {
                UAC_errorLog.logError(e.getMessage(), '',
                                      errorMsg,
                                      e.getStackTraceString());
            }
        }
    }
    
    /**
   * @description handling Legal Status Creation
   * @author Nithin Malla (Deloitte) | 3/17/2021
   * @param legalServiceProviderSet
   * @return void
   **/   
    Private Static Void createLegalStatusonStatusAdmitted(Set<Id> legalServiceProviderSet){
        
        
        Id idLSPRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('UAC_legalServiceProviderRecord')
            .getRecordTypeId();
        list<Case> lstLSPRecords = new list<Case>();
        list<Case> lstLSPRecordsUpdate = new list<Case>();
        
        map<id, Contact> mapContactLSP = new map<id, Contact>([select id,
                                                               (select id, UAC_programFacility__c from Cases where recordtypeid =
                                                                : idLSPRecordType) from contact where id in:legalServiceProviderSet]);
        for (Contact objContact : [select id,UAC_status__c,UAC_program__c from contact where id IN:legalServiceProviderSet]) {
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
        }
        system.debug(lstLSPRecords);
        system.debug(lstLSPRecordsUpdate);
        
        if (!lstLSPRecords.isEmpty()) {
            insert lstLSPRecords;
        }
        if (!lstLSPRecordsUpdate.isEmpty()) {
            update lstLSPRecordsUpdate;
            List<String> lstUserLSP = new List<String>();
            List<String> lstUserLSPContact = new List<String>();
            List<String> lstUserLSPProgramFacility = new List<String>();
            map<id, case> mapLSPRecord = new map<id, case>(lstLSPRecordsUpdate);
            list<Caseteammember> lstoldCaseTeamMember = [select id,MemberId,parent.contactid,parent.UAC_programFacility__c 
                                                         from caseteammember where parentid in:mapLSPRecord.keyset()];
            for (Caseteammember objCaseTM : lstoldCaseTeamMember) {
                lstUserLSP.add(objCaseTM.MemberId);
                lstUserLSPContact.add(objCaseTM.parent.contactid);
                lstUserLSPProgramFacility.add(objCaseTM.parent.UAC_programFacility__c);
            }
            List<Contactshare> lstContactShareDelete =
                [Select id from Contactshare where contactid in:lstUserLSPContact and UserOrGroupId
                 in:lstUserLSP Limit 5000];
            List<Accountshare> lstAccountShareDelete = [Select id from Accountshare where AccountId
                                                        in:lstUserLSPProgramFacility and UserOrGroupId
                                                        in:lstUserLSP Limit 5000];
            if (!lstoldCaseTeamMember.isEmpty()) {
                delete lstoldCaseTeamMember;
            }
            if (!lstContactShareDelete.isEmpty()) {
                delete lstContactShareDelete;
            }
            if (!lstAccountShareDelete.isEmpty()) {
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
        system.debug(lstIdAccounts);
        if (!lstIdAccounts.isEmpty()) {
            lstAccountPartner = [
                select id,
                Accounttoid,
                accountfromid from Partner where accountfromid in:lstIdAccounts and role
                =:Label.UAC_LawFirm
            ];
            for (Partner AccountPartner : lstAccountPartner) {
                mapAccountPartner.put(AccountPartner.accountfromid, AccountPartner.Accounttoid);
            }
        }
        
        for (case objfinalCase : lstfinalCases) {
            if (objfinalCase.UAC_programFacility__c != null
                && mapAccountPartner.containsKey(objfinalCase.UAC_programFacility__c))
                objfinalCase.accountid = mapAccountPartner.get(objfinalCase.UAC_programFacility__c);
        }
        if (!lstfinalCases.isEmpty()) {
            upsert lstfinalCases;
        }
        system.debug(mapAccountPartner);
        if (!mapAccountPartner.isEmpty() && mapAccountPartner.values().size() > 0) {
            list<Accountteammember> lstAccountTeamMember = [
                select id,
                accountid,
                UserId,
                TeamMemberRole from accountteammember where accountid
                in:mapAccountPartner.values()and TeamMemberRole
                =:Label.UAC_Attorney
            ];
            for (Accountteammember objAccountTeamMember : lstAccountTeamMember) {
                list<accountteammember> lstteammember = new list<accountTeamMember>();
                if (mapPartnerTeamMember.containskey(objAccountTeamMember.accountid))
                    lstteammember = mapPartnerTeamMember.get(objAccountTeamMember.accountid);
                
                lstteammember.add(objAccountTeamMember);
                mapPartnerTeamMember.put(objAccountTeamMember.accountid, lstteammember);
            }
        }
        system.debug(mapPartnerTeamMember);
        caseteamrole objAttorneyRole =
            [select id, name, AccessLevel from caseteamrole where name =:Label.UAC_Attorney];
        
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
                        ojAccountshare.UserOrGroupId = objAccountteamMember.userid;
                        lstAccountShare.add(ojAccountshare);
                    }
                }
        }
        system.debug(lstCaseTeamMember);
        if (!lstCaseTeamMember.isEmpty()) {
            insert lstCaseTeamMember;
        }
        if (!lstContactShare.isEmpty()) {
            insert lstContactShare;
        }
        if (!lstAccountShare.isEmpty()) {
            insert lstAccountShare;
        }
    }
}