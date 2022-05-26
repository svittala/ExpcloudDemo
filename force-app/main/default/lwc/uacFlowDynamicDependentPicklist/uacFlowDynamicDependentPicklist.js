import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class UacFlowDynamicDependentPicklist extends LightningElement {
   @api
   objectApiName;
   //An Api Name for Controlling PickList Field
   @api
   recordTypeId;
   // to capture the record Type Id
   @api
   controllingPicklistApiName;
   //An Api Name for Dependent Picklist for any Object
   @api
   dependentPicklistApiName;
   // to show the label for the dependent field
   @api
   dependentPicklistLabel;
   // to show the label for the controlling field
   @api
   controllingPicklistLabel;
   @api
   required = false;
   
   //An Object to fill show user all available options
   @track
   optionValues = {controlling:[], dependent:[]};
   //To fill all controlling value and its related valid values
   allDependentOptions={};
   //To hold what value, the user selected.
   @track
   selectedValues = {controlling:undefined, dependent:undefined};

   @track
  selectedValueInputs = {controlling:undefined, dependent:undefined};
   //Invoke in case of error.
   isError = false;
   errorMessage;
   //To Disable Dependent PickList until the user won't select any parent picklist.
   isDisabled = true;
//To pass value to assignemnt screen
   @api
  get controllingPicklistValue() {
    return this.selectedValues.controlling;
  }
  set controllingPicklistValue(controllingPicklistValue) {
    this.selectedValueInputs.controlling = controllingPicklistValue;
  }
  @api
  get dependentPicklistValue() {
    return this.selectedValues.dependent;
  }
  set dependentPicklistValue(dependentPicklistValue) {
    this.selectedValueInputs.dependent = dependentPicklistValue;
  }
  connectedCallback() {
    if (this.selectedValueInputs.controlling) {
        this.selectedValues.controlling = this.selectedValueInputs.controlling;
    }
    if (this.selectedValueInputs.dependent) {
        this.selectedValues.dependent = this.selectedValueInputs.dependent;
    }
    if (this.selectedValues.controlling) {
        this.dispatchEvent(new FlowAttributeChangeEvent('controllingPicklistValue', this.selectedValues.controlling));
    }
      if (this.selectedValues.dependent) {
          this.dispatchEvent(new FlowAttributeChangeEvent('dependentPicklistValue', this.selectedValues.dependent));
      }
  }
   @wire(getObjectInfo, {objectApiName : '$objectApiName'})
   objectInfo;
   @wire(getPicklistValuesByRecordType, { objectApiName: '$objectApiName', recordTypeId: '$recordTypeId'})
   fetchValues({error, data}){
       if(data && data.picklistFieldValues){
           try{
               this.setUpControllingPicklist(data);
               this.setUpDependentPickList(data);
           }catch(err){
               this.isError = true;
               this.errorMessage = err.message;
           }
       }else if(error){
           this.isError = true;
           this.errorMessage = 'Object is not configured properly please check';
       }
   }
   //Method to set Up Controlling Picklist
   setUpControllingPicklist(data){
       this.optionValues.controlling = [{ label:'None', value:'' }];
       if(data.picklistFieldValues[this.controllingPicklistApiName]){
           data.picklistFieldValues[this.controllingPicklistApiName].values.forEach(option => {
               this.optionValues.controlling.push({label : option.label, value : option.value});
           });
           if(this.optionValues.controlling.length == 1)
               throw new Error('No Values Available for Controlling PickList');
       }
   }
   //Method to set up dependent picklist
   setUpDependentPickList(data){
        this.optionValues.dependent = [{ label:'None', value:'' }];
       if(data.picklistFieldValues[this.dependentPicklistApiName]){
           this.allDependentOptions = data.picklistFieldValues[this.dependentPicklistApiName];
           if(this.selectedValueInputs.controlling && this.selectedValueInputs.controlling.length > 0) {
                let controllerValues = this.allDependentOptions.controllerValues;
                this.allDependentOptions.values.forEach( val =>{
                    val.validFor.forEach(key =>{
                        if(key === controllerValues[this.selectedValueInputs.controlling]){
                            this.isDisabled = false;
                            this.optionValues.dependent.push({label : val.label, value : val.value});
                        }
                    });
                });
            }
       }
   }
   handleControllingChange(event){
       const selected = event.target.value;
       this.dispatchEvent(new FlowAttributeChangeEvent('controllingPicklistValue', event.target.value));
       if(selected && selected != 'None'){
           this.selectedValues.controlling = selected;
           this.selectedValues.dependent = null;
           this.optionValues.dependent = [{ label:'None', value:'' }];
           let controllerValues = this.allDependentOptions.controllerValues;
           this.allDependentOptions.values.forEach( val =>{
               val.validFor.forEach(key =>{
                   if(key === controllerValues[selected]){
                       this.isDisabled = false;
                       this.optionValues.dependent.push({label : val.label, value : val.value});
                   }
               });
           });

           const selectedrecordevent = new CustomEvent(
                "selectedpicklists", {
                    detail : { pickListValue : this.selectedValues}
                }
            );
            this.dispatchEvent(selectedrecordevent);
            if(!this.optionValues.dependent || !this.optionValues.dependent.length > 1){
               this.optionValues.dependent = '';
               this.isDisabled = true;
           }
       }else{
           this.isDisabled = true;
           this.selectedValues.dependent = '';
           this.selectedValues.controlling = '';
       }
   }
   handleDependentChange(event){
       this.selectedValues.dependent = event.target.value;
       const selectedrecordevent = new CustomEvent(
           "selectedpicklists",
           {
               detail : { pickListValue : this.selectedValues}
           }
       );

       this.dispatchEvent(selectedrecordevent);
       this.dispatchEvent(new FlowAttributeChangeEvent('dependentPicklistValue', this.selectedValues.dependent));
       //sendDataToParent();
   }

  
  @api
  validate() {
    let errorMessage = 'Please enter some valid input. Input is not optional.';
    if (this.required === true && (!this.selectedValues.controlling || (!this.selectedValues.dependent && this.selectedValues.controlling !='Psychotherapy/Psychiatry' ))) {
        return { isValid: false, errorMessage: errorMessage };
    }
    return { isValid: true };
  }
}