/**
 * @File Name          : UAC_associatedContactTriggerHelper.cls
 * @Description        : Handles all Associated Contact trigger logic
 * @Author             : Karthi Subramanian (Deloitte)
 * @Test Class         : UAC_associatedContactTriggerHelperTest
 * @Group              : UAC_triggerHelper
 * @Modification Log   :
 * Ver       Date            Author      		          Modification
 * 1.0    6/7/2020   Karthi Subramanian (Deloitte)    Initial Implementation.
 * 1.1    6/8/2020   Sachet Khanal (Deloitte)         ORRUAC-1017 Associated Contact Uniqueness
 **/
public
class UAC_associatedContactTriggerHelper {
  static final String STR_ERROR_CANNOT_DELETE_RECORD = Label.UAC_backGroundChkError;
  static final String STR_ERROR_DUPLICATE_ASSOCIATED_CONTACT =
      Label.UAC_associatedContactSponsorAppDuplicateError;
   static final String Contact_Adult_Child_RecordType = Label.UAC_Contact_RecordTypeApiName_AdultContactChildren;

  /**
   * @description ORRUAC-1017 - Validate Associated Contact record uniqueness
   * @author Sachet Khanal (Deloitte) | 6/8/2020
   * @param lstAdultContactRelationship
   * @return void
   **/
  public
  static void checkDuplicate(List<UAC_associatedContact__c> lstAssociatedContact) {
    // Extract Adult Contact Id set to query existing adult contact relationship records
    Set<Id> setCaseId = new Set<Id>();
    for (UAC_associatedContact__c objAssociatedContact : lstAssociatedContact) {
      setCaseId.add(objAssociatedContact.UAC_case__c);
    }

    // Delimiter to use for concatenating UAC Id with Adult Contact Id in order to detect duplicates
    String strDelimiter = '-';

    // Query other existing relationships for Adult Contact to check for duplicates
    Set<String> setUniqueId = new Set<String>();
    for (UAC_associatedContact__c objAssociatedContact :
        // clang-format off
      [SELECT
        Id, UAC_contact__c, UAC_case__c
      FROM
        UAC_associatedContact__c
      WHERE
        UAC_case__c IN :setCaseId
        AND Id NOT IN :lstAssociatedContact
      ]
        // clang-format on
    ) {
      // Prepare unique identifier to match relationship
      String strUniqueId =
          objAssociatedContact.UAC_case__c + strDelimiter + objAssociatedContact.UAC_contact__c;
      setUniqueId.add(strUniqueId);
    }

    // Check for duplicates using set of concatenated UAC and Adult Contact Id as unique identifier
    for (UAC_associatedContact__c objAssociatedContact : lstAssociatedContact) {
      String strUniqueId =
          objAssociatedContact.UAC_case__c + strDelimiter + objAssociatedContact.UAC_contact__c;
      if (setUniqueId.contains(strUniqueId)) {  // Duplicate, then add duplicate error
        objAssociatedContact.addError(STR_ERROR_DUPLICATE_ASSOCIATED_CONTACT);
      } else {
        setUniqueId.add(strUniqueId);
      }
    }
  }
  /**
   * @description ORRUAC-789 - Validate background check record whether Results Entered
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param mapAssociatedContact
   * @return void
   **/
  public
  static void validateResultsUpdateBackGroundChk(
      Map<Id, UAC_associatedContact__c> mapAssociatedContact) {
    Set<Id> setContactIds = new set<Id>();
    Set<Id> setCaseIds = new set<Id>();
    Map<Id, UAC_backgroundCheck__c> mapBackGroundChkForDelete =
        new Map<Id, UAC_backgroundCheck__c>();
    Map<Id, UAC_backgroundCheck__c> mapBackGroundChkForUpdate =
        new Map<Id, UAC_backgroundCheck__c>();

    for (UAC_associatedContact__c objAssociatedContact : mapAssociatedContact.values()) {
      if (objAssociatedContact.UAC_contact__c != null) {
        setContactIds.add(objAssociatedContact.UAC_contact__c);
      }
      if (objAssociatedContact.UAC_case__c != null) {
        setCaseIds.add(objAssociatedContact.UAC_case__c);
      }
    }
    List<UAC_backgroundCheck__c> lstBackGroundchk = [
      SELECT Id,
      Name,
      UAC_adultContact__c,
      UAC_results__c,
      UAC_sponsorApplication__c,
      UAC_systemGeneratedRec__c FROM UAC_backgroundCheck__c where UAC_adultContact__c
      =:setContactIds and UAC_sponsorApplication__c
      =:setCaseIds
    ];

    for (UAC_backgroundCheck__c objBackGroundChk : lstBackGroundchk) {
      if (objBackGroundChk.UAC_results__c
          == null) {  // results not entered, then delete the reocrds
        objBackGroundChk.UAC_systemGeneratedRec__c =
            false;  // this update needed otherwise BGCHK trigger will throw error will not allow to
                    // delete
        mapBackGroundChkForUpdate.put(objBackGroundChk.id, objBackGroundChk);
        mapBackGroundChkForDelete.put(objBackGroundChk.id, objBackGroundChk);
      }
      if (objBackGroundChk.UAC_results__c
          != null) {  // results entered, then remove Sponsor Application case Association
        objBackGroundChk.UAC_sponsorApplication__c = null;
        mapBackGroundChkForUpdate.put(objBackGroundChk.id, objBackGroundChk);
      }
    }

    if (mapBackGroundChkForUpdate.values().size() > 0) {
      update mapBackGroundChkForUpdate.values();
    }

    if (mapBackGroundChkForDelete.values().size() > 0) {
      delete mapBackGroundChkForDelete.values();
    }
  }

