/**
* @File Name          : UAC_fetchHealthEvaluationController.cls
* @Description        : This class is used for Apex controller fetch associated exposure health
                        evaluation for current exposure events.
* @Author             : Vijayakumar Pethanan (Deloitte)
* @Group              : UAC_exposureEventTable
* @Test Class         : UAC_fetchHealthEvaluationControllerTest
* @Last Modified By   : Sachet Khanal (Deloitte)
* @Modification Log   : Initial version
* Ver       Date            Author                      Modification
* 1.0    9/9/2020   Vijayakumar Pethanan (Deloitte)  Initial version.
**/
public
with sharing class UAC_fetchHealthEvaluationController {

  /**
   * @description Method to get list of health evaluation records related to an exposure event.
   * @author Vijayakumar Pethanan (Deloitte) | 09-14-2020
   * @param exposureEventId Id of exposure event record
   * @return List<UAC_healthEvaluation__c>
   **/
  @AuraEnabled public static List<UAC_healthEvaluation__c> getExposureContacts(
      String exposureEventId) {
    // clang-format off
    return [
    SELECT
      Id, Name,
      UAC_aNum__c, UAC_PHIAge__c, UAC_associatedUAC__r.name, UAC_dateofLastExposure__c,
      UAC_outcomeofORRPHI__c, UAC_currentProgram__c, UAC_dischargeDateforMostRecentORRStay__c
    FROM
      UAC_healthEvaluation__c
    WHERE
      UAC_exposureEvent__c =: exposureEventId
    ORDER BY
      Name DESC
    ];
    // clang-format on
  }
}