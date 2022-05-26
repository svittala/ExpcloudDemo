import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import updateRelReq  from '@salesforce/apex/UAC_relReqSubmitController.updateRelReq';
import { getRecord , getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import Case_status from '@salesforce/schema/Case.Status';
import USER_PROFIL from '@salesforce/schema/Case.UAC_roleInReleaseRequest__c';
import Case_Id from '@salesforce/schema/Case.Id';
import Sponser_Cat from '@salesforce/schema/Case.UAC_sponsorCategory__c';
import ORR_Decision from '@salesforce/schema/Case.UAC_orrDecision__c';
import Remand_Info from '@salesforce/schema/Case.UAC_remandForFurtherInformation__c';
import Pending_Info from '@salesforce/schema/Case.UAC_pendingInformation__c';
import Waive_Info from '@salesforce/schema/Case.UAC_waiveThirdPartyReview__c';
import Court_Order from '@salesforce/schema/Case.UAC_courtOrderedRelease__c';
import Rel_Type from '@salesforce/schema/Case.UAC_typeOfRelease__c';
import Applicable_Cancellation from '@salesforce/schema/Case.UAC_ifApplicableCancellationReason__c';
import CaseManager_Recommendation from '@salesforce/schema/Case.UAC_caseManagerRecommendation__c';
import Home_Study from '@salesforce/schema/Case.UAC_homeStudyAddendum__c';
import ORRDecision_Home_Study from '@salesforce/schema/Case.UAC_orrDecisionHS__c';
import CaseManager_Recommendation_HS from '@salesforce/schema/Case.UAC_caseManagerRecommendationHS__c';
import CC_Recommendation_HS from '@salesforce/schema/Case.UAC_caseCoordinatorRecommendationHS__c';


export default class Uac_releaseRequestSubmit extends LightningElement {
    @api recordId;
    @track error;
    @track msg;
    @wire(getRecord , { recordId : '$recordId', fields : [CaseManager_Recommendation_HS,CC_Recommendation_HS,Case_status,ORRDecision_Home_Study,USER_PROFIL,Case_Id,Sponser_Cat,ORR_Decision,Remand_Info,Pending_Info,Waive_Info,Court_Order,Rel_Type,Applicable_Cancellation,CaseManager_Recommendation,Home_Study] })
    wiredCase;

    handleClick(event) {
        console.log('@@ submit button event');
        var data = this.wiredCase.data;
        if(data.fields.UAC_roleInReleaseRequest__c.value == 'None'){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Submit not allowed',
                    message: 'Case not assigned to you, Cannot Submit',
                    variant: 'error'
                })
            );
        }    
        else{
            console.log('@@ in else loop');
            console.log(data.fields.Status.value);
            console.log(data.fields.UAC_roleInReleaseRequest__c.value);
            console.log(data.fields.UAC_typeOfRelease__c.value);
            console.log(data.fields.UAC_orrDecision__c.value);
            const fields = {} ;
            const recordInput = { fields };
            fields[Case_Id.fieldApiName] = data.fields.Id.value;
            var SubmitRequest = false;
            if(data.fields.UAC_ifApplicableCancellationReason__c.value != null && (data.fields.UAC_roleInReleaseRequest__c.value == 'caseManager' 
            || data.fields.UAC_roleInReleaseRequest__c.value == 'leadCaseManager')){
                fields[Case_status.fieldApiName] = 'Inactive'; 
                SubmitRequest = true; 
                console.log('Cancellation Reason '+ Case_status +SubmitRequest);            
            }
            //ORRUAC-1433  AC-13.1
            else if(data.fields.Status.value == 'CM Initiated' && (data.fields.UAC_roleInReleaseRequest__c.value == 'caseManager' 
            || data.fields.UAC_roleInReleaseRequest__c.value == 'leadCaseManager')){
                fields[Case_status.fieldApiName] = 'CC Review'; 
                SubmitRequest = true; 
                console.log('CM initiate if' +SubmitRequest);            
            }
            else if(data.fields.Status.value == 'CM Initiated' && data.fields.UAC_waiveThirdPartyReview__c.value == 'Yes' && 
            ( data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor') && 
            data.fields.UAC_orrDecision__c.value != 'Approve Straight Release' && data.fields.UAC_orrDecision__c.value != 'Approve with Post-Release Only Services'){
                fields[Case_status.fieldApiName] = 'Completed'; 
                SubmitRequest = true;
                console.log('@@1');          
            }            
            else if(data.fields.Status.value == 'CC Review' && data.fields.UAC_pendingInformation__c.value == 'Yes' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseCoordinator' || data.fields.UAC_roleInReleaseRequest__c.value == 'directOperationsCoordinator')){
                SubmitRequest = true;
                fields[Case_status.fieldApiName] = 'CM to Provide Further Information';  
                console.log('@@2');              
            } 
            //ORRUAC-1433  AC-13.2
			else if(data.fields.Status.value == 'CC Review'  && data.fields.UAC_caseManagerRecommendation__c.value != null && (data.fields.UAC_roleInReleaseRequest__c.value == 'caseCoordinator' || data.fields.UAC_roleInReleaseRequest__c.value == 'directOperationsCoordinator')){
                fields[Case_status.fieldApiName] = 'FFS Review';    
                SubmitRequest = true; 
                console.log('CM initiate if' +SubmitRequest);            
            }           
            else if(data.fields.Status.value == 'CC Review' && (data.fields.UAC_roleInReleaseRequest__c.value == 'caseCoordinator'
            || data.fields.UAC_roleInReleaseRequest__c.value == 'directOperationsCoordinator')){
                fields[Case_status.fieldApiName] = 'FFS Review';                
                SubmitRequest = true;
                console.log('@@3');
            }
            //Modified based on ORRUAC-4216 AC 2.1 2.2
            else if((data.fields.Status.value == 'CC Review' || data.fields.Status.value == 'CM to Provide Further Information' || data.fields.Status.value == 'CM Initiated') 
            && data.fields.UAC_waiveThirdPartyReview__c.value == 'Yes' 
            && ( data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                if(data.fields.UAC_orrDecision__c.value == 'Approve Straight Release' || data.fields.UAC_orrDecision__c.value == 'Approve with Post-Release Only Services'){
                    fields[Case_status.fieldApiName] = 'DNF Generated';                    
                    SubmitRequest = true;
                    console.log('@@ORRUAC-4216_AC2.1');                    
                }
                else if(data.fields.UAC_orrDecision__c.value == 'Deny Release'){
                    fields[Case_status.fieldApiName] = 'Completed';
                    SubmitRequest = true;
                    console.log('@@ORRUAC-4216_AC2.2');                     
                }
            }
            // End ORRUAC-4216
            else if(data.fields.Status.value == 'CM to Provide Further Information' && data.fields.UAC_pendingInformation__c.value == 'Yes' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseManager' || data.fields.UAC_roleInReleaseRequest__c.value == 'leadCaseManager')){
                fields[Case_status.fieldApiName] = 'CC Review';
                //fields[Pending_Info.fieldApiName] = null;                    
                SubmitRequest = true;
                console.log(data.fields.UAC_pendingInformation__c.value);
                console.log('@@4');
            }
            else if(data.fields.Status.value == 'CM to Provide Further Information' && data.fields.UAC_remandForFurtherInformation__c.value == 'Yes' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseManager' || data.fields.UAC_roleInReleaseRequest__c.value == 'leadCaseManager')){
                fields[Case_status.fieldApiName] = 'FFS Review';
                //fields[Remand_Info.fieldApiName] = null;                  
                SubmitRequest = true;
                console.log('@@5');
            }
            else if(data.fields.Status.value == 'FFS Review' && data.fields.UAC_remandForFurtherInformation__c.value == 'Yes' &&
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseCoordinator' || data.fields.UAC_roleInReleaseRequest__c.value == 'directOperationsCoordinator')){
                fields[Case_status.fieldApiName] = 'CM to Provide Further Information';                
                SubmitRequest = true;
                console.log('@@6');
            }            
            else if(data.fields.Status.value == 'FFS Review'  &&
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                if(data.fields.UAC_sponsorCategory__c.value == 'Category 1' && data.fields.UAC_orrDecision__c.value == 'Deny Release'){
                    fields[Case_status.fieldApiName] = 'Case Consultation Process';                    
                    SubmitRequest = true;
                    console.log('@@7.1');
                }
                else if(data.fields.UAC_remandForFurtherInformation__c.value == 'Yes'){
                    fields[Case_status.fieldApiName] = 'CM to Provide Further Information';
                    SubmitRequest = true;
                }                 
                else if(data.fields.UAC_orrDecision__c.value == 'Approve Straight Release' || data.fields.UAC_orrDecision__c.value == 'Approve with Post-Release Only Services' ){
                    fields[Case_status.fieldApiName] = 'DNF Generated';                    
                    SubmitRequest = true;
                    console.log('@@10.1');
                }
                else if(data.fields.UAC_orrDecision__c.value == 'Conduct Home Study-TVPRA' || data.fields.UAC_orrDecision__c.value == 'Conduct Home Study-ORR Mandated' || data.fields.UAC_orrDecision__c.value == 'Conduct Home Study-Discretionary' ){
                    fields[Case_status.fieldApiName] = 'HS Requested';                    
                    SubmitRequest = true;
                    console.log('@@10.1');
                }                
                else{
                    fields[Case_status.fieldApiName] = 'Completed';                    
                    SubmitRequest = true;
                    console.log('@@7.2'); 
                }                
            }            
            else if(data.fields.Status.value == 'Case Consultation Process' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseCoordinator' || data.fields.UAC_roleInReleaseRequest__c.value == 'directOperationsCoordinator')){
                fields[Case_status.fieldApiName] = 'Completed';                
                SubmitRequest = true;
                console.log('@@8');
            }
            else if(data.fields.Status.value == 'ORR Initiated' && data.fields.UAC_typeOfRelease__c.value == 'Release to Program' &&
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor') && 
            (data.fields.UAC_orrDecision__c.value == 'Approve Straight Release' || data.fields.UAC_orrDecision__c.value == 'Approve with Post-Release Only Services')){
                fields[Case_status.fieldApiName] = 'DNF Generated';                
                SubmitRequest = true;
                console.log('@@12');
            }  
            else if(data.fields.Status.value == 'ORR Initiated' && data.fields.UAC_typeOfRelease__c.value == 'Release to Sponsor' &&
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor') &&
            (data.fields.UAC_orrDecision__c.value == 'Approve Straight Release' || data.fields.UAC_orrDecision__c.value == 'Approve with Post-Release Only Services')){
                fields[Case_status.fieldApiName] = 'DNF Generated';                
                SubmitRequest = true;
                console.log('@@13');
            }
            else if(data.fields.Status.value == 'ORR Initiated' && data.fields.UAC_sponsorCategory__c.value == 'Category 1' && data.fields.UAC_orrDecision__c.value == 'Deny Release' &&
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                fields[Case_status.fieldApiName] = 'Case Consultation Process';
                SubmitRequest = true;
                console.log('@@9');
            }            
            else if(data.fields.Status.value == 'ORR Initiated' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                fields[Case_status.fieldApiName] = 'Completed';                
                SubmitRequest = true;
                console.log('@@9');
            }           
            else if(data.fields.Status.value == 'Completed' &&
                    data.fields.UAC_orrDecision__c.value == 'Deny Release'
                    && data.fields.UAC_courtOrderedRelease__c.value == 'Yes' &&
                    (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                        fields[Case_status.fieldApiName] = 'DNF Generated';                
                        SubmitRequest = true;
                        console.log('@@11');
            }
            else if(data.fields.Status.value == 'HS Completed - FFS Review' &&
            data.fields.UAC_homeStudyAddendum__c.value == 'Yes' &&
            (data.fields.UAC_orrDecisionHS__c.value == '' ||
              data.fields.UAC_orrDecisionHS__c.value == null) && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                fields[Case_status.fieldApiName] = 'HS Requested';                
                SubmitRequest = true;
                console.log('@@12');
            }
            else if(data.fields.Status.value == 'HS Completed - FFS Review' &&
            (data.fields.UAC_orrDecisionHS__c.value == 'Approve with Post-Release Services-After ORR Mandated' ||
               data.fields.UAC_orrDecisionHS__c.value == 'Approve with Post-Release Services-After Discretionary' ||
               data.fields.UAC_orrDecisionHS__c.value == 'Approve with Post-Release Services-TVPRA' 
            ) && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                fields[Case_status.fieldApiName] = 'DNF Generated';                
                SubmitRequest = true;
                console.log('@@12');
            }      
            else if(data.fields.Status.value == 'HS Completed - FFS Review' &&
            data.fields.UAC_orrDecisionHS__c.value == 'Deny Release' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'ffs' || data.fields.UAC_roleInReleaseRequest__c.value == 'ffsSupervisor')){
                fields[Case_status.fieldApiName] = 'Completed';                
                SubmitRequest = true;
                console.log('@@12');
            }    
            else if(data.fields.Status.value == 'HS Requested' && 
            data.fields.UAC_roleInReleaseRequest__c.value == 'hSPRSPrimaryProvider'){
                fields[Case_status.fieldApiName] = 'HS Completed -CM Review';                
                SubmitRequest = true;
                console.log('@@12');
            }  
            else if(data.fields.Status.value == 'HS Completed -CM Review' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseManager' 
            || data.fields.UAC_roleInReleaseRequest__c.value == 'leadCaseManager') &&
            data.fields.UAC_caseManagerRecommendationHS__c.value != null){
                fields[Case_status.fieldApiName] = 'HS Completed - CC Review';                
                SubmitRequest = true;
                console.log('@@12');
            }  
            else if(data.fields.Status.value == 'HS Completed - CC Review' && 
            (data.fields.UAC_roleInReleaseRequest__c.value == 'caseCoordinator' || data.fields.UAC_roleInReleaseRequest__c.value == 'directOperationsCoordinator') &&
            data.fields.UAC_caseCoordinatorRecommendationHS__c.value != null){
                fields[Case_status.fieldApiName] = 'HS Completed - FFS Review';                
                SubmitRequest = true;
                console.log('@@12');
            }                                                            
            console.log('@@ submit request value');
            console.log(SubmitRequest);

            if(SubmitRequest == true){
                console.log('I am here');
                updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Release Request Submitted for Review',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {                   
                    if (Array.isArray(error.body)){
                        this.msg = error.body.map(e => e.message).join(',');
                        console.log('@@ array message');
                        console.log(this.msg);
                    }
                    else if(Array.isArray(error.body.output.errors)){
                        this.msg = error.body.output.errors.map(e => e.message).join(',');
                    }
                    else if(typeof error.body.message === 'string'){
                        this.msg = error.body.message;
                        console.log('@@ string message');
                        console.log(this.msg);
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: this.msg,
                            variant: 'error'
                        })
                    );
                });
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Conditions not met',
                        message: 'Release Request cannot be submitted',
                        variant: 'error'
                    })
                );
            }
        }    
        
    }    
    
}