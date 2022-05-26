/**
 * @File Name          : UAC_EmailFieldUtilTest.cls
 * @Description        : Test method for UAC_EmailFieldUtil.cls
 * @Author             : Ram Josyer (Creative Sys)
 * @Group              : 
 * @Last Modified By   :
 * @Last Modified On   : 12/30/2020
 * @Modification Log   :
 *
 * Ver       Date            Author                   Modification
 * 1.0  12-30-2020  Ram Josyer Initial Implementation.
  **/

@isTest(seeAllData = false) public class UAC_EmailFieldUtilTest {

    private
    static final String STR_A_NUM_UAC = '123456';
    private
    static final String strYes = Label.UAC_Yes;
    private
    static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;
    private
    static final Integer INTEGER_FIELD_MALE_BEDS = 1;
    private
    static final String STRING_FIELD_TYPE = 'Secure';
    private
    static final String STRING_PROGRAM_RECORD_NAME = 'UAC_program';    
    private
    static Contact objUACContact;
    private
    static Account program;    
    private
    static UAC_HealthEvaluation__c objHealthEval;
    private
    static UAC_HealthEvaluation__c objHealthEvalNonTB;
    private
    static UAC_HealthEvaluation__c objHealthEvalHA;
    public
    static final String strIMERecordType = System.label.UAC_IMERectype;
  
    /**
   * @description Method to create test data
   * @author Ram Josyer | 12-30-2020
   **/
    @TestSetup static void setupData() {
 
        User caseManagerUser = generateUser('Standard User', 'CaseManager@orr.gov', 'CaseManager', 'ORR');
        User clinicianUser = generateUser('Standard User', 'Clinician@orr.gov', 'Clinician', 'ORR');

  
    }
    /**
   * @description Method to create test data
   * @author Ram Josyer | 12-30-2020
   **/
  static void setupData2() {
 
    User caseManagerUser = [select id from User where email = 'caseManager@orr.gov'];
    User clinicianUser = [select id from User where email = 'Clinician@orr.gov'];

    program = new UAC_testAccountBuilder()
    .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
    .setType(STRING_FIELD_TYPE)
    .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
    .build();
    program.UAC_programMedicalTeamEmail__c = 'pmt@orrinvalid.gov';
    program.UAC_FFSEmail__c = 'ffs@orrinvalid.gov';

    insert program;
        
    objUACContact =
    new UAC_testContactBuilder()
    .setANumber(STR_A_NUM_UAC)
    .setEmail(STR_A_NUM_UAC + '@example.invalid')
    .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
    .build();
    objUACContact.UAC_program__c = program.Id;     
    insert objUACContact;

    Contact UAC = [select id, AccountId from Contact where id = :objUACContact.id];
    createTeamMember(UAC.AccountId, caseManagerUser.Id, 'Case Manager');
    createTeamMember(UAC.AccountId, clinicianUser.Id, 'Clinician');    

    objHealthEval = new UAC_testHealthEvaluationBuilder()
    .setUAC(objUACContact.Id)
    .setRecordTypeDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameTBPHI)
    .build();
    objHealthEval.UAC_lookupAssociatedProgram__c = program.Id;

