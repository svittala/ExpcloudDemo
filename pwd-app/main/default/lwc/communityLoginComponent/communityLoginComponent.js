import { LightningElement, track} from 'lwc';
import doFindContact from '@salesforce/apex/CommunityAuthController.findContact';
import doFindUser from '@salesforce/apex/CommunityAuthController.findUser';
import doEmailVerification from '@salesforce/apex/CommunityAuthController.verifyEmail';
import doPWLLogin from '@salesforce/apex/CommunityAuthController.passwordLessLogin';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class CommunityLoginComponent extends NavigationMixin(LightningElement) {
    email;
    contactId;
    userId;
    url;
    @track errorCheck;
    @track errorMessage;
    @track communityName ='Identity';

    connectedCallback(){
    }

    handleEmailChange(event){
        this.email = event.target.value;
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