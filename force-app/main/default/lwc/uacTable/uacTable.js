import {
  LightningElement,
  api,
  track
} from 'lwc';

const LBL_NO_DATA = 'No data found.';
const LBL_REVIEW_ALL_ERRORS = 'Please review all of the errors below.';
const LBL_LOADING_DATA = 'Loading...';

export default class UacTable extends LightningElement {
  @api
  get columns() {
    return this._columns;
  }
  set columns(value) {
    this._columns = value;
    this.refreshData();
  }
  @api defaultNewRecord = {};
  @api disableAdd = false;
  @api disableDelete = false;
  @api
  get records() {
    return this._records;
  }
  set records(value) {
    this._records = JSON.parse(JSON.stringify(value));
    this.refreshData();
  }
  @api
  get hasUnsavedData() {
    return this.data.filter((value) => {
        return value.isUnsaved;
      })
      .length > 0;
  }
  @api
  addError(errors) {
    if (!(errors instanceof Array)) errors = [errors];
    for (let error of errors) {
      this.errors.push(error);
    }
  }
  @api
  addFieldError(error, rowIndex, fieldName) {
    this.data[rowIndex].hasError = true;
    this.template.querySelector(`.${fieldName}[data-index='${rowIndex}']`)
      .setErrors(error);
  }
  @api
  deleteRows(indexes) {
    if (!(indexes instanceof Array)) indexes = [indexes];
    let i = 0;
    const data = [...this.data].filter((value, indx) => {
      if (!indexes.includes(indx)) {
        value.index = i;
        i++;
      }
      return !indexes.includes(indx);
    });
    this.data = data;
    const records = [...this._records].filter((value, indx) => {
      if (!indexes.includes(indx)) {
        value.index = i;
        i++;
      }
      return !indexes.includes(indx);
    });
    this._records = records;
  }
  @api
  handleSaveResponse(successMap, errorMap) {
    const data = [...this.data];
    Object.keys(successMap)
      .forEach((key) => {
        data[key].isUnsaved = false;
        data[key].record = successMap[key];
        this._records[key] = JSON.parse(JSON.stringify(successMap[key])); // deep copy record
        data[key].fields.forEach((fld) => {
          if (this._records[key][fld.name]) fld.value = this._records[key][fld.name];
        });
      });
    let errorMessageSet = new Set();
    Object.keys(errorMap)
      .forEach((key) => {
        data[key].hasError = true;
        errorMap[key].forEach((message) => {
          errorMessageSet.add(message);
        })
      });
    this.errors = Array.from(errorMessageSet);
  }
  @api
  handleDeleteResponse(successMap, errorMap) {
    const data = [...this.data];
    let indexes = [];
    Object.keys(successMap)
      .forEach((key) => {
        data.forEach((row) => {
          if (key === row.record.Id) indexes.push(row.index);
        });
      });
    this.deleteRows(indexes);
    let errorMessageSet = new Set();
    Object.keys(errorMap)
      .forEach((key) => {
        data.forEach((row) => {
          if (key === row.record.Id) row.hasError = true;
        });
        errorMap[key].forEach((message) => {
          errorMessageSet.add(message);
        });
      });
    this.errors = Array.from(errorMessageSet);
  }
  @api
  validate() {
    const data = [...this.data];
    data.forEach((value) => {
      value.hasError = false;
    });
    this.errors = [];
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      if (!cmpValidity) {
        data[inputCmp.dataset.index].hasError = true;
      }
      return validSoFar && cmpValidity;
    }, true);
    return isValid;
  }

  @track errors = [];
  @track data = [];
  @track isLoading = false;

  lblNoData = LBL_NO_DATA;
  lblLoading = LBL_LOADING_DATA;
  _records = [];
  _columns = [];

  get columnLength() {
    // Field Columns + Action Column + Tag Column
    return (!this._columns) ? 0 : this._columns.length + 2;
  }

  refreshData() {
    this.errors = [];
    let rows = [];
    this.isLoading = true;
    for (let i = 0; i < this._records.length; i++) {
      let row = {
        index: i,
        fields: JSON.parse(JSON.stringify(this._columns)),
        record: JSON.parse(JSON.stringify(this._records[i])),
      };
      for (let field of row.fields) {
        if (row.record[field.name] || row.record[field.name] === 0) {
          field.value = row.record[field.name];
        }
        if (field.controllingField && row.record[field.controllingField]) {
          field.controllingValue = row.record[field.controllingField];
        }
      }
      rows.push(row);
    }
    this.data = [];

    // Setting data in timeout as workaround for render not detecting changes to row/field attributes
    // eslint-disable-next-line
    setTimeout(() => {
      this.data = rows;
      this.isLoading = false;
      this.dispatchEvent(new CustomEvent('loadcomplete', {
        detail: {
          rows: this.data
        }
      }));
    }, 1);
  }

  onAddClick() {
    let data = [...this.data];
    const row = {
      index: this.data.length,
      fields: JSON.parse(JSON.stringify(this._columns)), // deep copy field definitions
      isUnsaved: true,
      record: JSON.parse(JSON.stringify(this.defaultNewRecord)) // deep copy new record object
    };
    row.fields.forEach((fld) => {
      if (row.record && row.record[fld.name]) {
        fld.value = row.record[fld.name];
      }
      if (row.record && fld.controllingField && row.record[fld.controllingField]) {
        fld.controllingValue = row.record[fld.controllingField];
      }
    });
    data.push(row);
    this.data = data;
  }

  onSaveClick() {
    this.errors = [];
    if (this.validate()) {
      let records = [];
      this.data.forEach((row) => {
        records.push(row.record);
      });
      this.dispatchEvent(new CustomEvent('save', {
        detail: {
          records: records
        }
      }));
    } else {
      this.errors.push(LBL_REVIEW_ALL_ERRORS);
    }
  }

  onCancelClick() {
    this.refreshData();
  }

  onDeleteClick(event) {
    this.errors = [];
    const index = parseInt(event.target.dataset.index, 10);
    const row = this.data[index];
    if (row.record.Id) {
      this.dispatchEvent(new CustomEvent('delete', {
        detail: {
          records: [row.record]
        }
      }));
    } else {
      this.deleteRows(index);
    }
  }

  handleFieldClick(event) {
    const index = event.target.dataset.index;
    const fieldName = event.detail.name;
    const row = this.data[index];
    this.dispatchEvent(new CustomEvent('fieldclick', {
      detail: {
        name: fieldName,
        record: row.record
      }
    }));
  }

  handleChange(event) {
    if (!event.target) return;
    const index = event.target.dataset.index;
    const fieldIndex = event.target.dataset.fieldIndex;
    const fieldName = event.detail.name;
    const value = event.detail.value;
    const data = [...this.data];
    const row = data[index];
    row.fields[fieldIndex].value = value;
    row.record[fieldName] = value;
    row.fields.filter((field) => {
        return field.controllingField === fieldName;
      })
      .forEach((field) => {
        field.controllingValue = value;
      });
    row.isUnsaved = true;
    row.hasError = false;
    this.data = data;
    this.dispatchEvent(new CustomEvent('fieldchange', {
      detail: {
        row: row,
        fieldName: fieldName,
        fieldValue: value
      }
    }));
  }
}