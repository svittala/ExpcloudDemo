Global class MassDeleteRecordsBatchClass Implements Database.batchable<sobject>{
     global final string query;
     global MassDeleteRecordsBatchClass(string q){
          query=q;
     }
    
     global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
     }
     global  void execute(Database.BatchableContext BC,List<SObject> scope){
         delete scope;
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Record Batch Delete ' + a.Status);
        mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  }