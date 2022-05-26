/**
 * @File Name          : UC_sirCDCHandler.cls
 * @Description        : Handles all SIR CDC trigger traffic
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 *  1.0      08/24/2021     Nithin Malla (Deloitte)      Initial Implementation.
 **/
public
without sharing class UC_sirCDCHandler {
    
   /**
   * @description Method to handle after insert sir CDC trigger traffic
   * @author Nithin Malla (Deloitte)
   * @param programIDs set of new sir records
   * @return void
   **/
  public
  void calculateNoOfSirForGivenUC(Set<Id> programIDs) {      
      
    List<Contact> conListToUpdate = new List<Contact>();      
    List<AggregateResult> aggResultExpEvent = [SELECT UAC_uaclookup__c, COUNT(Id) Id
										 FROM UAC_sir__c where UAC_uaclookup__c IN: programIDs
										 GROUP BY UAC_uaclookup__c];
      
    for (AggregateResult aggr : aggResultExpEvent) {
      Contact con = new Contact(Id=(String) aggr.get('UAC_uaclookup__c'));
      con.UC_no_of_SIRs__c = (Integer) aggr.get('Id');
      conListToUpdate.add(con);
    }
    
    if(conListToUpdate != null && !conListToUpdate.isEmpty()) {
      update conListToUpdate; 
    }      
  }
    
}