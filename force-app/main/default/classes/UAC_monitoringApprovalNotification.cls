/**
* @File Name         : UAC_monitoringApprovalNotification.cls
* @Description       : This Class handles the email to apex service for sending notification on Approved Visits.
* @Group             : UAC_monitoringApprovalNotification
* @Test Class        : UAC_monitoringApprovalNotificationTest
* @Author            : Nithin Malla (Deloitte)
* @Last Modified By  : Nithin Malla (Deloitte)
* @Last Modified On  : 10-14-2020
* Modifications Log
* Ver       Date                Author                              Modification
* 1.0       10-14-2020          Nithin Malla (Deloitte)             Initial Version
**/
public without sharing class UAC_monitoringApprovalNotification {
    
    private
    Static final String UAC_BREAK = '<br/>';
    
    private
    Static final String UAC_GREATER = '>';
    
    private
    Static final String UAC_HYPEN = ' - ';
    
    private
    Static final String UAC_SPACE = ' ';
    
    private
    Static final String UAC_URL ='/lightning/r/UAC_monitoring__c/';
    
    private
    Static final String UAC_MONITORING ='UAC_monitoring';
    
    private
    Static final String UAC_NOTIFICATIONSEND ='UAC_notificationsToSend';
    
    private
    Static final String UAC_VIEW ='/view';
    
    @InvocableMethod
    public static void execute (List<Id> monitoringIds) {

        List<UAC_monitoring__c> monitoringRecList = [Select Id,Name, 
                                                     (Select Id,UAC_uacMonitor__r.Email,UAC_monitoring__r.Name,
                                                      UAC_monitoring__r.UAC_program__r.Name,UAC_monitoring__r.UAC_travelReturn__c,
                                                      UAC_monitoring__r.UAC_travelDeparture__c,UAC_monitoring__c,UAC_uacMonitor__r.Name
                                                      from UAC_Monitors__r limit 1000) 
                                                     from UAC_monitoring__c where Id IN:monitoringIds]; 
        
        Map<String, object> bellInput = new Map<String, Object>();
        String subject;
        String body;
        String bellnotificationBody;
        List<UAC_flowNotification> flowBellNotify = new List<UAC_flowNotification>();
        
        List<Messaging.SingleEmailMessage> lstSendMails = new List<Messaging.SingleEmailMessage>();
        List<String> lstUserId = new List<String>();
        List<String> lstUserEmail = new List<String>();
        
        Id pathNotifyId = [select id from CustomNotificationType where DeveloperName =:UAC_MONITORING limit 1].id;
        
        for(UAC_monitoring__c monitoringRec: monitoringRecList){
            
            if(monitoringRec.UAC_Monitors__r.size()>0){
                subject = Label.UAC_monitoringVisit+UAC_SPACE+monitoringRec.Name+UAC_SPACE+Label.UAC_assignedScheduled;
                bellnotificationBody= Label.UAC_monitoringVisit+UAC_SPACE+monitoringRec.Name+UAC_SPACE+Label.UAC_assignedScheduled;
                
                //Create a new Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                for(UAC_monitor__c monitorRec: monitoringRec.UAC_Monitors__r){
                    
                    
                    lstUserId.add(monitorRec.UAC_uacMonitor__c);
                    body = Label.UAC_monitoringHello;
                    body += subject+UAC_BREAK;
                    body += Label.UAC_monitoringProgram+UAC_SPACE+monitorRec.UAC_monitoring__r.UAC_program__r.Name+UAC_BREAK;
                    body += Label.UAC_monitoringTravelDate+UAC_SPACE+String.valueOf(monitorRec.UAC_monitoring__r.UAC_travelDeparture__c)+UAC_HYPEN+String.valueOf(monitorRec.UAC_monitoring__r.UAC_travelReturn__c)+UAC_BREAK;
                    
                    String strListViewUrl = URL.getSalesforceBaseUrl().toExternalForm() + UAC_URL + monitorRec.UAC_monitoring__c+UAC_VIEW;
                    body += Label.UAC_monitoringPleaseVisit+strListViewUrl +UAC_GREATER+monitorRec.UAC_monitoring__r.Name +Label.UAC_monitoringAction;
                    String EmailBody = body;
                    
                    lstUserEmail.add(monitorRec.UAC_uacMonitor__r.Email);
                    
                    mail.setSubject(subject);
                    mail.setHtmlBody(EmailBody);                    
                }
                
                mail.setToAddresses(lstUserEmail);
                lstSendMails.add(mail);
                
                // Bell Notificatiosn to User UAC_notificationsToSend
                flowBellNotify.add(new UAC_flowNotification(pathNotifyId, bellnotificationBody, subject, 
                                                            lstUserId, monitoringRec.Id));
            }
        }
        
        if(lstSendMails.size()>0){
            Messaging.sendEmail(lstSendMails, false);
        }
		
        if(flowBellNotify.size()>0){
            bellInput.put(UAC_NOTIFICATIONSEND, flowBellNotify);
            Flow.Interview.UAC_sendMassNotifications BellFlow = new Flow.Interview.UAC_sendMassNotifications(bellInput);
            BellFlow.start();
        }
    }
}