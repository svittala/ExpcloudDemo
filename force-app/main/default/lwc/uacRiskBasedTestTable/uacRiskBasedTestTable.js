import getDependentFieldMap from '@salesforce/apex/UAC_dependentFieldMapController.getDependentFieldMap';
import deleteTestList from '@salesforce/apex/UAC_riskBasedTestTableController.deleteTestList';
import getTestList from '@salesforce/apex/UAC_riskBasedTestTableController.getTestList';
import upsertTestList from '@salesforce/apex/UAC_riskBasedTestTableController.upsertTestList';
import LBL_DISEASE_INFLUENZA from '@salesforce/label/c.UAC_diseaseConditionTestedtPicklistInfluenza';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_NO_BUT_SIGNS from '@salesforce/label/c.UAC_NoButObviousSigns';
import LBL_RESULT_INDETERMINATE from '@salesforce/label/c.UAC_resultPicklistIndeterminate';
import LBL_RESULT_NEGATIVE from '@salesforce/label/c.UAC_resultPicklistNegative';
import LBL_RESULT_NOT_DONE from '@salesforce/label/c.UAC_resultPicklistNotDone';
import LBL_RESULT_POSITIVE from '@salesforce/label/c.UAC_resultPicklistPositive';
import LBL_RESULT_SPECIMEN_REJECTED from '@salesforce/label/c.UAC_resultPicklistSpecimenRejected';
import LBL_ALERT_DRUG_USE from '@salesforce/label/c.UAC_testAlertMessageDrugUse';
import LBL_ALERT_MENARCHE from '@salesforce/label/c.UAC_testAlertMessageMenarche';
import LBL_ALERT_SEXUAL_ACTIVITY from '@salesforce/label/c.UAC_testAlertMessageSexualActivity';
import LBL_DISEASE_CHLAMYDIA from '@salesforce/label/c.UAC_testPicklistChlamydia';
import LBL_DISEASE_GONORRHEA from '@salesforce/label/c.UAC_testPicklistGonorrhea';
import LBL_DISEASE_HEPATITIS_B from '@salesforce/label/c.UAC_testPicklistHepatitisB';
import LBL_DISEASE_HEPATITIS_C from '@salesforce/label/c.UAC_testPicklistHepatitisC';
import LBL_DISEASE_HIV from '@salesforce/label/c.UAC_testPicklistHIV';
import LBL_DISEASE_LEAD from '@salesforce/label/c.UAC_testPicklistLead';
import LBL_TEST_LEAD_LEVEL from '@salesforce/label/c.UAC_testPicklistLeadLevel';
import LBL_CONDITION_PREGNANCY from '@salesforce/label/c.UAC_testPicklistPregnancy';
import LBL_DISEASE_STREP from '@salesforce/label/c.UAC_testPicklistStrep';
import LBL_DISEASE_SYPHILIS from '@salesforce/label/c.UAC_testPicklistSyphilis';
import LBL_RECORD_TYPE_RISK_BASED_LAB_TEST from '@salesforce/label/c.UAC_testRecTypeRiskBasedLabTest';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import FLD_IME_AGE_AT_ADMISSION from '@salesforce/schema/UAC_healthEvaluation__c.UAC_ageAtAdmission__c';
import FLD_IME_MENARCHE from '@salesforce/schema/UAC_healthEvaluation__c.UAC_hasMinorReachedMenarche__c';
import FLD_IME_INJECTION_DRUG_USE from '@salesforce/schema/UAC_healthEvaluation__c.UAC_injectionDrugs__c';
import FLD_IME_SEXUAL_ACT from '@salesforce/schema/UAC_healthEvaluation__c.UAC_sexualActivityOralVaginalAnal__c';
import OBJ_TEST from '@salesforce/schema/UAC_test__c';
import FLD_ASSOCIATED_HEALTH_EVALUATION from '@salesforce/schema/UAC_test__c.UAC_associatedHealthEvaluation__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_test__c.UAC_associatedUAC__c';
import FLD_BLOOD_LEAD_LEVEL from '@salesforce/schema/UAC_test__c.UAC_bloodLeadLevelMCGDL__c';
import FLD_DISEASE from '@salesforce/schema/UAC_test__c.UAC_diseaseConditionTested__c';
import FLD_INDICATOR from '@salesforce/schema/UAC_test__c.UAC_indicator__c';
import FLD_INFLUENZA_TYPE from '@salesforce/schema/UAC_test__c.UAC_influenzaType__c';
import FLD_RESULT from '@salesforce/schema/UAC_test__c.UAC_result__c';
import FLD_REASON_NOT_DONE from '@salesforce/schema/UAC_test__c.UAC_specifyReasonNotDone__c';
import FLD_SPECIMEN_COLLECTION_DATE from '@salesforce/schema/UAC_test__c.UAC_specimenCollectionDate__c';
import FLD_SPECIMEN_SOURCE from '@salesforce/schema/UAC_test__c.UAC_specimenSource__c';
import FLD_SYSTEM_GENERATED from '@salesforce/schema/UAC_test__c.UAC_systemGenerated__c';
import FLD_TEST from '@salesforce/schema/UAC_test__c.UAC_test__c';
import LBL_RECORD_TYPE_HEALTH_ASSESSMENT_EVAL from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import { reduceErrors } from 'c/uacUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';

