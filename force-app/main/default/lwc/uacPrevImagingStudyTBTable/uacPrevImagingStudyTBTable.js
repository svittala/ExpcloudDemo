import { LightningElement, api } from 'lwc';
import OBJ_TEST from "@salesforce/schema/UAC_test__c";
import FLD_ASSOCIATED_HEALTH_EVALUATION from "@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c";
import FLD_ASSOCIATED_UAC from "@salesforce/schema/UAC_test__c.UAC_associatedUAC__c";
import FLD_CREATED_DATE from "@salesforce/schema/UAC_test__c.CreatedDate";
import FLD_TEST from "@salesforce/schema/UAC_test__c.UAC_test__c";
import FLD_TEST_ID from "@salesforce/schema/UAC_test__c.Name";
import FLD_SPECIFYOTHERTEST from "@salesforce/schema/UAC_test__c.UAC_specifyOtherTest__c";
import FLD_RESULT from "@salesforce/schema/UAC_test__c.UAC_result__c";
import FLD_DATEPERFORMED from "@salesforce/schema/UAC_test__c.UAC_datePerformed__c";
import FLD_RADIOGRAPHICCLASSIFICATION from "@salesforce/schema/UAC_test__c.UAC_radiographicClassification__c";
import LBL_RECORD_TYPE_IMAGING_STUDY_TEST from "@salesforce/label/c.UAC_testRecTypeImagingStudy";


const COLUMNS = [
  { name: FLD_TEST_ID.fieldApiName, clickable: true },
  { name: FLD_TEST.fieldApiName},
  { name: FLD_SPECIFYOTHERTEST.fieldApiName},
  { name: FLD_RESULT.fieldApiName},
  { name: FLD_DATEPERFORMED.fieldApiName},
  { name: FLD_RADIOGRAPHICCLASSIFICATION.fieldApiName},
  { name: FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName, clickable: true}
];

const TITLE = 'Previously Entered Imaging Studies';

export default class UacPrevImagingStudyTBTable extends LightningElement {
  @api healthEvaluationId;
  @api uacId;

  title = TITLE;

  objectApiName = OBJ_TEST.objectApiName;
  columns = COLUMNS;

  get filter() {
    let queryFilter = `RecordType.DeveloperName='${LBL_RECORD_TYPE_IMAGING_STUDY_TEST}'`;
    queryFilter +=
      ` AND ${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    return queryFilter;
  }
  
}