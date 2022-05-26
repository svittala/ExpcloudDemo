/**
 * @File Name          : UAC_backGroundChkTriggerHelperTest.cls
 * @Description        : Test class for trigger helper and handler for UAC_backgroundCheck__c 
 *object.
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 6/9/2020, 01:41:11 AM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/9/2020   Karthi Subramanian (Deloitte)     Initial Version
 **/
@isTest(seeAllData=false) public class UAC_backGroundChkTriggerHelperTest {
    static final String STR_ERROR_CANNOT_DELETE_RECORD =
      Label.UAC_backGroundChkError;
  
    static final String RELATION_TO_SPONSOR = 'Grandson';
    static final String STR_A_NUM_ADULT_CONTACT_1 = '1234561';
    static final String STR_A_NUM_ADULT_CONTACT_2 = '1234562';
    static final String STR_A_NUM_ADULT_CONTACT_SPONSOR = '123456';
    static final String STR_A_NUM_UAC = '1234';
  
    /**
     * @description Method to setup test data
     * @author Karthi Subramanian (Deloitte) | 6/9/2020
     * @return void
     **/
    @TestSetup static void setupData() {
      Contact objSponsor =
          new UAC_testContactBuilder()
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
              .setANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR)
              .build();
      
      Contact objAdultContact1 =
          new UAC_testContactBuilder()
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
              .setANumber(STR_A_NUM_ADULT_CONTACT_1)
              .build();
      Contact objAdultContact2 =
          new UAC_testContactBuilder()
              .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
              .setANumber(STR_A_NUM_ADULT_CONTACT_2)
              .build();
	  Contact objUAC = new UAC_testContactBuilder()
                           .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                           .setANumber(STR_A_NUM_UAC)
                           .build();
      insert new List<Contact>{objSponsor,objAdultContact1,objAdultContact2,objUAC};
      // Insert primary sponsor relationship for Sponsor Application case creation
      UAC_adultContactRelationship__c objAdultContactRelationship =
          new UAC_adultContactRelationship__c();
      objAdultContactRelationship.UAC_adultContact__c = objSponsor.id;
      objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
      objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
      objAdultContactRelationship.UAC_uacLookup__c = objUAC.id;
      insert objAdultContactRelationship;
      // Insert Sponsor Application Case
      Case objSponsorApplicationCase =
          new UAC_testCaseBuilder()
              .setSponsor(objSponsor.Id)
              .setUAC(objUAC.Id)
              .setRelationshipToUAC(objAdultContactRelationship.Id)
              .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
              .buildAndSave();

      UAC_associatedContact__c objAssociatedContact = new UAC_associatedContact__c();
              objAssociatedContact.UAC_contact__c = objAdultContact1.Id;
              objAssociatedContact.UAC_case__c = objSponsorApplicationCase.Id;
              objAssociatedContact.UAC_alternateAdultCaregiver__c = true;
              objAssociatedContact.UAC_relationshipToSponsor__c = RELATION_TO_SPONSOR;
      insert objAssociatedContact;
      UAC_associatedContact__c objAssociatedContact2 = new UAC_associatedContact__c();
              objAssociatedContact2.UAC_contact__c = objAdultContact2.Id;
              objAssociatedContact2.UAC_case__c = objSponsorApplicationCase.Id;
              objAssociatedContact2.UAC_familyAndFriends__c = true;
              objAssociatedContact2.UAC_relationshipToSponsor__c = RELATION_TO_SPONSOR;
      insert objAssociatedContact2;  
    }
   
   /**
   * @description ORRUAC-789: Delete Background Check Record
   * @author Karthi Subramanian (Deloitte) | 6/9/2020
   * @return void
   **/
  @isTest static void deleteBackgroundCheckRecordTest() {
    Set<String> fieldsToQuery = new Set<String>{'Id'};
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_1, fieldsToQuery);
    Contact objSponsor =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR, fieldsToQuery);
    Case objSponsorApplicationCase =[Select id,UAC_sponsor__c from Case where UAC_sponsor__c =:objSponsor.Id Limit 1];
    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(objAdultContact, objSponsorApplicationCase,false);
    UAC_backgroundCheck__c objbackGroundChk2 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(objAdultContact, objSponsorApplicationCase,true);

    String actualErrorMessage;  
    Test.startTest();
    Database.DeleteResult objDeleteResult1 = Database.delete(objbackGroundChk1.Id,false);
    Database.DeleteResult objDeleteResult2 = Database.delete(objbackGroundChk2.Id,false);
    if (!objDeleteResult2.isSuccess()) {
      actualErrorMessage = objDeleteResult2.getErrors()[0].getMessage();
    }
    Test.stopTest();
    System.assertEquals(STR_ERROR_CANNOT_DELETE_RECORD,
        actualErrorMessage,
        'Test method: deleteBackgroundCheckRecordTest() failed.');
  }

    /**
   * @description ORRUAC-437/469 - Validate background check record whether Adult Contact is Sponsor or HHM or AACG
   * @author Vaibhav Kudesia (Deloitte) | 6/25/2020
   * @param listBackGroundChkRecs
   * @return void
   **/
  @isTest static void canCreateBGRecordsTest() {
    String RELATION_TO_SPONSOR = 'Grandson';
    Set<String> fieldsToQuery = new Set<String>{'Id'};
    Contact objAdultContact =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_1, fieldsToQuery);
    Contact objAdultContact2 =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_2, fieldsToQuery);        
    Contact objSponsor =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR, fieldsToQuery);
    Case objSponsorApplicationCase =[Select id,UAC_sponsor__c from Case where UAC_sponsor__c =:objSponsor.Id Limit 1];   
        Test.startTest();
    	 UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(objSponsor, objSponsorApplicationCase,false);
         UAC_backgroundCheck__c objbackGroundChk2 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(objAdultContact, objSponsorApplicationCase,false);
        try{
         UAC_backgroundCheck__c objbackGroundChk3 = new UAC_testBackGroundCheckBuilder()
          											.buildAndSave(objAdultContact2, objSponsorApplicationCase,false);   
        }
        catch(exception e){
            system.assertEquals(True,e.getMessage().contains(Label.UAC_backGroundChkContactTypeError));
        }
     Test.stopTest();
        
    }
}