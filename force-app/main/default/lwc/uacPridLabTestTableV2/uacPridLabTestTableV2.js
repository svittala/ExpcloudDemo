import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { api, LightningElement, track, wire } from 'lwc';
import { reduceErrors } from 'c/uacUtils'
import LBL_NO from '@salesforce/label/c.UAC_No';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import RECORD_TYPE_HEALTH_ASSESSMENT from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import LBL_RECORD_TYPE_IME from '@salesforce/label/c.UAC_healthEvaluationRecordTypeIME';
import LBL_RECORD_TYPE_NONTB_PHI from '@salesforce/label/c.UAC_healthEvaluationRecordTypeNonTBPHI';
import OBJ_HEALTH_EVAL from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import getDependentFieldMap from '@salesforce/apex/UAC_dependentFieldMapController.getDependentFieldMap';
import deleteTestList from '@salesforce/apex/UAC_PRIDLabTableController.deleteTestList';
import getTestList from '@salesforce/apex/UAC_PRIDLabTableController.getTestList';
import upsertTestList from '@salesforce/apex/UAC_PRIDLabTableController.upsertTestList';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_RECTYPE_PRID_LAB_TEST from '@salesforce/label/c.UAC_testRecTypePRIDLabTest';
import LBL_PRIDLABTEST_QUESTION from '@salesforce/label/c.UAC_PRIDLabTestFlowQuestion';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_HEALTH_EVAL_PRID_LAB_TEST_PERFORMED from '@salesforce/schema/UAC_healthEvaluation__c.UAC_PRIDLabTestsPerformed__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import FLD_SPECIFY_OTHER_DISEASE from '@salesforce/schema/UAC_test__c.UAC_specifyOtherDiseaseConditionTested__c';
import FLD_SPECIFY_OTHER_TEST from '@salesforce/schema/UAC_test__c.UAC_specifyOtherTest__c';
import FLD_SPECIFY_OTHER_SPSOURCE from '@salesforce/schema/UAC_test__c.UAC_specifyOtherSpecimenSource__c';
import LBL_OTHER from '@salesforce/label/c.UAC_other';
import LBL_PRID_TABLE_TITLE from '@salesforce/label/c.UAC_newPRIDFlowHeader';
import LBL_ACUTE_HEPATITIS_A from '@salesforce/label/c.UAC_diseaseConditionAcuteHepatitisA';
import LBL_COVID19 from '@salesforce/label/c.UAC_diseaseConditionCovid19';
import LBL_MEASLES from '@salesforce/label/c.UAC_diseaseConditionMeasles';
import LBL_MUMPS from '@salesforce/label/c.UAC_diseaseConditionMumps';
import LBL_PERTUSSIS from '@salesforce/label/c.UAC_diseaseConditionPertussis';
import LBL_RUBELLA from '@salesforce/label/c.UAC_diseaseConditionRubella';
import LBL_SEPSISMENINGITIS from '@salesforce/label/c.UAC_diseaseConditionSepsisMeningitis';
import LBL_VARICELLACHICKENPOX from '@salesforce/label/c.UAC_diseaseConditionVaricella';
import LBL_VIRALHAEMORRAGICFEVER from '@salesforce/label/c.UAC_diseaseConditionViralHemorrhagicFever';
import LBL_CHIKUGUNYA from '@salesforce/label/c.UAC_testPicklistChikungunya';
import LBL_DENGUE from '@salesforce/label/c.UAC_testPicklistDengue';
import LBL_MALARIA from '@salesforce/label/c.UAC_testPicklistMalaria';
import LBL_TYPHOID from '@salesforce/label/c.UAC_testPicklistTyphoid';
import LBL_ZIKA from '@salesforce/label/c.UAC_testPicklistZika';
import LBL_HIV from '@salesforce/label/c.UAC_testPicklistHIV';
import LBL_CHLAMYDIA from '@salesforce/label/c.UAC_testPicklistChlamydia';
import LBL_GONORRHEA from '@salesforce/label/c.UAC_testPicklistGonorrhea';
import LBL_SYPHILIS from '@salesforce/label/c.UAC_testPicklistSyphilis';
import LBL_ACUTE_HEPATITIS_B from '@salesforce/label/c.UAC_testPicklistHepatitisB';
import LBL_ACUTE_HEPATITIS_C from '@salesforce/label/c.UAC_testPicklistHepatitisC';

