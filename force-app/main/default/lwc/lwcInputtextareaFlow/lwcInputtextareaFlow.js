import { api, LightningElement, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class lwcInputtextareaFlow extends LightningElement {
  
  @api label;
  @api errorString;
  @api value;
  @api required;
  @api isReadOnly;
  @api placeholder;

    set  required (inputbool){
      this.required= inputbool;
      }
    set  isReadOnly (inputbool){
      this.isReadOnly= inputbool;
    }
    set label (inputval) {
      this.label = inputval;
    }
    set errorString (inputval){
      this.errorString = inputval;
    }
    set placeholder (inputval){
      this.placeholder = inputval;
    }
    

    handleChange(event) {
            this.value = event.detail.value;
            this.notifyFlow();
    }
    notifyFlow(){
        let valueChangeEvent;
        valueChangeEvent= new FlowAttributeChangeEvent("value",this.value)
    }
    @api
    validate() {
       if (this.required === true && !this.value) {
        return {isValid: true, errorMessage: this.errorString};
      } else {
        return {isValid: true};
      }
    } 

}