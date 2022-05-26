import getCallLogTaskRecordId from '@salesforce/apex/UAC_callLogContactList.getCallLogTaskRecordIdandPrimeLan';
import callLogContactListController from '@salesforce/apex/UAC_callLogContactList.getContactList';
import LBL_Authorized_Contact_List from '@salesforce/label/c.UAC_AuthorizedContactList';
import LBL_Restricted_Contact_List from '@salesforce/label/c.UAC_RestrictedContactList';
import APPREHEN_RELATION_OBJECT from '@salesforce/schema/UAC_apprehendedRelationship__c';
import {NavigationMixin} from 'lightning/navigation';
import {encodeDefaultFieldValues} from 'lightning/pageReferenceUtils';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {api, LightningElement, track, wire} from 'lwc';

const actions = [{label: 'Log a Call', name: 'Log_a_call'}];
const FIELDS_CONTACT = ['Contact.UAC_primaryLanguageSpoken__c'];

const columnsAuthorized = [
  {
    label: 'Contact Name',
    fieldName: 'urlLink',
    type: 'url',
    typeAttributes: {label: {fieldName: 'contactName'}, target: '_blank'},
    sortable: true,
  },
  {
    label: 'Relationship to UC',
    fieldName: 'UAC_relationshipToUAC__c',
    type: 'text',
    sortable: true,
  },
  {
    label: 'Proof of Relationship',
    fieldName: 'UAC_proofOfRelationship__c',
    type: 'text',
    sortable: true,
  },
  {
    label: 'Phone Number',
    fieldName: 'UAC_phone__c',
    type: 'phone',
    sortable: true,
  },
  {
    label: 'Contact Approved Date',
    fieldName: 'UAC_contactApprovedDate__c',
    type: 'date',
    sortable: true,
  },
  {
    type: 'action',
    typeAttributes: {rowActions: actions},
  },
];

const columnsRestricted = [
  {
    label: 'Contact Name',
    fieldName: 'urlLink',
    type: 'url',
    typeAttributes: {label: {fieldName: 'contactName'}, target: '_blank'},
    sortable: true,
  },
  {
    label: 'Phone Number',
    fieldName: 'UAC_phone__c',
    type: 'phone',
    sortable: true,
  },
  {
    label: 'Contact Restricted Date',
    fieldName: 'UAC_contactRestrictedDate__c',
    type: 'date',
    sortable: true,
  },
  {
    type: 'action',
    typeAttributes: {rowActions: actions},
  },
];

