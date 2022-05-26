import { LightningElement, api,track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import getRelatedSponsorApps from "@salesforce/apex/UC_SponsorApplication.getRelatedSponsorApps";

// Columns to display for Sponsor Applications
const sponAppColums = [
    {
      label: "Entry ID", fieldName: "strEntryId",
      type: "url", typeAttributes: { label: { fieldName: "strEntryNumber" },tooltip:{ fieldName: "strEntryNumber" } },
      target: "_blank",wrapText: true
    },
    { label: "Role", fieldName: "strRole", type: "string",wrapText: true },
    {
        label: "UC Name", fieldName: "strUCId",
        type: "url", typeAttributes: { label: { fieldName: "strUCName" },tooltip:{ fieldName: "strUCName" } },
        target: "_blank",wrapText: true
    },
    { label: "Relationship to UC", fieldName: "strRelationshipToUC", type: "string",wrapText: true },
    { label: "ORR Decision", fieldName: "strORRDecision", type: "string",wrapText: true },
    {
        label: "Discharge Program", fieldName: "strDischargeProgramId",
        type: "url", typeAttributes: { label: { fieldName: "strDischargeProgramName" },tooltip:{ fieldName: "strDischargeProgramName" } },
        target: "_blank",wrapText: true
    }
]

export default class UcSponsorApplications extends LightningElement {
  // Variable declaration
  @api SponAppColums;
  @api recordId;
  @api isParentLoaded = false;
  @api disableViewAll;
  @track dataWrap = [];
  @api title = 'HHM & AACG Sponsor Applications';
  @api icon = 'standard:household';
  @track count = 0;
  @track showLoadingSpinner = false;
  @api isDataAvailable = false;

  connectedCallback() {
    // Calling the method
    this.getData();
  }
  
  // Method to call the server method
  getData() {
      console.log('Im here with teh recordID: '+this.recordId);
    this.dataWrap = [];
    this.count = 0;
    this.isParentLoaded = false;
    this.showLoadingSpinner = true;
    this.isDataAvailable = false;
    getRelatedSponsorApps({
      recordID: this.recordId
    })
      .then(result => {
        if (result !== undefined && result.lstSponAppRecords.length > 0) {          
          this.SponAppColums = sponAppColums;
          console.log('this.dataWrap 41: '+JSON.stringify(result.lstSponAppRecords));
          console.log('this.dataWrap 42: '+result.lstSponAppRecords);
          this.dataWrap = result.lstSponAppRecords;
          this.count = result.lstSponAppRecords.length;
          this.isParentLoaded = true;
          this.showLoadingSpinner = false;
          this.isDataAvailable = true;
        } else if (result !== undefined && result.lstSponAppRecords.length == 0) {
          this.isParentLoaded = true;
          this.showLoadingSpinner = false;
        } 
      })
      .catch(error => {
          console.log('error:'+error);
          console.log(error);
          this.showLoadingSpinner = false;
        const toastEvent = new ShowToastEvent({
          title: "Error Loading Sponsor Applications",
          message: error.message,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
  }

  handleRefresh(){
      this.getData();
  }
}