const YES_NO_OPTIONS = [
  { label: LBL_YES, value: LBL_YES },
  { label: LBL_NO, value: LBL_NO }
];

const PHI_DISEASE_OPTIONS = [
  { label: LBL_ACUTE_HEPATITIS_A, value: LBL_ACUTE_HEPATITIS_A },
  { label: LBL_COVID19, value: LBL_COVID19 },
  { label: LBL_MEASLES, value: LBL_MEASLES },
  { label: LBL_MUMPS, value: LBL_MUMPS },
  { label: LBL_PERTUSSIS, value: LBL_PERTUSSIS },
  { label: LBL_RUBELLA, value: LBL_RUBELLA },
  { label: LBL_SEPSISMENINGITIS, value: LBL_SEPSISMENINGITIS },
  { label: LBL_VARICELLACHICKENPOX, value: LBL_VARICELLACHICKENPOX },
  { label: LBL_VIRALHAEMORRAGICFEVER, value: LBL_VIRALHAEMORRAGICFEVER }
];
const PRID_DISEASE_OPTIONS = [
  { label: LBL_ACUTE_HEPATITIS_A, value: LBL_ACUTE_HEPATITIS_A },
  { label: LBL_ACUTE_HEPATITIS_B, value: LBL_ACUTE_HEPATITIS_B },
  { label: LBL_ACUTE_HEPATITIS_C, value: LBL_ACUTE_HEPATITIS_C },
  { label: LBL_CHIKUGUNYA, value: LBL_CHIKUGUNYA },
  { label: LBL_CHLAMYDIA, value: LBL_CHLAMYDIA },
  { label: LBL_COVID19, value: LBL_COVID19 },
  { label: LBL_DENGUE, value: LBL_DENGUE },
  { label: LBL_GONORRHEA, value: LBL_GONORRHEA },
  { label: LBL_HIV, value: LBL_HIV },
  { label: LBL_MALARIA, value: LBL_MALARIA },
  { label: LBL_MEASLES, value: LBL_MEASLES },
  { label: LBL_MUMPS, value: LBL_MUMPS },
  { label: LBL_PERTUSSIS, value: LBL_PERTUSSIS },
  { label: LBL_RUBELLA, value: LBL_RUBELLA },
  { label: LBL_SEPSISMENINGITIS, value: LBL_SEPSISMENINGITIS },
  { label: LBL_SYPHILIS, value: LBL_SYPHILIS },
  { label: LBL_TYPHOID, value: LBL_TYPHOID },
  { label: LBL_VARICELLACHICKENPOX, value: LBL_VARICELLACHICKENPOX },
  { label: LBL_VIRALHAEMORRAGICFEVER, value: LBL_VIRALHAEMORRAGICFEVER },
  { label: LBL_ZIKA, value: LBL_ZIKA },
  { label: LBL_OTHER, value: LBL_OTHER }
];

const RECORD_TYPE_PRID_LAB_TEST = 'PRID Lab Test';
const OPT_NONE = {
  label: '--None--',
  value: ''
};
const LST_FIELD = [
  { name: FLD_DISEASE.fieldApiName, type: 'picklist', required: true },
  { name: FLD_SPECIFY_OTHER_DISEASE.fieldApiName, type: 'text', hide: true, required: true },
  {
    name: FLD_TEST.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName,
    required: true
  },
  { name: FLD_SPECIFY_OTHER_TEST.fieldApiName, type: 'text', hide: true, required: true },
  {
    name: FLD_RESULT.fieldApiName,
    type: 'picklist',
    controllingField: FLD_TEST.fieldApiName,
    required: true
  },
  {
    name: FLD_SPECIMEN_SOURCE.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName,
    required: true
  },
  { name: FLD_SPECIFY_OTHER_SPSOURCE.fieldApiName, type: 'text', hide: true, required: true },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName, type: 'date', required: true }
];

