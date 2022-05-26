import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LBL_DIAGNOSIS_STATUS_WORKING from '@salesforce/label/c.UAC_diagnosisStatusWorking';
import LBL_DIAGNOSIS_STATUS_FINAL from '@salesforce/label/c.UAC_statusFinal';
import LBL_RECORD_TYPE_DIAGNOSIS_MHD from '@salesforce/label/c.UAC_recordTypeMentalHealthDiagnosis';
import LBL_BEHAVIORAL_MENTAL_HEALTH_CONCERN from '@salesforce/label/c.UAC_diagnosisCategoryBehavioralAndMentalHealthConcerns';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import FLD_DIAGNOSIS_OUTCOME_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_diagnosisOutcome__c.UAC_associatedHealthEvaluation__c';
import OBJ_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c';
import FLD_DIAGNOSIS_NAME from '@salesforce/schema/UAC_diagnosis__c.Name';
import FLD_DIAGNOSIS_STATUS from '@salesforce/schema/UAC_diagnosis__c.UAC_status__c';
import FLD_DIAGNOSIS_DISCONTINUED from '@salesforce/schema/UAC_diagnosis__c.UAC_discontinued__c';
import FLD_DIAGNOSIS_CATEGORY from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCategory__c';
import FLD_DIAGNOSIS_CONDITION from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCondition__c';
import FLD_DIAGNOSIS_CONDITION_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_specifyOtherWDCondition__c';
import FLD_DIAGNOSIS_MEDS_PRESCRIBED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdMedicationPrescribed__c';
import FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedHealthEvaluation__c';
import FLD_DIAGNOSIS_ASSOCIATED_UAC from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedUAC__c';
import FLD_DIAGNOSIS_PARENT_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c.UAC_parentDiagnosis__c';
import OBJ_MEDICATION from '@salesforce/schema/UAC_medication__c';
import FLD_MEDICATION_NAME from '@salesforce/schema/UAC_medication__c.Name';
import FLD_MEDICATION_ASSOCIATED_DIAGNOSIS from '@salesforce/schema/UAC_medication__c.UAC_associatedDiagnosis__c';
import FLD_MEDICATION_DIAGNOSIS_STATUS from '@salesforce/schema/UAC_medication__c.UAC_diagnosisStatus__c';
import FLD_MEDICATION_DATE_STARTED from '@salesforce/schema/UAC_medication__c.UAC_dateStarted__c';
import FLD_MEDICATION_DATE_DISCONTINUED from '@salesforce/schema/UAC_medication__c.UAC_dateDiscontinued__c';
import FLD_MEDICATION_DOSE from '@salesforce/schema/UAC_medication__c.UAC_dose__c';
import FLD_MEDICATION_DIRECTION from '@salesforce/schema/UAC_medication__c.UAC_direction__c';
import FLD_MEDICATION_PSYCHOTROPIC from '@salesforce/schema/UAC_medication__c.UAC_psychotropic__c';
import FLD_MEDICATION_DISCHARGED_WITH_MEDS from '@salesforce/schema/UAC_medication__c.UAC_dischargedWithMedication__c';
import FLD_MEDICATION_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_medication__c.UAC_associatedHealthEvaluation__c';
import FLD_MEDICATION_REASON_FOR_MED from '@salesforce/schema/UAC_medication__c.UAC_reasonForMedication__c';