const IME_FIELDS = [FLD_IME_AGE_AT_ADMISSION, FLD_IME_SEXUAL_ACT, FLD_IME_INJECTION_DRUG_USE,
  FLD_IME_MENARCHE
];
const RECORD_TYPE_RISK_BASED_LAB_TEST = 'Risk Based Lab Test';
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
    defaultValue: 'Pending',
    required: true

  },
  { name: FLD_REASON_NOT_DONE.fieldApiName, type: 'text' },
  { name: FLD_BLOOD_LEAD_LEVEL.fieldApiName, type: 'number', hide: true, required: true },
  { name: FLD_INFLUENZA_TYPE.fieldApiName, type: 'picklist', hide: true, required: true },
  {
    name: FLD_SPECIMEN_SOURCE.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName
  },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName, type: 'date' }
];
const HA_LST_FIELD = [
  { name: FLD_DISEASE.fieldApiName, type: 'picklist', required: true },
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
  { name: FLD_BLOOD_LEAD_LEVEL.fieldApiName, type: 'number', hide: true, required: true },
  { name: FLD_INFLUENZA_TYPE.fieldApiName, type: 'picklist', hide: true, required: true },
  {
    name: FLD_SPECIMEN_SOURCE.fieldApiName,
    type: 'picklist',
    controllingField: FLD_DISEASE.fieldApiName
  },
  { name: FLD_SPECIMEN_COLLECTION_DATE.fieldApiName, type: 'date' }
];
const OPT_NONE = {
  label: '--None--',
  value: ''
};

