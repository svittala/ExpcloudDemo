import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFieldList from '@salesforce/apex/UAC_fileListController.getFieldList';
import getFileList from '@salesforce/apex/UAC_fileListController.getLegalFileList';
import { reduceErrors, DATETIME_TYPE_ATTRIBUTE } from 'c/uacUtils';
import UAC_filesLWCLabel from '@salesforce/label/c.UAC_filesLWCLabel';

const TITLE_COLUMN = {
  label: 'Title',
  fieldName: 'Title',
  type: 'button',
  sortable: true,
  typeAttributes: {
    label: { fieldName: 'Title' },
    name: 'view',
    variant: 'base'
  },
  cellAttributes: {
    alignment: 'center'
  }
}

export default class UacLegalFileList extends NavigationMixin(LightningElement) {
  @api recordId;
  @api height;
  @api recordTypeName;
  @api componentLabel;
  @api Label = UAC_filesLWCLabel;

  @track lstFile = [];
  @track isLoading = true;
  @track isModalOpen = false;

  label = { UAC_filesLWCLabel };
  lstColumn;
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy = 'Title';

  /**
   * @description Wired method to get data table columns to display
   */
  @wire(getFieldList, {}) wiredFieldList({ data, error }) {
    if (data) {
      let lstColumn = [TITLE_COLUMN];
      for (let objFieldInfo of data) {
        if (objFieldInfo.strFieldName ===
          'Title') { // Skip title column since it is already added
          continue;
        }
        let column = {
          label: objFieldInfo.strLabel,
          fieldName: objFieldInfo.strFieldName,
          sortable: true
        };
        switch (objFieldInfo.strDisplayType) {
        case "DATETIME":
          column.type = 'date';
          column.typeAttributes = DATETIME_TYPE_ATTRIBUTE;
          break;
        case "BOOLEAN":
          column.type = 'boolean';
          column.sortable = false;
          break;
        case "DOUBLE":
        case "INTEGER":
        case "LONG":
          column.type = 'number';
          break;
        case "PERCENT":
          column.type = 'percent';
          break;
        default:
          column.type = "text";
        }
        lstColumn.push(column);
      }
      this.lstColumn = lstColumn;
    } else if (error) {
      this.handleError(error);
    }
  }

  /**
   * @description Method to return styling for the div containing the data table.
   */
  get dataTableDivStyle() {
    if (this.height) {
      return `height: ${this.height};`;
    }
    return '';
  }

  /**
   * @description Method to return label for Add Files button
   */
  get addFilesLabel() {
    return 'Add ' + this.label.UAC_filesLWCLabel;
  }

  /**
   * @description Method to check if data table should be displayed
   */
  get showTable() {
    return !this.isLoading && this.lstFile.length > 0;
  }

  /**
   * @description Method to show Add Files modal
   */
  openModal() {
    this.isModalOpen = true;
  }

  /**
   * @description Method to hide Add Files modal
   */
  closeModal() {
    this.isModalOpen = false;
  }

  /**
   * @description Method to get list of files (content version) from the server
   */
  refreshFiles() {
    this.isLoading = true;
    getFileList({ idRecord: this.recordId, recordTypeName : this.recordTypeName })
      .then(result => {
        const lstFile = [...result];
        lstFile.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
        this.lstFile = lstFile;
        this.isLoading = false;
      })
      .catch(error => {
        this.handleError(error);
      });
  }

  /**
   * @description Method to sort list of files by the field provided
   */
  sortBy(field, reverse, primer) {
    const key = primer ?
      function (x) {
        return primer(x[field]);
      } :
      function (x) {
        return x[field];
      };

    return function (a, b) {
      a = key(a);
      b = key(b);
      if (typeof (a) === 'string') a = a.toUpperCase();
      if (typeof (b) === 'string') b = b.toUpperCase();
      return reverse * ((a > b) - (b > a));
    };
  }


  /**
   * @description Method to handle data table sorting
   * @param event Event fired on data table sort
   */
  handleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.lstFile];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    this.lstFile = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  /**
   * @description Method to handle data table row actions
   * @param event Event fired when data table button is clicked
   */
  handleRowAction(event) {
    const row = event.detail.row;
    const actionName = event.detail.action.name;
    if (actionName === 'view') {
      this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
          pageName: 'filePreview'
        },
        state: {
          selectedRecordId: row.ContentDocumentId
        }
      });
    }
  }

  /**
   * @description Method to handle post-upload logic
   */
  handleUploadFinish() {
    this.closeModal();
    this.refreshFiles();
  }

  /**
   * @description Method to handle errors and display a toast message
   * @param error Object containing error details
   */
  handleError(error) {
    if (!error) {
      return;
    }
    this.isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: 'Error',
      message: reduceErrors(error)
        .join('\n'),
      variant: 'error'
    }));
  }

  /**
   * @description Callback method called when the component is loaded
   */
  connectedCallback() {
    this.refreshFiles();
  }
}