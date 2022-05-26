import getChecklistItems from '@salesforce/apex/UC_visualChecklistService.getChecklistItems';
import getRecordStatus from '@salesforce/apex/UC_visualChecklistService.getRecordStatus';
import updateChecklistItem from '@salesforce/apex/UC_visualChecklistService.updateChecklistItem';
import UC_visualChecklistIcons from '@salesforce/resourceUrl/UC_visualChecklistIcons';
import {api, LightningElement, track} from 'lwc';

export default class UcVisualChecklist extends LightningElement {
  successUrl = UC_visualChecklistIcons + '/ActionIcons/Complete.png';
  progressOverdueUrl = UC_visualChecklistIcons + '/ActionIcons/ProgressOverdue.png';
  progressUrl = UC_visualChecklistIcons + '/ActionIcons/Progress.png';
  notStartedUrl = UC_visualChecklistIcons + '/ActionIcons/New.png';
  overdueUrl = UC_visualChecklistIcons + '/ActionIcons/Overdue.png';
  @api
  recordId;
  @api
  componentLabel = 'Task Checklist';
  error;
  @api
  configuration;
  formChecklistItem;
  formEditMode = false;
  @track
  checklistData = [];
  loading;
  statusChanged = false;
  lockEditing;

  picklistValues = [
    {label: 'Not Started', value: 'Not Started'},
    {label: 'In Progress', value: 'In Progress'},
    {label: 'Completed', value: 'Completed'}
  ];

  connectedCallback() {
    this.refreshData();
  }
  refreshData() {
    if (this.checklistData.length > 0) {
      this.checklistData = [];
    }
    this.formEditMode = false;
    this.statusChanged = false;
    this.loading = true;
    getChecklistItems({strConfiguration: this.configuration, recordId: this.recordId})
        .then(result => {
          if (result.success) {
            this.checklistData = this.parseData(result.data);
            this.loading = false;
          }
        })
        .catch(error => {
          console.log('Error');
          console.log(error);
          this.error = error;
        });
    getRecordStatus({strConfiguration: this.configuration, recordId: this.recordId})
        .then(result => {
          console.log('Result from getRecordStatus');
          console.log(result);
          this.lockEditing = result;
        })
        .catch(error => {
          console.log('Error');
          console.log(error);
          this.error = error;
        });
  }
  parseData(data) {
    let returnArray = [];
    for (let i = 0; i < data.length; i++) {
      console.log('For item');
      console.log(data[i]);
      if (data[i].icon) {
        if (data[i].icon == 'Completed') {
          data[i].iconImage = this.successUrl;
        } else if (data[i].icon == 'Overdue' && data[i].status == 'In Progress') {
          data[i].iconImage = this.progressOverdueUrl;
        } else if (data[i].icon == 'Overdue') {
          data[i].iconImage = this.overdueUrl;
        } else if (data[i].icon == 'In Progress') {
          data[i].iconImage = this.progressUrl;
        } else {
          data[i].iconImage = this.notStartedUrl;
        }
      }
      let intUnit = 0;
      let strPlural = '';
      let strUnit = '';
      let strDirection = '';
      if (data[i].status == 'Completed') {
        data[i].overdue = false;
        data[i].reminderMessage = '';
      } else if (data[i].hoursRemaining && data[i].hoursRemaining <= -72) {
        intUnit = Math.round(data[i].hoursRemaining * -1 / 24);
        strUnit = ' day';
        strDirection = ' overdue';
        data[i].overdue = true;
      } else if (data[i].hoursRemaining && data[i].hoursRemaining <= 0) {
        intUnit = data[i].hoursRemaining * -1;
        strUnit = ' hour';
        strDirection = ' overdue';
        data[i].overdue = true;
      } else if (data[i].hoursRemaining > 72) {
        intUnit = Math.round(data[i].hoursRemaining / 24);
        strUnit = ' day';
        strDirection = ' remaining';
        data[i].overdue = false;
      } else {
        intUnit = data[i].hoursRemaining;
        strUnit = ' hour';
        strDirection = ' remaining';
        data[i].overdue = false;
      }
      if (data[i].status != 'Completed') {
        if (intUnit > 1 || intUnit < 1) {
          strPlural = 's';
        }
        data[i].reminderMessage = intUnit + strUnit + strPlural + strDirection;
      }
      returnArray.push(data[i]);
    }
    return returnArray;
  }

  showPencil(event) {
    if (this.lockEditing == true) {
      return;
    }
    try {
      let boolUpdate = false;
      for (let i = 0; i < this.checklistData.length; i++) {
        if (this.checklistData[i].checklistId == event.currentTarget.dataset.itemid
            && !this.checklistData[i].showPencil && this.checklistData[i].editable) {
          this.checklistData[i].showPencil = true;
          boolUpdate = true;
        }
      }
    } catch (e) {
      console.log(e);
    }
  }
  hidePencil(event) {
    try {
      let boolUpdate = false;
      for (let i = 0; i < this.checklistData.length; i++) {
        if (this.checklistData[i].checklistId == event.currentTarget.dataset.itemid
            && this.checklistData[i].showPencil && this.checklistData[i].editable) {
          this.checklistData[i].showPencil = false;
          boolUpdate = true;
        }
      }
    } catch (e) {
      console.log(e);
    }
  }
  onclickEdit(event) {
    if (this.lockEditing == true) {
      return;
    }
    for (let i = 0; i < this.checklistData.length; i++) {
      if (this.checklistData[i].checklistId == event.currentTarget.dataset.itemid
          && !this.formEditMode) {
        console.log('Looping through items');
        console.log(this.formChecklistItem);
        this.formChecklistItem = this.checklistData[i];
        this.formEditMode = true;
      }
    }
  }
  onpicklistChange(event) {
    this.formChecklistItem.status = event.detail.value;
    this.statusChanged = true;
    console.log('Changed picklist: ' + event.detail.value);
  }
  onclickSave(event) {
    try {
      if (this.statusChanged) {
        console.log('Update checklist items');
        this.updateChecklistItem(event);
      }
    } catch (e) {
      console.log(e);
    }
  }
  updateChecklistItem(event) {
    this.loading = true;
    let itemToUpdate;
    for (let i = 0; i < this.checklistData.length; i++) {
      if (this.checklistData[i].checklistId == this.formChecklistItem.checklistId) {
        itemToUpdate = this.checklistData[i];
      }
    }
    if (itemToUpdate) {
      updateChecklistItem({
        recordId: this.recordId,
        checklistItemId: itemToUpdate.checklistId,
        strSubject: itemToUpdate.subject,
        strConfiguration: this.configuration,
        strNewStatus: itemToUpdate.status
      })
          .then(result => {
            if (result.success) {
              this.refreshData();
            } else {
              this.statusChanged = false;
              this.formEditMode = false;
              this.loading = false;
            }
          })
          .catch(error => {
            console.log('Error');
            console.log(error);
            this.error = error;
            this.loading = false;
            this.statusChanged = false;
          });
    }
  }
  onclickCloseEdit(event) {
    this.formEditMode = false;
    this.statusChanged = false;
  }
}