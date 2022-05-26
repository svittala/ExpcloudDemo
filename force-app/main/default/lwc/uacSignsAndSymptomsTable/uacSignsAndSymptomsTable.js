import {LightningElement,api,track,wire} from 'lwc';
import {getObjectInfo,getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import OBJ_SIGNANDSYMPTOMS from '@salesforce/schema/UAC_signsAndSymptoms__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_associatedUAC__c';
import FLD_SIGNSYMPTOM from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_signSymptom__c';
import FLD_SPECIFYOTHERSIGNSYMPTOM from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_specifyOtherSignSymptom__c';
import FLD_SIGNSYMPTOMONSETDATE from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_signSymptomOnsetDate__c';
import FLD_ONSETDATEUNKNOWN from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_onsetDateUnknown__c';
import FLD_LOCATIONOFPAIN from '@salesforce/schema/UAC_signsAndSymptoms__c.UAC_locationofPain__c';
import getSignAndSymptomsList from '@salesforce/apex/UAC_signAndSymptomsTableController.getSignAndSymptomsList';
import upsertSignAndSymptomsList from '@salesforce/apex/UAC_signAndSymptomsTableController.upsertSignAndSymptomsList';
import deleteSignAndSymptomsList from '@salesforce/apex/UAC_signAndSymptomsTableController.deleteSignAndSymptomsList';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import {reduceErrors} from 'c/uacUtils'

const LST_FIELD = [{
    name: FLD_SIGNSYMPTOM.fieldApiName,
    type: 'picklist',
    required: true
  },
  {
    name: FLD_SPECIFYOTHERSIGNSYMPTOM.fieldApiName,
    type: 'textarea',
    hide: true,
    required:true
  },
  {
    name: FLD_SIGNSYMPTOMONSETDATE.fieldApiName,
    type: 'date'
  },
  {
    name: FLD_ONSETDATEUNKNOWN.fieldApiName,
    type: 'checkbox'
  },
  {
    name: FLD_LOCATIONOFPAIN.fieldApiName,
    type: 'text',
    hide: true,
    required:true
  }
];
const SIGNANDSYMPTOMS_OPTIONS = [{
  label: LBL_YES,
  value: LBL_YES
},
{
  label: LBL_NO,
  value: LBL_NO
}];
const OPT_NONE = {
  label: '--None--',
  value: ''
};

export default class UacSignsAndSymptomsTable extends LightningElement {
  @api uacId;
  @api healthEvaluationId;
  @api
  get signAndSymptomsReported() {
    return this._signAndSymptomsReported;
  }
  set signAndSymptomsReported(value) {
    this._signAndSymptomsReported = value;
    this.showTable(this._signAndSymptomsReported === 'Yes');
  }

  @track lstField = LST_FIELD;
  @track _objectInfo;
  @track tableContainerClass = 'slds-hide';

  signAndSymptomsOptions = SIGNANDSYMPTOMS_OPTIONS;

  handleSignAndSymptomsReportedChange(event) {
    this._signAndSymptomsReported = event.detail.value;
    this.showTable(this._signAndSymptomsReported === 'Yes');
  }

  @track _signAndSymptomsReported;
  picklistValuesByRecordType;

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

  @wire(getObjectInfo, {
    objectApiName: OBJ_SIGNANDSYMPTOMS
  })
  wiredObjectInfo({
    data,
    error
  }) {
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
    objectApiName: OBJ_SIGNANDSYMPTOMS
  })
  wiredGetPicklistValuesByRecordType({
    data,
    error
  }) {
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
    upsertSignAndSymptomsList({
        strRecordList: JSON.stringify(records)
      })
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
    deleteSignAndSymptomsList({
        strRecordList: JSON.stringify(records)
      })
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

  handleLoad(event) {
    const rows = event.detail.rows;
    rows.forEach((row) => {
      this.checkConditionalRules(row);
    });
  }

  handleFieldChange(event) {
    /* eslint-disable no-unused-vars */
    const row = event.detail.row;
    /* eslint-enable no-unused-vars */

    // Handle conditional rules here
    this.checkConditionalRules(row);
    /* Example -
    row.fields.filter((fld) => {
        return fld.name === FLD_REACTION.fieldApiName
      })
      .forEach((fld) => {
        fld.hide = false;
        fld.required = true;
      });
    */
  }
  // for validations 08-03-2020
  checkConditionalRules(row) {
    row.fields.forEach((fld) => {
      let SignAndSymptomVal = row.record[FLD_SIGNSYMPTOM.fieldApiName];
      if (fld.name === FLD_SPECIFYOTHERSIGNSYMPTOM.fieldApiName) {
        fld.hide = !(SignAndSymptomVal === 'Other');
      }
      if (fld.name === FLD_LOCATIONOFPAIN.fieldApiName) {
        fld.hide = !(SignAndSymptomVal === 'Pain');
      }
    });
  }

  getSignAndSymptomsRecords() {
    getSignAndSymptomsList({
        healthEvaluationId: this.healthEvaluationId
      })
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
        field.options = [OPT_NONE];
        this.picklistValuesByRecordType.picklistFieldValues[field.name].values.forEach(key => {
          field.options.push({ label: key.label, value: key.value });
        });
      }
    }
    this.lstField = lstField;

    this.getSignAndSymptomsRecords();
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  @api validate() {
    const cmpSignAndSymptomsReported = this.template.querySelector('c-uac-input');
    if (!cmpSignAndSymptomsReported.validate()) {
      return {
        isValid: false,
        errorMessage: 'Please enter some valid input. Input is not optional.'
      };
    } else if (this.signAndSymptomsReported === LBL_NO && this.uacTable.records.length > 0) {
      return {
        isValid: false,
        errorMessage: 'In order to save the "Review of Systems & Physical Examination" section when "Were any Signs/Symptoms Reported by the Minor or Observed by Program Staff or HCP?" is No all Sign/Symptom records must be deleted.'
      };
    } else if (this.signAndSymptomsReported === LBL_YES && this.uacTable.records.length <= 0) {
      return {
        isValid: false,
        errorMessage: 'If "Were any Signs/Symptoms Reported by the Minor or Observed by Program Staff or Healthcare Provider?" is Yes at least one Sign/Symptom record must be added to the Sign/Symptom table.'
      };
    }
    return {
      isValid: true
    };
  }

  initializedTable = false;

  renderedCallback() {
    if(!this.initializedTable) {
      this.initialize();
    }
  }
}