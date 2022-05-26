import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { reduceErrors } from 'c/uacUtils'
import LBL_OTHER from '@salesforce/label/c.UAC_other';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import LBL_DIAGNOSIS_STATUS_WORKING from '@salesforce/label/c.UAC_diagnosisStatusWorking';
import LBL_DIAGNOSIS_STATUS_FINAL from '@salesforce/label/c.UAC_statusFinal';
import LBL_RECORD_TYPE_IME from '@salesforce/label/c.UAC_healthEvaluationRecordTypeIME';
import OBJ_HEALTH_EVAL from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS from '@salesforce/schema/UAC_healthEvaluation__c.UAC_diagnosesMedsReferrals__c';
import FLD_HEALTH_EVAL_ASSESSMENT_REASON from '@salesforce/schema/UAC_healthEvaluation__c.UAC_reasonforAssessment__c';
import FLD_HEALTH_EVAL_ASSESSMENT_REASON_OTHER from '@salesforce/schema/UAC_healthEvaluation__c.UAC_otherReasonforAssessment__c';
import FLD_DIAGNOSIS_OUTCOME_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_diagnosisOutcome__c.UAC_associatedHealthEvaluation__c';
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
import FLD_DIAGNOSIS_DISCONTINUED from '@salesforce/schema/UAC_diagnosis__c.UAC_discontinued__c';
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
const MEDICATION_TABLE_TITLE = 'New Medications';
const LBL_DIAGNOSES_MEDS_REFS =
  'Was this Assessment Related to any Previously Entered Diagnoses or were any New Diagnoses Identified?';
