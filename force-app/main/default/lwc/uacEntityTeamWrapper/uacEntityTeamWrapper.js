import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
export default class UacEntityTeamWrapper extends LightningElement {
    @api recordId;
    @track parentRecordId;
    @track showParentList = false;
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_FIELD]})
    contact({ error, data}) {
        console.log('WRAPPER QUERY');
        console.log(error);
        console.log(data);
        if(error) {
            this.showParentList = false;
        }
        if(data && data.fields && data.fields.AccountId) {
            console.log('Set Account ID');
            this.parentRecordId = data.fields.AccountId.value;
            this.showParentList = true;
        }
    }
    connectedCallback() {
        console.log(ACCOUNT_FIELD);
    }
}