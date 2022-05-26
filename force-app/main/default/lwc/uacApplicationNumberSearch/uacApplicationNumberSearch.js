import { LightningElement } from 'lwc';
import OBJ_CONTACT from '@salesforce/schema/Contact';
import FLD_UAC_A from "@salesforce/schema/Contact.UAC_A__c";
import FLD_NAME from "@salesforce/schema/Contact.Name";
import FLD_DOB from "@salesforce/schema/Contact.Birthdate";
import FLD_PPROGRAM from "@salesforce/schema/Contact.UAC_program__c";
import getRecords from '@salesforce/apex/UAC_listViewController.getRecords';
import { reduceErrors } from 'c/uacUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const LST_FIELD = [
  { name: FLD_UAC_A.fieldApiName },
  { name: FLD_NAME.fieldApiName },
  { name: FLD_DOB.fieldApiName },
  { name: FLD_PPROGRAM.fieldApiName }

];
const PROGRAM_FIELD_NAME = 'UAC_program__r.name';
const columns = [
  { label: 'A#', fieldName: FLD_UAC_A.fieldApiName, type: 'text' },
  { label: 'Name', fieldName: FLD_NAME.fieldApiName, type: 'text' },
  {
    label: 'DOB',
    fieldName: FLD_DOB.fieldApiName,
    type: 'date-local',
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    }
  },
  { label: 'Program', fieldName: 'programName', type: 'text' },
];


export default class UacApplicationNumberSearch extends LightningElement {
  columns = columns;
  uacObjectApiName = OBJ_CONTACT.objectApiName;
  applicationNumber = '';
  fields = LST_FIELD;
  isshowResult = false;
  uacAnumberList = [];
  fieldsToQuery = [];
  childRelationships = [];

  /**
   * This method trigger from onclick on search
   */
  handleSearch() {
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
      .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    if (isInputsCorrect === true) {
      this.isshowResult = true;
      this.getRecordList();
    }
  }

  /**
   * Load seacrch result after enter valid A#
   */
  getRecordList() {
    let fieldsToQuery = [];
    this.fields.forEach((fld) => {
      fieldsToQuery.push(fld.name);
    });
    fieldsToQuery.push(PROGRAM_FIELD_NAME);
    getRecords({
        query: JSON.stringify({
          objectApiName: this.uacObjectApiName,
          fieldsToQuery: fieldsToQuery,
          filter: this.uacAppnumberFilter
        }),
        childRelationshipQuery: JSON.stringify(this.childRelationships)
      })
      .then(response => {
        let recs = [];
        for (let i = 0; i < response.length; i++) {
          let uacMember = {};
          if (response[i].UAC_program__r) {
            uacMember.programName = response[i].UAC_program__r.Name;
          }
          uacMember = Object.assign(uacMember, response[i]);
          recs.push(uacMember);
        }
        this.uacAnumberList = recs;

        if (this.uacAnumberList.length === 0) {
          this.showToastMessage('Error',
            'The A# either does not exist in UC PATH or you do not have access to the UC record',
            'error');
        }
      })
      .catch(error => {

        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      })
  }


  /**
   *  Return filter condition for current Query
   */
  get uacAppnumberFilter() {
    let queryFilter =
      `${FLD_UAC_A.fieldApiName}='${this.template.querySelector('lightning-input').value}'`;
    return queryFilter;
  }

  /**
   * Capture event on click of search result and trigger parent component event
   * @param {*} event
   */
  handleRowSelection(event) {
    const row = event.detail.selectedRows;
    const evt = new CustomEvent('rowselection', { detail: row });
    this.dispatchEvent(evt);
  }
  /**
   *  Display Show toast message
   * @param {*} title  Title of the error message
   * @param {*} message Description for error
   * @param {*} variant
   */
  showToastMessage(title, message, variant) {
    this._isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

}