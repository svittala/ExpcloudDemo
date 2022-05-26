/**
* @File Name          : UAC_asyncIMEChildRecordService.cls
* @Description        : This class is used for IME child record Services.
* @Author             : Abhisek Pati (Deloitte)
* @Group              : 
* @Test Class         : UAC_healthEvaluationTriggerHelperTest.cls
* @Last Modified By   : Abhisek Pati (Deloitte)
* @Modification Log   : Initial version
* Ver       Date           Author                      	Modification
* 1.0    	3/22/2021	   Abhisek Pati (Deloitte)  	Initial version.
**/
public
without sharing class UAC_asyncIMEChildRecordService {
        
    /**
   * @description handling Creation of IME Physical Exam Records
   * @author Abhisek Pati (Deloitte) | 3/22/2021
   * @param healthEvaluationSet
   * @return boolean
   **/   
    Public Static boolean createIMEPhysicalExamRecords(Set<Id> healthEvaluationSet){
        boolean isSuccess = false;
        try{
            Set<String> setSObjectToGenerate = new Set<String>();
            setSObjectToGenerate.add(UAC_physicalExam__c.sObjectType.getDescribe().getName());
            List<UAC_physicalExam__c> lstAutoGenerateRecord =
            UAC_autoGenerationServices.getRecords(setSObjectToGenerate);
            List<UAC_physicalExam__c> lstRecordsToInsert = new List<UAC_physicalExam__c>();
        	
            for (UAC_healthEvaluation__c objHealthEvaluation :[SELECT Id,
                                                               UAC_associatedUAC__c,
                                                               (SELECT Id FROM UAC_physicalExams__r)
                                                               FROM UAC_healthEvaluation__c 
                                                               Where Id In:healthEvaluationSet]) {
                if(objHealthEvaluation.UAC_physicalExams__r.size() == 0){
                    for (UAC_physicalExam__c objRecord : lstAutoGenerateRecord) {
                        UAC_physicalExam__c ObjPhysicalExam = new UAC_physicalExam__c();
                        ObjPhysicalExam.UAC_associatedHealthEvaluation__c = objHealthEvaluation.Id;
                        ObjPhysicalExam.UAC_associatedUAC__c = objHealthEvaluation.UAC_associatedUAC__c;
                        ObjPhysicalExam.UAC_physicalSystem__c = objRecord.UAC_physicalSystem__c;
                        ObjPhysicalExam.UAC_order__c = objRecord.UAC_order__c;
                        lstRecordsToInsert.add(ObjPhysicalExam);
                        }
                    }
                }
       		
            if(!lstRecordsToInsert.isEmpty())
            	insert lstRecordsToInsert;
            	isSuccess = true;
            
        } catch (Exception ex) {
            UAC_errorLog.logError(ex.getMessage(),
            null,
            'Saving IME Physical Exam records',
            healthEvaluationSet.toString() + ex.getStackTraceString());
      }
        return isSuccess;
    }
    
    /**
   * @description handling Creation of IME RiskBased Test records
   * @author Abhisek Pati (Deloitte) | 3/22/2021
   * @param healthEvaluationSet
   * @return void
   **/   
    Public Static Void createIMERiskBasedLabRecords(Set<Id> healthEvaluationSet){
        try{
        Set<String> setSObjectToGenerate = new Set<String>();
            setSObjectToGenerate.add(UAC_test__c.sObjectType.getDescribe().getName());
            List<UAC_test__c> lstAutoGenerateRecord =
            UAC_autoGenerationServices.getRecords(setSObjectToGenerate);
            List<UAC_test__c> lstRecordsToInsert = new List<UAC_test__c>();
            
            for (UAC_healthEvaluation__c objHealthEvaluation : [SELECT Id,
                                                                UAC_associatedUAC__c,
                                                                (SELECT Id FROM Tests__r)
                                                                FROM UAC_healthEvaluation__c 
                                                                Where Id In:healthEvaluationSet]) {
            if(objHealthEvaluation.Tests__r.size() == 0){
                for (UAC_test__c objRecord : lstAutoGenerateRecord) {
                    UAC_test__c ObjTest	= new UAC_test__c();
                    ObjTest.UAC_systemGenerated__c = true;
                    ObjTest.UAC_associatedHealthEvaluation__c = objHealthEvaluation.Id;
                    ObjTest.UAC_associatedUAC__c = objHealthEvaluation.UAC_associatedUAC__c;
                    ObjTest.UAC_diseaseConditionTested__c = objRecord.UAC_diseaseConditionTested__c;
                    ObjTest.UAC_indicator__c = objRecord.UAC_indicator__c;
                    ObjTest.UAC_test__c = objRecord.UAC_test__c;
                    ObjTest.UAC_result__c = objRecord.UAC_result__c;
                    ObjTest.UAC_specimenSource__c = objRecord.UAC_specimenSource__c;
                    ObjTest.UAC_order__c = objRecord.UAC_order__c;
                    lstRecordsToInsert.add(ObjTest);
                    }
                }
            }
            if(!lstRecordsToInsert.isEmpty())
            insert lstRecordsToInsert;
        } catch (Exception ex) {
            UAC_errorLog.logError(ex.getMessage(),
            null,
            'Saving IME Risk Based records',
            healthEvaluationSet.toString() + ex.getStackTraceString());
      }
    }
}