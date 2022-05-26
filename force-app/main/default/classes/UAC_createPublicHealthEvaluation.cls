/**
 * @File Name          : UAC_createPublicHealthEvaluation.cls
 * @Description        : This class is used create public health evaluation.
 * @Author             : Vijayakumar Pethanan (Deloitte)
 * @Group              : UAC_exposureEventTable
 * @Test Class         : UAC_createPublicHealthEvaluationTest
 * @Last Modified By   : Abhisek Pati (Deloitte)
 * @Modification Log   : Initial version
 *
 * Ver       Date            Author                      Modification
 * 1.0    9/11/2020   Vijayakumar Pethanan (Deloitte)  Initial version.
 * 1.1    7/20/2021   Abhisek Pati (Deloitte)          ORRUAC-6049 Added error handling code.
 **/

public
with sharing class UAC_createPublicHealthEvaluation {

  static final String STRING_TB_RECORD_TYPE = 'UAC_activeTBPublicHealthInvestigation';

  static final String STRING_NON_TB_RECORD_TYPE = 'UAC_nonTBDiseasePublicHealthInvestigation';

  static final String STRING_TB_DISEASE = 'TB, Active Disease';

  public
  static final Id ID_RECORD_TYPE_TB =
      Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
          .get(STRING_TB_RECORD_TYPE)
          .getRecordTypeId();

  public
  static final Id ID_RECORD_TYPE_NON_TB =
      Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
          .get(STRING_NON_TB_RECORD_TYPE)
          .getRecordTypeId();

  @AuraEnabled public static UAC_genericResponse createPHI(Id exposureEventId, List<Id> uacIdList) {

    UAC_genericResponse objResponse = new UAC_genericResponse();
    objResponse.isSuccess = true;
    // clang-format off
    UAC_exposureEvent__c exposureEvent = [
      SELECT
        UAC_diseaseCondition__c,
        UAC_specifyCondition__c,
        UAC_diseaseConditionType__c
      FROM
        UAC_exposureEvent__c
      WHERE
        Id =: exposureEventId
    ];
    // clang-format on
    List<UAC_healthEvaluation__c> healthEvaluationList = new List<UAC_healthEvaluation__c>();
    for (Contact uacContact :
        // clang-format off
        [SELECT
          Id, UAC_currentAge__c, UAC_dischargeDateforMostRecentORRStay__c,
          UAC_admissionDateforMostRecentORRStay__c
        FROM
          Contact
        WHERE
          Id IN :uacIdList
        ]
        // clang-format on
    ) {
      UAC_healthEvaluation__c phi = new UAC_healthEvaluation__c();
      if (STRING_TB_DISEASE == exposureEvent.UAC_diseaseCondition__c) {
        phi.recordtypeId = ID_RECORD_TYPE_TB;
      } else {
        phi.recordtypeId = ID_RECORD_TYPE_NON_TB;
      }
      phi.UAC_diseaseCondition__c = exposureEvent.UAC_diseaseCondition__c;
      phi.UAC_specifyCondition__c = exposureEvent.UAC_specifyCondition__c;
      phi.UAC_diseaseConditionType__c = exposureEvent.UAC_diseaseConditionType__c;
      phi.UAC_sourceofPotentialExposure__c = 'Person-Specific';
      phi.UAC_associatedUAC__c = uacContact.id;
      phi.UAC_exposureEvent__c = exposureEvent.id;
      phi.UAC_outcomeofORRPHI__c = 'Pending';
      phi.UAC_PHIAge__c = Integer.valueOf(uacContact.UAC_currentAge__c);
      phi.UAC_admissionDateforMostRecentORRStay__c =
          uacContact.UAC_admissionDateforMostRecentORRStay__c;
      phi.UAC_dischargeDateforMostRecentORRStay__c =
          uacContact.UAC_dischargeDateforMostRecentORRStay__c;
      healthEvaluationList.add(phi);
    }

    if (healthEvaluationList.isEmpty() == false) {

      try {
        insert healthEvaluationList;
      } catch (DMLException e) {
        objResponse.isSuccess = false;
        objResponse.error = e.getDmlMessage(0);
        UAC_errorLog.platformEventErrorLog(e.getDmlMessage(0),
            exposureEventId,
            'UAC_createPublicHealthEvaluation cls insert on HealthEvaluation List ',
            e.getStackTraceString());
      }
    }
    return objResponse;
  }
}