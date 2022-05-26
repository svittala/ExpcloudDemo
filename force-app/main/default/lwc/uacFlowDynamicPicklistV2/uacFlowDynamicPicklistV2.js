import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class UacFlowDynamicPicklistV2 extends LightningElement {
  @api
  question;
  @api
  isMultipicklist;
  @api
  isRadioButtonGroup;
  @api
  get fieldName() {
    return this._fieldName;
  }
  set fieldName(value) {
    this._fieldName = value;
    this.objectName = value.split('.')[0];
  }
  @api
  recordTypeName;
  @api
  excludeValues = [];
  @api
  required = false;
  @api
  isReadOnly = false;
  @api
  radioButtonHelpTxt;

  @track
  picklistOptions = [];
  @track
  objectName;
  @track
  recordTypeId;
  @track
  selectedValue;
  selectedValueInput;

  @wire(getObjectInfo, { objectApiName: '$objectName' })
  objectInfo({ data, error }) {
    if (data) {
      for (let recordTypeId of Object.keys(data.recordTypeInfos)) {
        if (data.recordTypeInfos[recordTypeId].name === this.recordTypeName) {
          this.recordTypeId = recordTypeId;
        }
      }
      if (!this.recordTypeId) {
        this.recordTypeId = data.defaultRecordTypeId;
      }
    } else if (error) {
      // eslint-disable-next-line no-console
      console.error(error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: '$fieldName'
  })
  wiredGetPicklistValue({ data, error }) {
    if (data) {
      let options = [];
      for (let option of data.values) {
        if (!this.excludeValues.includes(option.value)) {
          options.push({ label: option.label, value: option.value });
        }
      }
      this.picklistOptions = options;
    } else if (error) {
      // eslint-disable-next-line no-console
      console.error(error);
    }
  }

  @api
  get value() {
    return (this.isMultipicklist && this.selectedValue) ?
      this.selectedValue.join(';') :
      this.selectedValue;
  }
  set value(value) {
    this.selectedValueInput = value;
  }

  connectedCallback() {
    if (this.isMultipicklist && this.selectedValueInput) {
      if (this.selectedValueInput[0].includes(';')) {
        this.selectedValue = this.selectedValueInput[0].split(';');
      } else {
        this.selectedValue = this.selectedValueInput;
      }
    } else if (!this.isMultipicklist && this.selectedValueInput) {
      this.selectedValue = this.selectedValueInput;
    }
    if (this.selectedValue) {
      this.notifyFlow();
    }
  }
  handleClearClick() {
    this.selectedValue = undefined;
  }
  handleChange(event) {
    this.selectedValue = event.detail.value;
    this.notifyFlow();
  }
  notifyFlow() {
    let valueChangeEvent;
    if (this.isMultipicklist) {
      valueChangeEvent = new FlowAttributeChangeEvent('value', this.selectedValue.join(
        ';'));
    } else {
      valueChangeEvent = new FlowAttributeChangeEvent('value', this.selectedValue);
    }
    this.dispatchEvent(valueChangeEvent);
  }
  @api
  validate() {
    let errorMessage = 'Please enter some valid input. Input is not optional.';
    if (this.required === true && !this.selectedValue) {
      return { isValid: false, errorMessage: errorMessage };
    }
    return { isValid: true };
  }
}