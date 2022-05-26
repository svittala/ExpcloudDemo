/**
 * @File Name          : UAC_contactTriggerHandler.cls
 * @Description        : Handles all Contact trigger traffic
 * @Author             : Chaitanya Nandamuri (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Test Class         : UAC_contactTriggerTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/29/2020, 3:03:36 PM
 * @Modification Log   :
 * Ver       Date            Author      		              Modification
 * 1.0    5/13/2020   Chaitanya Nandamuri (Deloitte)      Initial Implementation
 * 1.1    5/29/2020   Sachet Khanal (Deloitte)            ORRUAC_523 Populate Administrative Account
 * 1.2    6/23/2020   Abhisek Pati (Deloitte)             ORRUAC-1013 Populate A# on Cases 
 * 1.3    7/29/2020   Anupreeta Chakraborty               ORRUAC-213-Added new method to create IME records on UAC status update. 
 * 1.4    10/06/2020  Rahul Roy							              ORRUAC-2913 Added new method to update values on Referral Case
 * 2.1    11/03/2020  Sudeep Chintala(Deloitte)	          Adding bypass logic
 * 2.2    11/11/2020  Satish Kota(Kvortex)	              ORRUAC-4129 Adding Before Insert and Before Update Logic
 * 2.3	  03/01/2021  Nithin Malla (Deloitte) 			      ORRUAC-5322 Assign Administrative Account to new Adult Contact Children
 * 2.4	  03/18/2021  Nithin Malla (Deloitte) 			      ORRUAC-5561 Logic to handle Status Admitted Updates and
 *                       														      Commented these methods and moved to Async Queueable
 *                      														      createIMEonStatusAdmitted(),
 *                      														      createLegalStatusonStatusAdmitted(),
 *                      														      createInitialMentalHEonStatusAdmitted()
 * 2.5	  07/12/2021   Satish (Kvortex)					          ORRUAC-6025 Added Exclusion Logic
 **/
