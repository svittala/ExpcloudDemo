/**
 *___________________________________________________
 * @Name: UAC_apprehendedRelationshipHelper
 * @Author: Piyush Pranav
 * @Created Date: May 08, 2020
 * @Used_By: UAC PATH
 *___________________________________________________
 * @Description: Contains methods for different Trigger context on Apprehended Relationships
 *___________________________________________________
 * @Changes: Added Record Type and workflow field updates 05/20/2020
 * @Changes: Code optimization 05/22/2020
 *
 **/
public
without Sharing class UAC_apprehendedRelationshipHelper {
  public
  static Boolean booReciprocal = false;
  public
  static Boolean boolUpdate = false;
  private
  static final String STRING_CANNOT_CHANGE_PRIMARY = 'You cannot change the UC you are relating.';
  private
  static final String STRING_CANNOT_LINK_TO_SELF = 'You cannot relate a UC to the same UC.';
  private
  static final String STRING_RECORD_TYPE_UAC = 'Apprehended UC';
  private
  static final String STRING_UNKNOWN = 'Unknown';
  private
  static final String ID_UAC_RECORD_TYPE =
      Schema.SObjectType.UAC_apprehendedRelationship__c.getRecordTypeInfosByDeveloperName()
          .get('UAC_apprehendedUAC')
          .getRecordTypeId();

  /*  @author       James Qian
      @description  Sets referral lookups after the Entry field is populated
      @param        Map<Id, SObject> mapNewItems
      @param        Map<Id, SObject> mapOldItems
      @return       void
  */
  public
  static void setReferralLookups(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
    Map<Id, UAC_apprehendedRelationship__c> mapOldApprItems =
        (Map<Id, UAC_apprehendedRelationship__c>) mapOldItems;
    Map<Id, UAC_apprehendedRelationship__c> mapNewApprItems =
        (Map<Id, UAC_apprehendedRelationship__c>) mapNewItems;
    List<UAC_apprehendedRelationship__c> listRelationshipsToProcess =
        new List<UAC_apprehendedRelationship__c>();
    for (UAC_apprehendedRelationship__c relationshipCurrent : mapNewApprItems.values()) {
      if (String.isNotBlank(relationshipCurrent.UAC_entry__c)
          && relationshipCurrent.UAC_entry__c
              != mapOldApprItems.get(relationshipCurrent.Id).UAC_entry__c) {
        listRelationshipsToProcess.add(relationshipCurrent);
      }
    }
    if (listRelationshipsToProcess.isEmpty()) {
      return;
    }
    List<String> listFieldAPINames = new List<String>();
    for (Schema.FieldSetMember objFieldSet :
        Schema.SObjectType.UAC_apprehendedRelationship__c.fieldSets.getMap()
            .get(Label.UAC_relationshipFieldsetLookups)
            .getFields()) {
      listFieldAPINames.add(objFieldSet.getFieldPath());
    }
    for (UAC_apprehendedRelationship__c relationshipCurrent : listRelationshipsToProcess) {
      updateReferralLookupFields(relationshipCurrent, listFieldAPINames);
    }
  }

  /*  @author       James Qian
      @description  Sets referral lookups for a single relationship
      @param        UAC_apprehendedRelationship__c objRelationship
      @param        List<String> listFieldAPINames
      @return       void
  */
  private
  static void updateReferralLookupFields(
      UAC_apprehendedRelationship__c objRelationship, List<String> listFieldAPINames) {
    for (String strFieldAPIName : listFieldAPINames) {
      if (objRelationship.get(strFieldAPIName) == null) {
        objRelationship.put(strFieldAPIName, objRelationship.UAC_entry__c);
        objRelationship.UAC_entry__c = null;
      } else {
        continue;
      }
    }
  }

  /*  @author       James Qian
      @description  Sets unique pair ID on insert.
      @param        List<UAC_apprehendedRelationship__c> lstNewItems
      @return       void
  */
  public
  static void setPairID(List<UAC_apprehendedRelationship__c> lstNewItems) {
    for (UAC_apprehendedRelationship__c relationshipCurrent : lstNewItems) {
      if(String.isNotBlank(relationshipCurrent.UAC_relatedUAC__c)) {
        relationshipCurrent.UAC_pairID__c =
          relationshipCurrent.UAC_uacLookup__c + ';' + relationshipCurrent.UAC_relatedUAC__c;
      }
      if (relationshipCurrent.UAC_uacLookup__c == relationshipCurrent.UAC_relatedUAC__c) {
        relationshipCurrent.addError(STRING_CANNOT_LINK_TO_SELF);
      }
    }
  }

  /*  @author       James Qian
      @description  Sets unique pair ID on insert on update and adds errors if the primary
                    relationship is changed.
      @param        Map<Id, SObject> mapNewItems
      @param        Map<Id, SObject> mapOldItems
      @return       void
  */
  public
  static void setPairIDOnUpdate(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
    Map<Id, UAC_apprehendedRelationship__c> mapOldApprItems =
        (Map<Id, UAC_apprehendedRelationship__c>) mapOldItems;
    Map<Id, UAC_apprehendedRelationship__c> mapNewApprItems =
        (Map<Id, UAC_apprehendedRelationship__c>) mapNewItems;
    for (UAC_apprehendedRelationship__c relationshipCurrent : mapNewApprItems.values()) {
      if (relationshipCurrent.UAC_uacLookup__c
          != mapOldApprItems.get(relationshipCurrent.Id).UAC_uacLookup__c) {
        relationshipCurrent.addError(STRING_CANNOT_CHANGE_PRIMARY);
      }
      if (relationshipCurrent.UAC_uacLookup__c == relationshipCurrent.UAC_relatedUAC__c) {
        relationshipCurrent.addError(STRING_CANNOT_LINK_TO_SELF);
      }
      if (relationshipCurrent.UAC_relatedUAC__c
          != mapOldApprItems.get(relationshipCurrent.Id).UAC_relatedUAC__c
          && String.isNotBlank(relationshipCurrent.UAC_relatedUAC__c)) {
        relationshipCurrent.UAC_pairID__c =
            relationshipCurrent.UAC_uacLookup__c + ';' + relationshipCurrent.UAC_relatedUAC__c;
      }
    }
  }

  /*  @author       Piyush Pranav
      @description  Creates Reciprocal Apprehended Relation ship record on every insert
      @param        List<UAC_apprehendedRelationship__c> lstNewItems
      @return       void
  */
  public
  static void reciprocalCreation(List<UAC_apprehendedRelationship__c> lstNewItems) {
    System.debug('booReciprocal value:' + booReciprocal);
    if (booReciprocal) {
      System.debug('booReciprocal value inside if loop:' + booReciprocal);
      return;
    }
    List<Id> lstIds = new List<Id>();
    Map<Id, Contact> mapIdToContact = new Map<Id, Contact>();
    List<UAC_apprehendedRelationship__c> lstRelToInsert =
        new List<UAC_apprehendedRelationship__c>();
    for (UAC_apprehendedRelationship__c uacApp : lstNewItems) {
      if (uacApp.UAC_uacLookup__c != null && uacApp.UAC_relatedUAC__c != null) {
        lstIds.add(uacApp.UAC_uacLookup__c);
        lstIds.add(uacApp.UAC_relatedUAC__c);
      }
    }
    for (Contact con : [
           // clang-format off
            SELECT
              Id,
              UAC_gender__c,
              FirstName,
              LastName,
              UAC_A__c,
              Birthdate,
              Phone,
              MailingStreet
            FROM
              Contact
            WHERE
              Id IN :lstIds
           // clang-format on
         ]) {
      mapIdToContact.put(con.Id, con);
    }
    Map<String, UAC_relationshipMapping__mdt> mapRelationships = getRelationshipMapping();
    for (UAC_apprehendedRelationship__c uacApp : lstNewItems) {
      if (uacApp.UAC_reciprocal__c || uacApp.UAC_uacLookup__c == null
          || uacApp.UAC_relatedUAC__c == null) {
        continue;
      }
      String strRelationshipReciprocal;
      if (mapRelationships.containsKey(uacApp.UAC_relationshipToUAC__c)) {
        UAC_relationshipMapping__mdt metadataMatch =
            mapRelationships.get(uacApp.UAC_relationshipToUAC__c);
        if (mapIdToContact.get(uacApp.UAC_uacLookup__c).UAC_gender__c == 'Female') {
          strRelationshipReciprocal = metadataMatch.UAC_reverseRelationshipFemale__c;
        } else if (mapIdToContact.get(uacApp.UAC_uacLookup__c).UAC_gender__c == 'Male') {
          strRelationshipReciprocal = metadataMatch.UAC_reverseRelationshipMale__c;
        } else {
          strRelationshipReciprocal = metadataMatch.UAC_reverseRelationshipDefault__c;
        }
      } else {
        strRelationshipReciprocal = 'Unknown';
      }
      UAC_apprehendedRelationship__c objUACApr = createNewRelationship(uacApp.UAC_relatedUAC__c,
          uacApp.UAC_uacLookup__c,
          mapIdToContact.get(uacApp.UAC_uacLookup__c).FirstName,
          mapIdToContact.get(uacApp.UAC_uacLookup__c).LastName,
          mapIdToContact.get(uacApp.UAC_uacLookup__c).UAC_A__c,
          mapIdToContact.get(uacApp.UAC_uacLookup__c).Phone,
          mapIdToContact.get(uacApp.UAC_uacLookup__c).Birthdate,
          mapIdToContact.get(uacApp.UAC_uacLookup__c).MailingStreet,
          strRelationshipReciprocal);
      lstRelToInsert.add(objUACApr);
      uacApp.UAC_reciprocal__c = true;
      uacApp.UAC_firstName__c = mapIdToContact.get(uacApp.UAC_relatedUAC__c).FirstName;
      uacApp.UAC_lastName__c = mapIdToContact.get(uacApp.UAC_relatedUAC__c).LastName;
      uacApp.UAC_alienNumber__c = mapIdToContact.get(uacApp.UAC_relatedUAC__c).UAC_A__c;
    }
    if (boolUpdate == false) {
      lstRelToInsert.addAll(existingRelationshipCreation(lstNewItems));
    }
    booReciprocal = true;
    if (!lstRelToInsert.isEmpty()) {
      UC_exclusionLogicService.getInstance().bypassExclusions(true);
      Database.insert(lstRelToInsert, false);
    }
  }

  /*  @author       Piyush Pranav
      @description  Cascade Deletes corresponding Reciprocal Apprehended Relationship record on
     every delete
      @param        Map<Id,UAC_apprehendedRelationship__c> mapOldItems
      @return       void
  */
  public
  static void reciprocalDeletion(Map<Id, UAC_apprehendedRelationship__c> mapOldItems) {
    System.debug('reciprocalDeletion Start' + 'Limit::: ' + Limits.getLimitQueries() + '   '
        + 'Used::: ' + Limits.getQueries());
    if (booReciprocal) {
      System.debug('booReciprocal value inside if loop:' + booReciprocal);
      return;
    }
    List<Id> lstIdUac = new List<Id>();
    List<Id> lstIdRelUac = new List<Id>();
    List<String> lstStrType = new List<String>();
    Map<Id, UAC_apprehendedRelationship__c> mapRevOld =
        new Map<Id, UAC_apprehendedRelationship__c>();
    for (UAC_apprehendedRelationship__c uacRec : mapOldItems.values()) {
      if (uacRec.UAC_uacLookup__c != null && uacRec.UAC_relatedUAC__c != null
          && uacRec.recordTypeId == ID_UAC_RECORD_TYPE) {
        lstIdUac.add(uacRec.UAC_uacLookup__c);
        lstIdRelUac.add(uacRec.UAC_relatedUAC__c);
        lstStrType.add(uacRec.UAC_relationshipToUAC__c);
      }
    }
    List<UAC_apprehendedRelationship__c> lstRevUacApp = [
      // clang-format off
      SELECT
        Id,
        UAC_uacLookup__c,
        UAC_relatedUAC__c,
        UAC_relationshipToUAC__c
      FROM
        UAC_apprehendedRelationship__c
      WHERE
        UAC_uacLookup__c IN :lstIdRelUac
      AND
        UAC_relatedUAC__c IN :lstIdUac
      // clang-format on
    ];
    booReciprocal = true;
    if (!lstRevUacApp.isEmpty()) {
      UC_exclusionLogicService.getInstance().bypassExclusions(true);
      delete lstRevUacApp;
    }
  }

  /*  @author       Abhisek Pati
      @description  Creates Existing Reciprocal Relationships record on every insert
      @param        List<UAC_apprehendedRelationship__c> lstNewItems
      @return       void
  */
  public
  static List<UAC_apprehendedRelationship__c> existingRelationshipCreation(
      List<UAC_apprehendedRelationship__c> lstNewItems) {
    System.debug('existingRelationshipCreation Start' + 'Limit::: ' + Limits.getLimitQueries()
        + '   ' + 'Used::: ' + Limits.getQueries());
    List<UAC_apprehendedRelationship__c> lstRelToInsert =
        new List<UAC_apprehendedRelationship__c>();
    set<Id> setUACContactIds = new set<id>();
    set<Id> setRelatedUACContactIds = new set<id>();
    Map<Id, Contact> mapIdToCon = new Map<Id, Contact>();
    for (UAC_apprehendedRelationship__c apprRel : lstNewItems) {
      setUACContactIds.add(apprRel.UAC_uacLookup__c);
      setRelatedUACContactIds.add(apprRel.UAC_relatedUAC__c);
    }
    Map<Id, set<UAC_apprehendedRelationship__c>> mapUACApprRel =
        getExistingRelationships(setUACContactIds);
    Map<Id, set<UAC_apprehendedRelationship__c>> mapUACApprRelatedRel =
        getExistingRelationships(setRelatedUACContactIds);
    for (Contact contactCurrent : [
           // clang-format off
          SELECT
            Id,
            UAC_gender__c,
            FirstName,
            LastName,
            UAC_A__c,
            Birthdate,
            Phone,
            MailingStreet
          FROM
            Contact
          WHERE
            Id IN :setUACContactIds
          OR
            Id IN :setRelatedUACContactIds
           // clang-format on
         ]) {
      mapIdToCon.put(contactCurrent.Id, contactCurrent);
    }
    if (!mapUACApprRel.isEmpty() || !mapUACApprRelatedRel.isEmpty()) {
      for (UAC_apprehendedRelationship__c appRelNew : lstNewItems) {
        if (mapUACApprRel.containsKey(appRelNew.UAC_uacLookup__c)) {
          for (UAC_apprehendedRelationship__c appRelExisting :
              mapUACApprRel.get(appRelNew.UAC_uacLookup__c)) {
            if (String.isBlank(appRelExisting.UAC_uacLookup__c)) {
              continue;
            }
            if (appRelExisting.UAC_relatedUAC__c != null) {
              lstRelToInsert.add(createNewRelationship(appRelExisting.UAC_relatedUAC__c,
                  appRelNew.UAC_relatedUAC__c,
                  mapIdToCon.get(appRelNew.UAC_relatedUAC__c).FirstName,
                  mapIdToCon.get(appRelNew.UAC_relatedUAC__c).LastName,
                  mapIdToCon.get(appRelNew.UAC_relatedUAC__c).UAC_A__c,
                  mapIdToCon.get(appRelNew.UAC_relatedUAC__c).Phone,
                  mapIdToCon.get(appRelNew.UAC_relatedUAC__c).Birthdate,
                  mapIdToCon.get(appRelNew.UAC_relatedUAC__c).MailingStreet,
                  'Unknown'));
            }
            if (appRelNew.UAC_relatedUAC__c != null) {
              lstRelToInsert.add(createNewRelationship(appRelNew.UAC_relatedUAC__c,
                  appRelExisting.UAC_relatedUAC__c,
                  appRelExisting.UAC_relatedUAC__r.FirstName,
                  appRelExisting.UAC_relatedUAC__r.LastName,
                  appRelExisting.UAC_relatedUAC__r.UAC_A__c,
                  appRelExisting.UAC_relatedUAC__r.Phone,
                  appRelExisting.UAC_relatedUAC__r.Birthdate,
                  appRelExisting.UAC_relatedUAC__r.MailingStreet,
                  'Unknown'));
            }
          }
        }
        if (mapUACApprRelatedRel.containsKey(appRelNew.UAC_relatedUAC__c)) {
          for (UAC_apprehendedRelationship__c appRelExisting :
              mapUACApprRelatedRel.get(appRelNew.UAC_relatedUAC__c)) {
            if (String.isBlank(appRelExisting.UAC_uacLookup__c)) {
              continue;
            }
            if (appRelExisting.UAC_relatedUAC__c != null) {
              lstRelToInsert.add(createNewRelationship(appRelNew.UAC_uacLookup__c,
                  appRelExisting.UAC_relatedUAC__c,
                  appRelExisting.UAC_relatedUAC__r.FirstName,
                  appRelExisting.UAC_relatedUAC__r.LastName,
                  appRelExisting.UAC_relatedUAC__r.UAC_A__c,
                  appRelExisting.UAC_relatedUAC__r.Phone,
                  appRelExisting.UAC_relatedUAC__r.Birthdate,
                  appRelExisting.UAC_relatedUAC__r.MailingStreet,
                  'Unknown'));
            }
            if (appRelNew.UAC_relatedUAC__c != null) {
              lstRelToInsert.add(createNewRelationship(appRelExisting.UAC_relatedUAC__c,
                  appRelNew.UAC_uacLookup__c,
                  mapIdToCon.get(appRelNew.UAC_uacLookup__c).FirstName,
                  mapIdToCon.get(appRelNew.UAC_uacLookup__c).LastName,
                  mapIdToCon.get(appRelNew.UAC_uacLookup__c).UAC_A__c,
                  mapIdToCon.get(appRelNew.UAC_uacLookup__c).Phone,
                  mapIdToCon.get(appRelNew.UAC_uacLookup__c).Birthdate,
                  mapIdToCon.get(appRelNew.UAC_uacLookup__c).MailingStreet,
                  'Unknown'));
            }
          }
        }
      }
    }
    System.debug('existingRelationshipCreation End' + 'Limit::: ' + Limits.getLimitQueries() + '   '
        + 'Used::: ' + Limits.getQueries());
    return lstRelToInsert;
  }

  /*  @author       Abhisek Pati
      @description  Updates Reciprocal Relationships record on every update
      @param        List<UAC_apprehendedRelationship__c> lstNewItems
      @return       void
  */
  public
  static void RelationshipUpdates(Map<Id, SObject> mapNewItems, Map<Id, SObject> mapOldItems) {
    System.debug('RelationshipUpdates Start' + 'Limit::: ' + Limits.getLimitQueries() + '   '
        + 'Used::: ' + Limits.getQueries());
    if (booReciprocal) {
      System.debug('booReciprocal value inside if condition' + booReciprocal);
      return;
    }
    Map<Id, UAC_apprehendedRelationship__c> mapOldApprItems =
        (Map<Id, UAC_apprehendedRelationship__c>) mapOldItems;
    Map<Id, UAC_apprehendedRelationship__c> mapNewApprItems =
        (Map<Id, UAC_apprehendedRelationship__c>) mapNewItems;
    Map<Id, UAC_apprehendedRelationship__c> mapTriggerOld =
        new Map<Id, UAC_apprehendedRelationship__c>();
    List<UAC_apprehendedRelationship__c> lstTriggerNew = new List<UAC_apprehendedRelationship__c>();
    List<UAC_apprehendedRelationship__c> lstRelToUpdate =
        new List<UAC_apprehendedRelationship__c>();
    for (UAC_apprehendedRelationship__c uc : mapNewApprItems.values()) {
      if (mapOldApprItems.get(uc.id).recordTypeId == ID_UAC_RECORD_TYPE
          && (mapOldApprItems.get(uc.id).UAC_relationshipToUAC__c
                  != mapNewApprItems.get(uc.id).UAC_relationshipToUAC__c
              || mapOldApprItems.get(uc.id).UAC_relatedUAC__c
                  != mapNewApprItems.get(uc.id).UAC_relatedUAC__c)) {
        mapTriggerOld.put(uc.id, mapOldApprItems.get(uc.Id));
        uc.UAC_reciprocal__c = false;
        lstRelToUpdate.add(uc);
      }
    }
    booReciprocal = false;
    reciprocalDeletion(mapTriggerOld);
    booReciprocal = false;
    boolUpdate = true;
    reciprocalCreation(lstRelToUpdate);
    System.debug('RelationshipUpdates End' + 'Limit::: ' + Limits.getLimitQueries() + '   '
        + 'Used::: ' + Limits.getQueries());
  }

  /*  @author       James Qian
      @description  Creates map of relationship to metadata mapping
      @return       Map<String, UAC_relationshipMapping__mdt>
  */
  private
  static Map<String, UAC_relationshipMapping__mdt> getRelationshipMapping() {
    Map<String, UAC_relationshipMapping__mdt> mapRelationships =
        new Map<String, UAC_relationshipMapping__mdt>();

    for (UAC_relationshipMapping__mdt metadataMapping : [
           // clang-format off
      SELECT
        Id,
        MasterLabel,
        UAC_relationship__c,
        UAC_reverseRelationshipMale__c,
        UAC_reverseRelationshipDefault__c,
        UAC_reverseRelationshipFemale__c
      FROM
        UAC_relationshipMapping__mdt
           // clang-format on
         ]) {
      mapRelationships.put(metadataMapping.UAC_relationship__c, metadataMapping);
    }
    return mapRelationships;
  }

  /*  @author       James Qian
      @description  Creates map of relationship to metadata mapping
      @return       Map<String, UAC_relationshipMapping__mdt>
  */
  private
  static UAC_apprehendedRelationship__c createNewRelationship(Id idPrimary,
      Id idSecondary,
      String strFirstName,
      String strLastName,
      String strANum,
      String strPhone,
      Date dateDOB,
      String strAddress,
      String strRelationship) {
    return new UAC_apprehendedRelationship__c(UAC_uacLookup__c = idPrimary,
        UAC_relatedUAC__c = idSecondary,
        UAC_firstName__c = strFirstName,
        UAC_lastName__c = strLastName,
        UAC_alienNumber__c = strANum,
        UAC_phone__c = strPhone,
        UAC_address__c = strAddress,
        RecordTypeId = ID_UAC_RECORD_TYPE,
        UAC_reciprocal__c = true,
        UAC_relationshipToUAC__c = strRelationship);
  }

  /*  @author       James Qian
      @description  Returns query of existing relationships in map format
      @param        Set<Id> setIdToQuery
      @return       Map<Id, Set<UAC_apprehendedRelationship__c>>
  */
  private
  static Map<Id, Set<UAC_apprehendedRelationship__c>> getExistingRelationships(
      Set<Id> setIDsToQuery) {
    Map<Id, Set<UAC_apprehendedRelationship__c>> mapRelationships =
        new Map<Id, Set<UAC_apprehendedRelationship__c>>();
    for (UAC_apprehendedRelationship__c apprRel : [
           // clang-format off
          SELECT
            Id,
            Name,
            UAC_uacLookup__c,
            UAC_uacLookup__r.UAC_gender__c,
            UAC_uacLookup__r.FirstName,
            UAC_uacLookup__r.LastName,
            UAC_uacLookup__r.UAC_A__c,
            UAC_uacLookup__r.Birthdate,
            UAC_uacLookup__r.Phone,
            UAC_uacLookup__r.MailingStreet,
            UAC_relatedUAC__c,
            UAC_relatedUAC__r.UAC_gender__c,
            UAC_relatedUAC__r.FirstName,
            UAC_relatedUAC__r.LastName,
            UAC_relatedUAC__r.UAC_A__c,
            UAC_relatedUAC__r.Birthdate,
            UAC_relatedUAC__r.Phone,
            UAC_relatedUAC__r.MailingStreet,
            UAC_lastName__c,
            UAC_reciprocal__c,
            UAC_relationshipToUAC__c,
            UAC_alienNumber__c,
            UAC_phone__c,
            UAC_address__c
          FROM
            UAC_apprehendedRelationship__c
          WHERE
            UAC_uacLookup__c IN :setIDsToQuery
          AND
            RecordTypeId = :ID_UAC_RECORD_TYPE
           // clang-format on
         ]) {
      Set<UAC_apprehendedRelationship__c> setApprRel = new Set<UAC_apprehendedRelationship__c>();
      if (mapRelationships.containsKey(apprRel.UAC_uacLookup__c)) {
        setApprRel = mapRelationships.get(apprRel.UAC_uacLookup__c);
      }
      setApprRel.add(apprRel);
      mapRelationships.put(apprRel.UAC_uacLookup__c, setApprRel);
    }
    return mapRelationships;
  }
}