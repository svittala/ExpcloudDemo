/**
 * @File Name          : UAC_testMedicationBuilder.cls
 * @Description        : Builder class for creating Diagnosis for unit test.
 * @Author             : Omer Syed (Mutatio Inc)
 * @Group              : UAC_TestBuilder
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 09-15-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    6/20/2020   Omer Syed (Mutatio Inc)       Initial Version
 * 1.1    11/11/2020  Abhisek Pati (Deloitte)       Removed Legacy Id
 **/
@isTest public with sharing class UAC_testDiagnosisBuilder {

  Id idAssociatedUAC;
  Id idAssociatedHealthEval;

  /**
   * @description Set associated Health Evaluation Id
   * @author Sachet Khanal (Deloitte) | 09-15-2020
   * @param idAssociatedUAC Id of associated Health Evaluation
   * @return UAC_testDiagnosisBuilder
   **/
  public
  UAC_testDiagnosisBuilder setAssociatedHealthEval(Id idAssociatedHealthEval) {
    this.idAssociatedHealthEval = idAssociatedHealthEval;
    return this;
  }

  /**
   * @description Set associated UAC Id
   * @author Sachet Khanal (Deloitte) | 09-15-2020
   * @param idAssociatedUAC Id of associated UAC contact
   * @return UAC_testDiagnosisBuilder
   **/
  public
  UAC_testDiagnosisBuilder setAssociatedUAC(Id idAssociatedUAC) {
    this.idAssociatedUAC = idAssociatedUAC;
    return this;
  }

  public
  UAC_Diagnosis__c build() {
    UAC_Diagnosis__c objDiagnosis = new UAC_Diagnosis__c(
        UAC_wDCategory__c = 'Dental',
        UAC_wdMedicationName__c = 'TBD',
        UAC_wdMedicationPrescribed__c = Label.UAC_Yes,
        UAC_associatedUAC__c = idAssociatedUAC,
        UAC_associatedHealthEvaluation__c = idAssociatedHealthEval,
        UAC_WDCondition__c = 'Tooth Sensitivity');
    return objDiagnosis;
  }

  public
  UAC_Diagnosis__c buildAndSave() {
    UAC_Diagnosis__c objDiagnosis = this.build();
    insert objDiagnosis;
    return objDiagnosis;
  }

  public
  UAC_Diagnosis__c buildAndSave(Contact uacContact) {
    UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
                                         .setUAC(uacContact.Id)
                                         .setRecordTypeDeveloperName(Label.UAC_IMERectype)
                                         .buildAndSave();
    return this.setAssociatedUAC(uacContact.Id).setAssociatedHealthEval(objIME.Id).buildAndSave();
  }
}