import OBJ_MEDICATION from '@salesforce/schema/UAC_medication__c';
import FLD_MEDICATION_NAME from '@salesforce/schema/UAC_medication__c.Name';
import FLD_MEDICATION_ASSOCIATED_DIAGNOSIS from '@salesforce/schema/UAC_medication__c.UAC_associatedDiagnosis__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_medication__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_medication__c.UAC_associatedUAC__c';
import FLD_MEDICATION_DATE_DISCONTINUED from '@salesforce/schema/UAC_medication__c.UAC_dateDiscontinued__c';
import FLD_MEDICATION_DATE_STARTED from '@salesforce/schema/UAC_medication__c.UAC_dateStarted__c';
import FLD_MEDICATION_DIRECTION from '@salesforce/schema/UAC_medication__c.UAC_direction__c';
import FLD_MEDICATION_DISCHARGED_WITH_MEDS from '@salesforce/schema/UAC_medication__c.UAC_dischargedWithMedication__c';
import FLD_MEDICATION_DOSE from '@salesforce/schema/UAC_medication__c.UAC_dose__c';
import FLD_MEDICATION_PSYCHOTROPIC from '@salesforce/schema/UAC_medication__c.UAC_psychotropic__c';
import FLD_REASON_FOR_MEDICATION from '@salesforce/schema/UAC_medication__c.UAC_reasonForMedication__c';
import FLD_ENTERED_FROM_INITIAL_ASSESSMENT from '@salesforce/schema/UAC_medication__c.UAC_enteredfromInitialIntakesAssessment__c';

import {api, LightningElement} from 'lwc';


const COLUMNS = [
  {name: FLD_MEDICATION_ASSOCIATED_DIAGNOSIS.fieldApiName},
  {name: FLD_MEDICATION_NAME.fieldApiName},
  {name: FLD_MEDICATION_DATE_STARTED.fieldApiName},
  {name: FLD_MEDICATION_DATE_DISCONTINUED.fieldApiName},
  {name: FLD_MEDICATION_DOSE.fieldApiName},
  {name: FLD_MEDICATION_DIRECTION.fieldApiName},
  {name: FLD_MEDICATION_PSYCHOTROPIC.fieldApiName},
  {name: FLD_MEDICATION_DISCHARGED_WITH_MEDS.fieldApiName},
  {name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true}
];
const COLUMNS_WITH_REASON = [
  {name: FLD_MEDICATION_ASSOCIATED_DIAGNOSIS.fieldApiName},
  {name: FLD_MEDICATION_NAME.fieldApiName},
  {name: FLD_REASON_FOR_MEDICATION.fieldApiName},
  {name: FLD_MEDICATION_DATE_STARTED.fieldApiName},
  {name: FLD_MEDICATION_DATE_DISCONTINUED.fieldApiName},
  {name: FLD_MEDICATION_DOSE.fieldApiName},
  {name: FLD_MEDICATION_DIRECTION.fieldApiName},
  {name: FLD_MEDICATION_PSYCHOTROPIC.fieldApiName},
  {name: FLD_MEDICATION_DISCHARGED_WITH_MEDS.fieldApiName},
  {name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true}
];

const TITLE = 'Previously Entered Medications';

export default class UacPrevMedicationTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;
  @api showReasonForMedication = false;

  title = TITLE;

  objectApiName = OBJ_MEDICATION.objectApiName;

  get columns() {
    return (this.showReasonForMedication) ? COLUMNS_WITH_REASON : COLUMNS;
  }

  get filter() {
    let queryFilter =
      `${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}' AND ${FLD_ENTERED_FROM_INITIAL_ASSESSMENT.fieldApiName}=false`;
    return queryFilter;
  }
}