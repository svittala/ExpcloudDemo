/**
 * @File Name          : UAC_referralAssessmentTriggerHelper.cls
 * @Description        : Main helper class for trigger logic for UAC_referralAssessment__c
 * @Author             : Rahul Roy (Deloitte)
 * @Group              : UAC_referralAssessment__c
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    08/04/2020   Rahul Roy (Deloitte)     Initial Implementation.
 **/
public
without sharing class UAC_referralAssessmentTriggerHelper {
  public
  static final String strYes = Label.UAC_Yes;
  public
  static final String strAgenciesContactedRecordTypeHouseholdMember = Label.UAC_agenciesContactedRecordTypeHouseholdMember;
  public
  static final String strReferralAssessmentStatusDraft = Label.UAC_referralAssessmentStatusDraft;
  public
  static final String strReferralAssessmentStatusSubmitted = Label.UAC_referralAssessmentStatusSubmitted;
  public
  static final String strPRSStatusSubmitted = Label.UAC_referralAssessmentStatusSubmitted;
  public
  static final String strReferralAssessmentStatusDraftApprovedBySupervisor = Label.UAC_referralAssessmentStatusDraftApprovedBySupervisor;
  public
  static final String strHSAssessmentTaskSubjectInitialDraft = Label.UAC_hsAssessmentTaskSubjectInitialDraft;
  public
  static final String strHSAssessmentTaskSubjectReviewed = Label.UAC_hsAssessmentTaskSubjectReviewed;
  public
  static final String strCustomPermissionDCW = Label.UAC_CustomPermissionDCW;
  public
  static final String strCustomPermissionSupervisor = Label.UAC_CustomPermissionSupervisor;
  public
  static final string strHighPriority = 'High';
  public
  static final string strNotStartedSatus = 'Not Started';
  public
  static final String strnotificationRecordtypeTask = Label.UAC_notificationRecordtypeTask;
  private
  static final String strReferralAssessmentRecordTypeHSAssessment =
      Label.UAC_referralAssessmentRecordTypeHSAssessment;
  private 
  static final String strReferralAssessmentRecordTypePRSEvent =
      Label.UAC_prsEventRecordType;
  public
  static final String strCustomPermissionHSPRSProvider = Label.UAC_CustomPermissionHSPRSProvider;
  //Added by Ankur Aggarwal ( deloitte ) for ORRUAC_2096
  public
  static final 
  String strPRSTaskSubjectInitialDraft = Label.UAC_PRSTaskSubjectInitialDraft;
  public
  static final 
  String strPRSReviewbySupervisor = Label.UAC_PRSReviewbySupervisor;
  /**
   * @description ORRUAC-1548 AC 5 Method to populate date on HS Assessment.
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param Map<Id, UAC_referralAssessment__c> newItems
   * @param Map<Id, UAC_referralAssessment__c> oldItems
   **/
  public
  static void populateDateFields( Map<Id, UAC_referralAssessment__c> newItems, Map<Id, UAC_referralAssessment__c> oldItems) {
	Id idHSAssessmentRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
				   .get(strReferralAssessmentRecordTypeHSAssessment)
				   .getRecordTypeId();
  //added Record type  and conditions as part of ORRUAC-1547 AC 5 - Start                          
  Id idPRSEventRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
  .get(strReferralAssessmentRecordTypePRSEvent)
  .getRecordTypeId();     		  
  for (UAC_referralAssessment__c assessmentCurrent : newItems.values()) {
    if (assessmentCurrent.UAC_hsprsWorkerPrintedName__c
          != oldItems.get(assessmentCurrent.Id).UAC_hsprsWorkerPrintedName__c
		  && assessmentCurrent.UAC_hsprsWorkerPrintedName__c != null
		  && ( assessmentCurrent.recordTypeId == idHSAssessmentRecType || assessmentCurrent.recordTypeId == idPRSEventRecType)
      && (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)||
      FeatureManagement.checkPermission(strCustomPermissionDCW)||
      FeatureManagement.checkPermission(strCustomPermissionSupervisor))) {
          assessmentCurrent.UAC_hsprsWorkerCompletedDate__c = System.now();
      }
	  if (assessmentCurrent.UAC_hsprsSupervisorPrintedName__c
          != oldItems.get(assessmentCurrent.Id).UAC_hsprsSupervisorPrintedName__c
		  && assessmentCurrent.UAC_hsprsSupervisorPrintedName__c != null
		  && ( assessmentCurrent.recordTypeId == idHSAssessmentRecType || assessmentCurrent.recordTypeId == idPRSEventRecType)
      && (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)||
      FeatureManagement.checkPermission(strCustomPermissionDCW)||
      FeatureManagement.checkPermission(strCustomPermissionSupervisor))) {
          assessmentCurrent.UAC_hsprsSupervisorCompletedDate__c = System.now();
      }
	  if (assessmentCurrent.UAC_verifyAndSubmit__c
          != oldItems.get(assessmentCurrent.Id).UAC_verifyAndSubmit__c 
		  && assessmentCurrent.UAC_verifyAndSubmit__c == true
		  && assessmentCurrent.UAC_status__c == strReferralAssessmentStatusSubmitted
		  && ( assessmentCurrent.recordTypeId == idHSAssessmentRecType || assessmentCurrent.recordTypeId == idPRSEventRecType)
		  && (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider))) {
          assessmentCurrent.UAC_dateSubmittedToORR__c = System.now();
      }
    }
    //added Record type  and conditions as part of ORRUAC-1547 AC 5 - Ends     
  }
    
  /**
   * @description ORRUAC-1548 AC 7 Task creation on HS Assessment.
   * @author Rahul Roy (Deloitte) | 08/04/2020
   * @param Map<Id, UAC_referralAssessment__c> newItems
   * @param Map<Id, UAC_referralAssessment__c> oldItems
   **/
  
  public
  static void hsAssessmentTaskCreation(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    Id idHSAssessmentRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
                              .get(strReferralAssessmentRecordTypeHSAssessment)
                              .getRecordTypeId();
    //added as part of ORRUAC-1547 AC 7.1 - Start                          
    Id idPRSEventRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
                              .get(strReferralAssessmentRecordTypePRSEvent)
                              .getRecordTypeId();
    //added as part of ORRUAC-1547 AC 7.2 - End     
    Id idNotificationRecType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                .get(strnotificationRecordtypeTask)
                                .getRecordTypeId();

    list<task> lstTask = new list<task>();
    for (UAC_referralAssessment__c oldReferralAssessment : (list<UAC_referralAssessment__c>) oldItems.values()) {
      UAC_referralAssessment__c newReferralAssessment = (UAC_referralAssessment__c)newItems.get(oldReferralAssessment.Id);
     
        if(newReferralAssessment.recordtypeid == idHSAssessmentRecType && newReferralAssessment.UAC_status__c == strReferralAssessmentStatusDraft && newReferralAssessment.UAC_hsprsWorkerPrintedName__c != oldReferralAssessment.UAC_hsprsWorkerPrintedName__c
		&& newReferralAssessment.UAC_hsprsWorkerPrintedName__c != null
		&& newReferralAssessment.UAC_hsprsSupervisor__c != null
		&& (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)
        || FeatureManagement.checkPermission(strCustomPermissionDCW)
        || FeatureManagement.checkPermission(strCustomPermissionSupervisor))){
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationRecType;
          objTask.Subject = strHSAssessmentTaskSubjectInitialDraft  + ' ' + newReferralAssessment.Name;  // Update by Manoj: ORRUAC-2780  
          objTask.whatid = newReferralAssessment.id;
          objTask.OwnerId = newReferralAssessment.UAC_hsprsSupervisor__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority; 
          lstTask.add(objTask);
        }
        if(newReferralAssessment.recordtypeid == idHSAssessmentRecType && newReferralAssessment.UAC_status__c == strReferralAssessmentStatusDraftApprovedBySupervisor && newReferralAssessment.UAC_hsprsSupervisorPrintedName__c != oldReferralAssessment.UAC_hsprsSupervisorPrintedName__c
		&& newReferralAssessment.UAC_hsprsSupervisorPrintedName__c != null
		&& newReferralAssessment.UAC_assignedProviderName__c != null
		&& (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)
        || FeatureManagement.checkPermission(strCustomPermissionDCW)
        || FeatureManagement.checkPermission(strCustomPermissionSupervisor))){
		  Task objTask = new Task();
          objTask.recordtypeid = idNotificationRecType;
           objTask.Subject = strHSAssessmentTaskSubjectReviewed  + ' ' + newReferralAssessment.Name; // Update by Manoj: ORRUAC-2780      
          objTask.whatid = newReferralAssessment.id;
          objTask.OwnerId = newReferralAssessment.UAC_assignedProviderName__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority; 
          lstTask.add(objTask);
        }
      
      //Added by Ankur Aggarwal ( Deloitte) for ORRUAC-1547 AC 7.1 and 7.2 - Starts
   
        if( newReferralAssessment.recordtypeid == idPRSEventRecType && newReferralAssessment.UAC_status__c == strReferralAssessmentStatusDraft && newReferralAssessment.UAC_hsprsWorkerPrintedName__c != oldReferralAssessment.UAC_hsprsWorkerPrintedName__c
		&& newReferralAssessment.UAC_hsprsWorkerPrintedName__c != null
		&& newReferralAssessment.UAC_hsprsSupervisor__c != null
		&& (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)
        || FeatureManagement.checkPermission(strCustomPermissionDCW)
        || FeatureManagement.checkPermission(strCustomPermissionSupervisor))){
          Task objTask = new Task();
          objTask.recordtypeid = idNotificationRecType;
          objTask.Subject = strPRSTaskSubjectInitialDraft + ' ' + newReferralAssessment.Name;  
          objTask.whatid = newReferralAssessment.id;
          objTask.OwnerId = newReferralAssessment.UAC_hsprsSupervisor__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority; 
          lstTask.add(objTask);
        }
        if(newReferralAssessment.recordtypeid == idPRSEventRecType && newReferralAssessment.UAC_status__c == strReferralAssessmentStatusDraftApprovedBySupervisor && newReferralAssessment.UAC_hsprsSupervisorPrintedName__c != oldReferralAssessment.UAC_hsprsSupervisorPrintedName__c
		&& newReferralAssessment.UAC_hsprsSupervisorPrintedName__c != null
		&& newReferralAssessment.UAC_assignedProviderName__c != null
		&& (FeatureManagement.checkPermission(strCustomPermissionHSPRSProvider)
        || FeatureManagement.checkPermission(strCustomPermissionDCW)
        || FeatureManagement.checkPermission(strCustomPermissionSupervisor))){
		  Task objTask = new Task();
          objTask.recordtypeid = idNotificationRecType;
          objTask.Subject = strPRSReviewbySupervisor + ' ' + newReferralAssessment.Name;         
          objTask.whatid = newReferralAssessment.id;
          objTask.OwnerId = newReferralAssessment.UAC_assignedProviderName__c;
          objTask.Status = strNotStartedSatus;
          objTask.Priority = strHighPriority; 
          lstTask.add(objTask);
        }
            
      //Added by Ankur Aggarwal ( Deloitte) for ORRUAC-1547 AC 7.1 and 7.2 - Ends
    }
    system.debug(lstTask);
     if(!lstTask.isEmpty())
      insert lstTask;
  }
    
    /**
     * @description ORRUAC-1548 AC 8 Method to validate HS Assessment Deletion
     * @author Rahul Roy (Deloitte) | 08/04/2020
     * @param Map<Id, UAC_referralAssessment__c>
     * @return void
     **/
    public
    static void validateHSAssessmentDeletion(Map<Id, UAC_referralAssessment__c> mapOldHSAssessment, List<UAC_referralAssessment__c> listOldHSAssessment){  
		listOldHSAssessment[0].adderror(Label.UAC_hsAssessmentDeletionError);
    }

    
    /**
     * @description ORRUAC-1547 AC 8 Method to validate PRS Event Deletion
     * @author Ankur Aggarwal (Deloitte) |
     * @param Map<Id, UAC_referralAssessment__c>
     * @return void
     **/
    public
    static void validatePRSAssessmentDeletion(Map<Id, UAC_referralAssessment__c> mapOldHSAssessment, List<UAC_referralAssessment__c> listOldHSAssessment){  
	  	listOldHSAssessment[0].adderror(Label.UAC_PRSEventDeletionError);
    }    
    
 /**
   * @description ORRUAC-1548 AC 15 Auto Populate UAC and Sponsor 
   * @author Rahul Roy (Deloitte) | 08/05/2020
   * @param Map<Id, UAC_referralAssessment__c> newItems
   * @param Map<Id, UAC_referralAssessment__c> oldItems
   **/
  
  public
  static void populateUACAndSponsor(List<UAC_referralAssessment__c> lstNewReferralAssessment) {
    Id idHSAssessmentRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
                              .get(strReferralAssessmentRecordTypeHSAssessment)
                              .getRecordTypeId();
    //added as part of ORRUAC-1547 AC 11 - Start                          
    Id idPRSEventRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
                              .get(strReferralAssessmentRecordTypePRSEvent)
                              .getRecordTypeId();
    //added as part of ORRUAC-1547 AC 11 - End                          
    Map<Id, Case> mapParentCase = new Map<Id, Case>();
    list<String> lstCaseIDs = new list<String>();
	list<String> lstContactIDs = new list<String>();
	list<String> lstSponsorIDs = new list<String>();
    Map<String,Case> mapSponsorApplication = new Map<String, Case>();
    
    
    for (UAC_referralAssessment__c assessmentCurrent : lstNewReferralAssessment) {
          lstCaseIDs.add(assessmentCurrent.UAC_entry__c);
      } 
        
    if (!lstCaseIDs.isEmpty()) {
        //Update Logic to part of ORRUAC-2068
      for(Case objCase:[SELECT Id, ContactId,  UAC_sponsor__c,RecordType.DeveloperName  FROM Case WHERE Id IN:lstCaseIDs and RecordType.DeveloperName =: Label.UAC_caseRecordTypeHSPRSReferral] ){
       
            mapParentCase.put(objCase.Id,objCase);  
     		lstContactIDs.add(objCase.ContactId);
			lstSponsorIDs.add(objCase.UAC_sponsor__c);			
         
      }
	  if(!lstContactIDs.isEmpty() && !lstSponsorIDs.isEmpty()){
		  for(Case objCase:[SELECT Id, ContactId,  UAC_sponsor__c,RecordType.DeveloperName  FROM Case WHERE UAC_sponsor__c in : lstSponsorIDs  and  ContactId in : lstContactIDs and RecordType.DeveloperName = : Label.UAC_caseRecordTypeApiNameSponsorApplication] ){
			
				mapSponsorApplication.put(objCase.UAC_sponsor__c+'-'+objCase.ContactId,objCase); 
					
			
		  }
	  }
      for (UAC_referralAssessment__c assessmentCurrent : lstNewReferralAssessment) {
        //added or condition of PRS Event check as part of ORRUAC-1547 AC 11 - Start
        if (assessmentCurrent.recordTypeId == idHSAssessmentRecType || assessmentCurrent.recordTypeId == idPRSEventRecType) {
            //added or condition of PRS Event check as part of ORRUAC-1547 AC 11 - Start    
            if(mapParentCase.containsKey(assessmentCurrent.UAC_entry__c)){
                assessmentCurrent.UAC_uacProfileName__c = mapParentCase.get(assessmentCurrent.UAC_entry__c).ContactId;
                assessmentCurrent.UAC_sponsor__c = mapParentCase.get(assessmentCurrent.UAC_entry__c).UAC_sponsor__c;
                //added new condition of as part of ORRUAC-2068
                if(mapSponsorApplication.containsKey(mapParentCase.get(assessmentCurrent.UAC_entry__c).UAC_sponsor__c+'-'+mapParentCase.get(assessmentCurrent.UAC_entry__c).ContactId) && assessmentCurrent.recordTypeId == idHSAssessmentRecType){
                    assessmentCurrent.UAC_techSponsorApplication__c  = mapSponsorApplication.get(mapParentCase.get(assessmentCurrent.UAC_entry__c).UAC_sponsor__c+'-'+mapParentCase.get(assessmentCurrent.UAC_entry__c).ContactId).Id;
                }
            }
            
        }
      }
    }
  }
  /**
   * @description ORRUAC-2431 Create HouseHold Member for HS PRS Assessment
   * @author Manoj Sharma (Deloitte) | 09/15/2020
   * @param List< UAC_referralAssessment__c> lstNewReferralAssessment
   **/
  
  public
  static void populateHouseHoldMember(List<UAC_referralAssessment__c> lstNewReferralAssessment) {
	   Id idHSAssessmentRecType = Schema.SObjectType.UAC_referralAssessment__c.getRecordTypeInfosByDeveloperName()
                              .get(strReferralAssessmentRecordTypeHSAssessment)
                              .getRecordTypeId();
	   Id idHouseHoldMemberRecType = Schema.SObjectType.UAC_agenciesContacted__c.getRecordTypeInfosByDeveloperName()
                              .get(strAgenciesContactedRecordTypeHouseholdMember)
                              .getRecordTypeId();
	   Map<String,String>mapReferralAssSponsorApplication = new Map<String,String>();
	   Map<String,String>mapReferralAssCase = new Map<String,String>();
	   List<UAC_agenciesContacted__c> lstAgenciesContactedInsert= New List<UAC_agenciesContacted__c>();
	   for (UAC_referralAssessment__c assessmentCurrent : lstNewReferralAssessment) {
			 if (assessmentCurrent.recordTypeId == idHSAssessmentRecType && assessmentCurrent.UAC_techSponsorApplication__c  !=null ) {
				 mapReferralAssSponsorApplication.put(assessmentCurrent.UAC_techSponsorApplication__c,assessmentCurrent.Id );
				 mapReferralAssCase.put(assessmentCurrent.UAC_techSponsorApplication__c,assessmentCurrent.UAC_entry__c );
			 }
	   }
	   if(!mapReferralAssSponsorApplication.isEmpty()){ 
		   for(UAC_associatedContact__c objAssociateContact: [SELECT UAC_case__c,UAC_contact__c, UAC_contact__r.Name, UAC_dateOfBirth__c,UAC_dependentOnSponsorIncome__c,UAC_gender__c,UAC_householdMember__c,UAC_relationshipToSponsor__c FROM UAC_associatedContact__c where UAC_householdMember__c =True and UAC_case__c in : mapReferralAssSponsorApplication.keySet()]){
          if(mapReferralAssSponsorApplication.containsKey(objAssociateContact.UAC_case__c) && mapReferralAssCase.containsKey(objAssociateContact.UAC_case__c)){
					UAC_agenciesContacted__c objAgenciesContact= new UAC_agenciesContacted__c ();
					objAgenciesContact.UAC_contactName__c = objAssociateContact.UAC_contact__r.Name ;
					objAgenciesContact.UAC_currentHouseholdMember__c = strYes ;
					objAgenciesContact.UAC_dependentOnSponsorIncome__c = objAssociateContact.UAC_dependentOnSponsorIncome__c ;
					objAgenciesContact.UAC_DOB__c = objAssociateContact.UAC_dateOfBirth__c;
					objAgenciesContact.UAC_gender__c = objAssociateContact.UAC_gender__c;
					objAgenciesContact.UAC_relatedHSAssessment__c  = mapReferralAssSponsorApplication.get(objAssociateContact.UAC_case__c);
					objAgenciesContact.UAC_relationshipToSponsor__c = objAssociateContact.UAC_relationshipToSponsor__c;
					objAgenciesContact.UAC_entryID__c = mapReferralAssCase.get(objAssociateContact.UAC_case__c);
					objAgenciesContact.RecordTypeId= idHouseHoldMemberRecType;
					lstAgenciesContactedInsert.add(objAgenciesContact);
			   }
		   }
	   }
		if(!lstAgenciesContactedInsert.isEmpty()){
			insert lstAgenciesContactedInsert;
		}
  	}

}