    objHealthEvalNonTB = new UAC_testHealthEvaluationBuilder()
    .setUAC(objUACContact.Id)
    .setRecordTypeDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameNonTBPHI)
    .build();
    objHealthEvalNonTB.UAC_lookupAssociatedProgram__c = program.Id;    
 
    objHealthEvalHA = new UAC_testHealthEvaluationBuilder()
    .setUAC(objUACContact.Id)
    .setRecordTypeDeveloperName(System.label.UAC_healthEvaluationRecordTypeApiNameHA)
    .build();
    objHealthEvalHA.UAC_lookupAssociatedProgram__c = program.Id;      
    insert objHealthEval;
    insert objHealthEvalNonTB;
    insert objHealthEvalHA;


}

    public static AccountTeamMember createTeamMember(String accountId, String userId, String role) {
        Account acct=[SELECT Id, OwnerId FROM Account WHERE Id= :accountId];

        AccountTeamMember teamMember = new AccountTeamMember();
        teamMember.AccountId = acct.Id;
        System.debug(acct.Id + 'id');

        teamMember.UserId = userId;
        teamMember.TeamMemberRole = role;
        insert teamMember;        
        return teamMember;
    }


     public static User generateUser(String profileName, String email, String title, String company){
        UserRole userRole = new UserRole(DeveloperName = title, Name = title);
        insert userRole;
        User u = new User(
          ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
          LastName = 'last',
          Email = email,
          Username = email,
          CompanyName = company,
          Title = title,
          Alias = 'alias',
          TimeZoneSidKey = 'America/Los_Angeles',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          UserRoleId = userRole.Id
        );
        insert u;
        return u;
      }
    
    /**
     * @description ORRUAC-949: Method to test email fields for medical teams Health Evaluation(IME) 
     * record
     * @author Ram Josyer | 12/30/2020
     * @return void
     **/
    @isTest static void populateHealthEvalEmailFieldstest() {
      
        setupData2();
        Test.startTest();

        UAC_HealthEvaluation__c objHealthEvalAfterInsert =
            [select id, UAC_programMedicalTeamEmail__c, UAC_FFSEMail__c, UAC_CaseManagerEmail__c, UAC_ClinicianEmail__c from UAC_HealthEvaluation__c where Id
              =:objHealthEval.id LIMIT 1];
     
        System.assertEquals(objHealthEvalAfterInsert.UAC_programMedicalTeamEmail__c, program.UAC_programMedicalTeamEmail__c);
        System.assertEquals(objHealthEvalAfterInsert.UAC_FFSEmail__c, program.UAC_FFSEmail__c);
        System.assertEquals(objHealthEvalAfterInsert.UAC_CaseManagerEmail__c, 'casemanager@orr.gov');
        System.assertEquals(objHealthEvalAfterInsert.UAC_ClinicianEmail__c, 'clinician@orr.gov');

        objHealthEvalAfterInsert =
            [select id, UAC_programMedicalTeamEmail__c, UAC_FFSEMail__c, UAC_CaseManagerEmail__c, UAC_ClinicianEmail__c from UAC_HealthEvaluation__c where Id
              =:objHealthEvalNonTB.id LIMIT 1];
     
        System.assertEquals(objHealthEvalAfterInsert.UAC_programMedicalTeamEmail__c, program.UAC_programMedicalTeamEmail__c);
        System.assertEquals(objHealthEvalAfterInsert.UAC_FFSEmail__c, program.UAC_FFSEmail__c);
        System.assertEquals(objHealthEvalAfterInsert.UAC_CaseManagerEmail__c, 'casemanager@orr.gov');
        System.assertEquals(objHealthEvalAfterInsert.UAC_ClinicianEmail__c, 'clinician@orr.gov');

        objHealthEvalAfterInsert =
            [select id, UAC_programMedicalTeamEmail__c, UAC_FFSEMail__c, UAC_CaseManagerEmail__c, UAC_ClinicianEmail__c from UAC_HealthEvaluation__c where Id
              =:objHealthEvalHA.id LIMIT 1];
     
        System.assertEquals(objHealthEvalAfterInsert.UAC_programMedicalTeamEmail__c, program.UAC_programMedicalTeamEmail__c);
        System.assertEquals(objHealthEvalAfterInsert.UAC_FFSEmail__c, program.UAC_FFSEmail__c);
        System.assertEquals(objHealthEvalAfterInsert.UAC_CaseManagerEmail__c, 'casemanager@orr.gov');
        System.assertEquals(objHealthEvalAfterInsert.UAC_ClinicianEmail__c, 'clinician@orr.gov');
        
        Test.stopTest();
    }
    
  
  /**
  * @description ORRUAC-: Create PMT and FFS emails on diagnosis object
  * @author Ram Josyer (Creative Sys) | 12/30/2020
  * @return void
  **/
  @isTest static void populateMedicalTeamEmailOnDiagTest() {
        setupData2();
        Test.startTest();
        UAC_Diagnosis__c diagnosis = new UAC_testDiagnosisBuilder()
                                        .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                        .setAssociatedHealthEval(objHealthEval.Id)
                                        .build();

        insert diagnosis;

        UAC_Diagnosis__c diagnosis1 =
            [SELECT id, UAC_programMedicalTeamEmail__c, UAC_FFSEMail__c, UAC_CaseManagerEmail__c, UAC_ClinicianEmail__c FROM UAC_Diagnosis__c
                where id = :diagnosis.id];

        System.assertEquals(diagnosis1.UAC_programMedicalTeamEmail__c, program.UAC_programMedicalTeamEmail__c);
        System.assertEquals(diagnosis1.UAC_FFSEmail__c, program.UAC_FFSEmail__c);
        System.assertEquals(diagnosis1.UAC_CaseManagerEmail__c, 'casemanager@orr.gov');
        System.assertEquals(diagnosis1.UAC_ClinicianEmail__c, 'clinician@orr.gov');
 
        Test.stopTest();
    }    
   /**
  * @description ORRUAC-: Create PMT and FFS emails on UAC_Test__c object
  * @author Ram Josyer (Creative Sys) | 12/30/2020
  * @return void
  **/
  @isTest static void populateMedicalTeamEmailOnTestObjTest() {
      
        setupData2();   
        Test.startTest();
        UAC_Test__c medicalTest = UAC_testTBTestBuilder.uacTbbbTestRecord('UAC_imagingStudy',
                                        'Abnormal',
                                        objHealthEval.id,
                                        objUACContact.id
                                        );
                                        /*
                                        .setAssociatedUAC(objHealthEval.UAC_associatedUAC__c)
                                        .setAssociatedHealthEval(objHealthEval.Id)
                                        .build();
                                        */

        medicalTest.UAC_datePerformed__c = Date.today();
        medicalTest.RecordTypeId = UAC_TestObjectUtil.getRecordTypeIdByDeveloperName(System.label.UAC_testRecTypeImagingStudy);
        insert medicalTest;

        UAC_Test__c medicalTest1 =
            [SELECT id, UAC_programMedicalTeamEmail__c, UAC_FFSEMail__c FROM UAC_Test__c where id = :medicalTest.id];

        System.assertEquals(medicalTest1.UAC_programMedicalTeamEmail__c, program.UAC_programMedicalTeamEmail__c);
        System.assertEquals(medicalTest1.UAC_FFSEmail__c, program.UAC_FFSEmail__c);
        Test.stopTest();
    
    }     
  }