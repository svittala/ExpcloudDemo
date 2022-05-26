import createAccountTeamMember from '@salesforce/apex/UAC_accountTeamMemberController.createAccountTeamMember';
import deleteAccountTeamMember from '@salesforce/apex/UAC_accountTeamMemberController.deleteAccountTeamMember';
import getAccountTeamMembers from '@salesforce/apex/UAC_accountTeamMemberController.getAccountTeamMembers';
import updateAccountTeamMember from '@salesforce/apex/UAC_accountTeamMemberController.updateAccountTeamMember';
import UAC_accountTeamsConfirmDelete from '@salesforce/label/c.UAC_accountTeamsConfirmDelete';
import UAC_accountTeamsSuccessCreate from '@salesforce/label/c.UAC_accountTeamsSuccessCreate';
import UAC_accountTeamsSuccessDelete from '@salesforce/label/c.UAC_accountTeamsSuccessDelete';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {api, LightningElement, track} from 'lwc';
import hasPermission from '@salesforce/customPermission/UC_altProfileforAddingATM'; //GR ORRUAC-5686 

const actions = [{label: 'Edit', name: 'edit'}, {label: 'Delete', name: 'delete'}];
const LST_FIELD = [
  {
    label: 'Team Member',
    fieldName: 'strMemberURL',
    type: 'url',
    typeAttributes: {label: {fieldName: 'strMemberName'}, target: '_blank'}
  },
  {label: 'Member Role', fieldName: 'strRole', type: 'text', wrapText: true},
  {label: 'Entity Access', fieldName: 'strAccAccessLevel', type: 'text'},
  {label: 'Entry Access', fieldName: 'strCaseAccessLevel', type: 'text'},
  {label: 'UC Access', fieldName: 'strContactAccessLevel', type: 'text'},
  {type: 'action', typeAttributes: {rowActions: actions}}
];
export default class UacEntityTeamMemberRelatedList extends LightningElement {
  @api
  recordId;
  cATMrecordId;
  @track
  lstEntityTeamMembers;
  @track
  intNumberEntityTeamMembers = 0;
  @track
  isData = false;
  @track
  columns = LST_FIELD;
  lstAccountTeamRoles;
  strErrorMessage = 'Please fill in all required fields.';
  strUserId;
  strAccountRole;
  strTeamMemberIdToDelete;
  @track
  boolError = false;
  boolTrue = true;
  boolFalse = false;
  @track
  boolSavingRecord = false;
  boolEditATM = false;
  strConfirmText = UAC_accountTeamsConfirmDelete;
  @track
  optionsAccount = [
      { label: 'Read Only', value: 'Read' },
      { label: 'Read/Write', value: 'Edit' }
  ];
  @track
  optionsChildObjects = [
      { label: 'Read Only', value: 'Read' },
      { label: 'Read/Write', value: 'Edit' },
      { label: 'No Access', value: 'None' },
  ];
  strAccountAccessDefault = 'Read';
  strCaseAccessDefault = 'Read';
  strContactAccessDefault = 'Read';
  strAccountAccessValue = this.strAccountAccessDefault;
  strCaseAccessValue = this.strCaseAccessDefault;
  strContactAccessValue = this.strContactAccessDefault;
  onLoadATM;
  onSelectATM;

