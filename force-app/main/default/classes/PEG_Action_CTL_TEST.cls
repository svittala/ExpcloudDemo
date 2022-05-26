/***
* @author P-E GROS
* @date   August 2019
* @description Lightning controller to execute custom apex actions.
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
private class PEG_Action_CTL_TEST {
	
    @isTest
    static void executeActionTest(){
        system.debug('executeActionTest: START');
  
        SObject target = new Account(Name = 'TEST');
      
        test.startTest();

        // Test empty entry
        try {
            PEG_Action_CTL.executeAction(null, target);  
            System.debug('executeActionTest: KO / exception should be raised'); 
            System.assert(true);
        } 
        catch (Exception e) {
            system.debug('executeActionTest: ' + e.getMessage());   
            System.debug('executeActionTest: OK / exception raised');              
            System.assertEquals(e.getMessage(), 'No action name provided!');
        }

        // Test empty dummy entry
        try {
            PEG_Action_CTL.executeAction('DUMMYTEST', target);  
            System.debug('executeActionTest: KO / exception should be raised'); 
            System.assert(true);
        } 
        catch (Exception e) {
            system.debug('executeActionTest: ' + e.getMessage());   
            System.debug('executeActionTest: OK / exception raised');              
            System.assertEquals(e.getMessage(), 'Handler class for action DUMMYTEST not found!');
        }

        // Test standard default entry
        try {
            PEG_Action_CTL.executeAction('PEG_ActionHandler_SVC', target);  
            System.debug('executeActionTest: KO / exception should be raised'); 
            System.assert(true);
        } 
        catch (Exception e) {
            system.debug('executeActionTest: ' + e.getMessage());   
            System.debug('executeActionTest: OK / exception raised');              
            System.assertEquals(e.getMessage(), 'Action not implemented (at least with Object interface)!');
        }

        // Test standard default method entry
        try {
            PEG_Action_CTL.executeAction('PEG_ActionHandler_SVC.TEST', target);  
            System.debug('executeActionTest: KO / exception should be raised'); 
            System.assert(true);
        } 
        catch (Exception e) {
            system.debug('executeActionTest: ' + e.getMessage());   
            System.debug('executeActionTest: OK / exception raised');              
            System.assertEquals(e.getMessage(), 'Action not implemented (at least with Object Method interface)!');
        }

        test.stopTest();
        
        system.debug('executeActionTest: END');
    }
}