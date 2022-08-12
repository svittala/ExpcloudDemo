/**
 * @File Name          : UC_sirCDC.trigger
 * @Description        : Handles all SIR CDC trigger traffic
 * @Author             : Nithin Malla (Deloitte)
 * @Group              : UAC_triggerHandler
 * @Modification Log   :
 * Ver       Date            Author                        Modification
 *  1.0      08/24/2021     Nithin Malla (Deloitte)      Initial Implementation.
  **/
trigger UC_sirCDC on UAC_sir__ChangeEvent (after insert) {
    
    Set<Id> programIDs = new Set<ID>();
    for(UAC_sir__ChangeEvent sirRec : trigger.new) {
        EventBus.ChangeEventHeader header = sirRec.ChangeEventHeader;
        if (header.changetype == 'CREATE' && sirRec.UAC_uaclookup__c!=null) { 
            programIDs.add(sirRec.UAC_uaclookup__c);
        }
    }
    
    if(programIDs != null && !programIDs.isEmpty()) {
        new UC_sirCDCHandler().calculateNoOfSirForGivenUC(programIDs);
    }
}