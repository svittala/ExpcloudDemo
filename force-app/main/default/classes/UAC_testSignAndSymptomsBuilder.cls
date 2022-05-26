/**
 * @File Name         : UAC_testSignAndSymptomsBuilder.cls
 * @Description       : Test builder class to build Sign and Symptoms records for test instance
 * @Group             : UAC_testSignAndSymptomsBuilder
 * @Author            : Ranjith kumar (AI-Vets)
 * @Last Modified By  : Karthi Subramanian (Deloitte)
 * @Last Modified On  : 11-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   08-03-2020   Ranjith kumar (AI-Vets)   Initial Version
 * 1.1   11-03-2020   Karthi Subramanian (Deloitte) Update Test Factory class with @isTest annotation
 **/
@isTest 
public with sharing class UAC_testSignAndSymptomsBuilder {
    public
    String strSignSymptom = 'Pain';
    public
    Boolean onsetDateUnknown = True;
    public
    String strlocationofPain = 'Chest';
    public
    Id idHealthEvaluation;
    public
    Id idUAC;
  
  
    /**
     * @description Method to set associated Health Evaluation record
     * @author Ranjith kumar(AI_Vets) | 08-03-2020
     * @param idHealthEvaluation Id of health evaluation record
     * @return UAC_testSignAndSymptomsBuilder
     */
    public
    UAC_testSignAndSymptomsBuilder setHealthEvaluation(Id idHealthEvaluation) {
      this.idHealthEvaluation = idHealthEvaluation;
      return this;
    }
  
    /**
     * @description Method to set associated UAC record
     * @author Ranjith kumar(AI_Vets) | 08-03-2020
     * @param idUAC Id of UAC contact record
     * @return UAC_testSignAndSymptomsBuilder
     */
    public
    UAC_testSignAndSymptomsBuilder setUAC(Id idUAC) {
      this.idUAC = idUAC;
      return this;
    }
  
    /**
     * @description Method to build shell record for Signs And Symptoms
     * @author Ranjith kumar(AI_Vets) | 08-03-2020
     * @return UAC_signsAndSymptoms__c
     */
    public
    UAC_signsAndSymptoms__c build() {
      return new UAC_signsAndSymptoms__c(UAC_associatedHealthEvaluation__c = idHealthEvaluation,
          UAC_associatedUAC__c = idUAC,
          UAC_signSymptom__c = strSignSymptom,
          UAC_onsetDateUnknown__c = onsetDateUnknown,
          UAC_locationofPain__c = strlocationofPain
          );
    }
  
    /**
     * @description Method to create Signs And Symptoms record
     * @author Ranjith kumar(AI_Vets) | 08-03-2020
     * @return UAC_signsAndSymptoms__c
     */
    public
    UAC_signsAndSymptoms__c buildAndSave() {
      UAC_signsAndSymptoms__c objSignAndSymptoms = this.build();
      insert objSignAndSymptoms;
      return objSignAndSymptoms;
    }
      
  }