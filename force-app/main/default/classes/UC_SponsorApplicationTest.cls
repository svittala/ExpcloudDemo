/**
 * @File Name          : UC_SponsorApplicationTest.cls
 * @Description        : Test class for trigger helper and handler for UC_SponsorApplication.cls
 *object.
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_test
 * @Last Modified By   : Nithin Malla (Deloitte)
 * @Last Modified On   : 9/20/2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/20/2021   Nithin Malla (Deloitte)     Initial Version
 **/
@isTest public class UC_SponsorApplicationTest {

  static final String RELATION_TO_SPONSOR = 'Grandson';
  static final String RELATION_TO_SPONSOR1 = 'GrandFather';
  static final String STR_A_NUM_ADULT_CONTACT_1 = '1234561';
  static final String STR_A_NUM_ADULT_CONTACT_1_1 = '5678901';
  static final String STR_A_NUM_ADULT_CONTACT_2 = '1234562';
  static final String STR_A_NUM_ADULT_CONTACT_SPONSOR = '123456';
  static final String STR_A_NUM_ADULT_CONTACT_SPONSOR1 = '567890';
  static final String STR_A_NUM_UAC = '1234';
  static final String STR_A_NUM_UAC1 = '5678';
    
    /**
   * @description Method to setup test data
   * @author Nithin Malla (Deloitte) | 9/20/2021
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
   * @description Get Related Sponsor Application Records
   * @author Nithin Malla (Deloitte) | 9/20/2021
   * @return void
   **/
  @isTest static void getRelatedSponsorApplications() {
      Contact sponRec = [Select id from Contact where UAC_A__c=:STR_A_NUM_ADULT_CONTACT_SPONSOR limit 1];
      Contact objSponsor =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT_SPONSOR1)
            .build();
      
      Contact objAdultContact1 =
        new UAC_testContactBuilder()
            .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameAdultContact)
            .setANumber(STR_A_NUM_ADULT_CONTACT_1_1)
            .build();
      
      Contact objUAC = new UAC_testContactBuilder()
                         .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                         .setANumber(STR_A_NUM_UAC1)
                         .build();
      
      insert new List<Contact>{objSponsor, objAdultContact1, objUAC};
          
      UAC_adultContactRelationship__c objAdultContactRelationship =
        new UAC_adultContactRelationship__c();
    objAdultContactRelationship.UAC_adultContact__c = objSponsor.id;
    objAdultContactRelationship.UAC_relationshipType__c = 'Primary Sponsor';
    objAdultContactRelationship.UAC_relationshipToUAC__c = 'Father';
    objAdultContactRelationship.UAC_uacLookup__c = objUAC.id;
    insert objAdultContactRelationship;
      
      Case objSponsorApplicationCase =
        new UAC_testCaseBuilder()
            .setSponsor(sponRec.Id)
            .setUAC(objUAC.Id)
            .setRelationshipToUAC(objAdultContactRelationship.Id)
            .setRecordTypeDeveloperName(Label.UAC_caseRecordTypeApiNameSponsorApplication)
            .buildAndSave();
      // Insert Associated Contact for one of the Adult Contact
      UAC_associatedContact__c objAssociatedContact = new UAC_associatedContact__c();
      objAssociatedContact.UAC_contact__c = sponRec.Id;
      objAssociatedContact.UAC_case__c = objSponsorApplicationCase.Id;
      objAssociatedContact.UAC_alternateAdultCaregiver__c = true;
      objAssociatedContact.UAC_relationshipToSponsor__c = RELATION_TO_SPONSOR1;
      insert objAssociatedContact;
      
      Case objReleaseRequestCase = new UAC_testCaseBuilder().setUAC(objUAC.Id).build();
      objReleaseRequestCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.UAC_caseRecordTypeReleaseRequest).getRecordTypeId();
      objReleaseRequestCase.status = 'Completed';
      objReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
      objReleaseRequestCase.UAC_cfsName__c  = userinfo.getuserid();
      objReleaseRequestCase.UAC_ffsName__c  = userinfo.getuserid();
      objReleaseRequestCase.UAC_leadCaseManager__c  = userinfo.getuserid();
      objReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
      objReleaseRequestCase.UAC_remandForFurtherInformation__c = 'Yes';
      objReleaseRequestCase.UAC_orrComment__c = 'Test1';     
      objReleaseRequestCase.parentID = objSponsorApplicationCase.Id;
      insert objReleaseRequestCase;
      
      Test.startTest();
      objReleaseRequestCase.status = 'Completed';
      update objReleaseRequestCase;
      UC_SponsorApplication.SponsorApplication wrapperRecords = UC_SponsorApplication.getRelatedSponsorApps(objSponsorApplicationCase.Id);
      system.assert(wrapperRecords.lstSponAppRecords.size()>0);
      Test.stopTest();
  }

}