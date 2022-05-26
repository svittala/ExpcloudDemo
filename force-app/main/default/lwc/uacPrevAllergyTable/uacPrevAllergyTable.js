import { LightningElement, api } from 'lwc';
import OBJ_ALLERGY from '@salesforce/schema/UAC_allergy__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_allergy__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_allergy__c.UAC_associatedUAC__c';
import FLD_ALLERGYTYPE from '@salesforce/schema/UAC_allergy__c.UAC_allergyType__c';
import FLD_ALLERGEN from '@salesforce/schema/UAC_allergy__c.UAC_allergen__c';
import FLD_REACTION from '@salesforce/schema/UAC_allergy__c.UAC_reaction__c';


const COLUMNS = [
  { name: FLD_ALLERGYTYPE.fieldApiName },
  { name: FLD_ALLERGEN.fieldApiName },
  { name: FLD_REACTION.fieldApiName },
  { name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true }
];

const TITLE = 'Previously Reported Allergies';

export default class UacPrevAllergyTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  title = TITLE;

  objectApiName = OBJ_ALLERGY.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = ` ${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}