const PHI_LST_FIELD = [
  { name: FLD_DISEASE.fieldApiName, type: 'picklist', required: true },
  {
    name: FLD_TEST.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName,
    required: true
  },
  { name: FLD_SPECIFY_OTHER_TEST.fieldApiName, type: 'text', hide: true, required: true },
  {
    name: FLD_RESULT.fieldApiName,
    type: 'picklist',
    controllingField: FLD_TEST.fieldApiName,
    required: true
  },
  {
    name: FLD_SPECIMEN_SOURCE.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName,
    required: true
  },
  { name: FLD_SPECIFY_OTHER_SPSOURCE.fieldApiName, type: 'text', hide: true, required: true },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName, type: 'date', required: true }
];

const HEALTH_EVAL_FIELDS = [
{
  label: LBL_PRIDLABTEST_QUESTION,
  name: FLD_HEALTH_EVAL_PRID_LAB_TEST_PERFORMED.fieldApiName,
  type: 'radio',
  required: true,
  options: YES_NO_OPTIONS
}];

export default class UacPridLabTestTableV2 extends LightningElement {

  @api
  get healthEvaluationRecord() {
    return this._healthEvaluationRecord;
  }
  set healthEvaluationRecord(value) {
    this._healthEvaluationRecord = JSON.parse(JSON.stringify(value));
  }
  @api validationRan = false; // Used to track if flow has ran validate method

