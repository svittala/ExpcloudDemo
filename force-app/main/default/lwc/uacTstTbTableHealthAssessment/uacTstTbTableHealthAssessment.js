import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getDependentFieldMap from '@salesforce/apex/UAC_dependentFieldMapController.getDependentFieldMap';
import deleteTestList from '@salesforce/apex/UAC_tstTestTableController.deleteTSTList';
import getTestList from '@salesforce/apex/UAC_tstTestTableController.getTSTList';
import upsertTestList from '@salesforce/apex/UAC_tstTestTableController.upsertTSTList';
import LBL_DISEASE_TB from '@salesforce/label/c.UAC_diseaseConditionTestedtPicklistTB';
import LBL_TEST_TST from '@salesforce/label/c.UAC_testPicklistPPDTST';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_RECORD_TYPE_IME from '@salesforce/label/c.UAC_healthEvaluationRecordTypeIME';
import LBL_RECORD_TYPE_HA from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import LBL_RECORD_TYPE_TB_PHI from '@salesforce/label/c.UAC_healthEvaluationRecordTypeTBPHI';
import LBL_HA_TST_TBL_HEADER from '@salesforce/label/c.UAC_HATSTTestTableHeader';
import LBL_RESULT_NEGATIVE from '@salesforce/label/c.UAC_resultPicklistNegative';
import LBL_RESULT_POSITIVE from '@salesforce/label/c.UAC_resultPicklistPositive';
import LBL_RECORD_TYPE_NAME_TST_RESULTS from '@salesforce/label/c.UAC_testRecTypeTBScreeningUnder2YearsAge';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_RECORDTYPE_LBLNAME_TST from '@salesforce/label/c.UAC_testRecTypeNameTST';
import OBJ_HEALTH_EVAL from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_HE_TST_QN from '@salesforce/schema/UAC_healthEvaluation__c.UAC_PPDTSTTest__c';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_IME_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_CREATED_DATE from '@salesforce/schema/UAC_test__c.CreatedDate';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_DATE_PERFORMED from '@salesforce/schema/UAC_test__c.UAC_datePerformed__c';
import FLD_DATE_READ from '@salesforce/schema/UAC_test__c.UAC_dateRead__c';
import FLD_REACTION from '@salesforce/schema/UAC_test__c.UAC_reactionInMM__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import { reduceErrors } from 'c/uacUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { api, LightningElement, track, wire } from 'lwc';

const LST_HEALTH_EVAL_FIELD = [
{
  name: FLD_HE_TST_QN.fieldApiName,
  type: 'radio',
  required: true
}
];
const LST_FIELD = [
{
    name: FLD_RESULT.fieldApiName,
    type: 'picklist',
    controllingField: FLD_TEST.fieldApiName,
    defaultValue: 'Pending',
    required: true
},
{
    name: FLD_REACTION.fieldApiName,
    type: 'number',
    min:0,
    hide:true
},
{
  name: FLD_DATE_PERFORMED.fieldApiName,
  type: 'date',
  required: true
},
{
  name: FLD_DATE_READ.fieldApiName,
  type: 'date',
  hide:true
},
{
  name: FLD_CREATED_DATE.fieldApiName,
  type: 'date',
  readonly: true
}
];

const OPT_NONE = {
  label: '--None--',
  value: ''
};

export default class uacTstTbTableHealthAssessment extends LightningElement {

  @api
  get healthEvaluationRecord() {
    return this._healthEvaluationRecord;
  }
  set healthEvaluationRecord(value) {
    this._healthEvaluationRecord = JSON.parse(JSON.stringify(value));
  }
  @api validationRan = false; // Used to track if flow has ran validate method

  tableTitle = LBL_HA_TST_TBL_HEADER;
  @track
  objectInfo;
  @track
  recordTypeId;
  @track
  fields = LST_FIELD;
  picklistValuesByRecordType;
  dependentFieldMap;

