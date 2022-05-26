import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import LBL_HEALTH_ASSESSMENT from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import OBJ_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c';
import FLD_DIAGNOSIS_NAME from '@salesforce/schema/UAC_diagnosis__c.Name';
import FLD_DIAGNOSIS_STATUS from '@salesforce/schema/UAC_diagnosis__c.UAC_status__c';
import FLD_DIAGNOSIS_CATEGORY from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCategory__c';
import FLD_DIAGNOSIS_CONDITION from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCondition__c';
import FLD_DIAGNOSIS_CONDITION_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_specifyOtherWDCondition__c';
import FLD_DIAGNOSIS_CONDITION_TYPE from '@salesforce/schema/UAC_diagnosis__c.UAC_WDConditionType__c';
import FLD_DIAGNOSIS_ISOLATION_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdIsIsolationQuarantineRequired__c';
import FLD_DIAGNOSIS_DISCHARGED_DELAY from '@salesforce/schema/UAC_diagnosis__c.UAC_wdWillDischargeNeedtobeDelayed__c';
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

const OBJ_DIAGNOSIS_OUTCOMES = 'Diagnosis_Outcomes__r';
const PREV_DIAGNOSIS_TABLE_TITLE = 'Previously Entered Diagnosis';
const DIAGNOSIS_TABLE_TITLE = 'New Diagnosis';
const LBL_DIAGNOSIS_STATUS_WORKING = 'Working';
const LBL_DIAGNOSIS_STATUS_FINAL = 'Final';
const PREV_DIAGNOSIS_TABLE_COLUMNS = [
  { name: FLD_DIAGNOSIS_NAME.fieldApiName, clickable: true },
  { name: FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true },
  { name: FLD_DIAGNOSIS_CATEGORY.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName },
  { name: FLD_DIAGNOSIS_STATUS.fieldApiName }
];

const YES_NO_OPTIONS = [
  { label: LBL_YES, value: LBL_YES },
  { label: LBL_NO, value: LBL_NO }
];

const LBL_DIAGNOSES_MEDS_REFERRALS =
  'Minor with Complaints, Symptoms, Diagnoses/Conditions; Medications Prescribed (including OTC); Referrals Made';

export default class UacDiagnosisAndMedicationTable extends LightningElement {

  @api relatedTo;
  @api healthEvaluationId;
  @api uacId;
  @api validationRan; // Used to track if flow has ran validate method
  @api
  get diagnosesMedsReferrals() {
    return this._diagnosesMedsReferrals;
  }
  set diagnosesMedsReferrals(value) {
    this._diagnosesMedsReferrals = value;
  }

  @api prevDiagnosisTableTitle = PREV_DIAGNOSIS_TABLE_TITLE;
  @api diagnosisTableTitle = DIAGNOSIS_TABLE_TITLE;

  get isHealthAssessment() {
    return this.relatedTo === LBL_HEALTH_ASSESSMENT;
  }

  prevDiagnosisObjectApiName = OBJ_DIAGNOSIS.objectApiName;
  prevDiagnosisColumns = PREV_DIAGNOSIS_TABLE_COLUMNS;
  prevDiagnosisAdditionalButtons = [
    {
      name: 'examOutcome',
      label: 'Exam Outcome',
      variant: 'brand',
      iconName: 'utility:record_update',
      iconVariant: 'inverse'
    },
    { name: 'addMedication', label: 'Medications', iconName: 'utility:add' },
    { name: 'secondaryCondition', label: 'Secondary Condition', iconName: 'utility:add' }
  ];
  prevDiagnosisChildRelationshipsToQuery = [OBJ_DIAGNOSIS_OUTCOMES];

