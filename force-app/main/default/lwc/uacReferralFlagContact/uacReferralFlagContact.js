import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, track, wire} from 'lwc';

const fields = [
  'contact.UAC_criminalFlag__c',
  'Contact.UAC_deniedFlag__c',
  'Contact.UAC_fraudFlag__c',
  'Contact.UAC_previousSponsorshipFlag__c'
];

export default class UacReferralFlagContact extends LightningElement {

  @api
  recordId;

  @track
  boolDataPresent;

  contact;
  Name;
  class;
  style;

  @track
  lstFlags = [];
  @wire(getRecord, {recordId: '$recordId', fields})
  contactRecord({error, data}) {
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
      this.contact = data;
      this.lstFlags = [];

      // this.lstFlags = this.prepareFlagsList(this.contact.fields);
      this.prepareFlagsList(this.contact.fields);

      this.boolDataPresent = true;
      if (this.lstFlags.length == 0) this.boolDataPresent = false;
    }
  }

  /**
   * @description Method to prepare list of flags to display
   * @author Chaitanya Nandamuri (Deloitte)
   * @param {fields} Fields from the wire method
   */

  prepareFlagsList(fieldValues) {

    if (fieldValues.UAC_criminalFlag__c.value == 'Yes'
        || fieldValues.UAC_criminalFlag__c.value == true) {
      this.lstFlags.push(
          {'Name': 'Criminal', 'class': 'slds-badge slds-theme_error badgestyle', 'style': ''});
    }
    
    if (fieldValues.UAC_deniedFlag__c.value == 'Yes'
        || fieldValues.UAC_deniedFlag__c.value == true) {
      this.lstFlags.push(
          {'Name': 'Denied', 'class': 'badgestyle', 'style': 'background:#000000; color:white;'});
    }    

    if (fieldValues.UAC_fraudFlag__c.value == 'Yes' || fieldValues.UAC_fraudFlag__c.value == true) {
      this.lstFlags.push(
          {'Name': 'Fraud', 'class': 'slds-badge slds-theme_error badgestyle', 'style': ''});
    }

    if (fieldValues.UAC_previousSponsorshipFlag__c.value == 'Yes'
        || fieldValues.UAC_previousSponsorshipFlag__c.value == true) {
      this.lstFlags.push(
          {'Name': 'Previous Sponsorships', 'class': 'badgestyle', 'style': 'background:#4FD2D2;'});
    }
    //  return this.lstFlags;
  }
}