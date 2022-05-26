/**
* @File Name          : UAC_swbBatch.cls (Parent Batch)
* @Description        : ORRUAC-4216 : Batch class chaining to auto populate Case team for above Parent Batch
* @Author             : Piyush(Deloitte)
* @Test Class         : UAC_swbBatchTest.cls
* @Modification Log   :
* Ver       Date            Author               Modification
* 1.0    11/19/2020      Piyush(Deloitte)     Initial Implementation.
**/
global without sharing class UAC_swbCaseTeamBatch implements Database.Batchable<sObject>{
    private list<Case> lstSWB;
    public UAC_swbCaseTeamBatch (list<Case> inputSWBBatch){
        lstSWB = inputSWBBatch;
    }

    global Iterable<sObject> start(Database.BatchableContext bc){
        return lstSWB;
    }

    global void execute(Database.BatchableContext BC, List<Case> lstSWB){
        Set<Id> setAdmId = new Set<Id>();
        Set<Id> setSwbId = new Set<Id>();
        List<CaseTeamMember> csslst = new List<CaseTeamMember>();
        Map<Id, List<CaseTeamMember>> mapCseIdTolstCseTm = new Map<Id, List<CaseTeamMember>>();
        for(Case cs:lstSWB){
            setSwbId.add(cs.Id);
        }
        for(Case obC:lstSWB){
          if(obC.UAC_admission__c != null){
            setAdmId.add(obC.UAC_admission__c);
          }
        }
        List<CaseTeamMember> lstCseTm = [Select MemberId,ParentId,TeamRoleId from CaseTeamMember where ParentId =:setAdmId and ParentId not in :setSwbId];
        if(!lstCseTm.IsEmpty()){
          for(CaseTeamMember ctm:lstCseTm){
            if(mapCseIdTolstCseTm.containsKey(ctm.ParentId)){
              List<CaseTeamMember> csTmlst = mapCseIdTolstCseTm.get(ctm.ParentId);
              csTmlst.add(ctm);
            } 
            else{
              mapCseIdTolstCseTm.put(ctm.ParentId, new List<CaseTeamMember>{ctm});
            }
          }
        }
        for(Case obcse:lstSWB){
          if(mapCseIdTolstCseTm.get(obcse.UAC_admission__c) != null){
            for(CaseTeamMember ctm:mapCseIdTolstCseTm.get(obcse.UAC_admission__c)){
                CaseTeamMember cstm = new CaseTeamMember();
                cstm.ParentId = obcse.Id;
                cstm.MemberId = ctm.MemberId;
                cstm.TeamRoleId = ctm.TeamRoleId;
                csslst.add(cstm);
            }
          }
        }
        if(!csslst.IsEmpty()){
          insert csslst;
        }        
    }

    global void finish(Database.BatchableContext bc){
    }    
}