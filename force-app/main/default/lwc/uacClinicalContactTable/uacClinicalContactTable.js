import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createClinicalContacts from '@salesforce/apex/UAC_clinicalContactTableController.createClinicalContacts';
import FLD_EVENT_NAME from '@salesforce/schema/UAC_Event__c.Name';
import OBJ_HEALTH_EVAL from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__c';
import FLD_HEALTH_EVAL_ASSOCIATED_UAC_NAME from '@salesforce/schema/UAC_healthEvaluation__c.UAC_associatedUAC__r.Name';
import FLD_HEALTH_EVAL_TYPE_OF_CONTACT from '@salesforce/schema/UAC_healthEvaluation__c.UAC_typeOfContact__c';
import FLD_HEALTH_EVAL_METHOD_OF_CONTACT from '@salesforce/schema/UAC_healthEvaluation__c.UAC_methodofContact__c';
import FLD_HEALTH_EVAL_ATTEMPT_STATUS from '@salesforce/schema/UAC_healthEvaluation__c.UAC_attemptStatus__c';
import LBL_RECORD_TYPE_CLINICAL_CONTACT from '@salesforce/label/c.UAC_healthEvaluationRecordTypeClinicalContact';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_REMOVE from '@salesforce/label/c.UAC_remove';
import getRecords from '@salesforce/apex/UAC_listViewController.getRecords';
import { reduceErrors } from 'c/uacUtils';

const LBL_MODAL_HEADER = 'Add UC to Mental Health Group Event';
const LBL_CREATE_BUTTON = 'Create Clinical Contact';

const EVENT_FIELDS = [FLD_EVENT_NAME];

const COLUMNS = [
  {
    fieldName: 'uacLink',
    type: 'url',
    typeAttributes: {
      label: { fieldName: FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName },
      tooltip: 'Go to detail page',
      target: '_blank'
    },
    sortable: true
  },
  { fieldName: FLD_HEALTH_EVAL_TYPE_OF_CONTACT.fieldApiName, type: 'text', sortable: true },
  { fieldName: FLD_HEALTH_EVAL_METHOD_OF_CONTACT.fieldApiName, type: 'text', sortable: true },
  { fieldName: FLD_HEALTH_EVAL_ATTEMPT_STATUS.fieldApiName, type: 'text', sortable: true }
];
const DELETE_ACTION = {
  label: LBL_REMOVE,
  name: LBL_REMOVE,
  iconName: 'utility:delete'
};

export default class UacClinicalContactTable extends LightningElement {

  @api recordId;

  @track columns = [];
  @track recordList = [];
  @track recordsToDisplay = [];
  @track canAdd = false;

  modalHeader = LBL_MODAL_HEADER;
  lblCreateBtn = LBL_CREATE_BUTTON;
  sortDirection = 'asc';
  sortBy;
  eventRecord;
  selectedUACIdList = [];

  /**
   * @description Boolean flag to determine whether to display table or not.
   */
  get showTable() {
    return this.totalRecords > 0;
  }

  /**
   * @description Return subheader for event.
   */
  get subHeader() {
    return (this.eventRecord) ?
      `Event - ${this.eventRecord.fields[FLD_EVENT_NAME.fieldApiName].value}` :
      '';
  }

  /**
   * @description Returns number of total records.
   */
  get totalRecords() {
    return (this.recordList) ? this.recordList.length : 0;
  }

  /**
   * @description Returns title for the table.
   */
  get title() {
    return `UC Clinical Contacts (${this.totalRecords})`;
  }

  /**
   * @description Filter used to query Health Evaluation records.
   */
  get recordFilter() {
    return `RecordType.Name='${LBL_RECORD_TYPE_CLINICAL_CONTACT}' AND UAC_associatedEvent__c='${this.recordId}'`;
  }

  /**
   * @description Returns UAC search modal component.
   */
  get uacSearchModal() {
    return this.template.querySelector('c-uac-modal');
  }

