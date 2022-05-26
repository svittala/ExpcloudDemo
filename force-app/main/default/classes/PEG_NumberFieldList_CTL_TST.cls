/***
* @description Test class for the PEG_NumberFieldList_CTL class.
* @author      P-E GROS
* @date        Oct. 2019
* @see         PEG_NumberFieldList_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public class PEG_NumberFieldList_CTL_TST {

/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');

        System.debug('testSetup: END');
    }

/***
* @description Tests the "getDefaultValue" method, which should always return
*              the default N/A value.
***/
    static TestMethod void testGetDefaultValue() {
        System.debug('testGetDefaultValue: START'); 
        Test.startTest();

        VisualEditor.DesignTimePageContext  testContext = new VisualEditor.DesignTimePageContext();
        testContext.entityName =  'Lead';
        System.debug('testGetDefaultValue: testContext init'); 

        PEG_NumberFieldList_CTL controller = new PEG_NumberFieldList_CTL(testContext);
        System.debug('testGetDefaultValue: controller init'); 
        
        VisualEditor.DataRow defVal = controller.getDefaultValue();
        System.debug('testGetDefaultValue: getDefaultValue called ' + defVal); 

        System.assertEquals('N/A',defVal.getValue());

        Test.stopTest();
        System.debug('testGetDefaultValue: END');
    }

/***
* @description Tests the "getValues" method, which should always include
*              the default N/A value.
***/
    static TestMethod void testGetValues() {
        System.debug('testGetValues: START'); 
        Test.startTest();

        VisualEditor.DesignTimePageContext  testContext = new VisualEditor.DesignTimePageContext();
        testContext.entityName =  'Lead';
        System.debug('testGetValues: testContext init'); 

        PEG_NumberFieldList_CTL controller = new PEG_NumberFieldList_CTL(testContext);
        System.debug('testGetValues: controller init'); 
        
        VisualEditor.DynamicPickListRows listVal = controller.getValues();
        System.debug('testGetValues: getValues called ' + listVal); 

        System.assert(listVal.size() > 0);

        Test.stopTest();
        System.debug('testGetValues: END');
    }
}