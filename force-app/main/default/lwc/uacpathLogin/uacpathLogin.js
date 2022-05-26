import { LightningElement, track, api, wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import uacpathLoginTextInt from '@salesforce/label/c.UAC_pathLoginTextInt';
import uacpathLoginTextExt from '@salesforce/label/c.UAC_pathLoginTextExt';
import myCommLogo from '@salesforce/resourceUrl/LoginCommunityLogo';
import myAcfLogo from '@salesforce/resourceUrl/ACFLogo';
import getRedirectionUrls from '@salesforce/apex/UAC_pathloginSSO.getRedirectionUrls';
import intUrl from '@salesforce/schema/UAC_loginSSOUrls__c.UAC_pathLoginInternalURL__c';
import extUrl from '@salesforce/schema/UAC_loginSSOUrls__c.UAC_pathLoginExternalURL__c';
export default class UAC_pathLogin extends LightningElement {
    @api text;
    @api styleText;
    @track
    buttonHelptextInt = uacpathLoginTextInt;
    @track
    buttonHelptextExt = uacpathLoginTextExt;
    @track
    intPathUrl;
    @track
    extPathUrl;
    @wire(getRedirectionUrls)
    getUrls({ error, data }) {
        if (data) {
            console.log('data here');
            this.intPathUrl = getSObjectValue(data, intUrl);
            this.extPathUrl = getSObjectValue(data, extUrl);
        }
        else if (error) {
            console.log('error here');
            console.log(error);
            console.log(JSON.stringify(error));
        }
    }
    commLogo = myCommLogo;
    acfLogo = myAcfLogo;
}