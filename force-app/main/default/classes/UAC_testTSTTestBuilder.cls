/**
 * @File Name          : UAC_testTSTTestBuilder.cls
 * @Description        : Builder class for creating Test Object IGRA Record type for unit test.
 * @Author             : Manoj Bhagwat (EntelliMetrix)
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Manoj Bhagwat (EntelliMetrix)
 * @Last Modified On   : 08-13-2020
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    8/13/2020     Manoj Bhagwat (EntelliMetrix)    Initial Version
 **/

@isTest public with sharing class UAC_testTSTTestBuilder {
    public
    String strRecordTypeDeveloperName = Label.UAC_testRecTypeTBScreeningUnder2YearsAge;
    public
    Id idUAC;
    public
    Id idHealthEval;

     /**
     * @description Method to set RecordType
     * @author Manoj Bhagwat (EntelliMetrix) | 08/13/2020
     * @param strRecordTypeDeveloperName Value of strRecordTypeDeveloperName
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_testTSTTestBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
      this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
      return this;
    }

    /**
     * @description Method to set UAC Id
     * @author Manoj Bhagwat (EntelliMetrix) | 08/13/2020
     * @param idUAC Value of idUAC
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_testTSTTestBuilder setUAC(Id idUAC) {
      this.idUAC = idUAC;
      return this;
    }

    /**
     * @description Method to set Health Evaluation Id
     * @author Manoj Bhagwat (EntelliMetrix) | 08/13/2020
     * @param idHealthEval Value of idHealthEval
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_testTSTTestBuilder setHealthEval(Id idHealthEval) {
      this.idHealthEval = idHealthEval;
      return this;
    }
  
    /**
     * @description Method to build Test Object of IGRA Record Type
     * @author Manoj Bhagwat (EntelliMetrix) | 08/13/2020
     * @param N/A
     * @return UAC_testIGRATestBuilder
     **/ 
    public
    UAC_test__c build() {
      Id idRecordType = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName()
                            .get(strRecordTypeDeveloperName)
                            .getRecordTypeId();
        UAC_test__c objTSTTest = new UAC_test__c(RecordTypeId = idRecordType,
                                                 UAC_associatedUAC__c = idUAC,
                                                 UAC_associatedHealthEvaluation__c=idHealthEval,	
                                                 UAC_result__c='Pending',
                                                 UAC_diseaseConditionTested__c='Tuberculosis',
                                                 UAC_test__c='PPD/Tuberculin Skin Test (TST)'
                                                );
        return objTSTTest;
    }

    /**
     * @description Method to create Test Object of IGRA Record Type
     * @author Manoj Bhagwat (EntelliMetrix) | 08/13/2020
     * @param N/A
     * @return UAC_testIGRATestBuilder
     **/     
    public
    UAC_test__c buildAndSave() {
        UAC_test__c objTSTTest = this.build();
      insert objTSTTest;
      return objTSTTest;
    }
  }