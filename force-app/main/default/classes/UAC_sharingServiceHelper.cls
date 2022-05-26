/**
 * @File Name          : UAC_sharingServiceHelper.cls
 * @Description        : Batch Service Helper Class
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              :
 * @Test Class         : UAC_sharingRecalculateBatchTest
 * @Last Modified By   : Sarang Padhye (Deloitte)
 * @Last Modified On   : 8/30/2020,
 * @Modification Log   :
 * Ver       Date            Author                      Modification
 * 1.0    8/28/2020   Sarang Padhye (Deloitte)        Initial Implementation.
 */

/**
 * @description ORRUAC-1850 - Method deletes Account Team Members
 * @author Sarang Padhye (Deloitte) | 08/28/2020
 * @param listAtmToBeDeleted Account Team Members to be deleted
 * @return void
 **/
public
without sharing class UAC_sharingServiceHelper {
  @testVisible private static Boolean forceException = false;

  public
  static void deleteAccountTeamMems(List<AccountTeamMember> listAtmToBeDeleted) {
    Database.DeleteResult[] lstDR = new List<Database.DeleteResult>();

    if (!listAtmToBeDeleted.isEmpty()) {
      lstDR = Database.delete(listAtmToBeDeleted, false);
    }

    // Test Exception
    if (Test.isRunningTest() && forceException) {
      lstDR[0] = (Database.DeleteResult) JSON.deserialize(
          '{"success":false,"errors":[{"message":"Failure while deletion","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
          Database.DeleteResult.class);
    }
    for (Database.DeleteResult dr : lstDR) {
      if (!dr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : dr.getErrors()) {
          UAC_errorLog.logError(
              err.getMessage(), '', 'deleteAccountTeamMems:Error deleting Account Team Members', '');
        }
      }
    }
  }
  /**
   * @description ORRUAC-1850 - Method Deletes Case Team Members
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param listCtmToBeDeleted Case Team Members to be deleted
   * @return void
   **/
  public
  static void deleteCaseTeamMems(List<CaseTeamMember> listCtmToBeDeleted) {
    Database.DeleteResult[] lstDR = new List<Database.DeleteResult>();

    if (!listCtmToBeDeleted.isEmpty()) {
      lstDR = Database.delete(listCtmToBeDeleted, false);
    }
    // Test Exception
    if (Test.isRunningTest() && forceException) {
      lstDR[0] = (Database.DeleteResult) JSON.deserialize(
          '{"success":false,"errors":[{"message":"Failure while deletion","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
          Database.DeleteResult.class);
    }
    for (Database.DeleteResult dr : lstDR) {
      if (!dr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : dr.getErrors()) {
          UAC_errorLog.logError(
              err.getMessage(), '', 'deleteCaseTeamMems:Error deleting Case Team Members', '');
        }
      }
    }
  }
  /**
   * @description ORRUAC-1850 - Method updates the UAC_Sharing_Recalculated__c on Case
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param listCasesToBeUpdated Case records to be updated
   * @return void
   **/
  public
  static void updateSharingRecalculated(List<case> listCasesToBeUpdated) {
    Database.SaveResult[] lstSR = new List<Database.SaveResult>();

    if (!listCasesToBeUpdated.isEmpty()) {
      for (case c : listCasesToBeUpdated) {
        c.UAC_Sharing_Recalculated__c = true;
      }
    }

    if (!listCasesToBeUpdated.isEmpty()) {
      lstSR = Database.update(listCasesToBeUpdated, false);
    }
    // Test Exception
    if (Test.isRunningTest() && forceException) {
      lstSR[0] = (Database.SaveResult) JSON.deserialize(
          '{"success":false,"errors":[{"message":"Failure while deletion","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}',
          Database.SaveResult.class);
    }
    for (Database.SaveResult sr : lstSR) {
      if (!sr.isSuccess()) {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          UAC_errorLog.logError(
              err.getMessage(), '', 'updateSharingRecalculated:Error updating UAC_Sharing_Recalculated__c', '');
        }
      }
    }
  }
  /**
   * @description ORRUAC-1850 - Method finds the Accoun Team Members to be deleted
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstDischargedProgAtm Account Team Members related to DN case
   * @param lstUACFamGroupAtm Account Team Members related to the Family group account
   * @param lstUACProgramAtm Account Team Members related to the UACs program
   * @param lstAccTeamToBeDeleted Account Team Members to be deleted
   * @return lstAccTeamToBeDeleted Total Account Team Members to be deleted
   **/
  public
  Static List<AccountTeamMember> findATmDeleteCandidates(
      List<AccountTeamMember> lstDischargedProgAtm,
      List<AccountTeamMember> lstUACFamGroupAtm,
      List<AccountTeamMember> lstUACProgramAtm,
      List<AccountTeamMember> lstAccTeamToBeDeleted) {

    Map<String, AccountTeamMember> mapDischargeUserToAtm = new Map<String, AccountTeamMember>();
    Set<String> setuUACProgramUser = new Set<String>();
    try {
      if (lstUACProgramAtm != null || !lstUACProgramAtm.isEmpty()) {
        for (AccountTeamMember atm : lstUACProgramAtm) {
          setuUACProgramUser.add(atm.UserId);
        }
      }

      if (lstDischargedProgAtm != null || !lstDischargedProgAtm.isEmpty()) {
        for (AccountTeamMember atm : lstDischargedProgAtm) {
          mapDischargeUserToAtm.put(atm.UserId, atm);
        }
      }

      if (!lstDischargedProgAtm.isEmpty() && !lstUACFamGroupAtm.isEmpty()) {
        for (AccountTeamMember atm : lstUACFamGroupAtm) {

          if (mapDischargeUserToAtm.get(atm.UserId) != null) {
            lstAccTeamToBeDeleted.add(atm);
          }
        }
      }

      // Remove Profiles current program Atm users from this list
      for (Integer i = (lstAccTeamToBeDeleted.size() - 1); i >= 0; i--) {
        if (setuUACProgramUser.contains(lstAccTeamToBeDeleted.get(i).Userid)) {
          lstAccTeamToBeDeleted.remove(i);
        }
      }
      // Test Exception
      if (Test.isRunningTest() && forceException) {
        throw new System.DmlException('test exception');
      }

    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'findATmDeleteCandidates:Error finding Account Team Member delete candidates',
          e.getStackTraceString());
    }
    return lstAccTeamToBeDeleted;
  }
  /**
   * @description ORRUAC-1850 - Method finds the case team members to be deleted
   * @author Sarang Padhye (Deloitte) | 08/28/2020
   * @param lstDischargedProgAtm Account Team Members related to DN case
   * @param lstCaseTeamMem Case Team Members of all cases related to UAC
   * @param lstUACProgramAtm Account Team Members related to the UACs program
   * @param lstCaseTeamToBeDeleted Case Team Members to be deleted
   * @return lstCaseTeamToBeDeleted Total Case Team Members to be deleted
   **/
  public
  Static List<CaseTeamMember> findCtmDeleteCandidates(List<AccountTeamMember> lstDischargedProgAtm,
      List<CaseTeamMember> lstCaseTeamMem,
      List<AccountTeamMember> lstUACProgramAtm,
      List<CaseTeamMember> lstCaseTeamToBeDeleted) {

    Map<String, AccountTeamMember> mapDischargeUserToAtm = new Map<String, AccountTeamMember>();
    Set<String> setuUACProgramUser = new Set<String>();
    try {
      if (lstUACProgramAtm != null || !lstUACProgramAtm.isEmpty()) {
        for (AccountTeamMember atm : lstUACProgramAtm) {
          setuUACProgramUser.add(atm.UserId);
        }
      }
      if (lstDischargedProgAtm != null || !lstDischargedProgAtm.isEmpty()) {
        for (AccountTeamMember atm : lstDischargedProgAtm) {
          mapDischargeUserToAtm.put(atm.UserId, atm);
        }
      }

      if (!lstDischargedProgAtm.isEmpty() && !lstCaseTeamMem.isEmpty()) {
        for (CaseTeamMember ctm : lstCaseTeamMem) {
          if (mapDischargeUserToAtm.get(ctm.MemberId) != null) {
            lstCaseTeamToBeDeleted.add(ctm);
          }
        }
      }

      // Remove Profiles current program Atm users from this list
      for (Integer i = (lstCaseTeamToBeDeleted.size() - 1); i >= 0; i--) {
        if (setuUACProgramUser.contains(lstCaseTeamToBeDeleted.get(i).MemberId)) {
          lstCaseTeamToBeDeleted.remove(i);
        }
      }

      if (Test.isRunningTest() && forceException) {
        throw new System.DmlException('test exception');
      }

    } catch (Exception e) {
      UAC_errorLog.logError(e.getMessage(), '',
          'findCtmDeleteCandidates:Error finding Case Team Member delete candidates',
          e.getStackTraceString());
    }
    return lstCaseTeamToBeDeleted;
  }
}