/**
 * @File Name         : UAC_testLabTestBuilder.cls
 * @Description       : Test builder class to build Allergy records for test instance
 * @Group             : UAC_testBuilder
 * @Author            : Manoj Bhagwat (Entellimatrix)
 * @Last Modified By  : Manoj Bhagwat (Entellimatrix)
 * @Last Modified On  : 07-29-2020
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   07-29-2020   Manoj Bhagwat (Entellimatrix)   Initial Version
 **/
 @isTest
 public class UAC_testLabTestBuilder {

  public
  String strDisease = Label.UAC_testPicklistHepatitisB;
  public
  String strTest = 'HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)';
  public
  String strResult = 'Positive (Reactive, Detected)';
  public
  String strSpecimen = 'Blood/Serum';
  public Decimal strBloodLevel;
  public
  String strRecordTypeId ;        
  public
  Id idHealthEvaluation;
  public
  Id idUAC;

  /**
   * @description Method to set associated Health Evaluation record
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @param idHealthEvaluation Id of health evaluation record
   * @return UAC_testLabTestBuilder
   */
    public UAC_testLabTestBuilder setUAC(Id idUAC) {
        this.idUAC = idUAC;
        return this;
    }
  public
  UAC_testLabTestBuilder setHealthEvaluation(Id idHealthEvaluation) {
    this.idHealthEvaluation = idHealthEvaluation;
    return this;
  }

  /**
   * @description Method to set associated UAC record
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @param idUAC Id of UAC contact record
   * @return UAC_testLabTestBuilder
   */

  /**
   * @description Method to set allergen name
   * @author Manoj Bhagwat (Entellimatrix)| 07-23-2020
   * @param strDisease String value for Disease
   * @return UAC_testLabTestBuilder
   */
  public
  UAC_testLabTestBuilder setDisease(String strDisease) {
    this.strDisease= strDisease;
    return this;
  }
  public
  UAC_testLabTestBuilder setBloodLevel(Decimal strBloodLevel) {
    this.strBloodLevel= strBloodLevel;
    return this;
  }
  /**
   * @description Method to set allergy type
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @param strTest String value for test
   * @return UAC_testLabTestBuilder
   */
  public
  UAC_testLabTestBuilder setTest(String strTest) {
    this.strTest = strTest;
    return this;
  }

  /**
   * @description Method to set allergy reaction
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @param strReaction String value for allergy reaction
   * @return UAC_testAllergyBuilder
*/
    public
        UAC_testLabTestBuilder setResult(String strResult) {
            this.strResult = strResult;
            return this;
        }
    public UAC_testLabTestBuilder setSpecimen(String strResult) {
        this.strSpecimen = strResult;
        return this;
    }
    /**
* @description Method to set allergy reaction
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @param strReaction String value for allergy reaction
   * @return UAC_testAllergyBuilder
   */
  public
  UAC_testLabTestBuilder setRecordType(String strRecordTypeId) {
    this.strRecordTypeId = strRecordTypeId;
    return this;
  }
  /**
   * @description Method to build shell record for Allergy
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @return UAC_test__c
   */
  public
  UAC_test__c build() {
    return new UAC_test__c(UAC_associatedHealthEvaluation__c = idHealthEvaluation,
        UAC_associatedUAC__c=idUAC,
        UAC_diseaseConditionTested__c = strDisease,
        RecordTypeId = strRecordTypeId,
        UAC_result__c = strResult,
        UAC_specimenCollectionDate__c=System.today()-5,
        UAC_specimenSource__c=strSpecimen,
        UAC_test__c = strTest);
  }
  public
  UAC_test__c buildFlu () {
    return new UAC_test__c(UAC_associatedHealthEvaluation__c = idHealthEvaluation,
        UAC_associatedUAC__c=idUAC,
        UAC_diseaseConditionTested__c = strDisease,
        RecordTypeId = strRecordTypeId,
        UAC_result__c = strResult,
        UAC_specimenCollectionDate__c=System.today()-5,
        UAC_influenzaType__c =  'Type A',
        UAC_specimenSource__c=strSpecimen,
        UAC_test__c = strTest);
  }
      public
  UAC_test__c buildLead() {
    return new UAC_test__c(UAC_associatedHealthEvaluation__c = idHealthEvaluation,
        UAC_associatedUAC__c=idUAC,
        UAC_diseaseConditionTested__c = strDisease,
        RecordTypeId = strRecordTypeId,
        UAC_result__c = strResult,
        UAC_specimenCollectionDate__c=System.today()-5,
        UAC_bloodLeadLevelMCGDL__c=strBloodLevel,
        UAC_specimenSource__c=strSpecimen,
        UAC_test__c = strTest);
  }
  /**
   * @description Method to create Allergy record
   * @author Manoj Bhagwat (Entellimatrix) | 07-23-2020
   * @return UAC_test__c
   */
    public List<UAC_test__c> buildAndSave() {
        List<UAC_test__c> objListTest = new List<UAC_test__c>();
        this.setRecordType(UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeRiskBasedLabTest, 'UAC_test__c') );
        String dis = 'HIV , Pregnancy , Lead (Positive >= 5 mcg/ dl) , Chlamydia , Gonorrhea , Syphilis , Acute/Chronic Hepatitis B , Acute/Chronic Hepatitis C , Influenza (Flu), Rapid , Strep, Rapid';
        //Label.UAC_testLabTestRiskDiseases;
        List<String> validValues = dis.split(' , ');
        Boolean buildTest=false;
        for (String vv:validValues){            
            this.setDisease(vv); 
            this.setSpecimen('Blood/Serum');
            this.setTest('HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)');
            if(vv=='Pregnancy'){
                this.setTest('hCG');   
            }
            if(vv=='Lead (Positive >= 5 mcg/ dl)'){
                this.setBloodLevel(8.0);
                this.setTest('Lead Level');
                objListTest.add(this.buildLead());
                continue;
            }
            if(vv=='Influenza (Flu), Rapid'){
                this.setSpecimen('Nasopharyngeal (NP)/Throat');
                this.setTest('Rapid Antigen Detection'); 
                objListTest.add(this.buildFlu());
                continue;                
            } 
            if(vv=='Strep, Rapid'){
                this.setSpecimen('Nasopharyngeal (NP)/Throat');
                this.setTest('Rapid Antigen Detection');               
            } 
            objListTest.add(this.build());
        }
        insert objListTest;
        objListTest.clear();
        
        this.setRecordType(UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypeConfirmatoryLabTest, 'UAC_test__c') );
        this.setDisease(Label.UAC_testPicklistHepatitisB);
        this.setTest(Label.UAC_testPicklistCoreAntiBody);
        this.setResult('Positive (Reactive, Detected)');
        this.setSpecimen('Blood/Serum');
        UAC_test__c t1= this.build();
        objListTest.add(t1);
        this.setDisease(Label.UAC_testPicklistSyphilis);
        this.setTest(Label.UAC_testPicklistTreponemal);
        objListTest.add(this.build());
        this.setDisease(Label.UAC_testPicklistHIV);
        this.setTest(Label.UAC_testPicklistCombImmnasy);
        objListTest.add(this.build());    
        this.setDisease(Label.UAC_testPicklistHepatitisC);
        this.setTest(Label.UAC_testPicklistHCVRNA);
        this.setResult('Positive (Reactive, Detected)');
        objListTest.add(this.build());    
        this.setRecordType(UAC_TestUtility.getRecordTypeIdByDevName(Label.UAC_testRecTypePRIDLabTest, 'UAC_test__c') );        
        this.setTest('HIV 1/2 Antigen/Antibody Combination Immunoassay (Fourth Generation Test)');
        this.setSpecimen('Blood/Serum');
        objListTest.add(this.build());  
        insert objListTest;
        
        return objListTest;
    }
    
    
    /**
   * @description Method to create Tb Test record
   * @author Ranjith kumar (AI-Vets) | 07-31-2020
   * @return UAC_test__c
   */
  public static UAC_test__c uacTbTestRecord(String recDevName, String status, String healthEvalId,String UACId) {
    String recTypeId = Schema.SObjectType.UAC_test__c.getRecordTypeInfosByDeveloperName().get(recDevName).getRecordTypeId();
    UAC_test__c uacTest = new UAC_test__c(UAC_result__c=status,
                                          RecordTypeId=recTypeId,
                                          UAC_associatedHealthEvaluation__c=healthEvalId,
                                          UAC_diseaseConditionTested__c='Tuberculosis',
                                          UAC_associatedUAC__c =UACId,
                                          UAC_testType__c='QuantiFERON',
                                          UAC_specimenSource__c='Tissue',
                                          UAC_specimenCollectionDate__c = System.today()-10
                                         );
    if(recDevName == Label.UAC_testRecTypeTBScreening2YearsAgeAndOlder) {
        uacTest.UAC_test__c = Label.UAC_testPicklistTBBloodTest;
    }else if(recDevName == Label.UAC_testRecTypeTBScreeningUnder2YearsAge) {
        uacTest.UAC_test__c = Label.UAC_testPicklistPPDTST;
        uacTest.UAC_datePerformed__c = System.today()-6;      
        uacTest.UAC_specimenSource__c='Tissue';
        uacTest.UAC_dateRead__c = System.today()-4;
            if(status=='Pending'){
                uacTest.UAC_reactionInMM__c = 6;
            }else{
            uacTest.UAC_reactionInMM__c = 12;
            }
    }else if(recDevName == Label.UAC_testRecTypeImagingStudy) {
        uacTest.UAC_test__c = 'MRI';
        uacTest.UAC_datePerformed__c = System.today()-6;
    }else if(recDevName == Label.UAC_testRecTypeBacteriologicalResults) {
        uacTest.UAC_test__c = 'TB Culture';
    }
    return uacTest;
 }  
}