/**
 * @File Name          : UAC_testImagingStudyTestBuilder.cls
 * @Description        : Builder class for creating Health Evaluation for unit test.
 * @Author             : Ranjith kumar
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Ranjith kumar (AI-Vets)
 * @Last Modified On   : 08-10-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    8/05/2020     Ranjith kumar (AI-Vets)    Initial Version
 **/
@isTest public with sharing class UAC_testImagingStudyTestBuilder {
    public
    String strRecordTypeDeveloperName = Label.UAC_testRecTypeImagingStudy;
    public
    Id idUAC;
    public
    Id idHealthEval;

    public
    UAC_testImagingStudyTestBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
      this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
      return this;
    }
  
    public
    UAC_testImagingStudyTestBuilder setUAC(Id idUAC) {
      this.idUAC = idUAC;
      return this;
    }

    public
    UAC_testImagingStudyTestBuilder setHealthEval(Id idHealthEval) {
      this.idHealthEval = idHealthEval;
      return this;
    }
  
    public
    UAC_test__c build() {
      Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                            .get(strRecordTypeDeveloperName)
                            .getRecordTypeId();
        UAC_test__c objImagingStudyTest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='MRI',
          UAC_diseaseConditionTested__c = 'Tuberculosis',   
          UAC_result__c='Pending',
          UAC_specimenCollectionDate__c=system.today());
      return objImagingStudyTest;
    }
    public
    UAC_test__c buildAndSave() {
        UAC_test__c objImagingStudyTest = this.build();
      insert objImagingStudyTest;
      return objImagingStudyTest;
    }
  }