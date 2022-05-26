import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/uacUtils'
import { refreshApex } from '@salesforce/apex';
import FLD_HEALTH_EVAL_RECORD_TYPE_NAME from '@salesforce/schema/UAC_healthEvaluation__c.RecordType.Name';
import OBJ_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c';
import FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedHealthEvaluation__c';
import FLD_DIAGNOSIS_ASSOCIATED_UAC from '@salesforce/schema/UAC_diagnosis__c.UAC_associatedUAC__c';
import FLD_DIAGNOSIS_PARENT_DIAGNOSIS from '@salesforce/schema/UAC_diagnosis__c.UAC_parentDiagnosis__c';
import FLD_DIAGNOSIS_CATEGORY from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCategory__c';
import FLD_DIAGNOSIS_CONDITION from '@salesforce/schema/UAC_diagnosis__c.UAC_WDCondition__c';
import FLD_DIAGNOSIS_CONDITION_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_specifyOtherWDCondition__c';
import FLD_DIAGNOSIS_CONDITION_TYPE from '@salesforce/schema/UAC_diagnosis__c.UAC_WDConditionType__c';
import FLD_DIAGNOSIS_CONDITION_TYPE_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_specifyOtherWDConditionType__c';
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
import FLD_DIAGNOSIS_PRID_HD_NOTIFIED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdIfPRIDDiagnosishasHDBeenNotified__c';
import FLD_DIAGNOSIS_FOLLOW_UP from '@salesforce/schema/UAC_diagnosis__c.UAC_wdFollowUpVisitRequired__c';
import FLD_DIAGNOSIS_FOLLOW_UP_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdFollowUpVisitDate__c';
import FLD_DIAGNOSIS_SPECIALIST_VISIT_REQUIRED from '@salesforce/schema/UAC_diagnosis__c.UAC_wdReferralToSpecialistRequired__c';
import FLD_DIAGNOSIS_SPECIALIST_TYPE from '@salesforce/schema/UAC_diagnosis__c.UAC_wdSpecialistType__c';
import FLD_DIAGNOSIS_SPECIALIST_TYPE_OTHER from '@salesforce/schema/UAC_diagnosis__c.UAC_otherSpecialistType__c';
import FLD_DIAGNOSIS_SPECIALIST_VISIT_DUE_DATE from '@salesforce/schema/UAC_diagnosis__c.UAC_specialistVisitEstimatedDueDate__c';
import FLD_DIAGNOSIS_SPECIALITY_SERVICES from '@salesforce/schema/UAC_diagnosis__c.UAC_specialityServices__c';
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
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import LBL_YES from '@salesforce/label/c.UAC_Yes';
import LBL_WORKING from '@salesforce/label/c.UAC_diagnosisStatusWorking';
import LBL_FINAL from '@salesforce/label/c.UAC_statusFinal';
import LBL_CONDITION_PREGNANT from '@salesforce/label/c.UAC_diagnosisConditionPregnant';
import LBL_RULED_OUT_NEW_DIAGNOSIS from '@salesforce/label/c.UAC_diagnosisStatusRuledOutNewDiagnosis';
import LBL_CONDITIONS_FOR_PRID from '@salesforce/label/c.UAC_diagnosisConditionsForPRIDSection';
import LBL_CONDITIONS_FOR_CONDITION_TYPE from '@salesforce/label/c.UAC_diagnosisConditionsForConditionType';
import LBL_CONDITIONS_FOR_SEXUAL_ACTIVITY from '@salesforce/label/c.UAC_diagnosisConditionsForSexualActivitySection';
import LBL_CONDITIONS_FOR_SPECIFY_OTHER from '@salesforce/label/c.UAC_diagnosisConditionsForSpecifyOther';
import LBL_MENTAL_CONDITIONS_FOR_SPECIFY_OTHER from '@salesforce/label/c.UAC_mentalDiagnosisConditionsForSpecifyOther';
import LBL_CONDITIONS_FOR_EXPOSURE_DETAILS from '@salesforce/label/c.UAC_diagnosisConditionsForExposureDetails';
import LBL_CONDITION_TYPES_FOR_EXPOSURE_DETAILS from '@salesforce/label/c.UAC_diagnosisConditionTypesForExposureDetails';
import LBL_SECTION_PRID from '@salesforce/label/c.UAC_diagnosisSectionPRID';
import LBL_OTHER from '@salesforce/label/c.UAC_other';
import LBL_PRID from '@salesforce/label/c.UAC_PRID';
import LBL_TITLE_NEW from '@salesforce/label/c.UAC_titleNewDiagnosis';
import LBL_TITLE_EDIT from '@salesforce/label/c.UAC_titleEditDiagnosis';
import LBL_RECORD_TYPE_HEALTH_EVAL_HA from '@salesforce/label/c.UAC_healthEvaluationRecordTypeHA';
import LBL_RECORD_TYPE_HEALTH_EVAL_MHSR from '@salesforce/label/c.UAC_recordTypeMentalHealthServiceReport';
import LBL_RECORD_TYPE_HEALTH_EVAL_IME from '@salesforce/label/c.UAC_healthEvaluationRecordTypeIME';
import LBL_RECORD_TYPE_DIAGNOSIS_HA from '@salesforce/label/c.UAC_diagnosisRecordTypeHA';
import LBL_RECORD_TYPE_DIAGNOSIS_MHD from '@salesforce/label/c.UAC_recordTypeMentalHealthDiagnosis';
import LBL_RECORD_TYPE_DIAGNOSIS_IME from '@salesforce/label/c.UAC_diagnosisRecordTypeIME';
import saveDiagnosis from '@salesforce/apex/UAC_diagnosisFormController.saveDiagnosis';

