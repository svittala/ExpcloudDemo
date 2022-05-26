/**
 * @File Name          : UAC_TestTriggerHelper.cls
 * @Description        : Helper method for UAC_MedicalTestTriggerHandler
 * @Author             : Ram Josyer (Creative Sys)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_TestTriggerHelperTest
 * @Last Modified By   : Ram Josyer (Creative Sys)
 * @Last Modified On   : 11-24-2020
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    11/24/2020   Ram Josyer (Creative Sys)   Initial Implementation.
 **/
public
without sharing class UAC_TestTriggerHelper {

  


   /**
   * @description ORRUAC-498 - Method to Auto Populate Medical Team Email from Program of  UAC
   *record
   * @author Ram Josyer (Creative Sys) | 11/24/2020
   * @param
   * @return void
   **/
  public
  static void populateMedicalTeamEmail(List<UAC_Test__c> lstNewMedicalTest) {

    UAC_EmailFieldUtility.populateMedicalTeamEmail(lstNewMedicalTest);
  }
}