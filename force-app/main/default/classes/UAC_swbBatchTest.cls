@isTest
public class UAC_swbBatchTest {
    private static final String STR_PROGRAM_TYPE = 'Therapeutic Staff Secure';
    private static Account objProgram;
    private static Case objUACDNFCase; 
    private static Case objUACReleaseRequestCase;      
    static testmethod void testswbBatch(){
        Map<String,Schema.RecordTypeInfo> mapRecordTypesByDeveloperName = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Id idDNFRecType = mapRecordTypesByDeveloperName.get(Label.UAC_CaseRecordTypeDischargeNotification).getRecordTypeId();
        Id idSWBRecType = mapRecordTypesByDeveloperName.get(Label.UAC_caseRecordTypeSWB).getRecordTypeId();
        Set<String> setFieldsToQuery = new Set<String>{'Id'};
        objProgram = new UAC_testAccountBuilder().setRecordTypeDeveloperName(Label.UAC_accountRecordTypeAPINameProgram).setType(STR_PROGRAM_TYPE).build();
        objProgram.UAC_bedCountAvailableMale__c = 5;
        objProgram.UAC_bedCountAvailableFemale__c = 6;
        objProgram.UAC_withinORRNetwork__c = 'Yes';
        insert objProgram;
    
        List<Account> prgid = [Select Id from Account where id =:objProgram.Id];
        /*
        Contact objUAC = UAC_testContactBuilder.getContactByANumber('123456789', setFieldsToQuery);
        objUAC.UAC_program__c = prgid[0].Id;
        Update objUAC;
        Contact objAdultContact = UAC_testContactBuilder.getContactByANumber('123456789', setFieldsToQuery);
        UAC_adultContactRelationship__c objAdultContactRelationship = [select id,UAC_adultContact__c,UAC_uacLookup__c from UAC_adultContactRelationship__c where UAC_adultContact__c
                                                                       =:objAdultContact.Id and UAC_relationshipType__c = 'Primary Sponsor' and UAC_uacLookup__c =:objUAC.Id];        
    */
        String strNewANumber = '999999999';
        DateTime prev30Days = System.Now() - 30;
        Contact UAC = new UAC_testContactBuilder().setANumber(strNewANumber).setLastName(strNewANumber).setRecordTypeDeveloperName(Label.UAC_contactRecordTypeApiNameUAC).buildAndSave();
        objUACReleaseRequestCase = new UAC_testCaseBuilder().setStatus('CM Initiated').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeReleaseRequest).setUAC(UAC.id).build();
        objUACReleaseRequestCase.UAC_caseManager__c = userinfo.getuserid();
        objUACReleaseRequestCase.UAC_cfsName__c = userinfo.getuserid();
        objUACReleaseRequestCase.UAC_ffsName__c = userinfo.getuserid();
        objUACReleaseRequestCase.UAC_leadCaseManager__c = userinfo.getuserid();
        objUACReleaseRequestCase.UAC_caseCoordinator__c = userinfo.getuserid();
        objUACReleaseRequestCase.UAC_orrDecision__c = Label.UAC_approveStraightRelease;
        objUACReleaseRequestCase.UAC_orrComment__c = 'Test';
        objUACReleaseRequestCase.UAC_remandForFurtherInformation__c = 'Yes';
        objUACReleaseRequestCase.UAC_orrComment__c = 'Test1';        
        insert objUACReleaseRequestCase;  

        Case objUACAdmission = new UAC_testCaseBuilder().setStatus('CM Initiated').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeAdmission).setUAC(UAC.id).build();
        objUACAdmission.UAC_programFacility__c = prgid[0].id;
        insert objUACAdmission;

        User altAdminUser = UAC_TestUtility.getAlternateAdminUser();
        System.runAs(altAdminUser){
            List<CaseTeamRole> crt = [Select Id from CaseTeamRole where Name = 'Case MAnager' limit 1];
            CaseTeamMember ctm = new CaseTeamMember();
            ctm.MemberId = userinfo.getuserid();
            ctm.ParentId = objUACAdmission.Id;
            ctm.TeamRoleId = crt[0].Id;
            insert ctm;             
        }

        objUACDNFCase = new UAC_testCaseBuilder().setStatus('Discharge - (Initiated)').setRecordTypeDeveloperName(Label.UAC_caseRecordTypeDischargeNotification).setUAC(UAC.id).buildAndSave();
        objUACDNFCase.UAC_dateTimeOfDischarge__c = prev30Days;
        objUACDNFCase.ParentId = objUACReleaseRequestCase.Id;
        objUACDNFCase.UAC_typeOfDischarge__c = Label.UAC_dnfTypeOfDischargeReunifiedIndSp;
        objUACDNFCase.UAC_programFacility__c = prgid[0].Id;
        update objUACDNFCase;

        User altAdminUser1 = UAC_TestUtility.getAlternateAdminUser();
        System.runAs(altAdminUser1){
            AccountTeamMember atm = new AccountTeamMember();
            atm.AccountId = prgid[0].Id;
            atm.UserId = userinfo.getuserid();
            atm.TeamMemberRole = 'Federal Field Specialist';
            atm.AccountAccessLevel = 'Edit';
            insert atm;             
        }

        String CRON_EXP = '0 0 23 * * ?';   
        Test.startTest();     
        UAC_swbBatchScheduler swb = new UAC_swbBatchScheduler();
        System.schedule('UAC_swbBatchSchedulerTest', CRON_EXP, swb);
        Database.executeBatch(new UAC_swbBatch(), 200);       
        Test.stopTest();
        
        List<Case> updtCse = [Select Id,UAC_techSwbGenerated__c from case where id =:objUACDNFCase.Id];
        System.assertEquals(true,updtCse[0].UAC_techSwbGenerated__c);        
    }

}