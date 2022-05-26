import deleteMedicationList from '@salesforce/apex/UAC_medicationTableController.deleteMedicationList';
import getMedicationList from '@salesforce/apex/UAC_medicationTableController.getMedicationListForAssessment';
import upsertMedicationList from '@salesforce/apex/UAC_medicationTableController.upsertMedicationList';
import LBL_DELETE_SUCCESS from '@salesforce/label/c.UAC_lblDeleteSuccess';
import LBL_SAVE_SUCCESS from '@salesforce/label/c.UAC_lblSaveSuccess';
import OBJ_MEDICATION from '@salesforce/schema/UAC_medication__c';
import FLD_MEDICATION_NAME from '@salesforce/schema/UAC_medication__c.Name';
import FLD_ENTERED_FROM_INITIAL_ASSESSMENT from '@salesforce/schema/UAC_medication__c.UAC_enteredfromInitialIntakesAssessment__c';
import FLD_ADMISSION_ASSESSMENT from '@salesforce/schema/UAC_medication__c.UAC_admissionAssessment__c';
import FLD_ASSOCIATED_UAC from '@salesforce/schema/UAC_medication__c.UAC_associatedUAC__c';
//import FLD_DATE_DISCONTINUED from '@salesforce/schema/UAC_medication__c.UAC_dateDiscontinued__c';
import FLD_DATE_STARTED from '@salesforce/schema/UAC_medication__c.UAC_dateStarted__c';
import FLD_DIRECTION from '@salesforce/schema/UAC_medication__c.UAC_direction__c';
import FLD_DISCHARGED_WITH_MEDICATION from '@salesforce/schema/UAC_medication__c.UAC_dischargedWithMedication__c';
import FLD_DOSE from '@salesforce/schema/UAC_medication__c.UAC_dose__c';
import FLD_PSYCHOTROPIC from '@salesforce/schema/UAC_medication__c.UAC_psychotropic__c';
import {
    getTodaysDate,
    reduceErrors
} from 'c/uacUtils'
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'
import {
    getObjectInfo,
    getPicklistValuesByRecordType
} from 'lightning/uiObjectInfoApi';
import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';

const LST_FIELD = [{
        name: FLD_MEDICATION_NAME.fieldApiName,
        type: 'text',
        required: true
    },
    {
        name: FLD_DATE_STARTED.fieldApiName,
        type: 'date',
        max: getTodaysDate(),
        required: true
    },
    {
        name: FLD_DOSE.fieldApiName,
        type: 'text',
        required: true
    },
    {
        name: FLD_DIRECTION.fieldApiName,
        type: 'text',
        required: true
    },
    {
        name: FLD_PSYCHOTROPIC.fieldApiName,
        type: 'picklist',
        required: true
    },
    {
        name: FLD_DISCHARGED_WITH_MEDICATION.fieldApiName,
        type: 'picklist',
        required: true
    }
];
const OPT_NONE = {
    label: '--None--',
    value: ''
};
export default class UacMedicationTableAdmissionAssesment extends LightningElement {
    @api
    uacId;
    @api
    healthEvaluationId;
    @track
    lstField = LST_FIELD;
    @track
    _objectInfo;
    @track
    tableContainerClass = 'slds-show';
    @api 
    recordId;

    get uacTable() {
        return this.template.querySelector('c-uac-table');
    }

    get defaultNewRecord() {
        return JSON.parse(`{
            "${FLD_ENTERED_FROM_INITIAL_ASSESSMENT.fieldApiName}": true,
            "${FLD_ASSOCIATED_UAC.fieldApiName}": "${this.uacId}",
            "${FLD_ADMISSION_ASSESSMENT.fieldApiName}": "${this.recordId}"
          }`);
    }

    showTable(val) {
        this.tableContainerClass = (val) ? 'slds-show' : 'slds-hide';
    }

    @wire(getObjectInfo, {
        objectApiName: OBJ_MEDICATION
    })
    wiredObjectInfo({
        data,
        error
    }) {
        if (data) {
            this._objectInfo = data;
            for (let field of this.lstField) {
                field.label = data.fields[field.name].label;
            }
        } else if (error) {
            this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
        }
    }

    @wire(getPicklistValuesByRecordType, {
        recordTypeId: '$_objectInfo.defaultRecordTypeId',
        objectApiName: OBJ_MEDICATION
    })

    wiredGetPicklistValuesByRecordType({
        data,
        error
    }) {
        if (data) {
            let lstField = [...this.lstField];
            for (let field of this.lstField) {
                if (field.type === 'picklist') {
                    field.options = [OPT_NONE];
                    data.picklistFieldValues[field.name].values.forEach(key => {
                        field.options.push({
                            label: key.label,
                            value: key.value
                        });
                    });
                }
                this.lstField = lstField;
            }
        } else if (error) {
            this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
        }
    }

    handleSave(event) {
        const records = event.detail.records;
        upsertMedicationList({
                strRecordList: JSON.stringify(records)
            })
            .then(response => {
                if (response.isSuccess) {
                    if (Object.keys(response.data.errorMap).length <= 0) {
                        this.showToastMessage('Success', LBL_SAVE_SUCCESS, 'success');
                    }
                    this.uacTable.handleSaveResponse(response.data.successMap, response.data.errorMap);
                } else {
                    this.uacTable.addError(response.error);
                }
            })
            .catch(error => {
                this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
            })
    }

    handleDelete(event) {
        const records = event.detail.records;
        deleteMedicationList({
                strRecordList: JSON.stringify(records)
            })
            .then(response => {
                if (response.isSuccess) {
                    if (Object.keys(response.data.errorMap).length <= 0) {
                        this.showToastMessage('Success', LBL_DELETE_SUCCESS, 'success');
                    }
                    this.uacTable.handleDeleteResponse(response.data.successMap, response.data.errorMap)
                } else {
                    this.uacTable.addError(response.error);
                }
            })
            .catch(error => {
                this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
            });
    }

    handleLoad(event) {
        const rows = event.detail.rows;
        rows.forEach((row) => {
            this.checkConditionalRules(row);
        });
    }

    handleFieldChange(event) {

        const row = event.detail.row;

        // Handle conditional rules here
        this.checkConditionalRules(row);
    }
    // for validations
    checkConditionalRules(row) {
        row.fields.forEach((fld) => {
            switch (fld.name) {
                default:
                    break;
            }
        });
    }

    getMedicationRecords() {
        getMedicationList({
            assessmentRecordId: this.recordId
            })
            .then(response => {
                this.uacTable.records = response;
            })
            .catch(error => {
                this.showToastMessage('Error', reduceErrors(error).join('\n'), 'error');
            });
    }

    connectedCallback() {
        this.getMedicationRecords();
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }


    validate() {
        return {
            isValid: true
        };
    }
}