export default class UacRiskBasedTestTable extends LightningElement {

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
  @track
  hafields = HA_LST_FIELD;
  @track
  alerts = [];
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
          if (data.recordTypeInfos[key].name === RECORD_TYPE_RISK_BASED_LAB_TEST) {
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
    strRecordTypeName: LBL_RECORD_TYPE_RISK_BASED_LAB_TEST
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

  @wire(getRecord, { recordId: '$healthEvaluationId', fields: IME_FIELDS })
  wiredHealthEvaluationRecord({ data, error }) {
    if (data) {
      this.healthEvaluationRecord = data;
      this.alerts = [];
      if (this.showAlertForSexualActivity) {
        this.alerts.push(LBL_ALERT_SEXUAL_ACTIVITY);
      }
      if (this.showAlertForDrugUse) {
        this.alerts.push(LBL_ALERT_DRUG_USE);
      }
      if (this.showAlertForMenarche) {
        this.alerts.push(LBL_ALERT_MENARCHE);
      }
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get ageAtAdmission() {
    return (!this.healthEvaluationRecord) ?
      null :
      this.healthEvaluationRecord.fields[FLD_IME_AGE_AT_ADMISSION.fieldApiName].value;
  }

  get showAlertForSexualActivity() {
    return this.healthEvaluationRecord &&
      (this.healthEvaluationRecord.fields[FLD_IME_SEXUAL_ACT.fieldApiName].value === LBL_YES ||
        this.healthEvaluationRecord.fields[FLD_IME_SEXUAL_ACT.fieldApiName].value ===
        LBL_NO_BUT_SIGNS);
  }

  get showAlertForDrugUse() {
    return this.healthEvaluationRecord &&
      this.healthEvaluationRecord.fields[FLD_IME_INJECTION_DRUG_USE.fieldApiName].value;
  }

  get showAlertForMenarche() {
    return this.healthEvaluationRecord &&
      this.healthEvaluationRecord.fields[FLD_IME_MENARCHE.fieldApiName].value === LBL_YES;
  }

  initialize() {

    // Return without changes if wired data not initialized
    if (!this.objectInfo || !this.picklistValuesByRecordType || !this.dependentFieldMap ||
      !this.healthEvaluationRecord) {
      return;
    }

    let fields = [...this.fields];
    if (this.healthEvaluationRecord.recordTypeInfo.name ===
      LBL_RECORD_TYPE_HEALTH_ASSESSMENT_EVAL) {
      fields = [...this.hafields];
    }
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
          if (field.name === FLD_RESULT.fieldApiName && this.healthEvaluationRecord
            .recordTypeInfo.name === LBL_RECORD_TYPE_HEALTH_ASSESSMENT_EVAL) {
            const optionMap = field.dependentOptionMap;
            let hadependentOptionMap = {};
            Object.keys(optionMap)
              .forEach((key) => {
                var index = 0;
                var values = [];
                for (index === 0; index < optionMap[key].length; index++) {
                  if (optionMap[key][index].label !== "Not Done") {
                    values.push(optionMap[key][index]);
                  }
                }
                hadependentOptionMap[key] = values;

              });
            field.dependentOptionMap = hadependentOptionMap;
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
      let disease = row.record[FLD_DISEASE.fieldApiName];
      let result = row.record[FLD_RESULT.fieldApiName];
      let systemGenerated = row.record[FLD_SYSTEM_GENERATED.fieldApiName];
      if (systemGenerated) {
        row.disableDelete = true;
      }
      if (fld.name === FLD_DISEASE.fieldApiName && systemGenerated) {
        fld.readonly = true;
      } else if (fld.name === FLD_INFLUENZA_TYPE.fieldApiName) {
        fld.hide = !(row.record[FLD_DISEASE.fieldApiName] === LBL_DISEASE_INFLUENZA &&
          result === LBL_RESULT_POSITIVE);
      } else if (fld.name === FLD_BLOOD_LEAD_LEVEL.fieldApiName) {
        fld.hide = !(row.record[FLD_TEST.fieldApiName] === LBL_TEST_LEAD_LEVEL &&
          (result === LBL_RESULT_POSITIVE || result === LBL_RESULT_NEGATIVE));
      } else if (
        fld.name === FLD_SPECIMEN_COLLECTION_DATE.fieldApiName ||
        fld.name === FLD_SPECIMEN_SOURCE.fieldApiName
      ) {
        fld.required = (
          result === LBL_RESULT_POSITIVE ||
          result === LBL_RESULT_NEGATIVE ||
          result === LBL_RESULT_INDETERMINATE ||
          result === LBL_RESULT_SPECIMEN_REJECTED
        );
        fld.hide = (result === LBL_RESULT_NOT_DONE);
      } else if (fld.name === FLD_REASON_NOT_DONE.fieldApiName) {
        fld.hide = !(result === LBL_RESULT_NOT_DONE);
        fld.required =
          ((this.showAlertForSexualActivity &&
              (disease === LBL_DISEASE_CHLAMYDIA ||
                disease === LBL_DISEASE_GONORRHEA ||
                disease === LBL_DISEASE_HIV ||
                disease === LBL_CONDITION_PREGNANCY ||
                disease === LBL_DISEASE_SYPHILIS ||
                disease === LBL_DISEASE_HEPATITIS_B)) ||
            (this.showAlertForDrugUse &&
              (disease === LBL_DISEASE_HEPATITIS_B ||
                disease === LBL_DISEASE_HEPATITIS_C)) ||
            (this.showAlertForMenarche && disease === LBL_CONDITION_PREGNANCY) ||
            (this.ageAtAdmission >= 10 && disease === LBL_CONDITION_PREGNANCY) ||
            (this.ageAtAdmission > 0.5 && this.ageAtAdmission < 6 &&
              disease === LBL_DISEASE_LEAD) ||
            (this.ageAtAdmission >= 13 && disease === LBL_DISEASE_HIV));
      } else if (fld.name === FLD_INDICATOR.fieldApiName) {

        if (disease === LBL_DISEASE_HIV) {
          fld.value = '>= 13 yrs or Sexual Activity';
        } else if (disease === LBL_CONDITION_PREGNANCY) {
          fld.value =
            '>= 10 yrs  or < 10 who have reached menarche or report sexual activity';
        } else if (disease === LBL_DISEASE_LEAD) {
          fld.value = '6 mos up to 6 yrs';
        } else if (
          disease === LBL_DISEASE_CHLAMYDIA ||
          disease === LBL_DISEASE_GONORRHEA ||
          disease === LBL_DISEASE_SYPHILIS) {
          fld.value = 'Sexual Activity';
        } else if (disease === LBL_DISEASE_HEPATITIS_B) {
          fld.value = 'Sexual Activity or Injection Drug Use';
        } else if (disease === LBL_DISEASE_HEPATITIS_C) {
          fld.value = 'Injection Drug Use';
        } else if (disease === LBL_DISEASE_INFLUENZA) {
          fld.value = 'Fever + Cough or Sore throat';
        } else if (disease === LBL_DISEASE_STREP) {
          fld.value = 'Sore Throat + Fever without Cough';
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