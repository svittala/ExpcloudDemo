/**
 * @File Name          : UAC_adultContactChildrenTriggerHelper.cls
 * @Description        : Helper method for UAC_adultContactChildrenTriggerHandler
 * @Author             : Issam Awwad (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_adultContactChildrenTriggerTest
 * @Last Modified By   : Issam Awwad (Deloitte)
 * @Last Modified On   : 2/1/2021
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    2/1/2021   Issam Awwad (Deloitte)        Initial Implementation.
 **/

public
without sharing class UAC_adultContactChildrenTriggerHelper {

  public
  static final String strErrorMessage = Label.UAC_errorMessageForAdultContactChildrenParent;

  /**
   * @description Validates that the adult contact is indicated as Father or Mother on relationship
   *record
   * @author Issam Awwad (Deloitte) 2/1/2021
   * @param List<UAC_adultContactsChildren__c> lstAdultContactsChildren
   **/
  public
  static void validateAdultContactIsParent(
      List<UAC_adultContactsChildren__c> lstAdultContactsChildren) {
    Map<Id, UAC_adultContactsChildren__c> mapOfAdultContactToADC =
        new Map<Id, UAC_adultContactsChildren__c>();
    Map<Id, Contact> mapOfContacts = new Map<Id, Contact>();
    Set<Id> setOfChildren = new Set<Id>();
    for (UAC_adultContactsChildren__c objAdultContactChildren : lstAdultContactsChildren) {
      mapOfAdultContactToADC.put(
          objAdultContactChildren.UAC_adultContact__c, objAdultContactChildren);
      setOfChildren.add(objAdultContactChildren.UAC_child__c);
    }
    List<Contact> lstOfChildren =
        [SELECT Id, UAC_inORRCare__c, recordType.developerName FROM Contact WHERE Id
          IN:setOfChildren];
    for (Contact objContact : lstOfChildren) {
      mapOfContacts.put(objContact.Id, objContact);
    }
    List<UAC_adultContactRelationship__c> lstOfADR = [SELECT Id,
      UAC_adultContact__c,
      UAC_relationshipToUAC__c,
      UAC_uacLookup__c FROM UAC_adultContactRelationship__c WHERE UAC_adultContact__c
      IN:mapOfAdultContactToADC.keySet()];
    Map<Id, List<UAC_adultContactRelationship__c>> mapOfContactToADR =
        new Map<Id, List<UAC_adultContactRelationship__c>>();
    for (UAC_adultContactRelationship__c objADR : lstOfADR) {
      List<UAC_adultContactRelationship__c> lstADR = new List<UAC_adultContactRelationship__c>();
      if (mapOfContactToADR.containsKey(objADR.UAC_uacLookup__c)) {
        lstADR = mapOfContactToADR.get(objADR.UAC_uacLookup__c);
        lstADR.add(objADR);
        mapOfContactToADR.put(objADR.UAC_uacLookup__c, lstADR);
      } else {
        lstADR.add(objADR);
        mapOfContactToADR.put(objADR.UAC_uacLookup__c, lstADR);
      }
    }
    for (UAC_adultContactsChildren__c objADC : lstAdultContactsChildren) {
      Boolean boolErrorFound = false;
      Contact objChild = mapOfContacts.get(objADC.UAC_child__c);
      if (objChild.UAC_inORRCare__c == 'Yes'
          && mapOfContactToADR.get(objADC.UAC_child__c) != null) {
        for (UAC_adultContactRelationship__c objADR : mapOfContactToADR.get(objADC.UAC_child__c)) {
          if (objADR.UAC_relationshipToUAC__c != Label.UAC_fatherRelationshipType
              && objADR.UAC_relationshipToUAC__c != Label.UAC_motherRelationshipType) {
            boolErrorFound = true;
          }
        }
      } else {
        boolErrorFound = true;
      }

      if (boolErrorFound
          && objChild.recordType.developerName == Label.UAC_contactRecordTypeApiNameUAC) {
        objADC.addError(strErrorMessage);
      }
    }
  }
}