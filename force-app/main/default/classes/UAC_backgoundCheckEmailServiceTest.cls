/**
 * @File Name          : UAC_backgoundCheckEmailService.cls
 * @Description        : Test class for validating backgound Check Email Service.
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_TestBuilder
 * @Last Modified By   : Nithin Malla (Deloitte)
 * @Last Modified On   : 09-15-2020
 * @Modification Log   :
 * Ver  		Date        			Author                                	Modification
 * 1.0  		09-15-2020  			Nithin Malla (Deloitte)      			Initial Version
 * 2.0  		09-18-2020  			Nithin Malla (Deloitte)      			Updated code coverage
 * 3.0  		09-22-2020  			Nithin Malla (Deloitte)      			Updated code coverage
 * 4.0  		10-23-2020  			Nithin Malla (Deloitte)      			Removed Crypto blob conversion
 **/
@isTest public class UAC_backgoundCheckEmailServiceTest {

  static final String RELATION_TO_SPONSOR = 'Grandson';
  static final String STR_A_NUM_ADULT_CONTACT_1 = '1234561';
  static final String STR_A_NUM_ADULT_CONTACT_2 = '1234562';
  static final String STR_A_NUM_ADULT_CONTACT_SPONSOR = '123456';
  static final String STR_A_NUM_UAC = '1234';

  /**
   * @description Method to setup test data
   * @author Nithin Malla (Deloitte) | 9/15/2020
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

  /*
   * @description Method to test Back Ground Check Service Test with Error Code
   * @author Nithin Malla (Deloitte) | 09-15-2020
   * @return
   **/
  @isTest static void backGroundCheckEmailTest_Error() {
    UAC_associatedContact__c objAssociatedContact =
        getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    String firstName = objAssociatedContact.UAC_contact__r.FirstName;
    String lastName = objAssociatedContact.UAC_contact__r.LastName;
    Set<String> fieldsToQuery = new Set<String>{'Id'};

    Contact objSponsor =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR, fieldsToQuery);
    Case objSponsorApplicationCase =
        [Select id, UAC_sponsor__c, Contact.UAC_A__c from Case where UAC_sponsor__c
          =:objSponsor.Id Limit 1];

    Test.startTest();

    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder().buildAndSave(
        objSponsor, objSponsorApplicationCase, false);

    createEmailService('FW: ' + STR_A_NUM_UAC + '_' + lastName + '_' + firstName + '_ERROR'
        + '_20201209_20201210');

    objbackGroundChk1 = [Select Id,
      UAC_results__c,
      UAC_dateResultsReceived__c,
      UAC_dateRequested__c from UAC_backgroundCheck__c where Id =:objbackGroundChk1.ID];
    system.assertEquals('Unclassifiable 1st Attempt', objbackGroundChk1.UAC_results__c);
    system.assertEquals(system.today(), objbackGroundChk1.UAC_dateResultsReceived__c);

    Contact con = [Select Id, UAC_backgroundResultFlag__c from Contact where id =:objSponsor.Id];
    system.assert(con.UAC_backgroundResultFlag__c);

