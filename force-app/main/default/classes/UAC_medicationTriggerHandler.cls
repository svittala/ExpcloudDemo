/**
 * @File Name          : UAC_medicationTriggerHandler.cls
 * @Description        : Handles all Medication trigger traffic
 * @Author             : Omer Syed (MutatioInc)
 * @Group              : UAC_triggerHandler
 * @Last Modified By   : Omer Syed (MutatioInc)
 * @Last Modified On   : 06/19/2020, 03:50:03 PM
 * @Modification Log   :
 * Ver       Date            Author                        Modification
*  1.0      06/20/2020  Omer Syed (MutatioInc)          Initial Implementation.
 **/
public without sharing class UAC_medicationTriggerHandler implements UAC_ITriggerHandler {
  public
  Boolean isDisabled() {
    return UAC_bypassSettings__c.getInstance().UAC_bypassMedicationTrigger__c;
  }

  /**
   * @description Method to handle before update trigger traffic
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @param lstNewMedications List of new records
   * @return void
   **/
    public 
      void beforeInsert(List<UAC_medication__c> lstNewMedications) {
       UAC_medicationTriggerHelper.updateStausOnInsert(lstNewMedications);     
    }
    /**
   * @description Method to handle before insert trigger traffic
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @param newItems List of new records
   * @param oldItems List of old records
   * @return void
   **/
    public 
        void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
            if (UC_exclusionLogicService.getInstance().runExclusions(newItems, newItems.keyset(), 'UC_Medication')) {
                UAC_medicationTriggerHelper.updateStausOnDateDiscontinued(newItems,oldItems);   
            }
        }

    /**
   * @description Method to handle after undelete trigger traffic
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @param oldItems Map of old records
   * @return void
   **/    
    public
        void afterDelete(Map<Id, SObject> oldItems) {
        }

    /**
   * @description Method to handle after undelete trigger traffic
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @param oldItems Map of old records
   * @return void
   **/
    public
        void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        }
    /**
   * @description Method to handle after undelete trigger traffic
   * @author Omer Syed (MutatioInc) | 6/20/2020
   * @param oldItems Map of old records
   * @return void
   **/
    public
        void afterInsert(Map<Id, SObject> oldItems) {
            UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), 'UC_Medication');
        }

    /**
     * @description Method to handle after undelete trigger traffic
     * @author Omer Syed (MutatioInc) | 6/20/2020
     * @param oldItems Map of old records
     * @return void
    **/
    public
        void beforeDelete(Map<Id, SObject> oldItems) {
        UC_exclusionLogicService.getInstance().runExclusions(oldItems, oldItems.keyset(), 'UC_Medication');
        }

    /**
       * @description Method to handle after undelete trigger traffic
       * @author Omer Syed (MutatioInc) | 6/20/2020
       * @param oldItems Map of old records
       * @return void
    **/
      public
      void afterUndelete(Map<Id, SObject> oldItems) {
      }
}