import { LightningElement, api } from 'lwc';

const PAGE_SIZE_LIST = [5, 10, 25, 50, 100];

export default class uacPaginator extends LightningElement {

  @api pageSizeOptions = PAGE_SIZE_LIST; //Page size options; valid values are array of integers
  @api
  get records() {
    return this._records;
  }
  set records(value) {
    this._records = value;
    this.initialize();
  }

  _records = [];
  pageSize; //No.of records to be displayed per page
  pageNumber = 1; //Page number
  recordsToDisplay = []; //Records to be displayed on the page

  get totalRecords() {
    return this.records.length;
  }

  get totalPages() {
    let totalPages = Math.ceil(this.totalRecords / this.pageSize);
    return (totalPages > 0) ? totalPages : 1;
  }

  get hasPrev() {
    return this.pageNumber > 1;
  }

  get hasNext() {
    return this.pageNumber < this.totalPages;
  }

  initialize() {
    this.pageNumber = 1;
    if (!this.pageSize) {
      this.pageSize = this.pageSizeOptions[0];
    }
    this.setRecordsToDisplay();
  }

  handlePageSizeChange(event) {
    this.pageSize = event.target.value;
    this.setRecordsToDisplay();
  }

  handlePageNumberChange(event) {
    if (event.keyCode === 13) {
      this.pageNumber = event.target.value;
      this.setRecordsToDisplay();
    }
  }

  previousPage() {
    this.pageNumber = this.pageNumber - 1;
    this.setRecordsToDisplay();
  }

  nextPage() {
    this.pageNumber = this.pageNumber + 1;
    this.setRecordsToDisplay();
  }

  setRecordsToDisplay() {
    let recordsToDisplay = [];
    this.validatePageNumber();
    for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this
      .pageSize; i++) {
      if (i === this.totalRecords) break;
      recordsToDisplay.push(this.records[i]);
    }

    this.recordsToDisplay = recordsToDisplay;
    this.dispatchEvent(new CustomEvent('paginatorchange', {
      detail: this.recordsToDisplay
    })); //Send records to display on table to the parent component
  }

  validatePageNumber() {
    if (this.pageNumber < 1) {
      this.pageNumber = 1;
    } else if (this.pageNumber >= this.totalPages) {
      this.pageNumber = this.totalPages;
    }
  }
}