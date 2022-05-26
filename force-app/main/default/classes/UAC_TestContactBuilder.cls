/**
 * @File Name          : UAC_TestContactBuilder.cls
 * @Description        : Builder class for creating Contact record for unit test.
 * @Author             : Sachet Khanal (Deloitte)
 * @Group              : UAC_TestBuilder
 * @Last Modified By   : Sachet Khanal (Deloitte)
 * @Last Modified On   : 5/12/2020, 10:56:41 AM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   Sachet Khanal (Deloitte)     Initial Version
 **/
@isTest public class UAC_TestContactBuilder {
  private
  String strRecordTypeDeveloperName = Label.UAC_contactRecordTypeApiNameUAC;
  private
  String strFirstName = 'TestContactFirstName';
  private
  String strLastName = 'TestContactLastName';
  private
  String strEmail = 'test-contact@example.invalid';
  private
  String strPhone = '000-000-0000';
  private
  String strANum = '';
  private
  String strRelatedANum = '';
  private
  String strRelatedToOtherUAC = '';
  private
  String strGender = 'Female';
  private
  Date dateBirthdate = System.Today().addDays(-5500);

  /**
   * @description Method to set Contact FirstName
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param strFirstName Value of first name
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setRecordTypeDeveloperName(String strRecordTypeDeveloperName) {
    this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
    return this;
  }

  /**
   * @description Method to set Contact FirstName
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param strFirstName Value of first name
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setFirstName(String strFirstName) {
    this.strFirstName = strFirstName;
    return this;
  }

  /**
   * @description Method to set Contact LastName
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param strLastName Value of last name
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setLastName(String strLastName) {
    this.strLastName = strLastName;
    return this;
  }

  /**
   * @description Method to set Contact A Number
   * @author James Qian (Deloitte) | 5/13/2020
   * @param strANum Value of A Number
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setANumber(String strANum) {
    this.strANum = strANum;
    return this;
  }

  /**
   * @description Method to set Related Contact A Number
   * @author James Qian (Deloitte) | 5/13/2020
   * @param strRelatedANum Value of Related A Number
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setRelatedANum(String strRelatedANum) {
    this.strRelatedANum = strRelatedANum;
    return this;
  }

  /**
   * @description Method to set Related To Other UAC
   * @author James Qian (Deloitte) | 5/13/2020
   * @param strRelatedToOtherUAC Value of Related To UAC
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setRelatedToOtherUAC(String strRelatedToOtherUAC) {
    this.strRelatedToOtherUAC = strRelatedToOtherUAC;
    return this;
  }

  /**
   * @description Method to set Contact Gender
   * @author James Qian (Deloitte) | 5/13/2020
   * @param strGender Value of Gender
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setGender(String strGender) {
    this.strGender = strGender;
    return this;
  }

  /**
   * @description Method to set Contact Email
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param strEmail Value of email
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setEmail(String strEmail) {
    this.strEmail = strEmail;
    return this;
  }

  /**
   * @description Method to set Contact Phone
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param strPhone Value of email
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setPhone(String strPhone) {
    this.strPhone = strPhone;
    return this;
  }

  /**
   * @description Method to set Contact DOB
   * @author James Qian (Deloitte) | 3/17/2021
   * @param dob Value of DOB
   * @return UAC_TestContactBuilder
   **/
  public
  UAC_TestContactBuilder setBirthDate(Date dob) {
    this.dateBirthdate = dob;
    return this;
  }

  /**
   * @description Method to build a new Contact object
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return Contact
   **/
  public
  Contact build() {
    Id idRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                          .get(strRecordTypeDeveloperName)
                          .getRecordTypeId();
    Contact objContact = new Contact(RecordTypeId = idRecordType,
        FirstName = this.strFirstName,
        LastName = this.strLastName,
        Email = this.strEmail,
        Phone = this.strPhone,
        UAC_gender__c = this.strGender,
        Birthdate = this.dateBirthdate);
    if (String.isNotBlank(this.strANum)) {
      objContact.UAC_A__c = this.strANum;
    }
    if (String.isNotBlank(this.strRelatedANum)) {
      objContact.UAC_relatedUACA__c = this.strRelatedANum;
    }
    if (String.isNotBlank(this.strRelatedToOtherUAC)) {
      objContact.UAC_relatedToOtherUAC__c = this.strRelatedToOtherUAC;
    }
    return objContact;
  }

  /**
   * @description Method to create and return a new Contact record
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @return Contact
   **/
  public
  Contact buildAndSave() {
    Contact objContact = this.build();
    insert objContact;
    return objContact;
  }

  /**
   * @description Method to query a contact record by A Number
   * @author James Qian (Deloitte) | 5/13/2020
   * @param strANumber Value of A Number used for filtering
   * @param setFieldsToQuery Set of fields to query
   * @return Contact
   **/
  public
  static Contact getContactByANumber(String strANumber, Set<String> setFieldsToQuery) {
    setFieldsToQuery.add('Id');
    // clang-format off
    return Database.query(
      'SELECT ' + String.join(new List<String> (setFieldsToQuery), ',') +
      ' FROM Contact' +
      ' WHERE UAC_A__c = :strANumber' +
      ' LIMIT 1'
    );
    // clang-format on
  }

  /**
   * @description Method to query a contact record
   * @author Sachet Khanal (Deloitte) | 5/8/2020
   * @param setFieldsToQuery Set of fields to query
   * @return Contact
   **/
  public
  static Contact getContact(Set<String> setFieldsToQuery) {
    setFieldsToQuery.add('Id');
    // clang-format off
    return Database.query(
      'SELECT ' + String.join(new List<String> (setFieldsToQuery), ',') +
      ' FROM Contact' +
      ' LIMIT 1'
    );
    // clang-format on
  }
}