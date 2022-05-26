/**
 * @File Name          : UC_exclusionLogicTest.cls
 * @Description        : Test class for UC_exclusionLogicService
 * @Author             : James Qian (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		           Modification
 * 1.0       6/30/2021       James Qian (Deloitte)     Initial Version
 **/
@isTest public class UC_exclusionLogicTest {
  private
  static final String STRING_PROGRAM_RECORD_NAME = 'UAC_program';
  private
  static final String STRING_FIELD_TYPE = 'Secure';
  private
  static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;
  private
  static final String STRING_A_NUMBER_PRIMARY = '111111111';
  private
  static final String STR_A_NUM_UAC = '123456';
  private
  static final String STR_ACCNT_STATUS = 'Draft';
  private
  static final String STR_PAIN_LOC = 'Neck';
    
  /*
   * @description Positive test scenario for program exclusion logic
   * @return void
   **/
  @isTest static void accountProgramExclusionShouldBeSuccessful() {
    System.runAs(createUserAndSetBypass()) {
      setBypass(false);
      Test.startTest();
      Boolean boolSuccess = false;
      try {
        Account programToInsert = new UAC_testAccountBuilder()
                                      .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                      .setType(STRING_FIELD_TYPE)
                                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                      .build();
        programToInsert.UC_activeInPath__c = false;
        insert programToInsert;
      } catch (Exception e) {
        boolSuccess = true;
      }
      Test.stopTest();
      System.assert(boolSuccess);
    }
  }

  /*
   * @description Positive test scenario for organization exclusion logic
   * @return void
   **/
  @isTest static void accountOrgExclusionShouldBeSuccessfulOnUpdate() {
    System.runAs(createUserAndSetBypass()) {
      Account accountOrg = new UAC_testAccountBuilder()
                               .setRecordTypeDeveloperName(Label.UAC_organizationRecordTypeDevName)
                               .setType(STRING_FIELD_TYPE)
                               .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                               .build();
      accountOrg.UAC_organizationContact1__c = UserInfo.getUserId();
      insert accountOrg;
      Account programToInsert = new UAC_testAccountBuilder()
                                    .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                                    .setType(STRING_FIELD_TYPE)
                                    .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                                    .build();
      programToInsert.UC_activeInPath__c = false;
      programToInsert.ParentId = accountOrg.Id;
      insert programToInsert;
      Test.startTest();
      setBypass(false);
      Boolean boolSuccess = false;
      try {
        update accountOrg;
      } catch (Exception e) {
        boolSuccess = true;
      }
      Test.stopTest();
      System.assert(boolSuccess);
    }
  }

  /*
   * @description Positive test scenario for Signs and Symptoms exclusion logic on create
   * @return void
   **/
  @isTest static void signsAndSymptomsExclusionShouldBeSuccessfulOnCreate() {
    System.runAs(createUserAndSetBypass()) {
      // Instantiate related UC profile
      Contact objUCContact =
      new UAC_TestContactBuilder()
          // Set record type to UAC
          .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
          // Set required fields
          .setANumber(STR_A_NUM_UAC)
          // Build object, but don't insert
          .build();

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
      objProgram.UC_activeInPath__c = false;
      insert objProgram;

      // Set UC contact's related program to the instantiated objProgram id
      // Important because this trigger tests if the related program is inactive in path.
      objUCContact.UAC_program__c = objProgram.Id;
      // Insert UC contact now that attributes have been finalized.
      insert objUCContact;
        
      // Instantiate related health evaluation
      UAC_HealthEvaluation__c objHealthEval =
          new UAC_testHealthEvaluationBuilder()
          // Set record type to Inital Medical Exam
          .setRecordTypeDeveloperName(System.Label.UAC_healthEvaluationRecordTypeApiNameIME)
          // Set required fields
          .setUAC(objUCContact.Id)
          // Build object, then insert
          .buildAndSave();

      // Disable bypass now that setup objects have been created.
      setBypass(false);
        
      Test.startTest();
      Boolean boolSuccess = false;
      try {
        UAC_signsAndSymptoms__c signsAndSymptomsToCreate =
            new UAC_testSignAndSymptomsBuilder()
                // Set required fields
                .setUAC(objUCContact.id)
                .setHealthEvaluation(objHealthEval.id)
                // Build object
                .buildAndSave();
      } catch (Exception e) {
        boolSuccess = true;
      }
      Test.stopTest();
      System.assert(boolSuccess);
    }
  }
    
