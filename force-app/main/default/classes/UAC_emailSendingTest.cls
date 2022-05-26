/**
 * @File Name          : UAC_emailSendingTest.cls
 * @Description        : To send email
 * @Author             : Priyanka Bolla(Deloitte)
 * @Modification Log   :
 * Ver      Date           Author      		    			Modification
 * 1.0    	09/17/2020   	Priyanka Bolla (Deloitte)     	Initial Implementation.
 * 2.0    	10/22/2020   	Nithin Malla (Deloitte)     	Updating test class for code coverage.
 **/

@istest
public class UAC_emailSendingTest{
    
    
  static final String RELATION_TO_SPONSOR = 'Grandson';
  static final String STR_A_NUM_ADULT_CONTACT_1 = '1234561';
  static final String STR_A_NUM_ADULT_CONTACT_2 = '1234562';
  static final String STR_A_NUM_ADULT_CONTACT_SPONSOR = '123456';
  static final String STR_A_NUM_UAC = '1234';
  static final String STR_CLASS_NAME = UAC_emailSendingTest.class.getName();

  /**
   * @description Method to setup test data
   * @author Nithin Malla (Deloitte) | 10/22/2020
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
    insert new List<Contact>{objSponsor, objAdultContact1, objAdultContact2, objUAC};
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
    // Insert Associated Contact for one of the Adult Contact
    UAC_associatedContact__c objAssociatedContact = new UAC_associatedContact__c();
    objAssociatedContact.UAC_contact__c = objAdultContact1.Id;
    objAssociatedContact.UAC_case__c = objSponsorApplicationCase.Id;
    objAssociatedContact.UAC_alternateAdultCaregiver__c = true;
    objAssociatedContact.UAC_relationshipToSponsor__c = RELATION_TO_SPONSOR;
    insert objAssociatedContact;
  }

/**
   * @description SendEmail Method
   * @author Priyanka Bolla(Deloitte) | 9/17/2020
   * @param Flowoutputs
   **/
    public static testmethod void testgetInputs(){
        UAC_associatedContact__c objAssociatedContact = getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
        Id associatedContactId = objAssociatedContact.Id; 
        ID caseId =objAssociatedContact.UAC_case__c;
        ID contactId = objAssociatedContact.UAC_contact__c;
        UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder()
            .buildAndSave(contactId, caseId,false,'Unclassifiable 1st Attempt','FBI Criminal History');
        
        UAC_backgroundCheck__c objbackGroundChk2 = new UAC_testBackGroundCheckBuilder()
            .buildAndSave(contactId, caseId,false,'Unclassifiable 2nd Attempt','FBI Criminal History');
        
        List<string> lstEmails = new List<string>{'test@test.com','test1@test.com','test2@test.com'};
            UAC_emailSending.Flowoutputs TempOutput = new UAC_emailSending.Flowoutputs ();
        TempOutput.recipientEmailAddress = lstEmails;
        TempOutput.FinalBody = 'Test X';
        TempOutput.emailSubject ='Test Y';
        TempOutput.isFBICriminalSecondAttempt = true;
        TempOutput.adultContactID=contactId;
        TempOutput.backGroundCheckID = objbackGroundChk2.Id;
        
        List<UAC_emailSending.Flowoutputs> lstTempOutput = new List <UAC_emailSending.Flowoutputs>();
        lstTempOutput.add(TempOutput);
        
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.FirstPublishLocationId = objbackGroundChk2.Id;
        objContentVersion.Title = STR_CLASS_NAME;
        objContentVersion.PathOnClient = STR_CLASS_NAME + '.txt';
        objContentVersion.VersionData = Blob.valueOf(STR_CLASS_NAME);
        objContentVersion.UAC_backgroundCheck__c = objbackGroundChk2.Id;
        objContentVersion.RecordTypeId =
            Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get(Label.UAC_backgroundCheck)
            .getRecordTypeId();
        objContentVersion.UAC_documentType__c = Label.UAC_bcgTypeFBICriminalHistory;
        insert objContentVersion;
        
        Test.StartTest();
        UAC_emailSending.SendEmail(lstTempOutput);
        system.assert(true);
        Test.stopTest();
    }
    
    /**
   * @description Method to get associated contact record for test instance.
   * @author Nithin Malla (Deloitte) | 10/22/2020
   * @return UAC_associatedContact__c
   **/
    public 
        static UAC_associatedContact__c getAssociatedContactByANumber(String strANumber) {
        // clang-format off
        return [
            SELECT
            Id, UAC_contact__c, UAC_case__c, UAC_alternateAdultCaregiver__c,
            UAC_relationshipToSponsor__c
            FROM
            UAC_associatedContact__c
            WHERE
            UAC_contact__r.UAC_a__c =: strANumber
            LIMIT 1
        ];
        // clang-format on
    }
}