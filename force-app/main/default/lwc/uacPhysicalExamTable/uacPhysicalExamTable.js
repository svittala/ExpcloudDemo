import { LightningElement, api, track, wire } from 'lwc';
import {
  getObjectInfo,
  getPicklistValuesByRecordType
} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import OBJ_PHYSICALEXAM from '@salesforce/schema/UAC_physicalExam__c';
import FLD_PHYSICAL_EXAM from '@salesforce/schema/UAC_physicalExam__c.UAC_physicalSystem__c';
import FLD_OTHER_SYSTEM_EXAMINED from '@salesforce/schema/UAC_physicalExam__c.UAC_otherSystemExamined__c';
import FLD_STATUS from '@salesforce/schema/UAC_physicalExam__c.UAC_status__c';
import FLD_SPECIFY from '@salesforce/schema/UAC_physicalExam__c.UAC_specify__c';
import getPhysicalExamList from '@salesforce/apex/UAC_physicalExamTableController.getPhysicalExamList';
import updatePhysicalExamList from '@salesforce/apex/UAC_physicalExamTableController.updatePhysicalExamList';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import { reduceErrors } from 'c/uacUtils'

const LST_FIELD = [
  { name: FLD_PHYSICAL_EXAM.fieldApiName, type: 'picklist', readonly:true },
  { name: FLD_OTHER_SYSTEM_EXAMINED.fieldApiName, type: 'text', required:true },
  { name: FLD_STATUS.fieldApiName, type: 'picklist', required:true },
  { name: FLD_SPECIFY.fieldApiName, type: 'textarea' }

];

const OPT_NONE = { label: '--None--', value: '' };

export default class UacPhysicalExamTable extends LightningElement {
  @api uacId;
  @api healthEvaluationId;

  @track lstField = LST_FIELD;
  @track _objectInfo;
  @track tableContainerClass = 'slds-show';
  @track disableAdd = true;
  @track disableDelete = true;

  picklistValuesByRecordType;


  get uacTable() {
    return this.template.querySelector('c-uac-table');
  }


  @wire(getObjectInfo, { objectApiName: OBJ_PHYSICALEXAM })
  wiredObjectInfo({ data, error }) {
    if (data) {
      this._objectInfo = data;
      for (let field of this.lstField) {
        field.label = data.fields[field.name].label;
        if (field.required === undefined) {
          field.required = data.fields[field.name].nameField || data.fields[field.name].required;
        }
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, {
    recordTypeId: '$_objectInfo.defaultRecordTypeId',
    objectApiName: OBJ_PHYSICALEXAM
  })
  wiredGetPicklistValuesByRecordType({ data, error }) {
    if (data) {
      this.picklistValuesByRecordType = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  handleSave(event) {
    const records = event.detail.records;
    updatePhysicalExamList({ strRecordList: JSON.stringify(records) })
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
    /* Example -
    row.fields.filter((fld) => {
        return fld.name === FLD_STATUS.fieldApiName
      })
      .forEach((fld) => {
        fld.hide = false;
        fld.required = true;
      });
    */
  }


  checkConditionalRules(row) {
    row.fields.forEach((fld) => {
      let otherPhysicalExam = row.record[FLD_PHYSICAL_EXAM.fieldApiName];
      let status = row.record[FLD_STATUS.fieldApiName];
      if (fld.name === FLD_OTHER_SYSTEM_EXAMINED.fieldApiName) {
          if(!(otherPhysicalExam === 'Other'))
            fld.hide=!(otherPhysicalExam === 'Other');
          if(otherPhysicalExam === 'Other')
            fld.hide=(otherPhysicalExam === 'Other' && status==='Not Evaluated');
      }
      if (fld.name === FLD_SPECIFY.fieldApiName) {
        if(otherPhysicalExam === 'Other')
          fld.hide=(otherPhysicalExam === 'Other' && status==='Not Evaluated');
      }
    });
  }

  getPhysicalExamRecords() {
    getPhysicalExamList({ healthEvaluationId: this.healthEvaluationId })
      .then(response => {
        this.uacTable.records = response;
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  initialize() {
    // Return without changes if wired data not initialized
    if (!this.picklistValuesByRecordType || !this.uacTable || this.initializedTable) {
      return;
    }
    this.initializedTable = true;

    let lstField = JSON.parse(JSON.stringify(LST_FIELD));
    for (let field of lstField) {
      if (field.type === 'picklist') {
        field.options = [];
        this.picklistValuesByRecordType.picklistFieldValues[field.name].values.forEach(key => {
          field.options.push({ label: key.label, value: key.value });
        });
      }
    }
    this.lstField = lstField;
    this.getPhysicalExamRecords();
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  initializedTable = false;

  renderedCallback() {
    if(!this.initializedTable) {
      this.initialize();
    }
  }
}