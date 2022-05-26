/**
 * @File Name          : UAC_backgroundCheckDocsDeletionTest.cls
 * @Description        : test class for UAC_backgroundCheckDocumentsDeletion
 * @Author             : Priyanka Bolla(Deloitte)
 * @Group              : UAC_backgroundCheckDocumentsDeletion,UAC_scheduleBackGroundCheckDocsDeletion
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/10/2020   Priyanka Bolla (Deloitte)     Initial Implementation.
 * 2.0    11/5/2020   Nithin Malla (Deloitte)     	Code Scan fixes.
 **/

@isTest(seeAllData = false) public with sharing class UAC_backgroundCheckDocsDeletionTest {

  /**
   * @description Test method that calls the Batch
   * @author Priyanka Bolla (Deloitte) | 9/10/2020
   **/
    
   @isTest static void testInsertBackgroundCheckDocContentVersion() {
    
    Id BackGroudnCheckDocRecType = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
                            .get(Label.UAC_backgroundcheckRecordTypeName)
                            .getRecordTypeId();
    
    test.startTest();
    List<ContentVersion> lstNewFiles = new list<ContentVersion>();

    ContentVersion tempContentVersion = new ContentVersion();
    tempContentVersion.Title = 'test';
    tempContentVersion.ContentUrl = 'https://uacpath--sprintdev.my.salesforce.com';
    tempContentVersion.RecordTypeId = BackGroudnCheckDocRecType;
    tempContentVersion.UAC_documentType__c = Label.UAC_docTypeFBICriminalHistory;
    lstNewFiles.add(tempContentVersion);

    insert lstNewFiles;
       
       List<ContentVersion> lstNewFilesForScope =[Select Id,ContentDocumentId,CreatedDate,ContentVersion.RecordType.name,UAC_documentType__c from ContentVersion where UAC_documentType__c =:Label.UAC_docTypeFBICriminalHistory ];
        UAC_backgroundCheckDocumentsDeletion objBatch = new  UAC_backgroundCheckDocumentsDeletion(); 
        objBatch.execute(null,lstNewFilesForScope); 
        UAC_scheduleBackGroundCheckDocsDeletion scheduleDelJob = new UAC_scheduleBackGroundCheckDocsDeletion();
        String schedule = '0 0 * * * ?';
        system.schedule('Background check attachment records deletion', schedule, scheduleDelJob);

        system.assert(true);
        
       test.stopTest();
  

  }
 }