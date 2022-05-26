import { LightningElement, track } from 'lwc';
import myCommLogo from '@salesforce/resourceUrl/LoginCommunityLogo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFile from '@salesforce/apex/UAC_arfFileUploadController.saveFile';
import validateEmail from '@salesforce/apex/UAC_arfFileUploadController.validateEmail';
export default class Uac_complTrainForm extends LightningElement {
    @track firstName;
    @track lastName;
    @track email;
    @track formtype;
    @track formtypeSelected = false;
    @track submitting = false;
    @track unsubmitted = true;
    @track uploaded = false;
    @track validateSection = 'slds-hide';
    @track readOnly = false;
    @track disableCategory = true;
    @track errorMessage;
    @track error = false;
    @track filecount = 0;
    @track documentId;
    commLogo = myCommLogo;
    @track arfRecordId;
    @track fileName = '';
    @track UploadFile = 'Submit';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 3000000;

    get typeOptions(){
        return [
            { label: 'Privacy 101', value: 'Privacy 101' },
            { label: 'ROB', value: 'ROB' },
            { label: 'Cybersecurity', value: 'Cybersecurity' },
        ]
    }   
    onTypeChange(event){
        this.resetErrors();
        this.formtype = event.detail.value;
        this.UploadFile = 'Submit';
        this.isTrue = false;
        this.fileName = '';
        this.formtypeSelected = true;
    }
    onFirstNameChange(event){
        this.resetErrors();
        this.firstName = event.target.value;
    }
    onLastNameChange(event){
        this.resetErrors();
        this.lastName = event.target.value;
    }
    onEmailChange(event){
        this.resetErrors();
        this.email = event.target.value;
        console.log('Email:'+ this.email);
    }
    cancel(){
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.formtype = '';
        this.readOnly = false;
        this.validateSection = 'slds-hide';
        this.UploadFile = 'Upload File';
        this.fileName = '';
        this.isTrue = false;
        this.formtypeSelected = false;
        this.resetErrors();
    }
    resubmit(){
        window.location.reload();
    }    

    isValid(){
        if (this.firstName && this.lastName && this.email){
          return true;
        } 
        else {
          return false;
        }
    }
    resetErrors(){
        this.errorMessage = '';
        this.error = false;
    } 
    
    validate(){
        if(!this.isValid()){
            this.error = true;
            this.errorMessage = 'Please fill in all required fields before validating.'
        }
        else{
        validateEmail({email: this.email })
        .then(response => {
            if (response !== null) {
                this.validateSection = 'slds-show';
                this.readOnly = true;
                this.arfRecordId = response;
            } else {
                this.error = true;
                this.errorMessage = 'Please enter the accurate email address as it exists in the system. Please contact the UC Administrator if needed.';
            }
          })
        }
    }

    // getting file 
    handleFilesChange(event) {
        this.error = false;
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        if(!this.formtype){
            this.error = true;
            this.errorMessage = 'Please fill in all required fields before submitting.'
        }
        else{
            if(this.filesUploaded.length > 0) {
                this.uploadHelper();
            }
            else {
                this.fileName = 'Please select file to upload!!';
            }
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
       if (this.file.size > this.MAX_FILE_SIZE) {
            this.errorMessage = 'File Size cannot exceed 3MB.';
            this.error = true;
            return ;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader= new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            
            this.saveToFile();
        });
    
        this.fileReader.readAsDataURL(this.file);
    }

    // Calling apex class to insert the file
    saveToFile() {
        saveFile({ idParent: this.arfRecordId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents), formType: this.formtype})
        .then(result => {
            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.UploadFile = 'File Uploaded Successfully';
            this.isTrue = true;
            this.showLoadingSpinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.file.name + ' - Uploaded Successfully!!!',
                    variant: 'success',
                }),
            );

        })
        .catch(error => {
            this.error = true;
            this.errorMessage = 'Failed to attach to Account Request Form, please contact UC Administrator.';
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File,please contact UC Administrator.',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
}