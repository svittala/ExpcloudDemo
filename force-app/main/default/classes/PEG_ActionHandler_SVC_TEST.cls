/***
* @author P-E GROS
* @date   August 09 2019
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
private class PEG_ActionHandler_SVC_TEST {
    
    @isTest
    static void executeActionTest(){
        System.debug('executeActionTest: START');
        Object target = new Account(Name = 'TEST');
        PEG_ActionHandler_SVC pegExecAction = new PEG_ActionHandler_SVC();        
        
        test.startTest();
        try{
            Object execAct = pegExecAction.executeAction(target);
            System.debug('executeActionTest: KO / exception should be raised');                
            System.assert(false);
        } 
        catch (Exception e) {
            System.debug('executeActionTest: OK / exception raised ' + e.getMessage());                
            System.assertEquals(e.getMessage(), 'Action not implemented (at least with Object interface)!');
        }

        try{
            Object execAct = pegExecAction.executeActionMethod('method',target);
            System.debug('executeActionTest: KO / exception should be raised');                
            System.assert(false);
        } 
        catch (Exception e) {
            System.debug('executeActionTest: OK / exception raised ' + e.getMessage());                
            System.assertEquals(e.getMessage(), 'Action not implemented (at least with Object Method interface)!');
        }
        
        test.stopTest();
        System.debug('executeActionTest: START');
    }

	 
    @isTest
    static void actionOptionExceptionTest(){
        System.debug('actionOptionExceptionTest: START');
        String message = 'test';
        List<Object> details = new List<Account>();
        List<Object> options = new List<Account>();
    
        test.startTest();
        PEG_ActionHandler_SVC.PEG_ActionOptionException pegTest = new PEG_ActionHandler_SVC.PEG_ActionOptionException(message, details, options);
        System.debug('actionOptionExceptionTest: OK / exception should not be raised');                
        System.assert(true);
        test.stopTest();

        System.debug('actionOptionExceptionTest: END');
    }
}