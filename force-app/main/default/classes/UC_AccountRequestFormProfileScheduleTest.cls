/**
 * @File Name          : UC_AccountRequestFormProfileSchedule.cls
 * @Description        : Change Profile and Role for the Account Request User when training is completed
 * @Author             : Ankur Aggarwal (Deloitte)
 * @Group              : UC_AccountRequestFormProfileSchedule
 */
@isTest
public class UC_AccountRequestFormProfileScheduleTest {
  private
    static final Integer INTEGER_FIELD_FEMALE_BEDS = 1;
  private
    static final String STRING_FIELD_TYPE = 'Secure';
  private
    static final String STRING_PROGRAM_RECORD_NAME = 'UAC_program';    
  @isTest static void executeTest(){
    Profile p  = [select id from profile where name = 'MyTrailhead'];
    User u = new user();
    u.LastName = 'Test Code';
    u.Email = 'test@test.com';
    u.Alias = 'Tcode';
    u.Username = 'test1234444@test.com.test.test';
    u.CommunityNickname = 'test12';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'GMT';
    u.ProfileID = p.id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    u.isactive = true;
    insert u;
    Recordtype ProgramRecordtype = [select id from Recordtype where developername ='UAC_program' and sobjecttype = 'Account'];      Test.startTest();
    Account programToInsert = new UAC_testAccountBuilder()
                      .setRecordTypeDeveloperName(STRING_PROGRAM_RECORD_NAME)
                      .setType(STRING_FIELD_TYPE)
                      .setFemaleBeds(INTEGER_FIELD_FEMALE_BEDS)
                      .buildAndSave();
    programtoinsert.UC_activeInPath__c = true;
    update programtoinsert; 
    AccountTeamMember acctmem = new AccountTeamMember();
    acctmem.AccountId = programToInsert.Id;


    acctmem.UserId = u.id;
    acctmem.TeamMemberRole = 'Account Manager';

    insert acctmem;
    UAC_AccountRequestForm__c arfrec = new UAC_AccountRequestForm__c();
    arfrec.UC_existingUser__c = true;
    arfrec.UAC_UACPath_training_Completed__c = true;
    arfrec.UAC_Status__c = 'Ready for Profile Update';
    arfrec.User_Email__c = 'test@test.com';
    arfrec.User_map__c = u.id;
    arfrec.UC_role__c = 'Case Coordinator';
    arfrec.User_Profile__c = 'Case Coordinator';
    insert arfrec;

    //SELECT Id,UAC_Status__c,UC_existingUser__c,User_map__r.Profile.Name,User_map__r.Name,UAC_UACPath_training_Completed__c, User_Profile__c, UC_role__c, User_map__c FROM  WHERE =\'Ready for Profile Update\' AND  = true AND  = true
    SchedulableContext sc = null;
    UC_AccountRequestFormProfileSchedule tsc = new UC_AccountRequestFormProfileSchedule();
    tsc.execute(sc);
    Test.stopTest();

  }   
}