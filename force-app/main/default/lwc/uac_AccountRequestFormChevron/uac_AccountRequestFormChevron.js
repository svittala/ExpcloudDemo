import { LightningElement, api, wire, track  } from 'lwc';
import { getRecord , getFieldValue } from 'lightning/uiRecordApi';
import Record_Id from '@salesforce/schema/UAC_AccountRequestForm__c.Id';
import RecordStatus from '@salesforce/schema/UAC_AccountRequestForm__c.UAC_Status__c';
const FIELDS  = [Record_Id, RecordStatus];

export default class Uac_AccountRequestFormChevron extends LightningElement {
    @api recordId;
    @track status;
    @track showProgress = false;
    @track showRejected = false;
    @wire(getRecord , { recordId : '$recordId', fields : FIELDS  })
    wiredCase({data}){
       // alert('here' + data);
        //console.log(data.RecordStatus);
        this.showProgress = false;
        this.showRejected = false;
        if(data){
            this.status = getFieldValue(data,RecordStatus);
            if(this.status == 'Supervisor Rejected'){
                this.showRejected = true;
            }
            else{
                this.showProgress = true;
            }
        }
    }
}