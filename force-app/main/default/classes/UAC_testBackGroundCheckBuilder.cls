/**
 * @File Name          : UAC_testBackGroundCheckBuilder.cls
 * @Description        : Builder class for creating Background Check record for unit test.
 * @Author             : Karthi Subramanian (Deloitte)
 * @Group              : UAC_TestBuilder
 * @Last Modified By   : Karthi Subramanian (Deloitte)
 * @Last Modified On   : 6/8/2020, 11:38:41 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    6/8/2020   Karthi Subramanian (Deloitte)     Initial Version
 **/
@isTest public class UAC_testBackGroundCheckBuilder {
    private
    Boolean booleanCheckRequired = false;
    private
    String strFormat = 'ORR Digital Site';
    private
    String strResults;
    private
    String strBackGroundChkType = 'FBI Criminal History';
    private
    Boolean booleanSystemGeneratedRec = true;



    /**
     * @description Method to set CheckRequired
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @param booleanCheckRequired Value of CheckRequired
     * @return UAC_testBackGroundCheckBuilder
     **/
    public
    UAC_testBackGroundCheckBuilder setbooleanCheckRequired(Boolean booleanCheckRequired) {
      this.booleanCheckRequired = booleanCheckRequired;
      return this;
    }

    /**
     * @description Method to set Format
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @param strFormat Value of strFormat
     * @return UAC_testBackGroundCheckBuilder
     **/
    public
    UAC_testBackGroundCheckBuilder setFormat(String strFormat) {
      this.strFormat = strFormat;
      return this;
    }
  
    /**
     * @description Method to set Results
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @param strResults Value of strResults
     * @return UAC_testBackGroundCheckBuilder
     **/
    public
    UAC_testBackGroundCheckBuilder setResults(String strResults) {
      this.strResults = strResults;
      return this;
    }

    /**
     * @description Method to set Background Check Type
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @param strBackGroundChkType Value of strBackGroundChkType
     * @return UAC_testBackGroundCheckBuilder
     **/
    public
    UAC_testBackGroundCheckBuilder setBackGroundChkType(String strBackGroundChkType) {
      this.strBackGroundChkType = strBackGroundChkType;
      return this;
    }

    /**
     * @description Method to set SystemGenerated Record
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @param booleanSystemGeneratedRec Value of booleanSystemGeneratedRec
     * @return UAC_testBackGroundCheckBuilder
     **/
    public
    UAC_testBackGroundCheckBuilder SetSystemGeneratedRec(Boolean booleanSystemGeneratedRec) {
      this.booleanSystemGeneratedRec = booleanSystemGeneratedRec;
      return this;
    }
  
    /**
     * @description Method to build a new BackGround Check object
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @return UAC_backgroundCheck__c
     **/
    public
    UAC_backgroundCheck__c build() {
        UAC_backgroundCheck__c objBackGroundCheck = new UAC_backgroundCheck__c(
          UAC_format__c = this.strFormat,
          UAC_results__c = this.strResults,
          UAC_checkRequired__c = this.booleanCheckRequired,
          UAC_backgroundCheckType__c = this.strBackGroundChkType,
          UAC_systemGeneratedRec__c=this.booleanSystemGeneratedRec);
      return objBackGroundCheck;
    }
  
    /**
     * @description Method to create and return a new Background Check Record
     * @author Karthi Subramanian (Deloitte) | 6/8/2020
     * @return UAC_backgroundCheck__c
     **/
    public
    UAC_backgroundCheck__c buildAndSave(Contact adultContact, Case sponsorAppCase, boolean SystemGeneratedRec) {
      UAC_backgroundCheck__c objBackGroundCheck = this.build();
      objBackGroundCheck.UAC_adultContact__c=adultContact.Id;
      objBackGroundCheck.UAC_sponsorApplication__c=sponsorAppCase.Id;
      objBackGroundCheck.UAC_systemGeneratedRec__c=SystemGeneratedRec;
      insert objBackGroundCheck;
      return objBackGroundCheck;
    }
    /**
     * @description Method to create and return a new Background Check Record
     * @author Karthi Subramanian (Deloitte) | 6/9/2020
     * @return UAC_backgroundCheck__c
     **/
    public
    UAC_backgroundCheck__c buildAndSave(Id adultContactId, Id sponsorCaseId, boolean SystemGeneratedRec,string results,string backgroundchkType) {
      UAC_backgroundCheck__c objBackGroundCheck = this.build();
      objBackGroundCheck.UAC_adultContact__c=adultContactId;
      objBackGroundCheck.UAC_sponsorApplication__c=sponsorCaseId;
      objBackGroundCheck.UAC_systemGeneratedRec__c=SystemGeneratedRec;
      objBackGroundCheck.UAC_results__c=results; 
      objBackGroundCheck.UAC_backgroundCheckType__c=backgroundchkType;
      insert objBackGroundCheck;
      return objBackGroundCheck;
    }
    /**
     * @description Method to create and return a new Background Check Record
     * @author Karthi Subramanian (Deloitte) | 6/9/2020
     * @return UAC_backgroundCheck__c
     **/
    public
    UAC_backgroundCheck__c buildAndSave(Id adultContactId, Id sponsorCaseId, boolean SystemGeneratedRec) {
      UAC_backgroundCheck__c objBackGroundCheck = this.build();
      objBackGroundCheck.UAC_adultContact__c=adultContactId;
      objBackGroundCheck.UAC_sponsorApplication__c=sponsorCaseId;
      objBackGroundCheck.UAC_systemGeneratedRec__c=SystemGeneratedRec;
      insert objBackGroundCheck;
      return objBackGroundCheck;
    }


}