const OBJ_DIAGNOSIS_OUTCOMES = 'Diagnosis_Outcomes__r';
const PREV_DIAGNOSIS_TABLE_TITLE = 'Previously Entered Mental Health Diagnosis';
const DIAGNOSIS_TABLE_TITLE = 'New Mental Health Diagnosis';
const MEDICATION_TABLE_TITLE = 'New Medications';
const PREV_DIAGNOSIS_TABLE_COLUMNS = [
  { name: FLD_DIAGNOSIS_NAME.fieldApiName },
  { name: FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true },
  { name: FLD_DIAGNOSIS_CATEGORY.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName },
  { name: FLD_DIAGNOSIS_STATUS.fieldApiName }
];
const DIAGNOSIS_TABLE_COLUMNS = [
  { name: FLD_DIAGNOSIS_NAME.fieldApiName },
  { name: FLD_DIAGNOSIS_STATUS.fieldApiName },
  { name: FLD_DIAGNOSIS_CATEGORY.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName },
  { label: 'Ruled Out/Related Condition Id', name: FLD_DIAGNOSIS_PARENT_DIAGNOSIS.fieldApiName }
];
const MEDICATION_TABLE_COLUMNS = [
  { name: FLD_MEDICATION_ASSOCIATED_DIAGNOSIS.fieldApiName },
  { name: FLD_MEDICATION_DIAGNOSIS_STATUS.fieldApiName },
  { name: FLD_MEDICATION_NAME.fieldApiName },
  { name: FLD_MEDICATION_REASON_FOR_MED.fieldApiName },
  { name: FLD_MEDICATION_DATE_STARTED.fieldApiName },
  { name: FLD_MEDICATION_DATE_DISCONTINUED.fieldApiName },
  { name: FLD_MEDICATION_DOSE.fieldApiName },
  { name: FLD_MEDICATION_DIRECTION.fieldApiName },
  { name: FLD_MEDICATION_PSYCHOTROPIC.fieldApiName },
  { name: FLD_MEDICATION_DISCHARGED_WITH_MEDS.fieldApiName }
];
const BTN_ADD_MEDICATION = { name: 'addMedication', label: 'Medications', iconName: 'utility:add' };
const PREV_DIAGNOSIS_ADDITIONAL_BUTTONS = [
  {
    name: 'examOutcome',
    label: 'Exam Outcome',
    variant: 'brand',
    iconName: 'utility:record_update',
    iconVariant: 'inverse'
  },
  BTN_ADD_MEDICATION
];
const DIAGNOSIS_ADDITIONAL_BUTTONS = [
  BTN_ADD_MEDICATION
]

export default class UacMentalDiagnosisAndMedicationTable extends LightningElement {

  @api
  get healthEvaluationRecord() {
    return this._healthEvaluationRecord;
  }
  set healthEvaluationRecord(value) {
    this._healthEvaluationRecord = JSON.parse(JSON.stringify(value));
    this.healthEvaluationRecordTypeId = value.RecordTypeId;
  }
  @api validationRan = false; // Used to track if flow has ran validate method
  @api prevDiagnosisTableTitle = PREV_DIAGNOSIS_TABLE_TITLE;
  @api diagnosisTableTitle = DIAGNOSIS_TABLE_TITLE;
  @api medicationTableTitle = MEDICATION_TABLE_TITLE;


  @track isLoading = true;
  @track errors = {};
  @track healthEvaluationRecordTypeId;
  @track healthEvalFields = [];
  healthEvalPicklistValues;
  _healthEvaluationRecord;
  validated = false;

  get healthEvaluationId() {
    return this.healthEvaluationRecord.Id;
  }

  get uacId() {
    return this.healthEvaluationRecord[FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName];
  }

  objApiNameDiagnosis = OBJ_DIAGNOSIS.objectApiName;
  objApiNameMedication = OBJ_MEDICATION.objectApiName;
  prevDiagnosisColumns = PREV_DIAGNOSIS_TABLE_COLUMNS;
  prevDiagnosisAdditionalButtons = PREV_DIAGNOSIS_ADDITIONAL_BUTTONS;

  get diagnosisTableColumns() {
    return DIAGNOSIS_TABLE_COLUMNS;
  }

  diagnosisTableAdditionalFields = [FLD_DIAGNOSIS_MEDS_PRESCRIBED.fieldApiName];
  diagnosisTableAdditionalButtons = DIAGNOSIS_ADDITIONAL_BUTTONS;
  medicationTableColumns = MEDICATION_TABLE_COLUMNS;

