import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import {api, LightningElement, track} from 'lwc';

export default class UacFlowDynamicPicklist extends LightningElement {
  @api
  question;
  @api
  picklistValues;
  @api
  required = false;
  @track
  selectedValue;
  selectedValueInput;
  @track
  picklistOptions;
  @api
  get value() {
    return this.selectedValue;
  }
  set value(value) {
    this.selectedValueInput = value;
    console.log('Value  : ' + value);
    console.log('selectedValueInput : ' + this.selectedValueInput);    
  }
 
  connectedCallback() {
    let options = [];
    this.picklistValues.forEach(value => {
      options.push({label: value, value: value});
    });
    this.picklistOptions = options;
    if (this.selectedValueInput) {
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
        console.log('before dipatching event valueOutput ' + this.selectedValue);
      valueChangeEvent = new FlowAttributeChangeEvent('value', this.selectedValue);
    this.dispatchEvent(valueChangeEvent);
    console.log('after dipatching event valueOutput ' + this.selectedValue);

  }
  @api
  validate() {
    console.log('Validating: ' + this.question);
    let errorMessage = 'This question is required.';
    if (this.required === true && !this.selectedValue) {
      return {isValid: false, errorMessage: errorMessage};
    } else {
      return {isValid: true};
    }
  }
}