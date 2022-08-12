import { LightningElement, track, api, wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import uacpathLoginTextExt from '@salesforce/label/c.UAC_dhsLoginText';
import myCommLogo from '@salesforce/resourceUrl/LoginCommunityLogo';
import myAcfLogo from '@salesforce/resourceUrl/ACFLogo';
import getRedirectionUrls from '@salesforce/apex/UAC_pathloginSSO.getRedirectionUrls';
import extUrl from '@salesforce/schema/UAC_loginSSOUrls__c.UC_pathLoginCommunityURL__c';
import intUrl from '@salesforce/schema/UAC_loginSSOUrls__c.UAC_pathLoginInternalURL__c';
import portURL from '@salesforce/schema/UAC_loginSSOUrls__c.UC_loginPortalURL__c';


export default class UAC_pathLogin extends LightningElement {
    @api text;
    @api styleText;
    @track buttonHelptextExt = uacpathLoginTextExt;
    @track extPathUrl;
    @track intPathUrl;
    @track portalURL
    @wire(getRedirectionUrls)
    getUrls({ error, data }) {
        if (data) {
            console.log('data here');
            this.intPathUrl = getSObjectValue(data, intUrl);
            this.extPathUrl = getSObjectValue(data, extUrl);
            this.portalURL = "https://uacdev2.apincloud.com/";

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