  /*
   * @description Positive test scenario for Signs and Symptoms exclusion logic on Update
   * @return void
   **/
  @isTest static void signsAndSymptomsExclusionShouldBeSuccessfulOnUpdate() {
    System.runAs(createUserAndSetBypass()) {
      // Instantiate related UC profile
      Contact objUCContact =
      new UAC_TestContactBuilder()
          // Set record type to UAC
          .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
          // Set required fields
          .setANumber(STR_A_NUM_UAC)
          // Build object, but don't insert
          .build();

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
      objProgram.UC_activeInPath__c = false;
      insert objProgram;

      // Set UC contact's related program to the instantiated objProgram id
      // Important because this trigger tests if the related program is inactive in path.
      objUCContact.UAC_program__c = objProgram.Id;
      // Insert UC contact now that attributes have been finalized.
      insert objUCContact;
        
      // Instantiate related health evaluation
      UAC_HealthEvaluation__c objHealthEval =
          new UAC_testHealthEvaluationBuilder()
          // Set record type to Inital Medical Exam
          .setRecordTypeDeveloperName(System.Label.UAC_healthEvaluationRecordTypeApiNameIME)
          // Set required fields
          .setUAC(objUCContact.Id)
          // Build object, then insert
          .buildAndSave();

      UAC_signsAndSymptoms__c signsAndSymptomsToUpdate =
          new UAC_testSignAndSymptomsBuilder()
              // Set required fields
              .setUAC(objUCContact.id)
              .setHealthEvaluation(objHealthEval.id)
              // Build object
              .buildAndSave();

      // Disable bypass now that setup objects have been created.
      setBypass(false);
        
      Test.startTest();
      Boolean boolSuccess = false;
      try {
        signsAndSymptomsToUpdate.UAC_locationofPain__c = STR_PAIN_LOC;
        insert signsAndSymptomsToUpdate;
      } catch (Exception e) {
        boolSuccess = true;
      }
      Test.stopTest();
      System.assert(boolSuccess);
    }
  }
    
  /*
   * @description Positive test scenario for Signs and Symptoms exclusion logic on delete
   * @return void
   **/
  @isTest static void signsAndSymptomsExclusionShouldBeSuccessfulOnDelete() {
    System.runAs(createUserAndSetBypass()) {
      // Instantiate related UC profile
      Contact objUCContact =
      new UAC_TestContactBuilder()
          // Set record type to UAC
          .setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC)
          // Set required fields
          .setANumber(STR_A_NUM_UAC)
          // Build object, but don't insert
          .build();

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
      objProgram.UC_activeInPath__c = false;
      insert objProgram;

      // Set UC contact's related program to the instantiated objProgram id
      // Important because this trigger tests if the related program is inactive in path.
      objUCContact.UAC_program__c = objProgram.Id;
      // Insert UC contact now that attributes have been finalized.
      insert objUCContact;
        
      // Instantiate related health evaluation
      UAC_HealthEvaluation__c objHealthEval =
          new UAC_testHealthEvaluationBuilder()
          // Set record type to Inital Medical Exam
          .setRecordTypeDeveloperName(System.Label.UAC_healthEvaluationRecordTypeApiNameIME)
          // Set required fields
          .setUAC(objUCContact.Id)
          // Build object, then insert
          .buildAndSave();

      UAC_signsAndSymptoms__c signsAndSymptomsToDelete =
          new UAC_testSignAndSymptomsBuilder()
              // Set required fields
              .setUAC(objUCContact.id)
              .setHealthEvaluation(objHealthEval.id)
              // Build object
              .buildAndSave();

      // Disable bypass now that setup objects have been created.
      setBypass(false);
        
      Test.startTest();
      Boolean boolSuccess = false;
      try {
        delete signsAndSymptomsToDelete;
      } catch (Exception e) {
        boolSuccess = true;
      }
      Test.stopTest();
      System.assert(boolSuccess);
    }
  }
    
  /*
   * @description Sets bypass for exclusion logic
   * @param Boolean bypass
   * @return void
   **/
  private
  static void setBypass(Boolean bypass) {
    UC_exclusionLogicService.getInstance().bypassExclusions(bypass);
  }

  /*
   * @description Creates HQ user for testing
   * @return User
   **/
  private
  static User createUserAndSetBypass() {
    User newUser = UAC_TestUtility.createUser('FFS', Label.UAC_userRoleFFS);
    System.runAs(newUser) {
      UAC_bypassSettings__c newSetting = new UAC_bypassSettings__c();
      newSetting.UC_bypassExclusionLogic__c = true;
      newSetting.SetupOwnerId = newUser.Id;
      insert newSetting;
    }
    return newUser;
  }
}