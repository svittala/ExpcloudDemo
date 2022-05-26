/**
*___________________________________________________
* @Name: UAC_addressHistoryTest
* @Author: Ankur Aggarwal
* @Created Date: May 07, 2020 
* @Used_By: UAC PATH
*___________________________________________________
* @Description: Test class for UAC_addressHistory.trigger
                Test class for UAC_addressHistoryHandler.cls
                Test class for UAC_addressHistoryServices.cls
*___________________________________________________
* @Changes:
*
**/
@isTest (seeAllData=false)
public with sharing class UAC_addressHistoryTest {
    //Constants defined for Class   
    static final String UAC_cannotDeleteVerified = System.Label.UAC_cannotDeleteVerified;
    static final String UAC_currentAddressExist = System.Label.UAC_currentAddressExist;
    static final String UAC_dateCannotOverlap = System.Label.UAC_dateCannotOverlap;
    /*  @author       Ankur Aggarwal
        @description  Creates the data required to run the test method
        @param        N/A
        @return       N/A
    */ 
    @testSetup static void setupMethod() {
        list<contact> lstContacts = new list<contact>();
        list<UAC_addressHistory__c> lstAddressHistory = new list<UAC_addressHistory__c>();
        
        for(integer i =0; i <10 ; i ++){
            Contact tempContact = new contact();
            tempContact.lastName = 'Test Last Name ' + i;
            tempContact.FirstName = 'Test First Name '+ i;
            lstContacts.add(tempContact);        
        }
        insert lstContacts;
        for(Contact tempContact : lstContacts){
          
            UAC_addressHistory__c tempAddress = new UAC_addressHistory__c();
            tempAddress.UAC_adultContact__c = tempContact.id;
            //Begin of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
            tempAddress.UAC_country__c = 'United States of America';
            //End of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
            tempAddress.UAC_address__c = 'Temp Address';
            tempAddress.UAC_city__c = 'Temp City' ;
            tempAddress.UAC_dateFrom__c = system.today().adddays(-30);
            tempAddress.UAC_dateTo__c = system.today().adddays(-10);
            tempAddress.UAC_state__c = 'WA';
            tempAddress.UAC_zip__c = '12345';
            lstAddressHistory.add(tempAddress);
            
            UAC_addressHistory__c tempAddressCurrent = new UAC_addressHistory__c();
            tempAddressCurrent.UAC_adultContact__c = tempContact.id;
            //Begin of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
            tempAddress.UAC_country__c = 'United States of America';
            //End of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
            tempAddressCurrent.UAC_address__c = 'Temp Address' ;
            tempAddressCurrent.UAC_city__c = 'Temp City' ;
            tempAddressCurrent.UAC_dateFrom__c = system.today().adddays(-9);
            tempAddressCurrent.UAC_Current__c = true;
            tempAddressCurrent.UAC_state__c = 'WA';
            tempAddressCurrent.UAC_zip__c = '12345';
            lstAddressHistory.add(tempAddressCurrent);
            
        } 
        insert lstAddressHistory;
    }
    /*  @author       Ankur Aggarwal
        @description  test the insert of second Current address record
        @param        N/A
        @return       N/A
    */ 
    @isTest static void insertSecondCurrent() {
        Contact tempContact = [select id from contact where lastname = 'Test Last Name 1'];
        UAC_addressHistory__c tempAddress = new UAC_addressHistory__c();
        tempAddress.UAC_adultContact__c = tempContact.id;
        tempAddress.UAC_address__c = 'Temp Address' ;
        //Begin of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
        tempAddress.UAC_country__c = 'United States of America';
        //End of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
        tempAddress.UAC_city__c = 'Temp City' ;
        tempAddress.UAC_dateFrom__c = system.today().adddays(-60);
        tempAddress.UAC_Current__c = true;
        tempAddress.UAC_state__c = 'WA';
        tempAddress.UAC_zip__c = '12345';
        try{
            insert tempAddress;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(UAC_currentAddressExist)? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    /*  @author       Ankur Aggarwal
        @description  test the update of second Current address record
        @param        N/A
        @return       N/A
    */     
    @isTest static void updateSecondCurrent() {
        UAC_addressHistory__c ContactAddress = [select id from UAC_addressHistory__c where UAC_current__c = false limit 1];
        ContactAddress.uac_current__c = true;
        try{
            update ContactAddress;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(UAC_currentAddressExist) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    /*  @author       Ankur Aggarwal
        @description  test the insert of an address with overlapping dates
        @param        N/A
        @return       N/A
    */     
    @isTest static void insertOverlappingDatesTest() {
        Contact tempContact = [select id from contact where lastname = 'Test Last Name 1'];
        UAC_addressHistory__c tempAddress = new UAC_addressHistory__c();
        tempAddress.UAC_adultContact__c = tempContact.id;
        tempAddress.UAC_address__c = 'Temp Address' ;
        //Begin of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
        tempAddress.UAC_country__c = 'United States of America';
        //End of Change -ORR-UAC-252- Country Required -Priyanka--5/29/2020
        tempAddress.UAC_city__c = 'Temp City' ;
        tempAddress.UAC_dateFrom__c = system.today().adddays(-5);
        tempAddress.UAC_dateTo__c = system.today().adddays(-1);
        tempAddress.UAC_state__c = 'WA';
        tempAddress.UAC_zip__c = '12345';   
        try{
            insert tempAddress;    
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(UAC_dateCannotOverlap) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        // Implement test code
    }
    /*  @author       Ankur Aggarwal
        @description  test the update of an address with overlapping dates
        @param        N/A
        @return       N/A
    */     
    @isTest static void UpdateOverlappingDatesTest() {
        UAC_addressHistory__c ContactAddress = [select id from UAC_addressHistory__c where UAC_current__c = false limit 1];
        ContactAddress.UAC_dateTo__c = system.today().adddays(-4);
        try{
            update ContactAddress;    
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(UAC_dateCannotOverlap) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        // Implement test code
    }      
    /*  @author       Ankur Aggarwal
        @description  test the verfied adress cannot be deleted
        @param        N/A
        @return       N/A
    */     
    @isTest static void DeleteVerifiedTest() {
        UAC_addressHistory__c ContactAddress = [select id from UAC_addressHistory__c limit 1];
        delete ContactAddress;
        undelete ContactAddress;
        ContactAddress.UAC_googleMapsVerified__c = true;
        update ContactAddress;
        
        try{
            delete ContactAddress;
        }
        catch(exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(UAC_cannotDeleteVerified) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        // Implement test code
    }        

}