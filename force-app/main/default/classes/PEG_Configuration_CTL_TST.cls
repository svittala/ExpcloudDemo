/***
* @description Test class for the PEG_Configuration_CTL class.
* @author      P-E GROS
* @date        Nov. 2019
* @see         PEG_Configuration_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public class PEG_Configuration_CTL_TST {

/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');

        System.debug('testSetup: END');
    }


/***
* @description Tests the "getFieldSetDesc" method.
***/
    static TestMethod void testGetFieldSetDesc() {
        System.debug('testGetFieldSetDesc: START'); 
        Test.startTest();

        // OK Cases
        try {
            Map<String,Object> fsDesc = PEG_Configuration_CTL.getFieldSetDesc('PEG_TEST__c.PEG_TEST');
            System.debug('testGetFieldSetDesc: no exception raised OK and desc returned ' + fsDesc);
            System.assertNotEquals(null, fsDesc);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised KO ' + e.getMessage());
            System.assert(false);
        }
           
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST__c.PEG_TEST');
            Map<String,Object> fsDesc = PEG_Configuration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised OK and desc list returned ' + fsDesc);
            System.assertNotEquals(null, fsDesc);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised KO ' + e.getMessage());
            System.assert(false);
        }
        
        // Error Cases
        System.debug('testGetFieldSetDesc: Starting error case');
        try {
            PEG_Configuration_CTL.getFieldSetDesc(null);
            System.debug('testGetFieldSetDesc: no exception raised KO with null FS');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised OK with null FS ' + e.getMessage());
            System.assert(true);
        }
        
        try {
            PEG_Configuration_CTL.getFieldSetDescs(null);
            System.debug('testGetFieldSetDesc: no exception raised KO with null list');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised OK with null list ' + e.getMessage());
            System.assert(true);
        }
        
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST__c.SF_PEG_DUMMY_FIELDSET');
            PEG_Configuration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised KO for dummy FS');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised OK for dummy FS ' + e.getMessage());
            System.assert(true);
        }

        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_DUMMYTEST__c.SF_PEG_DUMMY_FIELDSET');
            PEG_Configuration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised KO for dummy object');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised OK for dummy object ' + e.getMessage());
            System.assert(true);
        }
        
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST__c.Test');
            PEG_Configuration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised for dummy FS KO');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised for dummy FS OK ' + e.getMessage());
            System.assert(true);
        }
       
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST');
            PEG_Configuration_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised for bad format KO');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised bad format OK ' + e.getMessage());
            System.assert(true);
        }
        
        Test.stopTest();
        System.debug('testGetFieldSetDesc: END');
    }
    
    
/***
* @description Tests the "getRecordTypeIDs" method.
***/
    static TestMethod void testGetRecordTypeIDs() {
        System.debug('testGetRecordTypeIDs: START'); 
        Test.startTest();

        // OK Cases
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST__c.PEG_TEST');
            Map<String,Object> idList = PEG_Configuration_CTL.getRecordTypeIDs(nameList);
            System.debug('testGetRecordTypeIDs: no exception raised OK and list returned ' + idList);
            System.assertNotEquals(null, idList);
        }
        catch (Exception e) {
            System.debug('testGetRecordTypeIDs: exception raised KO ' + e.getMessage());
            System.assert(false);
        }
        
        // Error Cases
        System.debug('testGetRecordTypeIDs: Starting error case');
        try {
            PEG_Configuration_CTL.getRecordTypeIDs(null);
            System.debug('testGetRecordTypeIDs: no exception raised KO with null list');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetRecordTypeIDs: exception raised OK with null list ' + e.getMessage());
            System.assert(true);
        }
        
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST__c.SF_PEG_DUMMY_RECORDTYPE');
            PEG_Configuration_CTL.getRecordTypeIDs(nameList);
            System.debug('testGetRecordTypeIDs: no exception raised KO with dummy RT');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetRecordTypeIDs: exception raised OK with dummy RT ' + e.getMessage());
            System.assert(true);
        }

        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST');
            PEG_Configuration_CTL.getRecordTypeIDs(nameList);
            System.debug('testGetRecordTypeIDs: no exception raised KO with bad format');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetRecordTypeIDs: exception raised OK with bad format ' + e.getMessage());
            System.assert(true);
        }
        
        Test.stopTest();
        System.debug('testGetRecordTypeIDs: END');
    }
    
/***
* @description Tests the "getListViewIDs" method.
***/
    static TestMethod void testGetListViewIDs() {
        System.debug('testGetListViewIDs: START'); 
        Test.startTest();

        // OK Cases
        try {
            List<String> nameList = new List<String>();
            nameList.add('Lead.AllOpenLeads');
            nameList.add('Account.AllAccounts');
            nameList.add('Account.MyAccounts');
            Map<String,Object> idList = PEG_Configuration_CTL.getListViewIDs(nameList);
            System.debug('testGetListViewIDs: no exception raised OK and list returned ' + idList);
            System.assertNotEquals(null, idList);
        }
        catch (Exception e) {
            System.debug('testGetListViewIDs: exception raised KO ' + e.getMessage());
            System.assert(false);
        }
        
        // Error Cases
        System.debug('testGetListViewIDs: Starting error case');
        try {
            PEG_Configuration_CTL.getListViewIDs(null);
            System.debug('testGetListViewIDs: no exception raised KO with null list');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetListViewIDs: exception raised OK with null list ' + e.getMessage());
            System.assert(true);
        }
        
        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST__c.PEG_TEST_DUMMYLIST');
            PEG_Configuration_CTL.getListViewIDs(nameList);
            System.debug('testGetListViewIDs: no exception raised KO with dummy list');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetListViewIDs: exception raised OK with dummy list ' + e.getMessage());
            System.assert(true);
        }

        try {
            List<String> nameList = new List<String>();
            nameList.add('PEG_TEST_DUMMYLIST');
            PEG_Configuration_CTL.getListViewIDs(nameList);
            System.debug('testGetListViewIDs: no exception raised KO with bad format');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetListViewIDs: exception raised OK with bad format ' + e.getMessage());
            System.assert(true);
        }
        
        Test.stopTest();
        System.debug('testGetListViewIDs: END');
    }
}