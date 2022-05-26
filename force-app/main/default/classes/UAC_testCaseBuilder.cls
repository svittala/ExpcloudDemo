/**
 * @File Name          : UAC_testCaseBuilder.cls
 * @Description        : Test builder class to create Case record for test instance
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 6/3/2020, 5:25:45 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/15/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_testCaseBuilder {
  private
  Id idSponsor;
  private
  Id idUAC;
  private
  Id idRelationshipToUAC;
  private
  String strRecordTypeDeveloperName = Label.UAC_caseRecordTypeApiNameSponsorApplication;
  private
  String strStatus = 'Open';

  /**
   * @description Method to set Sponsor Id on Case
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @param idSponsor Id of Sponsor contact
   * @return UAC_testCaseBuilder
   **/
  public
  UAC_testCaseBuilder setSponsor(Id idSponsor) {
    this.idSponsor = idSponsor;
    return this;
  }

  /**
   * @description Method to set Relationship to UAC field
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @param idRelationshipToUAC Id of Adult Contact Relationship
   * @return UAC_testCaseBuilder
   **/
  public
  UAC_testCaseBuilder setRelationshipToUAC(Id idRelationshipToUAC) {
    this.idRelationshipToUAC = idRelationshipToUAC;
    return this;
  }

  /**
   * @description Method to set UAC Id on Case
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @param idUAC Id of UAC contact
   * @return UAC_testCaseBuilder
   **/
  public
  UAC_testCaseBuilder setUAC(Id idUAC) {
    this.idUAC = idUAC;
    return this;
  }

  /**
   * @description Method to set Record Type Developer Name for Case
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @param strRecordTypeDeveloperName String value of Record Type developer name
   * @return UAC_testCaseBuilder
   **/
  public
  UAC_testCaseBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
    this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
    return this;
  }

  /**
   * @description Method to set Case status
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @param strStatus String value of status
   * @return UAC_testCaseBuilder
   **/
  public
  UAC_testCaseBuilder setStatus(String strStatus) {
    this.strStatus = strStatus;
    return this;
  }

  /**
   * @description Method to build and return Case object
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @return Case
   **/
  public
  Case build() {
    Id idRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                          .get(this.strRecordTypeDeveloperName)
                          .getRecordTypeId();
    Id idReleaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.UAC_CaseRecordTypeReleaseRequest).getRecordTypeId();                      
    Case objCase = new Case(RecordTypeId = idRecordType,
        ContactId = this.idUAC,
        UAC_sponsor__c = this.idSponsor,
        UAC_relationshipToUAC__c = this.idRelationshipToUAC,
        Status = this.strStatus);
    objCase.UAC_referringSectorName__c = 'Test';
    objCase.UAC_referringSectorCode__c = '1';
    objCase.UAC_referralDatetime__c = System.Now().addDays(-1);
    objCase.UAC_apprehensionDatetime__c = System.Now().addDays(-2);
    if(idRecordType == idReleaseRecType){
      objCase.UAC_remandForFurtherInformation__c = 'Yes';
      objCase.UAC_orrComment__c = 'Test101';
    }    
    return objCase;
  }

  /**
   * @description Method to create and return a new Case record
   * @author Sachet Khanal (Deloitte) | 5/15/2020
   * @return Case
   **/
  public
  Case buildAndSave() {
    Id idRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                          .get(this.strRecordTypeDeveloperName)
                          .getRecordTypeId();
    Case objCase = this.build();
    insert objCase;
    return objCase;
  }
}