/**
 * @File Name          : UAC_legalTriggerHelperTest.cls
 * @Description        : Test class for UAC_legalTriggerHelper,UAC_legalTriggerHandler
 * @Author             : Manoj Sharma (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Last Modified By   : Manoj Sharma (Deloitte)
 * @Last Modified On   : 8/24/2020
 * @Modification Log   :
 * Ver       Date            Author      		       Modification
 * 1.0    08/24/2020   Manoj Sharma (Deloitte)          Initial Version
 **/
@isTest(seeAllData = false) public class UAC_legalTriggerHelperTest {

  private
  static final String STR_UAC_CONTACT_A_NUMBER = '98761251';
  private
  static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
  
  /**
   * @description Sets up generic test data
   * @author Manoj Sharma (Deloitte) | 8/24/2020
   * @return void
   **/
 

    @TestSetup static void setupData() {
		//Create Prgram Account 
		 Account objProgram = new UAC_testAccountBuilder()
								 .setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram)
								 .setType(STR_PROGRAM_TYPE)
								 .build();
		objProgram.UAC_withinORRNetwork__c = 'Yes';
		insert objProgram; 
		// Create Law Frim 
		 Account objLAWFrim = new UAC_testAccountBuilder()
								 .setRecordTypeDeveloperName('UAC_lawFirms')
								 .setType(STR_PROGRAM_TYPE)
								 .build();
	
		insert objLAWFrim; 
		// Create UAC Contact
		 Contact objUACContact = new UAC_testContactBuilder()
									.setANumber(STR_UAC_CONTACT_A_NUMBER)
                                .setEmail(STR_UAC_CONTACT_A_NUMBER + '@example.invalid')
                                .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
                                .build();
		objUACContact.UAC_program__c =	objProgram.Id;
		insert objUACContact; 		
		//Create User as Profile as LSP
		 User LSPUser = UAC_TestUtility.CreateUser('Legal Service Provider');
		// Add user to LAW Frim Account as Account Team
		AccountTeamMember objAccountTeamMember= New AccountTeamMember(AccountId=objLAWFrim.Id,UserId=LSPUser.Id,CaseAccessLevel='Read',AccountAccessLevel='Read',
																		  ContactAccessLevel='None',OpportunityAccessLevel='None',TeamMemberRole='Attorney');
				
		insert objAccountTeamMember; 		
		
 
  	} 
    /*
   * @description test Method to Insert legal Program
   * on ORR Decision
   * @author Manoj Sharma (Deloitte) | 08/20/2020
   * @return void
   **/
	@isTest static void testInsertLegal() {
		
		List<User> LSPUser =[Select Id,Name from user where Profile.Name='Legal Service Provider' and LastName='Test Code'];
		system.debug('LSPUser:'+LSPUser);
		Contact objUACContact = [Select ID,UAC_program__c from Contact where RecordType.DeveloperName=:Label.UAC_contactRecordTypeApiNameUAC and UAC_A__c ='98761251'];
		Account objProgram = [Select ID from Account where RecordType.DeveloperName=:Label.UAC_accountRecordTypeAPINameProgram and Id = :objUACContact.UAC_program__c];
		Id idLegalMeetingsRecordTypee = Schema.SObjectType.UAC_legal__c.getRecordTypeInfosByDeveloperName()
		.get(label.UAC_legalLegalMeetingsRecordType)
		.getRecordTypeId();    
		
		Test.startTest();
		// Create Legal Meeting
		UAC_legal__c objLegal= New UAC_legal__c (UAC_attorney__c=LSPUser[0].Id,UAC_programFacility__c=objProgram.id,UAC_uacProfile__c = objUACContact.Id);
		objLegal.RecordTypeId =idLegalMeetingsRecordTypee;
		insert objLegal; 
        List<UAC_legal__c> lstLegal=[Select UAC_lawFirm__c from UAC_legal__c where Id=: objLegal.Id ];
		system.assertNotEquals(lstLegal[0].UAC_lawFirm__c, Null);
		Test.stopTest();
		
	}
    /*
   * @description test Method to update Update Legal
   * on ORR Decision
   * @author Manoj Sharma (Deloitte) | 08/20/2020
   * @return void
   **/
	@isTest static void testUpdateLegal() {
		
		List<User> LSPUser =[Select Id,Name from user where Profile.Name='Legal Service Provider' and LastName='Test Code'];
	    Contact objUACContact = [Select ID,UAC_program__c from Contact where RecordType.DeveloperName=:Label.UAC_contactRecordTypeApiNameUAC and UAC_A__c ='98761251'];
		Account objProgram = [Select ID from Account where RecordType.DeveloperName=:Label.UAC_accountRecordTypeAPINameProgram and Id = :objUACContact.UAC_program__c];
		Id idAttorneyOfRecordRecType = Schema.SObjectType.UAC_legal__c.getRecordTypeInfosByDeveloperName()
	   .get(label.UAC_legalAttorneyOfRecord)
	   .getRecordTypeId();
		// Update Legal Meeting 
		Test.startTest();
	    UAC_legal__c objLegal1= New UAC_legal__c (UAC_programFacility__c=objProgram.id,UAC_uacProfile__c = objUACContact.Id);
		objLegal1.RecordTypeId =idAttorneyOfRecordRecType;
		insert objLegal1; 
		
		objLegal1.UAC_attorney__c=LSPUser[0].Id;
		update objLegal1;
	    List<UAC_legal__c> lstLegal=[Select UAC_lawFirm__c from UAC_legal__c where Id=: objLegal1.Id ];
		system.assertNotEquals(lstLegal[0].UAC_lawFirm__c, Null);
		Test.stopTest();
	}
}