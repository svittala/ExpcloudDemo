/**
 * @File Name          : UAC_testImmunizationBuilder.cls
 * @Description        : Builder class for creating Immunization for unit test.
 * @Author             : Abhisek Pati (Deloitte)
 * @Group              : UAC_testBuilder
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    8/12/2020     Abhisek Pati (Deloitte)    Initial Version
 **/
@isTest public with sharing class UAC_testImmunizationBuilder {
    
    public
    Id idUAC;
    public
    Id idHealthEval;

    /**
     * @description Method to set UAC Id
     * @author Abhisek Pati (Deloitte) | 08/12/2020
     * @param idUAC Value of idUAC
     * @return UAC_testImmunizationBuilder
     **/ 
    public
    UAC_testImmunizationBuilder setUAC(Id idUAC) {
      this.idUAC = idUAC;
      return this;
    }

    /**
     * @description Method to set Health Evaluation Id
     * @author Abhisek Pati (Deloitte) | 08/12/2020
     * @param idHealthEval Value of idHealthEval
     * @return UAC_testImmunizationBuilder
     **/ 
    public
    UAC_testImmunizationBuilder setHealthEval(Id idHealthEval) {
      this.idHealthEval = idHealthEval;
      return this;
    }
  
    /**
     * @description Method to build Test Object of Immunization
     * @author Abhisek Pati (Deloitte) | 08/12/2020
     * @param N/A
     * @return UAC_testImmunizationBuilder
     **/ 
    public
    UAC_immunization__c build() {
        UAC_immunization__c objImmunization = new UAC_immunization__c(
          UAC_associatedUAC__c = idUAC,
          UAC_associatedHealthEvaluation__c=idHealthEval,
          UAC_vaccine__c='DTaP',
          UAC_dateAdministered__c = system.today());
      return objImmunization;
    }

    /**
     * @description Method to create Test Object of IGRA Record Type
     * @author Abhisek Pati (Deloitte) | 08/12/2020
     * @param N/A
     * @return UAC_testImmunizationBuilder
     **/     
    public
    UAC_immunization__c buildAndSave() {
        UAC_immunization__c objImmunization = this.build();
      insert objImmunization;
      return objImmunization;
    }
  }