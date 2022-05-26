import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/uacUtils';
import getRecords from '@salesforce/apex/UAC_listViewController.getRecords';

const LBL_NO_DATA = 'No data found.';
const LBL_LOADING_DATA = 'Loading...';

export default class UacListView extends NavigationMixin(LightningElement) {
  @api objectApiName;
  @api columns = [];
  @api disableActions = false;
  @api additionalFields = [];
  @api childRelationships = [];
  @api
  get additionalButtons() {
    return this._additionalButtons;
  }
  set additionalButtons(value) {
    this._additionalButtons = (value) ? JSON.parse(JSON.stringify(value)) : [];
    this._additionalButtons.forEach((btn) => {
      btn.className = 'slds-button';
      btn.className += (btn.variant) ? ' slds-button_' + btn.variant :
        ' slds-button_neutral';
    });
  }
  @api filter = [];
  @api overrideDeleteAction = false;
  @api disableEdit = false;
  @api disableDelete = false;

  @api
  refresh() {
    this.getRecordList();
  }

  @api
  isEmpty() {
    return this.data.length <= 0;
  }

  @api
  get isLoading() {
    return this._isLoading;
  }
  set isLoading(value) {
    this._isLoading = value;
  }

  @api
  getRecords() {
    return this.data.map((row) => { return row.record; });
  }

  @api
  disableActionsForRecordIds(actionsToDisable, recordIds) {
    let recordIdSet = new Set(recordIds);
    let index = 0;
    this.data.forEach((row) => {
      if (recordIdSet.has(row.record.Id)) {
        actionsToDisable.forEach((action) => {
          const btn = this.template.querySelector(
            `button[data-action='${action}'][data-index='${index}']`);
          if (btn) {
            btn.disabled = true;
          }
        });
      }
      index++;
    });
  }

  @api
  delete(recordId) {
    let rows = this.data.filter((row) => { return row.record.Id === recordId; });
    if (rows.length > 0) {
      this.deleteRecordById(recordId)
    }
  }

  _additionalButtons = [];
  @track _isLoading = true;
  @track data = [];
  @track _columns = [];

  lblNoData = LBL_NO_DATA;
  lblLoading = LBL_LOADING_DATA;

  @wire(getObjectInfo, { objectApiName: '$objectApiName' })
  wiredObjectInfo({ data, error }) {
    if (data) {
      this._columns = JSON.parse(JSON.stringify(this.columns));
      this._columns.forEach((fld) => {
        if (data.fields[fld.name] && !fld.label) {
          fld.label = data.fields[fld.name].label;
        }
        fld.isDate = data.fields[fld.name].dataType === 'Date';
        fld.isReference = data.fields[fld.name].dataType === 'Reference';
        fld.isText = !fld.isDate && !fld.isReference;
        if (fld.isReference) {
          fld.isReference = true;
          fld.relationshipName = data.fields[fld.name].relationshipName;
          if (data.fields[fld.name].referenceToInfos[0].nameFields.includes("Name")) {
            fld.nameFields = ["Name"];
          } else {
            fld.nameFields = data.fields[fld.name].referenceToInfos[0].nameFields;
          }
        }
      });
      this.getRecordList();
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get columnLength() {
    return this._columns.length + ((this.disableActions) ? 0 : 1);
  }

  get actionColumnStyle() {
    let additionButtonWidth = this.additionalButtons.reduce((width, button) => {
      return button.label.length * 10 + width;
    }, 0);
    return `width: ${additionButtonWidth + 125}px;`;
  }

  recordLoaded = false;

  getRecordList() {
    this.recordLoaded = false;
    this._isLoading = true;
    let fieldsToQuery = [];
    this._columns.forEach((fld) => {
      fieldsToQuery.push(fld.name);
      if (fld.isReference) {
        for (let nameField of fld.nameFields) {
          fieldsToQuery.push(fld.relationshipName + '.' + nameField);
        }
      }
    });
    this.additionalFields.forEach((fldName) => {
      fieldsToQuery.push(fldName)
    });
    getRecords({
        query: JSON.stringify({
          objectApiName: this.objectApiName,
          fieldsToQuery: fieldsToQuery,
          filter: this.filter
        }),
        childRelationshipQuery: JSON.stringify(this.childRelationships)
      })
      .then(response => {
        this._isLoading = false;
        let data = [];
        for (let record of response) {
          let row = { record: record, fields: JSON.parse(JSON.stringify(this._columns)) };
          row.fields.forEach((fld) => {
            Object.defineProperty(fld, 'isClickable', {
              get: function () {
                return this.clickable && this.value;
              }
            });
            if (record[fld.name]) {
              fld.value = record[fld.name];
              if (fld.clickable) {
                fld.idValue = record.Id;
              }
              if (fld.isReference) {
                let nameValues = [];
                for (let nameField of fld.nameFields) {
                  nameValues.push(record[fld.relationshipName][nameField]);
                }
                fld.nameFieldValue = nameValues.join(' ');
              }
            }
          });
          data.push(row);
        }
        this.data = data;
        this.recordLoaded = true;
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      })
  }

  onRowAction(event) {
    const index = event.target.dataset.index;
    const action = event.target.dataset.action;
    this.dispatchEvent(new CustomEvent('rowaction', {
      detail: {
        action: action,
        record: this.data[index].record
      }
    }));
  }

  onDeleteClick(event) {
    const index = event.target.dataset.index;
    if (this.overrideDeleteAction) {
      this.onRowAction(event);
    } else {
      this.deleteRecordById(this.data[index].record.Id);
    }
  }

  onReferenceFieldClick(event) {
    const referenceRecordId = event.target.dataset.id;
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
          recordId: referenceRecordId,
          actionName: 'view'
        }
      })
      .then(url => {
        window.open(url, "_blank");
      });
  }

  deleteRecordById(recordId) {
    this._isLoading = true;
    deleteRecord(recordId)
      .then(() => {
        this.getRecordList();
        this.showToastMessage('Success', 'Record successfully deleted.', 'success');
      })
      .catch(error => {
        if (error.body && error.body.output) {
          this.showToastMessage('Error', reduceErrors(error.body.output.errors)
            .join('\n'), 'error');
        } else {
          this.showToastMessage('Error', reduceErrors(error)
            .join('\n'), 'error');
        }
      });
  }

  showToastMessage(title, message, variant) {
    this._isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  renderedCallback() {
    if (this.recordLoaded) {
      this.dispatchEvent(new CustomEvent('loadcomplete'));
      this.recordLoaded = false;
    }
  }
}