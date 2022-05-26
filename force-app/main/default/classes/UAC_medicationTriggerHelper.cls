/**
* @File Name          : UAC_medicationTriggerHelper.cls
* @Description        : Helper method for UAC_medicationTriggerHandler
* @Author             : Omer Syed (MuatioInc)
* @Group              : UAC_triggerHelper
* @Test Class         : UAC_medicationTriggerHelperTest
* @Last Modified By   : Omer Syed(MuatioInc)
* @Last Modified On   : 6/20/2020, 10:34:50 AM
* @Modification Log   :
*
* Ver       Date            Author                      Modification
* 1.0    6/19/2020   Omer Syed (MuatioInc)           Initial Implementation.
**/
public without sharing class UAC_medicationTriggerHelper {
    /**
* @description ORRUAC-946 - Method to update Status if Date Discontinued is null on update'*
* @author  Omer Syed (MutatioInc) | 6/20/2020
* @param
* @return void
**/

   public
        static void  updateStausOnDateDiscontinued(Map<Id,SObject> newItems,Map<Id,SObject> oldItems){
            for (UAC_medication__c medication: (List<UAC_medication__c>) newItems.values()){
                UAC_medication__c oldMedication = (UAC_medication__c)oldItems.get(medication.Id);
                if(medication.UAC_DateDiscontinued__c!=oldMedication.UAC_DateDiscontinued__c){
                    if(medication.UAC_DateDiscontinued__c==null){
                        medication.UAC_Status__c= System.label.UAC_medicationStatusCurrent;
                    }else{
                        medication.UAC_Status__c=System.label.UAC_medicationStatusDiscont;
                    }
                }
            }
    }
    /**
* @description ORRUAC-946 - Method to update Status=Current IF dateDiscontinued is null on Insert*
* @author Omer Syed (MutatioInc) | 6/20/2020
* @param
* @return void
**/
    public 
        static void updateStausOnInsert(List<SObject> newItems){
            for (UAC_medication__c medication: (List<UAC_medication__c>) newItems){
                if(medication.UAC_DateDiscontinued__c==null){
                    medication.UAC_Status__c=System.label.UAC_medicationStatusCurrent;
                }else{
                    medication.UAC_Status__c=System.label.UAC_medicationStatusDiscont;
                }
            }
    }
    
    
}