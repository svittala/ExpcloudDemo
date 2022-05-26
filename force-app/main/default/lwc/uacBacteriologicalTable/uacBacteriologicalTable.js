import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getDependentFieldMap from '@salesforce/apex/UAC_dependentFieldMapController.getDependentFieldMap';
import deleteTestList from '@salesforce/apex/UAC_testTableController.deleteTestList';
import getTestList from '@salesforce/apex/UAC_testTableController.getTestList';
import upsertTestList from '@salesforce/apex/UAC_testTableController.upsertTestList';
import RECORD_TYPE_HEALTH_ASSESSMENT from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import LBL_DISEASE_TB from '@salesforce/label/c.UAC_diseaseConditionTestedtPicklistTB';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_RECORD_TYPE_BACTERIOLOGICAL_RESULTS from '@salesforce/label/c.UAC_testRecordTypeBacteriologicalResults';
import LBL_RECORD_TYPE_NAME_BACTERIOLOGICAL_RESULTS from '@salesforce/label/c.UAC_testRecTypeBacteriologicalResults';
import LBL_HEALTH_DECISION_WORKUP_NEEDED from '@salesforce/label/c.UAC_healthEvaluationHealthDeptDecisionWorkUpNeeded';
import LBL_TB_WORKUP_REASON_OTHER from '@salesforce/label/c.UAC_healthEvaluationTBWorkupReasonOther';
import LBL_TB_SCREEN_REFER_TO_HEALTH_DEPT from '@salesforce/label/c.UAC_healthEvaluationTBScreenOutcomeReferToHealthDept';
import OBJ_HEALTH_EVAL from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_HEALTH_EVAL_TB_SCREENING_OUTCOME from '@salesforce/schema/UAC_healthEvaluation__c.UAC_TBScreeningOutcome__c';
import FLD_HEALTH_EVAL_HEALTH_DEPT_DECISION from '@salesforce/schema/UAC_healthEvaluation__c.UAC_healthDepartmentSpecialistDecision__c';
import FLD_HEALTH_EVAL_WORKUP_REASON from '@salesforce/schema/UAC_healthEvaluation__c.UAC_reasonForActiveTBWorkUp__c';
import FLD_HEALTH_EVAL_WORKUP_REASON_OTHER from '@salesforce/schema/UAC_healthEvaluation__c.UAC_specifyOtherReasonWorkUpNeeded__c';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_CREATED_DATE from '@salesforce/schema/UAC_test__c.CreatedDate';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_OTHER_SPECIMEN from '@salesforce/schema/UAC_test__c.UAC_specifyOtherSpecimenSource__c';
import FLD_COLLECTED_BY_OTHER from '@salesforce/schema/UAC_test__c.UAC_specifyOtherSpecimenCollectedBy__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_SPECIMEN_COLLECTED_BY from '@salesforce/schema/UAC_test__c.UAC_specimenCollectedBy__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import { reduceErrors } from 'c/uacUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { api, LightningElement, track, wire } from 'lwc';

const LST_HEALTH_EVAL_FIELD = [
{
  name: FLD_HEALTH_EVAL_TB_SCREENING_OUTCOME.fieldApiName,
  type: 'picklist',
  required: true
},
{
  name: FLD_HEALTH_EVAL_HEALTH_DEPT_DECISION.fieldApiName,
  type: 'picklist',
  required: true,
  hide: true
},
{
  label: 'Reason Work-Up Needed to Rule Out Active TB Disease',
  name: FLD_HEALTH_EVAL_WORKUP_REASON.fieldApiName,
  type: 'multi-picklist',
  required: true,
  hide: true
},
{
  name: FLD_HEALTH_EVAL_WORKUP_REASON_OTHER.fieldApiName,
  type: 'text',
  required: true,
  hide: true
}];
const LST_FIELD = [
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
  defaultValue: 'Pending',
  required: true
},
{
  name: FLD_SPECIMEN_SOURCE.fieldApiName,
  type: 'picklist',
  controllingField: FLD_DISEASE.fieldApiName,
  required: true
},
{
  name: FLD_OTHER_SPECIMEN.fieldApiName,
  type: 'text',
  required: true,
  hide: true
},
{
  name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName,
  type: 'date',
  required: true
},
{
  name: FLD_SPECIMEN_COLLECTED_BY.fieldApiName,
  type: 'picklist',
  required: true
},
{
  name: FLD_COLLECTED_BY_OTHER.fieldApiName,
  type: 'text',
  required: true,
  hide: true
},
{
  name: FLD_CREATED_DATE.fieldApiName,
  type: 'date',
  readonly: true
}];
const OPT_NONE = {
  label: '--None--',
  value: ''
};

