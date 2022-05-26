/**
* @File Name          : UAC_swbBatch.cls
* @Description        : ORRUAC-2698 : Batch class to auto generate SWB(Safety Well-Being) Cases after 30 days of Date of Departure
* @Author             : Piyush(Deloitte)
* @Test Class         : UAC_swbBatchTest.cls
* @Modification Log   :
* Ver       Date            Author               Modification
* 1.0    9/30/2020      Piyush(Deloitte)     Initial Implementation.
**/
global without sharing class UAC_swbBatch implements Database.Batchable<sObject>,Database.Stateful{
    global static Map<String,Schema.RecordTypeInfo> mapRecordTypesByDeveloperName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    global static Id idDNFRecType = mapRecordTypesByDeveloperName.get(Label.UAC_CaseRecordTypeDischargeNotification).getRecordTypeId();
    global static Id idSWBRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeSWB).getRecordTypeId();
    global static Id idAdRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeAdmission).getRecordTypeId();
    global static Id idHSPrsRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeHSPRSReferral).getRecordTypeId();
    global static DateTime prev30Days = System.Now() - 30;
    global static String strDischargeReunifiedIndSp = Label.UAC_dnfTypeOfDischargeReunifiedIndSp;
    global static String strDischargeReunifiedSepPar = Label.UAC_dnfTypeOfDischargeReunifiedSepPar;
    global static String strDCORS = Label.UAC_dnfTODCORS;
    public String strQuery;
    List<Case> lstSwbAll = new List<Case>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        strQuery = 'Select Id,ContactId,UAC_techSwbGenerated__c,UAC_dateTimeOfDischarge__c,UAC_programFacility__c,ParentId from Case where RecordTypeId =:idDNFRecType'; 
        strQuery = strQuery + ' and UAC_techSwbGenerated__c = false and UAC_typeOfDischarge__c in (:strDischargeReunifiedIndSp,:strDischargeReunifiedSepPar,:strDCORS)';
        strQuery = strQuery + ' and UAC_dateTimeOfDischarge__c < :prev30Days';
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bc, List<Case> scope){
        List<Case> lstSwb = new List<Case>();
        Set<Id> setPid = new Set<Id>();
        Set<Id> setAdmId = new Set<Id>();
        Set<Id> setPCid = new Set<Id>();
        Set<Id> setPRRId = new Set<Id>();
        Set<Id> setPrgram = new Set<Id>();
        Map<Id,Case> mapIdToDnfCase = new Map<Id,Case>();
        Map<Id,Case> mapIdToPrsCase = new Map<Id,Case>();
        Map<Id,UAC_adultContactRelationship__c> mapContactPrimarySponsor = new Map<Id,UAC_adultContactRelationship__c>();
        Map<Id,Id> mapUACToAdultContact = new Map<Id,Id>();
        Map<Id,Case> mapContactIdToAdmCaseRec = new Map<Id,Case>();
        List<Case> lstflagupd = new List<Case>();
        Map<Id, List<CaseTeamMember>> mapCseIdTolstCseTm = new Map<Id, List<CaseTeamMember>>();
        Map<Id, List<AccountTeamMember>> mapActIdTolstActTm = new Map<Id, List<AccountTeamMember>>();
        Map<Id,CaseTeamRole> mapRoleIdToObj = new Map<Id,CaseTeamRole>([SELECT Id, Name, PreferencesVisibleInCSP from CaseTeamRole Limit 1000]);
        for(Case obCase:scope){
            setPid.add(obCase.Id);
            setPCid.add(obCase.ContactId);
            mapIdToDnfCase.put(obCase.Id,obCase);
            if(obCase.ParentId != null){
                setPRRId.add(obCase.ParentId);
            }
            if(obCase.UAC_programFacility__c != null){
                setPrgram.add(obCase.UAC_programFacility__c);
            }
        }

        for(UAC_adultContactRelationship__c objadultContactRelationship :[SELECT Id,UAC_adultContact__c,UAC_uacLookup__c FROM UAC_adultContactRelationship__c WHERE UAC_uacLookup__c
                                                                          in :setPCid AND UAC_relationshipType__c =:Label.UAC_relationshipTypePrimarySponsor]){                                                               
            mapContactPrimarySponsor.put(objadultContactRelationship.UAC_uacLookup__c, objadultContactRelationship);
            mapUACToAdultContact.put(objadultContactRelationship.UAC_uacLookup__c,objadultContactRelationship.UAC_adultContact__c);
        }
        for(Case objAdmission :[Select Id,ContactId,CaseNumber,UAC_admittedDateTime__c,lastmodifieddate from Case where RecordTypeId =:idAdRecType and ContactId in:setPCid]){
            setAdmId.add(objAdmission.Id);
            if(mapContactIdToAdmCaseRec.containsKey(objAdmission.ContactId) && mapContactIdToAdmCaseRec.get(objAdmission.ContactId) != null){
                if(mapContactIdToAdmCaseRec.get(objAdmission.ContactId).LastModifiedDate <  objAdmission.LastModifiedDate){
                    mapContactIdToAdmCaseRec.remove(objAdmission.ContactId);
                    mapContactIdToAdmCaseRec.put(objAdmission.ContactId,objAdmission);
                }
            }
            else{
                mapContactIdToAdmCaseRec.put(objAdmission.ContactId,objAdmission);
            }
        }
        for(Case objHsPrs:[Select Id,ContactId,UAC_hSPRSPrimaryProviderName__c,Type,Status from Case where RecordTypeId =:idHSPrsRecType and ContactId in :setPCid]){
            if(objHsPrs.UAC_hSPRSPrimaryProviderName__c != null && objHsPrs.Type.contains('PRS') && objHsPrs.Status == 'Active'){
                mapIdToPrsCase.put(objHsPrs.ContactId,objHsPrs);
            }
        }
        // Populating Case Team of Admission Case to pull CM,LCM
        List<CaseTeamMember> lstCseTm = [Select MemberId,ParentId,TeamRoleId from CaseTeamMember where ParentId =:setAdmId];
        if(!lstCseTm.IsEmpty()){
            for(CaseTeamMember ctm:lstCseTm){
                if(mapCseIdTolstCseTm.containsKey(ctm.ParentId)){
                    List<CaseTeamMember> cslst = mapCseIdTolstCseTm.get(ctm.ParentId);
                    cslst.add(ctm);
                } 
                else{
                    mapCseIdTolstCseTm.put(ctm.ParentId, new List<CaseTeamMember>{ctm});
                }
            }
        }
        // Populating Account Team of Program Facility - to be used for pulling CFS,FFS
        List<AccountTeamMember> lstActTmMem = [Select Id, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId in:setPrgram];
        if(!lstActTmMem.IsEmpty()){
            for(AccountTeamMember atm:lstActTmMem){
                if(mapActIdTolstActTm.containsKey(atm.AccountId)){
                    List<AccountTeamMember> actlst = mapActIdTolstActTm.get(atm.AccountId);
                    actlst.add(atm);
                } 
                else{
                    mapActIdTolstActTm.put(atm.AccountId, new List<AccountTeamMember>{atm});
                }
            }
        }        
            
        Map<Id,Case> mapIdToRReq = new Map<Id,Case>([Select Id,UAC_orrDecision__c,UAC_orrDecisionHS__c from Case where id in :setPRRId]);
        Map<Id,Contact> mapIdToAdCnt = new Map<Id,Contact>([Select Id,Phone from Contact where id in :mapUACToAdultContact.values()]);

        if(mapIdToDnfCase.IsEmpty()){
          return;
        }
        for(Case obC:mapIdToDnfCase.values()){
            Case swbCase = new Case();
            swbCase.RecordTypeId = idSWBRecType;
            if(mapIdToDnfCase.get(obC.Id) != null){
                swbCase.ContactId = mapIdToDnfCase.get(obC.Id).ContactId;
                swbCase.UAC_dateTimeOfDischarge__c = mapIdToDnfCase.get(obC.Id).UAC_dateTimeOfDischarge__c;
                swbCase.UAC_programFacility__c = mapIdToDnfCase.get(obC.Id).UAC_programFacility__c;                    
            }
            swbCase.ParentId = obC.Id;
            if(mapContactPrimarySponsor.get(mapIdToDnfCase.get(obC.Id).ContactId) != null){
                swbCase.UAC_relationshipToUAC__c = mapContactPrimarySponsor.get(mapIdToDnfCase.get(obC.Id).ContactId).Id;
            }
            if(mapUACToAdultContact.get(mapIdToDnfCase.get(obC.Id).ContactId) != null){
                swbCase.UAC_sponsor__c = mapUACToAdultContact.get(mapIdToDnfCase.get(obC.Id).ContactId);
            }
            if(mapIdToAdCnt.get(mapUACToAdultContact.get(mapIdToDnfCase.get(obC.Id).ContactId)) != null){
                swbCase.UAC_dischargePhone__c = mapIdToAdCnt.get(mapUACToAdultContact.get(mapIdToDnfCase.get(obC.Id).ContactId)).Phone;
            }
            if(mapContactIdToAdmCaseRec.get(obC.ContactId) != null){
                swbCase.UAC_admission__c = mapContactIdToAdmCaseRec.get(obC.ContactId).Id;
                swbCase.UAC_admittedDateTime__c = mapContactIdToAdmCaseRec.get(obC.ContactId).UAC_admittedDateTime__c;
                if(mapCseIdTolstCseTm.get(mapContactIdToAdmCaseRec.get(obC.ContactId).Id) != null){
                    for(CaseTeamMember ct:mapCseIdTolstCseTm.get(mapContactIdToAdmCaseRec.get(obC.ContactId).Id)){
                        if(mapRoleIdToObj.get(ct.TeamRoleId).Name == 'Case Manager'){
                            swbCase.UAC_caseManager__c = ct.MemberId;
                        }
                        else if(mapRoleIdToObj.get(ct.TeamRoleId).Name == 'Lead Case Manager'){
                            swbCase.UAC_leadCaseManager__c = ct.MemberId;
                        }
                    }
                }
            }
            if(obC.UAC_programFacility__c != null && mapActIdTolstActTm.get(obC.UAC_programFacility__c) != null){
                for(AccountTeamMember atm:mapActIdTolstActTm.get(obC.UAC_programFacility__c)){
                    if(atm.TeamMemberRole == Label.UAC_caseTeamRoleNameFFS){
                        swbCase.UAC_ffsName__c = atm.UserId;
                    }
                    else if(atm.TeamMemberRole == Label.UAC_caseTeamRoleNameCFS){
                        swbCase.UAC_cfsName__c = atm.UserId;
                    }
                }
            }
            if(mapIdToPrsCase.get(obC.ContactId) != null){
                swbCase.UAC_hSPRSPrimaryProviderName__c = mapIdToPrsCase.get(obC.ContactId).UAC_hSPRSPrimaryProviderName__c;
            }
            if(mapIdToRReq.get(obC.ParentId) != null && mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c != null){
                if((mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c == Label.UAC_approveStraightRelease 
                || mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c == Label.UAC_approveWithPostReleaseOnlyServices) && mapIdToRReq.get(obC.ParentId).UAC_orrDecisionHS__c == null){
                        swbCase.UAC_typeOfDischargeSWB__c = mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c;
                }
                else if(mapIdToRReq.get(obC.ParentId).UAC_orrDecisionHS__c != null
                && ((mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c == Label.UAC_conductHomeStudyTVPRA && mapIdToRReq.get(obC.ParentId).UAC_orrDecisionHS__c == Label.UAC_approveWithPostReleaseServicesTVPRA)
                || (mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c == Label.UAC_conductHomeStudyORRMandated && mapIdToRReq.get(obC.ParentId).UAC_orrDecisionHS__c == Label.UAC_approveWithPostReleaseServicesAfterORRMandated)
                || (mapIdToRReq.get(obC.ParentId).UAC_orrDecision__c == Label.UAC_conductHomeStudyDiscretionary && mapIdToRReq.get(obC.ParentId).UAC_orrDecisionHS__c == Label.UAC_approveWithPostReleaseServicesAfterDiscretionary))){
                        swbCase.UAC_typeOfDischargeSWB__c = mapIdToRReq.get(obC.ParentId).UAC_orrDecisionHS__c;
                }
            }
            lstSwb.add(swbCase);
        }
        if(!lstSwb.IsEmpty()){
            insert lstSwb;
        }
        lstSwbAll.addAll(lstSwb);
        for(Case obCse:mapIdToDnfCase.values()){
            obCse.UAC_techSwbGenerated__c = true;
        }
        if(!mapIdToDnfCase.IsEmpty()){
            update mapIdToDnfCase.values();
        }
    }
    global void finish(Database.BatchableContext bc){
        UAC_swbCaseTeamBatch  db = new UAC_swbCaseTeamBatch(lstSwbAll);
        database.executeBatch(db,10);
    }

}