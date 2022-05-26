/**
 * @File Name          : UAC_adultContactRelationshipHandler.cls
 * @Description        : Handles all AdultContactRelationship trigger traffic
 * @Author             : Priyanka Bolla (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Test Class         : UAC_adultContactRelationshipHelperTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/1/2020, 5:27:04 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/7/2020   Priyanka Bolla (Deloitte)     Initial Version
 * 1.1    5/18/2020   Sachet Khanal (Deloitte)     Refactored logic to avoid multiple for loops
 * 1.2    5/18/2020   Sachet Khanal (Deloitte)     ORR-256: Clear Explain Relationship to UAC
 * 1.3    6/1/2020    Sachet Khanal (Deloitte)     ORRUAC-414 Check duplicate relationships
 * 1.4    9/22/2020   Chaitanya Nandamuri(Deloitte) ORRUAC-2308 Collect UAC Id for Primary Sponser ACR
 * 2.1    11/03/2020     Sudeep Chintala(Deloitte)	 Adding bypass logic
 **/
public
with sharing class UAC_adultContactRelationshipHandler implements UAC_ITriggerHandler {
 /**
   * @description Adding Bypass logic
   * @author Sudeep Chintala (Deloitte) | 11/03/2020
  **/
      public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassAdultContactRelTrigger__c;
  }


  /*  @author       Priyanka Bolla
      @description  Before Insert
      @param        N/A
      @return       void
  */
  public
  void beforeInsert(List<UAC_adultContactRelationship__c> lstNewItems) {
    // Loop through all records once and collect items if required
    for (UAC_adultContactRelationship__c objNew : lstNewItems) {
      // Check if Date Assigned should be populated
      if (objNew.UAC_relationshipType__c == Label.UAC_typeOfSponsor) {
        objNew.UAC_dateAssignedAsPrimarySponsor__c = System.now();
      }
    }
    UAC_adultContactRelationshipHelper.validateOnePrimarySponsor(lstNewItems);
    // ORRUAC-414 - Validate Adult Contact Relationship uniqueness
    UAC_adultContactRelationshipHelper.checkDuplicate(lstNewItems);
  }

  /*  @author       Priyanka Bolla
      @description  Before Update
      @param        N/A
      @return       void
  */
  public
  void beforeUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {

    List<UAC_adultContactRelationship__c> lstValidateOnrPrimarySponsor =
        new List<UAC_adultContactRelationship__c>();
    List<UAC_adultContactRelationship__c> lstValidateUniqueness =
        new List<UAC_adultContactRelationship__c>();

    // Prepare set of Relationship to UAC values requiring Explain Relationship to UAC
    Set<String> setExplainRelationshipToUACRequired = new Set<String>{
        Label.UAC_relationshipToUACOtherDistantRelative, Label.UAC_relationshipToUACUnrelated};

    // Loop through all records once and collect into List/Map if required
    for (Id idNewItemId : mapNewItems.keySet()) {
      UAC_adultContactRelationship__c objNew =
          (UAC_adultContactRelationship__c) mapNewItems.get(idNewItemId);
      UAC_adultContactRelationship__c objOld =
          (UAC_adultContactRelationship__c) mapOldItems.get(idNewItemId);

      if (objNew.UAC_relationshipType__c != objOld.UAC_relationshipType__c) {
        // Add to list for One Primary Sponsor validation
        lstValidateOnrPrimarySponsor.add(objNew);
        // Check if Date Assigned as Sponsor should be populated
        if (objNew.UAC_relationshipType__c == Label.UAC_typeOfSponsor) {
          objNew.UAC_dateAssignedAsPrimarySponsor__c = System.now();
        }
        // Check if Declined Date should be populated
        if (objNew.UAC_relationshipType__c == Label.UAC_typeDeclined) {
          objNew.UAC_declinedDate__c = System.now();
        }
        //Updating Declined fields to null when type is not declined
        if(objNew.UAC_relationshipType__c != Label.UAC_typeDeclined){
          objNew.UAC_declinedDate__c = null;
          objNew.UAC_declinedReason__c = null;
          objNew.UAC_declinedReasonNotes__c = null;
            
        }
      }
      // ORRUAC-256: Check if Explain Relationship to UAC should be cleared
      if ((objNew.UAC_relationshipToUAC__c != objOld.UAC_relationshipToUAC__c
              || objNew.UAC_explainRelationshipToUAC__c != objOld.UAC_explainRelationshipToUAC__c)
          && !setExplainRelationshipToUACRequired.contains(objNew.UAC_relationshipToUAC__c)) {
        objNew.UAC_explainRelationshipToUAC__c = null;
      }
      // Add to list for uniqueness validation if UAC or Adult Contact lookup changes
      if (objNew.UAC_uacLookup__c != objOld.UAC_uacLookup__c
          || objNew.UAC_adultContact__c != objOld.UAC_adultContact__c) {
        lstValidateUniqueness.add(objNew);
      }
    }
    if (!lstValidateOnrPrimarySponsor.isEmpty()) {
      UAC_adultContactRelationshipHelper.validateOnePrimarySponsor(lstValidateOnrPrimarySponsor);
    }
    if (!lstValidateUniqueness.isEmpty()) {
      // ORRUAC-414 - Validate Adult Contact Relationship uniqueness
      UAC_adultContactRelationshipHelper.checkDuplicate(lstValidateUniqueness);
    }
  }

  /*  @author       Priyanka Bolla
       @description  Before Delete
       @param        N/A
       @return       void
   */
  public
  void beforeDelete(Map<Id, SObject> mapOldItems) {
  }

  /*  @author       Priyanka Bolla
     @description  After Insert
     @param        N/A
     @return       void
 */
  public
  void afterInsert(Map<Id, SObject> mapNewItems) {
  }

  /*  @author       Priyanka Bolla
      @description  After Update
      @param        N/A
      @return       void
  */
  public
  void afterUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
  }

  /*  @author       Priyanka Bolla
      @description  After Delete
      @param        N/A
      @return       void
  */
  public
  void afterDelete(Map<Id, SObject> mapOldItems) {
  }

  /*  @author       Priyanka Bolla
     @description  After UnDelete
     @param        N/A
     @return       void
 */
  public
  void afterUndelete(Map<Id, SObject> mapOldItems) {
  }
}