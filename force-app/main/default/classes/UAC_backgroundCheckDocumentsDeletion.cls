/**
 * @File Name          : UAC_backgroundCheckDocumentsDeletion.cls
 * @Description        : Batch class to delete background check records
 * @Author             : Priyanka Bolla(Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    9/10/2020   Priyanka Bolla (Deloitte)     Initial Implementation.
 **/


   global without sharing class UAC_backgroundCheckDocumentsDeletion implements
    
   Database.Batchable<sObject> {
        
/**
   * @description Start method 
   * @author Priyanka Bolla(Deloitte) | 9/10/2020
   * @param Database.BatchableContext
   * @return Database.QueryLocator
   **/
   global Database.QueryLocator start(Database.BatchableContext bc) {


   Datetime ExpectedDelDate = Datetime.now() -Integer.ValueOf(Label.UAC_backgroundcheckRecordsDeletion);
    
    
   
   String query= Label.UAC_backgroundcheckDocsDeletionBatchQuery;
   return Database.getQueryLocator(query);
  }
  /**
   * @description Execute method, called once per batch
   * @author Priyanka Bolla (Deloitte) | 9/10/2020
   * @param Database.BatchableContext
   * @param List<ContentVersion>
   **/
    global void execute(Database.BatchableContext bc, List<ContentVersion> scope) {
       
       if(!scope.isEmpty()){
           
        List<contentDocument> contentDocuments = new List<contentDocument>();
           for(ContentVersion cv:scope){
               contentDocuments.add(new contentDocument(Id=cv.ContentDocumentId));
                }
           if(!contentDocuments.isEmpty())  {
          delete contentDocuments;   
          Database.emptyRecycleBin(contentDocuments);  
           }  
       }

      }
 /**
   * @description Finish method - not used for this batch.
   * @author Priyanka Bolla (Deloitte) | 9/10/2020
   * @param Database.BatchableContext
   **/       
   global void finish(Database.BatchableContext bc) {
   }
}