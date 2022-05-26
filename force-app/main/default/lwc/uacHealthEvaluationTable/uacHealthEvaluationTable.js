import { LightningElement, api, wire, track } from 'lwc';
import { reduceErrors } from 'c/uacUtils';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OBJ_EXPOSURE_EVENT from '@salesforce/schema/UAC_exposureEvent__c';
import OBJ_HEALTHEVALUATION from '@salesforce/schema/UAC_healthEvaluation__c';
import FLD_UAC_A from "@salesforce/schema/UAC_healthEvaluation__c.UAC_aNum__c";
import FLD_AGE from "@salesforce/schema/UAC_healthEvaluation__c.UAC_PHIAge__c";
import FLD_DATEOFEXPOSOURE from "@salesforce/schema/UAC_healthEvaluation__c.UAC_dateofLastExposure__c";
import FLD_CURRENT_PROGRAM from "@salesforce/schema/UAC_healthEvaluation__c.UAC_currentProgram__c";
import FLD_OUTCOME from "@salesforce/schema/UAC_healthEvaluation__c.UAC_outcomeofORRPHI__c";
import FLD_MOSTRECENT from "@salesforce/schema/UAC_healthEvaluation__c.UAC_dischargeDateforMostRecentORRStay__c";
import FLD_Name from "@salesforce/schema/UAC_healthEvaluation__c.Name";
import FLD_EXPOSURE_NAME from "@salesforce/schema/UAC_exposureEvent__c.Name";
import FLD_EXPOSURE_DISEASE_CONDITION from "@salesforce/schema/UAC_exposureEvent__c.UAC_diseaseCondition__c";
import FLD_EXPOSURE_PHI_CLOSURE_DATE from "@salesforce/schema/UAC_exposureEvent__c.UAC_PHIClosureDate__c";
import LBL_CURRENT_PROGRAM from '@salesforce/label/c.UAC_currentProgram';
import LBL_DATE_OF_LAST_EXPOSURE from '@salesforce/label/c.UAC_dateOfLastExposure';
import LBL_MOST_RECENT_STAY from '@salesforce/label/c.UAC_dischargeDateMostRecentORRStay';
import LBL_HEALTH_EVALUATION_ID from '@salesforce/label/c.UAC_healthEvaluationID';
import LBL_OUTCOME_OF_ORR from '@salesforce/label/c.UAC_outcomeOfORRPHI';
import LBL_REMOVE from '@salesforce/label/c.UAC_remove';
import LBL_A from '@salesforce/label/c.UAC_aNumber';
import LBL_ASSOCIATED_UAC from '@salesforce/label/c.UAC_associatedUAC';
import LBL_PHI_AGE from '@salesforce/label/c.UAC_phiAge';
import LBL_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import getExposureContacts from '@salesforce/apex/UAC_fetchHealthEvaluationController.getExposureContacts'
import createPHI from '@salesforce/apex/UAC_createPublicHealthEvaluation.createPHI'

const columnsConst = [
  { label: LBL_A, fieldName: FLD_UAC_A.fieldApiName, type: 'text' },
  { label: LBL_ASSOCIATED_UAC, fieldName: 'associatedName', type: 'text' },
  { label: LBL_PHI_AGE, fieldName: FLD_AGE.fieldApiName, type: 'text', sortable: true },
  {
    label: LBL_DATE_OF_LAST_EXPOSURE,
    fieldName: FLD_DATEOFEXPOSOURE.fieldApiName,
    type: 'date-local',
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    }
  },
  {
    label: LBL_CURRENT_PROGRAM,
    fieldName: FLD_CURRENT_PROGRAM.fieldApiName,
    type: 'text',
    sortable: true
  },
  {
    label: LBL_OUTCOME_OF_ORR,
    fieldName: FLD_OUTCOME.fieldApiName,
    type: 'text',
    sortable: true
  },
  {
    label: LBL_MOST_RECENT_STAY,
    fieldName: FLD_MOSTRECENT.fieldApiName,
    type: 'date-local',
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    }
  },
  {
    label: LBL_HEALTH_EVALUATION_ID,
    fieldName: 'healthLink',
    type: 'url',
    typeAttributes: {
      label: { fieldName: FLD_Name.fieldApiName },
      tooltip: 'Go to detail page',
      target: '_blank'
    }
  },

];

const DELETE_ACTION = {
  label: LBL_REMOVE,
  name: LBL_REMOVE,
  iconName: 'utility:delete'
};

const FIELDS = [
  `${OBJ_EXPOSURE_EVENT.objectApiName}.Id`,
  `${OBJ_EXPOSURE_EVENT.objectApiName}.${FLD_EXPOSURE_NAME.fieldApiName}`,
  `${OBJ_EXPOSURE_EVENT.objectApiName}.${FLD_EXPOSURE_DISEASE_CONDITION.fieldApiName}`,
  `${OBJ_EXPOSURE_EVENT.objectApiName}.${FLD_EXPOSURE_PHI_CLOSURE_DATE.fieldApiName}`
];

export default class UacHealthEvaluationTable extends LightningElement {
  @api recordId;
  error;
  columns = [];
  healthEvaluationsList = []; //All healthEvaluationsList available for data table
  @track recordsToDisplay = []; //Records to be displayed on the page
  rowNumberOffset = 0; //Row number
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;
  uacAnumberId = []; //Capture selected A number id
  exposureEventId;
  healthExposureEvent = '';
  diseaseCondition;
  exposureEventName;
  phiclosoureDate;

  get showTable() {
    return this.healthEvaluationsList && this.healthEvaluationsList.length > 0;
  }

  get totalRecords() {
    return (this.healthEvaluationsList) ? this.healthEvaluationsList.length : 0;
  }

