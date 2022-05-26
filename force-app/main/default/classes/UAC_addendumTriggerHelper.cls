/**
* @File Name          : UAC_addendumTriggerHelper.cls
* @Description        : Handles all UAC_addendum__c trigger logic
* @Author             : Priyanka Bolla (Deloitte)
* @Group              :

* Ver       Date            Author                   		Modification
* 1.0    	7/16/2020   	Priyanka Bolla (Deloitte)   	Initial Version
* 1.1    	8/28/2020  		Nithin Malla (Deloitte)      	ORRUAC-2163 Multi-Select Values on Addendum
* 1.2    	8/31/2020  		Nithin Malla (Deloitte)      	Added Created In Error Updates
* 1.3    	10/02/2020  	Nithin Malla (Deloitte)      	Adding Sharing visibility keyword
* 1.4       11/5/2020       Chaitanya Nandamuri(Deloitte)   ORRUAC-856 Including fields on CPS, State Li, Law Enforce.. sections to auto-populate/update. 
**/
public with sharing class UAC_addendumTriggerHelper {
    
    Static set<id> setErroradded = new set<id>();
    Static final String strActiveAddendumExist = System.Label.UAC_addendumValidation;
    Static final String CREATED_IN_ERROR = System.Label.UAC_CreatedInError;
    Static final String SUBMITTED = System.Label.UAC_assessmentStatusSubmitted;
    Static final String ADDENDUM_SUBMITTED = System.Label.UAC_addendumSubmitted;
    Static final String ADDENDUM_IN_DRAFT = System.Label.UAC_addendumInDraft;
    Static final String SELECT_STR = 'Select ';
    Static final String UAC_SIR = 'UAC_sir__c';
    Static final String NEW_LINE = '\n';
    Static final String HYPHEN = '---';
    Static final String ADDENDUM_SUBMITTED_BY = 'Addendum Submitted By';
    Static final String ON_STR = ' On ';
	Static final String ADDENDUM_Reason = 'Addendum Reason : ';
    
    
   /*  @author      Priyanka Bolla
    @description  Validates the Current Addendum Status field for insert
    @param        List<UAC_addressHistory__c> lstNewItems
    @return       void
    */ 
    public static void validateCurrentAddendum(List<UAC_addendum__c> lstNewItems) {
        list<id> lstSIRIds = new list<id>();
        for(UAC_addendum__c newItem : lstNewItems){
            if(newItem.UAC_addendumStatus__c == Label.UAC_addendumDraftStatus)
                lstSIRIds.add(newItem.UAC_sir__c);
        }
        map<id,UAC_sir__C> mapSIR= new map<id,UAC_sir__C>(
                                                            [select 
                                                             id, 
                                                             (select 
                                                              id,
                                                              UAC_addendumStatus__c
                                                              from 
                                                              Addendums__r
                                                              where 
                                                              UAC_addendumStatus__c =: Label.UAC_addendumDraftStatus)
                                                             from 
                                                             UAC_sir__C 
                                                             where
                                                             id in : lstSIRIds]
        													);
        for(UAC_addendum__c newItem : lstNewItems){
            UAC_sir__c objSIR  = mapSIR.get(newItem.UAC_sir__c);
            if(objSIR != null && objSIR.Addendums__r != null && objSIR.Addendums__r.size() > 0){
                setErroradded.add(newItem.id);
                newItem.addError(strActiveAddendumExist);
            }
        }
    }
    
    
    /**
    * @description Processing addendum submitted on SIR records
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param Map<Id, SObject> Map of Addendums from Trigger New
    * @return UAC_sir__c
    **/
    public static void addendumSubmittedProcess(Map<Id, SObject> newItems) {
        Set<Id> sirIDs = new Set<Id>();
        Set<Id> createdErrorIDs = new Set<Id>();
        Set<Id> sirAddendumInDraftIDs = new Set<Id>();
        Map<Id,UAC_addendum__c> addMap = new Map<Id,UAC_addendum__c>();
        for(UAC_addendum__c newItem : (list<UAC_addendum__c>) newItems.values()){
            if(newItem.UAC_addendumStatus__c==SUBMITTED){
                newItem.UAC_submittedBy__c = newItem.LastModifiedById;
                newItem.UAC_addendumSubmittedDate__c = system.today();
                sirIDs.add(newItem.UAC_sir__c);
                addMap.put(newItem.UAC_sir__c, newItem);
            } else if(newItem.UAC_addendumStatus__c==CREATED_IN_ERROR){
                createdErrorIDs.add(newItem.UAC_sir__c);
                addMap.put(newItem.UAC_sir__c, newItem);
            }
        }
        
        if(createdErrorIDs.size()>0){
            List<UAC_sir__c> sirRecordsToUpd = new List<UAC_sir__c>();
            List<UAC_addendum__c> existingAddendumList = [Select Id,UAC_addendumStatus__c,UAC_sir__c  
                                                          from UAC_addendum__c 
                                                          where UAC_sir__c IN:createdErrorIDs AND
                                                          UAC_addendumStatus__c =:SUBMITTED ];
            Map<Id,List<UAC_addendum__c>> sirWithAddendumList = new Map<Id,List<UAC_addendum__c>>();
            for(UAC_addendum__c addendumRec: existingAddendumList){
                
                if(sirWithAddendumList.containsKey(addendumRec.UAC_sir__c)){
                    sirWithAddendumList.get(addendumRec.UAC_sir__c).add(addendumRec);
                }else{
                    sirWithAddendumList.put(addendumRec.UAC_sir__c, new List<UAC_addendum__c>{addendumRec});
                }
            }
            
            for(ID sirRecId: createdErrorIDs){
                UAC_sir__c sirRec = new UAC_sir__c(Id=sirRecId,UAC_addendumDraft__c=false,UAC_checkSubmissionFlag__c=true);
                if(!sirWithAddendumList.isEmpty() && sirWithAddendumList.get(sirRecId).size()>=1){
                    sirRec.UAC_status__c=ADDENDUM_SUBMITTED;
                }else{
                    sirRec.UAC_status__c=SUBMITTED;
                }
                sirRecordsToUpd.add(sirRec);
            }
            
            handleResultSet(sirRecordsToUpd, addMap);
        }
        
        if(sirIDs.size()>0){
            String query = SELECT_STR + getDynamicFieldString(UAC_SIR) + ' from UAC_sir__c where Id IN:sirIDs' ;
            
            Map<Id,UAC_sir__c> sirMap = new Map<Id,UAC_sir__c>( (List<UAC_sir__c>)Database.query(query));
            
            if(sirMap.size()>0){
                List<UAC_sir__c> sirRecordsToUpdate = new List<UAC_sir__c>();
                for(ID sirRecID:sirIDs){
                    //Populatting Text fields from SIR to Addendum
                    UAC_sir__c uacRec = populateTextFieldsFromAddendumToSIR(sirRecID, sirMap, addMap);
                    
                    //Populatting all the other fields from SIR to Addendum
                    popuateAllOtherFieldsFromAddendumToSIR(addMap.get(uacRec.Id), uacRec);
                    sirRecordsToUpdate.add(uacRec);
                }
                
                handleResultSet(sirRecordsToUpdate, addMap);
            }
        }
    }
    
    /**
    * @description Populating Addendum values to related SIR record
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param Id, Map<Id,UAC_sir__c>, Map<Id,UAC_addendum__c> 
    * @return UAC_sir__c
    **/
    Private static UAC_sir__c populateTextFieldsFromAddendumToSIR(ID sirRecID, Map<Id,UAC_sir__c> sirMap, Map<Id,UAC_addendum__c> addMap){
        UAC_sir__c uacRec = new UAC_sir__c();
        uacRec.Id = sirRecID;
        uacRec.UAC_addendumDraft__c = false;
        uacRec.UAC_checkSubmissionFlag__c = false;
        uacRec.UAC_status__c = ADDENDUM_SUBMITTED;
		
        uacRec.UAC_IfNotReportedToLawEnforcementExplain__c  = formatTextFields(addMap.get(uacRec.id).UAC_IfNotReportedToLawEnforcementUpdate__c, 
                                                                               sirMap.get(uacRec.id).UAC_IfNotReportedToLawEnforcementExplain__c);
        
        uacRec.UAC_ifNotReportedToHHSOIGExplain__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifNotReportedToHHSOIGExplainUpdated__c, 
                                                                        sirMap.get(uacRec.id).UAC_ifNotReportedToHHSOIGExplain__c);
        
        uacRec.UAC_ifNotReportedToCPSExplain__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifNotReportedToCPSExplainUpdated__c, 
                                                                     sirMap.get(uacRec.id).UAC_ifNotReportedToCPSExplain__c);
        
        uacRec.UAC_ifNotReportedToDOJFBIExplain__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifNotReportedToDOJFBIExplainUpd__c, 
                                                                         sirMap.get(uacRec.id).UAC_ifNotReportedToDOJFBIExplain__c);
        uacRec.UAC_ifNotReportedToStLicensingExplain__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifNotReportedToStLicensing__c, 
                                                                             sirMap.get(uacRec.id).UAC_ifNotReportedToStLicensingExplain__c);
        uacRec.UAC_OtherActionsTakenForVictim__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifOtherExplainUpdated__c, 
                                                                      sirMap.get(uacRec.id).UAC_OtherActionsTakenForVictim__c);
        uacRec.UAC_ReasonForStopPlacement__c =   formatTextFields(addMap.get(uacRec.id).UAC_reasonForStopPlacementUpd__c, 
                                                                  sirMap.get(uacRec.id).UAC_ReasonForStopPlacement__c);
        uacRec.UAC_descriptionOfIncident__c =   formatTextFields(addMap.get(uacRec.id).UAC_descriptionOfIncidentUpdated__c, 
                                                                 sirMap.get(uacRec.id).UAC_descriptionOfIncident__c);
        uacRec.UAC_explainCPSAction__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainCPSActionUpdated__c, 
                                                            sirMap.get(uacRec.id).UAC_explainCPSAction__c);
        uacRec.UAC_explainDOJFBIAction__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainDOJFBIActionUpdated__c, 
                                                               sirMap.get(uacRec.id).UAC_explainDOJFBIAction__c);
        uacRec.UAC_explainHHSOIGAction__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainHHSOIGActionUpdated__c, 
                                                               sirMap.get(uacRec.id).UAC_explainHHSOIGAction__c);
        uacRec.UAC_explainLawEnforcementAction__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainLawEnforcementActionUpdated__c, 
                                                                       sirMap.get(uacRec.id).UAC_explainLawEnforcementAction__c);
        uacRec.UAC_explainMediaorExternalAffairsInvolv__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainMediaorExternalAffairsInvolvU__c, 
                                                                               sirMap.get(uacRec.id).UAC_explainMediaorExternalAffairsInvolv__c);
        uacRec.UAC_explainProgramVideoFootage__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainProgramVideoFootageUpd__c, 
                                                                      sirMap.get(uacRec.id).UAC_explainProgramVideoFootage__c);
        uacRec.UAC_explainStaffSuspensionDecision__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainStaffSuspensionDecisionUpd__c, 
                                                                          sirMap.get(uacRec.id).UAC_explainStaffSuspensionDecision__c);
        uacRec.UAC_explainStateLicensingAction__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainStateLicensingActionUpdated__c, 
                                                                       sirMap.get(uacRec.id).UAC_explainStateLicensingAction__c);
        uacRec.UAC_explaintheSafetyPlan__c =   formatTextFields(addMap.get(uacRec.id).UAC_explaintheSafetyPlanUpdated__c, 
                                                                sirMap.get(uacRec.id).UAC_explaintheSafetyPlan__c);
        uacRec.UAC_explainMediaorExternalAffairsInvolv__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainMediaorExternalAffairsInvolvU__c, 
                                                                               sirMap.get(uacRec.id).UAC_explainMediaorExternalAffairsInvolv__c);
        uacRec.UAC_followupandorResolution__c =   formatTextFields(addMap.get(uacRec.id).UAC_followupandorResolutionUpdated__c, 
                                                                   sirMap.get(uacRec.id).UAC_followupandorResolution__c);
        uacRec.UAC_ifOtherExplain__c =   formatTextFields(addMap.get(uacRec.id).UAC_otherActionsTakenForAlleged__c, 
                                                          sirMap.get(uacRec.id).UAC_ifOtherExplain__c);
        uacRec.UAC_explainStateLicensingAction__c =   formatTextFields(addMap.get(uacRec.id).UAC_explainStateLicensingActionUpdated__c, 
                                                                       sirMap.get(uacRec.id).UAC_explainStateLicensingAction__c);
        uacRec.UAC_explaintheSafetyPlan__c =   formatTextFields(addMap.get(uacRec.id).UAC_explaintheSafetyPlanUpdated__c, 
                                                                sirMap.get(uacRec.id).UAC_explaintheSafetyPlan__c);
        uacRec.UAC_resultsFindingsofInvestigationCPS__c =   formatTextFields(addMap.get(uacRec.id).UAC_resultsFindingsofInvestigationCPSUp__c, 
                                                                             sirMap.get(uacRec.id).UAC_resultsFindingsofInvestigationCPS__c);
        uacRec.UAC_resultsFindingsofInvestigationDOJFBI__c =   formatTextFields(addMap.get(uacRec.id).UAC_resultsFindingsofInvestigationDOJUpd__c, 
                                                                                sirMap.get(uacRec.id).UAC_resultsFindingsofInvestigationDOJFBI__c);
        uacRec.UAC_resultsFindingsofInvestigationHHSOIG__c =   formatTextFields(addMap.get(uacRec.id).UAC_resultsFindingsofInvestigationHHSUpd__c, 
                                                                                sirMap.get(uacRec.id).UAC_resultsFindingsofInvestigationHHSOIG__c);
        uacRec.UAC_resultsFindingsofInvestigationIncide__c =   formatTextFields(addMap.get(uacRec.id).UAC_resultsFindingsOfInvestigationUpdate__c, 
                                                                                sirMap.get(uacRec.id).UAC_resultsFindingsofInvestigationIncide__c);
        uacRec.UAC_resultsFindingsofInvestigationLawEnf__c =   formatTextFields(addMap.get(uacRec.id).UAC_resultsFindingsOfInvestigationLawUpd__c, 
                                                                                sirMap.get(uacRec.id).UAC_resultsFindingsofInvestigationLawEnf__c);
        uacRec.UAC_resultsFindingsofInvestigationStatec__c =   formatTextFields(addMap.get(uacRec.id).UAC_resultsFindingsOfInvestigationLawUpd__c, 
                                                                                sirMap.get(uacRec.id).UAC_resultsFindingsofInvestigationStatec__c);
        uacRec.UAC_specifyIfUACOrAnyoneElseEvacuat__c =   formatTextFields(addMap.get(uacRec.id).UAC_specifyTheUACAnyoneElseEvaUpdated__c, 
                                                                           sirMap.get(uacRec.id).UAC_specifyIfUACOrAnyoneElseEvacuat__c);
        uacRec.UAC_specifyIncidentInformationThree__c =   formatTextFields(addMap.get(uacRec.id).UAC_specifyIncidentInformationUpdated__c, 
                                                                           sirMap.get(uacRec.id).UAC_specifyIncidentInformationThree__c);
        
        uacRec.UAC_staffResponseandIntervention__c =   formatTextFields(addMap.get(uacRec.id).UAC_staffResponseandInterventionUpdated__c, 
                                                                        sirMap.get(uacRec.id).UAC_staffResponseandIntervention__c);
        
        uacRec.UAC_whatWasFindingofFootage__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifYesWhatWasFindingOfFootageUpd__c, 
                                                                   sirMap.get(uacRec.id).UAC_whatWasFindingofFootage__c);
        uacRec.UAC_whywasfootagenotavailable__c =   formatTextFields(addMap.get(uacRec.id).UAC_whywasfootagenotavailableUpdated__c, 
                                                                     sirMap.get(uacRec.id).UAC_whywasfootagenotavailable__c);
        uacRec.UAC_IfNoWhyWasFootageNotAvailable__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifNoWhyWasFootageNotAvailableUpd__c, 
                                                                         sirMap.get(uacRec.id).UAC_IfNoWhyWasFootageNotAvailable__c);
        uacRec.UAC_IfYesWhatWasFindingOfFootage__c =   formatTextFields(addMap.get(uacRec.id).UAC_ifYesWhatWasFindingOfFootageUpd__c, 
                                                                   sirMap.get(uacRec.id).UAC_IfYesWhatWasFindingOfFootage__c);
        uacRec.UAC_specifyIfUACOrAnyoneElseInjure__c =   formatTextFields(addMap.get(uacRec.id).UAC_specifyOtherNotificationsTableUpdat__c, 
                                                                           sirMap.get(uacRec.id).UAC_specifyIfUACOrAnyoneElseInjure__c);
        uacRec.UAC_specifyHowWasThisUACInvolved__c =   formatTextFields(addMap.get(uacRec.id).UAC_specifyIncidentInformationUpdated__c, 
                                                                           sirMap.get(uacRec.id).UAC_specifyHowWasThisUACInvolved__c);
        uacRec.UAC_descriptionOfAddendumChanges__c =   formatTextonDescriptionOfChanges(addMap.get(uacRec.id).UAC_descriptionOfAddendumChanges__c, 
                                                                       sirMap.get(uacRec.id).UAC_descriptionOfAddendumChanges__c,addMap.get(uacRec.id).UAC_addendumReason__c); 

		uacRec.UC_specifyBehavioralIncidentsThatThreate__c =   formatTextonDescriptionOfChanges(addMap.get(uacRec.id).UC_specifyBehavioralIncidentsThatThreate__c, 
                                                                       sirMap.get(uacRec.id).UC_specifyBehavioralIncidentsThatThreate__c,addMap.get(uacRec.id).UAC_addendumReason__c);
        
        return uacRec;
    }
    
    /**
    * @description Formatting Text Fields for value population
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param String, String
    * @return String
    **/
	  Private static string formatTextFields(String addendumTextValue, String sirStrinVal){
        if(String.isNotBlank(addendumTextValue)){
            DateTime now = System.now();
            sirStrinVal =  (sirStrinVal!=null?sirStrinVal + NEW_LINE + HYPHEN + NEW_LINE :'');
            addendumTextValue = sirStrinVal + ADDENDUM_SUBMITTED_BY +userinfo.getName()+ ON_STR +
                				now.format('yyyy-MM-dd HH:mm:ss')+ NEW_LINE +addendumTextValue;	                				
            return addendumTextValue;
        }
        
        
        return sirStrinVal;
    }
	 /**
    * @description Formatting Text Fields for value population
    * @author Priyanka Bolla (Deloitte) | 9/03/2020
    * @param String, String
    * @return String
    **/
      Private static string formatTextonDescriptionOfChanges(String addendumTextValue, String sirStrinVal,string addendumReasonValue){
        if(String.isNotBlank(addendumTextValue)){
            DateTime now = System.now();
            sirStrinVal =  (sirStrinVal!=null?sirStrinVal + NEW_LINE + HYPHEN + NEW_LINE :'');
            addendumTextValue = sirStrinVal + ADDENDUM_SUBMITTED_BY +userinfo.getName()+ ON_STR + 
                				 +now.format('yyyy-MM-dd HH:mm:ss' )+ NEW_LINE + ADDENDUM_Reason +addendumReasonValue+ NEW_LINE +addendumTextValue;
     
            return addendumTextValue;
        }
        
        
        return sirStrinVal;
    }
    /**
    * @description Other Addendum Fields on SIR record
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param UAC_addendum__c, UAC_sir__c 
    * @return Void
    **/
    Private static void popuateAllOtherFieldsFromAddendumToSIR(UAC_addendum__c addRec, UAC_sir__c sirRec){
        sirRec.UAC_abuseorNeglect__c = addRec.UAC_abuseorNeglect__c;
        sirRec.UAC_allegedPerpetrator__c = addRec.UAC_allegedPerpetrator__c;
        sirRec.UAC_behaveIncidentsnotimmediately__c = addRec.UAC_behaveIncidentsnotimmediately__c;
        sirRec.UAC_behavioralIncidentsimmediate__c = addRec.UAC_behavioralIncidentsimmediate__c;
        sirRec.UAC_category__c = addRec.UAC_category__c;
        sirRec.UAC_criminalHistory__c = addRec.UAC_criminalHistory__c;
        sirRec.UAC_gangAffiliation__c = addRec.UAC_gangAffiliationAddendum__c;
        sirRec.UAC_crisisIntervention__c = addRec.UAC_crisisIntervention__c;
        sirRec.UAC_deathNonUAC__c = addRec.UAC_deathNonUAC__c;
        sirRec.UAC_incidentsinvolvinglawenforcement__c = addRec.UAC_incidentsinvolvinglawenforcement__c;
        sirRec.UAC_majorDisturbance__c = addRec.UAC_majorDisturbance__c;
        sirRec.UAC_naturalDisaster__c = addRec.UAC_naturalDisaster__c;
        sirRec.UAC_orrReportingtoExternalAgencies__c = addRec.UAC_orrReportingtoExternalAgencies__c;
        sirRec.UAC_pastAbuseorNeglect__c = addRec.UAC_pastAbuseorNeglect__c;
        sirRec.UAC_potentialfraudschemes__c = addRec.UAC_potentialfraudschemes__c;
        sirRec.UAC_publicHealthEmergency__c = addRec.UAC_publicHealthEmergency__c;
        sirRec.UAC_stopPlacement__c = addRec.UAC_stopPlacement__c;
        sirRec.UAC_subcategory__c = addRec.UAC_subcategory__c;
        sirRec.UAC_traffickingConcern__c = addRec.UAC_traffickingConcern__c;
        sirRec.UAC_typeofAbuse__c = addRec.UAC_typeofAbuse__c;
        sirRec.UAC_unauthorizedAbsence__c = addRec.UAC_unauthorizedAbsence__c;
        sirRec.UAC_ReportedtoDOJFBI__c = addRec.UAC_ReportedtoDOJFBI__c;
        sirRec.UAC_WereStaffPresentOrInvolved__c = addRec.UAC_WereStaffPresentOrInvolved__c;
        sirRec.UAC_actionsTakenforAllegedPerpetrator__c = addRec.UAC_actionsTakenforAllegedPerpetrator__c;
        sirRec.UAC_actionsTakenforVictim__c = addRec.UAC_actionsTakenforVictim__c;
        sirRec.UAC_attachReportFindingsCPS__c = addRec.UAC_attachReportFindingsCPS__c;
        sirRec.UAC_attachReportFindingsDOJ__c = addRec.UAC_attachReportFindingsDOJ__c;
        sirRec.UAC_attachReportFindingsHHSOIG__c = addRec.UAC_attachReportFindingsHHSOIG__c;
        sirRec.UAC_attachReportFindingsLawEnforcement__c = addRec.UAC_attachReportFindingsLawEnforcement__c;
        sirRec.UAC_attachReportFindingsStateLicensing__c = addRec.UAC_attachReportFindingsStateLicensing__c;
        sirRec.UAC_capturedonProgramVideoFootage__c = addRec.UAC_capturedonProgramVideoFootage__c;
        sirRec.UAC_careProviderName__c = addRec.UAC_careProviderName__c;
        sirRec.UAC_caseConfirmationNumberCPS__c = addRec.UAC_caseConfirmationNumberCPS__c;
        sirRec.UAC_caseConfirmationNumberDOJFBI__c = addRec.UAC_caseConfirmationNumberDOJFBI__c;
        sirRec.UAC_caseConfirmationNumberHHSOIG__c = addRec.UAC_caseConfirmationNumberHHSOIG__c;
        sirRec.UAC_caseConfirmationNumberLawEnforcement__c = addRec.UAC_caseConfirmationNumberLawEnforcement__c;
        sirRec.UAC_caseConfirmationNumberStateLicensing__c = addRec.UAC_caseConfirmationNumberStateLicensing__c;
        sirRec.UAC_dateFootageReviewedByProgram__c = addRec.UAC_dateFootageReviewedByProgram__c;
        sirRec.UAC_dateInvestigationCompleted__c = addRec.UAC_dateInvestigationCompleted__c;
        sirRec.UAC_dateNotifiedTheIncidentWillBeDOJFBI__c = addRec.UAC_dateNotifiedTheIncidentWillBeDOJFBI__c;
        sirRec.UAC_dateNotifiedTheIncidentWillBeHHSOIG__c = addRec.UAC_dateNotifiedTheIncidentWillBeHHSOIG__c;
        sirRec.UAC_dateNotifiedTheIncidentWillBeLawEnfo__c = addRec.UAC_dateNotifiedTheIncidentWillBeLawEnfo__c;
        sirRec.UAC_dateNotifiedtheIncidentwillbeCPS__c = addRec.UAC_dateNotifiedtheIncidentwillbeCPS__c;
        sirRec.UAC_dateNotifiedtheIncidentwillbeinvStat__c = addRec.UAC_dateNotifiedtheIncidentwillbeinvStat__c;
        sirRec.UAC_dateTimeOfReportCPS__c = addRec.UAC_dateTimeOfReportCPS__c;
        sirRec.UAC_dateTimeOfReportDOJFBI__c = addRec.UAC_dateTimeOfReportDOJFBI__c;
        sirRec.UAC_dateTimeOfReportHHSOIG__c = addRec.UAC_dateTimeOfReportHHSOIG__c;
        sirRec.UAC_dateTimeOfReportLawEnforcement__c = addRec.UAC_dateTimeOfReportLawEnforcement__c;
        sirRec.UAC_dateTimeOfReportStateLicensing__c = addRec.UAC_dateTimeOfReportStateLicensing__c;
        sirRec.UAC_dateTimeReportedToORR__c = addRec.UAC_dateTimeReportedToORR__c;
        sirRec.UAC_deathInCareProviderFacility__c = addRec.UAC_deathInCareProviderFacility__c;
        sirRec.UAC_dispositionofIncident__c = addRec.UAC_dispositionofIncident__c;
        sirRec.UAC_howWasThisUACInvolved__c = addRec.UAC_howWasThisUACInvolved__c;
        sirRec.UAC_iConfirmThatIHaveCompletedAll__c = addRec.UAC_iConfirmThatIHaveCompletedAll__c;
        sirRec.UAC_incidentatOtherCareProvFacility__c = addRec.UAC_incidentatOtherCareProvFacility__c;
        sirRec.UAC_internalInvestigation__c = addRec.UAC_internalInvestigation__c;
        sirRec.UAC_isCPSDifferentFromStateLicensing__c = addRec.UAC_isCPSDifferentFromStateLicensing__c;
        sirRec.UAC_mediaorExternalAffairsInvolvement__c = addRec.UAC_mediaorExternalAffairsInvolvement__c;
        sirRec.UAC_medicalEmergencyRequiringImmediateHo__c = addRec.UAC_medicalEmergencyRequiringImmediateHo__c;
        sirRec.UAC_officerBadge__c = addRec.UAC_officerBadge__c;
        sirRec.UAC_officerName__c = addRec.UAC_officerName__c;
        sirRec.UAC_printedName__c = addRec.UAC_printedName__c;
        sirRec.UAC_reportedToHHSOIG__c = addRec.UAC_reportedToHHSOIG__c;
        sirRec.UAC_reportedToStateLicensing__c = addRec.UAC_reportedToStateLicensing__c;
        sirRec.UAC_reportedtoCPS__c = addRec.UAC_reportedtoCPS__c;
        sirRec.UAC_reportedtoLawEnforcement__c = addRec.UAC_reportedtoLawEnforcement__c;
        sirRec.UAC_sirNameOfAllegedPerpetrator__c = addRec.UAC_sirNameOfAllegedPerpetrator__c;
        sirRec.UAC_sirPLEReportDisposition__c = addRec.UAC_sirPLEReportDisposition__c;
        sirRec.UAC_title__c = addRec.UAC_title__c;
        sirRec.UAC_wasStaffSuspended__c = addRec.UAC_wasStaffSuspended__c;
        sirRec.UAC_wasTheIncidentInvestigatedDOJFBI__c = addRec.UAC_wasTheIncidentInvestigatedDOJFBI__c;
        sirRec.UAC_wasTheIncidentInvestigatedHHSOIG__c = addRec.UAC_wasTheIncidentInvestigatedHHSOIG__c;
        sirRec.UAC_wasTheIncidentInvestigatedLawEnfo__c = addRec.UAC_wasTheIncidentInvestigatedLawEnfo__c;
        sirRec.UAC_wasTheIncidentInvestigatedStat__c = addRec.UAC_wasTheIncidentInvestigatedStat__c;
        sirRec.UAC_wasaSafetyPlanCreated__c = addRec.UAC_wasaSafetyPlanCreated__c;
        sirRec.UAC_wasanonstaffAdultpresentorInvolve__c = addRec.UAC_wasanonstaffAdultpresentorInvolve__c;
        sirRec.UAC_wastheIncidentInvestigatedCPS__c = addRec.UAC_wastheIncidentInvestigatedCPS__c;
        sirRec.UAC_wastheUACorAnyoneElseEvacuated__c = addRec.UAC_wastheUACorAnyoneElseEvacuated__c;
        sirRec.UAC_wastheUACorAnyoneElseInjured__c = addRec.UAC_wastheUACorAnyoneElseInjured__c;
        sirRec.UAC_wereOtherUACInvolved__c = addRec.UAC_wereOtherUACInvolved__c;
        sirRec.UAC_subcategoryOtherLong__c = addRec.UAC_subcategoryOtherLong__c;
        sirRec.UAC_incidentReviewFormIsSubmitted__c =addRec.UAC_adultChildIncidentReviewformsubmit__c;
        //ORRUAC-856
        sirRec.UAC_agencyName_CPS__c = addRec.UAC_agencyName_CPS__c;
        sirRec.UAC_agencyName_LawEnforcement__c =  addRec.UAC_agencyName_LawEnforcement__c;
        sirRec.UAC_AgencyName_StateLicensing__c =  addRec.UAC_AgencyName_StateLicensing__c;
        sirRec.UAC_contactMethod_CPS__c = addRec.UAC_contactMethod_CPS__c;
        sirRec.UAC_contactMethod_LawEnforcement__c = addRec.UAC_contactMethod_LawEnforcement__c;
        sirRec.UAC_contactMethod_StateLicensing__c = addRec.UAC_contactMethod_StateLicensing__c;
        sirRec.UAC_contactName_CPS__c = addRec.UAC_contactName_CPS__c;
        sirRec.UAC_ContactName_StateLicensing__c = addRec.UAC_ContactName_StateLicensing__c;
        sirRec.UAC_phone_CPS__c = addRec.UAC_phone_CPS__c;
        sirRec.UAC_phone_LawEnforcement__c = addRec.UAC_phone_LawEnforcement__c;
        sirRec.UAC_phone_StateLicensing__c = addRec.UAC_phone_StateLicensing__c;
        sirRec.UAC_email_CPS__c = addRec.UAC_email_CPS__c;
        sirRec.UAC_email_LawEnforcement__c = addRec.UAC_email_LawEnforcement__c;
        sirRec.UAC_email_StateLicensing__c = addRec.UAC_email_StateLicensing__c;      

    }
    
    /**
    * @description Updating SIR records on addendum insertion 
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param List<UAC_addendum__c> List of Addendums from Trigger New
    * @return Void
    **/
    public static void populateAddendumDraftOnInsert(List<UAC_addendum__c> lstNewItems) {
        List<UAC_sir__c> lstSIRForUpdate = new List<UAC_sir__c>();
        Map<Id,UAC_addendum__c> addMap = new Map<Id,UAC_addendum__c>();
        
        for (UAC_addendum__C newItem : lstNewItems) {
            
            UAC_sir__c sir = new UAC_sir__c(Id=newItem.UAC_sir__c );
            sir.UAC_addendumDraft__c = true;
            sir.UAC_checkSubmissionFlag__c=true;
            sir.UAC_status__c = ADDENDUM_IN_DRAFT;
            addMap.put(newItem.UAC_sir__c, newItem);
            lstSIRForUpdate.add(sir);
        }
        
       	//Updating SIR Records
        handleResultSet(lstSIRForUpdate, addMap);
    }
    
    /**
    * @description SIR Fields to Addendum record
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param List<UAC_addendum__c> List of Addendums from Trigger New
    * @return Void
    **/
    public static void populateSIRToAddendumOnInsert(List<UAC_addendum__c> lstNewItems) {
        List<UAC_sir__c> lstSIRForUpdate = new List<UAC_sir__c>();
        Set<Id> sirSetIDs = new Set<Id>();
        for (UAC_addendum__C newItem : lstNewItems) {
            sirSetIDs.add(newItem.UAC_sir__c);
        }
        
        String query = SELECT_STR + getDynamicFieldString(UAC_SIR) + ' from UAC_sir__c where Id IN:sirSetIDs' ;
        
        Map<Id,UAC_sir__c> sirMap = new Map<Id,UAC_sir__c>( (List<UAC_sir__c>) Database.query(query));
        
        if(sirMap.size()>0){
            for (UAC_addendum__C newItem : lstNewItems) {
                popuateMultiPicklistFromSIRToAddendum(newItem, sirMap.get(newItem.UAC_sir__c));
            }
        }
    }
    
    /**
    * @description Other Addendum Fields on SIR record
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param UAC_addendum__c, UAC_sir__c
    * @return Void
    **/
    Private Static void popuateMultiPicklistFromSIRToAddendum(UAC_addendum__c addRec, UAC_sir__c sirRec){
        addRec.UAC_abuseorNeglect__c = sirRec.UAC_abuseorNeglect__c;
        addRec.UAC_allegedPerpetrator__c = sirRec.UAC_allegedPerpetrator__c;
        addRec.UAC_behaveIncidentsnotimmediately__c = sirRec.UAC_behaveIncidentsnotimmediately__c;
        addRec.UAC_behavioralIncidentsimmediate__c = sirRec.UAC_behavioralIncidentsimmediate__c;
        addRec.UAC_category__c = sirRec.UAC_category__c;
        addRec.UAC_criminalHistory__c = sirRec.UAC_criminalHistory__c;
        addRec.UAC_gangAffiliationAddendum__c = sirRec.UAC_gangAffiliation__c;
        addRec.UAC_crisisIntervention__c = sirRec.UAC_crisisIntervention__c;
        addRec.UAC_deathNonUAC__c = sirRec.UAC_deathNonUAC__c;
        addRec.UAC_incidentsinvolvinglawenforcement__c = sirRec.UAC_incidentsinvolvinglawenforcement__c;
        addRec.UAC_majorDisturbance__c = sirRec.UAC_majorDisturbance__c;
        addRec.UAC_naturalDisaster__c = sirRec.UAC_naturalDisaster__c;
        addRec.UAC_orrReportingtoExternalAgencies__c = sirRec.UAC_orrReportingtoExternalAgencies__c;
        addRec.UAC_pastAbuseorNeglect__c = sirRec.UAC_pastAbuseorNeglect__c;
        addRec.UAC_potentialfraudschemes__c = sirRec.UAC_potentialfraudschemes__c;
        addRec.UAC_publicHealthEmergency__c = sirRec.UAC_publicHealthEmergency__c;
        addRec.UAC_stopPlacement__c = sirRec.UAC_stopPlacement__c;
        addRec.UAC_subcategory__c = sirRec.UAC_subcategory__c;
        addRec.UAC_traffickingConcern__c = sirRec.UAC_traffickingConcern__c;
        addRec.UAC_typeofAbuse__c = sirRec.UAC_typeofAbuse__c;
        addRec.UAC_unauthorizedAbsence__c = sirRec.UAC_unauthorizedAbsence__c;
        //ORRUAC-856
        addRec.UAC_agencyName_CPS__c = sirRec.UAC_agencyName_CPS__c;
        addRec.UAC_agencyName_LawEnforcement__c =  sirRec.UAC_agencyName_LawEnforcement__c;
        addRec.UAC_AgencyName_StateLicensing__c =  sirRec.UAC_AgencyName_StateLicensing__c;
        addRec.UAC_contactMethod_CPS__c = sirRec.UAC_contactMethod_CPS__c;
        addRec.UAC_contactMethod_LawEnforcement__c = sirRec.UAC_contactMethod_LawEnforcement__c;
        addRec.UAC_contactMethod_StateLicensing__c = sirRec.UAC_contactMethod_StateLicensing__c;
        addRec.UAC_contactName_CPS__c = sirRec.UAC_contactName_CPS__c;
        addRec.UAC_ContactName_StateLicensing__c = sirRec.UAC_ContactName_StateLicensing__c;
        addRec.UAC_phone_CPS__c = sirRec.UAC_phone_CPS__c;
        addRec.UAC_phone_LawEnforcement__c = sirRec.UAC_phone_LawEnforcement__c;
        addRec.UAC_phone_StateLicensing__c = sirRec.UAC_phone_StateLicensing__c;
        addRec.UAC_email_CPS__c = sirRec.UAC_email_CPS__c;
        addRec.UAC_email_LawEnforcement__c = sirRec.UAC_email_LawEnforcement__c;
        addRec.UAC_email_StateLicensing__c = sirRec.UAC_email_StateLicensing__c;      
    
    }
    
    /**
    * @description Database.update and adding errors
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param List<UAC_sir__c>, Map<Id,UAC_addendum__c>
    * @return Void
    **/
    Private Static void handleResultSet(List<UAC_sir__c> sirRecordsToUpdate, Map<Id,UAC_addendum__c> addMap){
        if(sirRecordsToUpdate.size()>0){
            Database.SaveResult[] saveResults = Database.update(sirRecordsToUpdate, false);
            for(Integer i=0;i<sirRecordsToUpdate.size();i++){
                if (!saveResults.get(i).isSuccess()){
                    Database.Error error = saveResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    addMap.get(sirRecordsToUpdate.get(i).Id).adderror(failedDML);
                }
            }
        }
    }
    
    /**
    * @description Dynamic SOQL for retrinving all fields from sobject
    * @author Nithin Malla (Deloitte) | 8/29/2020
    * @param String
    * @return String
    **/
    Private static String getDynamicFieldString(String sobjectName){
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String sfield : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = sfield;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + sfield;
            }
        }
        
        return commaSepratedFields;
    }
}