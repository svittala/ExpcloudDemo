/**
 * @File Name          : UAC_flowContactQuery.cls
 * @Description        : Class to get Profile details for DHS Referral Flow
 * @Author             : Vaibhav Kudesia (Deloitte)
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0     02/10/2021   Vaibhav Kudesia (Deloitte)     Initial Implementation.
 **/
global without sharing class UAC_flowContactQuery {

   /**
   * @description Invocable method to query UAC Contact/Profile
   * @author Vaibhav Kudesia (Deloitte) | 02/10/2021
   * @param List<Request>
   * @return List<Response>
   **/
  @InvocableMethod(label = 'Get Referral Contact') 
    
    public static list<Contact> queryContactANumber(List<String> listInputString) {
          
      List<Contact> lstUAC = [Select Id, UAC_A__c, Birthdate, FirstName, LastName,MiddleName, UAC_COB__c, UAC_gender__c from Contact where UAC_A__c =: listInputString[0]];
      if(lstUAC.isEmpty()){
        lstUAC.add(new Contact(Id = null, FirstName ='', LastName='', MiddleName='',Birthdate = System.today(),UAC_COB__c='',UAC_gender__c=''));
      }
      else if(!lstUAC.isEmpty()){
        if(lstUAC[0].MiddleName == null){
        lstUAC[0].MiddleName='';
        }
        if(lstUAC[0].UAC_gender__c == null){
        lstUAC[0].UAC_gender__c='';
        }
      }  
      return lstUAC;
	}
}