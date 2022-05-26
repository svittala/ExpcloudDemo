/**
* @File Name          : UC_hsPrsEmailBatch.cls
* @Description        : ORRUAC-4590 AC-1,AC-3 : Batch class to send Email notif. to Entry Team members for HSPRS Referall Cases for UCs turning 18
* @Author             : Piyush(Deloitte)
* @Scheduler class    : UC_hsPrsEmailBatchScheduler.cls
* @Test Class         : UC_hsPrsEmailBatchTest.cls
* @Modification Log   :
* Ver       Date            Author               Modification
* 1.0    8/26/2021     Piyush(Deloitte)     Initial Implementation.
**/
global without sharing class UC_hsPrsEmailBatch implements Database.Batchable<sObject>,Database.Stateful{
    global static Map<String,Schema.RecordTypeInfo> mapRecordTypesByDeveloperName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    global static Id idHSPrsRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeHSPRSReferral).getRecordTypeId();
    global static String strPrs = Label.UAC_caseTypePRSOnly;
    global static String strPrsTVPrA = Label.UAC_caseTypePRSTVPRA;
    global static String strActive = Label.UAC_caseStatusActive;
    global static String strPend = Label.UAC_pending;
    global static String strCan = Label.UAC_caseStatusCancelled;
    global static String strAge18 = '18';
    global static String strAgeOut = 'Age Out';
    public String strQuery;
    Set<Id> setUsersGlobal = new Set<Id>();
    Set<Id> setUsrs30DaysGlobal = new Set<Id>();
    Map<Id,Case> qualifiedCseGlobal = new Map<Id,Case>();
    Map<Id,Case> cancelled30DaysCseGlobal = new Map<Id,Case>();
    Map<Id, List<CaseTeamMember>> mapCseIdTolstCseTmGlobal = new Map<Id, List<CaseTeamMember>>();
    Map<Id, List<CaseTeamMember>> mapCsIdTolstCsTm30DaysGlobal = new Map<Id, List<CaseTeamMember>>();
    global Database.QueryLocator start(Database.BatchableContext bc){
        strQuery = 'Select Id,Status,type,UAC_hsPrsReasonforCancel__c,UAC_dischargeComment__c,CaseNumber,ContactId,contact.Name,UAC_age__c from Case where RecordTypeId =:idHSPrsRecType'; 
        strQuery = strQuery + ' and Status in (:strActive,:strPend) and UAC_age__c = :strAge18';
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        Set<Id> setProId = new Set<Id>();
        Set<Id> qualifiedCseId = new Set<Id>();
        Set<Id> cancelled30DaysCseId = new Set<Id>();
        Map<Id,Case> scopedCntIdToCases = new Map<Id,Case>();
        Map<Id,Case> qualifiedCntIdToCases = new Map<Id,Case>();
        Map<Id,Case> cancelledCntIdToCases = new Map<Id,Case>();
        Map<Id,Case> cancelledCntIdToCases30Days = new Map<Id,Case>();
        list<Case> lstcs = new List<Case>();
        for(Case obC:scope){
            setProId.add(obC.ContactId);
            scopedCntIdToCases.put(obC.ContactId,obC);
        }
        List<Contact> lstCnts = [Select Id,UAC_currentAge__c,BirthDate from Contact where Id in :setProId];
        if(!lstCnts.isEmpty()){
            for (Contact obP :lstCnts){
                Date prevDay = System.Today() - 1;
                Date prev30Day = System.today() - 31;
                Date prev29Day = System.today() - 30;
                Integer daysDOB = obP.BirthDate.daysBetween(prevDay);
                if((Integer)Math.floor(daysDOB/365.2425) == 17){
                    if(scopedCntIdToCases.get(obP.Id).Status == strActive && (scopedCntIdToCases.get(obP.Id).Type == strPrs || scopedCntIdToCases.get(obP.Id).Type == strPrsTVPrA)){
                        qualifiedCntIdToCases.put(obP.Id,scopedCntIdToCases.get(obP.Id));
                    }
                    else if(scopedCntIdToCases.get(obP.Id).Status == strPend){
                        cancelledCntIdToCases.put(obP.Id,scopedCntIdToCases.get(obP.Id));
                    }
                }
                else if(((Integer)Math.floor(obP.BirthDate.daysBetween(prev30Day)/365.2425) == 17 && (Integer)Math.floor(obP.BirthDate.daysBetween(prev29Day)/365.2425) == 18)){
                    if(scopedCntIdToCases.get(obP.Id).Status == strActive && (scopedCntIdToCases.get(obP.Id).Type == strPrs || scopedCntIdToCases.get(obP.Id).Type == strPrsTVPrA)){
                        cancelledCntIdToCases30Days.put(obP.Id,scopedCntIdToCases.get(obP.Id));
                    }
                }
            }
        }
        if(!qualifiedCntIdToCases.isEmpty()){
            for (Case cse:qualifiedCntIdToCases.values()){
                qualifiedCseId.add(cse.Id);
                if(!qualifiedCseGlobal.containsKey(cse.Id)){
                    qualifiedCseGlobal.put(cse.Id,cse);
                }
            }
        }
        //4590 AC-2
        if(!cancelledCntIdToCases30Days.isEmpty()){
            for (Case cse:cancelledCntIdToCases30Days.values()){
                cancelled30DaysCseId.add(cse.Id);
                if(!cancelled30DaysCseGlobal.containsKey(cse.Id)){
                    cancelled30DaysCseGlobal.put(cse.Id,cse);
                }
                cse.Status = strCan;
                cse.UAC_hsPrsReasonforCancel__c = strAgeOut;
                lstcs.add(cse);
            }
        }        
        // 4590 - AC 3
        if(!cancelledCntIdToCases.isEmpty()){
            for(Case oc:cancelledCntIdToCases.values()){
                oc.Status = strCan;
                oc.UAC_hsPrsReasonforCancel__c = strAgeOut;
                lstcs.add(oc);
            }
        }
        if(!lstcs.isEmpty()){
            try{
                update lstcs;
            }
            catch(DMLException e){
                UAC_errorLog.logError(e.getMessage(), '', 'Hs Prs Email Batch update error', e.getStackTraceString());
            }
        }        
        // Populating Case Team of qualified (who just turned 18) HSPRS Referall Case
        List<CaseTeamMember> lstCseTm = [Select MemberId,ParentId,TeamRoleId from CaseTeamMember where ParentId in :qualifiedCseId]; // AC-1 recipients
        List<CaseTeamMember> lstCseTmCan = [Select MemberId,ParentId,TeamRoleId from CaseTeamMember where ParentId in :cancelled30DaysCseId]; // AC-2 recipients
        // AC-1  send Email list
        if(!lstCseTm.IsEmpty()){
            for(CaseTeamMember ctm:lstCseTm){
                if(!setUsersGlobal.contains(ctm.MemberId)){
                    setUsersGlobal.add(ctm.MemberId);
                }
                if(mapCseIdTolstCseTmGlobal.containsKey(ctm.ParentId)){
                    mapCseIdTolstCseTmGlobal.get(ctm.ParentId).add(ctm);
                } 
                else{
                    mapCseIdTolstCseTmGlobal.put(ctm.ParentId, new List<CaseTeamMember>{ctm});
                }
            }
        }
        // AC-2 send Email list
        if(!lstCseTmCan.IsEmpty()){
            for(CaseTeamMember ctm:lstCseTmCan){
                if(!setUsrs30DaysGlobal.contains(ctm.MemberId)){
                    setUsrs30DaysGlobal.add(ctm.MemberId);
                }
                if(mapCsIdTolstCsTm30DaysGlobal.containsKey(ctm.ParentId)){
                    mapCsIdTolstCsTm30DaysGlobal.get(ctm.ParentId).add(ctm);
                } 
                else{
                    mapCsIdTolstCsTm30DaysGlobal.put(ctm.ParentId, new List<CaseTeamMember>{ctm});
                }
            }
        }                
    }
    // This  will  send Emails to all qualified Cases Entry Teams
    global void finish(Database.BatchableContext bc){
        Set<Id> comboSet = new Set<Id>();
        comboset.addAll(setUsersGlobal);
        comboset.addAll(setUsrs30DaysGlobal);
        Map<Id, User> mapIdToUser = new Map<Id, User>([Select Id, Email from User where id = :comboset]);
        list<Messaging.SingleEmailMessage> lstmessages = new list<Messaging.SingleEmailMessage>();
        list<EmailTemplate> notifyHsprsTem = [select id, developername from emailtemplate where developername in (:Label.UC_denNotifyHsPrsEntryTeam,:Label.UC_notifyHsPrsEntryTeam)];
        List<String> toLst = new List<String>();
        List<String> recipientlist = new List<String>();
        if(!notifyHsprsTem.IsEmpty()){
            // AC-1 send Email compile loop
            for(Case obCs:qualifiedCseGlobal.values()){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                for (CaseTeamMember ctm :mapCseIdTolstCseTmGlobal.get(obCs.Id)) {
                    toLst.add(ctm.MemberId);
                }
                if (!toLst.IsEmpty()) {
                    for (String str : toLst) {
                      recipientlist.add(mapIdToUser.get(str).Email);
                    }
                }
                message.setToAddresses(recipientlist);
                for(EmailTemplate et:notifyHsprsTem){
                    if(et.developername == Label.UC_notifyHsPrsEntryTeam){
                        message.setTemplateId(et.id);
                    }
                }
                message.setWhatId(obCs.Id);
                message.settargetObjectId(obCs.ContactId);
                message.setTreatTargetObjectAsRecipient(false);
                lstmessages.add(message);
                toLst.clear();
                recipientlist.clear();                
            }
            // AC-2 send email compile loop
            for(Case obCs:cancelled30DaysCseGlobal.values()){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                for (CaseTeamMember ctm :mapCsIdTolstCsTm30DaysGlobal.get(obCs.Id)) {
                    toLst.add(ctm.MemberId);
                }
                if (!toLst.IsEmpty()) {
                    for (String str : toLst) {
                      recipientlist.add(mapIdToUser.get(str).Email);
                    }
                }
                message.setToAddresses(recipientlist);
                for(EmailTemplate et:notifyHsprsTem){
                    if(et.developername == Label.UC_denNotifyHsPrsEntryTeam){
                        message.setTemplateId(et.id);
                    }
                }
                message.setWhatId(obCs.Id);
                message.settargetObjectId(obCs.ContactId);
                message.setTreatTargetObjectAsRecipient(false);
                lstmessages.add(message);
                toLst.clear();
                recipientlist.clear();                
            }            
            if (lstmessages != null && lstmessages.size() > 0) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstmessages);
            }            
        }
    }
}