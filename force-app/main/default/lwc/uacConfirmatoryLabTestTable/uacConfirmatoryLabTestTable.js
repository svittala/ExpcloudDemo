import getDependentFieldMap from '@salesforce/apex/UAC_dependentFieldMapController.getDependentFieldMap';
import deleteTestList from '@salesforce/apex/UAC_confirmatoryLabTableController.deleteTestList';
import getTestList from '@salesforce/apex/UAC_confirmatoryLabTableController.getTestList';
import upsertTestList from '@salesforce/apex/UAC_confirmatoryLabTableController.upsertTestList';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_RESULT_INDETERMINATE from '@salesforce/label/c.UAC_resultPicklistIndeterminate';
import LBL_RESULT_NEGATIVE from '@salesforce/label/c.UAC_resultPicklistNegative';
import LBL_RESULT_NOT_DONE from '@salesforce/label/c.UAC_resultPicklistNotDone';
import LBL_RESULT_POSITIVE from '@salesforce/label/c.UAC_resultPicklistPositive';
import LBL_RESULT_SPECIMEN_REJECTED from '@salesforce/label/c.UAC_resultPicklistSpecimenRejected';
import LBL_DISEASE_HEPATITIS_B from '@salesforce/label/c.UAC_testPicklistHepatitisB';
import LBL_DISEASE_HEPATITIS_C from '@salesforce/label/c.UAC_testPicklistHepatitisC';
import LBL_DISEASE_HIV from '@salesforce/label/c.UAC_testPicklistHIV';
import LBL_DISEASE_SYPHILIS from '@salesforce/label/c.UAC_testPicklistSyphilis';
import LBL_RECORD_TYPE_CONF_LAB_TEST from '@salesforce/label/c.UAC_testRecTypeConfirmatoryLabTest';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_INDICATOR from '@salesforce/schema/UAC_test__c.UAC_indicator__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_REASON_NOT_DONE from '@salesforce/schema/UAC_test__c.UAC_specifyReasonNotDone__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import RECORD_TYPE_CONF_LAB_TEST from '@salesforce/label/c.UAC_testRecTypeNameConfirmatoryLabTest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';

const OPT_NONE = {
  label: '--None--',
  value: ''
};
  
const LST_FIELD = [
  { name: FLD_DISEASE.fieldApiName, type: 'picklist', required: true },
  { name: FLD_INDICATOR.fieldApiName, type: 'text', readonly: true },
  {
    name: FLD_TEST.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName,
    required: true
  },
  {
    name: FLD_RESULT.fieldApiName,
    type: 'picklist',
    controllingField: FLD_TEST.fieldApiName,	
    required: true
  },
  { name: FLD_REASON_NOT_DONE.fieldApiName, type: 'text', required: true  },
  {
    name: FLD_SPECIMEN_SOURCE.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName,
    required: true  
  },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName, type: 'date', required: true }
];

export default class UacConfirmatoryLabTestTable extends LightningElement {

  @api
  uacId;
  @api
  healthEvaluationId;

  @track
  objectInfo;
  @track
  recordTypeId;
  @track
  fields = LST_FIELD;
  @track
  healthEvaluationRecord;
  picklistValuesByRecordType;
  dependentFieldMap;

  get defaultNewRecord() {
    return JSON.parse(`{
        "${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}": "${this.healthEvaluationId}",
        "${FLD_ASSOCIATED_UAC.fieldApiName}": "${this.uacId}",
        "RecordTypeId": "${this.recordTypeId}"
      }`);
  }

  get uacTable() {
    return this.template.querySelector('c-uac-table');
  }

  /**
   * @description Method to get object info and populate field attributes for label and required
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_TEST })
  wiredObjectInfo({ data, error }) {
    if (data) {
      this.objectInfo = data;
      Object.keys(data.recordTypeInfos)
        .forEach((key) => {
          if (data.recordTypeInfos[key].name === RECORD_TYPE_CONF_LAB_TEST) {
            this.recordTypeId = data.recordTypeInfos[key].recordTypeId;
          }
        });
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, { objectApiName: OBJ_TEST, recordTypeId: '$recordTypeId' })
  wiredPicklistValues({ data, error }) {
    if (data) {
      this.picklistValuesByRecordType = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getDependentFieldMap, {
    strObjectName: OBJ_TEST.objectApiName,
    strRecordTypeName: LBL_RECORD_TYPE_CONF_LAB_TEST
  })
  wiredDependentFieldMap({ data, error }) {
    if (data) {
      this.dependentFieldMap = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  initialize() {

    // Return without changes if wired data not initialized
    if (!this.objectInfo || !this.picklistValuesByRecordType || !this.dependentFieldMap) {
      return;
    }

    let fields = [...this.fields];

    fields
      .forEach((field) => {
        // Populate field label and required attribute using object info
        field.label = this.objectInfo.fields[field.name].label;
        if (field.required === undefined) {
          field.required = this.objectInfo.fields[field.name].nameField ||
            this.objectInfo.fields[field.name].required;
        }

        // Populate picklist options using picklistValuesByRecordType
        if (
          field.type === 'picklist' && field.name !== FLD_TEST
          .fieldApiName && // Populated using dependentFieldMap
          field.name !== FLD_RESULT.fieldApiName && // Populated using dependentFieldMap
          field.name !== FLD_SPECIMEN_SOURCE.fieldApiName // Populated using dependentFieldMap
        ) {
          let fieldInfo = this.picklistValuesByRecordType.picklistFieldValues[field.name];
          let optionValidForMap = new Map(); // Used for populated dependent options
          let options = [];
          options.push(OPT_NONE);
          for (let option of fieldInfo.values) {
            options.push({ label: option.label, value: option.value });
            for (let key of option.validFor) {
              if (!optionValidForMap.has(key)) {
                optionValidForMap.set(key, []);
              }
              optionValidForMap.get(key)
                .push({ label: option.label, value: option.value });
            }
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

        // Populate dependent option map using dependent field map
        if (this.dependentFieldMap[field.name]) {
          field.dependentOptionMap = this.dependentFieldMap[field.name];
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
    upsertTestList({ strRecordList: JSON.stringify(records) })
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
    deleteTestList({ strRecordList: JSON.stringify(records) })
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
    /* eslint-disable no-unused-vars */
    const row = event.detail.row;
    /* eslint-enable no-unused-vars */

    // Handle conditional rules here
    this.checkConditionalRules(row);
  }

  checkConditionalRules(row) {
    row.fields.forEach((fld) => {
      let disease = row.record[FLD_DISEASE.fieldApiName];
      let result = row.record[FLD_RESULT.fieldApiName];
      if (
        fld.name === FLD_SPECIMEN_COLLECTION_DATE.fieldApiName ||
        fld.name === FLD_SPECIMEN_SOURCE.fieldApiName
      ) {
        fld.hide = (result === LBL_RESULT_NOT_DONE);
      } else if (fld.name === FLD_REASON_NOT_DONE.fieldApiName) {
        fld.hide = !(result === LBL_RESULT_NOT_DONE);
      } else if (fld.name === FLD_INDICATOR.fieldApiName) {
        if (disease === LBL_DISEASE_HIV ||
          disease === LBL_DISEASE_SYPHILIS ||
		  disease === LBL_DISEASE_HEPATITIS_B ||
		  disease === LBL_DISEASE_HEPATITIS_C) {
          fld.value = 'Positive Screening Test';
        } 
        row.record[fld.name] = fld.value;
      }
    });
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  getRecords() {
    getTestList({ healthEvaluationId: this.healthEvaluationId })
      .then((response) => {
        this.uacTable.records = response;
      })
      .catch((error) => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }
}