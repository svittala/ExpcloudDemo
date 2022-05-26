import createCaseTeamMember from '@salesforce/apex/UAC_caseTeamMemberHelper.createCaseTeamMember';
import deleteCaseTeamMember from '@salesforce/apex/UAC_caseTeamMemberHelper.deleteCaseTeamMember';
import getCaseTeamMembers from '@salesforce/apex/UAC_caseTeamMemberHelper.getCaseTeamMembers';
import getCaseTeamRoles from '@salesforce/apex/UAC_caseTeamMemberHelper.getCaseTeamRoles';
import UAC_caseTeamsConfirmDelete from '@salesforce/label/c.UAC_caseTeamsConfirmDelete';
import UAC_caseTeamsSuccessCreate from '@salesforce/label/c.UAC_caseTeamsSuccessCreate';
import UAC_caseTeamsSuccessDelete from '@salesforce/label/c.UAC_caseTeamsSuccessDelete';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {api, LightningElement, track} from 'lwc';

const actions = [{label: 'Delete', name: 'delete'}];
const LST_FIELD = [
  {
    label: 'Team Member',
    fieldName: 'strMemberURL',
    type: 'url',
    typeAttributes: {label: {fieldName: 'strMemberName'}, target: '_blank'}
  },
  {label: 'Member Role', fieldName: 'strRole', type: 'text', wrapText: true},
  {label: 'Entry Access', fieldName: 'strAccessLevel', type: 'text'},
  {type: 'action', typeAttributes: {rowActions: actions}}
];
export default class UacEntryTeamMemberRelatedList extends LightningElement {
  @api
  recordId;
  @track
  lstEntryTeamMembers;
  @track
  intNumberEntryTeamMembers = 0;
  @track
  isData = false;
  @track
  columns = LST_FIELD;
  lstCaseTeamRoles;
  @track
  lstRolePicklistValues;
  strErrorMessage = 'Please fill in all required fields.';
  strUserId;
  strCaseTeamRoleId;
  strTeamMemberIdToDelete;
  @track
  boolError = false;
  boolTrue = true;
  boolFalse = false;
  @track
  boolSavingRecord = false;
  strConfirmText = UAC_caseTeamsConfirmDelete;

  connectedCallback() {
    this.getTeamMembers();
    this.getTeamRoles();
  }
  renderedCallback() {
    this.setCardStyle();
  }
  onRefreshClick() {
    this.getTeamMembers();
  }
  onAddMemberClick() {
    this.boolSavingRecord = true;
    this.template.querySelector('[data-target-id="entry-team-member-modal-create"]').show();
  }
  onUserLookupLoad() {
    this.boolSavingRecord = false;
    console.log('LOADED');
  }
  handleSave() {
    if (this.strUserId && this.strCaseTeamRoleId) {
      this.boolError = false;
      this.createTeamMember();
    } else {
      this.boolError = true;
    }
  }
  handleCancelCreate() {
    this.template.querySelector('[data-target-id="entry-team-member-modal-create"]').hide();
  }
  handleCancelDelete() {
    this.strTeamMemberIdToDelete = null;
    this.template.querySelector('[data-target-id="entry-team-member-modal-delete"]').hide();
  }
  handleConfirmDelete() {
    this.deleteTeamMember(this.strTeamMemberIdToDelete);
  }
  handleUserLookupChange(event) {
    this.strUserId = event.target.value;
  }
  handleRoleChange(event) {
    this.strCaseTeamRoleId = event.target.value;
  }
  handleRowAction(event) {
    if (event.detail.action.name == 'delete' && !this.boolSavingRecord) {
      this.strTeamMemberIdToDelete = event.detail.row.idRecord;
      this.template.querySelector('[data-target-id="entry-team-member-modal-delete"]').show();
    }
  }
  getTeamMembers() {
    this.lstEntryTeamMembers = null;
    this.isData = false;
    getCaseTeamMembers({idCase: this.recordId})
        .then(result => {
          if (result && result.length) {
            this.intNumberEntryTeamMembers = result.length;
            this.lstEntryTeamMembers = result;
            if (this.intNumberEntryTeamMembers > 0) {
              this.isData = true;
            }
          } else {
            this.intNumberEntryTeamMembers = 0;
          }
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
        });
  }
  getTeamRoles() {
    getCaseTeamRoles()
        .then(result => {
          if (result) {
            this.lstCaseTeamRoles = result;
            this.setTeamRolePicklistValues();
          }
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
        });
  }
  setTeamRolePicklistValues() {
    let options = [];
    this.lstCaseTeamRoles.forEach(value => {
      options.push({label: value.Name, value: value.Id});
    });
    this.lstRolePicklistValues = options;
  }
  createTeamMember() {
    this.boolSavingRecord = true;
    createCaseTeamMember(
        {idCase: this.recordId, idUser: this.strUserId, idRole: this.strCaseTeamRoleId})
        .then(result => {
          console.log(result);
          if (result && result.success) {
            this.dispatchEvent(
                new ShowToastEvent({title: UAC_caseTeamsSuccessCreate, variant: 'success'}));
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
    deleteCaseTeamMember({idCaseTeamMember: idRecord, idCase: this.recordId })
        .then(result => {
          console.log(result);
          if (result && result.success) {
            this.dispatchEvent(
                new ShowToastEvent({title: UAC_caseTeamsSuccessDelete, variant: 'success'}));
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
    this.template.querySelector('[data-target-id="entry-team-member-related-list"]')
        .appendChild(elementStyle);
  }
}