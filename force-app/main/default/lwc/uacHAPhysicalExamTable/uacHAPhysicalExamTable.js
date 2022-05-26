import deletePhysicalExamList from '@salesforce/apex/UAC_physicalExamTableController.deletePhysicalExamList';
import getPhysicalExamList from '@salesforce/apex/UAC_physicalExamTableController.getPhysicalExamList';
import upsertPhysicalExamList from '@salesforce/apex/UAC_physicalExamTableController.upsertPhysicalExamList';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import OBJ_PHYSICALEXAM from '@salesforce/schema/UAC_physicalExam__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_physicalExam__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_physicalExam__c.UAC_associatedUAC__c';
import FLD_OTHERSYSTEMEXAMINED from '@salesforce/schema/UAC_physicalExam__c.UAC_otherSystemExamined__c';
import FLD_PHYSICALSYSTEM from '@salesforce/schema/UAC_physicalExam__c.UAC_physicalSystem__c';
import FLD_DESCRIBEFINDINGS from '@salesforce/schema/UAC_physicalExam__c.UAC_specify__c';
import FLD_STATUS from '@salesforce/schema/UAC_physicalExam__c.UAC_status__c';
import {reduceErrors} from 'c/uacUtils'
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import {getObjectInfo, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import {api, LightningElement, track, wire} from 'lwc';

const LST_FIELD = [
  {name: FLD_PHYSICALSYSTEM.fieldApiName, type: 'picklist', required: true},
  {name: FLD_OTHERSYSTEMEXAMINED.fieldApiName, type: 'text', hide: true, required: true},
  {name: FLD_STATUS.fieldApiName, type: 'picklist', required: true},
  {name: FLD_DESCRIBEFINDINGS.fieldApiName, type: 'textarea'}
];
const PHYSICAL_EXAM_OPTIONS = [{label: LBL_YES, value: LBL_YES}, {label: LBL_NO, value: LBL_NO}];
const OPT_NONE = {
  label: '--None--',
  value: ''
};

export default class UacHAPhysicalExamTable extends LightningElement {
  @api
  uacId;
  @api
  healthEvaluationId;
  @track
  _physicalExamReported;
  @api
  get physicalExamReported() {
    return this._physicalExamReported;
  }
  set physicalExamReported(value) {
    this._physicalExamReported = value;
    this.showTable(this._physicalExamReported === 'Yes');
  }

  @track
  lstField = LST_FIELD;
  @track
  _objectInfo;
  @track
  tableContainerClass = 'slds-hide';

  physicalExamOptions = PHYSICAL_EXAM_OPTIONS;
  picklistValuesByRecordType;

  handlePhysicalExamReportedChange(event) {
    this._physicalExamReported = event.detail.value;
    this.showTable(this._physicalExamReported === 'Yes');
  }

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

  @wire(getObjectInfo, {objectApiName: OBJ_PHYSICALEXAM})
  wiredObjectInfo({data, error}) {
    if (data) {
      this._objectInfo = data;
      for (let field of this.lstField) {
        field.label = data.fields[field.name].label;
        if (field.label === 'Describe, Or If Not Evaluated, State Why') {
          field.label = 'Describe Findings';
        }
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType,
      {recordTypeId: '$_objectInfo.defaultRecordTypeId', objectApiName: OBJ_PHYSICALEXAM})
  wiredGetPicklistValuesByRecordType({data, error}) {
    if (data) {
      this.picklistValuesByRecordType = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
    }
  }

  handleSave(event) {
    const records = event.detail.records;
    upsertPhysicalExamList({strRecordList: JSON.stringify(records)})
        .then(response => {
          if (response.isSuccess) {
            if (Object.keys(response.data.errorMap).length <= 0) {
              this.showToastMessage('Success', LBL_SAVE_SUCCESS, 'success');
            }
            this.uacTable.handleSaveResponse(response.data.successMap, response.data.errorMap);
          } else {
            this.uacTable.addError(response.error);
          }
        })
        .catch(error => {
          this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
        })
  }

  handleDelete(event) {
    const records = event.detail.records;
    deletePhysicalExamList({strRecordList: JSON.stringify(records)})
        .then(response => {
          if (response.isSuccess) {
            if (Object.keys(response.data.errorMap).length <= 0) {
              this.showToastMessage('Success', LBL_DELETE_SUCCESS, 'success');
            }
            this.uacTable.handleDeleteResponse(response.data.successMap, response.data.errorMap)
          } else {
            this.uacTable.addError(response.error);
          }
        })
        .catch(error => {
          this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
        });
  }

  handleLoad(event) {
    const rows = event.detail.rows;
    rows.forEach((row) => {
      this.checkConditionalRules(row);
    });
  }

  handleFieldChange(event) {
    const row = event.detail.row;
    // Handle conditional rules here
    this.checkConditionalRules(row);
  }
  // for validations 08-03-2020
  checkConditionalRules(row) {
    row.fields.forEach((fld) => {
      switch (fld.name) {
        case FLD_OTHERSYSTEMEXAMINED.fieldApiName:
          fld.hide = (row.record[FLD_PHYSICALSYSTEM.fieldApiName] !== 'Other');
          break;
        default:
          break;
      }
    });
  }

  getPhysicalExamRecords() {
    getPhysicalExamList({healthEvaluationId: this.healthEvaluationId})
        .then(response => {
          this.uacTable.records = response;
        })
        .catch(error => {
          this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
        });
  }

  initialize() {
    // Return without changes if wired data not initialized
    if (!this.picklistValuesByRecordType || !this.uacTable || this.initializedTable) {
      return;
    }
    this.initializedTable = true;

    let lstField = JSON.parse(JSON.stringify(LST_FIELD))
    for (let field of lstField) {
      if (field.type === 'picklist') {
        field.options = [OPT_NONE];
        this.picklistValuesByRecordType.picklistFieldValues[field.name].values.forEach(key => {
          if (key.label !== 'Not Evaluated') {
            field.options.push({label: key.label, value: key.value});
          }
        });
      }
    }
    this.lstField = lstField;
    this.getPhysicalExamRecords();
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({title: title, message: message, variant: variant}));
  }

  @api
  validate() {
    const cmpPhysicalExamReported = this.template.querySelector('c-uac-input');
    if (!cmpPhysicalExamReported.validate()) {
      return {
        isValid: false,
        errorMessage: 'Please enter some valid input. Input is not optional.'
      };
    } else if (this.physicalExamReported === LBL_NO && this.uacTable.records.length > 0) {
      return {
        isValid: false,
        errorMessage:
            'In order to save the Review of Systems & Physical Examination section when "Physical Exam Performed by HCP?" is No all Physical Exam records must be deleted.'
      };
    } else if (this.physicalExamReported === LBL_YES && this.uacTable.records.length <= 0) {
      return {
        isValid: false,
        errorMessage:
            'If "Physical Exam Performed by HCP?" is Yes at least one Physical Exam record must be added to the Physical Exam table.'
      };
    }
    return {isValid: true};
  }

  initializedTable = false;

  renderedCallback() {
    if(!this.initializedTable) {
      this.initialize();
    }
  }
}