  get prevDiagnosisFilter() {
    let queryFilter =
      `${FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    queryFilter +=
      ` AND ${FLD_DIAGNOSIS_STATUS.fieldApiName} IN ('${LBL_DIAGNOSIS_STATUS_WORKING}','${LBL_DIAGNOSIS_STATUS_FINAL}')`;
    return queryFilter;
  }

  handlePrevDiagnosisLoadComplete() {
    let actionsToDisable = ['addMedication', 'secondaryCondition'];
    let recordIds = [];
    this.prevDiagnosisTable.getRecords()
      .forEach((record) => {
        const outcomes = record[OBJ_DIAGNOSIS_OUTCOMES];
        if (!outcomes) {
          recordIds.push(record.Id);
        }
      });
    this.prevDiagnosisTable.disableActionsForRecordIds(actionsToDisable, recordIds);
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
    case "secondaryCondition":
      this.diagnosisForm.show(null, this.healthEvaluationId, diagnosisRecord.Id);
      break;
    default:
      break;
    }
  }

  _diagnosesMedsReferrals;
  validated = false;
  @track isLoading = true;
  @track errors = {};

  objApiNameDiagnosis = OBJ_DIAGNOSIS.objectApiName;
  objApiNameMedication = OBJ_MEDICATION.objectApiName;
  diagnosesMedsReferralsOptions = YES_NO_OPTIONS;
  lblDiagnosesMedsReferrals = LBL_DIAGNOSES_MEDS_REFERRALS;
  get diagnosisTableColumns() {
    let columns = [
      { name: FLD_DIAGNOSIS_NAME.fieldApiName },
      { name: FLD_DIAGNOSIS_STATUS.fieldApiName },
      { name: FLD_DIAGNOSIS_CATEGORY.fieldApiName },
      { name: FLD_DIAGNOSIS_CONDITION.fieldApiName },
      { name: FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName },
      { name: FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName },
      { name: FLD_DIAGNOSIS_ISOLATION_REQUIRED.fieldApiName },
      { name: FLD_DIAGNOSIS_DISCHARGED_DELAY.fieldApiName }
    ];
    if (this.isHealthAssessment) {
      columns.push({ name: FLD_DIAGNOSIS_PARENT_DIAGNOSIS.fieldApiName });
    }
    return columns;
  }
  diagnosisTableAdditionalFields = [FLD_DIAGNOSIS_MEDS_PRESCRIBED.fieldApiName];
  diagnosisTableAdditionalButtons = [
    { name: 'addMedication', label: 'Medications', iconName: 'utility:add' }
  ]
  medicationTableColumns = [
    { name: FLD_MEDICATION_ASSOCIATED_DIAGNOSIS.fieldApiName },
    { name: FLD_MEDICATION_DIAGNOSIS_STATUS.fieldApiName },
    { name: FLD_MEDICATION_NAME.fieldApiName },
    { name: FLD_MEDICATION_DATE_STARTED.fieldApiName },
    { name: FLD_MEDICATION_DATE_DISCONTINUED.fieldApiName },
    { name: FLD_MEDICATION_DOSE.fieldApiName },
    { name: FLD_MEDICATION_DIRECTION.fieldApiName },
    { name: FLD_MEDICATION_PSYCHOTROPIC.fieldApiName },
    { name: FLD_MEDICATION_DISCHARGED_WITH_MEDS.fieldApiName }
  ];

  get diagnosisTableFilter() {
    return `${FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName}='${this.healthEvaluationId}'`;
  }

  get medicationTableFilter() {
    return `${FLD_MEDICATION_ASSOCIATED_HEALTH_EVAL.fieldApiName}='${this.healthEvaluationId}'`;
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

  get medicationTable() {
    return this.template.querySelector('.uac-medication-table')
  }

  get diagnosisTable() {
    return this.template.querySelector('.uac-diagnosis-table')
  }

  get prevDiagnosisTable() {
    return this.template.querySelector('.uac-prev-diagnosis-table');
  }

  hideTables() {
    this.template.querySelector('.uac-diagnosis-table-container')
      .classList.add('slds-hide');
    this.template.querySelector('.uac-medication-table-container')
      .classList.add('slds-hide');
  }

  showTables() {
    this.template.querySelector('.uac-diagnosis-table-container')
      .classList.remove('slds-hide');
    this.template.querySelector('.uac-medication-table-container')
      .classList.remove('slds-hide');
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

  handleFieldChange(event) {
    // const fieldName = event.detail.name;
    const value = event.detail.value;
    this._diagnosesMedsReferrals = value;
    if (this._diagnosesMedsReferrals === LBL_YES) {
      this.showTables();
    } else {
      this.hideTables();
    }
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
    if (this.medicationTable.isLoading || this.diagnosisTable.isLoading) {
      return;
    }
    this.isLoading = false;
    if (this.validationRan && !this.validated) {
      this.validated = true;
      this.validate();
    }
    if (this._diagnosesMedsReferrals === LBL_YES || this.isHealthAssessment) {
      this.showTables();
    }
  }

  @api
  validate() {
    const cmpDiagnosesMedsReferrals = this.template.querySelector('c-uac-input');
    this.errors = {};
    this.dispatchEvent(new FlowAttributeChangeEvent('validationRan', true));
    if (!this.isHealthAssessment && !cmpDiagnosesMedsReferrals.validate()) {
      return {
        isValid: false,
        errorMessage: ' '
      };
    } else if (this._diagnosesMedsReferrals === LBL_NO && !this.diagnosisTable.isEmpty()) {
      this.errors.diagnosesMedsReferrals =
        `In order to save the Diagnosis and Plan section when "${this.lblDiagnosesMedsReferrals}" is No, all diagnosis/medications records must be deleted.`;
      /* Alternative - On table related error, show tables even if value for parent question is No and display errors
      this.showTables();
      this.errors._diagnosesMedsReferrals =
        `In order to save the Diagnosis and Plan section when "${this.lblDiagnosesMedsReferrals}" is No, all diagnosis records must be deleted.`;
      if (!this.medicationTable.isEmpty) {
        this.errors.medicationTable =
          `In order to save the Diagnosis and Plan section when "${this.lblDiagnosesMedsReferrals}" is No, all medication records must be deleted.`;
      }
      */
      return {
        isValid: false,
        errorMessage: ' '
      };
    } else if (this._diagnosesMedsReferrals === LBL_YES && this.diagnosisTable.isEmpty()) {
      this.showTables();
      this.errors.diagnosisTable =
        `In order to save the Diagnosis and Plan section when "${this.lblDiagnosesMedsReferrals}" is Yes, at least one diagnosis record must be entered.`;
      return {
        isValid: false,
        errorMessage: ''
      };
    } else if (this._diagnosesMedsReferrals === LBL_YES) {
      let diagnosesWithMeds = this.medicationTable.getRecords()
        .map((record) => {
          return record[FLD_MEDICATION_ASSOCIATED_DIAGNOSIS
            .fieldApiName];
        });
      diagnosesWithMeds = new Set(diagnosesWithMeds);

      let diagnosesWithoutMeds = this.diagnosisTable.getRecords()
        .filter((record) => {
          return (
            record[FLD_DIAGNOSIS_MEDS_PRESCRIBED.fieldApiName] === LBL_YES &&
            !diagnosesWithMeds.has(record.Id)
          );
        })
        .map((record) => { return record.Name; });
      if (diagnosesWithoutMeds.length > 0) {
        this.errors.diagnosisTable =
          'Please ensure medication records are added for all diagnoses with Medications Prescribed as Yes.';
        this.errors.diagnosisTable +=
          ` Medications required for following diagnoses: ${diagnosesWithoutMeds.join(', ')}`;
        return {
          isValid: false,
          errorMessage: ''
        }
      }
    }
    return { isValid: true };
  }
}