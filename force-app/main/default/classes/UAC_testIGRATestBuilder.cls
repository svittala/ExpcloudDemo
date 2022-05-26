/**
 * @File Name          : UAC_testIGRATestBuilder.cls
 * @Description        : Builder class for creating Test Object IGRA Record type for unit test.
 * @Author             : Karthi Subramanian
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 08-3-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    8/3/2020     Karthi Subramanian (Deloitte)    Initial Version
 **/
@isTest public with sharing class UAC_testIGRATestBuilder {
    public
    String strRecordTypeDeveloperName = Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder;
    public
    Id idUAC;
    public
    Id idHealthEval;

     /**
     * @description Method to set RecordType
     * @author Karthi Subramanian (Deloitte) | 08/3/2020
     * @param strRecordTypeDeveloperName Value of strRecordTypeDeveloperName
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_testIGRATestBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
      this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
      return this;
    }

    /**
     * @description Method to set UAC Id
     * @author Karthi Subramanian (Deloitte) | 08/3/2020
     * @param idUAC Value of idUAC
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_testIGRATestBuilder setUAC(Id idUAC) {
      this.idUAC = idUAC;
      return this;
    }

    /**
     * @description Method to set Health Evaluation Id
     * @author Karthi Subramanian (Deloitte) | 08/3/2020
     * @param idHealthEval Value of idHealthEval
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_testIGRATestBuilder setHealthEval(Id idHealthEval) {
      this.idHealthEval = idHealthEval;
      return this;
    }
  
    /**
     * @description Method to build Test Object of IGRA Record Type
     * @author Karthi Subramanian (Deloitte) | 08/3/2020
     * @param N/A
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_test__c build() {
      Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                            .get(strRecordTypeDeveloperName)
                            .getRecordTypeId();
        UAC_test__c objIGRATest = new UAC_test__c(RecordTypeId = idRecordType,
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_test__c='TB Blood Test (Interferon-Gamma Release Assay [IGRA])',
          UAC_diseaseConditionTested__c	= 'Tuberculosis',	
          UAC_result__c='Indeterminate',
          UAC_testType__c='QuantiFERON',
          UAC_specimenCollectionDate__c=system.today());
      return objIGRATest;
    }

    /**
     * @description Method to create Test Object of IGRA Record Type
     * @author Karthi Subramanian (Deloitte) | 08/3/2020
     * @param N/A
     * @return UAC_testIGRATestBuilder
     **/     
    public
    UAC_test__c buildAndSave() {
        UAC_test__c objIGRATest = this.build();
      insert objIGRATest;
      return objIGRATest;
    }
  }