export default class UacBacteriologicalTable extends LightningElement {

  //@api healthEvaluationRecord = {}
  @api
  get healthEvaluationRecord() {
    return this._healthEvaluationRecord;
  }
  set healthEvaluationRecord(value) {
    this._healthEvaluationRecord = JSON.parse(JSON.stringify(value));
  }
  @api validationRan = false; // Used to track if flow has ran validate method
  @api title = LBL_RECORD_TYPE_BACTERIOLOGICAL_RESULTS;

  @track
  objectInfo;
  @track
  recordTypeId;
  @track
  fields = LST_FIELD;
  picklistValuesByRecordType;
  dependentFieldMap;

  @track
  healthEvalFields = [];
  healthEvalRecord = {};
  healthEvalPicklistValues;
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

  get isHealthAssessment() {
    return this.healthEvalObjectInfo.recordTypeInfos[this.healthEvalRecord.RecordTypeId]
      .name === RECORD_TYPE_HEALTH_ASSESSMENT;
  }

  initializeHealthEval() {
    if (!this.healthEvalObjectInfo || !this.healthEvalPicklistValues || Object.keys(this
        .healthEvaluationRecord)
      .length <= 0) {
      return;
    }

    // Copy health evaluation record from flow to healthEvalRecord
    this.healthEvalRecord = JSON.parse(JSON.stringify(this.healthEvaluationRecord));

    // Deep clone healthEvalFields to handle internal attribute changes
    let healthEvalFields = JSON.parse(JSON.stringify(LST_HEALTH_EVAL_FIELD));
    healthEvalFields = healthEvalFields.filter((fld) => {
      if (this.isHealthAssessment) {
        return fld.name !== FLD_HEALTH_EVAL_TB_SCREENING_OUTCOME.fieldApiName;
      }
      return true;
    });
    healthEvalFields.forEach((fld) => {
      // Populate field labels
      if (this.healthEvalObjectInfo.fields[fld.name] && !fld.label) {
        fld.label = this.healthEvalObjectInfo.fields[fld.name].label;
      }

      // Get picklist field options
      if (fld.type === 'picklist' || fld.type === 'multi-picklist') {
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
      this.dispatchEvent(new FlowAttributeChangeEvent('healthEvaluationRecord', this
        .healthEvalRecord));
    }
  }

  checkConditionalRulesForHealthEval() {
    let reasonWorkupNeeded = this.healthEvalRecord[FLD_HEALTH_EVAL_WORKUP_REASON.fieldApiName];
    reasonWorkupNeeded = (reasonWorkupNeeded && reasonWorkupNeeded!==null) ? new Set(reasonWorkupNeeded.split(';')) : new Set();
    this.healthEvalFields.forEach((fld) => {
      switch (fld.name) {
      case FLD_HEALTH_EVAL_HEALTH_DEPT_DECISION.fieldApiName:
        fld.hide = !(this.healthEvalRecord[FLD_HEALTH_EVAL_TB_SCREENING_OUTCOME
            .fieldApiName] ===
          LBL_TB_SCREEN_REFER_TO_HEALTH_DEPT || this.isHealthAssessment);
        break;
      case FLD_HEALTH_EVAL_WORKUP_REASON.fieldApiName:
        fld.hide = (this.healthEvalRecord[FLD_HEALTH_EVAL_HEALTH_DEPT_DECISION
            .fieldApiName] !==
          LBL_HEALTH_DECISION_WORKUP_NEEDED);
        break;
      case FLD_HEALTH_EVAL_WORKUP_REASON_OTHER.fieldApiName:
        fld.hide = !reasonWorkupNeeded.has(LBL_TB_WORKUP_REASON_OTHER);
        break;
      default:
        break;
      }
    });
    this.tableSectionClass =
      (this.healthEvalRecord[FLD_HEALTH_EVAL_HEALTH_DEPT_DECISION.fieldApiName] ===
        LBL_HEALTH_DECISION_WORKUP_NEEDED) ? 'slds-show' : 'slds-hide';
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
          if (data.recordTypeInfos[key].name === LBL_RECORD_TYPE_BACTERIOLOGICAL_RESULTS) {
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
    strRecordTypeName: LBL_RECORD_TYPE_NAME_BACTERIOLOGICAL_RESULTS
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
        "${FLD_ASSOCIATED_HEALTH_EVALUATION.fieldApiName}": "${this.healthEvaluationRecord.Id}",
        "${FLD_ASSOCIATED_UAC.fieldApiName}": "${this.healthEvalRecord[FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName]}",
        "RecordTypeId": "${this.recordTypeId}",
        "${FLD_DISEASE.fieldApiName}" : "${LBL_DISEASE_TB}"
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
    row.fields.forEach((fld) => {
      let specimenSrc = row.record[FLD_SPECIMEN_SOURCE.fieldApiName];
      let specimenCollectedBy = row.record[FLD_SPECIMEN_COLLECTED_BY.fieldApiName];
      switch (fld.name) {
      case FLD_OTHER_SPECIMEN.fieldApiName:
        fld.hide = (specimenSrc !== 'Other');
        break;
      case FLD_COLLECTED_BY_OTHER.fieldApiName:
        fld.hide = (specimenCollectedBy !== 'Other');
        break;
      default:
        break;
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
    let lstFieldsToQuery = this.fields.map((fld) => { return fld.name; });
    lstFieldsToQuery.push(FLD_DISEASE.fieldApiName);
    getTestList({
        healthEvaluationId: this.healthEvaluationRecord.Id,
        strRecordTypeName: LBL_RECORD_TYPE_NAME_BACTERIOLOGICAL_RESULTS,
        lstFieldsToQuery: lstFieldsToQuery
      })
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
    let fldHealthDeptDecision = this.healthEvalFields.filter((fld) => {
      return fld.name === FLD_HEALTH_EVAL_HEALTH_DEPT_DECISION.fieldApiName;
    })[0];
    if (this.healthEvalRecord[fldHealthDeptDecision.name] !==
      LBL_HEALTH_DECISION_WORKUP_NEEDED && this.uacTable.records.length > 0) {
      this.healthEvalRecord[FLD_HEALTH_EVAL_TB_SCREENING_OUTCOME.fieldApiName] =
        LBL_TB_SCREEN_REFER_TO_HEALTH_DEPT;
      this.healthEvalRecord[fldHealthDeptDecision.name] = LBL_HEALTH_DECISION_WORKUP_NEEDED;
      this.healthEvalRecord[FLD_HEALTH_EVAL_WORKUP_REASON.fieldApiName] = this.healthEvalFields
        .filter((
          fld) => {
          return fld.name === FLD_HEALTH_EVAL_WORKUP_REASON.fieldApiName;
        })[0].options[0].value;
      this.dispatchEvent(new FlowAttributeChangeEvent('healthEvaluationRecord', this
        .healthEvalRecord));
      let msg =
        `In order to save the TB Lab Testing section when ${LBL_HEALTH_DECISION_WORKUP_NEEDED} is not selected in the "${fldHealthDeptDecision.label}" field, all Bacteriological Results records must be deleted.`;
      return {
        isValid: false,
        errorMessage: msg
      };
    } else if (this.healthEvalRecord[fldHealthDeptDecision.name] ===
      LBL_HEALTH_DECISION_WORKUP_NEEDED && this.uacTable.records.length <= 0) {
      let msg =
        `In order to save the TB Lab Testing section when ${LBL_HEALTH_DECISION_WORKUP_NEEDED} is selected in the "${fldHealthDeptDecision.label}" field, at least one Bacteriological Results record must be entered.`;
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