/**
 * @Description        : Queueable class for New Admission entry generation from case trigger 
 * @Author             : Piyush(Deloitte) 
 * @userStory          : ORRUAC 5560
 * @Test Class         : 
 * @Modification Log   : 03-18-2021 draft
 **/
public without sharing class UC_newAdmissionEntry implements Queueable{
    private List<Case> refLst;
    private Map<Id,Case> newCases;
    private string strQueueName = 'Care Provider';
    private static final string strPendingAdmissionStatus = 'Pending Admission';
    private static final Map<String, Schema.RecordTypeInfo> mapRecordTypesByDeveloperName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    private static final Id UACReferralRecordTypeId = mapRecordTypesByDeveloperName.get(Label.UAC_referralRecordTypeName).getRecordTypeId();
    private static Id TransferRequestRecordTypeId = mapRecordTypesByDeveloperName.get(Label.UAC_caseTransferRequest).getRecordTypeId();
    private static Id InfluxTransferRequestTypeId = mapRecordTypesByDeveloperName.get(Label.UAC_TransferRequestInflux).getRecordTypeId();    
    private static final string strcaseRecordTypeAdmission = Label.UAC_caseRecordTypeAdmission;  
    public UC_newAdmissionEntry(List<Case> caseList, Map<Id,Case> CaseMap) {
        this.refLst = caseList;
        this.newCases = CaseMap;
    }
    public void execute(QueueableContext context){
        if(refLst.isEmpty()){
            return;
        }
        Set<Id> setReferralIds = new Set<Id>();
        for (Case currentCase : refLst) {
          setReferralIds.add(currentCase.Id);
        }
        Map<Id, Case> MapParentIdToAdmissionEntry = new Map<Id, Case>();
        List<case> LstCaseTeamforAdmissionInsert = new List<case>();
        Map<Id, Id> mapContactIdToReferral = UAC_CaseTriggerHelper.getMostRecentReferral(refLst);
    
        Id queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:strQueueName limit 1].id;
        Set<Id> setReferralsIdsWithChildren = new Set<Id>();
        for (Case currentAdmission : [SELECT Id,ParentId FROM Case WHERE ParentId IN:setReferralIds AND RecordType.DeveloperName =:Label.UAC_caseRecordTypeAdmission]) {
          setReferralsIdsWithChildren.add(currentAdmission.ParentId);
        }
        for (Case caseCurrent : refLst) {
          if (setReferralsIdsWithChildren.contains(caseCurrent.Id)) {
            continue;
          }
          Case admissionEntry = new Case();
          admissionEntry.ParentId = caseCurrent.Id;
          admissionEntry.RecordTypeId = mapRecordTypesByDeveloperName.get(strcaseRecordTypeAdmission).getRecordTypeId();
          admissionEntry.Status = strPendingAdmissionStatus;
          admissionEntry.ContactId = caseCurrent.ContactId;
          admissionEntry.OwnerId = queueId;
          admissionEntry.UAC_programFacility__c = caseCurrent.UAC_programFacility__c;
          admissionEntry.UAC_programType__c = caseCurrent.UAC_programType__c;
          if (caseCurrent.RecordTypeId == UACReferralRecordTypeId) {
            admissionEntry.Type = Label.UAC_caseTypeInitialPlacement;
            admissionEntry.UAC_referral__c = caseCurrent.Id;
          } 
          else if (caseCurrent.RecordTypeId == TransferRequestRecordTypeId) {
            admissionEntry.Type = Label.UAC_caseTypeRegularTransfer;
            if(String.isNotBlank(admissionEntry.ContactId) && mapContactIdToReferral.containsKey(admissionEntry.ContactId) && mapContactIdToReferral.get(admissionEntry.ContactId) != null){
              admissionEntry.UAC_referral__c = mapContactIdToReferral.get(admissionEntry.ContactId);
            }
          } 
          else if (caseCurrent.RecordTypeId == InfluxTransferRequestTypeId) {
            admissionEntry.Type = label.UAC_caseTypeInfluxTransfer;
            if (String.isNotBlank(admissionEntry.ContactId) && mapContactIdToReferral.containsKey(admissionEntry.ContactId) && mapContactIdToReferral.get(admissionEntry.ContactId) != null) {
              admissionEntry.UAC_referral__c = mapContactIdToReferral.get(admissionEntry.ContactId);
            }
          }
          MapParentIdToAdmissionEntry.put(caseCurrent.id, admissionEntry); // Map of ParentId (Referral Case Id) as Key , AdmissionEntry Record as value.
        }
    
        if (!MapParentIdToAdmissionEntry.Isempty()) {
          Database.insert(MapParentIdToAdmissionEntry.values(), false);
          // loop over referral Case Id to get the Admission Record Id
          for (Id ParentCase : MapParentIdToAdmissionEntry.keyset()) {
            // If admission Id equals to null ? Admission Case Creation Failed : Admission created
            if (MapParentIdToAdmissionEntry.get(ParentCase).id == null) {
                newCases.get(ParentCase).addError('Admission Entry Creation Failed');
            } 
            else {
              LstCaseTeamforAdmissionInsert.add(MapParentIdToAdmissionEntry.get(ParentCase)); // Creating a List of successfully Inserted Admission entry
            }
          }
        }
    
        if (!LstCaseTeamforAdmissionInsert.isEmpty()) {
          try {
            UAC_CaseTriggerHelper.CaseTeamforAdmissionInsert(LstCaseTeamforAdmissionInsert); // Method to create CaseTeamMember
          } 
          catch (Exception e) {
            UAC_errorLog.platformEventErrorLog(e.getMessage(),'', 'Case Trigger', e.getStackTraceString());
          }
        }        

    }
}