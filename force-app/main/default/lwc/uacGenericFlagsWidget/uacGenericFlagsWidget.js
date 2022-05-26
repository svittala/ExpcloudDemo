import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class uacGenericFlagsWidget extends LightningElement {
    @api recordId;
    @api fields = [];    
}