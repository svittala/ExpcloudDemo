/**
 * @File Name          : UAC_emailSending.cls
 * @Description        : To send email
 * @Author             : Priyanka Bolla(Deloitte)
 * @Modification Log   :
 * Ver       Date           Author      		    		Modification
 * 1.0    	9/17/2020   	Priyanka Bolla (Deloitte)     	Initial Implementation.
 * 1.1    	10/02/2020  	Nithin Malla (Deloitte)      	Adding Sharing visibility keyword
 * 1.2    	10/20/2020  	Nithin Malla (Deloitte)      	ORRUAC-2972 PSC Notification changes
 * 1.#    	10/27/2020  	Nithin Malla (Deloitte)      	Adding Null Check 
 **/

public
with sharing class UAC_emailSending {
  /**
   * @description Wrapper class to send parametres as list
   * @author Priyanka Bolla(Deloitte) | 9/17/2020
   **/
  public
  with sharing class Flowoutputs {

    @InvocableVariable public string[] recipientEmailAddress;

    @InvocableVariable public String FinalBody;

    @InvocableVariable public String emailSubject;
      
    @InvocableVariable public String[] userIds;
      
    @InvocableVariable public boolean isFBICriminalSecondAttempt;
      
    @InvocableVariable public Id adultContactID;
      
    @InvocableVariable public Id backGroundCheckID;
  }

  /**
   * @description SendEmail Method
   * @author Priyanka Bolla(Deloitte) | 9/17/2020
   * @param Flowoutputs
   **/
  @InvocableMethod public static void
  SendEmail(Flowoutputs[] flowoutputs) {

      // Define the email
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      // Now sets the below paramaters of the email object
      email.setSubject(flowoutputs[0].emailSubject);
      // Here I am accessing current user email id to whom we are sending email
      email.setToAddresses(flowoutputs[0].recipientEmailAddress);
      email.setHtmlBody(flowoutputs[0].FinalBody);
      if(flowoutputs[0].isFBICriminalSecondAttempt!=null && flowoutputs[0].isFBICriminalSecondAttempt && flowoutputs[0].adultContactID!=null && flowoutputs[0].backGroundCheckID!=null){
          List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
          Id unclassifiableId= [SELECT Id FROM UAC_backgroundCheck__c WHERE UAC_adultContact__c=:flowoutputs[0].adultContactID 
                                AND UAC_results__c=:Label.UAC_unclassifiable1stAttempt ORDER BY CreatedDate DESC LIMIT 1].Id;

          Set<Id> backGroundList = new Set<Id>{unclassifiableId, flowoutputs[0].backGroundCheckID};
          List<contentversion> conVerList = [SELECT Id, Title, VersionData, FileType  
                                             FROM contentversion WHERE RecordType.DeveloperName =:Label.UAC_backgroundCheck 
                                             AND UAC_backgroundCheck__c IN :backGroundList];

          for(contentversion conVer: conVerList){
              Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
              efa.setFileName(conVer.Title);
              efa.setBody(conVer.VersionData);
              efa.setContentType(Label.UAC_fileTypePDF);
              attachments.add(efa);
          }
          
          if(attachments.size()>0)
          	email.setFileAttachments(attachments);
      }
      // Sends the email
      Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
  }
    
}