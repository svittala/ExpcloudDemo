/**
 * @File Name          : UAC_sieTriggerHelper.cls
 * @Description        : Helper method for UAC_sirTriggerHandler
 * @Author             : Sarang Padhye (Deloitte)
 * @Group              : UAC_triggerHelper
 * @Test Class         : UAC_sirTriggerHelperTest
 * @Modification Log   :
 *
 * Ver       Date            Author                      Modification
 * 1.0    10/29/2020    Sarang Padhye(Deloitte)     Initial Implementation.
 **/
public
without sharing class UAC_sirTriggerHelper {

    Private Static boolean isExecuted = false;
    
  /**
   * @description Method to reset SIR fields on clone
   * @author Sarang Padhye (Deloitte)
   * @param listSirs List of new records
   * @return void
   **/
  public
  static void resetSIRFieldsOnCreate(List<UAC_sir__c> listSirs) {
    try {
      List<Schema.FieldSetMember> fieldsToReset =
          SObjectType.UAC_sir__c.FieldSets.UAC_fieldsToReset.getFields();
      list<UAC_sir__c> listClonedSirs = new List<UAC_sir__c>();
      for (UAC_sir__c sR : listSirs) {
        if (sr.isClone()) {
          listClonedSirs.add(sR);
        }
      }
      if (listClonedSirs == null || listClonedSirs.isEmpty()) return;
      for (UAC_sir__c sR : listClonedSirs) {
        for (Schema.FieldSetMember mem : fieldsToReset) {
          if (mem.getType() == Schema.displayType.boolean) {
            system.debug(mem.getFieldPath());
            sr.put(mem.getFieldPath(), false);
          } else {
            sr.put(mem.getFieldPath(), null);
          }
        }
      }
    } catch (Exception e) {
      UAC_errorLog.logError(
          e.getMessage(), '', 'Before Insert : Error reseting SIR fields', e.getStackTraceString());
    }
  }
    
    /**
   * @description Method to reset SIR fields on clone
   * @author Nithin Malla (Deloitte)
   * @param sirs Map of new records
   * @param sirs Map of old records
   * @return void
   **/
  public
  static void validateSIRStatusUpdates(Map<Id, UAC_sir__c> newItems, Map<Id, UAC_sir__c> oldItems) {
      if(!isExecuted){
          for(UAC_sir__c sirRec: newItems.values()){
              UAC_sir__c oldSirRec = oldItems.get(sirRec.Id);
              if( validationCheck5(sirRec, oldSirRec)) {
                     sirRec.addError('SIR with a status of "Submitted" or "Created in Error" cannot be updated.');
                 }
          }
          isExecuted = true;
      }
  }    
    /**
   * @description Method to validation SIR before update
   * @author Nithin Malla (Deloitte)
   * @param sirs of new record
   * @param sirs of old record
   * @return boolean
   **/  
  Private 
  static boolean validationCheck5(UAC_sir__c sirRec, UAC_sir__c oldSirRec){
      boolean isValid=false;
      if(!sirRec.UAC_addendumDraft__c &&
         sirRec.UAC_status__c==oldSirRec.UAC_status__c &&         
         sirRec.UAC_status__c =='Submitted' && 
         sirRec.UAC_notificationEmailSet__c != oldSirRec.UAC_notificationEmailSet__c)
      {
          isValid = true;
      }
      return isValid;
  }
}