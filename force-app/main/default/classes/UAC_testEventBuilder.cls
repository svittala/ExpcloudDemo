/**
 * @File Name         :
 * @Description       :
 * @Group             :
 * @Test Class        :
 * @Author            :
 * @Last Modified By  : Sachet Khanal (Deloitte)
 * @Last Modified On  : 11-03-2020
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-02-2020   Sachet Khanal (Deloitte)   Initial Version
 * 2.0   7/16/2021    Nithin Malla (Deloitte)    Exclusion Logic updates.
 **/
@isTest public class UAC_testEventBuilder {
  String strRecordTypeDeveloperName = Label.UAC_eventRecTypeMentalHealthGroupEvent;
  DateTime dtEventStart = System.now();
  String strEventType = 'Community Meeting';

  /**
   * @description Method to set Event record type developer name
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   * @param strRecordTypeName String value for Developer Name of Record Type
   * @return UAC_testEventBuilder
   **/
  public
  UAC_testEventBuilder setRecordTypeDeveloperName(String strRecordTypeName) {
    this.strRecordTypeDeveloperName = strRecordTypeDeveloperName;
    return this;
  }

  /**
   * @description Method to set Event Type
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   * @param strEventType String value for Event Type
   * @return UAC_testEventBuilder
   **/
  public
  UAC_testEventBuilder setEventType(String strEventType) {
    this.strEventType = strEventType;
    return this;
  }

  /**
   * @description Method to set Event start date/time
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   * @param dtEventStart DateTime Start Date/Time of event
   * @return UAC_testEventBuilder
   **/
  public
  UAC_testEventBuilder setEventStartDateTime(DateTime dtEventStart) {
    this.dtEventStart = dtEventStart;
    return this;
  }

  /**
   * @description Method to build new UAC_event__c shell record
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   * @return UAC_event__c
   **/
  public
  UAC_event__c build() {
    UAC_event__c objEvent = new UAC_event__c();
    objEvent.RecordTypeId = Schema.SObjectType.UAC_event__c.getRecordTypeInfosByDeveloperName()
                                .get(this.strRecordTypeDeveloperName)
                                .getRecordTypeId();
    objEvent.UAC_eventStartDateTime__c = this.dtEventStart;
    objEvent.UAC_eventType__c = this.strEventType;
    return objEvent;
  }

  /**
   * @description Method to create and return new UAC_event__c record
   * @author Sachet Khanal (Deloitte) | 10-02-2020
   * @return UAC_event__c
   **/
  public
  UAC_event__c buildAndSave(Account program) {
    UAC_event__c objEvent = this.build();
    objEvent.UAC_programID__c = program.Id;
    insert objEvent;
    return objEvent;
  }
}