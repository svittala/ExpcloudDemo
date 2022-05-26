import { LightningElement, api } from 'lwc';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_SPECIMENT_COLLECTED_BY from '@salesforce/schema/UAC_test__c.UAC_specimenCollectedBy__c';
import RECORD_TYPE_BACTERIOLOGICAL_RESULTS from '@salesforce/label/c.UAC_testRecTypeBacteriologicalResults';


const COLUMNS = [
  { name: FLD_TEST.fieldApiName },
  { name: FLD_RESULT.fieldApiName },
  { name: FLD_SPECIMEN_SOURCE.fieldApiName },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName },
  { name: FLD_SPECIMENT_COLLECTED_BY.fieldApiName },
  { name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true }
];

const TITLE = 'Previously Entered Bacteriological Results';

export default class UacPrevBacteriologicalTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  title = TITLE;

  objectApiName = OBJ_TEST.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = `RecordType.DeveloperName='${RECORD_TYPE_BACTERIOLOGICAL_RESULTS}'`;
    queryFilter +=
      ` AND ${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}