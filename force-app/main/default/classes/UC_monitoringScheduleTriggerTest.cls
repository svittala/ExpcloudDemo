/**
 * @File Name          : UC_monitoringScheduleTriggerTest.cls
 * @Description        : Provides test class coverage for Monitoring Schedule Trigger
 * @Author             : Chase Oden (Deloitte)
 * @Group              : UAC_test
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    07/26/2021   Chase Oden (Deloitte)     Initial Implementation.
 **/
@isTest public with sharing class UC_monitoringScheduleTriggerTest {
    // private
    // static final String STR_A_NUM_UAC = '123456';
    private
    static final String STRING_ASSERT_MS_COUNT = 'The Monitoring Schedule count does not match as expected.';
  
    /**
     * @description Sets up test data.
     */
    @TestSetup static void setupTestData() {
      // Instantiate new monitoring schedule
      UAC_MonitoringSchedule__c objMonitoringSchedule =
          new UC_testMonitoringScheduleBuilder()
        //   // Set record type to Monitoring Schedule
        //   .setRecordTypeDeveloperName(System.Label.)
          // Build object, then insert
          .buildAndSave();
    }
    
    /**
     * @description Tests positive case for creating UAC_monitoringSchedule__c record.
     */
    @isTest static void insertShouldSucceed() {
        // Acquire a baseline for how many UAC_monitoringSchedule__c objects exist in the database
        Integer intMonitoringScheduleRecordCount = [
                // clang-format off
                SELECT
                  count()
                FROM
                    UAC_monitoringSchedule__c
                // clang-format on
                ];

        // Begin test actions
        Test.startTest();
        // Build and insert a new Monitoring Schedule record
        UAC_monitoringSchedule__c objNewMonitoringRecord =
            new UC_testMonitoringScheduleBuilder().build();
        objNewMonitoringRecord.UAC_fiscalYear__c = '9999';
        insert objNewMonitoringRecord;
        Test.stopTest();
        // Assert changes in object result in expected behavior
        Integer intNewMonitoringScheduleRecordCount = [
                    // clang-format off
                    SELECT
                        count()
                    FROM
                        UAC_monitoringSchedule__c
                    // clang-format on
                    ];
        // Assert that a new record was successfully created and added
        System.assertEquals(
            intMonitoringScheduleRecordCount + 1,
            intNewMonitoringScheduleRecordCount,
            STRING_ASSERT_MS_COUNT
        );
    }
    
    /**
     * @description Tests positive case for updating UAC_monitoringSchedule__c record.
     */
    @isTest static void updateShouldSucceed() {
        // Get object
        UAC_monitoringSchedule__c objMonitoringShedule = getMonitoringSchedule();

        // Begin test actions
        Test.startTest();
        // Change fiscal year to 2001
        objMonitoringShedule.UAC_fiscalYear__c = '2001';
        update objMonitoringShedule;
        Test.stopTest();

        // Reacquire the object from the database
        objMonitoringShedule = getMonitoringSchedule();
        // Assert changes in object result in expected behavior
        System.assertEquals('2001', objMonitoringShedule.UAC_fiscalYear__c, 'Could not update value of UAC_fiscalYear__c');
    }
    
    /**
     * @description Tests positive case for deleting UAC_monitoringSchedule__c records.
     */
    @isTest static void deleteShouldSucceed() {
        // Get object
        UAC_monitoringSchedule__c objMonitoringSchedule = getMonitoringSchedule();

        // Acquire a baseline for how many UAC_monitoringSchedule__c objects exist in the database
        Integer intMonitoringScheduleRecordCount = [
                // clang-format off
                SELECT
                  count()
                FROM
                    UAC_monitoringSchedule__c
                // clang-format on
                ];

        // Begin test actions
        Test.startTest();
        // Delete a Monitoring Schedule record
        delete objMonitoringSchedule;
        Test.stopTest();
        // Assert changes in object result in expected behavior
        Integer intNewMonitoringScheduleRecordCount = [
                    // clang-format off
                    SELECT
                        count()
                    FROM
                        UAC_monitoringSchedule__c
                    // clang-format on
                    ];
        // Assert that a new record was successfully created and added
        System.assertEquals(
            intMonitoringScheduleRecordCount - 1,
            intNewMonitoringScheduleRecordCount,
            STRING_ASSERT_MS_COUNT
        );
    }
  
    /**
     * @description Queries UAC_monitoringSchedule__c for test data insertion and assertions.
     * @return UAC_monitoringSchedule__c
     */
    private static UAC_monitoringSchedule__c getMonitoringSchedule() {
      return [
        // clang-format off
          SELECT
            Id,
            UAC_fiscalYear__c
          FROM
            UAC_monitoringSchedule__c
          LIMIT 1
        // clang-format on
        ];
    }
  }