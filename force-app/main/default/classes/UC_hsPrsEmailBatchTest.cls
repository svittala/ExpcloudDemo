/**
* @File Name          : UC_hsPrsEmailBatchTest.cls
* @Description        : ORRUAC-4590 : Test class for Batch apex to send Email notif. to Entry Team members for HSPRS Referall Cases for UCs turning 18
* @Author             : Piyush(Deloitte)
* @Scheduler class    : UC_hsPrsEmailBatchScheduler.cls
* @Batch Class         : UC_hsPrsEmailBatch.cls
* @Modification Log   :
* Ver       Date            Author               Modification
* 1.0    8/30/2021     Piyush(Deloitte)     Initial Implementation.
**/
@isTest
public class UC_hsPrsEmailBatchTest {
    private static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    private static Account objProgram;
    private static Case objHsPrsReferralCase1; 
    private static Case objHsPrsReferralCase2;
    private static Case objHsPrsReferralCase3;
    static testmethod void testhsPrsEmailBatch(){
        Map<String,Schema.RecordTypeInfo> mapRecordTypesByDeveloperName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Id idDNFRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeHSPRSReferral).getRecordTypeId();
        Set<String> setFieldsToQuery = new Set<String>{'Id'};
        objProgram = new UAC_testAccountBuilder().setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram).setType(STR_PROGRAM_TYPE).build();
        objProgram.UAC_bedCountAvailableMale__c = 5;
        objProgram.UAC_bedCountAvailableFemale__c = 6;
        objProgram.UAC_withinORRNetwork__c = 'Yes';
        insert objProgram;
        List<Account> prgid = [Select Id from Account where id =:objProgram.Id];
        String strNewANumber1 = '999999999';
        String strNewANumber2 = '999999998';
        String strNewANumber3 = '999999997';
        Contact UAC1 = new UAC_testContactBuilder().setANumber(strNewANumber1).setLastName(strNewANumber1).setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC).buildAndSave();
        Contact UAC2 = new UAC_testContactBuilder().setANumber(strNewANumber2).setLastName(strNewANumber2).setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC).buildAndSave();
        Contact UAC3 = new UAC_testContactBuilder().setANumber(strNewANumber3).setLastName(strNewANumber3).setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC).buildAndSave();
        UAC1.Birthdate = System.today().addYears(-18);  // test data for AC2
        update UAC1;
        UAC2.Birthdate = System.today().addYears(-18).addMonths(-1).addDays(1);  // test data for AC3
        update UAC2;
        UAC3.Birthdate = System.today().addYears(-18);   // test data for AC4
        update UAC3;
        objHsPrsReferralCase1 = new UAC_testCaseBuilder().setStatus('HS/PRS Referral Initiation').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral).setUAC(UAC1.id).build();
        objHsPrsReferralCase1.UAC_caseManager__c = userinfo.getuserid();
        objHsPrsReferralCase1.UAC_leadCaseManager__c = userinfo.getuserid();
        objHsPrsReferralCase1.UAC_hsPrsQueue__c = 'PRS';
        objHsPrsReferralCase1.Type = 'PRS -Only';
        objHsPrsReferralCase1.Status = 'Active';
        objHsPrsReferralCase1.UAC_hSPRSPrimaryProviderName__c = userinfo.getuserid();
        insert objHsPrsReferralCase1;
        objHsPrsReferralCase2 = new UAC_testCaseBuilder().setStatus('HS/PRS Referral Initiation').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral).setUAC(UAC2.id).build();
        objHsPrsReferralCase2.UAC_caseManager__c = userinfo.getuserid();
        objHsPrsReferralCase2.UAC_leadCaseManager__c = userinfo.getuserid();
        objHsPrsReferralCase2.UAC_hsPrsQueue__c = 'PRS';
        objHsPrsReferralCase2.Type = 'PRS -Only';
        objHsPrsReferralCase2.Status = 'Active';
        objHsPrsReferralCase2.UAC_hSPRSPrimaryProviderName__c = userinfo.getuserid();
        insert objHsPrsReferralCase2;        
        objHsPrsReferralCase3 = new UAC_testCaseBuilder().setStatus('HS/PRS Referral Initiation').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeHSPRSReferral).setUAC(UAC3.id).build();
        objHsPrsReferralCase3.UAC_caseManager__c = userinfo.getuserid();
        objHsPrsReferralCase3.UAC_leadCaseManager__c = userinfo.getuserid();
        objHsPrsReferralCase3.UAC_hsPrsQueue__c = 'PRS';
        objHsPrsReferralCase3.Type = 'PRS -Only';
        objHsPrsReferralCase3.Status = 'Pending';
        objHsPrsReferralCase3.UAC_hSPRSPrimaryProviderName__c = userinfo.getuserid();
        insert objHsPrsReferralCase3;

        String CRON_EXP = '0 0 23 * * ?';   
        Test.startTest();     
        UC_hsPrsEmailBatchScheduler hsEB = new UC_hsPrsEmailBatchScheduler();
        System.schedule('UC_hsPrsEmailBatchTest', CRON_EXP, hsEB);
        Database.executeBatch(new UC_hsPrsEmailBatch(), 3);       
        Test.stopTest();

        List<Case> updtCse = [Select Id,Status from case where id =:objHsPrsReferralCase3.Id];
        System.assertEquals('Cancelled',updtCse[0].Status);
    }
}