/**
 * @File Name          : UAC_testTBTestBuilder.cls
 * @Description        : Builder class for creating Test Object TB Record type for unit test.
 * @Author             : Abhisek Pati
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Abhisek Pati
 * @Last Modified On   : 02-16-2021
 * @Modification Log   :
 * Ver       Date         Author                 Modification
 * 1.0    02/16/2021     Abhisek Pati          Added Comments, Initial Version by Ram
 **/

@isTest 
public class UAC_testTBTestBuilder {
    public static UAC_test__c uacTbbbTestRecord(String recDevName, String status, 
    String healthEvalId,String UACId) {
        String recTypeId = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName().get(recDevName).getRecordTypeId();
        UAC_test__c uacTest = new UAC_test__c(
                                              UAC_result__c=status,
                                              RecordTypeId=recTypeId,
                                              UAC_associatedHealthEvaluation__c=healthEvalId,
                                              UAC_diseaseConditionTested__c='Tuberculosis',
                                              UAC_associatedUAC__c =UACId,
                                              UAC_testType__c='QuantiFERON',
                                              UAC_specimenSource__c='Tissue',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        if(recDevName == Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder) {
            uacTest.UAC_test__c = 'TB Blood Test (Interferon-Gamma Release Assay [IGRA])';
        }else if(recDevName == Label.UAC_testRecTypeTBScreeningUnder2YearsAge) {
            uacTest.UAC_test__c = 'PPD/Tuberculin Skin Test (TST)';
            uacTest.UAC_datePerformed__c = System.today()-7;      
            uacTest.UAC_specimenSource__c='Tissue';
            uacTest.UAC_dateRead__c = System.today()-5;
            uacTest.UAC_reactionInMM__c = 12;
        }else if(recDevName == Label.UAC_testRecTypeImagingStudy) {
            uacTest.UAC_test__c = 'MRI';
        }else if(recDevName == Label.UAC_testRecTypeBacteriologicalResults) {
            uacTest.UAC_test__c = 'TB Culture';
        }
        return uacTest;
    }  
    
}