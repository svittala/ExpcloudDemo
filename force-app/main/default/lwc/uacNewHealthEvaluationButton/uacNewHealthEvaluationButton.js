import LBL_RECORD_TYPES from '@salesforce/label/c.UAC_newHealthEvaluationButton';
import FLD_ADMISSION_AGE from '@salesforce/schema/Contact.UAC_admissionAgeforMostRecentORRStay__c';
import FLD_ADMISSION_DATE from '@salesforce/schema/Contact.UAC_admissionDateforMostRecentORRStay__c';
import FLD_CURRENT_AGE from '@salesforce/schema/Contact.UAC_currentAge__c';
import FLD_DISCHARGE_DATE from '@salesforce/schema/Contact.UAC_dischargeDateforMostRecentORRStay__c';
import FLD_PROFILE_PROGRAMID from '@salesforce/schema/Contact.UAC_program__c';
import FLD_PROFILE_PROGRAM from '@salesforce/schema/Contact.UAC_program__r.Name';
import OBJ_HE from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_RECORDTYPE from '@salesforce/schema/UAC_healthEvaluation__c.RecordTypeId';
import FLD_HE_ADMISSION_DATE from '@salesforce/schema/UAC_healthEvaluation__c.UAC_admissionDateforMostRecentORRStay__c';
import FLD_AGE_AT_ADMISSION from '@salesforce/schema/UAC_healthEvaluation__c.UAC_ageAtAdmission__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import FLD_DATE_REPORT from '@salesforce/schema/UAC_healthEvaluation__c.UAC_dateReportEntered__c';
import FLD_HE_DISCHARGE_DATE from '@salesforce/schema/UAC_healthEvaluation__c.UAC_dischargeDateforMostRecentORRStay__c';
import FLD_ASSOCIATED_PROGRAM from '@salesforce/schema/UAC_healthEvaluation__c.UAC_lookupAssociatedProgram__c';
import FLD_PHI_AGE from '@salesforce/schema/UAC_healthEvaluation__c.UAC_PHIAge__c';
import FLD_PROGRAM_NAME from '@salesforce/schema/UAC_healthEvaluation__c.UAC_programNameattheTimeofExam__c';
import {getTodaysDate, reduceErrors} from 'c/uacUtils'
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {createRecord, getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, track, wire} from 'lwc';

export default class UacNewHealthEvaluationButton extends NavigationMixin
(LightningElement) {

  @api
  recordId;
  tableTitle = 'New Health Evaluation';
  selectedRecordType;
  @track
  imeObjectInfo;
  @track
  programName;
  @track
  programId;
  @track
  currentAge;
  @track
  admissionDate;
  @track
  admissionAge;
  @track
  dischargeDate;
  newHealthRecordId;
  contact;
  @track
  question = 'Select a Record Type';
  @track
  recordTypeOptions = [];
  @track
  openModal;

  openPopUp() {
    this.openModal = true;
  }
  closePopUp() {
    this.openModal = false;
  }

  /**
   * @description Method to get program name field
   * @param RecordId and field to retrieve from schema
   * @return {data, error}
   */
  @wire(getRecord, {
    recordId: '$recordId',
    fields: [
      FLD_PROFILE_PROGRAM,
      FLD_PROFILE_PROGRAMID,
      FLD_CURRENT_AGE,
      FLD_ADMISSION_DATE,
      FLD_ADMISSION_AGE,
      FLD_DISCHARGE_DATE
    ]
  })
  wiredContact({data, error}) {
    if (data) {
      this.contact = data;
      if(this.contact.fields.UAC_program__c.value){
        this.programName = this.contact.fields.UAC_program__r.value.fields.Name.value;
        this.programId = this.contact.fields.UAC_program__c.value;
      }
      this.currentAge = this.contact.fields.UAC_currentAge__c.value;
      this.admissionDate = this.contact.fields.UAC_admissionDateforMostRecentORRStay__c.value;
      this.admissionAge = this.contact.fields.UAC_admissionAgeforMostRecentORRStay__c.value;
      this.dischargeDate = this.contact.fields.UAC_dischargeDateforMostRecentORRStay__c.value;
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
    }
  }

  /**
   * @description Method to get object info and record types
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, {objectApiName: OBJ_HE})
  wiredIMEObjectInfo({data, error}) {
    if (data) {
      this.imeObjectInfo = data;
      let recordTypeValues = [];
      var recordTypeNames = LBL_RECORD_TYPES.split(',');
      recordTypeNames.forEach((recordTypeName) => {
        Object.keys(data.recordTypeInfos).forEach((key) => {
          if (recordTypeName.includes(data.recordTypeInfos[key].name)) {
            recordTypeValues.push({
              label: data.recordTypeInfos[key].name,
              value: data.recordTypeInfos[key].recordTypeId
            })
          }
        })
      });
      this.recordTypeOptions = recordTypeValues;
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
    }
  }

  // Handling on change value
  handleChange(event) {
    this.selectedRecordType = event.detail.value;
  }

  showToastMessage(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({title: title, message: message, variant: variant}));
  }

  /**
   * @description Method to get create new Health Evaluation Record
   * @param none
   * @return {recordId, error}
   */
  createHealthEvaluation() {

    if (this.selectedRecordType === undefined) {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error Creating Record',
        message: 'Please select Record Type',
        variant: 'error'
      }));
      return;
    } else {
      const fields = {};
      fields[FLD_RECORDTYPE.fieldApiName] = this.selectedRecordType;
      fields[FLD_ASSOCIATED_UAC.fieldApiName] = this.recordId;
      fields[FLD_DATE_REPORT.fieldApiName] = getTodaysDate();
      fields[FLD_PROGRAM_NAME.fieldApiName] = this.programName;
      fields[FLD_ASSOCIATED_PROGRAM.fieldApiName] = this.programId;
      fields[FLD_AGE_AT_ADMISSION.fieldApiName] = this.admissionAge;
      fields[FLD_HE_ADMISSION_DATE.fieldApiName] = this.admissionDate;
      fields[FLD_HE_DISCHARGE_DATE.fieldApiName] = this.dischargeDate;
      fields[FLD_PHI_AGE.fieldApiName] = this.currentAge;
      const recordInput = {apiName: OBJ_HE.objectApiName, fields};
      createRecord(recordInput)
          .then(healthEvaluation => {
            this.newHealthRecordId = healthEvaluation.id;
            this.dispatchEvent(new ShowToastEvent(
                {title: 'Success', message: 'Health Evaluation Created', variant: 'success'}));
            this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
                objectApiName: 'UAC_healthEvaluation__c',
                actionName: 'view',
                recordId: this.newHealthRecordId
              },
            });
          })
          .catch(error => {
            this.dispatchEvent(new ShowToastEvent(
                {title: 'Error creating record', message: error.body.output.errors[0].message, variant: 'error'}));
          });
    }
  }
}