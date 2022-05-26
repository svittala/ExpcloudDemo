/**
 * @File Name          : UC_userUpdateServiceTest.cls
 * @Description        : Test class for UC_userUpdateService
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : 
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 03-19-2021
 * @Modification Log   :
 *
 * Ver       Date            Author                   Modification
 * 1.0  03-19-2021   Karthi Subramanian (Deloitte) Initial Implementation.
  **/

@isTest(seeAllData = false)
public class UC_userUpdateServiceTest {

 /**
   * @description Test Method to create Account request form records and test negative scenario
   * @author Karthi Subramanian (Deloitte)
   * @return void a0rr000000Whn9aAAB
   **/
  @isTest static void updateUserORRFlagTest() {
    Test.startTest();
    User objUser =  new UC_testUserBuilder().buildAndSave();
    UC_userUpdateService.updateUserORRFlag(new Set<Id>{objUser.id});
    Test.stopTest();
    User objUserUpd =
    [Select Id, UAC_ORRAuthorizedUser__c from User where id =:objUser.id];
    System.assertEquals(true, objUserUpd.UAC_ORRAuthorizedUser__c);
  }
}