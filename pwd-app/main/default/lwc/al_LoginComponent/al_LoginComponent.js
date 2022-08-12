import { LightningElement, track} from 'lwc';
import doFindContact from '@salesforce/apex/al_authController.findContact';
import doFindUser from '@salesforce/apex/al_authController.findUser';
import doEmailVerification from '@salesforce/apex/al_authController.verifyEmail';
import doPWLLogin from '@salesforce/apex/al_authController.passwordLessLogin';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class CommunityLoginComponent extends NavigationMixin(LightningElement) {
    email;
    contactId;
    userId;
    url;
    @track isDisovery = false;
    @track errorCheck;
    @track errorMessage;
    @track communityName ='Identity';

    connectedCallback(){
    }

    handleEmailChange(event){
        this.email = event.target.value;
    }
    handleDiscovery(event){
        this.isDisovery = true;
        console.log('got discovery');
    }
    handleEmail(event){
        if(this.email){
            event.preventDefault();
            doFindContact({ email: this.email})
            .then((result) => {
                //console.log(result);
                this.contactId = result;
                this.callFindUser();
            })
            .catch((error) => {
                this.error = error;      
                this.errorCheck = true;
                this.errorMessage = error.body.message;
                //console.log(this.errorMessage);
            });
        }
    }
     
    callFindUser(){
        if(this.contactId){
            doFindUser({contactId: this.contactId})
            .then((result) => {
                //console.log(result);
                this.userId = result;
                this.callValidateEmail();
            })
            .catch((error) => {
                this.error = error;      
                this.errorCheck = true;
                this.errorMessage = error.body.message;
                //console.log(this.errorMessage);
            });
        }
    }

    callValidateEmail(){
        if(this.userId){
            doEmailVerification({userId: this.userId})
            .then((result) => {
                //console.log(result);
                if (result == true) {
                    this.callPWLLogin();
                }
                else {
                    this.navigateToStartUrl();
                }
            })
            .catch((error) => {
                this.error = error;      
                this.errorCheck = true;
                this.errorMessage = error.body.message;
                this.navigateToStartUrl();
                //console.log(this.errorMessage);
            });
        }
    }

    callPWLLogin(){
        if(this.userId){
            doPWLLogin({ userId: this.userId})
            .then((result) => {
                //console.log(result);
                this.url = result;
                this.navigateToCompletionUrl();
            })
            .catch((error) => {
                this.error = error;      
                this.errorCheck = true;
                this.errorMessage = error.body.message;
            });
        }
    }

    navigateToCompletionUrl() { 
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.url
            }
        })
	}

    navigateToStartUrl() { 
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login'
            }
        })
	}
}