public
without sharing class UAC_contactTriggerHandler implements UAC_ITriggerHandler {

/**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassContactTrigger__c;
  }
  public
  void beforeInsert(List<Contact> newItems) {
    for (Contact newContact : newItems) {
      // ORRUAC-523: Assign Administrative Account to new Adult Contact
      // ORRUAC-5322: Assign Administrative Account to new Adult Contact Children
      if (newContact.RecordTypeId == UAC_contactTriggerHelper.ID_ADULT_CONTACT_RECORD_TYPE ||
         newContact.RecordTypeId == UAC_contactTriggerHelper.ID_ADULT_CONTACTS_CHILDREN_RECORD_TYPE) {
        newContact.AccountId = UAC_utilities.OBJ_ACCOUNT_SETTINGS.UAC_administrativeAccountId__c;
      }
    }
    UAC_contactTriggerHelper.findUACFamilyGroup(newItems);
    //Begin of Change ORRUAC-106 - Saluatation to blank --Priyanka--6/3/20--//
    UAC_contactTriggerHelper.updateContactSalutation(newItems);
    //End of Change ORRUAC-106 - Saluatation to blank --Priyanka--6/3/20---//
    //Begin of Change ORRUAC-1936 - Ankur Aggarwal
    UAC_contactTriggerHelper.assignOwnerHSPRSContractor(newItems);
    //End of Change ORRUAC-1936  - Ankur Aggarwal  
    //Begin of Change -4129 - Satish Kota
    UAC_contactTriggerHelper.updateMostRecentProgram((List<contact>)newItems,null);
    //End of Change -4129 - Satish Kota
  }

  public
  void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    // Change to add if condision for Exclusion logic -- Satish 07/12/21 ORRUAC-6025
    if (UC_exclusionLogicService.getInstance().runExclusionsForContacts(newItems)) {     
      //Begin of Change ORRUAC-106 - Saluatation to blank --Priyanka--6/3/20--//
      UAC_contactTriggerHelper.updateContactSalutation((List<contact>) newItems.values());
      //End of Change ORRUAC-106 - Saluatation to blank --Priyanka--6/3/20---//
      //Begin of Change ORRUAC-1936 - Ankur Aggarwal
      UAC_contactTriggerHelper.assignOwnerHSPRSContractor(newItems.values());
      //End of Change ORRUAC-1936  - Ankur Aggarwal  
      //Begin of Change ORRUAC-4129 - Satish Kota
      UAC_contactTriggerHelper.updateDischargeNotificationField((List<contact>)newItems.values(),  (Map<Id, Contact>)oldItems);    
      UAC_contactTriggerHelper.updateMostRecentProgram((List<contact>)newItems.values(),  (Map<Id, Contact>)oldItems);    
      //End of Change ORRUAC-4129  - Satish Kota
    }
  }

  public
  void beforeDelete(Map<Id, SObject> oldItems) {
    // Change to add if condision for Exclusion logic -- Satish 07/12/21 ORRUAC-6025
    UC_exclusionLogicService.getInstance().runExclusionsForContacts(oldItems);
  }

  public
  void afterInsert(Map<Id, SObject> newItems) {
    // Change to add if condision for Exclusion logic -- Satish 07/12/21 ORRUAC-6025
    if (UC_exclusionLogicService.getInstance().runExclusionsForContacts(newItems)) { 
      //Begin of Change ORRUAC-1936 - Ankur Aggarwal
      UAC_contactTriggerHelper.updateAcountTeamMemberSubcontractor((Map<Id, Contact>)newItems);
      //End of Change ORRUAC-1936  - Ankur Aggarwal    
    }   
  }

  public
  void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    // Begin of Change ORRUAC-1013 --Abhisek--6/22/20
    UAC_contactTriggerHelper.populateANumOnCases(
        (Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);
    // End of Change ORRUAC-1013 --Abhisek--6/22/20

    //Added by James 3/5/2021 to reduce unneeded queries
    Map<Id, Contact> mapAdmittedCases = UAC_contactTriggerHelper.getAdmittedContacts(
        (Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);
    // ORRUAC-213-Logic to create IME records on UAC status update.
    if (!mapAdmittedCases.isEmpty()) {
      //ORRUAC-5561 Logic to handle Status Admitted Updates
      UAC_contactTriggerHelper.statusAdmittedUpdates(mapAdmittedCases, (Map<Id, Contact>) oldItems);
      //Commented this logic as this is being handle in Queueable class
      /*UAC_contactTriggerHelper.createIMEonStatusAdmitted((Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);	
      // ORRUAC-2798-Logic to create Initial Mental Health Evaluation records on UAC status update.      
      UAC_contactTriggerHelper.createInitialMentalHEonStatusAdmitted((Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);
      UAC_contactTriggerHelper.createLegalStatusonStatusAdmitted((Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);*/
    }
    //Begin of Change ORRUAC-2133 --Ankur Aggarwal--8/21/20
    UAC_contactTriggerHelper.updateLegalStatusonProgramChange((Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);
  
    //ends of Change ORRUAC-2133 --Ankur Aggarwal--8/21/20
    //Begin of Change ORRUAC-1936 - Ankur Aggarwal
    UAC_contactTriggerHelper.updateAcountTeamMemberSubcontractor((Map<Id, Contact>)newItems);
    //End of Change ORRUAC-1936  - Ankur Aggarwal
    //Begin of Change ORRUAC-2913 --Rahul--10/05/20
    UAC_contactTriggerHelper.populateValuesOnReferralCase((Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);
    //End of Change ORRUAC-2913 --Rahul
    //Begin of Change --James--11/09/20
    UAC_contactTriggerHelper.updateChildCasesOnAccountChange(
        (Map<Id, Contact>) newItems, (Map<Id, Contact>) oldItems);
    //End of Change --James--11/09/20
  }

  public
  void afterDelete(Map<Id, SObject> oldItems) {
  }

  public
  void afterUndelete(Map<Id, SObject> oldItems) {
  }
}