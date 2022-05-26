import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSectionList from '@salesforce/apex/UAC_progressBarController.getSectionList';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/uacUtils';

export default class UacProgressBar extends LightningElement {
  @api recordId;
  @api relatedTo;
  @api currentSection;
  @api clickable = false;

  @api
  refresh() {
    refreshApex(this.wiredRecord);
  }

  @track lstSection = [];
  @track statusFields = [];
  _currentSection;
  wiredRecord;

  @wire(getRecord, { recordId: '$recordId', fields: '$statusFields' })
  wiredGetRecord(value) {
    this.wiredRecord = value;
    const { data, error } = value;
    if (data) {
      let dataFields = data.fields;
      this.lstSection.forEach((section) => {
        let statusField = section.strStatusField.split('.')[1];
        if (dataFields[statusField]) {
          section.strStatus = dataFields[statusField].value;
        }
      });
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get hasSection() {
    return this.lstSection.length > 0;
  }

  getProgressStatus() {
    let cmp = this;
    getSectionList({ idRecord: this.recordId, strRelatedTo: this.relatedTo })
      .then((response) => {
        this.lstSection = response;
        let statusFields = [];
        let selectedSection = (this.lstSection.length > 0) ? this.lstSection[0] : null;
        for (let section of this.lstSection) {
          if (section.strStatusField) {
            statusFields.push(section.strStatusField);
          }
          Object.defineProperty(section, "selected", {
            get: function () {
              return (cmp.currentSection === this.strName);
            }
          });
          if (section.selected) {
            selectedSection = section;
          }
        }
        this.statusFields = statusFields;
        if (selectedSection) {
          this.dispatchEvent(new CustomEvent('sectionclick', {
            detail: {
              sectionName: selectedSection.strName,
              flowName: selectedSection.strFlowName
            }
          }));
        }
      })
      .catch((error) => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      })
  }

  handlePathClick(event) {
    event.preventDefault();
    const sectionName = event.target.dataset.sectionName;
    const flowName = event.target.dataset.flowName;
    this.dispatchEvent(new CustomEvent('sectionclick', {
      detail: {
        sectionName: sectionName,
        flowName: flowName
      }
    }));
  }

  showToastMessage(title, message, variant) {
    this.isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  connectedCallback() {
    this.getProgressStatus();
  }
}