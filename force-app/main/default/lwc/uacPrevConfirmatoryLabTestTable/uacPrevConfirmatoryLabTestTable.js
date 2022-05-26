import { LightningElement, api } from 'lwc';
import LBL_RECORD_TYPE_CONF_LAB_TEST from '@salesforce/label/c.UAC_testRecTypeConfirmatoryLabTest';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_REASON_NOT_DONE from '@salesforce/schema/UAC_test__c.UAC_specifyReasonNotDone__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';



const COLUMNS = [
  { name: FLD_DISEASE.fieldApiName },
  { name: FLD_TEST.fieldApiName },
  { name: FLD_RESULT.fieldApiName },
  { name: FLD_REASON_NOT_DONE.fieldApiName },
  { name: FLD_SPECIMEN_SOURCE.fieldApiName },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName },
  { name: FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName, clickable: true }
];

const TITLE = 'Previously Entered Confirmatory Lab Tests';

export default class UacPrevConfirmatoryLabTestTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  title = TITLE;

  objectApiName = OBJ_TEST.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = `RecordType.DeveloperName='${LBL_RECORD_TYPE_CONF_LAB_TEST}'`;
    queryFilter +=
      ` AND ${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}