import deleteImmunizationList from '@salesforce/apex/UAC_immunizationTableController.deleteImmunizationList';
import getImmunizationList from '@salesforce/apex/UAC_immunizationTableController.getImmunizationList';
import upsertImmunizationList from '@salesforce/apex/UAC_immunizationTableController.upsertImmunizationList';
import LBL_HA_IMMUN_PICKLIST from '@salesforce/label/c.UAC_haImmunizationPicklist';
import LBL_HA_IMMUNIZATION_TBL_HEADER from '@salesforce/label/c.UAC_haImmunizationsHeader';
import LBL_RECORD_TYPE_HA from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import LBL_RECORD_TYPE_IME from '@salesforce/label/c.UAC_healthEvaluationRecordTypeIME';
import LBL_RECORD_TYPE_NON_TB_PHI from '@salesforce/label/c.UAC_healthEvaluationRecordTypeNonTBPHI';
import LBL_IME_IMMUN_PICKLIST from '@salesforce/label/c.UAC_immunizationPicklist';
import LBL_IME_IMMUNIZATION_TBL_HEADER from '@salesforce/label/c.UAC_immunizationsHeader';
import LBL_NON_TB_VACCINES from '@salesforce/label/c.UAC_immunizationNonTBPHIVaccines';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import OBJ_HEALTH_EVAL from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_HE_IMMUNE_QN from '@salesforce/schema/UAC_healthEvaluation__c.UAC_immunizationsAdministered__c';
import OBJ_IMMUNIZATION from '@salesforce/schema/UAC_immunization__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_immunization__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_immunization__c.UAC_associatedUAC__c';
import FLD_IME_ASSOCIATED_UAC from '@salesforce/schema/UAC_immunization__c.UAC_associatedUAC__c';
import FLD_UAC_DATE_ADMINISTERED from '@salesforce/schema/UAC_immunization__c.UAC_dateAdministered__c';
import FLD_UAC_DURATION from '@salesforce/schema/UAC_immunization__c.UAC_expectedShortageDuration__c';
import FLD_UAC_OTHER_REASON from '@salesforce/schema/UAC_immunization__c.UAC_otherReasonNotAdministered__c';
import FLD_UAC_REASON_NOT_ADMINISTERED from '@salesforce/schema/UAC_immunization__c.UAC_reasonNotAdministered__c';
import FLD_UAC_OTHER_VACCINE from '@salesforce/schema/UAC_immunization__c.UAC_specifyOtherVaccine__c';
import FLD_UAC_STATUS from '@salesforce/schema/UAC_immunization__c.UAC_status__c';
import FLD_UAC_VACCINE from '@salesforce/schema/UAC_immunization__c.UAC_vaccine__c';
import { getTodaysDate, reduceErrors } from 'c/uacUtils'
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { api, LightningElement, track, wire } from 'lwc';

const LST_HEALTH_EVAL_FIELD = [{
  name: FLD_HE_IMMUNE_QN.fieldApiName,
  type: 'radio',
  required: true
}];
const LST_FIELD = [
  { name: FLD_UAC_VACCINE.fieldApiName, type: 'picklist', required: true },
  {
    name: FLD_UAC_OTHER_VACCINE.fieldApiName,
    type: 'text',
    required: true,
    hide: true
  },
  { name: FLD_UAC_STATUS.fieldApiName, type: 'picklist', required: true },
  {
    name: FLD_UAC_DATE_ADMINISTERED.fieldApiName,
    type: 'date',
    required: true,
    hide: true
  },
  {
    name: FLD_UAC_REASON_NOT_ADMINISTERED.fieldApiName,
    type: 'picklist',
    required: true,
    hide: true
  },
  {
    name: FLD_UAC_OTHER_REASON.fieldApiName,
    type: 'textarea',
    required: true,
    hide: true
  },
  {
    name: FLD_UAC_DURATION.fieldApiName,
    type: 'text',
    required: true,
    hide: true
  }
];

const OPT_NONE = {
  label: '--None--',
  value: ''
};

export default class UacImmunizationsTable extends LightningElement {

  @api
  get healthEvaluationRecord() {
    return this._healthEvaluationRecord;
  }
  set healthEvaluationRecord(value) {
    this._healthEvaluationRecord = JSON.parse(JSON.stringify(value));
    this.initialize();
  }
  @api
  validationRan = false; // Used to track if flow has ran validate method