  connectedCallback() {
    this.getTeamMembers();
  }
  renderedCallback() {
    this.setCardStyle();
  }
  onRefreshClick() {
    this.getTeamMembers();
  }
  onAddMemberClick() {
    this.boolSavingRecord = true;
    this.template.querySelector('[data-target-id="entity-team-member-modal-create"]').show();
    if (hasPermission) {  
      this.alternateProfiles = true;
    }  // GR ORRUAC-5686 
  }
  onUserLookupLoad() {
    this.boolSavingRecord = false;
  }
  onAccountAccessLevelChange(event) {
    this.strAccountAccessValue = event.target.value;
  }
  onContactAccessLevelChange(event) {
    this.strContactAccessValue = event.target.value;
  }
  onCaseAccessLevelChange(event) {
    this.strCaseAccessValue = event.target.value;
  }
  editATMRolechange(event) {
    this.onSelectATM.strATMRole = event.target.value;
  }
  editATMAccountAccess(event) {
    this.onSelectATM.strAccAccess = event.target.value;
  }
  editATMCaseAccess(event) {
    this.onSelectATM.strCaseAccess = event.target.value;
  }
  editATMContactAccess(event) {
    this.onSelectATM.strConAccess = event.target.value;
  }
  handleSave() {
    if (this.strUserId && this.strAccountRole) {
      this.boolError = false;
      this.createTeamMember();
    } else {
      this.boolError = true;
    }
  }
  handleClickUpdate() {
    if (this.onSelectATM.strATMRole) {
      this.boolError = false;
      this.updateTeamMember();
    } else {
      this.boolError = true;
    }
  }
  handleCancelCreate() {
    this.template.querySelector('[data-target-id="entity-team-member-modal-create"]').hide();
    this.template.querySelector('[data-target-id="entity-team-member-modal-edit"]').hide();
  }
  handleCancelDelete() {
    this.strTeamMemberIdToDelete = null;
    this.template.querySelector('[data-target-id="entity-team-member-modal-delete"]').hide();
  }
  handleConfirmDelete() {
    this.deleteTeamMember(this.strTeamMemberIdToDelete);
  }
  handleUserLookupChange(event) {
    this.strUserId = event.target.value;
  }
  handleRoleChange(event) {
    this.strAccountRole = event.target.value;
  }
  handleRowAction(event) {
    if (event.detail.action.name == 'delete' && !this.boolSavingRecord) {
      this.strTeamMemberIdToDelete = event.detail.row.idRecord;
      this.template.querySelector('[data-target-id="entity-team-member-modal-delete"]').show();
    }
    if (event.detail.action.name == 'edit') {
      this.cATMrecordId = event.detail.row.idRecord;
      this.getATMrecord(this.cATMrecordId);
    }
  }

  getATMrecord(currentATMRecordId) {
    this.template.querySelector('[data-target-id="entity-team-member-modal-edit"]').show();
    this.onSelectATM = {
      strATMRole: this.onLoadATM.get(currentATMRecordId).aTMRole,
      strAccAccess: this.onLoadATM.get(currentATMRecordId).account == 'Read/Write'
          ? 'Edit'
          : this.onLoadATM.get(currentATMRecordId).account,
      strCaseAccess: this.onLoadATM.get(currentATMRecordId).case == 'Read/Write'
          ? 'Edit'
          : this.onLoadATM.get(currentATMRecordId).case,
      strConAccess: this.onLoadATM.get(currentATMRecordId).contact == 'Read/Write'
          ? 'Edit'
          : this.onLoadATM.get(currentATMRecordId).contact,
    };

    if (this.onSelectATM) {
      this.boolEditATM = true;
    } else {
      this.boolEditATM = false;
    }
  }

