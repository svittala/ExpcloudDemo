import { LightningElement, api, wire } from 'lwc';
import UAC_referralAssessment__c from '@salesforce/schema/UAC_referralAssessment__c';
import UAC_uacProfileName__c from '@salesforce/schema/UAC_referralAssessment__c.UAC_uacProfileName__c'
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const FIELDS = [
    'UAC_referralAssessment__c.UAC_uacProfileName__c',
];

export default class WireGetRecordDynamicContact extends LightningElement {

    @api recordId;

    // @wire(getRecord, { recordId: '$recordId', fields: [UAC_uacProfileName__c] })
    //assessment;


    clickedButtonLabel;

    handleClick(event) {

        /* fetch('http://uacdev.apincloud.com/')
             .then(res => res.json())
             .then(data => {
                 // do something with data
             })
             .catch(rejected => {
                 console.log(rejected);
             });
 */
        fetch(
            'http://uacdev.apincloud.com/',
            {
                method: "POST",
                body: JSON.stringify({
                    "path": [
                        "CaseStatus.aspx"
                    ],
                    "query": [
                        {
                            "key": "UAC_ID",
                            "value": "1121"
                        },
                        {
                            "key": "UAC_PROGRAM_ID",
                            "value": "783830"
                        }
                    ]
                }),
                credentials: "include",
                headers: {
                    contentType: "application/json"
                }
            }
        )
    }
}