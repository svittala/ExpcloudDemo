/**
 * @File Name          : UAC_BusinessDaysUtilityTest.cls
 * @Description        : Provides test class coverage for UAC_BusinessDaysUtility
 * @Author             : Ankur Aggarwal (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : Ankur Aggarwal (Deloitte)
 * @Last Modified On   : 5/30/2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/30/2020   Ankur Aggarwal (Deloitte)     Initial Implementation.
 **/
@isTest(seeAllData = false) public with sharing class UAC_BusinessDaysUtilityTest {
/**
   * @description Method to test auto-population of administrative account for Adult Contacts
   * @author Ankur Aggarwal (Deloitte) | 5/30/2020
   * @return void
   **/
  @isTest static void UAC_BusinessDaysTest() {
    UAC_BusinessDaysUtility testInstanceBusinessUtility = new UAC_BusinessDaysUtility();    

    date cal = system.today().adddays(-10);
    system.debug(system.now());
    for(integer i = 0;i < 20 ;i++){
        testInstanceBusinessUtility.adddays(cal.adddays(i),1);
        
    }
    system.assertNotEquals(cal.addDays(10), testInstanceBusinessUtility.adddays(cal,10));

    system.debug(system.now());
    for(integer i = 0;i < 20 ;i++){
        testInstanceBusinessUtility.subtractDays(cal.adddays(i),1);       
    }    
    

    testInstanceBusinessUtility.getNextWorkingDay(cal);
    testInstanceBusinessUtility.isWorkingDay(cal);
    testInstanceBusinessUtility.getNoOfBusinessDaysBetweenDates(cal, system.now());

    testInstanceBusinessUtility = new UAC_BusinessDaysUtility('Default');
  }
}