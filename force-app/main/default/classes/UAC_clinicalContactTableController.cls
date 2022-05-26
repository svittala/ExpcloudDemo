/**
 * @File Name         : UAC_clinicalContactTableController.cls
 * @Description       : Controller class for uacClinicalContactTable.
 * @Group             : UAC_clinicalContactTable
 * @Test Class        : UAC_clinicalContactTableControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 11-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-02-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
with sharing class UAC_clinicalContactTableController {
  @AuraEnabled public static UAC_genericResponse createClinicalContacts(
      Id associatedEventId, List<Id> uacIdList) {
    UAC_genericResponse objResponse = new UAC_genericResponse();
    try {
      // clang-format off
      UAC_event__c objEvent = [
        SELECT
          Id, UAC_eventStartDateTime__c, UAC_eventType__c
        FROM
          UAC_event__c
        WHERE
          Id =:associatedEventId
      ];
      // clang-format on
      Id idClinicalContactRTID =
          Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
              .get(Label.UAC_healthEvaluationRecordTypeApiNameClinicalContact)
              .getRecordTypeId();
      List<UAC_healthEvaluation__c> lstHealthEval = new List<UAC_healthEvaluation__c>();
      for (Contact objUAC :
          // clang-format off
          [SELECT
            Id, UAC_admissionDateforMostRecentORRStay__c, UAC_dischargeDateforMostRecentORRStay__c
          FROM
            Contact
          WHERE
            Id IN :uacIdList
          ]
          // clang-format on
      ) {
        UAC_healthEvaluation__c objClinicalContact = new UAC_healthEvaluation__c();
        objClinicalContact.RecordTypeId = idClinicalContactRTID;
        objClinicalContact.UAC_associatedUAC__c = objUAC.Id;
        objClinicalContact.UAC_associatedEvent__c = associatedEventId;
        objClinicalContact.UAC_contactDateTime__c = objEvent.UAC_eventStartDateTime__c;
        objClinicalContact.UAC_typeOfContact__c = objEvent.UAC_eventType__c;
        objClinicalContact.UAC_attemptStatus__c = Label.UAC_statusInProgress;
        objClinicalContact.UAC_admissionDateforMostRecentORRStay__c =
            objUAC.UAC_admissionDateforMostRecentORRStay__c;
        objClinicalContact.UAC_dischargeDateforMostRecentORRStay__c =
            objUAC.UAC_dischargeDateforMostRecentORRStay__c;
        lstHealthEval.add(objClinicalContact);
      }
      insert lstHealthEval;
      objResponse.isSuccess = true;
    } catch (Exception ex) {
      objResponse.error = ex.getMessage();
    }
    return objResponse;
  }
}