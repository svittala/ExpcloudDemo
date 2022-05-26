/**
* @File Name          : UAC_exposureEventTriggerTest.cls
* @Description        : Helper method for UC_exposureEventTriggerHandler
* @Author             : Satish (Kvortex) 
* @Group              : UAC_triggerHelper
* @Last Modified By   : Satish (Kvortex) 
* @Last Modified On   : 07/14/2021
* @Modification Log   :
*
* Ver       Date            Author                      Modification
* 1.0    07-14-2021   Satish (Kvortex)   Initial Implementation.
**/@isTest(seeAllData = false)public class UAC_exposureEventTriggerTest {
    private
        static final String STR_A_NUM_UAC = '123456';
    private
        static Contact objUACContact;
    private
        static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    private
        static UAC_Diagnosis__c objDiagnosis;
    private
        static Account objProgram;
    
    /**
* @description Method to create test data
* @author Satish (Kvortex) | 07/14/2021
**/
    @TestSetup static void setupData() {
        UAC_bypassSettings__c setting = new UAC_bypassSettings__c();
        setting.Name = 'System Administrator Setting';
        setting.UC_bypassExclusionLogic__c = true;
        setting.SetupOwnerId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        insert setting;    Contact objUACContact = new UAC_testContactBuilder()
            .setANumber(STR_A_NUM_UAC)
            .setEmail(STR_A_NUM_UAC + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
            .build();
        
        insert objUACContact;
        UAC_healthEvaluation__c objIME = new UAC_testHealthEvaluationBuilder()
            .setUAC(objUACContact.Id)
            .setRecordTypeDeveloperName(Label.UAC_IMERectype)
            .buildAndSave();
        
    }
    
    
    /**
* @Exposure Event Testing Creation of Test Data
* @author Satish (Kvortex) | 07/14/2021
* @return void
**/
    @isTest static void createExposureEvent() {
        UAC_healthEvaluation__c objHealthEval = getHealthEvaluationByANumber(STR_A_NUM_UAC);
        Test.startTest();
        UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
            .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
            .setAssociatedHealthEval(objHealthEval.Id)
            .build();
        diagnosis.UAC_status__c = Label.UAC_statusFinal;
        diagnosis.UAC_potentiallyExposedUAC__c = Label.UAC_Yes;
        diagnosis.UAC_WDCategory__c = 'Potentially Reportable Infectious Disease';
        diagnosis.UAC_WDCondition__c = 'Rubella';
        diagnosis.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c = Label.UAC_No;
        insert diagnosis;
        Test.stopTest();
        UAC_exposureEvent__c exposureEvent =
            [SELECT id, UAC_diseaseCondition__c FROM UAC_exposureEvent__c];
        exposureEvent.UAC_exposureDescription__c = 'Test';
        Update exposureEvent;
        Delete exposureEvent;
        undelete exposureEvent;
        System.assertEquals(diagnosis.UAC_WDCondition__c,
                            exposureEvent.UAC_diseaseCondition__c,
                            'Exposure event condition doesn\'t match disease condition');
    }
    
    public
        static UAC_healthEvaluation__c getHealthEvaluationByANumber(String strANumber) {
            // clang-format off
            return [
                SELECT
                Id, Name, UAC_associatedUAC__c
                FROM
                UAC_healthEvaluation__c
                WHERE
                UAC_associatedUAC__r.UAC_a__c = :strANumber
                LIMIT 1
            ];
            // clang-format on
        }
    
}