const TITLE_NEW = LBL_TITLE_NEW;
const TITLE_EDIT = LBL_TITLE_EDIT;
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
const SECONDARY_DIAGNOSIS_OPTIONS = [
  { label: LBL_WORKING, value: LBL_WORKING },
  { label: LBL_FINAL, value: LBL_FINAL }
];

export default class UacDiagnosisForm extends LightningElement {

  @api
  show(recordId, associatedHealthEvaluationId, parentDiagnosisId) {
    this.isLoading = true;
    this.recordId = recordId;
    this.associatedHealthEvaluationId = associatedHealthEvaluationId;
    this.parentDiagnosisId = parentDiagnosisId;
    if (this.wiredHealthEvalRecord && !recordId) {
      refreshApex(this.wiredHealthEvalRecord);
    }
    if (recordId && this.wiredDiagnosisRecord) {
      refreshApex(this.wiredDiagnosisRecord);
    }
    this.showModal();
  }

  @track layout = { sections: [] }
  @track associatedHealthEvaluationId;
  @track associatedUACId;
  @track parentDiagnosisId;
  @track recordId;
  @track isLoading = false;
  @track initialized = false;
  @track statusOptions = [];
  @track diagnosisStatus;
  @track error;
  @track diagnosisObjectInfo;
  @track diagnosisRecordTypeId;
  @track diagnosisRecordType;
  wiredHealthEvalRecord;
  wiredDiagnosisRecord;

  objectApiName = OBJ_DIAGNOSIS.objectApiName;
  fldDiagnosisAssociatedHealthEval = FLD_DIAGNOSIS_ASSOCIATED_HEALTH_EVAL.fieldApiName;
  fldDiagnosisAssociatedUAC = FLD_DIAGNOSIS_ASSOCIATED_UAC.fieldApiName;
  fldDiagnosisParentDiagnosis = FLD_DIAGNOSIS_PARENT_DIAGNOSIS.fieldApiName;
  preventRecordChangeOnLoad = false;

  get title() {
    return (this.recordId) ? TITLE_EDIT : TITLE_NEW;
  }

  get diagnosisStatusLabel() {
    return (this.diagnosisObjectInfo) ?
      this.diagnosisObjectInfo.fields[
        FLD_DIAGNOSIS_STATUS.fieldApiName
      ].label :
      '';
  }

  get diagnosisStatusOptions() {
    return (this.parentDiagnosisId) ? SECONDARY_DIAGNOSIS_OPTIONS : this.statusOptions;
  }