  @track isLoading = true;
  @track errors = {};
  @track healthEvalObjectInfo;
  @track healthEvalFields = [];
  @track testObjectInfo;
  @track recordTypeId;
  @track fields = [];
  tableTitle = LBL_PRID_TABLE_TITLE;
  _healthEvaluationRecord;
  validated = false;
  healthEvalInitialized = false;
  tablesInitialized = false;
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
   * @description Method to get object info for Health Evaluation
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_HEALTH_EVAL })
  wiredHealthEvalObjectInfo({ data, error }) {
    if (data) {
      this.healthEvalObjectInfo = data;
      this.initializeHealthEval();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  /**
   * @description Method to get object info for Test
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_TEST })
  wiredObjectInfo({ data, error }) {
    if (data) {
      this.testObjectInfo = data;
      Object.keys(data.recordTypeInfos)
        .forEach((key) => {
          if (data.recordTypeInfos[key].name === RECORD_TYPE_PRID_LAB_TEST) {
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
    strRecordTypeName: LBL_RECTYPE_PRID_LAB_TEST
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

  get healthEvaluationId() {
    return this.healthEvaluationRecord.Id;
  }

  get uacId() {
    return this.healthEvaluationRecord[FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName];
  }

  get isHealthAssessment() {
    if (!this.healthEvalObjectInfo) {
      return false;
    }
    const recordType = this.healthEvalObjectInfo.recordTypeInfos[
      this._healthEvaluationRecord.RecordTypeId
    ];
    return (recordType) ? recordType.name === RECORD_TYPE_HEALTH_ASSESSMENT : false;
  }

  get isIME() {
    if (!this.healthEvalObjectInfo) {
      return false;
    }
    const recordType = this.healthEvalObjectInfo.recordTypeInfos[
      this._healthEvaluationRecord.RecordTypeId
    ];
    return (recordType) ? recordType.name === LBL_RECORD_TYPE_IME : false;
  }

  get isNonTBPHI() {
    if (!this.healthEvalObjectInfo) {
      return false;
    }
    const recordType = this.healthEvalObjectInfo.recordTypeInfos[
      this._healthEvaluationRecord.RecordTypeId
    ];
    return (recordType) ? recordType.name === LBL_RECORD_TYPE_NONTB_PHI : false;
  }

  hideTables() {
    const tableContainer = this.template.querySelector('.uac-table-container');
    if (tableContainer) {
      tableContainer.classList.add('slds-hide');
    }
  }

  showTables() {
    const tableContainer = this.template.querySelector('.uac-table-container');
    if (tableContainer) {
      tableContainer.classList.remove('slds-hide');
    }
  }

  initializeHealthEval() {
    if (!this.healthEvalObjectInfo ||
      !this._healthEvaluationRecord || !this.rendered) {
      return;
    }

    this.healthEvalFields = JSON.parse(JSON.stringify(HEALTH_EVAL_FIELDS));
    this.healthEvalFields.forEach((fld) => {
      let cmp = this;
      if (!Object.prototype.hasOwnProperty.call(fld, 'value')) {
        Object.defineProperty(fld, 'value', {
          get: function () {
            return cmp._healthEvaluationRecord[this.name];
          },
          set: function (value) {
            cmp._healthEvaluationRecord[this.name] = value;
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
    if ((this.healthEvaluationRecord[FLD_HEALTH_EVAL_PRID_LAB_TEST_PERFORMED
          .fieldApiName] ===
        LBL_YES) || this.isIME) {
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
    if (this.healthEvalInitialized) {
      this.dispatchEvent(new FlowAttributeChangeEvent('healthEvaluationRecord',
        this._healthEvaluationRecord));
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
    // Return without changes if wired data not initialized
    if (!this.testObjectInfo || !this.picklistValuesByRecordType || !this
      .dependentFieldMap) {
      return;
    }

    let fields = [...LST_FIELD];
    if (this.isNonTBPHI) {
      fields = [...PHI_LST_FIELD];
    }
    fields
      .forEach((field) => {
        // Populate field label and required attribute using object info
        field.label = this.testObjectInfo.fields[field.name].label;
        if (field.required === undefined) {
          field.required = this.testObjectInfo.fields[field.name].nameField ||
            this.testObjectInfo.fields[field.name].required;
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
            field.options = (field.name === FLD_DISEASE.fieldApiName) ? PRID_DISEASE_OPTIONS : options;
          }
          if (field.name === FLD_DISEASE.fieldApiName && this.isNonTBPHI){
            field.options = PHI_DISEASE_OPTIONS;
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

    //******//

    this.isLoading = false;
    if (this.validationRan && !this.validated) {
      this.validated = true;
      this.validate();
    }
    this.tablesInitialized = true;
    this.runValidation();
  }

  runValidation() {
    if (this.validationRan && this.healthEvalInitialized && this.tablesInitialized) {
      this.validate();
    }
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
    const row = event.detail.row;

    // Handle conditional rules here
    this.checkConditionalRules(row);
  }

  checkConditionalRules(row) {
    row.fields.forEach((fld) => {
      if (fld.name === FLD_DISEASE.fieldApiName && this.isNonTBPHI){
        fld.options = PHI_DISEASE_OPTIONS;
      }
      let disease = row.record[FLD_DISEASE.fieldApiName];
      // let result = row.record[FLD_RESULT.fieldApiName];
      if (fld.name === FLD_SPECIFY_OTHER_DISEASE.fieldApiName) {
        fld.hide = !(disease === LBL_OTHER);
      } else if (fld.name === FLD_SPECIFY_OTHER_TEST.fieldApiName) {
        fld.hide = !(row.record[FLD_TEST.fieldApiName] === LBL_OTHER);
      } else if (fld.name === FLD_SPECIFY_OTHER_SPSOURCE.fieldApiName) {
        fld.hide = !(row.record[FLD_SPECIMEN_SOURCE.fieldApiName] === LBL_OTHER);
      }
    });
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

  @api
  validate() {
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      return validSoFar && cmpValidity;
    }, true);
    const pridTestPerformed = this.healthEvaluationRecord[FLD_HEALTH_EVAL_PRID_LAB_TEST_PERFORMED
      .fieldApiName];
    if (!isValid) {
      return {
        isValid: false,
        errorMessage: 'Please enter some valid input. Input is not optional.'
      };
    } else if (pridTestPerformed === LBL_NO && this.uacTable.records.length > 0) {
      if (this.isHealthAssessment) {
        return {
          isValid: false,
          errorMessage: `In order to save the "Risk-Based & PRID Lab Testing" section when "${LBL_PRIDLABTEST_QUESTION}" is No all PRID Lab Test records must be deleted`
        };
      }
      if (this.isNonTBPHI) {
        return {
          isValid: false,
          errorMessage: `In order to save the Public Health Investigation when "${LBL_PRIDLABTEST_QUESTION}" is No all PRID Lab Test records must be deleted`
        };
      }
    } else if (pridTestPerformed === LBL_YES && this.uacTable.records.length <= 0) {
      if (this.isHealthAssessment) {
        return {
          isValid: false,
          errorMessage: `If "${LBL_PRIDLABTEST_QUESTION}" is Yes at least one PRID Lab Test record must be added to the PRID Lab Test table.`
        };
      }
      if (this.isNonTBPHI) {
        return {
          isValid: false,
          errorMessage: `If "${LBL_PRIDLABTEST_QUESTION}" is Yes at least one PRID Lab Test record must be added to the PRID Lab Test table.`
        };
      }
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