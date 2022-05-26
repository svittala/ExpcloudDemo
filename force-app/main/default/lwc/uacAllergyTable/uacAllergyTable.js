import { LightningElement, api, track, wire } from 'lwc';
import {
  getObjectInfo,
  getPicklistValuesByRecordType
} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import OBJ_ALLERGY from '@salesforce/schema/UAC_allergy__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_allergy__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_allergy__c.UAC_associatedUAC__c';
import FLD_ALLERGY_TYPE from '@salesforce/schema/UAC_allergy__c.UAC_allergyType__c';
import FLD_ALLERGEN from '@salesforce/schema/UAC_allergy__c.UAC_allergen__c';
import FLD_REACTION from '@salesforce/schema/UAC_allergy__c.UAC_reaction__c';
import getAllergyList from '@salesforce/apex/UAC_allergyTableController.getAllergyList';
import upsertAllergyList from '@salesforce/apex/UAC_allergyTableController.upsertAllergyList';
import deleteAllergyList from '@salesforce/apex/UAC_allergyTableController.deleteAllergyList';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import { reduceErrors } from 'c/uacUtils'

const LST_FIELD = [
  { name: FLD_ALLERGY_TYPE.fieldApiName, type: 'picklist', required: true },
  { name: FLD_ALLERGEN.fieldApiName, type: 'text', required: true },
  { name: FLD_REACTION.fieldApiName, type: 'text', required: true }
];
const ALLERGY_OPTIONS = [
  { label: LBL_YES, value: LBL_YES },
  { label: LBL_NO, value: LBL_NO }
];
const OPT_NONE = { label: '--None--', value: '' };

export default class UacAllergyTable extends LightningElement {
  @api uacId;
  @api healthEvaluationId;
  @api allergyReportedLabel = 'Allergies Reported?';
  @api HEvalRecordTypeName = 'Initial Medical Exam';
  @api
  get allergiesReported() {
    return this._allergiesReported;
  }
  set allergiesReported(value) {
    this._allergiesReported = value;
    this.showTable(this._allergiesReported === 'Yes');
  }

  @track lstField = LST_FIELD;
  @track _objectInfo;
  @track tableContainerClass = 'slds-hide';

  allergyOptions = ALLERGY_OPTIONS;

  handleAllergyReportedChange(event) {
    this._allergiesReported = event.detail.value;
    this.showTable(this._allergiesReported === 'Yes');
  }

  @track _allergiesReported;

  get uacTable() {
    return this.template.querySelector('c-uac-table');
  }

  get defaultNewRecord() {
    return JSON.parse(`{
        "${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}": "${this.healthEvaluationId}",
        "${FLD_ASSOCIATED_UAC.fieldApiName}": "${this.uacId}"
      }`);
  }

  showTable(val) {
    this.tableContainerClass = (val) ? 'slds-show' : 'slds-hide';
  }

  @wire(getObjectInfo, { objectApiName: OBJ_ALLERGY })
  wiredObjectInfo({ data, error }) {
    if (data) {
      this._objectInfo = data;
      for (let field of this.lstField) {
        field.label = data.fields[field.name].label;
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, {
    recordTypeId: '$_objectInfo.defaultRecordTypeId',
    objectApiName: OBJ_ALLERGY
  })
  wiredGetPicklistValuesByRecordType({ data, error }) {
    if (data) {
      let lstField = [...this.lstField];
      for (let field of this.lstField) {
        if (field.type === 'picklist') {
          field.options = [OPT_NONE];
          data.picklistFieldValues[field.name].values.forEach(key => {
            field.options.push({ label: key.label, value: key.value });
          });
        }
        this.lstField = lstField;
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  handleSave(event) {
    const records = event.detail.records;
    upsertAllergyList({ strRecordList: JSON.stringify(records) })
      .then(response => {
        if (response.isSuccess) {
          if (Object.keys(response.data.errorMap)
            .length <= 0) {
            this.showToastMessage('Success', LBL_SAVE_SUCCESS, 'success');
          }
          this.uacTable.handleSaveResponse(response.data.successMap, response.data.errorMap);
        } else {
          this.uacTable.addError(response.error);
        }
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      })
  }

  handleDelete(event) {
    const records = event.detail.records;
    deleteAllergyList({ strRecordList: JSON.stringify(records) })
      .then(response => {
        if (response.isSuccess) {
          if (Object.keys(response.data.errorMap)
            .length <= 0) {
            this.showToastMessage('Success', LBL_DELETE_SUCCESS, 'success');
          }
          this.uacTable.handleDeleteResponse(response.data.successMap, response.data.errorMap)
        } else {
          this.uacTable.addError(response.error);
        }
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  getAllergyRecords() {
    getAllergyList({ healthEvaluationId: this.healthEvaluationId })
      .then(response => {
        this.uacTable.records = response;
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  connectedCallback() {
    this.getAllergyRecords();
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  @api validate() {
    const cmpAllergiesReported = this.template.querySelector('c-uac-input');
    if (!cmpAllergiesReported.validate()) {
      return {
        isValid: false,
        errorMessage: 'Please enter some valid input. Input is not optional.'
      };
    } else if (this.allergiesReported === LBL_NO && this.uacTable.records.length > 0) {
      if (this.HEvalRecordTypeName === 'Health Assessment') {
        return {
          isValid: false,
          errorMessage: 'In order to save the History & Physical Assessment section when "New Allergies Reported" is No, all allergy records must be deleted.'
        };
      }
      return {
        isValid: false,
        errorMessage: 'In order to save the History and Physical Assessment section when "Allergies Reported" is No, all allergy records must be deleted.'
      };
    } else if (this.allergiesReported === LBL_YES && this.uacTable.records.length <= 0) {
      if (this.HEvalRecordTypeName === 'Health Assessment') {
        return {
          isValid: false,
          errorMessage: 'If "New Allergies Reported" is Yes at least one Allergy record must be added to the Allergy table.'
        };
      }
      return {
        isValid: false,
        errorMessage: 'In order to save the History and Physical Assessment section when "Allergies Reported" is Yes, at least one allergy record must be entered.'
      };
    }
    return { isValid: true };
  }
}