/**
 * @File Name          : UAC_testHealthEvaluationBuilder.cls
 * @Description        : Builder class for creating Health Evaluation for unit test.
 * @Author             : Anupreeta Chakraborty
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 11-03-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    7/14/2020     Anupreeta Chakraborty       Initial Version
 * 1.1    7/14/2020     Sachet Khanal (Deloitte)    Adding record type logic
 * 1.2    10/29/2020    Karthi Subramanian (Deloitte)  TestBuilder Method for MHSR and OON Site Visit
 * 1.3    11/3/2020     Karthi Subramanian (Deloitte)  use of getRecordTypeInfosByDeveloperName() instead of getRecordTypeInfosByName()
 **/
@isTest public with sharing class UAC_testHealthEvaluationBuilder {
  public
  String strRecordTypeDeveloperName = Label.UAC_healthEvaluationRecordTypeApiNameIME;
  public
  Id idUAC;
  public
  String strNameOfHealthcareProvider = 'Test Healthcare Provider';
  public
  String serviceCategory = 'Out of Network Stay';
  public
  Id idAssociatedHealthEval;
  
  public
  UAC_testHealthEvaluationBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
    this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
    return this;
  }

  public
  UAC_testHealthEvaluationBuilder setUAC(Id idUAC) {
    this.idUAC = idUAC;
    return this;
  }

  public
  UAC_testHealthEvaluationBuilder setServiceCategory(String serviceCategory) {
    this.serviceCategory = serviceCategory;
    return this;
  }

  public
  UAC_testHealthEvaluationBuilder setAssociatedHealthEval(Id idAssociatedHealthEval) {
    this.idAssociatedHealthEval = idAssociatedHealthEval;
    return this;
  }

  public
  UAC_HealthEvaluation__c build() {
    Id idRecordType = Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
                          .get(strRecordTypeDeveloperName)
                          .getRecordTypeId();

    UAC_HealthEvaluation__c objIME = new UAC_HealthEvaluation__c(RecordTypeId = idRecordType,
        UAC_associatedUAC__c = idUAC,
        UAC_nameofHealthcareProvider__c = strNameOfHealthcareProvider);
    return objIME;
  }
  public
  UAC_HealthEvaluation__c buildAndSave() {
    UAC_HealthEvaluation__c objIME = this.build();
    insert objIME;
    return objIME;
  }

  /**
     * @description Test Builder Method for Mental Health Service Report.
     * * @author Karthi Subrmanian (Deloitte) | 10-29-2020
     * @param N/A
     * @return UAC_HealthEvaluation__c
  **/
  public
  UAC_HealthEvaluation__c buildMentalHealthServiceReport() {
    Id idRecordType = Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
                          .get(strRecordTypeDeveloperName)
                          .getRecordTypeId();

    UAC_HealthEvaluation__c objMHSR = new UAC_HealthEvaluation__c(RecordTypeId = idRecordType,
        UAC_associatedUAC__c = idUAC,
        UAC_nameofHealthcareProvider__c = strNameOfHealthcareProvider,
        UAC_serviceCategory__c=serviceCategory);
    insert  objMHSR;   
    return objMHSR;
  }
  
  /**
     * @description Test Builder Method for OON Site Visit.
     * * @author Karthi Subrmanian (Deloitte) | 10-29-2020
     * @param N/A
     * @return UAC_HealthEvaluation__c
  **/
  public
  UAC_HealthEvaluation__c buildOONSiteVisit() {
    Id idRecordType = Schema.SObjectType.UAC_healthEvaluation__c.getRecordTypeInfosByDeveloperName()
                          .get(strRecordTypeDeveloperName)
                          .getRecordTypeId();

    UAC_HealthEvaluation__c objOONSiteVisit = new UAC_HealthEvaluation__c(RecordTypeId = idRecordType,
        UAC_associatedUAC__c = idUAC,
        UAC_nameofHealthcareProvider__c = strNameOfHealthcareProvider,
        UAC_associatedHealthEvaluation__c=idAssociatedHealthEval);
    insert  objOONSiteVisit;   
    return objOONSiteVisit;
  }

}