  getTeamMembers() {
    this.lstEntityTeamMembers = null;
    this.isData = false;
    getAccountTeamMembers({idAccount: this.recordId})
        .then(result => {
          if (result && result.length) {
            this.intNumberEntityTeamMembers = result.length;
            this.lstEntityTeamMembers = result;
            if (this.intNumberEntityTeamMembers > 0) {
              this.isData = true;
              let ATMMap = new Map()
              result.forEach(myFunction);
              function myFunction(item, index) {
                ATMMap.set(item.idRecord, {
                  aTMRole: item.strRole,
                  account: item.strAccAccessLevel,
                  case: item.strCaseAccessLevel,
                  contact: item.strContactAccessLevel
                })
              }
              this.onLoadATM = ATMMap;
            }
          } else {
            this.intNumberEntityTeamMembers = 0;
          }
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
        });
  }
  createTeamMember() {
    this.boolError = false;
    this.boolSavingRecord = true;
    if(!this.strUserId || !this.strAccountRole || !this.strAccountAccessValue || !this.strCaseAccessValue || !this.strContactAccessValue) {
      this.boolError = true;
      this.boolSavingRecord = false;
      return;
    }
    createAccountTeamMember(
      {idAccount: this.recordId,
      idUser: this.strUserId,
      strRole: this.strAccountRole,
      strAccAccessLevel: this.strAccountAccessValue,
      strCaseAccessLevel: this.strCaseAccessValue,
      strContactAccessLevel: this.strContactAccessValue})
        .then(result => {
          if (result && result.success) {
            this.dispatchEvent(
                new ShowToastEvent({title: UAC_accountTeamsSuccessCreate, variant: 'success'}));
            this.handleCancelCreate();
            this.getTeamMembers();
          } else {
            this.dispatchEvent(
                new ShowToastEvent({title: 'Error', message: result.message, variant: 'error'}));
          }
          this.boolSavingRecord = false;
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
          this.boolSavingRecord = false;
        });
  }
  updateTeamMember() {
    this.boolError = false;
    this.boolSavingRecord = true;
    if (!this.onSelectATM.strATMRole || !this.onSelectATM.strAccAccess
        || !this.onSelectATM.strCaseAccess || !this.onSelectATM.strConAccess) {
      this.boolError = true;
      this.boolSavingRecord = false;
      return;
    }
    updateAccountTeamMember({
      idATMRecord: this.cATMrecordId,
      idAccount: this.recordId,
      strRole: this.onSelectATM.strATMRole,
      strAccAccessLevel: this.onSelectATM.strAccAccess,
      strCaseAccessLevel: this.onSelectATM.strCaseAccess,
      strContactAccessLevel: this.onSelectATM.strConAccess
    })
        .then(result => {
          if (result && result.success) {
            this.dispatchEvent(
                new ShowToastEvent({title: UAC_accountTeamsSuccessCreate, variant: 'success'}));
            this.handleCancelCreate();
            this.getTeamMembers();
          } else {
            this.dispatchEvent(
                new ShowToastEvent({title: 'Error', message: result.message, variant: 'error'}));
          }
          this.boolSavingRecord = false;
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
          this.boolSavingRecord = false;
        });
  }
  deleteTeamMember(idRecord) {
    this.boolSavingRecord = true;
    deleteAccountTeamMember({idAccountTeamMember: idRecord})
        .then(result => {
          if (result && result.success) {
            this.dispatchEvent(
                new ShowToastEvent({title: UAC_accountTeamsSuccessDelete, variant: 'success'}));
            this.handleCancelDelete();
            this.getTeamMembers();
          } else {
            this.dispatchEvent(
                new ShowToastEvent({title: 'Error', message: result.message, variant: 'error'}));
          }
          this.boolSavingRecord = false;
          this.strTeamMemberIdToDelete = null;
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
          this.boolSavingRecord = false;
          this.strTeamMemberIdToDelete = null;
        });
  }
  setCardStyle() {
    let strSelectorStartHeader = '.uac-related-list article header {';
    let strSelectorStartBody = '.uac-related-list article div {';
    let strSelectorStartButton = '.uac-button button {';
    let strSelectorStartModal =
        '.uac-modal .slds-modal .slds-modal__container .slds-modal__content {';
    let strStyleText =
        'background-color: #f3f2f2 !important; border-bottom: 1px solid #dddbda; font-weight: 700 !important; font-size: 14px !important; ';
    let strStyleFormatting =
        'padding: 10px !important; margin-bottom: 0px !important; border-radius: 5px 5px 0px 0px !important; margin-bottom: 0px !important;';
    let strStyleMargin = 'margin-top: 0px !important;';
    let strStyleBackground = 'background-color: #fff !important;';
    let strStyleModal = 'overflow: initial;';
    let strSelectorStop = '}';
    let elementStyle = document.createElement('style');
    elementStyle.innerText = strSelectorStartHeader + strStyleText + strStyleFormatting
        + strSelectorStop + strSelectorStartBody + strStyleMargin + strSelectorStop
        + strSelectorStartButton + strStyleBackground + strSelectorStop + strSelectorStartModal
        + strStyleModal + strSelectorStop;
    this.template.querySelector('[data-target-id="entity-team-member-related-list"]')
        .appendChild(elementStyle);
  }
}