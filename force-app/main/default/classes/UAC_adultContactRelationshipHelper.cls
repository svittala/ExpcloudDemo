/**
 * @File Name          : UAC_adultContactRelationshipHelper.cls
 * @Description        : Trigger helper for UAC_adultContactRelationshipHandler
 * @Author             : Priyanka Bolla (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_adultContactRelationshipHelperTest
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/1/2020, 5:24:38 PM
 * @Modification Log   :
 * Ver       Date            Author      		      Modification
 * 1.0    5/8/2020   Priyanka Bolla (Deloitte)    Initial Version
 * 1.1    5/14/2020  Rahul Roy (Deloitte)         Populate Date Assigned as Primary Sponsor
 * 1.2    5/18/2020  Sachet Khanal (Deloitte)     Refactored to avoid multiple for loops (Moved
 *                                                auto-populate to trigger handler)
 * 1.3    6/1/2020   Sachet Khanal (Deloitte)     ORRUAC-414 Adult Contact Relation duplicate check
 * 1.4    9/23/2020  Chaitanya Nandamuri(Deloitte) ORRUAC-2308 - Clear the Sponser Information on Related CaseReview
 **/
public
with sharing class UAC_adultContactRelationshipHelper {

  static final String STR_ERROR_MORE_THAN_ONE_PRIMARY_SPONSOR =
      System.Label.UAC_onePrimarySponsorError;
  static final String STR_ERROR_DUPLICATE_ADULT_CONTACT_RELATIONSHIP =
      Label.UAC_adultContactRelationshipDuplicateError;

  /*  @author       Priyanka Bolla
      @description  Validates one primary sponsor for a UAC on Insert
      @param        List<UAC_adultContactRelationship__c> lstNewItems
      @return       void
  */
  public
  static void validateOnePrimarySponsor(List<UAC_adultContactRelationship__c> lstNewItems) {
    set<UAC_adultContactRelationship__c> setTriggerContext =
        new set<UAC_adultContactRelationship__c>();
    set<id> setUACContactIds = new set<id>();
   
   //ORRUAC-2308 collects set of UAC contact whose AdultContactReationship is a primary Sponsor.
    List<id> lstUACIdwithPrimarySponsor = new List<id>();
    
    Map<id, set<UAC_adultContactRelationship__c>> mapUACAdultContRel =
        new Map<id, set<UAC_adultContactRelationship__c>>();
    // Collecting contact Ids and Trigger Context Adult Contact Relationships//
    for (UAC_adultContactRelationship__c adContRel : lstNewItems) {
      setUACContactIds.add(adContRel.UAC_uacLookup__c);
      setTriggerContext.add(adContRel);
    }
    // Getting the list of existing adult contact records where UAC_relationshipType__c is Primary
    // Sponsor and they are related to same UAC Contact from the database//
    for (UAC_adultContactRelationship__c adContRel : [
           Select id,
           UAC_relationshipType__c,
           UAC_uacLookup__c from UAC_adultContactRelationship__c where UAC_relationshipType__c
            =:Label.UAC_typeOfSponsor and UAC_uacLookup__c
           in:setUACContactIds
         ]) {

      set<UAC_adultContactRelationship__c> setAdultContRel =
          new set<UAC_adultContactRelationship__c>();
      // Adding the Adult Contact Relationships to the map with the UAC_uacLookup__c as the key and
      // values as Adult Coontact Relationship Records//
      if (mapUACAdultContRel.containsKey(adContRel.UAC_uacLookup__c)) {
        setAdultContRel = mapUACAdultContRel.get(adContRel.UAC_uacLookup__c);
      }
      setAdultContRel.add(adContRel);

      mapUACAdultContRel.put(adContRel.UAC_uacLookup__c, setAdultContRel);
    }
    // Iterating on the list of adult contact records being modified /Inserted where they are
    // related to same UAC Contact from the database and updating the map with latest value of Adult
    // Contact Relationship Type where UAC_relationshipType__c =Primary //
    for (UAC_adultContactRelationship__c adContRel : lstNewItems) {

      set<UAC_adultContactRelationship__c> setAdultContRel =
          new set<UAC_adultContactRelationship__c>();

      if (mapUACAdultContRel.containsKey(adContRel.UAC_uacLookup__c)) {

        for (UAC_adultContactRelationship__c adRel :
            mapUACAdultContRel.get(adContRel.UAC_uacLookup__c)) {
          // Checking if existing adult Contact Relationships are being updated from Primary Sponsor
          // to other Type//
          if (adRel.Id == adContRel.Id
              && adRel.UAC_relationshipType__c != adContRel.UAC_relationshipType__c) {

            mapUACAdultContRel.get(adContRel.UAC_uacLookup__c).remove(adRel);
          }
        }
        setAdultContRel = mapUACAdultContRel.get(adContRel.UAC_uacLookup__c);
      }
      if (adContRel.UAC_relationshipType__c == Label.UAC_typeOfSponsor) {
        setAdultContRel.add(adContRel);
      }
      mapUACAdultContRel.put(adContRel.UAC_uacLookup__c, setAdultContRel);
    }
    // Checking if there are more than one Primary Sponsor inserted/Updated for the same UAC//
    for (Id idContact : mapUACAdultContRel.keyset()) {
      if (mapUACAdultContRel.get(idContact).size() > 1) {
        for (UAC_adultContactRelationship__c adContRel : mapUACAdultContRel.get(idContact)) {
          if (setTriggerContext.contains(adContRel)) {
            adContRel.addError(STR_ERROR_MORE_THAN_ONE_PRIMARY_SPONSOR);
          }
        }
      }
      //ORRUAC-2308 collects set of UAC contact whose AdultContactReationship is a primary Sponsor.
        else if (mapUACAdultContRel.get(idContact).size() == 1){
          for (UAC_adultContactRelationship__c adContRel : mapUACAdultContRel.get(idContact)) {
              lstUACIdwithPrimarySponsor.add(idContact);
          }
      }
    }
      // ORRUAC-2308
      clearSponsorInformationOnCaseReviewAdmission(lstUACIdwithPrimarySponsor);
  }

  /**
   * @description ORRUAC-414 - Validate Adult Contact Relationship uniqueness
   * @author Sachet Khanal (Deloitte) | 6/1/2020
   * @param lstAdultContactRelationship
   * @return void
   **/
  public
  static void checkDuplicate(List<UAC_adultContactRelationship__c> lstAdultContactRelationship) {
    // Extract Adult Contact Id set to query existing adult contact relationship records
    Set<Id> setAdultContactId = new Set<Id>();
    for (UAC_adultContactRelationship__c objRelationship : lstAdultContactRelationship) {
      setAdultContactId.add(objRelationship.UAC_adultContact__c);
    }

    // Delimiter to use for concatenating UAC Id with Adult Contact Id in order to detect duplicates
    String strDelimiter = '-';

    // Query other existing relationships for Adult Contact to check for duplicates
    Set<String> setUniqueId = new Set<String>();
    for (UAC_adultContactRelationship__c objRelationship :
        // clang-format off
      [SELECT
        Id, UAC_uacLookup__c, UAC_adultContact__c
      FROM
        UAC_adultContactRelationship__c
      WHERE
        UAC_adultContact__c IN :setAdultContactId
        AND Id NOT IN :lstAdultContactRelationship
      ]
        // clang-format on
    ) {
      // Prepare unique identifier to match relationship
      String strUniqueId =
          objRelationship.UAC_uacLookup__c + strDelimiter + objRelationship.UAC_adultContact__c;
      setUniqueId.add(strUniqueId);
    }

    // Check for duplicates using set of concatenated UAC and Adult Contact Id as unique identifier
    for (UAC_adultContactRelationship__c objRelationship : lstAdultContactRelationship) {
      String strUniqueId =
          objRelationship.UAC_uacLookup__c + strDelimiter + objRelationship.UAC_adultContact__c;
      if (setUniqueId.contains(strUniqueId)) {  // Duplicate, then add duplicate error
        objRelationship.addError(STR_ERROR_DUPLICATE_ADULT_CONTACT_RELATIONSHIP);
      } else {
        setUniqueId.add(strUniqueId);
      }
    }
  }
   /**
   * @description ORRUAC-2308 - Clear the Sponser Information on Related CaseReview
   * @author Chaitanya Nandamuri (Deloitte) | 9/22/2020
   * @param setUACcontactId
   * @return void
   **/ 
   public static void clearSponsorInformationOnCaseReviewAdmission(List<Id>UACcontactId){
      
       if (UACcontactId.isEmpty()){
           return;
       }
       set<string> setCaseReviewFieldSet = new set<string>();
       List<UAC_admissionAssessment__c> listCaseReviewAssessment = new List<UAC_admissionAssessment__c>();
       string CaseReviewRCtype = Label.UAC_assessmentRecordTypeReview;
       string strStatusSubmitted = 'Submitted';
       
       string queryBase = 'Select Id ';
       String queryEnd = ' FROM UAC_admissionAssessment__c where UAC_uac__c IN: UACcontactId and RecordType.DeveloperName =: CaseReviewRCtype and UAC_mostRecentAssessment__c = true and UAC_assessmentStatus__c !=:strStatusSubmitted';
       
       for (Schema.FieldSetMember fieldSetMemberObj : UAC_utilities.getFieldSet(
             'UAC_admissionAssessment__c', 'UAC_sponsorInformation')) {
      setCaseReviewFieldSet.add(fieldSetMemberObj.getFieldPath());
      queryBase += ', ' + fieldSetMemberObj.getFieldPath();
    }
       queryBase += queryEnd;
      
        for (UAC_admissionAssessment__c CaseReview : Database.query(queryBase)){
            for (String field : setCaseReviewFieldSet){
                CaseReview.put(field,'');
            }
            listCaseReviewAssessment.add(CaseReview);
        }
       if (!listCaseReviewAssessment.isEmpty()){
           update listCaseReviewAssessment;
       }
    }
}