  get title() {
    return `Potentially Exposed UCs (${this.totalRecords})`;
  }

  /**
   * @description Method to get object info and populate field attributes for label and required
   * @param objectApiName Name of object to get object info from schema
   * @return {data, error}
   */
  @wire(getObjectInfo, { objectApiName: OBJ_HEALTHEVALUATION.objectApiName })
  wiredHealthEvalObjectInfo({ data, error }) {
    if (data) {
      let columns = JSON.parse(JSON.stringify(columnsConst));
      if (data.deletable === true) {
        let action = {
          type: 'action',
          typeAttributes: {
            rowActions: [DELETE_ACTION]
          }
        }
        columns.push(action);
      }
      this.columns = columns;
    }
    else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  /*
   * Wire current Health exposure records.
   * param {recordId} current lighting page record id
   */
  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  wireHealthExposureEvent(data, error) {
    if (data) {
      this.healthExposureEvent = data;
      if (this.healthExposureEvent.data) {
        this.exposureEventId = this.healthExposureEvent.data.fields.Id.value;
        this.exposureEventName = this.healthExposureEvent.data.fields.Name.value;
        this.phiclosoureDate = this.healthExposureEvent.data.fields.UAC_PHIClosureDate__c
          .value;
        this.diseaseCondition = this.healthExposureEvent.data.fields.UAC_diseaseCondition__c
          .displayValue;
        this.getRecordList();
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  /**
   * Method trigged on click remove buttion from list data table
   * @param {event} event information on handle rows
   */
  callRowAction(event) {
    const recId = event.detail.row.Id;
    const actionName = event.detail.action.name;
    if (LBL_REMOVE === actionName) {

      deleteRecord(recId)
        .then(() => {
          this.getRecordList();
          this.showToastMessage('Success', 'Record successfully deleted.', 'success');
        })
        .catch(error => {
          this.showToastMessage('Error', error.body.output.errors[0].message, 'error');
        });

    }
  }

  /**
   * Return tre if exposure event have phi closure date other wise return false.
   */
  get isphiclosedate() {
    return this.phiclosoureDate == null;
  }

  /**
   * Load releated Health evaluation record for current exposure event
   * param {exposureEventId} current exposoure event id
   */
  getRecordList() {
    getExposureContacts({ exposureEventId: this.exposureEventId })
      .then(data => {
        let recs = [];
        for (let i = 0; i < data.length; i++) {
          let healthEvaluation = {};
          healthEvaluation.rowNumber = '' + (i + 1);
          healthEvaluation.healthLink = '/' + data[i].Id;
          healthEvaluation.associatedName = data[i].UAC_associatedUAC__r.Name;
          healthEvaluation = Object.assign(healthEvaluation, data[i]);
          recs.push(healthEvaluation);
        }
        this.healthEvaluationsList = recs;
      })
      .catch(error => {
        this.showToastMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });

  }

  /*
   * This event is fires onclick for sorting by PHI age or Out come of ORR PHI
   */
  handleSortdata(event) {
    // field name
    this.sortBy = event.detail.fieldName;

    // sort direction
    this.sortDirection = event.detail.sortDirection;

    // calling sortdata function to sort the data based on direction and selected field
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
  }
  /**
   * Sort  list of records based on defautl sort direction
   * @param {*} fieldname  is used for identify sorting fields
   * @param {*} direction  sorting direction asc or dsc
   */
  sortData(fieldname, direction) {
    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.healthEvaluationsList));

    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };

    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1 : -1;

    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ''; // handling null values
      y = keyValue(y) ? keyValue(y) : '';

      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });

    // set the sorted data to data table data
    this.healthEvaluationsList = parseData;
  }

  //Capture the event fired from the paginator component
  handlePaginatorChange(event) {
    this.recordsToDisplay = [...event.detail];
    this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
  }
  /**
   * Capture the event from uac modal component. This is used capute aumemeber id
   * @param {*} event  event have selected au member information
   */
  onhandleRowSelection(event) {
    let row = event.detail;
    let amemberId = [];
    if (row.length > 0) {
      amemberId.push(row[0].Id);
    }
    this.uacAnumberId = amemberId;
  }
  /**
   * Onclick of add button to open up modal dialogue box and search for A#
   */
  showModal() {
    this.template.querySelector('c-uac-modal')
      .show();

  }
  /**
   *  Return subheader for exposure event
   */
  get subHeader() {
    return 'Exposure Event - ' + this.exposureEventName;
  }

  /**
   * Hide uac modal box
   */

  hideModal() {
    this.template.querySelector('c-uac-modal')
      .hide();
  }

  /**
   * Set the loading flag
   */
  handleLoad() {
    this.isLoading = false;
  }

  /**
   * On click of create PHI button from uac modal components.
   * @param {*} exposoureEventId  current exposoure event id
   * @param {*} uacIdList List of uac memeber
   */
  handleSave() {
    if (this.uacAnumberId.length > 0) {
      createPHI({
          exposureEventId: this.exposureEventId,
          uacIdList: this.uacAnumberId
        })
        .then(response => {
          if (response.isSuccess) {
            this.showToastMessage('Success', LBL_SUCCESS, 'success');
            this.uacAnumberId = [];
            this.getRecordList();
          }
          else {
            this.dispatchEvent(new ShowToastEvent(
              {title: 'Error creating record', message: response.error, variant: 'error'}));
          }
        })
        .catch(error => {
          this.showToastMessage('Error', reduceErrors(error)
            .join('\n'), 'error');
        });
    }
    this.handleClose();
  }

  /**
   * Close modal dialogue box. This method onclick of close or cancel.
   */
  handleClose() {
    this.isLoading = false;
    this.error = undefined;
    this.hideModal();
  }

  showToastMessage(title, message, variant) {
    this._isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

}