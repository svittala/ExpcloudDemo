/**
* @File Name         : UAC_PRIDLabTableControllerTest.cls
* @Description       : Test class for UAC_PRIDLabTableController
* @Group             : UAC_PRIDLabTableController
* @Author            : Anupreeta Chakraborty (Deloitte)
* @Last Modified By  : Anupreeta Chakraborty (Deloitte)
* @Last Modified On  : 08-04-2020
* Modifications Log
* Ver   Date         Author                             Modification
* 1.0   08-04-2020   Anupreeta Chakraborty (Deloitte)   Initial Version
**/
@isTest public class UAC_PRIDLabTableControllerTest {
    private
        static final String STR_A_NUM_UAC = '123456';
    private
        static final String STR_TEST_CLASS_NAME = UAC_PRIDLabTableControllerTest.class.getName();
    private 
        static final Id recordTypeId =
        Schema.SObjectType.UAC_Test__c.getRecordTypeInfosByDeveloperName()
        .get('UAC_PRIDLabTest').getRecordTypeId();
    
    /**
* @description Method to setup test data
* @author Anupreeta Chakraborty (Deloitte) | 08-04-2020
**/
    @TestSetup static void setupData() {
        Contact objUACContact = new UAC_testContactBuilder()
            .setANumber(STR_A_NUM_UAC)
            .setEmail(STR_A_NUM_UAC + '@example.invalid')
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
            .buildAndSave();
        UAC_healthEvaluation__c objIME =
            new UAC_testHealthEvaluationBuilder().setUAC(objUACContact.Id).buildAndSave();
    }
    
    /**
* @description Method to test all functionalities of UAC_PRIDLabTableController
* @author Anupreeta Chakraborty (Deloitte) | 08-04-2020
*/
    @isTest static void testPRIDLabTableController() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();  
        UAC_test__c uacTest = new UAC_test__c(UAC_test__c = 'IgM',
                                              UAC_result__c='Pending',
                                              RecordTypeId= recordTypeId,
                                              UAC_associatedHealthEvaluation__c= objIME.Id,
                                              UAC_diseaseConditionTested__c='HIV',
                                              UAC_associatedUAC__c = objIME.UAC_associatedUAC__c,
                                              UAC_testType__c='QuantiFERON',
                                              UAC_specimenSource__c='Stool',
                                              UAC_specimenCollectionDate__c = System.today()-10
                                             );
        insert uacTest;
        /*   UAC_testLabTestBuilder tb = new  UAC_testLabTestBuilder();
tb.setHealthEvaluation(objIME.Id);
tb.setUAC(objIME.UAC_associatedUAC__c);
List<UAC_test__c> labtests =tb.buildAndSave();   */   
        List<UAC_test__c> lstTest = UAC_PRIDLabTableController.getTestList(objIME.Id);
        System.assert(!lstTest.isEmpty(), 'Failed to get Test list');
        lstTest[0].UAC_diseaseConditionTested__c = Label.UAC_testPicklistLead;
        UAC_genericResponse objResponse =
            UAC_PRIDLabTableController.upsertTestList(JSON.serialize(lstTest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to update Test list');
        UAC_PRIDLabTableController.deleteTestList(JSON.serialize(lstTest));
        System.assertEquals(true, objResponse.isSuccess, 'Failed to delete Test list');
        lstTest = UAC_PRIDLabTableController.getTestList(objIME.Id);
        Test.stopTest();
        System.assertEquals(
            0, lstTest.size(), 'Test method: testPRIDTableController() failed.');
    }
	
    /**
* @description Method to test negative functionalities of UAC_PRIDLabTableController
* @author Anupreeta Chakraborty (Deloitte) | 11-05-2020
*/
    @isTest static void testPRIDLabTableControllerUpsertNegativeScenario() {
        UAC_healthEvaluation__c objIME = getIMEByUACANumber(STR_A_NUM_UAC);
        Test.startTest();  
        UAC_genericResponse objResponse =
            UAC_PRIDLabTableController.upsertTestList('Testing');
        System.assertEquals(false, objResponse.isSuccess, 'Updated Test list');
        Test.stopTest();
    } 
    
    /**
* @description Method to test all functionalities of UAC_PRIDLabTableController
* @author Anupreeta Chakraborty (Deloitte) | 11-05-2020
*/
    @isTest static void testPRIDLabTableControllerDeleteNegativeScenario() {
        Test.startTest();      
        UAC_genericResponse objResponse =
        UAC_PRIDLabTableController.deleteTestList('Testing');
        System.assertEquals(false, objResponse.isSuccess, 'Deleted Test list');
        Test.stopTest();
    }     	
    
    /**
* @description Method to get IME record by UAC A Number
* @author Anupreeta Chakraborty (Deloitte) | 08-04-2020
* @param strANumber String value for UAC A Number
* @return UAC_healthEvaluation__c
*/
    public
        static UAC_healthEvaluation__c getIMEByUACANumber(String strANumber) {
            // clang-format off
            return [
                SELECT
                Id,
                UAC_associatedUAC__c 
                FROM
                UAC_healthEvaluation__c
                WHERE
                UAC_associatedUAC__r.UAC_a__c = :strANumber
                LIMIT 1
            ];
            // clang-format on
        }
}