  /**
   * @description Method to get object info for Health Evaluation object.
   */
  @wire(getObjectInfo, { objectApiName: OBJ_HEALTH_EVAL.objectApiName })
  wiredHealthEvalInfo({ data, error }) {
    if (data) {
      let columns = [...COLUMNS];
      columns.forEach(col => {
        let fieldName = col.fieldName;
        if (fieldName === 'uacLink') {
          fieldName = FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName;
        }
        col.label = data.fields[fieldName].label;
      });
      this.canAdd = data.createable;
      if (data.deletable === true) {
        let action = {
          type: 'action',
          typeAttributes: {
            rowActions: [DELETE_ACTION]
          }
        };
        columns.push(action);
      }
      this.columns = columns;
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  /*
   * Method to get Event record
   * param {recordId} current lighting page record id
   */
  @wire(getRecord, { recordId: '$recordId', fields: EVENT_FIELDS })
  wiredEventRecord({ data, error }) {
    if (data) {
      this.eventRecord = data;
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  /**
   * @description Method to reset sort settings
   */
  resetSort() {
    this.sortBy = 'uacLink';
    this.sortDirection = 'asc';
  }

  /**
   * @description Method to query Clinical Contact records
   */
  getRecordList() {
    let fieldsToQuery = [];
    COLUMNS.forEach(col => {
      let fieldName = col.fieldName;
      if (fieldName === 'uacLink') {
        fieldName = FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName;
      }
      fieldsToQuery.push(fieldName);
    });
    fieldsToQuery.push(FLD_HEALTH_EVAL_ASSOCIATED_UAC_NAME.fieldApiName);
    getRecords({
        query: JSON.stringify({
          objectApiName: OBJ_HEALTH_EVAL.objectApiName,
          fieldsToQuery: fieldsToQuery,
          filter: this.recordFilter
        })
      })
      .then(response => {
        let recordList = response;
        recordList.forEach(record => {
          record.uacLink = '/' + record.Id;
          // Replace UAC Id with UAC Name
          record[FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName] = record[
            FLD_HEALTH_EVAL_ASSOCIATED_UAC_NAME.fieldApiName.split('.')[0]
          ][
            FLD_HEALTH_EVAL_ASSOCIATED_UAC_NAME.fieldApiName.split('.')[1]
          ];
        })
        this.recordList = recordList;
        this.resetSort();
        this.sortData();
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  /**
   * @description Handle add button click.
   */
  handleAddClick() {
    this.uacSearchModal.show();
  }

  /**
   * @description Handle modal close button click.
   */
  handleClose() {
    this.uacSearchModal.hide();
  }

  /**
   * @description Handle modal Create button click.
   */
  handleSave() {
    if (this.selectedUACIdList.length > 0) {
      createClinicalContacts({
          associatedEventId: this.recordId,
          uacIdList: this.selectedUACIdList
        })
        .then(response => {
          if (!response.isSuccess) {
            this.showToastMessage('Error', reduceErrors(response.error)
              .join('\n'), 'error');
          } else {
            this.showToastMessage('Success', LBL_SAVE_SUCCESS, 'success');
            this.handleClose();
            this.getRecordList();
          }
        })
        .catch(error => {
          this.showToastMessage('Error', reduceErrors(error)
            .join('\n'), 'error');
        });
    }
  }

  /**
   * @description Handle the row selection event from UAC search modal component.
   * @param {Event} event Event trigger on row selection
   */
  handleRowSelection(event) {
    let row = event.detail;
    let selectedRowIds = [];
    if (row.length > 0) {
      selectedRowIds.push(row[0].Id);
    }
    this.selectedUACIdList = selectedRowIds;
  }

  /**
   * @description Method to handle action button click on lightning data-table
   * @param {Event} event Event triggered on row action in lightning data-table
   */
  handleRowAction(event) {
    const recId = event.detail.row.Id;
    const actionName = event.detail.action.name;
    if (LBL_REMOVE === actionName) {
      deleteRecord(recId)
        .then(() => {
          this.getRecordList();
          this.showToastMessage('Success', LBL_DELETE_SUCCESS, 'success');
        })
        .catch(error => {
          this.showToastMessage('Error', reduceErrors(error)
            .join('\n'), 'error');
        });

    }
  }

  /**
   * @description Method to handle sort action
   * @param {Event} event Event triggered on sort
   */
  handleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  /**
   * @description Method to sort list of records.
   */
  sortData() {
    let sortBy = (this.sortBy === 'uacLink') ?
      FLD_HEALTH_EVAL_ASSOCIATED_UAC.fieldApiName :
      this.sortBy;
    let sortDirection = this.sortDirection;

    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.recordList));

    // Return the value stored in the field
    let keyValue = (a) => {
      return a[sortBy];
    };

    // cheking reverse direction
    let isReverse = sortDirection === 'asc' ? 1 : -1;

    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ''; // handling null values
      y = keyValue(y) ? keyValue(y) : '';

      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });

    // set the sorted data to data table data
    this.recordList = parseData;
  }

  handlePaginatorChange(event) {
    this.recordsToDisplay = [...event.detail];
  }

  showToastMessage(title, message, variant) {
    this._isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

  connectedCallback() {
    this.getRecordList();
  }
}