  get prevDiagnosisTableFilter() {
    let queryFilter =
      `${FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    queryFilter +=
      ` AND ${FLD_DIAGNOSIS_STATUS.fieldApiName} IN ('${LBL_DIAGNOSIS_STATUS_WORKING}','${LBL_DIAGNOSIS_STATUS_FINAL}')`;
    queryFilter += ` AND (RecordType.Name='${LBL_RECORD_TYPE_DIAGNOSIS_MHD}' OR ${FLD_DIAGNOSIS_CATEGORY.fieldApiName}='${LBL_BEHAVIORAL_MENTAL_HEALTH_CONCERN}')`;
    queryFilter += ` AND ${FLD_DIAGNOSIS_DISCONTINUED.fieldApiName}=FALSE`;
    return queryFilter;
  }

  get prevDiagnosisChildRelationshipsQuery() {
    return [{
      objectApiName: OBJ_DIAGNOSIS_OUTCOMES,
      fieldsToQuery: ['Id'],
      filter: `${FLD_DIAGNOSIS_OUTCOME_ASSOCIATED_HEALTH_EVAL.fieldApiName}='${this.healthEvaluationId}'`
    }];
  }

  get diagnosisTableFilter() {
    return `${FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName}='${this.healthEvaluationId}'`;
  }

  get medicationTableFilter() {
    return `${FLD_MEDICATION_ASSOCIATED_HEALTH_EVAL.fieldApiName}='${this.healthEvaluationId}'`;
  }

  get prevDiagnosisTable() {
    return this.template.querySelector('.uac-prev-diagnosis-table');
  }

  get diagnosisTable() {
    return this.template.querySelector('.uac-diagnosis-table')
  }

  get medicationTable() {
    return this.template.querySelector('.uac-medication-table')
  }

  get outcomeForm() {
    return this.template.querySelector('c-uac-diagnosis-outcome');
  }

  get diagnosisForm() {
    return this.template.querySelector('c-uac-diagnosis-form');
  }

  get medicationForm() {
    return this.template.querySelector('c-uac-medication-form');
  }

  handlePrevDiagnosisRowAction(event) {
    const action = event.detail.action;
    const diagnosisRecord = event.detail.record;
    const outcomes = diagnosisRecord[OBJ_DIAGNOSIS_OUTCOMES];
    const outcomeId = (outcomes && outcomes.length > 0) ? outcomes[0].Id : null;
    switch (action) {
    case "examOutcome":
      this.outcomeForm.show(outcomeId, this.healthEvaluationId, diagnosisRecord.Id);
      break;
    case "addMedication":
      this.medicationForm.show(null, diagnosisRecord.Id, this.healthEvaluationId);
      break;
    default:
      break;
    }
  }

  onAddDiagnosisClick() {
    this.diagnosisForm.show(null, this.healthEvaluationId);
  }

  handleDiagnosisRowAction(event) {
    const action = event.detail.action;
    const diagnosisRecord = event.detail.record;
    if (action === 'addMedication') {
      this.medicationForm.show(null, diagnosisRecord.Id, this.healthEvaluationId);
    } else if (action === 'edit') {
      this.diagnosisForm.show(diagnosisRecord.Id, this.healthEvaluationId);
    } else if (action === 'delete') {
      let diagnosisMeds = this.medicationTable.getRecords()
        .filter((record) => {
          return (
            record[
              FLD_MEDICATION_ASSOCIATED_DIAGNOSIS.fieldApiName
            ] === diagnosisRecord.Id
          );
        });
      if (diagnosisMeds.length > 0) {
        this.showToastMessage('Error',
          'Please delete all associated medication records prior to deleting the diagnosis record',
          'error');
      } else {
        this.diagnosisTable.delete(diagnosisRecord.Id);
      }
    }
  }

  handleMedicationRowAction(event) {
    const action = event.detail.action;
    const medicationRecord = event.detail.record;
    if (action === 'edit') {
      this.medicationForm.show(medicationRecord.Id, medicationRecord
        .UAC_associatedDiagnosis__c,
        this.healthEvaluationId);
    }
  }

  handleDiagnosisOutcomeSaveSuccess() {
    this.prevDiagnosisTable.refresh();
    this.diagnosisTable.refresh();
  }

  handleDiagnosisSaveSuccess() {
    this.diagnosisTable.refresh();
    this.medicationTable.refresh();
  }

  handleMedicationSaveSuccess() {
    this.medicationTable.refresh();
  }

  showToastMessage(title, message, variant) {
    this._isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  initialize() {
    if (this.prevDiagnosisTable.isLoading ||
      this.medicationTable.isLoading ||
      this.diagnosisTable.isLoading) {
      return;
    }

    let actionsToDisable = ['addMedication'];
    let recordIds = [];
    this.prevDiagnosisTable.getRecords()
      .forEach((record) => {
        const outcomes = record[OBJ_DIAGNOSIS_OUTCOMES];
        if (!outcomes) {
          recordIds.push(record.Id);
        }
      });
    this.prevDiagnosisTable.disableActionsForRecordIds(actionsToDisable, recordIds);

    this.isLoading = false;
    if (this.validationRan && !this.validated) {
      this.validated = true;
      this.validate();
    }
  }

  @api
  validate() {
    this.errors = {};
    this.dispatchEvent(new FlowAttributeChangeEvent('validationRan', true));
    return { isValid: true };
  }
}