/**
 * @File Name         : UC_testMonitoringScheduleBuilder.cls
 * @Description       : Test builder class to build Monitoring Schedule records for test instance
 * @Group             : UC_testMonitoringScheduleBuilder
 * @Author            : Chase Oden (Deloitte)
 * @Last Modified By  : Chase Oden (Deloitte)
 * @Last Modified On  : 07/26/2021
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07/26/2021   Chase Oden (Deloitte)   Initial Version
 **/
@isTest 
public with sharing class UC_testMonitoringScheduleBuilder {
    public
    String strFiscalYear = '2000';

  
    /**
     * @description Method to build shell record for Monitoring Schedule
     * @author Chase Oden (Deloitte) | 07/26/2021
     * @return UAC_monitoringSchedule__c
     */
    public
    UAC_monitoringSchedule__c build() {
        return new UAC_monitoringSchedule__c(UAC_fiscalYear__c = strFiscalYear);
    }
  
    /**
     * @description Method to create Monitoring Schedule record
     * @author Chase Oden (Deloitte) | 07/26/2021
     * @return UAC_monitoringSchedule__c
     */
    public
    UAC_monitoringSchedule__c buildAndSave() {
        UAC_monitoringSchedule__c objMonitoringSchedule = this.build();
        insert objMonitoringSchedule;
        return objMonitoringSchedule;
    }
      
}