  @wire(getRecord, {
    recordId: "$associatedHealthEvaluationId",
    fields: [
      FLD_HEALTH_EVAL_ASSOCIATED_UAC,
      FLD_HEALTH_EVAL_RECORD_TYPE_NAME
    ]
  })
  wiredHealthEvalGetRecord(response) {
    this.wiredHealthEvalRecord = response;
    const { data, error } = response;
    if (data) {
      this.associatedUACId = data.fields[FLD_HEALTH_EVAL_ASSOCIATED_UAC
        .fieldApiName].value;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getObjectInfo, { objectApiName: OBJ_DIAGNOSIS })
  wiredDiagnosisInfo({ data, error }) {
    if (data) {
      this.diagnosisObjectInfo = data;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: '$diagnosisRecordTypeId',
    fieldApiName: FLD_DIAGNOSIS_STATUS
  })
  wiredStatusValues({ data, error }) {
    if (data) {
      this.statusOptions = data.values;
      this.initialize();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      FLD_DIAGNOSIS_STATUS
    ]
  })
  wiredDiagnosisGetRecord(response) {
    this.wiredDiagnosisRecord = response;
    let { data, error } = response;
    if (data) {
      this.diagnosisRecordTypeId = data.recordTypeId;
      this.diagnosisRecordType = data.recordTypeInfo.name;
      this.diagnosisStatus = data.fields[FLD_DIAGNOSIS_STATUS.fieldApiName].value;
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  initialize() {
    if (!this.diagnosisRecordTypeId) {
      if (this.wiredHealthEvalRecord && this.wiredHealthEvalRecord.data && this
        .diagnosisObjectInfo) {
        let diagnosisRecordTypeMap = new Map();
        Object.keys(this.diagnosisObjectInfo.recordTypeInfos)
          .forEach(recordTypeId => {
            diagnosisRecordTypeMap.set(this.diagnosisObjectInfo.recordTypeInfos[
                recordTypeId]
              .name,
              recordTypeId);
          });
        switch (this.wiredHealthEvalRecord.data.fields.RecordType.value.fields.Name.value) {
        case LBL_RECORD_TYPE_HEALTH_EVAL_HA:
          this.diagnosisRecordType = LBL_RECORD_TYPE_DIAGNOSIS_HA;
          this.diagnosisRecordTypeId = diagnosisRecordTypeMap.get(this.diagnosisRecordType);
          break;
        case LBL_RECORD_TYPE_HEALTH_EVAL_IME:
          this.diagnosisRecordType = LBL_RECORD_TYPE_DIAGNOSIS_IME;
          this.diagnosisRecordTypeId = diagnosisRecordTypeMap.get(this.diagnosisRecordType);
          break;
        case LBL_RECORD_TYPE_HEALTH_EVAL_MHSR:
          this.diagnosisRecordType = LBL_RECORD_TYPE_DIAGNOSIS_MHD;
          this.diagnosisRecordTypeId = diagnosisRecordTypeMap.get(this.diagnosisRecordType);
          break;
        default:
          this.diagnosisRecordTypeId = this.diagnosisObjectInfo.defaultRecordTypeId;
          break;
        }
      } else {
        return;
      }
    }
    if (!this.statusOptions || this.statusOptions.length <= 0) {
      return;
    }
    this.initialized = true;
    this.isLoading = false;
  }

  get diagnosisForm() {
    return this.template.querySelector('c-uac-record-edit-form');
  }

  get isReplacement() {
    return this.recordId && this.diagnosisStatus === LBL_RULED_OUT_NEW_DIAGNOSIS;
  }

  get showStatusField() {
    return this.initialized && this.statusOptions.length > 0 && this.loadComplete;
  }

  get isMentalHealth() {
    return this.diagnosisRecordType === LBL_RECORD_TYPE_DIAGNOSIS_MHD;
  }

  loadComplete = false;

  handleLoadComplete() {
    this.loadComplete = true;
    this.checkConditionalRules();
  }

  handleFieldChange() {
    this.checkConditionalRules();
  }

  handleStatusChange(event) {
    this.diagnosisStatus = event.detail.value;
    this.checkConditionalRules();
  }

  checkConditionalRules() {
    const diagnosisRecord = this.diagnosisForm.getRecord();
    const statusFieldValue = (this.isReplacement) ? LBL_FINAL : this.diagnosisStatus;
    this.diagnosisForm.form.sections.forEach((section) => {
      if (section.heading === SECTON_PRID) {
        section.hide = !(
          statusFieldValue === LBL_FINAL &&
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
              case FLD_DIAGNOSIS_STATUS.fieldApiName:
                layoutComponent.hide = true;
                layoutComponent.value = statusFieldValue;
                break;
              case FLD_DIAGNOSIS_CONDITION_OTHER.fieldApiName:
                layoutComponent.hide = !(
                  (this.isMentalHealth &&
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
                  statusFieldValue === LBL_FINAL &&
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
                  statusFieldValue === LBL_FINAL && (
                    CONDITIONS_FOR_EXPOSURE_DETAILS.has(
                      diagnosisRecord[FLD_DIAGNOSIS_CONDITION.fieldApiName]
                    ) ||
                    CONDITION_TYPES_FOR_EXPOSURE_DETAILS.has(
                      diagnosisRecord[FLD_DIAGNOSIS_CONDITION_TYPE.fieldApiName]
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
                layoutComponent.required = !layoutComponent.hide && this
                  .diagnosisRecordType !== LBL_RECORD_TYPE_DIAGNOSIS_IME;
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
                  ]) && this.diagnosisRecordType === LBL_RECORD_TYPE_DIAGNOSIS_HA);
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
              if ((layoutComponent.hide || section.hide) &&
                layoutComponent.apiName !== FLD_DIAGNOSIS_STATUS.fieldApiName
              ) {
                layoutComponent.value = (typeof (layoutComponent.value) ===
                  "boolean") ? false : null;
              }
              diagnosisRecord[layoutComponent.apiName] = layoutComponent.value;
            }
          })
        })
      });
    });
  }

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
    this.validateInput();
    this.diagnosisForm.save();
  }

  handleSubmit(event) {
    const fields = event.detail.fields;
    const status = this.diagnosisStatus;
    event.preventDefault();
    let diagnosis;
    let replacementDiagnosis;
    if (this.isReplacement) {
      diagnosis = { Id: this.recordId, RecordTypeId: this.diagnosisRecordTypeId };
      replacementDiagnosis = fields;
      replacementDiagnosis.RecordTypeId = this.diagnosisRecordTypeId;
      replacementDiagnosis[FLD_DIAGNOSIS_STATUS.fieldApiName] = LBL_FINAL;
      replacementDiagnosis[FLD_DIAGNOSIS_PARENT_DIAGNOSIS.fieldApiName] = this.recordId;
      delete replacementDiagnosis.Id;
    } else {
      diagnosis = fields;
      diagnosis.Id = this.recordId;
      diagnosis.RecordTypeId = this.diagnosisRecordTypeId;
    }
    diagnosis[FLD_DIAGNOSIS_STATUS.fieldApiName] = status;
    let params = {
      diagnosis: JSON.stringify(diagnosis)
    };
    if (replacementDiagnosis) {
      params.replacementDiagnosis = JSON.stringify(replacementDiagnosis);
    }
    saveDiagnosis(params)
      .then(response => {
        if (response.isSuccess) {
          if (this.recordId) {
            getRecordNotifyChange([{ recordId: this.recordId }]);
          }
          this.handleSuccess();
        } else {
          this.error = response.error;
          this.template.querySelector('c-uac-modal')
            .scrollToTop();
        }
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  handleSuccess() {
    this.dispatchEvent(new CustomEvent('success', {}));
    this.handleClose();
  }

  handleError() {
    this.isLoading = false;
    this.template.querySelector('c-uac-modal')
      .scrollToTop();
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
    this.initialized = false;
    this.hideModal();
    this.recordId = undefined;
    this.associatedHealthEvaluationId = undefined;
    this.parentDiagnosisId = undefined;
    this.diagnosisRecordTypeId = undefined;
    this.diagnosisStatus = undefined;
    this.statusOptions = [];
    this.error = undefined;
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