/**
 * @File Name         : UAC_progressBarController.cls
 * @Description       : Controller for uacProgressBar LWC
 * @Group             : UAC_progressBar
 * @Test Class        : UAC_progressBarControllerTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-26-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-17-2020   Sachet Khanal (Deloitte)   Initial Version
 **/
public
with sharing class UAC_progressBarController {

  /**
   * @description Method to get list of sections to display progress indicator
   * @author Sachet Khanal (Deloitte) | 07-17-2020
   * @param idRecord Id of record to query section status
   * @param strRelatedTo Related module name for displaying progress indicator
   * @return List<UAC_section>
   **/
  @AuraEnabled public static List<UAC_section> getSectionList(
      String idRecord, String strRelatedTo) {
    List<UAC_section> lstSection = new List<UAC_section>();

    try {
      String strObjectName = ((Id) idRecord).getSobjectType().getDescribe().getName();
      for (UAC_progressIndicator__mdt objProgressIndicator :
          // clang-format off
        [
        SELECT
          Id, UAC_sectionName__c, UAC_sectionStatusFieldApiName__c, UAC_flowApiName__c, UAC_order__c
        FROM
          UAC_progressIndicator__mdt
        WHERE
          UAC_relatedTo__c = :strRelatedTo
        ORDER BY
          UAC_order__c ASC
        ]
          // clang-format on
      ) {
        String strStatusField = (objProgressIndicator.UAC_sectionStatusFieldApiName__c != null)
            ? strObjectName + '.' + objProgressIndicator.UAC_sectionStatusFieldApiName__c
            : null;
        lstSection.add(new UAC_section(objProgressIndicator.UAC_sectionName__c,
            strStatusField,
            objProgressIndicator.UAC_flowApiName__c));
      }
    } catch (Exception ex) {
      UAC_errorLog.platformEventErrorLog(
          ex.getMessage(), idRecord, 'Progress Indicator', ex.getStackTraceString());
      throw new AuraHandledException(ex.getMessage());
    }
    return lstSection;
  }

  public
  inherited sharing class UAC_section {
    @AuraEnabled public String strName;
    @AuraEnabled public String strStatusField;
    @AuraEnabled public String strFlowName;

    public
    UAC_section(String strName, String strStatusField, String strFlowName) {
      this.strName = strName;
      this.strStatusField = strStatusField;
      this.strFlowName = strFlowName;
    }
  }
}