  /**
   * @description ORRUAC-789 - Validate background check record whether Results Entered
   * @author Karthi Subramanian (Deloitte) | 6/7/2020
   * @param mapAssociatedContact
   * @return void
   **/
  public
  static void checkHouseHoldAdultCareGiverFlagChange(
      Map<Id, UAC_associatedContact__c> mapNewAssociatedCon,
      Map<Id, UAC_associatedContact__c> mapOldAssociatedCon) {

    Map<Id, UAC_associatedContact__c> mapAssociatedConUpd = new Map<Id, UAC_associatedContact__c>();
    for (UAC_associatedContact__c objNewAssociatedCon : mapNewAssociatedCon.values()) {
      UAC_associatedContact__c objOldAssociatedCon =
          (mapOldAssociatedCon != null) ? mapOldAssociatedCon.get(objNewAssociatedCon.Id) : null;
      if (objOldAssociatedCon != null) {
        if (((objOldAssociatedCon.UAC_householdMember__c
                 != objNewAssociatedCon.UAC_householdMember__c)
                || (objOldAssociatedCon.UAC_alternateAdultCaregiver__c
                    != objNewAssociatedCon.UAC_alternateAdultCaregiver__c))
            && ((!objNewAssociatedCon.UAC_householdMember__c)
                && (!(objNewAssociatedCon.UAC_alternateAdultCaregiver__c)))) {
          mapAssociatedConUpd.put(objNewAssociatedCon.id, objNewAssociatedCon);
        }
      }
    }

    if (mapAssociatedConUpd.size() > 0) {
      validateResultsUpdateBackGroundChk(
          mapAssociatedConUpd);  // Call to update Case association
                                 // and delete background check record
    }
  }

  /**
   * @description ORRUAC-438 - Create background check record for sponsor and Associated contacts
   * @author Vaibhav Kudesia (Deloitte) | 9/14/2020
   * @param AssociatedContact,sponsorCategory,SAiD,boolCANforAll
   * @return list<UAC_backgroundCheck__c>
   **/
  public
  static list<UAC_backgroundCheck__c> createBackGroundChk(
      Contact AssociatedContact, String sponsorCategory, Id SAiD, Boolean boolCANforAll) {

    list<UAC_backgroundCheck__c> lstBGCtoInsert = new list<UAC_backgroundCheck__c>();

    lstBGCtoInsert.add(createBackgroundCheck(
        AssociatedContact.Id, SAiD, Label.UAC_bcgTypeInternetCriminalPublicRecords));
    lstBGCtoInsert.add(
        createBackgroundCheck(AssociatedContact.Id, SAiD, Label.UAC_bcgTypeSexOffenderRegistry));
    if (Label.UAC_bcgcategorylist.split(',').contains(sponsorCategory)
        || AssociatedContact.UAC_FFSRequiresFBIBackgroundCheck__c) {
      lstBGCtoInsert.add(
          createBackgroundCheck(AssociatedContact.Id, SAiD, Label.UAC_bcgTypeFBICriminalHistory));
    }
    if (AssociatedContact.UAC_FFSRequiresCAOrNCheck__c || boolCANforAll) {
      lstBGCtoInsert.add(createBackgroundCheck(AssociatedContact.Id, SAiD, Label.UAC_bcgTypeCAN));
    }
    if (AssociatedContact.UAC_FFSRequiresStateLocalCheck__c) {
      lstBGCtoInsert.add(
          createBackgroundCheck(AssociatedContact.Id, SAiD, Label.UAC_bcgTypeStateLocal));
    }

    return lstBGCtoInsert;
  }

