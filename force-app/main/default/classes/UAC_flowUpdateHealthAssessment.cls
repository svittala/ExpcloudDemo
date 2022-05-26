/**
 * @File Name         : UAC_flowUpdateHealthAssessment.cls
 * @Description       : Class used to update Health Assessment(Health Evaluation) records from Health Assessment flows.
 * @Group             : UAC_flowUpdateHealthAssessment
 * @Test Class        : UAC_flowUpdateHealthAssessmentTest
 * @Author            : Anupreeta Chakraborty (Deloitte)
 * @Last Modified By  : Anupreeta Chakraborty (Deloitte)
 * @Last Modified On  : 08-17-2020
 * Modifications Log
 * Ver  Date        Author                                Modification
 * 1.0  08-17-2020  Anupreeta Chakraborty (Deloitte)      Initial Version
 * 1.1  08-25-2020  Abhisek Pati (Deloitte)               Added TB Lab Testing Code ORRUAC-1152
 * 1.2  09-01-2020  Abhisek Pati (Deloitte)               Added Status Integration ORRUAC-1965
 **/
public
with sharing class UAC_flowUpdateHealthAssessment {

  @InvocableMethod(label = 'Update Health Assessment') public static List<Response> updateHA(
    List<Request> lstRequest) {
    Request objRequest = lstRequest[0];
    Boolean isValidateTBLabTesting = true;
    Boolean isRiskBasedPRIDLabTestingValid = true;
     List<String> lstErrorMessage = new List<String>();
    // Clean up fields values
    objRequest.objRecord =
        (UAC_healthEvaluation__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);

    // Call conditional validation based on section name here
    if (objRequest.strSectionName == Label.UAC_generalInformationSectionNameHA) {
      objRequest.objRecord.UAC_generalInformationStatus__c =
          Label.UAC_HAgeneralInformationStatusComplete; 
    }

    if (objRequest.strSectionName == Label.UAC_reviewOfSystem_PhysicalSectionName) {
      objRequest.objRecord =
          (UAC_healthEvaluation__c) UpdateSystemsandPhysicalExamStatus(objRequest.objRecord);
    } 

    if (objRequest.strSectionName == Label.UAC_sectionHAHistoryAndPhysicalAssessment) {
      objRequest.objRecord.UAC_historyAndPhysicalAssessmentStatus__c =
          Label.UAC_HAHistoryandPhysicalAssessmentStatusComplete; 
    }	
    //RiskBased Test Records Check
    if (objRequest.strSectionName == Label.UAC_RiskBasedPRIDLabTestingHA) {
      isRiskBasedPRIDLabTestingValid =
           validateRiskBasedPRIDLabTest(objRequest.objRecord,lstErrorMessage );
      if (isRiskBasedPRIDLabTestingValid) {
        objRequest.objRecord =
            (UAC_healthEvaluation__c) UpdateRiskBasedPRIDLabTestingHAStatus(objRequest.objRecord);
      }
    }
    
    if (objRequest.strSectionName == Label.UAC_HASectionDiagnosisAndPlan) {
        objRequest.objRecord =
                    (UAC_healthEvaluation__c) validateDiagnosisandPlan(objRequest.objRecord);
            }	
			
    if (objRequest.strSectionName == Label.UAC_tbLabTesting) {
        isValidateTBLabTesting = validateTBLabTest(objRequest.objRecord,lstErrorMessage);
        if(isValidateTBLabTesting)
        objRequest.objRecord = (UAC_healthEvaluation__c)validateAndUpdateStatus(objRequest.objRecord);
    }
	
	if (objRequest.strSectionName == Label.UAC_HASectionContactTracing) {
        objRequest.objRecord =
                    (UAC_healthEvaluation__c) validateContactTracing(objRequest.objRecord);
            }
    
    // Perform update DML
    if(isRiskBasedPRIDLabTestingValid && isValidateTBLabTesting){
    Database.SaveResult objSaveResult = Database.update(objRequest.objRecord, false);
    if (!objSaveResult.isSuccess()) {
      for (Database.Error objError : objSaveResult.getErrors()) {
        lstErrorMessage.add(objError.getMessage());
        }
      }
    }

    // Prepare and return response
    Response objResponse = new Response();
    objResponse.objRecord = objRequest.objRecord;
    objResponse.errorMessage =
        (lstErrorMessage.isEmpty()) ? null : String.join(lstErrorMessage, '\n');
    return new List<Response>{objResponse};
  }
    
  /**
   * @description Method to update Status of Review of Systems and Physical Exam Status Section.
   * @author Karthi Subramanian (Deloitte) | 08-19-2020
   * @param objSObject SObject record to clean values
   * @return SObject
  **/
  public
  static SObject UpdateSystemsandPhysicalExamStatus(SObject objSObject) {
    Boolean isSignAndSymptomsValid = false;
    Boolean isPhysicalExamValid = false;
    UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c)objSObject;
    Integer countSignAndSymptoms = [SELECT count() FROM UAC_signsAndSymptoms__c WHERE UAC_associatedHealthEvaluation__c =:objSObject.Id];
    Integer countPhysicalExam = [SELECT count() FROM UAC_physicalExam__c WHERE UAC_associatedHealthEvaluation__c =:objSObject.Id];    
    if (
      (objHE.UAC_signsSymptomsObservedReported__c == Label.UAC_Yes && countSignAndSymptoms > 0) ||
        (objHE.UAC_signsSymptomsObservedReported__c == Label.UAC_No && countSignAndSymptoms == 0)){
          isSignAndSymptomsValid = true;
    }
    //Condition for Physical Exam
    if (
      (objHE.UAC_physicalExamPerformedbyHCP__c == Label.UAC_Yes && countPhysicalExam > 0) ||
        (objHE.UAC_physicalExamPerformedbyHCP__c == Label.UAC_No && countPhysicalExam == 0)){
      isPhysicalExamValid = true;
    }

    if (isSignAndSymptomsValid && isPhysicalExamValid ) {
      objSObject.put('UAC_statusReviewofSystemsandPhysicalExam__c', Label.UAC_HASystemsandPhysicalExamStatusComplete);
    }

    return objSObject;
  }    

    /**
* @description Method to Validate HE - Risk Based Lab Testing Save for RiskBased Lab Testing Section.
* Section.
* @author Ranjith kumar | 08-21-2020
* @param objSObject SObject record to clean values
* @return SObject
**/
    public
        static Boolean validateRiskBasedPRIDLabTest(SObject objSObject,List<String> lstErrorMessage) {
            Boolean isValid = true;
            UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c)objSObject;
            Map<String, List<UAC_test__c>> mapRTUAC = new Map<String, List<UAC_test__c>>{
                Label.UAC_testRecTypeRiskBasedLabTest => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeConfirmatoryLabTest => new List<UAC_test__c>()
                    };
                        List<UAC_test__c> lstTests = new List<UAC_test__c>();
            lstTests = [
                Select Id,
                UAC_result__c,
                UAC_associatedHealthEvaluation__r.UAC_ageAtAdmission__c,
                RecordType.DeveloperName FROM UAC_test__c WHERE UAC_associatedHealthEvaluation__c
                =:objSObject.Id AND RecordType.DeveloperName
                IN:mapRTUAC.keySet()
            ];
            
            if (lstTests.size() > 0) {
                for (UAC_test__c uac : lstTests) {
                    mapRTUAC.get(uac.RecordType.DeveloperName).add(uac);
                }
                if ((objHE.UAC_RiskBasedLabsPerformed__c == Label.UAC_No && mapRTUAC.get(Label.UAC_testRecTypeRiskBasedLabTest).size() > 0) || objHE.UAC_RiskBasedLabsPerformed__c == Label.UAC_No && mapRTUAC.get(Label.UAC_testRecTypeConfirmatoryLabTest).size() > 0){
                    isValid = false;
                    lstErrorMessage.add(Label.UAC_HaRiskBasedTestsNoErrorMessage);           
                }      
                
            }
            else if (objHE.UAC_RiskBasedLabsPerformed__c == Label.UAC_Yes && mapRTUAC.get(Label.UAC_testRecTypeRiskBasedLabTest).size() == 0){
                    isValid = false;
                    lstErrorMessage.add(Label.UAC_HaRiskBasedTestsYesErrorMessage);
                }
                
            return isValid;
        }

  /**
   * @description Method to update Status of Risk Based and PRID Lab testing Status Section.
   * @author Abhisek Pati (Deloitte) | 09-01-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static SObject UpdateRiskBasedPRIDLabTestingHAStatus(SObject objSObject) {
    Boolean isRiskBasedLabTestValid = false;
    Boolean isConfirmatoryLabTestValid = false;
    Boolean isPRIDLabTestValid = false;
    UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c) objSObject;
    // clang-format off
    Map<String, List<UAC_test__c>> mapRTUAC = new Map<String, List<UAC_test__c>>{
                Label.UAC_testRecTypeRiskBasedLabTest => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeConfirmatoryLabTest => new List<UAC_test__c>(),
                    Label.UAC_testRecTypePRIDLabTest => new List<UAC_test__c>()
                    };
    // clang-format on
    List<UAC_test__c> lstTests = new List<UAC_test__c>();
    lstTests = [
      Select Id,
      UAC_associatedHealthEvaluation__c,
      UAC_associatedUAC__c,
      UAC_result__c,
      UAC_diseaseConditionTested__c,
      UAC_specimenCollectionDate__c,
      UAC_bloodLeadLevelMCGDL__c,
      UAC_test__c,
      RecordType.DeveloperName FROM UAC_test__c WHERE UAC_associatedHealthEvaluation__c
       =:objSObject.Id AND RecordType.DeveloperName
      IN:mapRTUAC.keySet()
    ];

    if (lstTests.size() > 0) {
      for (UAC_test__c uac : lstTests) {
        mapRTUAC.get(uac.RecordType.DeveloperName).add(uac);
      }
    }

    Map<String, String> riskResultMap = new Map<String, String>();
    Map<String, String> confResultMap = new Map<String, String>();
    Map<String, String> pridResultMap = new Map<String, String>();

    isRiskBasedLabTestValid =
        validateRiskLabTest(mapRTUAC.get(Label.UAC_testRecTypeRiskBasedLabTest), riskResultMap);
    if (isRiskBasedLabTestValid) {
      isConfirmatoryLabTestValid =
          validateConfLabTest(mapRTUAC.get(Label.UAC_testRecTypeConfirmatoryLabTest),
              mapRTUAC.get(Label.UAC_testRecTypeRiskBasedLabTest),
              confResultMap,
              riskResultMap);
    }

    isPRIDLabTestValid =
        validatePridLabTest(mapRTUAC.get(Label.UAC_testRecTypePRIDLabTest), pridResultMap);

    if (isRiskBasedLabTestValid && isConfirmatoryLabTestValid && isPRIDLabTestValid) {
      objSObject.put('UAC_labTestingStatus__c', Label.UAC_testLabTestStatusComplete);
    } else {
      objSObject.put('UAC_labTestingStatus__c', Label.UAC_testLabTestStatusInProgress);
    }

    return objSObject;
  }

  /**
   * @description Method to validate Risk Lab Test
   * @author Abhisek Pati (Deloitte) | 09-01-2020
   * @param objSObject Current HealthEvaluation  record
   * @return SObject
   **/
  private
  static Boolean validateRiskLabTest(
      List<UAC_test__c> lstRiskTest, Map<String, String> testResultMap) {
    Boolean isValid = true;
    if (lstRiskTest != null && lstRiskTest.size() > 0) {
      for (UAC_test__c lstTest : lstRiskTest) {
        if (lstTest.UAC_result__c == Label.UAC_testPicklistPending) {
          isValid = false;
        }
        testResultMap.put(lstTest.UAC_diseaseConditionTested__c, lstTest.UAC_result__c);
      }
    }
    return isValid;
  }
  /**
   * @description Method to validate Confirmatory Lab test
   * @author Abhisek Pati (Deloitte) | 09-01-20200
   * @param objSObject Current HealthEvaluation  record
   * @return SObject
   **/
  private
  static Boolean validateConfLabTest(List<UAC_test__c> lstConfTest,
      List<UAC_test__c> lstRiskTest,
      Map<String, String> confResultMap,
      Map<String, String> riskResultMap) {
    Boolean isValid = false;

    Boolean isHBCoreTested = false;
    Boolean isHBSurfaceTested = false;
    Boolean isHCTested = false;
    Boolean isSyphilisTested = false;
    Boolean isHIVTested = false;
    Final String confirmatoryResult = Label.UAC_testLabTestResults;
    List<String> lstConfirmatoryResult = new List<String>();
    lstConfirmatoryResult = confirmatoryResult.split(' ; ');

    if (lstConfTest != null && lstConfTest.size() > 0) {
      for (UAC_test__c lstTest : lstConfTest) {
        if (lstTest.UAC_result__c == Label.UAC_testPicklistPending) {
          return false;
        }
        if (riskResultMap.containsKey(Label.UAC_testPicklistHepatitisB)
            && riskResultMap.get(Label.UAC_testPicklistHepatitisB)
                == Label.UAC_testPicklistPositive) {
          if (lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB) {
            if (lstTest.UAC_test__c == Label.UAC_testPicklistCoreAntiBody
                && lstConfirmatoryResult.contains(lstTest.UAC_result__c)) {
              isHBCoreTested = true;
            } else if (lstTest.UAC_test__c == Label.UAC_testPicklistSurfaceAntiBody
                && lstConfirmatoryResult.contains(lstTest.UAC_result__c)) {
              isHBSurfaceTested = true;
            }
          }
        } else {
          isHBCoreTested = true;
          isHBSurfaceTested = true;
        }

        if (riskResultMap.containsKey(Label.UAC_testPicklistSyphilis)
            && riskResultMap.get(Label.UAC_testPicklistSyphilis)
                == Label.UAC_testPicklistPositive) {
          if (lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistSyphilis
              && (lstTest.UAC_test__c == Label.UAC_testPicklistNonTreponemal
                  || lstTest.UAC_test__c == Label.UAC_testPicklistTreponemal)
              && lstConfirmatoryResult.contains(lstTest.UAC_result__c)) {
            isSyphilisTested = true;
          }
        } else {
          isSyphilisTested = true;
        }

        if (riskResultMap.containsKey(Label.UAC_testPicklistHIV)
            && riskResultMap.get(Label.UAC_testPicklistHIV) == Label.UAC_testPicklistPositive) {
          if (lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHIV
              && (lstTest.UAC_test__c == Label.UAC_testPicklistCombImmnasy
                  || lstTest.UAC_test__c == Label.UAC_testPicklistDiffImmnasy)
              && lstConfirmatoryResult.contains(lstTest.UAC_result__c)) {
            isHIVTested = true;
          }
        } else {
          isHIVTested = true;
        }

        if (riskResultMap.containsKey(Label.UAC_testPicklistHepatitisC)
            && riskResultMap.get(Label.UAC_testPicklistHepatitisC)
                == Label.UAC_testPicklistPositive) {
          if (lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisC
              && lstTest.UAC_test__c == Label.UAC_testPicklistHCVRNA
              && lstConfirmatoryResult.contains(lstTest.UAC_result__c)) {
            isHCTested = true;
          }
        } else {
          isHCTested = true;
        }

        confResultMap.put(lstTest.UAC_diseaseConditionTested__c, lstTest.UAC_result__c);
      }
    } else {
      boolean isNegative = false;
      for (UAC_test__c lstTest : lstRiskTest) {
        if ((lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHIV
                || lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisC
                || lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB
                || lstTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistSyphilis)
            && lstTest.UAC_result__c == Label.UAC_testPicklistPositive) {
          isNegative = true;
        }
      }
      if (!isNegative) {
        isHBCoreTested = true;
        isHBSurfaceTested = true;
        isHCTested = true;
        isSyphilisTested = true;
        isHIVTested = true;
      }
    }

    if (isHBCoreTested && isHBSurfaceTested && isHCTested && isSyphilisTested && isHIVTested) {
      isValid = true;
    }

    return isValid;
  }

  /**
   * @description Method to validate PRID Tab test
   * @author Abhisek Pati (Deloitte) | 09-01-2020
   * @param objSObject Current HealthEvaluation  record
   * @return SObject
   **/
  private
  static Boolean validatePridLabTest(
      List<UAC_test__c> lstPRIDTest, Map<String, String> testResultMap) {
    Boolean isValid = true;
    if (lstPRIDTest != null && lstPRIDTest.size() > 0) {
      for (UAC_test__c lstTest : lstPRIDTest) {
        if (lstTest.UAC_result__c == Label.UAC_testPicklistPending) {
          isValid = false;
        }
        testResultMap.put(lstTest.UAC_diseaseConditionTested__c, lstTest.UAC_result__c);
      }
    }
    return isValid;
  }

  /**
   * @description Method to Validate HE - TB Lab Testing Save for TB Lab Testing Section.
   * Section.
   * @author Abhisek Pati (Deloitte) | 08-25-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static Boolean validateTBLabTest(SObject objSObject,List<String> lstErrorMessage) {
    Boolean isValid = true;
    Map<String, List<UAC_test__c>> mapRTUAC = new Map<String, List<UAC_test__c>>{
                Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeTBScreeningUnder2YearsAge => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeImagingStudy => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeBacteriologicalResults => new List<UAC_test__c>()
                    };
    List<UAC_test__c> lstTests = new List<UAC_test__c>();
    lstTests = [
      Select Id,
      UAC_result__c,
      UAC_associatedHealthEvaluation__r.UAC_ageAtAdmission__c,
      RecordType.DeveloperName FROM UAC_test__c WHERE UAC_associatedHealthEvaluation__c
       =:objSObject.Id AND RecordType.DeveloperName
      IN:mapRTUAC.keySet()
    ];
    if (lstTests.size() > 0) {
      for (UAC_test__c objTest : lstTests) {
        mapRTUAC.get(objTest.RecordType.DeveloperName).add(objTest);
      }
    UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c)objSObject;
        if (objHE.UAC_wereAnyTBLabTestsPerformed__c == Label.UAC_No 
            && (mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder).size() > 0
            || mapRTUAC.get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge).size() > 0 
            || mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() > 0
            || mapRTUAC.get(Label.UAC_testRecTypeBacteriologicalResults).size() > 0)){
            lstErrorMessage.add(Label.UAC_HaTBLabTestingNoErrorMessage);
            isValid = false;
        }
        else if (objHE.UAC_wereAnyTBLabTestsPerformed__c == Label.UAC_Yes 
            && ((mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder).size() == 0)
            && (mapRTUAC.get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge).size() == 0) 
            && (mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() == 0)
            && (objHE.UAC_healthDepartmentSpecialistDecision__c == Label.UAC_healthEvaluationHealthDeptDecisionWorkUpNeeded 
                  && mapRTUAC.get(Label.UAC_testRecTypeBacteriologicalResults).size() == 0))){
            lstErrorMessage.add(Label.UAC_HaTBLabTestingYesErrorMessage);
            isValid = false;
        }
    } 
     return isValid;
    }
	
	  /**
   * @description Method to Validate HE - TB Lab Testing Section and update status.
   * Section.
   * @author Anupreeta Chakraborty (Deloitte) | 09-1-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static SObject validateandUpdateStatus(SObject objSObject) {
    Boolean isValid = true;
    // clang-format off
    Map<String, List<UAC_test__c>> mapRTUAC = new Map<String, List<UAC_test__c>>{
                Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeTBScreeningUnder2YearsAge => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeImagingStudy => new List<UAC_test__c>(),
                    Label.UAC_testRecTypeBacteriologicalResults => new List<UAC_test__c>()
                    };
    // clang-format on
    List<UAC_test__c> lstTests = new List<UAC_test__c>();
    lstTests = [
      Select Id,
      UAC_result__c,
      UAC_associatedHealthEvaluation__r.UAC_ageAtAdmission__c,
      RecordType.DeveloperName FROM UAC_test__c WHERE UAC_associatedHealthEvaluation__c
       =:objSObject.Id AND RecordType.DeveloperName
      IN:mapRTUAC.keySet()
    ];
    if (lstTests.size() > 0) {
      for (UAC_test__c objTest : lstTests) {
        mapRTUAC.get(objTest.RecordType.DeveloperName).add(objTest);
        //Checking if any test records have status pending
        if(objTest.UAC_result__c == Label.UAC_Pending)
        isValid = false;        
      }
      }
    UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c)objSObject;
        if (objHE.UAC_PPDTSTTest__c == Label.UAC_Yes
            && (mapRTUAC.get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge). size() == 0) ){
            isValid = false;
        }
        else if (objHE.UAC_IGRATBTest__c == Label.UAC_Yes
            && (mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder).size() == 0) ){
            isValid = false;
        }
        else if (objHE.UAC_ImagingStudyTBTest__c == Label.UAC_Yes
            && (mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() == 0) ){
            isValid = false;
        }
        else if (objHE.UAC_healthDepartmentSpecialistDecision__c == Label.UAC_healthEvaluationHealthDeptDecisionWorkUpNeeded
            && (mapRTUAC.get(Label.UAC_testRecTypeBacteriologicalResults).size() == 0) ){
            isValid = false;
        }       
        
    if (isValid) {
    objSObject.put('UAC_TBLabTestingStatus__c', Label.UAC_tbLabTestingStatusComplete);
    } else {
    objSObject.put('UAC_TBLabTestingStatus__c', Label.UAC_tbLabTestingStatusInProgress);
    }
 
            return objSObject;
    }   
	
	    
    /**
* @description Method to update HA - Diagnosis and Plan Status value for Diagnosis and Plan
*Section.
* @author Anupreeta Chakraborty (Deloitte) | 09-11-2020
* @param objSObject SObject record to clean values
* @return SObject
**/
    public
        static SObject validateDiagnosisandPlan(SObject objSObject) {
            Boolean isValid = true;
            UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c)objSObject;

            Integer countImmunization = [SELECT count() FROM UAC_immunization__c WHERE UAC_associatedHealthEvaluation__c =:objSObject.Id];
            Integer countDiagnosis = [SELECT count() FROM UAC_diagnosis__c WHERE UAC_associatedHealthEvaluation__c =:objSObject.Id];            
            // Fetch previously created Diagnoses and Diagnosis Outcomes associated with the UAC and not associated with the current health assessment.
            List<UAC_diagnosis__c> PrevDiagnoses = [select id from UAC_diagnosis__c where UAC_associatedUAC__c =: objHE.UAC_associatedUAC__c and UAC_associatedHealthEvaluation__c !=: objHE.Id];  
            
            if (objHE.UAC_diagnosesMedsReferrals__c == Label.UAC_Yes){
            if (countDiagnosis <= 0 && (PrevDiagnoses.size() > 0)) {
                    // If "Minor with Complaints, Symptoms, Diagnoses/Conditions; Medications Prescribed
                    // (including OTC); Referrals Made" = Yes then the user must enter at least one Diagnosis entry
                    // OR add a new Exam Outcome to an Existing Diagnosis record
                    List<UAC_diagnosisOutcome__c> lstDiagnosisOutcome = [select id from UAC_diagnosisOutcome__c where UAC_associatedHealthEvaluation__c =:objSObject.id and UAC_associatedDiagnosis__c IN: PrevDiagnoses];
                    if(lstDiagnosisOutcome.size()<=0)
                        isValid = false;
                }
            if(countDiagnosis <= 0 && PrevDiagnoses.size() <= 0){
                    // Atleast one new or Previous diagnosis should be associated with the health Assessment
                    // if "Minor with Complaints, Symptoms, Diagnoses/Conditions; Medications Prescribed
                    // (including OTC); Referrals Made" = Yes
                        isValid = false;            
            }
                }
            if (countDiagnosis > 0) {
                List<UAC_diagnosis__c> lstWorkingDiagnosis = [select id 
                                                       from UAC_diagnosis__c where UAC_associatedHealthEvaluation__c =:objSObject.id and UAC_status__c =: Label.UAC_diagnosisStatusWorking];
                  if(lstWorkingDiagnosis.size()>0){
                        // All diagnoses records entered in the Diagnosis table should be in status not equal to
                        // "Working"
                  isValid = false;
                  }
            }
            if (objHE.UAC_immunizationsAdministered__c == Label.UAC_Yes
                && countImmunization <= 0) {
                    // If "Were Immunizations Administered as Part of Exam, and/or Indicated, but not Given?" = Yes
                    // then the user must enter at least one Immunization entry into the Immunization table
                    isValid = false;
                }
            if (isValid) {
                objSObject.put('UAC_assessmentAndPlanStatus__c', Label.UAC_assessmentAndPlanStatusComplete);
            } else {
                objSObject.put('UAC_assessmentAndPlanStatus__c', Label.UAC_assessmentAndPlanStatusInProgress);
            }
            return objSObject;
        } 
        
        /**
* @description Method to update HA - Contact Tracing Status value for Contact Tracing section
*Section.
* @author Anupreeta Chakraborty (Deloitte) | 09-14-2020
* @param objSObject SObject record to clean values
* @return SObject
**/
    public
        static SObject validateContactTracing(SObject objSObject) {
            Boolean isNotStarted = false;
            Boolean isInProgress = false;   
            Boolean isComplete = false; 
            Boolean isNotApplicable = false;
            
            map<String,Integer> phiStatusCountMap =new map<String,Integer>();
            
            // Fetch the Exposure events associated with Health Assessment.
            List<AggregateResult> aggResultExpEvent = [SELECT count(Id)ExpEventcount,UAC_PHIStatus__c FROM UAC_exposureEvent__c WHERE UAC_associatedHealthEvaluation__c =:objSObject.Id group by UAC_PHIStatus__c]; 
            
            for(AggregateResult aggr:aggResultExpEvent){   
            phiStatusCountMap.put((String)aggr.get('UAC_PHIStatus__c'), (Integer)aggr.get('ExpEventcount')); 
        } 
            
            if (aggResultExpEvent != null && aggResultExpEvent.size() > 0) {

                // Check if all Exposure Events have a 'PHI Status' = Not Started. 
                    if (phiStatusCountMap.containskey(Label.UAC_PHIStatusNotStarted) && aggResultExpEvent.size() == 1){
                        isNotStarted = true;
                    }           
                                    
                // Check if at least one Exposure Event has a 'PHI Status' of "In Progress"
                    if (phiStatusCountMap.containskey(Label.UAC_PHIStatusInProgress)) {
                        isInProgress = true;
                    }
              
                // Check if all Exposure Events have a 'PHI Status' of "Complete"                                                      
                    if (phiStatusCountMap.containskey(Label.UAC_PHIStatusComplete) && aggResultExpEvent.size() == 1){
                        isComplete = true;
                    }
            } else{
            isNotApplicable = true;
            }

            if (isNotStarted) {
                objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusNotStarted);
            } else if(isInProgress){
                objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusInProgress);
            } else if(isComplete){
                objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusComplete);          
            } else if(isNotApplicable){
                objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusNotApplicable);             
            }
            return objSObject;
        }   
    

  /**
   * @description Request class to hold request data
   * Each @InvocableVariable defined in this class is an input variable you can populate when
   *calling this from Flow
   * @author Anupreeta Chakraborty (Deloitte) | 07-15-2020
   * @Group             : UAC_flowUpdateHealthAssessment
   **/
  public
   inherited sharing class Request {
    @InvocableVariable(required = true) public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String strSectionName;
  }

  /**
   * @description Response class to hold response data
   * Each @InvocableVariable defined in this class is an output variable and you can populate use it
   *in  Flow
   * @author Anupreeta Chakraborty (Deloitte) | 07-15-2020
   * @Group             : UAC_flowUpdateHealthAssessment
   **/
  public inherited sharing class Response {
    @InvocableVariable public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}