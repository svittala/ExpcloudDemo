import { LightningElement, track, api, wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import uacpathLoginTextExt from '@salesforce/label/c.UAC_pathLogoutTextExt';
import uacpathLoginTextDhs from '@salesforce/label/c.UAC_pathLogoutTextDhs';
import uacpathLoginVerbDhs from '@salesforce/label/c.UAC_pathLoginVerbDhs';
import uacpathLoginVerbExt from '@salesforce/label/c.UAC_pathLoginVerbExt';
import loginButtonName from '@salesforce/label/c.UAC_pathLoginButtonName';
import myCommLogo from '@salesforce/resourceUrl/LoginCommunityLogo';
import myAcfLogo from '@salesforce/resourceUrl/ACFLogo';
import getRedirectionUrls from '@salesforce/apex/UAC_pathloginSSO.getRedirectionUrls';
import extUrl from '@salesforce/schema/UAC_loginSSOUrls__c.UAC_pathLoginExternalURL__c';
import dhsUrl from '@salesforce/schema/UAC_loginSSOUrls__c.UC_pathLoginCommunityURL__c';
export default class UAC_pathLogin extends LightningElement {
    @api text;
    @api styleText;
    @track
    buttonHelptextDhs = uacpathLoginTextDhs;
    @track
    buttonHelptextExt = uacpathLoginTextExt;
    @track
    buttonNameDhs = uacpathLoginVerbDhs;
    @track
    buttonNameExt = uacpathLoginVerbExt;
    @track
    buttonName=loginButtonName;
    @track
    dhsPathUrl;
    @track
    extPathUrl;    
    @wire(getRedirectionUrls) 
    getUrls({ error, data }){
        if(data){
            console.log('data here');
            this.extPathUrl = getSObjectValue(data, extUrl);
            this.dhsPathUrl = getSObjectValue(data, dhsUrl);
        }
        else if(error){
            console.log('error here');
            console.log(error);
            console.log(JSON.stringify(error));
        }
    }   
    commLogo = myCommLogo;
    acfLogo = myAcfLogo;
}