  tableTitle = LBL_IME_IMMUNIZATION_TBL_HEADER;
  @track
  objectInfo;
  @track
  recordTypeId;
  @track
  fields = [];
  picklistValuesByRecordType;

  @track
  healthEvalFields = LST_HEALTH_EVAL_FIELD;
  healthEvalRecord = {};
  imeRecordTypeId;
  haRecordTypeId;
  nonTBPhiRecordTypeId;
  @track
  tableSectionClass = 'slds-hide';
  @track
  isLoading = true;

  /**
   * @description Method to get object info and populate field attributes for label and required
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_HEALTH_EVAL })
  wiredHealthEvalObjectInfo({ data, error }) {
    if (data) {
      this.healthEvalObjectInfo = data;
      Object.keys(data.recordTypeInfos)
        .forEach((key) => {
          if (data.recordTypeInfos[key].name === LBL_RECORD_TYPE_IME) {
            this.imeRecordTypeId = data.recordTypeInfos[key].recordTypeId;
          } else if (data.recordTypeInfos[key].name === LBL_RECORD_TYPE_HA) {
            this.haRecordTypeId = data.recordTypeInfos[key].recordTypeId;
          } else if (data.recordTypeInfos[key].name === LBL_RECORD_TYPE_NON_TB_PHI) {
            this.nonTBPhiRecordTypeId = data.recordTypeInfos[key].recordTypeId;
          }
        });
      this.initializeHealthEval();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, {
    objectApiName: OBJ_HEALTH_EVAL,
    recordTypeId: '$healthEvaluationRecord.RecordTypeId'
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

  initializeHealthEval() {
    if (!this.healthEvalObjectInfo || !this.healthEvalPicklistValues ||
      Object.keys(this.healthEvaluationRecord).length <= 0 ||
      this.initializedHealthEval) {
      return;
    }
    this.initializedHealthEval = true;

    // Copy health evaluation record from flow to healthEvalRecord
    this.healthEvalRecord = JSON.parse(JSON.stringify(this.healthEvaluationRecord));

    // Assign table title based on Record Type
    if (this.healthEvalRecord.RecordTypeId === this.imeRecordTypeId) {
      this.tableTitle = LBL_IME_IMMUNIZATION_TBL_HEADER;
    } else if (this.healthEvalRecord.RecordTypeId === this.haRecordTypeId ||
      this.healthEvalRecord.RecordTypeId === this.nonTBPhiRecordTypeId) {
      this.tableTitle = LBL_HA_IMMUNIZATION_TBL_HEADER;
    }

    // Deep clone healthEvalFields to handle internal attribute changes
    let healthEvalFields = JSON.parse(JSON.stringify(this.healthEvalFields));
    healthEvalFields.forEach((fld) => {
      // Populate field labels
      if (this.healthEvalObjectInfo.fields[fld.name]) {
        if (this.healthEvalRecord.RecordTypeId === this.imeRecordTypeId) {
          fld.label = (fld.name === FLD_HE_IMMUNE_QN.fieldApiName) ?
            LBL_IME_IMMUN_PICKLIST :
            this.healthEvalObjectInfo.fields[fld.name].label;
        } else if (this.healthEvalRecord.RecordTypeId === this.haRecordTypeId ||
          this.healthEvalRecord.RecordTypeId === this.nonTBPhiRecordTypeId) {
          fld.label = (fld.name === FLD_HE_IMMUNE_QN.fieldApiName) ?
            LBL_HA_IMMUN_PICKLIST :
            this.healthEvalObjectInfo.fields[fld.name].label;
        }
      }
      // Get picklist field options
      if (fld.type === 'radio') {
        let options = [];
        for (let option of this.healthEvalPicklistValues.picklistFieldValues[fld.name]
            .values) {
          options.push({ label: option.label, value: option.value });
        }
        fld.options = options;
      }

      if (this.healthEvalRecord[fld.name]) {
        fld.value = this.healthEvalRecord[fld.name];
      }
    });
    this.healthEvalFields = healthEvalFields;
    this.checkConditionalRulesForHealthEval();

    if (this.validationRan) {
      // Re-trigger validate method to display errors if validation ran before
      // eslint-disable-next-line
      setTimeout(() => { // Timeout to allow input component to re-render before validating
        this.validate();
      }, 100);
    }

    this.isLoading = false;
  }

  handleHealthEvalFieldChange(event) {
    const fieldName = event.detail.name;
    const value = event.detail.value;
    this.healthEvalRecord[fieldName] = value;
    this.healthEvalFields.forEach((fld) => {
      if (fld.name === fieldName) fld.value = value;
    });
    this.checkConditionalRulesForHealthEval();
    if (!this.isLoading) {
      this.dispatchEvent(
          new FlowAttributeChangeEvent('healthEvaluationRecord', this.healthEvalRecord));
    }
  }

  checkConditionalRulesForHealthEval() {
    this.tableSectionClass = (this.healthEvalRecord[FLD_HE_IMMUNE_QN.fieldApiName] === LBL_YES) ?
      'slds-show' :
      'slds-hide';
  }

  /**
   * @description Method to get object info and populate field attributes for label and required
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_IMMUNIZATION })
  wiredObjectInfo({ data, error }) {
    if (data) {
      this.objectInfo = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, {
    objectApiName: OBJ_IMMUNIZATION,
    recordTypeId: '$objectInfo.defaultRecordTypeId'
  })
  wiredPicklistValues({ data, error }) {
    if (data) {
      this.picklistValuesByRecordType = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get defaultNewRecord() {
    return JSON.parse(`{
        "${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}": "${this.healthEvaluationRecord.Id}",
        "${FLD_ASSOCIATED_UAC.fieldApiName}": "${
        this.healthEvalRecord[FLD_IME_ASSOCIATED_UAC.fieldApiName]}"
      }`);
  }

  get uacTable() {
    return this.template.querySelector('c-uac-table');
  }

  initialize() {
    // Return without changes if wired data not initialized
    if (!this.objectInfo || !this.picklistValuesByRecordType
        || Object.keys(this.healthEvaluationRecord).length <= 0 ||
        this.initializedTable) {
      return;
    }
    this.initializedTable = true;

    let fields = JSON.parse(JSON.stringify(LST_FIELD));
    if (this.healthEvaluationRecord.RecordTypeId === this.nonTBPhiRecordTypeId) {
      fields = JSON.parse(JSON.stringify(LST_FIELD.filter(fld => {
        return fld.name !== FLD_UAC_OTHER_VACCINE.fieldApiName
      })));
    }

    fields.forEach((field) => {
      // Populate field label and required attribute using object info
      field.label = this.objectInfo.fields[field.name].label;
      if (field.required === undefined) {
        field.required = this.objectInfo.fields[field.name].nameField ||
          this.objectInfo.fields[field.name].required;
      }

      // Populate picklist options using picklistValuesByRecordType
      if (field.type === 'picklist') {
        let fieldInfo = this.picklistValuesByRecordType.picklistFieldValues[field.name];
        let optionValidForMap = new Map(); // Used for populated dependent options
        let options = [];
        options.push(OPT_NONE);
        for (let option of fieldInfo.values) {
          if (this.healthEvaluationRecord.RecordTypeId === this.imeRecordTypeId) {
            options.push({ label: option.label, value: option.value });
          } else if (this.healthEvaluationRecord.RecordTypeId === this.haRecordTypeId ||
            this.healthEvaluationRecord.RecordTypeId === this.nonTBPhiRecordTypeId) {
            if (option.label !== 'Received Out of ORR Care')
              options.push({ label: option.label, value: option.value });
          }
          for (let key of option.validFor) {
            if (!optionValidForMap.has(key)) {
              optionValidForMap.set(key, []);
            }
            optionValidForMap.get(key)
              .push({ label: option.label, value: option.value });
          }
        }
        // Override Non-TB PHI Vaccine options
        if (field.name === FLD_UAC_VACCINE.fieldApiName &&
          this.healthEvalRecord.RecordTypeId === this.nonTBPhiRecordTypeId) {
          options = [];
          options.push(OPT_NONE);
          LBL_NON_TB_VACCINES.split(/\r?\n/)
            .forEach(val => {
              options.push({ label: val, value: val });
            });
        }

        // Populate dependent field options using standard field dependencies
        if (Object.keys(fieldInfo.controllerValues)
          .length > 0) {
          let dependentOptionMap = {};
          for (let controllerValue of Object.keys(fieldInfo.controllerValues)) {
            dependentOptionMap[controllerValue] =
              optionValidForMap.get(fieldInfo.controllerValues[controllerValue]);
          }
          field.dependentOptionMap = dependentOptionMap;
        } else {
          field.options = options;
        }
      }
    });
    this.fields = fields;

    // Get records
    this.getRecords();
  }

  handleLoad(event) {
    const rows = event.detail.rows;
    rows.forEach((row) => {
      this.checkConditionalRules(row);
    });
  }

  handleSave(event) {
    const records = event.detail.records;
    upsertImmunizationList({ strRecordList: JSON.stringify(records) })
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
    deleteImmunizationList({ strRecordList: JSON.stringify(records) })
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

  handleFieldChange(event) {
    const row = event.detail.row;
    // Handle conditional rules here
    this.checkConditionalRules(row);
  }

  checkConditionalRules(row) {
    row.fields.forEach((fld) => {
      switch (fld.name) {
      case FLD_UAC_OTHER_VACCINE.fieldApiName:
        fld.hide = (row.record[FLD_UAC_VACCINE.fieldApiName] !== 'Other');
        break;
      case FLD_UAC_DATE_ADMINISTERED.fieldApiName:
        fld.hide = (row.record[FLD_UAC_STATUS.fieldApiName] !== 'Received Out of ORR Care' &&
          row.record[FLD_UAC_STATUS.fieldApiName] !== 'Received in ORR Care');
        if (row.record[FLD_UAC_STATUS.fieldApiName] === 'Received in ORR Care') {
          fld.value = (!fld.value) ? getTodaysDate() : fld.value;
          row.record[FLD_UAC_DATE_ADMINISTERED.fieldApiName] = fld.value;
        }
        // fld.readonly = (row.record[FLD_UAC_STATUS.fieldApiName] === 'Received in ORR Care');
        break;
      case FLD_UAC_REASON_NOT_ADMINISTERED.fieldApiName:
        fld.hide = (row.record[FLD_UAC_STATUS.fieldApiName] !== 'Indicated, but Not Given');
        break;
      case FLD_UAC_OTHER_REASON.fieldApiName:
        fld.hide = (row.record[FLD_UAC_REASON_NOT_ADMINISTERED.fieldApiName] !== 'Other');
        break;
      case FLD_UAC_DURATION.fieldApiName:
        fld.hide =
          (row.record[FLD_UAC_REASON_NOT_ADMINISTERED.fieldApiName] !== 'Vaccine Shortage');
        break;
      default:
        break;
      }
    });
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title: title, message: message, variant: variant }));
  }

  getRecords() {
    getImmunizationList({ healthEvaluationId: this.healthEvaluationRecord.Id })
      .then((response) => {
        this.uacTable.records = response;
      })
      .catch((error) => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  @api
  validate() {
    this.dispatchEvent(new FlowAttributeChangeEvent('validationRan', true));
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      return validSoFar && cmpValidity;
    }, true);
    let fldIMMUNEQN = this.healthEvalFields.filter((fld) => {
      return fld.name === FLD_HE_IMMUNE_QN.fieldApiName;
    })[0];
    if (this.healthEvalRecord[fldIMMUNEQN.name] !== LBL_YES && this.uacTable.records.length > 0) {
      this.healthEvalRecord[fldIMMUNEQN.name] = LBL_NO;
      this.dispatchEvent(
        new FlowAttributeChangeEvent('healthEvaluationRecord', this.healthEvalRecord));
      let msg = `In order to save the Diagnosis & Plan section when "${fldIMMUNEQN.label}" is ${
          LBL_NO}, all Immunization records must be deleted.`;
      return { isValid: false, errorMessage: msg };
    } else if (this.healthEvalRecord[fldIMMUNEQN.name] === LBL_YES &&
      this.uacTable.records.length <= 0) {
      let msg = `In order to save the Diagnosis & Plan section when "${fldIMMUNEQN.label}" is  ${
          LBL_YES}, then at least one Immunization must be entered.`;
      return { isValid: false, errorMessage: msg };
    } else if (!isValid) {
      return { isValid: false, errorMessage: '' };
    }
    return { isValid: true };
  }

  initializedHealthEval = false;
  initializedTable = false;

  renderedCallback() {
    if(!this.initializedHealthEval) {
      this.initializeHealthEval();
    }
    if(!this.initializedTable) {
      this.initialize();
    }
  }
}