  /**
   * @description creates instance of Background Check to be inserted.
   * @author Vaibhav Kudesia (Deloitte) | 9/14/2020
   * @param lstAssociatedContact
   * @return
   **/
  public
  static void processCaseRelatedData(List<UAC_associatedContact__c> lstAssociatedContact) {
    list<UAC_backgroundCheck__c> lstBGCtoInsertFinal = new list<UAC_backgroundCheck__c>();
    list<UAC_associatedSponsorApplication__c> lstASAtoInsert =
        new list<UAC_associatedSponsorApplication__c>();
    map<Id, Boolean> mapCaseIDSponsorCANCheck = new map<Id, Boolean>();
    map<Id, Id> mapcontactSponsorIds = new map<Id, Id>();
    map<Id, set<Id>> mapContactIdCases = new map<Id, set<Id>>();
    for (UAC_associatedContact__c objAC : lstAssociatedContact) {
      // setContactId.add(objAC.UAC_contact__c);
      Set<Id> setCases = new set<Id>();
      if (mapContactIdCases.keyset().contains(objAC.UAC_contact__c)) {
        setCases.addall(mapContactIdCases.get(objAC.UAC_contact__c));
      }
      setCases.add(objAC.UAC_case__c);
      mapContactIdCases.put(objAC.UAC_contact__c, setCases);
      mapCaseIDSponsorCANCheck.put(objAC.UAC_case__c, false);
    }
    map<Id, Contact> mapContactDetails = new map<Id, Contact>([Select Id,UAC_currentAge__c,Recordtype.Developername,
      UAC_FFSRequiresCAOrNCheck__c,
      UAC_FFSRequiresStateLocalCheck__c,
      UAC_FFSRequiresFBIBackgroundCheck__c from Contact where Id =:mapContactIdCases.keyset()]);
    // Household Member, Alternate Adult Caregiver CA/N required if: Sponsor Requires CA/N check OR
    // FFS Requires CA/N Check = TRUE
    for (Case cs : [Select id,
           (Select id,
               UAC_backgroundCheckType__c,
               UAC_adultContact__c from UAC_backgroundCheck__r where UAC_backgroundCheckType__c =
                   : Label.UAC_bcgTypeCAN),
           UAC_relationshipToUAC__r.UAC_category__c,
           UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresStateLocalCheck__c,
           UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresCAOrNCheck__c,
           UAC_relationshipToUAC__c,
           UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresFBIBackgroundCheck__c
               from case where Id =:mapCaseIDSponsorCANCheck.keySet()]) {

      mapCaseIDSponsorCANCheck.put(
          cs.Id, cs.UAC_relationshipToUAC__r.UAC_adultContact__r.UAC_FFSRequiresCAOrNCheck__c);

      for (UAC_backgroundCheck__c Bc : cs.UAC_backgroundCheck__r) {
        if (Bc.UAC_adultContact__c == cs.UAC_relationshipToUAC__c) {
          mapCaseIDSponsorCANCheck.put(cs.Id, True);
        }
      }
    }

    List<UAC_backgroundCheck__c> lstBGCOld = [Select id,
      UAC_backgroundCheckType__c,
      UAC_adultContact__c from UAC_backgroundCheck__c where UAC_adultContact__c
      =:mapContactIdCases.keySet() and UAC_expirationDate__c > TODAY];
    for (UAC_associatedContact__c objAC : lstAssociatedContact) {
        if (objAC.UAC_alternateAdultCaregiver__c == true || objAC.UAC_householdMember__c == true){
          if(mapContactDetails.get(objAC.UAC_contact__c).RecordType.DeveloperName == Contact_Adult_Child_RecordType && Integer.valueOf(mapContactDetails.get(objAC.UAC_contact__c).UAC_currentAge__c) < 18){         
            continue;
            } 
        
        for (UAC_backgroundCheck__c objBGCNew :
            createBackGroundChk(mapContactDetails.get(objAC.UAC_contact__c),
                'null',
                objAC.UAC_case__c,
                mapCaseIDSponsorCANCheck.get(objAC.UAC_case__c))) {
          boolean boolBGCExist = false;
          for (UAC_backgroundCheck__c objBGCOld : lstBGCOld) {
            if (objBGCOld.UAC_backgroundCheckType__c == objBGCNew.UAC_backgroundCheckType__c
                && objBGCOld.UAC_adultContact__c == objBGCNew.UAC_adultContact__c) {
              boolBGCExist = true;
              lstASAtoInsert.add(
                  createAssociatedSponsorApplication(objBGCOld.Id, objAC.UAC_case__c));
            }
          }
          if (!boolBGCExist) {
            lstBGCtoInsertFinal.add(objBGCNew);
          }
        }
      }
    }

    if (!lstBGCtoInsertFinal.isEmpty()) {
      List<Database.SaveResult> lstSaveResult = Database.insert(lstBGCtoInsertFinal, false);
      // Inspect save result
      for (Database.SaveResult objSaveResult : lstSaveResult) {
        if (!objSaveResult.isSuccess()) {
          for (Database.Error objError : objSaveResult.getErrors()) {
            UAC_errorLog.platformEventErrorLog(
                objError.getMessage(), 'createBackGroundChk', 'UAC_associatedContactTriggerHelper','');
          }
        }
      }
    }

    for (UAC_backgroundCheck__c objBGC : lstBGCtoInsertFinal) {
      for (Id caseId : mapContactIdCases.get(objBGC.UAC_adultContact__c)) {
        lstASAtoInsert.add(createAssociatedSponsorApplication(objBGC.Id, caseId));
      }
    }

    if (!lstASAtoInsert.isEmpty()) {
      insert lstASAtoInsert;
    }
  }
  /**
   * @description creates instance of Background Check to be inserted.
   * @author Vaibhav Kudesia (Deloitte) | 9/14/2020
   * @param Background Check record details
   * @return UAC_backgroundCheck__c
   **/
  public
  static UAC_backgroundCheck__c createBackgroundCheck(Id AdultContactId, Id SAiD, String Type) {
    UAC_backgroundCheck__c objBackgroundCheck = new UAC_backgroundCheck__c();
    objBackgroundCheck.UAC_systemGeneratedRec__c = True;
    objBackgroundCheck.UAC_adultContact__c = AdultContactId;
    objBackgroundCheck.UAC_backgroundCheckType__c = Type;
    objBackgroundCheck.UAC_checkRequired__c = True;
    objBackgroundCheck.UAC_sponsorApplication__c = SAiD;
    return objBackgroundCheck;
  }
  /**
   * @description creates instance of Background Check to be inserted.
   * @author Vaibhav Kudesia (Deloitte) | 9/14/2020
   * @param Background Check record details
   * @return UAC_associatedSponsorApplication__c
   **/
  public
  static UAC_associatedSponsorApplication__c createAssociatedSponsorApplication(
      Id BackgroundCheckId, Id SAiD) {
    UAC_associatedSponsorApplication__c objBackgroundCheckforApplication =
        new UAC_associatedSponsorApplication__c();
    objBackgroundCheckforApplication.UAC_backgroundCheck__c = BackgroundCheckId;
    objBackgroundCheckforApplication.UAC_sponsorApplication__c = SAiD;
    objBackgroundCheckforApplication.UAC_dateAssociated__c = System.today();
    return objBackgroundCheckforApplication;
  }
  /**
   * @description Set role of background check based on associated contact when updated
   * @author Issam Awwad (Deloitte) | 1/19/2021
   * @param mapNewAssociatedCon,mapOldAssociatedCon
   * @return void
   **/
  public
  static void populateSponsorRole(Map<Id, UAC_associatedContact__c> mapNewAssociatedCon,
      Map<Id, UAC_associatedContact__c> mapOldAssociatedCon) {
    List<UAC_backgroundCheck__c> lstBackgroundChecksToUpdate = new List<UAC_backgroundCheck__c>();
    Set<Id> setOFAssociatedContact = new Set<Id>();
    Map<Id, UAC_backgroundCheck__c> mapOfContactToBackground =
        new Map<Id, UAC_backgroundCheck__c>();
    for (UAC_associatedContact__c objAssociatedContact : mapNewAssociatedCon.values()) {
      setOFAssociatedContact.add(objAssociatedContact.UAC_contact__c);
    }
    List<UAC_backgroundCheck__c> lstOfBackgroundCheck = [
      SELECT Id,
      UAC_role__c,
      UAC_adultContact__c FROM UAC_backgroundCheck__c WHERE UAC_adultContact__c
      IN:setOFAssociatedContact AND UAC_backgroundCheckType__c
       =:Label.UAC_bcgTypeFBICriminalHistory
    ];
    for (UAC_backgroundCheck__c objBackground : lstOfBackgroundCheck) {
      mapOfContactToBackground.put(objBackground.UAC_adultContact__c, objBackground);
    }
    for (UAC_associatedContact__c objAssociatedContact : mapNewAssociatedCon.values()) {
      UAC_associatedContact__c objOldAssociatedContact =
          mapOldAssociatedCon.get(objAssociatedContact.Id);
      UAC_backgroundCheck__c objBackgroundCheck =
          mapOfContactToBackground.get(objAssociatedContact.UAC_contact__c);
      if (objBackgroundCheck != null) {
        if (objAssociatedContact.UAC_alternateAdultCaregiver__c
                != objOldAssociatedContact.UAC_alternateAdultCaregiver__c
            || objAssociatedContact.UAC_familyAndFriends__c
                != objOldAssociatedContact.UAC_familyAndFriends__c
            || objAssociatedContact.UAC_supervisionPlanPerson__c
                != objOldAssociatedContact.UAC_supervisionPlanPerson__c
            || objAssociatedContact.UAC_householdMember__c
                != objOldAssociatedContact.UAC_householdMember__c) {
          if (objAssociatedContact.UAC_alternateAdultCaregiver__c == false
              && objAssociatedContact.UAC_familyAndFriends__c == false
              && objAssociatedContact.UAC_supervisionPlanPerson__c == false
              && objAssociatedContact.UAC_householdMember__c == false) {
            objBackgroundCheck.UAC_role__c = Label.UAC_backgroundCheckRoleSponsor;
          } else {
            objBackgroundCheck.UAC_role__c = '';
            objBackgroundCheck.UAC_role__c =
                objAssociatedContact.UAC_alternateAdultCaregiver__c == true
                ? Label.UAC_backgroundCheckRoleAlternate + ','
                : '';
            objBackgroundCheck.UAC_role__c += objAssociatedContact.UAC_familyAndFriends__c == true
                ? Label.UAC_backgroundCheckRoleFamilyFriend + ','
                : '';
            objBackgroundCheck.UAC_role__c +=
                objAssociatedContact.UAC_supervisionPlanPerson__c == true
                ? Label.UAC_backgroundCheckRoleSupervision + ','
                : '';
            objBackgroundCheck.UAC_role__c += objAssociatedContact.UAC_householdMember__c == true
                ? Label.UAC_backgroundCheckRoleHouseholdMember
                : '';
          }
          lstBackgroundChecksToUpdate.add(objBackgroundCheck);
        }
      }
    }
    if (!lstBackgroundChecksToUpdate.isEmpty()) {
      try {
        update lstBackgroundChecksToUpdate;
      } catch (DMLException e) {
        UAC_errorLog.logError(e.getMessage(), '',
            'Error updating background check role ' + e.getStackTraceString(),
            e.getStackTraceString());
      }
    }
  }
}