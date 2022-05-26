/**
 * @File Name          : UAC_contentDocumentLinkTriggerHelper.cls
 * @Description        : Helper method for UAC_contentDocumentLinkTriggerHelper
 * @Author             : Ankur(Deloitte)
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author                Modification
 * 1.0    8/23/2020      Ankur Aggarwal(Deloitte) Initial Version
 * 1.1	  9/22/2020	     Ranjith kumar(AI-Vets)	  ORRUAC-1564: Adding Logic to update ShareType for Health Evalution Documents
* 2.0    10/14/2020      Vaibhav Kudesia(Deloitte)	 Added before insert logic to restrict Document upload for Monitoring Visit based on status.
 * 3.0    10/23/2020     Nithin Malla(Deloitte)	 	 ORRUAC-2972: Program Staff Upload restrictions on background check uploads.
 * 3.1    04/14/2020     Abhisek Pati (Deloitte)   Added Null check for Linked Entity and removed Debug statement.
 **/
public with Sharing class UAC_contentDocumentLinkTriggerHelper { 
  private static boolean run = true;
  public
  final static Id idLegalDocumentRecordType =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get(label.UAC_legalDocument)
          .getRecordTypeId();   
  public
  final static Id ID_RECORD_TYPE_OTHER =
      Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
          .get(Label.UAC_contentVersionRecordTypeApiNameOther)
          .getRecordTypeId();  
  public 
  final static Id ID_RECORD_TYPE_LSPRECORD =
  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get(label.UAC_legalServiceProviderRecord)
          .getRecordTypeId();
  public
  static void linkToLSPRecord(Map<Id,ContentDocumentLink> newItems){
    if(run){
      run = false;
      set<Id> setContentDocumentId = new set<id>();
      map<String,list<contentDocumentlink>> mapContentDocumentlink = new map<String,list<contentDocumentlink>>();
      for(ContentDocumentLink objContentDocumentLink : newItems.values()){
        String SobjectType = objContentDocumentLink.LinkedEntityId.getsobjecttype().getdescribe().getname();
        if(SobjectType == label.UAC_CaseSobjectName || SobjectType ==  label.UAC_ContactSobjectName){
          list<contentDocumentlink> lstcontentDocumentlink = new list<contentDocumentlink>();
          if(mapContentDocumentlink.containskey(SobjectType)){
            lstcontentDocumentlink = mapContentDocumentlink.get(SobjectType);
          }
          lstcontentDocumentlink.add(objContentDocumentLink);
          mapContentDocumentlink.put(SobjectType,lstcontentDocumentlink);
          setContentDocumentId.add(objContentDocumentLink.contentdocumentid);
        }        
      }

      map<id,ContentDocument> mapContectDocument = new map<id,ContentDocument>([select id,(select id,islatest,recordtype.name,uac_documenttype__C  from contentversions where islatest = true) from contentdocument where id in :setContentDocumentId order by createddate desc]);
      
      list<id> lstContactIds = new list<id>();
      list<id> lstAdmissionRecordIds = new list<id>();
      list<ContentDocumentLink> lstfinalContentDocumentLink = new list<ContentDocumentLink>();

      if(mapContentDocumentlink.containskey(label.UAC_ContactSobjectName)){
        list<contentDocumentlink> lstContentDocument = mapContentDocumentlink.get(label.UAC_ContactSobjectName);
        for(contentDocumentlink objcontentDocumentlink : lstContentDocument){
          ContentVersion objContentVersion = mapContectDocument.get(objcontentDocumentlink.ContentDocumentId).contentversions[0];
          if(objContentVersion.Recordtypeid == idLegalDocumentRecordType && 
              (objContentVersion.uac_documenttype__c ==Label.UAC_DHSDocumentNTADocumentType ||
              objContentVersion.uac_documenttype__c ==Label.UAC_DHSDocumentI213DocumentType ||
              objContentVersion.uac_documenttype__c ==Label.UAC_BirthCertificateUACDocumentType ||
              objContentVersion.uac_documenttype__c ==Label.UAC_placementIdentificationDocumentType)
            ){
            lstContactIds.add(objcontentDocumentlink.linkedEntityId);
            lstfinalContentDocumentLink.add(objcontentDocumentlink);
          }
        }
      }
      if(mapContentDocumentlink.containskey(label.UAC_CaseSobjectName)){
        list<contentDocumentlink> lstContentDocument = mapContentDocumentlink.get(label.UAC_CaseSobjectName);
        for(contentDocumentlink objcontentDocumentlink : lstContentDocument){
          ContentVersion objContentVersion = mapContectDocument.get(objcontentDocumentlink.ContentDocumentId).contentversions[0];
          if(objContentVersion.Recordtypeid == ID_RECORD_TYPE_OTHER && objContentVersion.uac_documenttype__c == label.UAC_placementAuthorizationDocumentType){
            lstAdmissionRecordIds.add(objcontentDocumentlink.linkedEntityId);
            lstfinalContentDocumentLink.add(objcontentDocumentlink);
          }
        }
      }      

      list<case> AdmissionRecords = [select id,contactid  from case where id in :lstAdmissionRecordIds ];
      map<id,id> mapAdmissionContact = new map<id,id>();
      for(case objCase : AdmissionRecords){
        mapAdmissionContact.put(objCase.id,objCase.contactid);
        lstContactIds.add(objCase.contactid);
      }

      map<id,contact> mapContactsAndLSP = new map<id,contact>([select id,(select id from cases where recordtypeid = :ID_RECORD_TYPE_LSPRECORD ) from contact where id in :lstContactIds]);
      
      list<contentDocumentlink> lstNewcontentDocumentlink = new list<contentDocumentlink>();
      set<id> setlegalCaseIds = new set<id>();

      for(contentDocumentlink objcontentDocumentlink :lstfinalContentDocumentLink){
        ContentDocumentLink objNewcontentDocumentlink = new ContentDocumentLink();
        objNewcontentDocumentlink.ContentDocumentId = objcontentDocumentlink.ContentDocumentId;
        objNewcontentDocumentlink.Visibility ='AllUsers';
        objNewcontentDocumentlink.ShareType ='I';
        String SobjectType = objcontentDocumentlink.LinkedEntityId.getsobjecttype().getdescribe().getname();
        
		  if(SobjectType == label.UAC_ContactSobjectName && mapContactsAndLSP.containskey(objcontentDocumentlink.LinkedEntityId) &&
			   mapContactsAndLSP.get(objcontentDocumentlink.LinkedEntityId).cases != null &&
			   mapContactsAndLSP.get(objcontentDocumentlink.LinkedEntityId).cases.size() > 0){
			objNewcontentDocumentlink.LinkedEntityId = mapContactsAndLSP.get(objcontentDocumentlink.LinkedEntityId).cases[0].id;
			lstNewcontentDocumentlink.add(objNewcontentDocumentlink);
		  }
        
     
          if(SobjectType == label.UAC_CaseSobjectName && mapAdmissionContact.containskey(objcontentDocumentlink.LinkedEntityId) && mapContactsAndLSP.containskey(mapAdmissionContact.get(objcontentDocumentlink.LinkedEntityId)) &&
              mapContactsAndLSP.get(mapAdmissionContact.get(objcontentDocumentlink.LinkedEntityId)).cases != null &&
              mapContactsAndLSP.get(mapAdmissionContact.get(objcontentDocumentlink.LinkedEntityId)).cases.size() > 0){
            objNewcontentDocumentlink.LinkedEntityId = mapContactsAndLSP.get(mapAdmissionContact.get(objcontentDocumentlink.LinkedEntityId)).cases[0].id;
            lstNewcontentDocumentlink.add(objNewcontentDocumentlink);
          }
        
        setlegalCaseIds.add(objNewcontentDocumentlink.LinkedEntityId);
      }
      if(!lstNewcontentDocumentlink.isEmpty())
      insert lstNewcontentDocumentlink;
    }
    
    //[select id from contentversion WHERE IsLatest=true AND ContentDocumentId IN :setContentDocumentId]
  }

  /*  @author       Ranjith kumar
  @description  Before Insert - ORRUAC-1564: Upadating ShareType for Health Evalution Documents
*/ 
  public
  static void updateShareForHealthEvaluation(List<ContentDocumentLink> newItems){
    for(ContentDocumentLink objContentDocumentLink : newItems){
      if (objContentDocumentLink.LinkedEntityId != null) {
      String SobjectType = objContentDocumentLink.LinkedEntityId.getsobjecttype().getdescribe().getname();          
      if(SobjectType ==  'UAC_healthEvaluation__c'|| SobjectType ==  'UAC_test__c'){
        objContentDocumentLink.Visibility ='AllUsers';
        objContentDocumentLink.ShareType ='I';
        }
      }
    }
  }
  /**
   * @description checks for Program Staff can upload Documents when Monitoring Visit in the Following Statuses: Pre-Monitoring, On-Site, Post-Monitoring.
   * @author Vaibhav kudesia (Deloitte) | 10/13/2020
   * @param oldRecs List of ContentVersion to process
   * @return void
   **/ 
public 
static void verifycontentdocumentforMonitoringvisit(List<ContentDocumentLink> newRecs){
    list<Id> lstMonVisit = new list<Id>();        
    list<Id> lstBackGroundCheck = new list<Id>();   
    list<Id> lstBackGroundCheckToError = new list<Id>();   
    list<String> lstMonVisitStatus = Label.UAC_monitoringVisitStatusForDocUpdate.split(';');
    list<String> lstProgramStaffProfile = Label.UAC_programStaffForUploadRestriction.split(',');
    list<String> lstBackGroundCheckType = Label.UAC_backGroundCheckType.split(';');

    String profileName = [Select Name from Profile where Id=:UserInfo.getProfileId()].Name;

    for(ContentDocumentLink objContentDoc : (List<ContentDocumentLink>)newRecs){  
        String SobjectType = objContentDoc.LinkedEntityId.getsobjecttype().getdescribe().getname(); 
        if(SobjectType == 'UAC_monitoring__c'){
         lstMonVisit.add(objContentDoc.LinkedEntityId);                            
        }
        if(SobjectType == Label.UAC_backGroundCheckSObject){
          lstBackGroundCheck.add(objContentDoc.LinkedEntityId);                            
        }
    }
    
    for(UAC_monitoring__c objMonV : [Select Id, UAC_status__c from UAC_monitoring__c where Id =: lstMonVisit]){
        if(lstMonVisitStatus.contains(objMonV.UAC_status__c)){
            lstMonVisit.remove(lstMonVisit.indexof(objMonV.Id));
        }
    }

    for(UAC_backgroundCheck__c objbackground : [Select Id,UAC_backgroundCheckType__c from UAC_backgroundCheck__c where Id =: lstBackGroundCheck]){
      if(lstProgramStaffProfile.contains(profileName) && lstBackGroundCheckType.contains(objbackground.UAC_backgroundCheckType__c)){
          lstBackGroundCheckToError.add(objbackground.Id);
      }
    }

    for(ContentDocumentLink objContentDoc : (List<ContentDocumentLink>)newRecs){  
        if(lstMonVisit.contains(objContentDoc.LinkedEntityId)){
         objContentDoc.addError(Label.UAC_monVisitDocUploadRestrictionMessage);                            
        }
        if(lstBackGroundCheckToError.contains(objContentDoc.LinkedEntityId)){
          objContentDoc.addError(Label.UAC_backGroundCheckErrorMsg);                            
        }
    }        
}
}