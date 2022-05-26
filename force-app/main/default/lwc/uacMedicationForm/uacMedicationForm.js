import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/uacUtils'
import OBJ_MEDICATION from '@salesforce/schema/UAC_medication__c';
import FLD_ASSOCIATED_DIAGNOSIS from '@salesforce/schema/UAC_medication__c.UAC_associatedDiagnosis__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_medication__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_medication__c.UAC_associatedUAC__c';
import FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedHealthEvaluation__c';
import FLD_DIAGNOSIS_ASSOCIATED_UAC from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedUAC__c';
import FLD_DIAGNOSIS_ASSOCIATED_UAC_NAME from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedUAC__r.Name';
import FLD_DIAGNOSIS_CATEGORY from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCategory__c';
import FLD_DIAGNOSIS_CONDITION from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCondition__c';
import FLD_DIAGNOSIS_NAME from '@salesforce/schema/UAC_diagnosis__c.Name';
import FLD_DIAGNOSIS_STATUS from '@salesforce/schema/UAC_diagnosis__c.UAC_status__c';
import FLD_HEALTH_EVAL_RECORD_TYPE_NAME from '@salesforce/schema/UAC_healthEvaluation__c.RecordType.Name';
import FLD_REASON_FOR_MEDICATION from '@salesforce/schema/UAC_medication__c.UAC_reasonForMedication__c';
import LBL_RECORD_TYPE_HEALTH_EVAL_MHSR from '@salesforce/label/c.UAC_recordTypeMentalHealthServiceReport';

const TITLE_NEW = 'New Medication';
const TITLE_EDIT = 'Edit Medication';
const SECTION_MEDICATION_INFO = 'Medication Information';
const MEDICATION_FORM_SECTIONS = [SECTION_MEDICATION_INFO];
const SAVE_ERROR_TITLE = 'An error has occured while trying to save.';

export default class UacMedicationForm extends LightningElement {

  @api
  show(recordId, associatedDiagnosisId, associatedHealthEvaluationId) {
    this.recordId = recordId;
    this.associatedDiagnosisId = associatedDiagnosisId;
    this.associatedHealthEvaluationId = associatedHealthEvaluationId;
    this.showModal();
  }

  @track
  layout = { sections: [] }
  @track
  associatedDiagnosisId;
  @track
  associatedHealthEvaluationId;
  @track
  associatedUACId;
  @track
  diagnosisRecord;
  @track
  recordId;
  @track
  error;
  @track
  isLoading = false;
  healthEvalRecordType;

  objectApiName = OBJ_MEDICATION.objectApiName;
  fldAssociatedDiagnosis = FLD_ASSOCIATED_DIAGNOSIS.fieldApiName;
  fldAssociatedHealthEvaluation = FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName;
  fldAssociatedUAC = FLD_ASSOCIATED_UAC.fieldApiName;
  diagnosisFldAssociatedUAC = FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName;
  diagnosisFldCategory = FLD_DIAGNOSIS_CATEGORY.fieldApiName;
  diagnosisFldCondition = FLD_DIAGNOSIS_CONDITION.fieldApiName;
  diagnosisFldName = FLD_DIAGNOSIS_NAME.fieldApiName;
  diagnosisFldStatus = FLD_DIAGNOSIS_STATUS.fieldApiName;
  medicationFormSections = MEDICATION_FORM_SECTIONS;
  saveErrorTitle = SAVE_ERROR_TITLE;

  get title() {
    return (this.recordId) ? TITLE_EDIT : TITLE_NEW;
  }

  @wire(getRecord, {
    recordId: "$associatedHealthEvaluationId",
    fields: [
      FLD_HEALTH_EVAL_RECORD_TYPE_NAME
    ]
  })
  wiredHealthEvalGetRecord({ data, error }) {
    if (data) {
      this.healthEvalRecordType = data.fields.RecordType.value.fields.Name.value
      //this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getRecord, {
    recordId: "$associatedDiagnosisId",
    fields: [
      FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVALUATION,
      FLD_DIAGNOSIS_ASSOCIATED_UAC,
      FLD_DIAGNOSIS_ASSOCIATED_UAC_NAME,
      FLD_DIAGNOSIS_CATEGORY,
      FLD_DIAGNOSIS_CONDITION,
      FLD_DIAGNOSIS_NAME,
      FLD_DIAGNOSIS_STATUS
    ]
  }) wiredDiagnosisRecord({ data, error }) {
    if (data) {
      this.diagnosisRecord = data;
      this.associatedUACId = this.diagnosisRecord.fields[
        FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName
      ].value;
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get medicationForm() {
    return this.template.querySelector('c-uac-record-edit-form');
  }

  get isMHSR() {
    return this.healthEvalRecordType === LBL_RECORD_TYPE_HEALTH_EVAL_MHSR;
  }

  showModal() {
    this.template.querySelector('c-uac-modal')
      .show();
  }

  hideModal() {
    this.template.querySelector('c-uac-modal')
      .hide();
  }

  handleLoad() {
    this.isLoading = false;
    this.checkConditionalRules();
  }

  checkConditionalRules() {
    const medicationRecord = this.medicationForm.getRecord();
    this.medicationForm.form.sections.forEach((section) => {
      section.layoutRows.forEach((layoutRow) => {
        layoutRow.layoutItems.forEach((layoutItem) => {
          layoutItem.layoutComponents.forEach((layoutComponent) => {
            if (layoutComponent.isField) {
              layoutComponent.value = medicationRecord[layoutComponent
                .apiName];
              switch (layoutComponent.apiName) {
              case FLD_REASON_FOR_MEDICATION.fieldApiName:
                layoutComponent.hide = !this.isMHSR;
                break;
              default:
                break;
              }
              if (layoutComponent.hide || section.hide) {
                layoutComponent.value = (typeof (layoutComponent.value) ===
                  "boolean") ? false : null;
              }
              medicationRecord[layoutComponent.apiName] = layoutComponent.value;
            }
          })
        })
      });
    });
  }

  handleFieldChange() {
    this.checkConditionalRules();
  }

  handleClose() {
    this.isLoading = false;
    this.error = undefined;
    this.hideModal();
  }

  handleSave() {
    this.isLoading = true;
    this.error = undefined;
    this.medicationForm.save();
  }

  handleSuccess() {
    this.dispatchEvent(new CustomEvent('success', {}));
    this.handleClose();
    this.isLoading = false;
  }

  handleError(event) {
    this.isLoading = false;
    this.error = event.detail.detail;
    this.template.querySelector('c-uac-modal')
      .scrollToTop();
  }

  showToastMessage(title, message, variant) {
    this.isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }
}