  @track
  healthEvalFields = LST_HEALTH_EVAL_FIELD;
  healthEvalRecord = {};
  @track
  imeRecordTypeId;
  @track
  haRecordTypeId;
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
          }
          if (data.recordTypeInfos[key].name === LBL_RECORD_TYPE_HA) {
            this.haRecordTypeId = data.recordTypeInfos[key].recordTypeId;
          }
        });
      this.initializeHealthEval();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, { objectApiName: OBJ_HEALTH_EVAL, recordTypeId: '$healthEvaluationRecord.RecordTypeId'})
  wiredHealthEvalPicklistValues({ data, error }) {
    if (data) {
      this.healthEvalPicklistValues = data;
      this.initializeHealthEval();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get isPHI() {
    if (!this.healthEvalObjectInfo) {
      return false;
    }
    const recordType = this.healthEvalObjectInfo.recordTypeInfos[
      this._healthEvaluationRecord.RecordTypeId
    ];
    return (recordType) ? recordType.name === LBL_RECORD_TYPE_TB_PHI : false;
  }

  initializeHealthEval() {
    if (!this.healthEvalObjectInfo || !this.healthEvalPicklistValues || Object.keys(this.healthEvaluationRecord)
      .length <= 0) {
      return;
    }

    // Copy health evaluation record from flow to healthEvalRecord
    this.healthEvalRecord = JSON.parse(JSON.stringify(this.healthEvaluationRecord));

    //Assign table title based on Record Type
    if(this.healthEvalRecord.RecordTypeId === this.imeRecordTypeId){
          this.tableTitle = LBL_TEST_TST;
    }else if(this.healthEvalRecord.RecordTypeId === this.haRecordTypeId){
          //this.tableTitle = LBL_HA_IGRA_TBL_HEADER;
          this.tableTitle = LBL_HA_TST_TBL_HEADER;
    }

    // Deep clone healthEvalFields to handle internal attribute changes
    let healthEvalFields = JSON.parse(JSON.stringify(this.healthEvalFields));
    healthEvalFields.forEach((fld) => {
      // Populate field labels
      if (this.healthEvalObjectInfo.fields[fld.name]) {
       fld.label =  (fld.name ===FLD_HE_TST_QN.fieldApiName)? LBL_TEST_TST : this.healthEvalObjectInfo.fields[fld.name].label;
      }

      // Get picklist field options
      if (fld.type === 'radio') {
        let options = [];
        for (let option of this.healthEvalPicklistValues.picklistFieldValues[fld.name].values) {
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
      this.dispatchEvent(new FlowAttributeChangeEvent('healthEvaluationRecord', this.healthEvalRecord));
    }
  }

  checkConditionalRulesForHealthEval() {
    this.tableSectionClass =
      (this.healthEvalRecord[FLD_HE_TST_QN.fieldApiName] ===
        LBL_YES) ? 'slds-show' : 'slds-hide';
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
            if (data.recordTypeInfos[key].name === LBL_RECORDTYPE_LBLNAME_TST) {
            this.recordTypeId = data.recordTypeInfos[key].recordTypeId;
          }
        });
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, {
    objectApiName: OBJ_TEST,
    recordTypeId: '$recordTypeId'
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

  @wire(getDependentFieldMap, {
    strObjectName: OBJ_TEST.objectApiName,
    strRecordTypeName: LBL_RECORD_TYPE_NAME_TST_RESULTS
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

  get defaultNewRecord() {
    return JSON.parse(`{
        "${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}": "${this.healthEvalRecord.Id}",
        "${FLD_ASSOCIATED_UAC.fieldApiName}": "${this.healthEvalRecord[FLD_IME_ASSOCIATED_UAC.fieldApiName]}",
        "RecordTypeId": "${this.recordTypeId}",
        "${FLD_DISEASE.fieldApiName}" : "${LBL_DISEASE_TB}",
        "${FLD_TEST.fieldApiName}" : "${LBL_TEST_TST}"
      }`);
  }

  get uacTable() {
    return this.template.querySelector('c-uac-table');
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
          field.name !== FLD_SPECIMEN_SOURCE
          .fieldApiName // Populated using dependentFieldMap
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

          // Populate Created Date as today's date for successfully saved records if not present
          Object.keys(response.data.successMap)
            .forEach((key) => {
              if (!response.data.successMap[key][FLD_CREATED_DATE.fieldApiName]) {
                response.data.successMap[key][FLD_CREATED_DATE.fieldApiName] = new Date()
                  .toISOString();
              }
            });

          this.uacTable.handleSaveResponse(response.data.successMap, response.data
            .errorMap);
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
          this.uacTable.handleDeleteResponse(response.data.successMap, response.data
            .errorMap)
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
      // Handle conditional rules here
          /*
          fld.hide = !(result === LBL_RESULT_POSITIVE || result === LBL_RESULT_NEGATIVE);
            fld.required=(result === LBL_RESULT_POSITIVE || result === LBL_RESULT_NEGATIVE);
            break;
          */
      row.fields.forEach((fld) => {
        let result = row.record[FLD_RESULT.fieldApiName];
        switch (fld.name) {
          case FLD_REACTION.fieldApiName:
          case FLD_DATE_READ.fieldApiName:
              fld.hide = !(result === LBL_RESULT_POSITIVE || result === LBL_RESULT_NEGATIVE);
              fld.required=(result === LBL_RESULT_POSITIVE || result === LBL_RESULT_NEGATIVE);
              break;
        default:
          break;
        }
      })

  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  getRecords() {
    getTestList({
        healthEvaluationId: this.healthEvaluationRecord.Id})
      .then((response) => {
        this.uacTable.records = response;
      })
      .catch((error) => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  connectedCallback() {
    this.initializeHealthEval();
  }

  @api validate() {
    this.dispatchEvent(new FlowAttributeChangeEvent('validationRan', true));
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      return validSoFar && cmpValidity;
    }, true);
    let fldTSTQN = this.healthEvalFields.filter((fld) => {
      return fld.name === FLD_HE_TST_QN.fieldApiName;
    })[0];
    if (this.healthEvalRecord[fldTSTQN.name] !==
      LBL_YES && this.uacTable.records.length > 0) {
      this.healthEvalRecord[fldTSTQN.name] = LBL_NO;
      this.dispatchEvent(new FlowAttributeChangeEvent('healthEvaluationRecord', this.healthEvalRecord));
      let sectionName = (this.isPHI) ? 'Public Health Investigation' : 'Lab Testing section';
      let msg =
        `In order to save the ${sectionName} when ""PPD/Tuberculin Skin Test (TST)" is No, all TST records must be deleted.`;
      return {
        isValid: false,
        errorMessage: msg
      };
    } else if (this.healthEvalRecord[fldTSTQN.name] ===
      LBL_YES && this.uacTable.records.length <= 0) {
      let msg =
        `If "PPD/Tuberculin Skin Test (TST)" is Yes at least one test record must be added to the TST Test table.`;
      return {
        isValid: false,
        errorMessage: msg
      };
    } else if (!isValid) {
      return { isValid: false, errorMessage: '' };
    }
    return { isValid: true };
  }
}