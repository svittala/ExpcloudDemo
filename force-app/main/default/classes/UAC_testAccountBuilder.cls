/**
 * @File Name          : UAC_testAccountBuilder.cls
 * @Description        : Test builder class to build Account object to use for test instance
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_testBuilder
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/29/2020, 2:24:47 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/29/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_testAccountBuilder {
  private
  String strName = 'Test Account';
  private
  String strRecordTypeDeveloperName = Label.UAC_accountRecordTypeApiNameAdministrativeAccount;
  private
  String strType;
  private
  String strStreet = '123 Test Street';
  private
  String strZip = '85297';
  private
  String strCity = 'Gilbert';
  private
  String strState = 'Arizona';
  private
  String strCountry = 'United States';
  private
  String strAcceptablePlacements = 'Near Hospital';
  private
  Integer intMaleBeds = 0;
  private
  Integer intFemaleBeds = 0;
  private
  String strProgramStatus = 'Active';
  private
  String strTextName = 'Test User';
  private
  String strPhone = '123456789';
  private
  String strEmail = 'Test@company.com';

  /**
   * @description Method to set account name
   * @param  strName String value for account name
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setName(String strName) {
    this.strName = strName;
    return this;
  }

  /**
   * @description Method to set account record type developer name
   * @param  strName String value for account name
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
    this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
    return this;
  }

  /**
   * @description Method to set account type
   * @param  strType String value for account type
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setType(String strType) {
    this.strType = strType;
    return this;
  }

  /**
   * @description Method to set account city
   * @param  strCity String value for account city
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setCity(String strCity) {
    this.strCity = strCity;
    return this;
  }

  /**
   * @description Method to set account street
   * @param  strStreet String value for account street
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setStreet(String strStreet) {
    this.strStreet = strStreet;
    return this;
  }

  /**
   * @description Method to set account zip
   * @param  strZip String value for account zip
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setZip(String strZip) {
    this.strZip = strZip;
    return this;
  }

  /**
   * @description Method to set account state
   * @param  strState String value for account state
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setState(String strState) {
    this.strState = strState;
    return this;
  }

  /**
   * @description Method to set account country
   * @param  strCountry String value for account country
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setCountry(String strCountry) {
    this.strCountry = strCountry;
    return this;
  }

  /**
   * @description Method to set account status
   * @param  strProgramStatus String value for account status
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setStatus(String strProgramStatus) {
    this.strProgramStatus = strProgramStatus;
    return this;
  }

  /**
   * @description Method to set acceptable placements
   * @param  strAcceptablePlacements String value for acceptable placements
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setAcceptablePlacements(String strAcceptablePlacements) {
    this.strAcceptablePlacements = strAcceptablePlacements;
    return this;
  }

  /**
   * @description Method to set male beds
   * @param  intMaleBeds Integer value for male beds
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setMaleBeds(Integer intMaleBeds) {
    this.intMaleBeds = intMaleBeds;
    return this;
  }

  /**
   * @description Method to set female beds
   * @param  intFemaleBeds Integer value for female beds
   * @return UAC_testAccountBuilder
   */
  public
  UAC_testAccountBuilder setFemaleBeds(Integer intFemaleBeds) {
    this.intFemaleBeds = intFemaleBeds;
    return this;
  }

  public
  Account build() {
    Id idRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                          .get(strRecordTypeDeveloperName)
                          .getRecordTypeId();
    Account objAccount = new Account(Name = strName, RecordTypeId = idRecordType);
    if (String.isNotBlank(strType)) {
      objAccount.Type = strType;
    }

    date dtStartDate = system.today().AddDays(-1);
    date dtEndDate = system.today().AddDays(1);

    objAccount.ShippingStreet = strStreet;
    objAccount.ShippingPostalCode = strZip;
    objAccount.ShippingCity = strCity;
    objAccount.ShippingState = strState;
    objAccount.ShippingCountry = strCountry;
    objAccount.UAC_acceptablePlacements__c = strAcceptablePlacements;
    objAccount.UAC_bedCountAvailableMale__c = intMaleBeds;
    objAccount.UAC_bedCountAvailableFemale__c = intFemaleBeds;
    objAccount.UAC_programStatus__c = strProgramStatus;
    objAccount.UAC_Copy_of_Lease_Uploaded__c = true;
    objAccount.UAC_licensed__c = 'No';
    objAccount.UAC_bedCountAvailableMale__c = 1;
    objAccount.UAC_programContact__c = strTextName;
    objAccount.UAC_programEmail__c = strEmail;
    objAccount.phone = strPhone;
    objAccount.UAC_Current_Grant_Budget_Start_Date__c = dtStartDate;
    objAccount.UAC_Current_Grant_Budget_End_Date__c = dtEndDate;
    objAccount.UAC_Current_Grant_Project_Start_Date__c = dtStartDate;
    objAccount.UAC_Current_Grant_Project_End_Date__c = dtEndDate;
    objAccount.UAC_Grant_Number__c = '8';
    objAccount.UAC_Initial_Grant_Award_Date__c = dtStartDate;
    objAccount.UAC_licensed__c = 'Yes';
    objAccount.UAC_License_Issued_Date__c = dtStartDate;
    objAccount.UAC_Licensing_POC__c = strTextName;
    objAccount.UAC_Licensing_POC_Email__c = strEmail;
    objAccount.UAC_Licensing_POC_Phone__c = strPhone;
    objAccount.UAC_IntakesPrimaryContact__c = strTextName;
    objAccount.UAC_IntakesPrimaryContactEmail__c = strEmail;
    objAccount.UAC_IntakesPrimaryContactPhone__c = strPhone;
    objAccount.UAC_fundedCapacity__c =
        objAccount.UAC_bedCountAvailableMale__c + objAccount.UAC_bedCountAvailableFemale__c;
    objAccount.UC_activeInPath__c = true;
    return objAccount;
  }

  public
  Account buildAndSave() {
    Account objAccount = this.build();
    insert objAccount;
    return objAccount;
  }
}