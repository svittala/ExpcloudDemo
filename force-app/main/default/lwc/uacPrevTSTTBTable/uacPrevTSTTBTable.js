import { LightningElement, api } from 'lwc';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_REACTION from '@salesforce/schema/UAC_test__c.UAC_reactionInMM__c';
import FLD_DATE_PERFORMED from '@salesforce/schema/UAC_test__c.UAC_datePerformed__c';
import FLD_DATE_READ from '@salesforce/schema/UAC_test__c.UAC_dateRead__c';
import LBL_RECORD_TYPE_NAME_TST_RESULTS from '@salesforce/label/c.UAC_testRecTypeTBScreeningUnder2YearsAge';


const COLUMNS = [
  { name: FLD_RESULT.fieldApiName },
  { name: FLD_REACTION.fieldApiName },
  { name: FLD_DATE_PERFORMED.fieldApiName },
  { name: FLD_DATE_READ.fieldApiName },  
  { name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true }
];

const TITLE = 'Previously Entered TST Tests';

export default class UacPrevTSTTBTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  title = TITLE;

  objectApiName = OBJ_TEST.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = `RecordType.DeveloperName='${LBL_RECORD_TYPE_NAME_TST_RESULTS}'`;
    queryFilter +=
      ` AND ${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}