/**
 * @File Name         :
 * @Description       :
 * @Group             :
 * @Test Class        :
 * @Author            :
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 10-02-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-02-2020   Sachet Khanal (Deloitte)   Initial Version
 * 2.0   7/16/2021    Nithin Malla (Deloitte)    Exclusion Logic updates.
 **/
@isTest private class UAC_clinicalContactTableControllerTest {
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final String STR_ACCNT_STATUS = 'Draft';

  /**
   * @description Method to setup test data.
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   **/
  @TestSetup static void setupData() {
    Contact objUACContact = new UAC_testContactBuilder()
                                .setANumber(STR_A_NUM_UAC)
                                .setEmail(STR_A_NUM_UAC + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .buildAndSave();
      
      // Instantiate related program
      Account objProgram =
          new UAC_testAccountBuilder()
          // Set record type to Program
          .setRecordTypeDeveloperName(System.Label.UAC_accountRecordTypeAPINameProgram)
          // Set required fields 
          .setStatus(STR_ACCNT_STATUS)
          .setType(STRING_FIELD_TYPE)
          // Build object, but don't insert
          .build();
      objProgram.UC_activeInPath__c = true;
      insert objProgram;
  }

  /**
   * @description Method to test creation of Clinical Contact.
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   **/
  @isTest static void createClinicalContactsShouldInsertClinicalContact() {
    Contact objUACContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_UAC, new Set<String>{'Id'});
      
    Account objProgram = [Select id from account where recordtype.developername=:System.Label.UAC_accountRecordTypeAPINameProgram limit 1];
    UAC_event__c objEvent = new UAC_testEventBuilder().buildAndSave(objProgram);
    Test.startTest();
    UAC_genericResponse response = UAC_clinicalContactTableController.createClinicalContacts(
        objEvent.Id, new List<Id>{objUACContact.Id});
    Test.stopTest();
    System.assert(response.isSuccess,
        'Test method: createClinicalContactsShouldInsertClinicalContact() failed.');
  }
}