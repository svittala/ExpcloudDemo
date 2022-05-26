/**
 * @File Name          : UC_SponsorApplication.cls
 * @Description        : This class for used to display all Realted sponsor application records.
 *object.
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : Nithin Malla (Deloitte)
 * @Last Modified On   : 9/20/2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/20/2021   Nithin Malla (Deloitte)     Initial Version
 * 1.0    9/21/2021   Nithin Malla (Deloitte)     Updating the Role and Discharge Mapping
 **/
public with sharing class UC_SponsorApplication {
    
    @AuraEnabled
    public static SponsorApplication getRelatedSponsorApps(Id recordID){
        SponsorApplication retObj = new SponsorApplication();
        List<SponsorApplicationWrapper> lstofSponsorApplications = new List<SponsorApplicationWrapper>();
        Map<Id,UAC_associatedContact__c> sponsorWithAssConMap = new Map<Id,UAC_associatedContact__c>();
        Map<Id,Case> sponsorWithCaseMap = new Map<Id,Case>();
        
        List<UAC_associatedContact__c> associatedConList = [SELECT UAC_contact__c,UC_role__c
                                                            FROM UAC_associatedContact__c 
                                                            WHERE UAC_case__c = :recordID 
                                                            AND (UAC_householdMember__c=true OR UAC_alternateAdultCaregiver__c=true)];
        
        for(UAC_associatedContact__c associatedContRec: associatedConList){
            sponsorWithAssConMap.put(associatedContRec.UAC_contact__c, associatedContRec);
        }
        
        Map<Id,Case> caseWithParentMap = new Map<Id,Case>();
        for(Case cs: [select ParentId,UAC_programFacility__c,UAC_programFacility__r.Name from case where parent.UAC_sponsor__c IN: sponsorWithAssConMap.keySet() 
                      and recordtype.DeveloperName=:Label.UAC_caseRecordTypeReleaseRequest
                      and parent.recordtype.DeveloperName=:Label.UAC_caseRecordTypeApiNameSponsorApplication
                      and Status IN ('Completed','DNF Generated')
                      ORDER BY CreatedDate Desc]){
            if(!caseWithParentMap.containsKey(cs.Id)){
                caseWithParentMap.put(cs.parentID, cs);
            }
        }
        
        for(Case caseRec: [SELECT CaseNumber, RecordType.Name, ContactId,Contact.Name,UAC_dateOfBirth__c,UAC_relationshipToUACPickLst__c, Status, 
                           UAC_legacyCaseORRDecision__c,UAC_parentName__c,UAC_relationshipToUAC__r.UAC_relationshipToUAC__c,UAC_sponsor__c
                           FROM Case WHERE 
                           UAC_sponsor__c IN: sponsorWithAssConMap.keySet() 
                           AND Recordtype.DeveloperName = :Label.UAC_caseRecordTypeApiNameSponsorApplication
                           AND Id != :recordID WITH SECURITY_ENFORCED]){
                               
             	SponsorApplicationWrapper sponAppRec = new SponsorApplicationWrapper();
                sponAppRec.strEntryId = '/'+caseRec.Id;
                sponAppRec.strEntryNumber = caseRec.CaseNumber;
                if(sponsorWithAssConMap.containsKey(caseRec.UAC_sponsor__c)){
                	sponAppRec.strRole = sponsorWithAssConMap.get(caseRec.UAC_sponsor__c).UC_role__c;
                }
                sponAppRec.strUCId = '/'+caseRec.ContactId;
                sponAppRec.strUCName = caseRec.Contact.Name;
                sponAppRec.strRelationshipToUC = caseRec.UAC_relationshipToUAC__r.UAC_relationshipToUAC__c;
                sponAppRec.strORRDecision = caseRec.UAC_legacyCaseORRDecision__c;
                if(caseWithParentMap.containsKey(caseRec.Id)){
                    sponAppRec.strDischargeProgramName = caseWithParentMap.get(caseRec.Id).UAC_programFacility__r.Name;
                    sponAppRec.strDischargeProgramId = caseWithParentMap.get(caseRec.Id).UAC_programFacility__c;
                }
                lstofSponsorApplications.add(sponAppRec);
        }     
        
        retObj.lstSponAppRecords = lstofSponsorApplications;
        return retObj;
    }
    
    Public class SponsorApplicationWrapper {
        @AuraEnabled Public string strEntryId;
        @AuraEnabled Public string strEntryNumber;
        @AuraEnabled Public string strRole;
        @AuraEnabled Public string strUCId;
        @AuraEnabled Public string strUCName;
        @AuraEnabled Public string strRelationshipToUC;
        @AuraEnabled Public string strORRDecision;
        @AuraEnabled Public string strDischargeProgramName;
        @AuraEnabled Public string strDischargeProgramId;
    }
    
    Public class SponsorApplication {
        @AuraEnabled Public List<SponsorApplicationWrapper> lstSponAppRecords;
        public SponsorApplication(){
            lstSponAppRecords = new List<SponsorApplicationWrapper>();
        }
    }
}