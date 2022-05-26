import getAdmissionAssesment from '@salesforce/apex/UAC_medicationTableController.getAdmissionAssesment';
import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'

export default class UacPHIMedTableParent extends LightningElement {
    @api recordId;
    @track healthEvaluationId;
    @track uacId;
    @track loaded = false;

    connectedCallback() {
        console.log('In connectedCallBack');
        this.getAdmissionAssesmentJS();

    }

    getAdmissionAssesmentJS() {
        console.log('assesment Id ' + this.recordId);
        getAdmissionAssesment({
                admissionAssesmentId: this.recordId
            })
            .then(response => {
                console.log('RESPONSE ' + response);
                this.healthEvaluationId = response.UAC_healthEvaluationIme__c;
                this.uacId = response.UAC_uac__c;
                console.log('response.UAC_healthEvaluationIme__c ' + response.UAC_healthEvaluationIme__c);
                console.log('response.UAC_uac__c ' + response.UAC_uac__c);
                this.loaded = true;
            })
            .catch(error => {
                this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
            })
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

}