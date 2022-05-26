import { LightningElement, api } from 'lwc';
import OBJ_EXPOSURE_EVENT from '@salesforce/schema/UAC_exposureEvent__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_exposureEvent__c.UAC_associatedHealthEvaluation__c';
import FLD_EXPOSURE_EVENT_ID from '@salesforce/schema/UAC_exposureEvent__c.Name';
import FLD_DISEASE_CONDITION from '@salesforce/schema/UAC_exposureEvent__c.UAC_diseaseCondition__c';
import FLD_DISEASE_CONDITION_TYPE from '@salesforce/schema/UAC_exposureEvent__c.UAC_diseaseConditionType__c';
import FLD_PENDING_OUTCOMES from '@salesforce/schema/UAC_exposureEvent__c.UAC_pendingOutcomes__c';
import FLD_DIANOSED_WITH_ILLNESS_OUTCOMES from '@salesforce/schema/UAC_exposureEvent__c.UAC_diagnosedWithIllnessOutcomes__c';
import FLD_TOTAL_OUTCOMES from '@salesforce/schema/UAC_exposureEvent__c.UAC_totalOutcomes__c';

const COLUMNS = [
  { name: FLD_EXPOSURE_EVENT_ID.fieldApiName, clickable: true },
  { name: FLD_DISEASE_CONDITION.fieldApiName },
  { name: FLD_DISEASE_CONDITION_TYPE.fieldApiName },
  { name: FLD_PENDING_OUTCOMES.fieldApiName },  
  { name: FLD_DIANOSED_WITH_ILLNESS_OUTCOMES.fieldApiName },
  { name: FLD_TOTAL_OUTCOMES.fieldApiName }
];

export default class UacExposureEventFlowTbl extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  objectApiName = OBJ_EXPOSURE_EVENT.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter =  `${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}='${this.healthEvaluationId}'`;
    return queryFilter;
  }
}