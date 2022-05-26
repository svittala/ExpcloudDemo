import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import numReferrals from '@salesforce/schema/Case.Contact.UAC_ApprehendedRelationshipCount__c';
import {api, LightningElement, track, wire} from 'lwc';

const fields = [
  'Case.UAC_specialConsiderationCase__c',
  'Case.UAC_pregnantIHI__c',
  'Case.UAC_medicalHealthConcernsIHI__c',
  'Case.UAC_criminalConcerns__c',
  'Case.UAC_returningUAC__c',
  'Case.UAC_agingOut__c',
  'Case.UAC_ageAtReferral__c',
  'Case.UAC_relatedUAC__c',
  'Case.UAC_past72HourWindow__c',
  numReferrals
];

export default class UacReferralFlagCase extends LightningElement {

  @api
  recordId;

  @track
  boolDataPresent;

  case;
  Name;
  class;
  style;

  @track
  lstFlags = [];

  @wire(getRecord, {recordId: '$recordId', fields})
  caseRecord({error, data}) {
    if (error) {
      let message = 'Unknown error';
      if (Array.isArray(error.body)) {
        message = error.body.map(e => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        message = error.body.message;
      }
      this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error loading record details',
            message,
            variant: 'error',
          }),
      );
    } else if (data) {
      this.case = data;
      this.lstFlags = [];

      this.lstFlags = this.prepareFlagsList(this.case.fields);

      this.boolDataPresent = true;
      if (this.lstFlags.length == 0) this.boolDataPresent = false;
    }
  }

  /**
   * @description Method to prepare list of flags to display
   * @author Abhisek Pati (Deloitte)
   * @param {fields} Fields from the wire method
   */

  prepareFlagsList(fieldValues) {

    if (fieldValues.UAC_specialConsiderationCase__c.value == 'Yes'
        || fieldValues.UAC_specialConsiderationCase__c.value == true)
      this.lstFlags.push({
        Name: 'Special Consideration',
        class: 'slds-badge slds-theme_success badgestyle',
        style: ''
      });

    if (fieldValues.UAC_pregnantIHI__c.value == 'Yes'
        || fieldValues.UAC_pregnantIHI__c.value == true)
      this.lstFlags.push({Name: 'Pregnant', class: 'badgestyle', style: 'background:#FFA3CF;'});

    if (fieldValues.UAC_medicalHealthConcernsIHI__c.value == 'Yes'
        || fieldValues.UAC_medicalHealthConcernsIHI__c.value == true)
      this.lstFlags.push({
        Name: 'Medical Information',
        class: 'slds-badge slds-theme_warning badgestyle',
        style: ''
      });

    if (fieldValues.UAC_returningUAC__c.value == 'Yes'
        || fieldValues.UAC_returningUAC__c.value == true)
      this.lstFlags.push(
          {Name: 'Returning UC', class: 'badgestyle', style: 'background:#4FD2D2;'});

    if (fieldValues.UAC_criminalConcerns__c.value == 'Yes'
        || fieldValues.UAC_criminalConcerns__c.value == true)
      this.lstFlags.push(
          {Name: 'Criminal Concern', class: 'slds-badge slds-theme_error badgestyle', style: ''});

    if (fieldValues.UAC_agingOut__c.value == 'Yes' || fieldValues.UAC_agingOut__c.value == true)
      this.lstFlags.push({Name: 'Aging Out', class: 'slds-badge_inverse badgestyle', style: ''});

    if (fieldValues.UAC_ageAtReferral__c.value >= 18)
      this.lstFlags.push({Name: 'Aged Out', class: 'slds-badge_inverse badgestyle', style: ''});

    if (fieldValues.UAC_ageAtReferral__c.value <= 12)
      this.lstFlags.push({Name: 'Tender Age', class: 'slds-badge badgestyle', style: ''});

    if (fieldValues.UAC_relatedUAC__c.value == true)
      this.lstFlags.push(
          {Name: 'Related UC', class: 'slds-badge badgestyle', style: 'background:#F77E76;'});
    
    if (fieldValues.UAC_past72HourWindow__c.value == true)
      this.lstFlags.push(
          {Name: 'Past 72 Hours', class: 'slds-badge badgestyle', style: 'background:#de350b;'});
    
    if (getFieldValue(this.case, numReferrals) > 0)
        this.lstFlags.push(
            {Name: 'Parent + Child', class: 'slds-badge badgestyle', style: 'background:#F77E76;'});

    return this.lstFlags;
  }
}