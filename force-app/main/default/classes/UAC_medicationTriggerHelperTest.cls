/**
 * @File Name          : UAC_medicationTriggerHelperTest.cls
 * @Description        : Test class for trigger helper and handler for UAC_medication__c
 *object.
 * @Author             : Omer Syed (Mutatio)
 * @Group              : UAC_test
 * @Last Modified By   : Omer Syed (Mutatio)
 * @Last Modified On   : 6/8/2020, 6:41:11 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/20/2020   Omer Syed (Mutatio)            Initial Version
 **/
@isTest(seeAllData = false)
public class UAC_medicationTriggerHelperTest {
    static final String STR_A_NUM_UAC = '123456';  
  /**
   * @description Method to setup test data
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @return void
   **/
    @TestSetup static void setupData() {
        Contact objUAC =
            new UAC_testContactBuilder()
                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                .setANumber(STR_A_NUM_UAC)
                .build();
                insert new List<Contact>{objUAC};
        UAC_Diagnosis__c Diagnosis =  new UAC_testDiagnosisBuilder()
                                        .buildAndSave(objUAC);
    }
      /**
   * @description ORRUAC-414: Validate Status update
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @return void
   **/
     @isTest static void medicationstatusupdatetocurrent() {

        //Create new Medication record 
        Contact objuac = [SELECT Id FROM Contact Limit 1];
        UAC_Diagnosis__c  diagnosis = [SELECT Id FROM UAC_diagnosis__c Limit 1];          
        Test.startTest();                                                                                              
        UAC_medication__c objMedication = new UAC_testMedicationBuilder()
          											.buildAndSave(objUAC, Diagnosis,null);
        System.assertEquals(objMedication.UAC_Status__c, System.label.UAC_medicationStatusCurrent);

        objMedication.UAC_DateDiscontinued__c = Date.today().addDays(+5);
        update objMedication;
        UAC_medication__c medicationtovalidate=[SELECT Id,UAC_Status__c FROM UAC_medication__c WHERE Id=:objMedication.Id];
        System.assertEquals(medicationtovalidate.UAC_Status__c, System.label.UAC_medicationStatusDiscont);

        Test.stopTest();
    }
      /**
   * @description ORRUAC-414: Validate datediscontinued and change status
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @return void
   **/
    @isTest static void medicationstatusupdatetodiscontinued() {
        //Create new Medication record                                                                                               
        List<UAC_medication__c> lstMedicationsToInsert = new List<UAC_medication__c>();    
        Contact objuac = [SELECT Id FROM Contact Limit 1];
        UAC_Diagnosis__c  diagnosis = [SELECT Id FROM UAC_diagnosis__c Limit 1];                                                                                         
        
        Test.startTest();

        UAC_medication__c objMedication = new UAC_testMedicationBuilder()
          											.buildAndSave(objUAC, Diagnosis,Date.today());
        
        UAC_medication__c medicationtovalidate=[SELECT Id,UAC_Status__c FROM UAC_medication__c WHERE Id=:objMedication.Id];
        System.assertEquals(medicationtovalidate.UAC_Status__c, System.label.UAC_medicationStatusDiscont);

        objMedication.UAC_DateDiscontinued__c = null;
        update objMedication;
        System.assertEquals(objMedication.UAC_Status__c, System.label.UAC_medicationStatusCurrent);

        Test.stopTest();
    }
	
	  /**
   * @description: Validate datediscontinued and change status when bypass settings is enabled.
   * @author Anupreeta Chakraborty | 9/27/2020
   * @return void
   **/
    @isTest static void bypassShouldNotMedicationstatusupdatetodiscontinued() {
        // Enabled Medication Trigger Bypass
        UAC_bypassSettings__c objBypassSettings = UAC_bypassSettings__c.getInstance();
        objBypassSettings.UAC_bypassMedicationTrigger__c = true;
        upsert objBypassSettings;
        //Create new Medication record                                                                                               
        List<UAC_medication__c> lstMedicationsToInsert = new List<UAC_medication__c>();    
        Contact objuac = [SELECT Id FROM Contact Limit 1];
        UAC_Diagnosis__c  diagnosis = [SELECT Id FROM UAC_diagnosis__c Limit 1];                                                                                         
        
        Test.startTest();

        UAC_medication__c objMedication = new UAC_testMedicationBuilder()
                                                    .buildAndSave(objUAC, Diagnosis,Date.today());
        
        System.assertNotEquals(objMedication.UAC_Status__c, System.label.UAC_medicationStatusDiscont);

        Test.stopTest();
    }
}