import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import {api, LightningElement, track} from 'lwc';

export default class UacFlowDynamicPicklist extends LightningElement {
  @api
  question;
  @api
  isMultipicklist;
  @api
  picklistValues;
  @api
  required = false;
  @api
  isReadOnly = false;
  @track
  selectedValue;
  selectedValueInput;
  @track
  picklistOptions;
  @track
  helpTextBool = false;
  @track
  helpTextValue = '';
  @api
  get helpText() {
    if (!this.helpTextValue) {
      return '';
    }
    return this.helpTextValue;
  }
  set helpText(value) {
    this.helpTextValue = value;
    this.helpTextBool = true;
  }
  @api
  get valueOutput() {
    if (!this.selectedValue) {
      return '';
    }
    if (this.isMultipicklist) {
      return this.selectedValue.join(';');
    } else {
      return this.selectedValue;
    }
  }
  @api
  get valueInput() {
    return this.selectedValue;
  }
  set valueInput(valueInput) {
    this.selectedValueInput = valueInput;
  }
  connectedCallback() {
    let options = [];
    this.picklistValues.forEach(value => {
      options.push({label: value, value: value});
    });
    this.picklistOptions = options;
    if (this.isMultipicklist && this.selectedValueInput) {
      if (this.selectedValueInput[0].includes(';')) {
        this.selectedValue = this.selectedValueInput[0].split(';');
      } else {
        this.selectedValue = this.selectedValueInput;
      }
    } else if (!this.isMultipicklist && this.selectedValueInput) {
      console.log('Setting Value Input Single: ' + this.selectedValueInput);
      this.selectedValue = this.selectedValueInput;
    }
    if (this.selectedValue) {
      this.notifyFlow();
    }
  }
  handleChange(event) {
    this.selectedValue = event.detail.value;
    this.notifyFlow();
  }
  notifyFlow() {
    let valueChangeEvent;
    if (this.isMultipicklist) {
      valueChangeEvent = new FlowAttributeChangeEvent('valueOutput', this.selectedValue.join(';'));
    } else {
      valueChangeEvent = new FlowAttributeChangeEvent('valueOutput', this.selectedValue);
    }
    this.dispatchEvent(valueChangeEvent);
  }
  @api
  validate() {
    let errorMessage = 'This question is required.';
    if (this.required === true && !this.selectedValue) {
      return {isValid: false, errorMessage: errorMessage};
    } else {
      return {isValid: true};
    }
  }
}