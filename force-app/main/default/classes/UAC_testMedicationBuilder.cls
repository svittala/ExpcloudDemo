/**
 * @File Name          : UAC_testMedicationBuilder.cls
 * @Description        : Builder class for creating Medication for unit test.
 * @Author             : Omer Syed (Mutatio Inc)
 * @Group              : UAC_TestBuilder
 * @Last Modified By   : Omer Syed (Mutatio Inc)
 * @Last Modified On   : 6/8/2020, 11:38:41 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/20/2020   Omer Syed (Mutatio Inc)       Initial Version
 * 1.1    11/11/2020  Abhisek Pati (Deloitte)       Removed Legacy Id
 **/
@isTest 
    public with sharing class UAC_testMedicationBuilder {
        public
        UAC_Medication__c build() {
            UAC_Medication__c objmedication = new UAC_Medication__c(
                UAC_dateStarted__c = System.Today(),
                UAC_direction__c  = 'TBD',
                UAC_dischargedWithMedication__c = Label.UAC_No,
                UAC_dose__c = 'TBD',
                UAC_psychotropic__c = Label.UAC_yes,
                UAC_status__c = Label.UAC_medicationStatusCurrent);
        return objmedication;
        }
        public
        UAC_medication__c buildAndSave(Contact adultContact, UAC_Diagnosis__c diagnosis, Date datediscontinued) {
            UAC_Medication__c objmedication = this.build();
            objmedication.UAC_associatedDiagnosis__c = diagnosis.id;
            objmedication.UAC_associatedUAC__c =adultContact.Id;
            objmedication.UAC_DateDiscontinued__c=datediscontinued;
          insert objmedication;
          return objmedication;
        }
}