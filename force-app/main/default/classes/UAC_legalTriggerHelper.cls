/**
 * @File Name          : UAC_legalTriggerHelper.cls
 * @Description        : Main helper class for trigger logic for UAC_legal__c
 * @Author             : Manoj Sharma (Deloitte)
 * @Group              : UAC_legal__c
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    08/24/2020   Manoj Sharma (Deloitte)     Initial Implementation.
 **/
public
without sharing class UAC_legalTriggerHelper {
  
  /**
   * @description ORRUAC-1982 Method to populate law firm
   * @author Manoj Sharma (Deloitte) | 08/24/2020
   * @param Map<Id, UAC_legal__c> newItems
   * @param Map<Id, UAC_legal__c> oldItems
   **/
  public
  static void populateLawFirm(List<UAC_legal__c> lstLegal, List<Id> lstUserIds) {
      
      Map<String,AccountTeamMember> mapAccountTeam = New Map<String, AccountTeamMember>();
      for(AccountTeamMember oblAccountTeamMember : [SELECT AccountId,UserId FROM AccountTeamMember where UserId in :lstUserIds and Account.RecordType.DeveloperName ='UAC_lawFirms' and TeamMemberRole='Attorney' ]){
          mapAccountTeam.put(oblAccountTeamMember.UserId, oblAccountTeamMember);
      
      }
      for(UAC_legal__c objLegal:lstLegal){
        
        if(mapAccountTeam.containsKey(objLegal.UAC_attorney__c)){
            objLegal.UAC_lawFirm__c = mapAccountTeam.get(objLegal.UAC_attorney__c).AccountId;
        }
      
      }

  }
  

}