import OBJ_IMMUNIZATION from '@salesforce/schema/UAC_immunization__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_immunization__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_immunization__c.UAC_associatedUAC__c';
import FLD_UAC_DATE_ADMINISTERED from '@salesforce/schema/UAC_immunization__c.UAC_dateAdministered__c';
import FLD_UAC_DURATION from '@salesforce/schema/UAC_immunization__c.UAC_expectedShortageDuration__c';
import FLD_UAC_REASON_NOT_ADMINISTERED from '@salesforce/schema/UAC_immunization__c.UAC_reasonNotAdministered__c';
import FLD_UAC_OTHER_VACCINE from '@salesforce/schema/UAC_immunization__c.UAC_specifyOtherVaccine__c';
import FLD_UAC_STATUS from '@salesforce/schema/UAC_immunization__c.UAC_status__c';
import FLD_UAC_VACCINE from '@salesforce/schema/UAC_immunization__c.UAC_vaccine__c';
import {api, LightningElement} from 'lwc';


const COLUMNS = [
  {name: FLD_UAC_VACCINE.fieldApiName},
  {name: FLD_UAC_OTHER_VACCINE.fieldApiName},
  {name: FLD_UAC_STATUS.fieldApiName},
  {name: FLD_UAC_DATE_ADMINISTERED.fieldApiName},
  {name: FLD_UAC_REASON_NOT_ADMINISTERED.fieldApiName},
  {name: FLD_UAC_DURATION.fieldApiName},
  {name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true}
];

const TITLE = 'Previously Entered Immunizations';

export default class UacPrevImmunizationsTable extends LightningElement {
  @api
  healthEvaluationId;
  @api
  uacId;

  title = TITLE;

  objectApiName = OBJ_IMMUNIZATION.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = ` ${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}