/**
 * @File Name         : UAC_flowUpdateIME.cls
 * @Description       : Class used to update IME Health Evaluation records from IME flows.
 * @Group             : UAC_flowUpdateIME
 * @Test Class        : UAC_flowUpdateTest
 * @Author            : Sachet Khanal (Deloitte)
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 11-19-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-14-2020   Sachet Khanal (Deloitte)   Initial Version
 * 1.1   11-18-2020   Abhisek Pati (Deloitte)    ORRUAC-4230 Added Logic for IME Progress Bar
 * 1.2   11-30-2020   Abhisek Pati (Deloitte)    ORRUAC-4378 Added TB Lab Testing Logic
 **/
public
with sharing class UAC_flowUpdateIME {

  @InvocableMethod(label = 'Update IME') public static List<Response> updateIME(
      List<Request> lstRequest) {
    Request objRequest = lstRequest[0];

    // Clean up fields values
    objRequest.objRecord =
        (UAC_healthEvaluation__c) UAC_utilities.cleanFieldValues(objRequest.objRecord);

    // Call conditional validation based on section name here
    if (objRequest.strSectionName == Label.UAC_sectionIMEPsychosocialRisk) {
      objRequest.objRecord =
          (UAC_healthEvaluation__c) validatePsychoSocialRisk(objRequest.objRecord);
      objRequest.objRecord.UAC_psychosocialRiskStatus__c = Label.UAC_psychosocialRiskStatus;
    }
    if (objRequest.strSectionName == Label.UAC_sectionIMELabTest) {
      objRequest.objRecord = (UAC_healthEvaluation__c) validateLabTest(objRequest.objRecord);
    }
    if (objRequest.strSectionName == Label.UAC_generalInformationSectionName) {
      objRequest.objRecord.UAC_generalInformationStatus__c =
          Label.UAC_generalInformationStatusComplete;
    }

    if (objRequest.strSectionName == Label.UAC_reviewOfSystem_PhysicalSectionName) {
      // Count Query physical exam where status = null = 0, then Complete, else In Progress"
      objRequest.objRecord =
          (UAC_healthEvaluation__c) UpdateSystemsandPhysicalExamStatus(objRequest.objRecord);
    }

    if (objRequest.strSectionName == Label.UAC_tbLabTesting) {
      Map<sObject, List<String>> mapsObjErrors = validateTBLabTest(objRequest.objRecord);
      for (sObject sobj : mapsObjErrors.keySet()) {
        objRequest.objRecord = (UAC_healthEvaluation__c) sobj;
      }
    }

    if (objRequest.strSectionName == Label.UAC_imeSectionDiagnosisAndPlan) {
      objRequest.objRecord =
          (UAC_healthEvaluation__c) validateDiagnosisandPlan(objRequest.objRecord);
    }

    if (objRequest.strSectionName == Label.UAC_IMESectionContactTracing) {
      objRequest.objRecord = (UAC_healthEvaluation__c) validateContactTracing(objRequest.objRecord);
    }

    // Perform update DML
    List<String> lstErrorMessage = new List<String>();
    Database.SaveResult objSaveResult = Database.update(objRequest.objRecord, false);
    if (!objSaveResult.isSuccess()) {
      for (Database.Error objError : objSaveResult.getErrors()) {
        lstErrorMessage.add(objError.getMessage());
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
   * @description Method to clean value types for Flow variables and conditional logic for
   *PsychoSocialRisk section. Used to clean values from Flow.
   * @author Karthi Subrmanian (Deloitte) | 07-17-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static sObject validatePsychoSocialRisk(SObject objSObject) {

    // Adding default value for Checkbox datatype to false; Flow variable will be defaulted to null
    // if not displayed on screen
    for (String strFieldName : objSObject.getPopulatedFieldsAsMap().keySet()) {
      if (objSObject.getSObjectType()
              .getDescribe()
              .fields.getMap()
              .get(strFieldName)
              .getDescribe()
              .getType()
          == Schema.DisplayType.BOOLEAN) {
        if (objSObject.get(strFieldName) == null) {
          objSObject.put(strFieldName, Boolean.valueOf('false'));
        } else {
          objSObject.put(strFieldName, Boolean.valueOf(objSObject.get(strFieldName)));
        }
      }
    }
    return objSObject;
  }
  /**
   * @description Method to validate Lab Test.
   * Used to validate Lab Test of Flow
   * @author Manoj Bhagwat(Entellimatrix) | 07-27-2020 | Jira 1439
   * @param objSObject Current HealthEvaluation  record
   * @return SObject
   **/
  private
  static sObject validateLabTest(SObject objSObject) {
    Boolean isRiskValid = false;
    Boolean isConfValid = false;
    Boolean isPridValid = false;
    String fieldList;
    String testQuery;
    String recTypeName;
    String recTypeId;
    List<UAC_test__c> testList = new List<UAC_test__c>();
    // get all fields and record types of UAC_test__c object
    Schema.DescribeSObjectResult imeFR = Schema.SObjectType.UAC_test__c;
    List<Schema.RecordTypeInfo> recTypes = imeFR.getRecordTypeInfos();
    map<String, String> recTypeMap = new map<String, String>();
    for (Schema.RecordTypeInfo ri : recTypes) {
      recTypeMap.put(ri.getDeveloperName(), ri.getRecordTypeId());
    }
    Map<String, Object> fieldMap = imeFR.fields.getMap();
    // now construct  Query string
    // clang-format off
    testQuery =
      'SELECT ' +
        'Id,Name , UAC_associatedHealthEvaluation__c, UAC_associatedUAC__c, ' +
        'UAC_result__c,UAC_specimenCollectionDate__c,UAC_test__c,UAC_diseaseConditionTested__c,' +
        'UAC_bloodLeadLevelMCGDL__c,RecordTypeId  ' +
      'FROM '+
        'UAC_test__c ' +
      'WHERE ' +
        'UAC_associatedHealthEvaluation__c = \'' + objSObject.Id + '\'';
    // clang-format on
    try {
      testList = Database.query(testQuery);
    } catch (Exception e) {
      UAC_errorLog.platformEventErrorLog(
          e.getMessage(), objSObject.Id, 'Fetching Diagnostic records', e.getStackTraceString());
    }
    // let us put all UAC Test records into a recordType map
    map<String, List<UAC_test__c>> labTestMap = new map<String, List<UAC_test__c>>();
    for (UAC_test__c ut : testList) {
      List<UAC_test__c> tList = labTestMap.containsKey(ut.RecordTypeId)
          ? labTestMap.get(ut.RecordTypeId)
          : new List<UAC_test__c>();
      tList.add(ut);
      labTestMap.put(ut.RecordTypeId, tList);
    }
    // Now let us validate all the record types of UAC Test
    Map<String, String> riskResultMap = new Map<String, String>();
    Map<String, String> pridResultMap = new Map<String, String>();
    isPridValid = validatePridLabTest(
        labTestMap.get(recTypeMap.get(Label.UAC_testRecTypePRIDLabTest)), pridResultMap);
    if (isPridValid) {
      isRiskValid = validateRiskLabTest(
          labTestMap.get(recTypeMap.get(Label.UAC_testRecTypeRiskBasedLabTest)), riskResultMap);
      if (isRiskValid) {
        isConfValid = validateConfLabTest(
            labTestMap.get(recTypeMap.get(Label.UAC_testRecTypeConfirmatoryLabTest)),
            riskResultMap);
      }
    }
    if (isRiskValid && isConfValid && isPridValid) {
      objSObject.put('UAC_labTestingStatus__c', Label.UAC_testLabTestStatusComplete);
    } else {
      objSObject.put('UAC_labTestingStatus__c', Label.UAC_testLabTestStatusInProgress);
    }

    return objSObject;
  }

  /**
   * @description Method to update Status of Review of Systems and Physical Exam Status Section.
   * @author Abhisek Pati (Deloitte) | 11-17-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static SObject updateSystemsandPhysicalExamStatus(SObject objSObject) {
    Boolean isSignAndSymptomsValid = false;
    Boolean isPhysicalExamValid = false;
    UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c) objSObject;
    Integer countSignAndSymptoms = [SELECT count()
            FROM UAC_signsAndSymptoms__c WHERE UAC_associatedHealthEvaluation__c =:objSObject.Id];
    Integer countPhysicalExam =
        [SELECT count() FROM UAC_physicalExam__c WHERE UAC_associatedHealthEvaluation__c
            =:objSObject.Id AND UAC_status__c != null];
    if ((objHE.UAC_signsSymptomsObservedReported__c == Label.UAC_Yes && countSignAndSymptoms > 0)
        || (objHE.UAC_signsSymptomsObservedReported__c == Label.UAC_No
            && countSignAndSymptoms == 0)) {
      isSignAndSymptomsValid = true;
    }
    // Condition for Physical Exam
    if (countPhysicalExam > 0) {
      isPhysicalExamValid = true;
    }

    if (isSignAndSymptomsValid && isPhysicalExamValid) {
      objSObject.put('UAC_statusReviewofSystemsandPhysicalExam__c',
          Label.UAC_HASystemsandPhysicalExamStatusComplete);
    } else {
      objSObject.put('UAC_statusReviewofSystemsandPhysicalExam__c', Label.UAC_testPicklistPending);
    }
    return objSObject;
  }

    /**
* @description Method to validate Test of type Risk.
* Used to validate Risk Lab Test of Flow
* @author Anupreeta Chakraborty(Deloitte) | 11-18-2020 ORRUAC-4376
* @param objSObject Current HealthEvaluation  record
* @return SObject
**/
    private
        static Boolean validateRiskLabTest(
            List<UAC_test__c> testList, Map<String, String> testDiseaseResultMap) {
                Map<String, String> testValidDiseaseResultMap = new Map<String, String>();  
                List<UAC_test__c> pendingTestList;
                List<UAC_test__c> validTestList;
                Boolean isValid = true;
                String statusPending = Label.UAC_testPicklistPending;
                String diseases = Label.UAC_testLabTestRiskDiseases;
                List<String> lstDiseases = diseases.split(' ; ');
                Final String rsl = Label.UAC_validRiskBasedLabTestResults;
                List<String> rslList = new List<String>();
                rslList = rsl.split(' ; ');
                
                // Check if any of the Risk based lab tests related to IME is in pending status. If yes, then
                // return false(Lab testing status should be In Progress).
                pendingTestList =
                    [SELECT Id FROM UAC_test__c WHERE Id IN:testList AND UAC_result__c =:statusPending];
                if (pendingTestList.size() > 0) {
                    return false;
                }
                
                // Get all the risk based lab test that have results either Positive (Reactive, Detected) or
                // Negative (Not Reactive, Not Detected), or Not Done.
                // clang-format off
                validTestList = [
                    SELECT
                    Id, UAC_diseaseConditionTested__c, UAC_result__c
                    FROM
                    UAC_test__c
                    WHERE
                    Id IN:testList
                    AND UAC_result__c IN :rslList
                ];
                // clang-format on
                if (validTestList.size() > 0) {
                    for (UAC_test__c objTest : validTestList) {
                        testValidDiseaseResultMap.put(objTest.UAC_diseaseConditionTested__c, objTest.UAC_result__c);
                        if(objTest.UAC_result__c == Label.UAC_testPicklistPositive && (objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB || 
                                                                                       objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisC || objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHIV
                                                                                       || objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistSyphilis))
                            testDiseaseResultMap.put(objTest.UAC_diseaseConditionTested__c, objTest.UAC_result__c);
                    }
                    
                    // Check if all the disease/condition has result either Positive (Reactive, Detected) or
                    // Negative (Not Reactive, Not Detected), or Not Done. If any of the disease/condition is not
                    // found to have these valid results, return false(Lab testing status should be In Progress).
                    for (String disease : lstDiseases) {
                        if (testValidDiseaseResultMap.containsKey(disease))
                            continue;
                        else {
                            return false;
                        }
                    }
                }
                
                return isValid;
            }
  
    /**
* @description Method to validate Test of type Confirmatory.
* Used to validate Confirmatory Lab Test of Flow of type Confirmatory
* @author Anupreeta Chakraborty | 11-24-2020 | Jira 1439
* @param objSObject Current HealthEvaluation  record
* @return SObject
**/
    private
        static Boolean validateConfLabTest(List<UAC_test__c> testList,
                                           Map<String, String> riskResultMap) {
                                               
                                               Boolean isValid = true;                                              
                                               Boolean pendingTestListCheck = false;
                                               Boolean heptBCAntibodyCheck = false;
                                               Boolean heptBSAntibodyCheck = false;
                                               Boolean heptCHCVRNACheck = false;
                                               Boolean HIVCheck = false;
                                               Boolean syphillisCheck = false;
                                               
                                               String statusPending = Label.UAC_testPicklistPending;
                                               String strTestHepatitisBCoreAntibody = Label.UAC_testHepatitisBCoreAntibody;
                                               String strTestHepatitisBSurfaceAntibody = Label.UAC_testHepatitisBSurfaceAntibody;  
                                               String strTestPicklistHCVRNA = Label.UAC_testPicklistHCVRNA;    
                                               String rsl = Label.UAC_confLabTestResults;
                                               List<String> rslList = new List<String>();
                                               rslList = rsl.split(' ; ');
                                               String strHIVTestOptions = Label.UAC_HIVTestOptions;
                                               List<String> lstHIVTests = new List<String>();
                                               lstHIVTests = strHIVTestOptions.split(' ; ');
                                               String strSyphillisTestOptions = Label.UAC_syphillisTestOptions;
                                               List<String> lstSyphillisTests = new List<String>();
                                               lstSyphillisTests = strSyphillisTestOptions.split(' ; '); 
                                               
                                               if(riskResultMap != null && !riskResultMap.isEmpty()){    
                                                   if(testList != null){
                                                       
                                                       for(UAC_test__c objTest : testList){
                                                           //Get list of Confirmatory lab tests related to IME with pending status.                                                    
                                                           if(objTest.UAC_result__c == statusPending)
                                                               pendingTestListCheck = true;
                                                           
                                                           //Get list of Confirmatory lab tests with Disease/condition - Hepatitis B and Results either Positive (Reactive, Detected) or
                                                           // Negative (Not Reactive, Not Detected), or Not Done and Test - 'Hepatitis B Core Antibody',
                                                           if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB &&
                                                              objTest.UAC_test__c == strTestHepatitisBCoreAntibody
                                                              && rslList.contains(objTest.UAC_result__c)){
                                                                  heptBCAntibodyCheck = true;
                                                              }
                                                           
                                                           //Get list of Confirmatory lab tests with Disease/condition - Hepatitis B and Results either Positive (Reactive, Detected) or
                                                           // Negative (Not Reactive, Not Detected), or Not Done and Test - 'Hepatitis B Surface Antibody',                                                    
                                                           if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisB &&
                                                              objTest.UAC_test__c == strTestHepatitisBSurfaceAntibody
                                                              && rslList.contains(objTest.UAC_result__c)){
                                                                  heptBSAntibodyCheck = true;
                                                              }                                                                                                              
                                                           
                                                           //Get list of Confirmatory lab tests with Disease/condition - Hepatitis C and Results either Positive (Reactive, Detected) or
                                                           // Negative (Not Reactive, Not Detected), or Not Done and Test - 'HCV RNA',
                                                           if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHepatitisC &&
                                                              objTest.UAC_test__c == strTestPicklistHCVRNA
                                                              && rslList.contains(objTest.UAC_result__c)){
                                                                  heptCHCVRNACheck = true;
                                                              }                                                                                                              
                                                           
                                                           //Get list of Confirmatory lab tests with Disease/condition - HIV and Results either Positive (Reactive, Detected) or
                                                           // Negative (Not Reactive, Not Detected), or Not Done and Test - HIV1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test) OR HIV-1/HIV-2 Antibody Differentiation Immunoassay                                                     
                                                           if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistHIV &&
                                                              lstHIVTests.contains(objTest.UAC_test__c)
                                                              && rslList.contains(objTest.UAC_result__c)){
                                                                  HIVCheck = true;
                                                              }                                                     
                                                           
                                                           //Get list of Confirmatory lab tests with Disease/condition - Syphilis and Results either Positive (Reactive, Detected) or
                                                           // Negative (Not Reactive, Not Detected), or Not Done and Test -  Non-treponemal (e.g., RPR/VRDL) OR Treponemal (e.g., FTA-ABS, TPPA)
                                                           if(objTest.UAC_diseaseConditionTested__c == Label.UAC_testPicklistSyphilis &&
                                                              lstSyphillisTests.contains(objTest.UAC_test__c)
                                                              && rslList.contains(objTest.UAC_result__c)){
                                                                  syphillisCheck = true;
                                                              }                                                       
                                                       }
                                                       
                                                       // Check if any of the Confirmatory lab tests related to IME is in pending status. If yes, then
                                                       // return false(Lab testing status should be In Progress).
                                                       if(pendingTestListCheck)
                                                           return false;
                                                       
                                                       // Check if there is at least one Risk-Based Lab Test entry where "Disease/Condition Tested" = Acute/Chronic Hepatitis B and "Result" = Positive (Reactive, Detected), then there must be at least two Confirmatory Lab test //record entry with Disease Acute/Chronic Hepatitis B and conditions met.
                                                       // or else return false(Lab testing status should be In Progress).  
                                                       if (riskResultMap.containsKey(Label.UAC_testPicklistHepatitisB) && riskResultMap.get(Label.UAC_testPicklistHepatitisB)
                                                           == Label.UAC_testPicklistPositive && (!heptBSAntibodyCheck || !heptBCAntibodyCheck))
                                                           return false;
                                                       
                                                       // Check if there is at least one Risk-Based Lab Test entry where "Disease/Condition Tested" = Syphilis and "Result" = Positive (Reactive, Detected), then there must be at least one Confirmatory Lab test record entry with Disease Syphillis and conditions met.
                                                       if (riskResultMap.containsKey(Label.UAC_testPicklistSyphilis) && riskResultMap.get(Label.UAC_testPicklistSyphilis) == Label.UAC_testPicklistPositive
                                                           && !syphillisCheck)
                                                           return false;   
                                                       
                                                       // Check if there is at least one Risk-Based Lab Test entry where "Disease/Condition Tested" = HIV and "Result" = Positive (Reactive, Detected), then there must be at least one Confirmatory Lab test record and conditions met.
                                                       if (riskResultMap.containsKey(Label.UAC_testPicklistHIV)
                                                           && riskResultMap.get(Label.UAC_testPicklistHIV) == Label.UAC_testPicklistPositive && !HIVCheck)
                                                           return false;
                                                       
                                                       // Check if there is at least one Risk-Based Lab Test entry where "Disease/Condition Tested" = Acute/Chronic Hepatitis C and "Result" = Positive (Reactive, Detected), then there must be at least one Confirmatory Lab test record entry with Disease Acute/Chronic Hepatitis C and conditions met.
                                                       if (riskResultMap.containsKey(Label.UAC_testPicklistHepatitisC) 
                                                           && riskResultMap.get(Label.UAC_testPicklistHepatitisC) == Label.UAC_testPicklistPositive && !heptCHCVRNACheck)
                                                           return false;
                                                   } else {
                                                       return false;
                                                   }
                                               }
                                               
                                               return isValid;                                         
                                           }
										   
  /**
   * @description Method to validate Test of type PRID.
   * Used to validate Lab Test of Flow of type PRID
   * @author Manoj Bhagwat(Entellimetrix) | 07-30-2020 | Jira 1439
   * @param objSObject Current HealthEvaluation  record
   * @return SObject
   **/
  private
  static Boolean validatePridLabTest(
      List<UAC_test__c> testList, Map<String, String> testResultMap) {
    Boolean isValid = true;
    if (testList != null && testList.size() > 0) {
      for (UAC_test__c ut : testList) {
        if (ut.UAC_result__c == Label.UAC_testPicklistPending) {
          isValid = false;
        }
        testResultMap.put(ut.UAC_diseaseConditionTested__c, ut.UAC_result__c);
      }
    }
    return isValid;
  }
  /*****************End of Validate Lab Test methods ********************/

  /**
   * @description Method to update IME - TB Lab Testing Status value for TB Lab Testing Section.
   * @author Ranjith kumar (AI-Vets) | 07-29-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static Map<sObject, List<String>> validateTBLabTest(SObject objSObject) {
    Map<sObject, List<String>> mapObjErrors = new Map<sObject, List<String>>();
    Boolean isValid = true;
    String errorMsg = '';
    List<String> lstErrorMsgs = new List<String>();
    Decimal ageAtAdmission = 0;
    Integer positiveRecs = 0;
    // clang-format off
    Map<String, List<UAC_test__c>> mapRTUAC = new Map<String, List<UAC_test__c>>{
      Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder => new List<UAC_test__c>(),
      Label.UAC_testRecTypeTBScreeningUnder2YearsAge => new List<UAC_test__c>(),
      Label.UAC_testRecTypeImagingStudy => new List<UAC_test__c>(),
      Label.UAC_testRecTypeBacteriologicalResults => new List<UAC_test__c>()
    };
    List<UAC_test__c> lstTests = new List<UAC_test__c>();
    lstTests = [
      SELECT
        Id, UAC_result__c, UAC_associatedHealthEvaluation__r.UAC_ageAtAdmission__c,
        RecordType.DeveloperName
      FROM
        UAC_test__c
      WHERE
        UAC_associatedHealthEvaluation__c = :objSObject.Id
        AND RecordType.DeveloperName IN :mapRTUAC.keySet()
    ];
    // clang-format on
    if (lstTests.size() > 0) {
      ageAtAdmission = lstTests[0].UAC_associatedHealthEvaluation__r.UAC_ageAtAdmission__c;
      for (UAC_test__c uac : lstTests) {
        mapRTUAC.get(uac.RecordType.DeveloperName).add(uac);
      }
      if (ageAtAdmission >= 2) {
        if (mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder).size() > 0) {
          for (UAC_test__c u : mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder)) {
            if (u.UAC_result__c == Label.UAC_testPicklistPending) {
              isValid = false;
              lstErrorMsgs.add('UAC test screening 2 years older record has pending Result');
            }
            if (u.UAC_result__c == Label.UAC_resultPicklistPositive
                && mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() == 0) {

              isValid = false;
              positiveRecs++;
              lstErrorMsgs.add('UAC test screening 2 years older record has Positive Result');
            }
          }
        } else {
          isValid = false;
          lstErrorMsgs.add('No UAC test screening 2 years age or older records has been created');
        }
      }
      if (ageAtAdmission < 2) {
        if (mapRTUAC.get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge).size() > 0) {
          for (UAC_test__c u : mapRTUAC.get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge)) {
            if (u.UAC_result__c == Label.UAC_testPicklistPending) {
              isValid = false;
              lstErrorMsgs.add('UAC test screening under 2 years record has pending Result');
            }
            if (u.UAC_result__c == Label.UAC_resultPicklistPositive
                && mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() == 0) {
              isValid = false;
              positiveRecs++;
              lstErrorMsgs.add('UAC test screening under 2 years record has Positive Result');
            }
          }
        }
        if (mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder).size() > 0) {
          for (UAC_test__c u : mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder)) {
            if (u.UAC_result__c == Label.UAC_testPicklistPending) {
              isValid = false;
              lstErrorMsgs.add('UAC test screening 2 years older record has pending Result');
            }
            if (u.UAC_result__c == Label.UAC_resultPicklistPositive
                && mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() == 0) {
              isValid = false;
              positiveRecs++;
              lstErrorMsgs.add('UAC test screening 2 years older record has Positive Result');
            }
          }
        }
        if (mapRTUAC.get(Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder).size() == 0
            && mapRTUAC.get(Label.UAC_testRecTypeTBScreeningUnder2YearsAge).size() == 0) {
          isValid = false;
          lstErrorMsgs.add(
              'No UAC test screening under 2 years or 2 years age or older records has been created');
        }
      }
      if (ageAtAdmission >= 15) {
        if (mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() > 0) {
          for (UAC_test__c u : mapRTUAC.get(Label.UAC_testRecTypeImagingStudy)) {
            if (u.UAC_result__c == Label.UAC_testPicklistPending) {
              isValid = false;
              lstErrorMsgs.add(
                  'UAC test screening >=15 years Imaging study record has pending Result');
            }
          }
        } else {
          isValid = false;
          lstErrorMsgs.add('No Imaging Study record has been created for >= 15 years');
        }
      }
      if (ageAtAdmission < 15 && positiveRecs > 0) {
        if (mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() > 0) {
          for (UAC_test__c u : mapRTUAC.get(Label.UAC_testRecTypeImagingStudy)) {
            if (u.UAC_result__c == Label.UAC_testPicklistPending) {
              isValid = false;
              lstErrorMsgs.add(
                  'UAC test screening <15 years Imaging study record has pending Result');
            }
          }
        } else {
          isValid = false;
          lstErrorMsgs.add(
              'No Imaging Study record has been created for < 15 years and having positive record');
        }
      }
      if (mapRTUAC.get(Label.UAC_testRecTypeBacteriologicalResults).size() > 0) {
        for (UAC_test__c u : mapRTUAC.get(Label.UAC_testRecTypeBacteriologicalResults)) {
          if (u.UAC_result__c == Label.UAC_testPicklistPending) {
            isValid = false;
            lstErrorMsgs.add('UAC test screening Bacteriological has pending Result');
          }
        }
      }
      if (mapRTUAC.get(Label.UAC_testRecTypeImagingStudy).size() > 0) {
        for (UAC_test__c imaging : mapRTUAC.get(Label.UAC_testRecTypeImagingStudy)) {
          if (imaging.UAC_result__c == Label.UAC_testPicklistPending) {
            isValid = false;
            lstErrorMsgs.add(
                'UAC test screening >=15 years Imaging study record has pending Result');
          }
        }
      }
    } else {
      isValid = false;
      lstErrorMsgs.add('No Test record has been created');
    }
    if (isValid) {
      objSObject.put('UAC_TBLabTestingStatus__c', Label.UAC_tbLabTestingStatusComplete);
    } else {
      objSObject.put('UAC_TBLabTestingStatus__c', Label.UAC_tbLabTestingStatusInProgress);
    }
    // clang-format off
    return new Map<sObject, List<String>>{objSObject => lstErrorMsgs};
    // clang-format on
  }
  /***********************END of validateTBLabTest Method*******************************/

  /**
   * @description Method to update IME - Diagnosis and Plan Status value for Diagnosis and Plan
   *Section.
   * @author Anupreeta Chakraborty (Deloitte) | 08-11-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static SObject validateDiagnosisandPlan(SObject objSObject) {
    Boolean isValid = true;
    UAC_healthEvaluation__c objHE = (UAC_healthEvaluation__c) objSObject;
    List<UAC_healthEvaluation__c> lstHE = [select(select Id FROM Diagnoses__r),
      (select id from immunizations__r) from UAC_healthEvaluation__c where id =:objSObject.Id];
    if (objHE.UAC_diagnosesMedsReferrals__c == Label.UAC_Yes
        && !(lstHE[0].Diagnoses__r.size() > 0)) {
      // If "Minor with Complaints, Symptoms, Diagnoses/Conditions; Medications Prescribed
      // (including OTC); Referrals Made" = Yes then the user must enter at least one Diagnosis
      // entry
      isValid = false;
    }
    if (lstHE[0].Diagnoses__r.size() > 0) {
      List<UAC_diagnosis__c> lstDiagnosis = [select UAC_wdMedicationPrescribed__c,
        UAC_status__c,
        (select id from Medications__r)
            from UAC_diagnosis__c where UAC_associatedHealthEvaluation__c =:lstHE[0].id];
      for (UAC_diagnosis__c objDiagnosis : lstDiagnosis) {
        if (objDiagnosis.UAC_wdMedicationPrescribed__c == Label.UAC_Yes
            && !(objDiagnosis.Medications__r.size() > 0)) {
          // If any Diagnosis record listed in the diagnosis table on the IME has "Medications
          // Prescribed?" = Yes then the user must enter at least one Medication entry into the
          // Medications table associated to the same diagnosis
          isValid = false;
        }
        if (objDiagnosis.UAC_status__c == Label.UAC_diagnosisStatusWorking) {
          // All diagnoses records entered in the Diagnosis table should be in status not equal to
          // "Working"
          isValid = false;
        }
      }
    }
    if (objHE.UAC_immunizationsAdministered__c == Label.UAC_Yes
        && !(lstHE[0].immunizations__r.size() > 0)) {
      // If "Were Immunizations Administered as Part of Exam, Previously Administered while not in
      // ORR Custody and Validated by HCP, and/or Indicated, but not Given?" = Yes then the user
      // must enter at least one Immunization entry into the Immunization table
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
   * @description Method to update IME - Contact Tracing Status for Contact Tracing section
   * @author Karthi Subramanian (Deloitte) | 09-15-2020
   * @param objSObject SObject record to clean values
   * @return SObject
   **/
  public
  static SObject validateContactTracing(SObject objSObject) {
    Boolean isNotStarted = false;
    Boolean isInProgress = false;
    Boolean isComplete = false;
    Boolean isNotApplicable = false;

    map<String, Integer> phiStatusCountMap = new map<String, Integer>();

    // Get Exposure events associated with IME - Health Eval Record.
    List<AggregateResult> aggResultExpEvent = [SELECT count(Id) ExpEventcount,
      UAC_PHIStatus__c FROM UAC_exposureEvent__c WHERE UAC_associatedHealthEvaluation__c
      =:objSObject.Id group by UAC_PHIStatus__c];
    Integer intCount = 0;
    for (AggregateResult aggr : aggResultExpEvent) {
      phiStatusCountMap.put(
          (String) aggr.get('UAC_PHIStatus__c'), (Integer) aggr.get('ExpEventcount'));
      intCount = intCount + (Integer) aggr.get('ExpEventcount');
    }

    if (aggResultExpEvent != null && aggResultExpEvent.size() > 0) {

      // Check if all Exposure Events have a 'PHI Status' = Not Started.
      if (phiStatusCountMap.containskey(Label.UAC_PHIStatusNotStarted)) {
        if (phiStatusCountMap.get(Label.UAC_PHIStatusNotStarted) == intCount) {
          isNotStarted = true;
        }
      }
      // Check if all Exposure Events have a 'PHI Status' of "Complete"
      if (phiStatusCountMap.containskey(Label.UAC_PHIStatusComplete)) {
        if (phiStatusCountMap.get(Label.UAC_PHIStatusComplete) == intCount) {
          isComplete = true;
        }
      }
      // set status to In Progress if Not started and Complete equal to False
      if (!isNotStarted && !isComplete) {
        isInProgress = true;
      }

    } else {
      isNotApplicable = true;
    }

    if (isNotStarted) {
      objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusNotStarted);
    } else if (isInProgress) {
      objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusInProgress);
    } else if (isComplete) {
      objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusComplete);
    } else if (isNotApplicable) {
      objSObject.put('UAC_contactTracingStatus__c', Label.UAC_contactTracingStatusNotApplicable);
    }
    return objSObject;
  }

  /**
   * @description Request class to hold request data
   * Each @InvocableVariable defined in this class is an input variable you can populate when
   *calling this from  Flow
   * @author Sachet Khanal (Deloitte) | 07-15-2020
   * @Group             : UAC_flowUpdateIME
   **/
  public
  class Request {
    @InvocableVariable(required = true) public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String strSectionName;
  }

  /**
   * @description Response class to hold response data
   * Each @InvocableVariable defined in this class is an output variable and you can populate use it
   *in  Flow
   * @author Sachet Khanal (Deloitte) | 07-15-2020
   * @Group             : UAC_flowUpdateIME
   **/
  public class Response {
    @InvocableVariable public UAC_healthEvaluation__c objRecord;
    @InvocableVariable public String errorMessage;
  }
}