export default class UacAuthorizedContactList extends NavigationMixin
(LightningElement) {
  LBLauthorizedTableTitle = LBL_Authorized_Contact_List;
  LBLrestrictedTableTitle = LBL_Restricted_Contact_List;

  @api
  recordId;
  @track
  authorizedContactdata = [];
  @track
  RestrictedContactdata = [];
  @track
  ChangeData = [];

  columnsAuthorized = columnsAuthorized;
  columnsRestricted = columnsRestricted;
  authorizedContactLength = 0;
  RestrictedContactLength = 0;
  sortedDirectionRestricted;
  sortedDirectionAuthorized;
  sortedBy;
  str_Authorized = 'Authorized';
  isLoading = false;


  connectedCallback() {
    this.getCallLogList();
  }

  @wire(getObjectInfo, {objectApiName: APPREHEN_RELATION_OBJECT})
  objectInfoApprehendedR;


  get ApprehendedrecordTypeId() {
    // Returns a map of record type Ids
    let rtis = this.objectInfoApprehendedR.data.recordTypeInfos;
    return Object.keys(rtis).find(rti => rtis[rti].name === 'Family Friend');
  }

  // Refresh button
  onRefreshClick() {
    this.getCallLogList();
  }

  // Calling imperative apex which returns List of Apprehended and AdultContact
  getCallLogList() {
    this.isLoading = true;
    callLogContactListController({UACId: this.recordId})
        .then(result => {
          if (result && result.length) {
            this.ChangeData = result.map(row => {

              return {
                contactName: row.UAC_contactFullName__c, urlLink: `/${row.Id}`,
                    UAC_relationshipToUAC__c: row.UAC_relationshipToUAC__c,
                    UAC_proofOfRelationship__c: row.UAC_proofOfRelationship__c,
                    UAC_phone__c: row.UAC_phone__c,
                    UAC_contactApprovedDate__c: row.UAC_contactApprovedDate__c,
                    UAC_contactRestrictedDate__c: row.UAC_contactRestrictedDate__c,
                    UAC_contactType__c: row.UAC_contactType__c, Id: row.Id, row
              }
            });

            if (result.length > 0) {
              const AuthData = [];
              const RestData = [];
              // separates Authorized and Restricted Records
              this.ChangeData.forEach(element => {
                if (element.UAC_contactType__c == 'Authorized') {
                  AuthData.push(element);
                } else {
                  RestData.push(element);
                }
              });
              this.authorizedContactdata = AuthData;
              this.RestrictedContactdata = RestData;
              
            }

            if (this.authorizedContactdata.length > 0) {
              this.authorizedContactLength = this.authorizedContactdata.length;
            } else {
              this.authorizedContactLength = 0;
            }

            if (this.RestrictedContactdata.length > 0) {
              this.RestrictedContactLength = this.RestrictedContactdata.length;
            } else {
              this.RestrictedContactLength = 0;
            }

          } else {
            this.authorizedContactLength = 0;
            this.RestrictedContactLength = 0;
          }
          this.isLoading = false;
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
          this.isLoading = false;
        });
  }

  // Row level action to create Log a call
  handleRowAction(event) {
    let actionName = event.detail.action.name;
    let row = event.detail.row;
    console.log('action and Row: ', actionName, row);
    switch (actionName) {
      case 'View_Record':
        this.navigateToRecordViewPage(row.Id);
        break;
      case 'Log_a_call':
        this.logAcall(row.Id);
        break;
    }
  }


  onClickFamilyFriend(event) {
    let buttonName = event.target.dataset.name;
    switch (buttonName) {
      case 'newAuthorized':
        this.createFamilyFriends('Authorized');
        break;
      case 'newRestricted':
        this.createFamilyFriends('Restricted');
        break;
    }
  }

  navigateToRecordViewPage(currentRecordId) {
    // View a custom object record.
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {recordId: currentRecordId, actionName: 'view'}
    });
  }

  // Pre-population of field to create a Log a Call
  logAcall(WhatId) {
    let callLogRTId;
    getCallLogTaskRecordId({recordId: this.recordId})
        .then(result => {
          console.log('contact data : ', JSON.stringify(result));
          callLogRTId = result.TaskCallLogRecordId;

          let primaryLanuguage = '';

          if (result.strPrimaryLanguageSpoken) {
            primaryLanuguage = result.strPrimaryLanguageSpoken;
          }
          console.log('Prime:', primaryLanuguage)
          let defaultValues = encodeDefaultFieldValues(
              {WhoId: this.recordId, WhatId: WhatId, UAC_primaryLanguage__c: primaryLanuguage});

          this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {objectApiName: 'Task', actionName: 'new'},
            state: {
              defaultFieldValues: defaultValues,
              recordTypeId: callLogRTId,
              navigationLocation: 'RELATED_LIST'
            }
          });
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
        });
  }

  // creates new Contact (Apprehended-Family and Friends)
  createFamilyFriends(status) {
    let defaultValues = encodeDefaultFieldValues({
      UAC_uacLookup__c: this.recordId,
      UAC_contactType__c: status,
    });

    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {objectApiName: 'UAC_apprehendedRelationship__c', actionName: 'new'},
      state: {
        defaultFieldValues: defaultValues,
        recordTypeId: this.ApprehendedrecordTypeId,
        navigationLocation: 'RELATED_LIST'
      }
    });
  }

  // sorting for Authorized Contacts
  onHandleSortAuthorized(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirectionAuthorized = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortedDirectionAuthorized, this.str_Authorized);
  }

  // sorting for restricted Contacts
  onHandleSortRestricted(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirectionRestricted = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortedDirectionRestricted, '');
  }

  sortData(fieldName, sortDirection, typeOfDataTable) {
    var sortedData = typeOfDataTable === this.str_Authorized
        ? JSON.parse(JSON.stringify(this.authorizedContactdata))
        : JSON.parse(JSON.stringify(this.RestrictedContactdata));

    // function to return the value stored in the field
    let key = (a) => a[fieldName];
    var reverse = sortDirection === 'asc' ? 1 : -1;
    sortedData.sort((a, b) => {
      let valueA = key(a) ? key(a).toLowerCase() : '';
      let valueB = key(b) ? key(b).toLowerCase() : '';
      return reverse * ((valueA > valueB) - (valueB > valueA));
    });

    // set sorted data to data list
    if (typeOfDataTable === this.str_Authorized) {
      this.authorizedContactdata = sortedData
    } else {
      this.RestrictedContactdata = sortedData;
    }
  }
}