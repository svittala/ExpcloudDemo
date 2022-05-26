import { LightningElement, api, track, wire } from 'lwc';
import {getObjectInfo, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/uacUtils'
import LBL_OUTCOME_NO_STATUS_CHANGE from '@salesforce/label/c.UAC_diagnosisOutcomeNoStatusChange';
import LBL_OUTCOME_STATUS_CHANGE from '@salesforce/label/c.UAC_diagnosisOutcomeStatusChange';
import LBL_OUTCOME_RULED_OUT from '@salesforce/label/c.UAC_diagnosisOutcomeRuledOut';
import LBL_OUTCOME_RULED_OUT_REPLACE from '@salesforce/label/c.UAC_diagnosisOutcomeRuledOutReplace';
import LBL_DIAGNOSIS_STATUS_RULED_OUT from '@salesforce/label/c.UAC_diagnosisStatusRuledOut';
import LBL_FINAL from '@salesforce/label/c.UAC_statusFinal';
import LBL_WORKING from '@salesforce/label/c.UAC_diagnosisStatusWorking';
import OBJ_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c';
import OBJ_OUTCOME from '@salesforce/schema/UAC_diagnosisOutcome__c';
import FLD_OUTCOME_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_diagnosisOutcome__c.UAC_associatedHealthEvaluation__c';
import FLD_OUTCOME_ASSOCIATED_DIAGNOSIS from '@salesforce/schema/UAC_diagnosisOutcome__c.UAC_associatedDiagnosis__c';
import FLD_OUTCOME_EVALUATION_OUTCOME from '@salesforce/schema/UAC_diagnosisOutcome__c.UAC_outcomeofEvaluation__c';
import FLD_OUTCOME_EVALUATION_NOTE from '@salesforce/schema/UAC_diagnosisOutcome__c.UAC_evaluationNotes__c';
import FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedHealthEvaluation__c';
import FLD_DIAGNOSIS_ASSOCIATED_UAC from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedUAC__c';
import FLD_DIAGNOSIS_PARENT_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c.UAC_parentDiagnosis__c';
import FLD_DIAGNOSIS_CATEGORY from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCategory__c';
import FLD_DIAGNOSIS_CONDITION from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCondition__c';
import FLD_DIAGNOSIS_CONDITION_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_specifyOtherWDCondition__c';
import FLD_DIAGNOSIS_END_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_endDate__c';
import FLD_DIAGNOSIS_LAST_SEXUAL_ENCOUNTER_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_dateOfLastSexualEncounter__c';
import FLD_DIAGNOSIS_LAST_SEXUAL_ENCOUNTER_MONTHS from '@salesforce/schema/UAC_diagnosis__c.UAC_monthsSinceLastSexualEncounter__c';
import FLD_DIAGNOSIS_DURING_JOURNEY_TO_US from '@salesforce/schema/UAC_diagnosis__c.UAC_duringJourneyToUS__c';
import FLD_DIAGNOSIS_IN_HOME_COUNTRY from '@salesforce/schema/UAC_diagnosis__c.UAC_inHomeCountry__c';
import FLD_DIAGNOSIS_IN_ORR from '@salesforce/schema/UAC_diagnosis__c.UAC_inORRCustody__c';
import FLD_DIAGNOSIS_IN_US_NOT_ORR from '@salesforce/schema/UAC_diagnosis__c.UAC_inUSNotInORRCustody__c';
import FLD_DIAGNOSIS_DURING_JOURNEY_TO_US_SPECIFY from '@salesforce/schema/UAC_diagnosis__c.UAC_duringJourneyToUSSpecify__c';
import FLD_DIAGNOSIS_IN_HOME_COUNTRY_SPECIFY from '@salesforce/schema/UAC_diagnosis__c.UAC_inHomeCountrySpecify__c';
import FLD_DIAGNOSIS_IN_ORR_SPECIFY from '@salesforce/schema/UAC_diagnosis__c.UAC_inORRCustodySpecify__c';
import FLD_DIAGNOSIS_IN_US_NOT_ORR_SPECIFY from '@salesforce/schema/UAC_diagnosis__c.UAC_inUSNotInORRCustodySpecify__c';
import FLD_DIAGNOSIS_GESTATIONAL_AGE from '@salesforce/schema/UAC_diagnosis__c.UAC_currentGestationalAge__c';
import FLD_DIAGNOSIS_ESTIMATED_DUE_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_estimatedDueDate__c';
import FLD_DIAGNOSIS_CONDITION_TYPE from '@salesforce/schema/UAC_diagnosis__c.UAC_WDConditionType__c';
import FLD_DIAGNOSIS_CONDITION_TYPE_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_specifyOtherWDConditionType__c';
import FLD_DIAGNOSIS_PRID_HD_NOTIFIED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c';
import FLD_DIAGNOSIS_FOLLOW_UP from '@salesforce/schema/UAC_diagnosis__c.UAC_wdFollowUpVisitRequired__c';
import FLD_DIAGNOSIS_FOLLOW_UP_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdFollowUpVisitDate__c';
import FLD_DIAGNOSIS_SPECIALIST_VISIT_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdReferralToSpecialistRequired__c';
import FLD_DIAGNOSIS_SPECIALIST_TYPE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdSpecialistType__c';
import FLD_DIAGNOSIS_SPECIALIST_TYPE_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_otherSpecialistType__c';
import FLD_DIAGNOSIS_SPECIALITY_SERVICES from '@salesforce/schema/UAC_diagnosis__c.UAC_specialityServices__c';
import FLD_DIAGNOSIS_SPECIALIST_VISIT_DUE_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_specialistVisitEstimatedDueDate__c';
import FLD_DIAGNOSIS_ISOLATION_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdIsIsolationQuarantineRequired__c';
import FLD_DIAGNOSIS_ISOLATION_START_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdIsolationQuarantineStartDate__c';
import FLD_DIAGNOSIS_ISOLATION_END_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdIsolationQuarantineEndDate__c';
import FLD_DIAGNOSIS_DELAYED_DISCHARGE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdWillDischargeNeedtobeDelayed__c';
import FLD_DIAGNOSIS_DELAYED_DISCHARGE_END_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_delayedDischargeEstimatedEndDate__c';
import FLD_DIAGNOSIS_STATUS from '@salesforce/schema/UAC_diagnosis__c.UAC_status__c';
import FLD_DIAGNOSIS_CBP_REACH_BACK_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_CBPReachBackRequired__c';
import FLD_DIAGNOSIS_CBP_REACH_BACK_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_CBPReachBackDateSent__c';
import FLD_DIAGNOSIS_ICE_NOTIFICATION_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_ICENotificationRequired__c';
import FLD_DIAGNOSIS_ICE_NOTIFICATION_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_ICENotificationDateSent__c';
import FLD_DIAGNOSIS_SHD_NOTIFICATION_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_SHDNotificationRequired__c';
import FLD_DIAGNOSIS_SHD_NOTIFICATION_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_SHDNotificationDateSent__c';
import FLD_DIAGNOSIS_POTENTIALLY_EXPOSED_UAC from '@salesforce/schema/UAC_diagnosis__c.UAC_potentiallyExposedUAC__c';
import FLD_DIAGNOSIS_POTENTIALLY_EXPOSED_STAFF from '@salesforce/schema/UAC_diagnosis__c.UAC_potentiallyExposedStaff__c';
import FLD_DIAGNOSIS_RECORD_TYPE_NAME from '@salesforce/schema/UAC_diagnosis__c.RecordType.Name';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import LBL_BEHAVIORAL_MENTAL_HEALTH_CONCERN from '@salesforce/label/c.UAC_diagnosisCategoryBehavioralAndMentalHealthConcerns';
import LBL_CONDITION_PREGNANT from '@salesforce/label/c.UAC_diagnosisConditionPregnant';
import LBL_CONDITIONS_FOR_PRID from '@salesforce/label/c.UAC_diagnosisConditionsForPRIDSection';
import LBL_CONDITIONS_FOR_CONDITION_TYPE from '@salesforce/label/c.UAC_diagnosisConditionsForConditionType';
import LBL_CONDITIONS_FOR_SEXUAL_ACTIVITY from '@salesforce/label/c.UAC_diagnosisConditionsForSexualActivitySection';
import LBL_CONDITIONS_FOR_SPECIFY_OTHER from '@salesforce/label/c.UAC_diagnosisConditionsForSpecifyOther';
import LBL_MENTAL_CONDITIONS_FOR_SPECIFY_OTHER from '@salesforce/label/c.UAC_mentalDiagnosisConditionsForSpecifyOther';
import LBL_CONDITIONS_FOR_EXPOSURE_DETAILS from '@salesforce/label/c.UAC_diagnosisConditionsForExposureDetails';
import LBL_CONDITION_TYPES_FOR_EXPOSURE_DETAILS from '@salesforce/label/c.UAC_diagnosisConditionTypesForExposureDetails';
import LBL_SECTION_DIAGNOSIS_PLAN from '@salesforce/label/c.UAC_diagnosisSectionDiagnosisPlan';
import LBL_SECTION_PREGNANCY_DETAILS from '@salesforce/label/c.UAC_diagnosisSectionPregnancyDetails';
import LBL_SECTION_EXPOSURE_DETAILS from '@salesforce/label/c.UAC_diagnosisSectionExposureDetails';
import LBL_SECTION_PRID from '@salesforce/label/c.UAC_diagnosisSectionPRID';
import LBL_OTHER from '@salesforce/label/c.UAC_other';
import LBL_PRID from '@salesforce/label/c.UAC_PRID';
import LBL_RECORD_TYPE_HEALTH_EVAL_HA from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import LBL_RECORD_TYPE_HEALTH_EVAL_MHSR from '@salesforce/label/c.UAC_recordTypeMentalHealthServiceReport';
import LBL_RECORD_TYPE_DIAGNOSIS_HA from '@salesforce/label/c.UAC_diagnosisRecordTypeHA';
import LBL_RECORD_TYPE_DIAGNOSIS_MHD from '@salesforce/label/c.UAC_recordTypeMentalHealthDiagnosis';
import LBL_RECORD_TYPE_DIAGNOSIS_IME from '@salesforce/label/c.UAC_diagnosisRecordTypeIME';
import LBL_TITLE_UPDATE_OUTCOME from '@salesforce/label/c.UAC_titleUpdateDiagnosisOutcome';
import LBL_SAVE_ERROR from '@salesforce/label/c.UAC_toastMessageSaveError';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_toastMessageDiagnosisOutcomeUpdateSuccess';
import updateDiagnosisOutcome from '@salesforce/apex/UAC_diagnosisOutcomeController.updateDiagnosisOutcome';

const TITLE = LBL_TITLE_UPDATE_OUTCOME;
const SUCCESS_MESSAGE = LBL_SAVE_SUCCESS;
const SAVE_ERROR_TITLE = LBL_SAVE_ERROR;
const OUTCOME_FIELDS = [
  { name: FLD_OUTCOME_EVALUATION_OUTCOME.fieldApiName, type: "picklist", required: true },
  { name: FLD_OUTCOME_EVALUATION_NOTE.fieldApiName, type: "textarea" }
];
const DIAGNOSIS_STATUS_OPTIONS = [
  { label: LBL_WORKING, value: LBL_WORKING },
  { label: LBL_FINAL, value: LBL_FINAL }
];
const DIAGNOSIS_UPDATE_STATUS_SECTION_FIELDS = [
  {name: FLD_DIAGNOSIS_STATUS.fieldApiName, type: 'picklist', required: true, options: DIAGNOSIS_STATUS_OPTIONS},
  {name: FLD_DIAGNOSIS_END_DATE.fieldApiName, type: 'date'}
];
const EXCLUDE_FIELDS_FOR_DIAGNOSIS_REPLACEMENT = [
  FLD_DIAGNOSIS_STATUS.fieldApiName
];
const SECTON_PRID = LBL_SECTION_PRID;
const CATEGORY_FOR_PRID_HD_NOTIFIED = new Set([LBL_PRID]);
const CONDITION_TYPE_FOR_SPECIFY_OTHER = new Set([LBL_OTHER]);
const CONDITION_FOR_SEXUAL_ACTIVITY = new Set(
  LBL_CONDITIONS_FOR_SEXUAL_ACTIVITY.split(/\r?\n/)
);
const CONDITION_FOR_CONDITION_TYPE_REQUIRED = new Set(
  LBL_CONDITIONS_FOR_CONDITION_TYPE.split(/\r?\n/)
);
const CONDITION_FOR_PRID_SECTION = new Set(
  LBL_CONDITIONS_FOR_PRID.split(/\r?\n/)
);
const CONDITION_FOR_SPECIFY_OTHER = new Set(
  LBL_CONDITIONS_FOR_SPECIFY_OTHER.split(/\r?\n/)
);
const MENTAL_CONDITION_FOR_SPECIFY_OTHER = new Set(
  LBL_MENTAL_CONDITIONS_FOR_SPECIFY_OTHER.split(/\r?\n/)
);
const CONDITIONS_FOR_EXPOSURE_DETAILS = new Set(
  LBL_CONDITIONS_FOR_EXPOSURE_DETAILS.split(/\r?\n/)
);
const CONDITION_TYPES_FOR_EXPOSURE_DETAILS = new Set(
  LBL_CONDITION_TYPES_FOR_EXPOSURE_DETAILS.split(/\r?\n/)
);
const SECTIONS_FOR_UPDATE_DIAGNOSIS_PLAN = [
  LBL_SECTION_EXPOSURE_DETAILS,
  LBL_SECTION_PREGNANCY_DETAILS,
  LBL_SECTION_DIAGNOSIS_PLAN
];

export default class UacDiagnosisOutcome extends LightningElement {

  @api
  show(recordId, associatedHealthEvaluationId, associatedDiagnosisId) {
    this.recordId = recordId;
    this.associatedHealthEvaluationId = associatedHealthEvaluationId;
    this.associatedDiagnosisId = associatedDiagnosisId;
    if (this.wiredHealthEvalRecord) {
      refreshApex(this.wiredHealthEvalRecord);
    }
    if(this.wiredOutcomeRecord) {
      refreshApex(this.wiredOutcomeRecord);
    }
    if(this.wiredDiagnosisRecord) {
      refreshApex(this.wiredDiagnosisRecord);
    }
    this.showModal();
  }

  @track layout = { sections: [] }
  @track associatedHealthEvaluationId;
  @track associatedUACId;
  @track associatedDiagnosisId;
  @track recordId;
  @track outcomeOfEvaluation;
  @track replacementDiagnosisRecordType;
  @track isLoading = false;
  @track error;
  @track diagnosisRecord;
  @track diagnosisUpdateStatusSectionFields = [];
  @track outcomeFields = [];
  @track outcomeRecord;
  @track initialized = false;

  saveErrorTitle = SAVE_ERROR_TITLE;
  objDiagnosisApiName = OBJ_DIAGNOSIS.objectApiName;
  fldDiagnosisAssociatedHealthEval = FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName;
  fldDiagnosisAssociatedUAC = FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName;
  fldDiagnosisParentDiagnosis = FLD_DIAGNOSIS_PARENT_DIAGNOSIS.fieldApiName;
  title = TITLE;
  sectionsForUpdateDiagnosisPlan = SECTIONS_FOR_UPDATE_DIAGNOSIS_PLAN;
  excludeFieldsForDiagnosisReplacement = EXCLUDE_FIELDS_FOR_DIAGNOSIS_REPLACEMENT;
  outcomeObjectInfo;
  outcomePicklistValues;
  diagnosisObjectInfo;
  associatedDiagnosisRecord;
  associatedDiagnosisRecordType;
  newDiagnosisRecord;
  wiredHealthEvalRecord;
  wiredOutcomeRecord;
  wiredDiagnosisRecord;
  diagnosisStatusOld; // Holds old value of diagnosis status.
  showPregnancyDetailsSection = false;
  showExposureDetailsSection = false;

  @wire(getObjectInfo, {objectApiName: OBJ_OUTCOME.objectApiName})
  wiredGetOutcomeObjectInfo({data, error}) {
    if(data) {
      this.outcomeObjectInfo = data;
    }else if(error) {
      this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
    }
  }

  @wire(getPicklistValuesByRecordType, { objectApiName: OBJ_OUTCOME, recordTypeId: '$outcomeObjectInfo.defaultRecordTypeId' })
  wiredOutcomePicklistValues({data,error}) {
    if(data) {
      this.outcomePicklistValues = data.picklistFieldValues;
      this.initialize();
    } else if(error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      FLD_OUTCOME_EVALUATION_OUTCOME,
      FLD_OUTCOME_EVALUATION_NOTE
    ]
  })
  wiredOutcomeGetRecord(response) {
    this.wiredOutcomeRecord = response;
    let {data,error} = response;
    if (data) {
      this.outcomeRecord = {};
      Object.keys(data.fields).forEach(key => {
        this.outcomeRecord[key] = data.fields[key].value;
      });
      this.outcomeOfEvaluation = this.outcomeRecord[FLD_OUTCOME_EVALUATION_OUTCOME.fieldApiName];
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getObjectInfo, {objectApiName: OBJ_DIAGNOSIS.objectApiName})
  wiredGetDiagnosisObjectInfo({data, error}) {
    if(data) {
      this.diagnosisObjectInfo = data;
      this.initialize();
    }else if(error) {
      this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
    }
  }

  @wire(getRecord, {
    recordId: "$associatedHealthEvaluationId",
    fields: [
      FLD_HEALTH_EVAL_ASSOCIATED_UAC
    ]
  })
  wiredHealthEvaluationGetRecord(response) {
    this.wiredHealthEvalRecord = response;
    const { data, error } = response;
    if (data) {
      this.associatedUACId = data.fields[FLD_HEALTH_EVAL_ASSOCIATED_UAC
        .fieldApiName].value;
      if (data.recordTypeInfo.name === LBL_RECORD_TYPE_HEALTH_EVAL_HA) {
        this.replacementDiagnosisRecordType = LBL_RECORD_TYPE_DIAGNOSIS_HA;
      } else if(data.recordTypeInfo.name === LBL_RECORD_TYPE_HEALTH_EVAL_MHSR){
        this.replacementDiagnosisRecordType = LBL_RECORD_TYPE_DIAGNOSIS_MHD;
      } else {
        this.replacementDiagnosisRecordType = LBL_RECORD_TYPE_DIAGNOSIS_IME;
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getRecord, {
    recordId: "$associatedDiagnosisId",
    fields: [
      FLD_DIAGNOSIS_STATUS,
      FLD_DIAGNOSIS_CATEGORY,
      FLD_DIAGNOSIS_CONDITION,
      FLD_DIAGNOSIS_CONDITION_TYPE,
      FLD_DIAGNOSIS_END_DATE,
      FLD_DIAGNOSIS_RECORD_TYPE_NAME
    ]
  })
  wiredDiagnosisGetRecord(response) {
    this.wiredDiagnosisRecord = response;
    let { data, error } = response;
    if (data) {
      this.diagnosisRecord = {};
      Object.keys(data.fields).forEach(key => {
        this.diagnosisRecord[key] = data.fields[key].value;
        if(key === 'RecordType') {
          delete this.diagnosisRecord.RecordType;
          this.associatedDiagnosisRecordType = data.fields.RecordType.value.fields.Name.value;
        }
      });
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  initialize() {
    if(!this.recordId) {
      this.outcomeRecord = {};
    }
    if(!this.diagnosisObjectInfo || !this.diagnosisRecord || !this.outcomeObjectInfo || !this.outcomeRecord || !this.outcomePicklistValues || this.initialized) {
      return;
    }
    let cmp = this;

    // Initialize Diagnosis Outcome field labels and value
    this.outcomeFields = JSON.parse(JSON.stringify(OUTCOME_FIELDS));
    this.outcomeFields.forEach(fld => {
      fld.label = this.outcomeObjectInfo.fields[fld.name].label;
      if(fld.type === "picklist") {
        let options = [];
        this.outcomePicklistValues[FLD_OUTCOME_EVALUATION_OUTCOME.fieldApiName].values.forEach(opt => {
          if(!this.allowOnlyRuledOut ||
          opt.value === LBL_OUTCOME_RULED_OUT ||
          opt.value === LBL_OUTCOME_RULED_OUT_REPLACE) {
            options.push({label: opt.label, value: opt.value});
          }
        });
        fld.options = options;
      }
      Object.defineProperty(fld, 'value', {
        get: function() {
          return (cmp.outcomeRecord) ? cmp.outcomeRecord[this.name] : null;
        },
        set: function(value) {
          cmp.outcomeRecord[this.name] = value;
        }
      });
    });

    // Initialize Diagnosis field labels and value
    this.diagnosisStatusOld = this.diagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName];
    this.diagnosisUpdateStatusSectionFields = JSON.parse(JSON.stringify(
      DIAGNOSIS_UPDATE_STATUS_SECTION_FIELDS.filter(fld => {
        return (this.isMentalHealthDiagnosis) ? true : fld.name === FLD_DIAGNOSIS_STATUS.fieldApiName;
      })
    ));
    this.diagnosisUpdateStatusSectionFields.forEach(fld=> {
      fld.label = this.diagnosisObjectInfo.fields[fld.name].label;
      Object.defineProperty(fld, 'value', {
        get: function() {
          return (cmp.diagnosisRecord) ? cmp.diagnosisRecord[this.name] : null;
        },
        set: function(value) {
          cmp.diagnosisRecord[this.name] = value;
        }
      });
    });

    this.initialized = true;
  }

  get allowOnlyRuledOut() {
    return (this.diagnosisRecord && this.diagnosisRecord[
      FLD_DIAGNOSIS_CATEGORY.fieldApiName
    ] === LBL_BEHAVIORAL_MENTAL_HEALTH_CONCERN);
  }

  get diagnosisForm() {
    return this.template.querySelector('c-uac-record-edit-form');
  }

  get lblWorking() {
    return LBL_WORKING;
  }

  get lblFinal() {
    return LBL_FINAL;
  }

  get diagnosisStatus() {
    if( this.diagnosisRecord &&  this.diagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName]) {
      return this.diagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName];
    }
    return undefined;
  }

  get isHealthAssessment() {
    return this.replacementDiagnosisRecordType === LBL_RECORD_TYPE_DIAGNOSIS_HA;
  }

  get isMentalHealthEval() {
    return this.replacementDiagnosisRecordType === LBL_RECORD_TYPE_DIAGNOSIS_MHD;
  }

  get isMentalHealthDiagnosis() {
    return this.associatedDiagnosisRecordType === LBL_RECORD_TYPE_DIAGNOSIS_MHD;
  }

  handleLoadComplete() {
    this.checkConditionalRules();
  }

  handleUpdateDiagnosisPlanLoadComplete() {
    this.diagnosisForm.form.sections.forEach((section) => {
      if (section.heading === LBL_SECTION_DIAGNOSIS_PLAN) {
        section.layoutRows.forEach((layoutRow) => {
          layoutRow.layoutItems.forEach((layoutItem) => {
            layoutItem.layoutComponents.forEach((layoutComponent) => {
              if (layoutComponent.isField) {
                layoutComponent.value = null;
              }
            });
          });
        });
      }
    });
    this.checkConditionalRules();
  }

  get updateDiagnosisPlan() {
    return this.outcomeOfEvaluation === LBL_OUTCOME_NO_STATUS_CHANGE || this
      .outcomeOfEvaluation === LBL_OUTCOME_STATUS_CHANGE;
  }

  get updateDiagnosisStatus() {
    return this.outcomeOfEvaluation === LBL_OUTCOME_STATUS_CHANGE;
  }

  get replaceDiagnosis() {
    return this.outcomeOfEvaluation === LBL_OUTCOME_RULED_OUT_REPLACE;
  }

  get showUpdateStatusTitle() {
    return this.updateDiagnosisStatus ||
      (this.updateDiagnosisPlan &&
        (this.showPregnancyDetailsSection || this.showExposureDetailsSection)
      );
  }

  handleOutcomeFieldChange(event) {
    const fieldName = event.target.dataset.id;
    this.outcomeRecord[fieldName] =
      (Object.prototype.hasOwnProperty.call(event.detail, 'checked')) ?
      event.detail.checked :
      event.detail.value;
    if (fieldName === FLD_OUTCOME_EVALUATION_OUTCOME.fieldApiName) {
      this.outcomeOfEvaluation = event.detail.value;
    }
  }

  handleDiagnosisStatusUpdateChange(event) {
    let fieldName = event.target.dataset.id;
    this.diagnosisRecord[fieldName] =
      (Object.prototype.hasOwnProperty.call(event.detail, 'checked')) ?
      event.detail.checked :
      event.detail.value;
    this.checkConditionalRules();
  }

  handleDiagnosisFieldChange() {
    this.checkConditionalRules();
  }

  checkConditionalRules() {
    if(!this.diagnosisForm.form) {
      return;
    }
    const diagnosisRecord = this.diagnosisForm.getRecord();
    // If replacement diagnosis, predefine status as final
    if (this.replaceDiagnosis) {
      diagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName] = LBL_FINAL;
    }
    // If update diagnosis plan, copy queried diagnosis category into diagnosisRecord
    if (this.updateDiagnosisPlan) {
      diagnosisRecord[FLD_DIAGNOSIS_CATEGORY.fieldApiName] = this.diagnosisRecord[FLD_DIAGNOSIS_CATEGORY.fieldApiName];
      diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName] = this.diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName];
      diagnosisRecord[FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName] = this.diagnosisRecord[FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName];
    }
    this.diagnosisForm.form.sections.forEach((section) => {
      if (section.heading === SECTON_PRID) {
        section.hide = !(
          diagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName] === LBL_FINAL &&
          CONDITION_FOR_PRID_SECTION.has(
            diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
          )
        );
      }
      section.layoutRows.forEach((layoutRow) => {
        layoutRow.layoutItems.forEach((layoutItem) => {
          layoutItem.layoutComponents.forEach((layoutComponent) => {
            if (layoutComponent.isField) {
              layoutComponent.value = diagnosisRecord[layoutComponent
                .apiName];
              switch (layoutComponent.apiName) {
              case FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName:
                layoutComponent.hide = !(
                  (this.isMentalHealthEval &&
                  MENTAL_CONDITION_FOR_SPECIFY_OTHER.has(
                    diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
                  )) ||
                  CONDITION_FOR_SPECIFY_OTHER.has(
                    diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
                  )
                );
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_PRID_HD_NOTIFIED.fieldApiName:
                layoutComponent.hide = !CATEGORY_FOR_PRID_HD_NOTIFIED.has(
                  diagnosisRecord[FLD_DIAGNOSIS_CATEGORY.fieldApiName]
                );
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_CONDITION_TYPE_OTHER.fieldApiName:
                layoutComponent.hide = !CONDITION_TYPE_FOR_SPECIFY_OTHER.has(
                  diagnosisRecord[
                    FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName
                  ]
                );
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_FOLLOW_UP_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_FOLLOW_UP.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_SPECIALIST_TYPE.fieldApiName:
              case FLD_DIAGNOSIS_SPECIALIST_VISIT_DUE_DATE.fieldApiName:
              case FLD_DIAGNOSIS_SPECIALITY_SERVICES.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_SPECIALIST_VISIT_REQUIRED.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide &&
                  layoutComponent.apiName!==FLD_DIAGNOSIS_SPECIALITY_SERVICES.fieldApiName;
                break;
              case FLD_DIAGNOSIS_SPECIALIST_TYPE_OTHER.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_SPECIALIST_TYPE.fieldApiName
                ] !== LBL_OTHER;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_ISOLATION_START_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_ISOLATION_REQUIRED.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_ISOLATION_END_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_ISOLATION_REQUIRED.fieldApiName
                ] !== LBL_YES;
                break;
              case FLD_DIAGNOSIS_DELAYED_DISCHARGE_END_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_DELAYED_DISCHARGE.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName:
                layoutComponent.required = (
                  diagnosisRecord[
                    FLD_DIAGNOSIS_STATUS.fieldApiName
                  ] === LBL_FINAL &&
                  CONDITION_FOR_CONDITION_TYPE_REQUIRED.has(
                    diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
                  )
                );
                break;
              case FLD_DIAGNOSIS_CBP_REACH_BACK_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_CBP_REACH_BACK_REQUIRED.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_ICE_NOTIFICATION_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_ICE_NOTIFICATION_REQUIRED.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_SHD_NOTIFICATION_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_SHD_NOTIFICATION_REQUIRED.fieldApiName
                ] !== LBL_YES;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_POTENTIALLY_EXPOSED_UAC.fieldApiName:
              case FLD_DIAGNOSIS_POTENTIALLY_EXPOSED_STAFF.fieldApiName:
                layoutComponent.hide = !(
                  (
                    (this.diagnosisStatusOld === LBL_WORKING && this.diagnosisStatus === LBL_FINAL)
                    ||
                    this.replaceDiagnosis
                  )
                  && (
                    CONDITIONS_FOR_EXPOSURE_DETAILS.has(
                      diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
                    ) ||
                    CONDITION_TYPES_FOR_EXPOSURE_DETAILS.has(
                      diagnosisRecord[FLD_DIAGNOSIS_CONDITION_TYPE
                        .fieldApiName]
                    )
                  )
                );
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_GESTATIONAL_AGE.fieldApiName:
              case FLD_DIAGNOSIS_ESTIMATED_DUE_DATE.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_CONDITION.fieldApiName
                ] !== LBL_CONDITION_PREGNANT;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_LAST_SEXUAL_ENCOUNTER_DATE.fieldApiName:
              case FLD_DIAGNOSIS_LAST_SEXUAL_ENCOUNTER_MONTHS.fieldApiName:
              case FLD_DIAGNOSIS_IN_HOME_COUNTRY.fieldApiName:
              case FLD_DIAGNOSIS_DURING_JOURNEY_TO_US.fieldApiName:
              case FLD_DIAGNOSIS_IN_US_NOT_ORR.fieldApiName:
              case FLD_DIAGNOSIS_IN_ORR.fieldApiName:
                layoutComponent.hide = !(CONDITION_FOR_SEXUAL_ACTIVITY.has(
                  diagnosisRecord[
                    FLD_DIAGNOSIS_CONDITION.fieldApiName
                  ]) && this.isHealthAssessment);
                break;
              case FLD_DIAGNOSIS_IN_HOME_COUNTRY_SPECIFY.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_IN_HOME_COUNTRY.fieldApiName
                ] === false;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_DURING_JOURNEY_TO_US_SPECIFY.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_DURING_JOURNEY_TO_US.fieldApiName
                ] === false;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_IN_US_NOT_ORR_SPECIFY.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_IN_US_NOT_ORR.fieldApiName
                ] === false;
                layoutComponent.required = !layoutComponent.hide;
                break;
              case FLD_DIAGNOSIS_IN_ORR_SPECIFY.fieldApiName:
                layoutComponent.hide = diagnosisRecord[
                  FLD_DIAGNOSIS_IN_ORR.fieldApiName
                ] === false;
                layoutComponent.required = !layoutComponent.hide;
                break;
              default:
                break;
              }
              if (layoutComponent.hide || section.hide) {
                layoutComponent.value = (typeof (layoutComponent.value) ===
                  "boolean") ? false : null;
              }
              diagnosisRecord[layoutComponent.apiName] = layoutComponent.value;
            }
          })
        })
      });
    });

    this.showPregnancyDetailsSection = diagnosisRecord[
      FLD_DIAGNOSIS_CONDITION.fieldApiName
    ] === LBL_CONDITION_PREGNANT;
    this.showExposureDetailsSection = (
      this.diagnosisStatusOld === LBL_WORKING &&
      this.diagnosisStatus === LBL_FINAL && (
        CONDITIONS_FOR_EXPOSURE_DETAILS.has(
          diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
        ) ||
        CONDITION_TYPES_FOR_EXPOSURE_DETAILS.has(
          diagnosisRecord[FLD_DIAGNOSIS_CONDITION_TYPE
            .fieldApiName]
        )
      )
    );
  }

  submittedDiagnosisPlan = false;
  submittedDiagnosisReplacement = false;

  validateInput() {
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      return validSoFar && cmpValidity;
    }, true);
    return isValid;
  }

  handleSave() {
    this.isLoading = true;
    this.error = undefined;
    this.associatedDiagnosisRecord = {};
    this.newDiagnosisRecord = {};
    this.submittedDiagnosisPlan = false;
    this.submittedDiagnosisReplacement = false;
    this.validateInput();
    this.saveDiagnosisOutcome();
    if (this.diagnosisForm) {
      this.diagnosisForm.save();
    }
  }

  handleDiagnosisPlanSubmit(event) {
    event.preventDefault();
    Object.keys(event.detail.fields)
      .forEach((fld) => {
        this.associatedDiagnosisRecord[fld] = event.detail.fields[fld];
      });
    this.submittedDiagnosisPlan = true;
    this.saveDiagnosisOutcome();
  }

  handleDiagnosisStatusSubmit(event) {
    event.preventDefault();
    Object.keys(event.detail.fields)
      .forEach((fld) => {
        this.associatedDiagnosisRecord[fld] = event.detail.fields[fld];
      });
    this.submittedDiagnosisStatus = true;
    this.saveDiagnosisOutcome();
  }

  handleDiagnosisReplacementSubmit(event) {
    event.preventDefault();
    this.newDiagnosisRecord = JSON.parse(JSON.stringify(event.detail.fields));
    this.newDiagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName] = LBL_FINAL;
    this.newDiagnosisRecord.RecordTypeId = this.diagnosisForm.getRecord()
      .RecordTypeId;
    this.submittedDiagnosisReplacement = true;
    this.saveDiagnosisOutcome();
  }

  saveDiagnosisOutcome() {
    const diagnosisStatus = this.template.querySelector(
      `c-uac-input[data-id="${FLD_DIAGNOSIS_STATUS.fieldApiName}"]`);
    if (!this.validateInput() ||
      (this.replaceDiagnosis && !this.submittedDiagnosisReplacement) ||
      (this.updateDiagnosisStatus && !diagnosisStatus.validate()) ||
      (this.updateDiagnosisPlan && !this.submittedDiagnosisPlan)) {
      return;
    }

    this.outcomeRecord[FLD_OUTCOME_ASSOCIATED_DIAGNOSIS.fieldApiName] = this.associatedDiagnosisId;
    this.outcomeRecord[FLD_OUTCOME_ASSOCIATED_HEALTH_EVAL.fieldApiName] = this.associatedHealthEvaluationId;

    if (this.updateDiagnosisStatus) {
      this.diagnosisUpdateStatusSectionFields.forEach(fld=> {
        this.associatedDiagnosisRecord[fld.name] = fld.value;
      });
    }

    this.outcomeRecord.Id = this.recordId;
    this.associatedDiagnosisRecord.Id = this.associatedDiagnosisId;
    if (this.outcomeOfEvaluation === LBL_OUTCOME_RULED_OUT || this.outcomeOfEvaluation ===
      LBL_OUTCOME_RULED_OUT_REPLACE) {
      this.associatedDiagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName] =
        LBL_DIAGNOSIS_STATUS_RULED_OUT;
      if (this.outcomeOfEvaluation === LBL_OUTCOME_RULED_OUT_REPLACE) {
        this.newDiagnosisRecord[FLD_DIAGNOSIS_STATUS.fieldApiName] = LBL_FINAL;
      }
    }
    updateDiagnosisOutcome({
        strOutcome: JSON.stringify(this.outcomeRecord),
        strAssociatedDiagnosis: JSON.stringify(this.associatedDiagnosisRecord),
        strNewDiagnosis: (this.replaceDiagnosis) ? JSON.stringify(this.newDiagnosisRecord) : ''
      })
      .then(response => {
        if (!response.isSuccess) {
          this.error = response.error;
          if (this.recordId) {
            getRecordNotifyChange([{ recordId: this.recordId }]);
          }
        } else {
          this.showToastMessage('Success', SUCCESS_MESSAGE, 'success');
          this.dispatchEvent(new CustomEvent('success', {}));
          this.handleClose();
        }
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  handleError() {
    this.isLoading = false;
    this.template.querySelector('.slds-modal__content')
      .scrollTop = 0;
  }

  showModal() {
    this.template.querySelector('c-uac-modal')
      .show();
  }

  hideModal() {
    this.template.querySelector('c-uac-modal')
      .hide();
  }

  handleClose() {
    this.isLoading = false;
    this.hideModal();
    this.recordId = undefined;
    this.associatedDiagnosisId = undefined;
    this.associatedHealthEvaluationId = undefined;
    this.outcomeOfEvaluation = undefined;
    this.replacementDiagnosisRecordType = undefined;
    this.diagnosisRecord = undefined;
    this.outcomeRecord = undefined;
    this.error = undefined;
    this.initialized = false;
  }

  showToastMessage(title, message, variant) {
    this.isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }
}