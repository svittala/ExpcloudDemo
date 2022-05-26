import { LightningElement, api } from 'lwc';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_OTHER_DISEASE_CONDITION from '@salesforce/schema/UAC_test__c.UAC_specifyOtherDiseaseConditionTested__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import LBL_RECORD_TYPE_PRID_LAB_TEST from '@salesforce/label/c.UAC_testRecTypePRIDLabTest';


const COLUMNS = [
  { name: FLD_DISEASE.fieldApiName },
  { name: FLD_OTHER_DISEASE_CONDITION.fieldApiName },  
  { name: FLD_TEST.fieldApiName },
  { name: FLD_RESULT.fieldApiName },
  { name: FLD_SPECIMEN_SOURCE.fieldApiName },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName },
  { name: FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true }
];

const TITLE = 'Previously Entered PRID Lab Tests';

export default class UacPrevPRIDLabTestTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  @api title = TITLE;

  objectApiName = OBJ_TEST.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = `RecordType.DeveloperName='${LBL_RECORD_TYPE_PRID_LAB_TEST}'`;
    queryFilter +=
      ` AND ${FLD_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
}