const YES_NO_OPTIONS = [
  { label: LBL_YES, value: LBL_YES },
  { label: LBL_NO, value: LBL_NO }
];
const HEALTH_EVAL_FIELDS = [
{
  name: FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS.fieldApiName,
  type: 'radio',
  required: true,
  options: YES_NO_OPTIONS
},
{
  name: FLD_HEALTH_EVAL_ASSESSMENT_REASON.fieldApiName,
  type: 'picklist',
  required: true,
  hide: true
},
{
  name: FLD_HEALTH_EVAL_ASSESSMENT_REASON_OTHER.fieldApiName,
  type: 'text',
  required: true,
  hide: true
}];
const PREV_DIAGNOSIS_TABLE_COLUMNS = [
  { name: FLD_DIAGNOSIS_NAME.fieldApiName },
  { name: FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName, clickable: true },
  { name: FLD_DIAGNOSIS_CATEGORY.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName },
  { name: FLD_DIAGNOSIS_STATUS.fieldApiName }
];
const DIAGNOSIS_TABLE_COLUMNS = [
  { name: FLD_DIAGNOSIS_NAME.fieldApiName },
  { name: FLD_DIAGNOSIS_STATUS.fieldApiName },
  { name: FLD_DIAGNOSIS_CATEGORY.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName },
  { name: FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName },
  { name: FLD_DIAGNOSIS_ISOLATION_REQUIRED.fieldApiName },
  { name: FLD_DIAGNOSIS_DISCHARGED_DELAY.fieldApiName },
  { name: FLD_DIAGNOSIS_PARENT_DIAGNOSIS.fieldApiName }
];
const MEDICATION_TABLE_COLUMNS = [
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

export default class UacDiagnosisAndMedicationTableV2 extends LightningElement {

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

  @track healthEvalObjectInfo;
  @track isLoading = true;
  @track errors = {};
  @track healthEvaluationRecordTypeId;
  @track healthEvalFields = [];
  healthEvalPicklistValues;
  _healthEvaluationRecord;
  validated = false;
  healthEvalInitialized = false;
  tablesInitialized = false;
  diagnosisOutcomeSave = false;

  /**
   * @description Method to get object info and populate field attributes for label and required
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_HEALTH_EVAL.objectApiName })
  wiredHealthEvalObjectInfo({ data, error }) {
    if (data) {
      this.healthEvalObjectInfo = data;
      this.initializeHealthEval();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, {
    objectApiName: OBJ_HEALTH_EVAL,
    recordTypeId: '$healthEvaluationRecordTypeId'
  })
  wiredHealthEvalPicklistValues({ data, error }) {
    if (data) {
      this.healthEvalPicklistValues = data;
      this.initializeHealthEval();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get healthEvaluationId() {
    return this.healthEvaluationRecord.Id;
  }

  get uacId() {
    return this.healthEvaluationRecord[FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName];
  }

  objApiNameDiagnosis = OBJ_DIAGNOSIS.objectApiName;
  objApiNameMedication = OBJ_MEDICATION.objectApiName;
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

  get diagnosisTableColumns() {
    return DIAGNOSIS_TABLE_COLUMNS;
  }

  diagnosisTableAdditionalFields = [FLD_DIAGNOSIS_MEDS_PRESCRIBED.fieldApiName];
  diagnosisTableAdditionalButtons = [
    { name: 'addMedication', label: 'Medications', iconName: 'utility:add' }
  ]
  medicationTableColumns = MEDICATION_TABLE_COLUMNS;

  get prevDiagnosisTableFilter() {
    let queryFilter =
      `${FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName}!='${this.healthEvaluationId}'`;
    queryFilter += ` AND ${FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName}='${this.uacId}'`;
    queryFilter +=
      ` AND ${FLD_DIAGNOSIS_STATUS.fieldApiName} IN ('${LBL_DIAGNOSIS_STATUS_WORKING}','${LBL_DIAGNOSIS_STATUS_FINAL}')`;
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

  hideTables() {
    this.template.querySelector('.uac-prev-diagnosis-table-container')
      .classList.add('slds-hide');
    this.template.querySelector('.uac-diagnosis-table-container')
      .classList.add('slds-hide');
    this.template.querySelector('.uac-medication-table-container')
      .classList.add('slds-hide');
  }

  showTables() {
    this.template.querySelector('.uac-prev-diagnosis-table-container')
      .classList.remove('slds-hide');
    this.template.querySelector('.uac-diagnosis-table-container')
      .classList.remove('slds-hide');
    this.template.querySelector('.uac-medication-table-container')
      .classList.remove('slds-hide');
  }

  initializeHealthEval() {
    if (!this.healthEvalObjectInfo ||
      !this.healthEvalPicklistValues ||
      !this.healthEvaluationRecord) {
      return;
    }

    let isIME = this.healthEvalObjectInfo.recordTypeInfos[this.healthEvaluationRecordTypeId]
      .name === LBL_RECORD_TYPE_IME;

    this.healthEvalFields = JSON.parse(JSON.stringify(HEALTH_EVAL_FIELDS))
      .filter(fld => {
        return (isIME) ? fld.name === FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS
          .fieldApiName :
          true;
      });
    this.healthEvalFields.forEach((fld) => {
      fld.helpText = this.healthEvalObjectInfo.fields[fld.name].inlineHelpText;
      fld.label = this.healthEvalObjectInfo.fields[fld.name].label;
      if (fld.name === FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS.fieldApiName) {
        fld.label = LBL_DIAGNOSES_MEDS_REFS;
      }
      if (fld.type === 'picklist') {
        let options = [];
        for (let option of this.healthEvalPicklistValues.picklistFieldValues[
            fld.name
          ].values) {
          options.push({ label: option.label, value: option.value });
        }
        fld.options = options;
      }
      let cmp = this;
      if (!Object.prototype.hasOwnProperty.call(fld, 'value')) {
        Object.defineProperty(fld, 'value', {
          get: function () {
            return cmp.healthEvaluationRecord[this.name];
          },
          set: function (value) {
            cmp.healthEvaluationRecord[this.name] = value;
          }
        });
      }
      if (!Object.prototype.hasOwnProperty.call(fld, 'containerClass')) {
        Object.defineProperty(fld, 'containerClass', {
          get: function () {
            return this.hide ? 'slds-grid slds-hide' : 'slds-grid';
          }
        });
      }
    });
    this.checkConditionalRulesForHealthEval();
    this.healthEvalInitialized = true;
    this.runValidation();
    this.isLoading = false;
  }

  checkConditionalRulesForHealthEval() {
    this.healthEvalFields.forEach((fld) => {
      switch (fld.name) {
      case FLD_HEALTH_EVAL_ASSESSMENT_REASON.fieldApiName:
        fld.hide = (this.healthEvaluationRecord[FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS
            .fieldApiName] !==
          LBL_NO);
        break;
      case FLD_HEALTH_EVAL_ASSESSMENT_REASON_OTHER.fieldApiName:
        fld.hide = (this.healthEvaluationRecord[FLD_HEALTH_EVAL_ASSESSMENT_REASON
            .fieldApiName] !==
          LBL_OTHER);
        break;
      default:
        break;
      }
    });
    if (this.healthEvaluationRecord[FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS
        .fieldApiName] ===
      LBL_YES) {
      this.showTables();
    } else {
      this.hideTables();
    }
  }

  handleHealthEvalFieldChange(event) {
    const fieldName = event.detail.name;
    const value = event.detail.value;
    this.errors = {};
    this._healthEvaluationRecord[fieldName] = value;
    this.healthEvalFields.forEach((fld) => {
      if (fld.name === fieldName) fld.value = value;
    });
    this.checkConditionalRulesForHealthEval();
    if (!this.isLoading) {
      this.dispatchEvent(new FlowAttributeChangeEvent('healthEvaluationRecord',
        this._healthEvaluationRecord));
    }
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
    this.diagnosisOutcomeSave = true;
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

    this.isLoading = false;
    if (this.validationRan && !this.validated) {
      this.validated = true;
      this.validate();
    }
    if (this.healthEvaluationRecord[FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS
        .fieldApiName] ===
      LBL_YES) {
      this.showTables();
    }
    this.tablesInitialized = true;
    this.runValidation();
  }

  runValidation() {
    if (this.validationRan && this.healthEvalInitialized && this.tablesInitialized) {
      this.validate();
    }
  }

  @api
  validate() {
    this.errors = {};
    this.dispatchEvent(new FlowAttributeChangeEvent('validationRan', true));
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      return validSoFar && cmpValidity;
    }, true);
    let hasDiagnosisOutcome = false;
    this.prevDiagnosisTable.getRecords()
      .forEach((record) => {
        const outcomes = record[OBJ_DIAGNOSIS_OUTCOMES];
        if (outcomes && outcomes.length > 0) {
          hasDiagnosisOutcome = true;
        }
      });
    let lblDiagnosesMedsReferrals = LBL_DIAGNOSES_MEDS_REFS;
    let diagnosesMedsReferrals = this.healthEvaluationRecord[
      FLD_HEALTH_EVAL_DIAGNOSIS_MEDS_REFERRALS.fieldApiName];
    if (!isValid) {
      return {
        isValid: false,
        errorMessage: ' '
      };
    } else if (diagnosesMedsReferrals === LBL_NO && !this.diagnosisTable.isEmpty()) {
      this.errors.diagnosesMedsReferrals =
        `In order to save the Diagnosis and Plan section when "${lblDiagnosesMedsReferrals}" is No, all diagnosis/medication records must be deleted.`;
      return {
        isValid: false,
        errorMessage: ' '
      };
    } else if (diagnosesMedsReferrals === LBL_YES &&
      this.diagnosisTable.isEmpty() &&
      !hasDiagnosisOutcome && !this.diagnosisOutcomeSave) {
      this.showTables();
      this.errors.diagnosesMedsReferrals =
        `In order to save the Diagnosis and Plan section when "${lblDiagnosesMedsReferrals}" is Yes, at least one diagnosis record must be entered or at least one exam outcome must be associated.`;
      return {
        isValid: false,
        errorMessage: ''
      };
    }
    return { isValid: true };
  }

  rendered = false;

  renderedCallback() {
    if (!this.rendered) {
      this.rendered = true;
      this.initializeHealthEval();
    }
  }
}