    Test.stopTest();
  }

  /*
   * @description Method to test Back Ground Check Service Test with Error Code
   * @author Nithin Malla (Deloitte) | 09-15-2020
   * @return
   **/
  @isTest static void backGroundCheckEmailTest_Error2() {
    UAC_associatedContact__c objAssociatedContact =
        getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    String firstName = objAssociatedContact.UAC_contact__r.FirstName;
    String lastName = objAssociatedContact.UAC_contact__r.LastName;
    Set<String> fieldsToQuery = new Set<String>{'Id'};

    Contact objSponsor =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR, fieldsToQuery);
    Case objSponsorApplicationCase =
        [Select id, UAC_sponsor__c, Contact.UAC_A__c from Case where UAC_sponsor__c
          =:objSponsor.Id Limit 1];

    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder().buildAndSave(
        objSponsor, objSponsorApplicationCase, false);

    createEmailService('FW: ' + STR_A_NUM_UAC + '_' + lastName + '_' + firstName + '_ERROR'
        + '_20201209_20201210');

    Test.startTest();

    UAC_backgroundCheck__c objbackGroundChk2 = new UAC_testBackGroundCheckBuilder().buildAndSave(
        objSponsor, objSponsorApplicationCase, false);

    createEmailService('FW: ' + STR_A_NUM_UAC + '_' + lastName + '_' + firstName + '_ERROR'
        + '_20201209_20201210');

    objbackGroundChk2 = [Select Id,
      UAC_results__c,
      UAC_dateResultsReceived__c,
      UAC_dateRequested__c from UAC_backgroundCheck__c where Id =:objbackGroundChk2.ID];
    system.assertEquals('Unclassifiable 2nd Attempt', objbackGroundChk2.UAC_results__c);
    system.assertEquals(system.today(), objbackGroundChk2.UAC_dateResultsReceived__c);

    Contact con = [Select Id, UAC_backgroundResultFlag__c from Contact where id =:objSponsor.Id];
    system.assert(!con.UAC_backgroundResultFlag__c);

    Test.stopTest();
  }

  /*
   * @description Method to test Back Ground Check Service Test with IDENT Code
   * @author Nithin Malla (Deloitte) | 09-15-2020
   * @return
   **/
  @isTest static void backGroundCheckEmailTest_IDENT() {
    UAC_associatedContact__c objAssociatedContact =
        getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    String firstName = objAssociatedContact.UAC_contact__r.FirstName;
    String lastName = objAssociatedContact.UAC_contact__r.LastName;
    Set<String> fieldsToQuery = new Set<String>{'Id'};

    Contact objSponsor =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR, fieldsToQuery);
    Case objSponsorApplicationCase =
        [Select id, UAC_sponsor__c, Contact.UAC_A__c from Case where UAC_sponsor__c
          =:objSponsor.Id Limit 1];

    Test.startTest();

    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder().buildAndSave(
        objSponsor, objSponsorApplicationCase, false);

    createEmailService('FW: ' + STR_A_NUM_UAC + '_' + lastName + '_' + firstName + '_IDENT'
        + '_20201209_20201210');

    objbackGroundChk1 = [Select Id,
      UAC_results__c,
      UAC_dateResultsReceived__c,
      UAC_dateRequested__c from UAC_backgroundCheck__c where Id =:objbackGroundChk1.ID];
    system.assertEquals('Refer to FFS', objbackGroundChk1.UAC_results__c);
    system.assertEquals(system.today(), objbackGroundChk1.UAC_dateResultsReceived__c);

    Test.stopTest();
  }
  /*
   * @description Method to test Back Ground Check Service Test with galton date population
   * @author Issam Awwad (Deloitte) | 01-12-2021
   * @return
   **/
  @isTest static void backGroundCheckEmailTest_GaltonDates() {
    UAC_associatedContact__c objAssociatedContact =
        getAssociatedContactByANumber(STR_A_NUM_ADULT_CONTACT_1);
    String firstName = objAssociatedContact.UAC_contact__r.FirstName;
    String lastName = objAssociatedContact.UAC_contact__r.LastName;
    Set<String> fieldsToQuery = new Set<String>{'Id'};

    Contact objSponsor =
        UAC_testContactBuilder.getContactByANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR, fieldsToQuery);
    Case objSponsorApplicationCase =
        [Select id, UAC_sponsor__c, Contact.UAC_A__c from Case where UAC_sponsor__c
          =:objSponsor.Id Limit 1];

    Test.startTest();

    UAC_backgroundCheck__c objbackGroundChk1 = new UAC_testBackGroundCheckBuilder().buildAndSave(
        objSponsor, objSponsorApplicationCase, false);

    createEmailService('FW: ' + STR_A_NUM_UAC + '_' + lastName + '_' + firstName + '_ERROR'
        + '_20201209_20201210');

    objbackGroundChk1 = [Select Id,
      UAC_results__c,
      UAC_dateResultsReceived__c,
      UAC_dateRequested__c,
      UAC_dateResultTransmittedToFBICJIS__c,
      UAC_dateResultReceivedFromFBICJIS__c from UAC_backgroundCheck__c where Id
      =:objbackGroundChk1.ID];
    Date dateResultTransmitted = date.newinstance(2020, 12, 9);
    Date dateResultReceived = date.newinstance(2020, 12, 10);

    system.assertEquals(
        dateResultTransmitted, objbackGroundChk1.UAC_dateResultTransmittedToFBICJIS__c);
    system.assertEquals(dateResultReceived, objbackGroundChk1.UAC_dateResultReceivedFromFBICJIS__c);

    Test.stopTest();
  }

  /*
   * @description Method to test Back Ground Check Service Test with No Records Found
   * @author Nithin Malla (Deloitte) | 09-15-2020
   * @return
   **/
  @isTest static void backGroundCheckEmailTest_NoRecordsFound() {
    Boolean boolSuccess = false;
    try {
      createEmailService(
        STR_A_NUM_ADULT_CONTACT_1 + '_lastName_firstName_IDENT' + '_20201209_20201210');
      boolSuccess = true;
    } catch (Exception e) {
      boolSuccess = false;
    }
    System.assert(boolSuccess);
  }

  /*
   * @description Method to test Back Ground Check Service Test with Exception
   * @author Nithin Malla (Deloitte) | 09-15-2020
   * @return
   **/
  @isTest static void backGroundCheckEmailTest_Exception() {
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

    email.subject = 'subject';
    Messaging.InboundEmail.BinaryAttachment[] binaryAttachments =
        new Messaging.InboundEmail.BinaryAttachment[1];
    Messaging.InboundEmail.BinaryAttachment binaryAttachment =
        new Messaging.InboundEmail.BinaryAttachment();
    binaryAttachment.Filename = 'test.txt';
    binaryAttachment.Body = Blob.valueOf('test');
    binaryAttachments[0] = binaryAttachment;
    email.binaryAttachments = binaryAttachments;
    envelope.fromAddress = 'user@acme.com';

    // setup controller object
    UAC_backgoundCheckEmailService catcher = new UAC_backgoundCheckEmailService();
    Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
    System.assertEquals(false, result.success);
  }

  /**
   * @description Method to Create Email Instance.
   * @author Nithin Malla (Deloitte) | 9/15/2020
   * @return void
   **/
  private
  static void createEmailService(String subject) {
    // Create a new email, envelope object and Attachment
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

    email.subject = subject;
    Messaging.InboundEmail.BinaryAttachment[] binaryAttachments =
        new Messaging.InboundEmail.BinaryAttachment[1];
    Messaging.InboundEmail.BinaryAttachment binaryAttachment =
        new Messaging.InboundEmail.BinaryAttachment();
    binaryAttachment.Filename = 'test.txt';
    binaryAttachment.Body = Blob.valueOf('test');
    binaryAttachments[0] = binaryAttachment;
    email.binaryAttachments = binaryAttachments;
    envelope.fromAddress = 'user@acme.com';

    // setup controller object
    UAC_backgoundCheckEmailService catcher = new UAC_backgoundCheckEmailService();
    Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
  }

  /**
   * @description Method to get associated contact record for test instance.
   * @author Nithin Malla (Deloitte) | 9/15/2020
   * @return UAC_associatedContact__c
   **/
  private
  static UAC_associatedContact__c getAssociatedContactByANumber(String strANumber) {
    // clang-format off
      return [
        SELECT
          Id, UAC_contact__c, UAC_case__c, UAC_alternateAdultCaregiver__c,
          UAC_relationshipToSponsor__c,UAC_contact__r.LastName,UAC_contact__r.FirstName
        FROM
          UAC_associatedContact__c
        WHERE
          UAC_contact__r.UAC_a__c =: strANumber
        LIMIT 1
      ];
    // clang-format on
  }
}