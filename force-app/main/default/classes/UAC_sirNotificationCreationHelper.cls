/**
* @File Name          : UAC_sirNotificationCreationHelper.cls
* @Description        : the class utilizes UAC_sirNotificationTable__mdt framework to create system generated SIR notifications for every SIR
* @Author             : Vaibhav Kudesia (Deloitte)
* @Group              : 
* @Test Class         : UAC_sirNotificationTriggerHelperTest
* @Modification Log   :
*
* Ver       Date            Author                      Modification
* 1.0    7/31/2020    Vaibhav Kudesia (Deloitte)     Initial Implementation.
* 2.0    8/09/2020    Vaibhav Kudesia (Deloitte)     Changed Program Team reference from UAC Program to Event Program on SIR.
**/

public without sharing class UAC_sirNotificationCreationHelper {
    
   /**
   * @description receives the SIR list and calls methods to gather Roles for SIR notification and calls create SIR notification method.
   * @author Vaibhav Kudesia (Deloitte) | 7/31/2020
   * @param lstSIR List of Sir Notification to process
   * @return void
   **/    
    @InvocableMethod
    public static void createNotificationData(List<UAC_sir__c> lstSIR){
        List<UAC_sirNotification__c> lstSIRNotification = new List<UAC_sirNotification__c>();        
        Map<Id,Id> mapUACAccountIDs = new Map<Id,Id>();
        List<Id> lstSIRIds = new List<Id>();
        List<UAC_sirNotificationTable__mdt> lstSIRNT = [Select Id,UAC_category__c,UAC_externalagencyRoles__c,UAC_orrRoles__c,UAC_subCategory__c,UAC_subCategoryField__c,
                                                     UAC_additionalSubCategory__c,UAC_additionalSubCategoryField__c,UAC_reporterFollowUpRole__c,UAC_typeOfSIR__c from UAC_sirNotificationTable__mdt] ;
        List<Id> lstRelatedEvent = new List<Id>(); //  lstRelatedUAC
        for(UAC_sir__c objSIR : lstSIR){
        //  lstRelatedUAC.add(objSIR.UAC_uaclookup__c);
            lstRelatedEvent.add(objSIR.UAC_eventID__c);
            lstSIRIds.add(objSIR.Id);
        }
        /* 
        for(Contact objUAC : [Select Id,AccountId,UAC_program__c from Contact where Id =: lstRelatedUAC]){
           mapUACAccountIDs.put(objUAC.Id,objUAC.UAC_program__c);
              //mapUACAccountIDs.add(objUAC.UAC_program__c);
            }
		*/
        for(UAC_Event__c objEvent : [Select Id,UAC_programID__c from UAC_Event__c where Id =: lstRelatedEvent]){
            mapUACAccountIDs.put(objEvent.Id,objEvent.UAC_programID__c);
        }
        Map<Id,List<AccountTeamMember>> mapEntityTeamMembers = new Map<Id,List<AccountTeamMember>>();
        for(AccountTeamMember objACT : [Select Id, UserId, User.Email, AccountId, TeamMemberRole from AccountTeamMember where AccountId =: mapUACAccountIDs.values()]){
            List<AccountTeamMember> lstTemp = new List<AccountTeamMember>();
            if(!mapEntityTeamMembers.isempty() && !mapEntityTeamMembers.get(objACT.AccountId).isEmpty()){
                lstTemp = mapEntityTeamMembers.get(objACT.AccountId);
            }
            lstTemp.add(objACT);
            mapEntityTeamMembers.put(objACT.AccountId,lstTemp);           
        }
        if(!mapEntityTeamMembers.keyset().isEmpty()){
            for(UAC_sir__c objSIR : lstSIR){
                Map<String,String> mapRolltype = getSIRRolesForNotification(objSIR,lstSIRNT);
                for(AccountTeamMember objACT : mapEntityTeamMembers.get(mapUACAccountIDs.get(objSIR.UAC_eventID__c))){ //UAC_uaclookup__c
                    if(mapRolltype.keyset().contains(objACT.TeamMemberRole)){
                       lstSIRNotification.add(createNotification(objSIR.Id,objACT.UserId,mapRolltype.get(objACT.TeamMemberRole),objACT.TeamMemberRole)) ;
                    }                    
                }
                if(mapRolltype.keyset().contains('Reporter')){
                       lstSIRNotification.add(createNotification(objSIR.Id,objSIR.createdbyId,mapRolltype.get('Reporter'),'Reporter')) ;
                }  
            }
        }
            List<UAC_sirNotification__c> lstSIRNotificationtodelete = new List<UAC_sirNotification__c>();
            for(UAC_sirNotification__c objSN : [Select Id from UAC_sirNotification__c where UAC_autoPopulated__c = True and UAC_sir__c =: lstSIRIds ] ){
            	objSN.UAC_autoPopulated__c = false;
                lstSIRNotificationtodelete.add(objSN);
            }
            if(!lstSIRNotificationtodelete.isEmpty()){
            	update lstSIRNotificationtodelete ;
                delete lstSIRNotificationtodelete ; 
            }
        if(!lstSIRNotification.isEmpty()){
            List<Database.SaveResult> lstSaveResult = Database.insert(lstSIRNotification,false);
            // Inspect save result 
            for (Database.SaveResult objSaveResult : lstSaveResult) {
                if (!objSaveResult.isSuccess()) {
                    for(Database.Error objError : objSaveResult.getErrors()) {                        
                        UAC_errorLog.platformEventErrorLog(objError.getMessage(),'', 'UAC_sirNotificationCreationHelper','');  
                      }
                  }
              }
        }
    }

   /**
   * @description receives the SIR and SIR metadata to create map of Roles for SIR notification.
   * @author Vaibhav Kudesia (Deloitte) | 7/31/2020
   * @param UAC_sir__c objSIR SIR record and metadata table for processing
   * @param List<UAC_sirNotificationTable__mdt> lstsirNotificationMTDTA
   * @return Map<String,String>
   **/ 
  public static Map<String,String> getSIRRolesForNotification(UAC_sir__c objSIR, List<UAC_sirNotificationTable__mdt> lstsirNotificationMTDTA) {
    Map<String, String> mapRolltype = new Map<String, String>();

    for (UAC_sirNotificationTable__mdt objSIRNT : lstsirNotificationMTDTA) {
      Boolean boolCreateSIRNotification = false;
      if (objSIRNT.UAC_typeOfSIR__c == objSIR.UAC_sirType__c
          && String.isNotBlank((String) objSIR.UAC_category__c)) {
        for (String strCat : objSIR.UAC_category__c.split(';')) {
          if (objSIRNT.UAC_category__c != null && objSIRNT.UAC_category__c.contains(strCat)) {
            if (objSIRNT.UAC_subCategoryField__c != null
                && String.isNotBlank((String) objSIR.get(objSIRNT.UAC_subCategoryField__c))
                && objSIRNT.UAC_subCategory__c != null) {
              for (String strSubCat :
                  ((String) objSIR.get(objSIRNT.UAC_subCategoryField__c)).split(';')) {
                if (objSIRNT.UAC_subCategory__c.contains(strSubCat)) {
                  if (objSIRNT.UAC_additionalSubCategoryField__c != null
                      && String.isNotBlank(
                          (String) objSIR.get(objSIRNT.UAC_additionalSubCategoryField__c))
                      && objSIRNT.UAC_additionalSubCategory__c != null) {
                    for (String strAddSubCat :
                        ((String) objSIR.get(objSIRNT.UAC_additionalSubCategoryField__c))
                            .split(';')) {
                      if (objSIRNT.UAC_additionalSubCategory__c.contains(strAddSubCat)) {
                        boolCreateSIRNotification = true;
                      }
                    }
                  } else if (objSIRNT.UAC_additionalSubCategory__c == null) {
                    boolCreateSIRNotification = true;
                  }
                }
              }
            } else if (objSIRNT.UAC_subCategory__c == null) {
              boolCreateSIRNotification = true;
            }
          }
        }
      }
      if (boolCreateSIRNotification) {
        for (String strRole : objSIRNT.UAC_externalagencyRoles__c.split(';')) {
          mapRolltype.put(strRole, 'External Agency');
        }
        for (String strRole : objSIRNT.UAC_orrRoles__c.split(';')) {
          mapRolltype.put(strRole, 'ORR');
        }
        for (String strRole : objSIRNT.UAC_reporterFollowUpRole__c.split(';')) {
          mapRolltype.put(strRole, 'Reporter & Follow-Up');
        }
      }
    }
    return mapRolltype;
  }

   /**
   * @description creates instance of SIR notification to be inserted.
   * @author Vaibhav Kudesia (Deloitte) | 7/31/2020
   * @param SIR notification record details
   * @return UAC_sirNotification__c
   **/    
    public static UAC_sirNotification__c createNotification(Id SIRId,Id UserId,String Type, String Title){
        UAC_sirNotification__c objSIRNotification = new UAC_sirNotification__c();
        objSIRNotification.UAC_autoPopulated__c = True;
        objSIRNotification.UAC_sir__c = SIRId;
        objSIRNotification.UAC_user__c = UserId;
        objSIRNotification.UAC_title__c = Title;
        objSIRNotification.UAC_type__c = Type;        
        return objSIRNotification;
    }
}