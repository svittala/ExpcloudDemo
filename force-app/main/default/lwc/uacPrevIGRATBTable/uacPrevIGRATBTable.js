import { LightningElement, api } from 'lwc';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_TEST_TYPE from '@salesforce/schema/UAC_test__c.UAC_testType__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import LBL_RECORD_TYPE_NAME_IGRA_RESULTS from '@salesforce/label/c.UAC_testRecTypeTBScreening2YearsAgeAndOlder';


const COLUMNS = [
  { name: FLD_TEST_TYPE.fieldApiName },
  { name: FLD_RESULT.fieldApiName },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName },
  { name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true }
];

const TITLE = 'Previously Entered IGRA Tests';

export default class UacPrevIGRATBTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  title = TITLE;

  objectApiName = OBJ_TEST.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = `RecordType.DeveloperName='${LBL_RECORD_TYPE_NAME_IGRA_RESULTS}'`;
    queryFilter +=
      ` AND ${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}