import getCaseRecords from '@salesforce/apex/UAC_preScreenCheckController.getCaseRecords';
import getManifestChildCases from '@salesforce/apex/UAC_preScreenCheckController.getManifestChildCases';
import setTransferMatch from '@salesforce/apex/UAC_preScreenCheckController.setTransferMatch';
import updateEntryInflux from '@salesforce/apex/UAC_preScreenCheckController.updateEntryInflux';
import updateManualCompletedDate from '@salesforce/apex/UAC_preScreenCheckController.updateManualCompletedDate';
import UAC_preScreenLWCLabel from '@salesforce/label/c.UAC_preScreenLWCLabel';
import UAC_assets from '@salesforce/resourceUrl/UAC_assets';
import LightningDatatable from 'lightning/datatable';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord} from 'lightning/uiRecordApi';
import {api, LightningElement, track, wire} from 'lwc';
import hasPermission from '@salesforce/customPermission/UAC_modifyCensus'


const columns = [
  {
    label: 'Entry Id',
    fieldName: 'Id',
    type: 'url',
    typeAttributes: {
      label: {fieldName: 'CaseNumber'},
      tooltip: 'Name',
      target: '_blank',
    },
    sortable: true
  },
  {label: 'Status', fieldName: 'Status', sortable: true},
  {label: 'A#', fieldName: 'UAC_aNum__c', sortable: true},
  {label: 'Profile Name', fieldName: 'Name', type: 'text', sortable: true},
  {label: 'Gender', fieldName: 'Gender', type: 'text', sortable: true},
  {label: 'Age', fieldName: 'Age', type: 'text', sortable: true},
  {
    label: 'Pre-Screened Criteria',
    fieldName: 'CriteriaPassCount',
    sortable: true,
    cellAttributes: {iconName: {fieldName: 'CriteriaPassCountIcon'}, iconPosition: 'left'}

  },
  {
    label: 'Manual Review',
    fieldName: 'manualReviewPassCount',
    sortable: true,
    cellAttributes: {iconName: {fieldName: 'manualReviewPassCountIcon'}, iconPosition: 'left'}
  },
  {
    label: 'Transfer Match',
    fieldName: 'transferEligibility',
    sortable: true,
    cellAttributes: {iconName: {fieldName: 'transferEligibilityIcon'}, iconPosition: 'left'}
  },
  {label: 'Last Modified Date/Time', fieldName: 'lastModifiedDate', type: 'Date', sortable: true},
  {
    type: 'button',
    typeAttributes:
        {label: 'Review Criteria', variant: 'brand', disabled: {fieldName: 'hideReviewButton'}}
  }
];
export default class BasicDatatable extends LightningElement {
  @track
  influxMap;
  @track
  manualReviewMap;
  @track
  manualReviewCriteria;
  @track
  data;
  @track
  error;
  @api
  recordId;
  @track
  isModalOpen = false;
  @track
  overrideCommentRequired = false;
  @track
  missingRequiredFields = false;
  @track
  selectedRows;
  @api
  isLoaded = false;
  @track
  boolCallBackFirstRun = true;
  @track
  sortedDirection;
  @track
  sortedBy;
  @track
  tableErrors = false;
  @track
  tableError;
  label = {UAC_preScreenLWCLabel};
  profileName;
  manualReviewCriteriaMaster;
  aNum;
  entryID;
  Status;
  CaseNumber;
  updatedJSON;
  cob;
  age;
  currentAutoPassCount;
  currentManualPassCount;
  autoReviewCriteria;
  autoReviewCriteriaMaster;
  masterCaseMap;
  gender;
  genderOther;
  statusOptions = [
    {label: 'Passed', value: 'Pass'},
    {label: 'Failed', value: 'Fail'},
    {label: 'Passed (Override)', value: 'Passed (Override)'},
    {label: 'Failed (Override)', value: 'Failed (Override)'},
  ];
  manualStatusOptions = [
    {label: '', value: ''},
    {label: 'Passed', value: 'Pass'},
    {label: 'Failed', value: 'Fail'},
  ];
  passStatusOptions =
      [{label: 'Pass', value: 'Pass'}, {label: 'Failed (Override)', value: 'Failed (Override)'}];
  failStatusOptions =
      [{label: 'Fail', value: 'Fail'}, {label: 'Passed (Override)', value: 'Passed (Override)'}];
  columns = columns;
  dataObject = {
    UAC_influxScreeningJSON__c: '',
    CriteriaPassCount: '',
    CriteriaPassCountIcon: '',
    manualReviewPassCount: '',
    manualReviewPassCountIcon: '',
    transferEligibility: '',
    transferEligibilityIcon: '',
    Name: '',
    CaseNumber: '',
    Status: '',
    UAC_aNum__c: '',
    lastModifiedDate: '',
    hideReviewButton: false,
    Age: '',
    Gender: ''
  };

  get isModifyEnabledBool() {
    return hasPermission;
  }

  processResultList(result) {
    function resultData(CriteriaPassCount,
        CriteriaPassCountIcon,
        manualReviewPassCount,
        manualReviewPassCountIcon,
        transferEligibility,
        transferEligibilityIcon,
        Name,
        CaseNumber,
        Status,
        UAC_aNum__c,
        Id,
        lastModifiedDate,
        hideReviewButton,
        Age,
        Gender) {
      this.CriteriaPassCount = CriteriaPassCount;
      this.CriteriaPassCountIcon = CriteriaPassCountIcon;
      this.manualReviewPassCount = manualReviewPassCount;
      this.manualReviewPassCountIcon = manualReviewPassCountIcon;
      this.transferEligibility = transferEligibility;
      this.transferEligibilityIcon = transferEligibilityIcon;
      this.Name = Name;
      this.CaseNumber = CaseNumber;
      this.Status = Status;
      this.UAC_aNum__c = UAC_aNum__c;
      this.Id = Id;
      this.lastModifiedDate = lastModifiedDate;
      this.hideReviewButton = hideReviewButton;
      this.Age = Age;
      this.Gender = Gender;
    }
    var influxMapTemp = new Object();
    var emptyInflux = false;
    var noPreScreens = true;
    var dataResult = [];
    var manualReviewMapTemp = new Object();
    var masterCaseMapHelper = new Object();
    console.log("here e");
    for (let key in result) {
      emptyInflux = false;
      var jsonData = JSON.parse(JSON.stringify(result[key]));
      if (result[key].UAC_influxScreeningJSON__c == undefined) {
        emptyInflux = true;
        this.dataObject.hideReviewButton = true;
        this.dataObject.CriteriaPassCount = '';
        this.dataObject.CriteriaPassCountIcon = '';
        this.dataObject.transferEligibility = '';
        this.dataObject.transferEligibilityIcon = '';
        this.dataObject.manualReviewPassCount = '';
        this.dataObject.manualReviewPassCountIcon = '';
      }
      console.log("point 2");
      if (emptyInflux == false) {
        noPreScreens = false;
        this.dataObject.hideReviewButton = !this.isModifyEnabledBool;
        var influxList = new Object();
        var manualReviewListTemp = new Object();
        var jsonVar = JSON.parse(result[key].UAC_influxScreeningJSON__c);
        this.dataObject.CriteriaPassCount = jsonVar.CriteraPassCount.Pass + '/19';
        var overrideCheck = jsonVar.CriteraPassCount.Comment;
        this.dataObject.manualReviewPassCount = jsonVar.manualCriteraPassCount.Pass + '/5';
        for (var jsonKey in jsonVar) {
          if (jsonKey.includes('manual')) {
            manualReviewListTemp[jsonKey] = jsonVar[jsonKey];
          } else {
            influxList[jsonKey] = jsonVar[jsonKey];
          }
        }
        if (this.dataObject.CriteriaPassCount == '19/19') {
          if (overrideCheck == 'Override') {
            this.dataObject.CriteriaPassCountIcon = 'action:priority';
          } else {
            this.dataObject.CriteriaPassCountIcon = 'action:approval';
          }

          if (this.dataObject.manualReviewPassCount == '5/5' || this.dataObject.manualReviewPassCount == '-/5') {
            this.dataObject.manualReviewPassCountIcon = 'action:approval';
            this.dataObject.transferEligibility = 'Eligible';
            this.dataObject.transferEligibilityIcon = 'action:approval';
          } else{
            this.dataObject.manualReviewPassCountIcon = 'action:close';
            this.dataObject.transferEligibility = 'Ineligible';
            this.dataObject.transferEligibilityIcon = 'action:close';
          }
        } else {
          console.log("point 3");
          this.dataObject.CriteriaPassCountIcon = 'action:close';
          this.dataObject.transferEligibility = 'Ineligible';
          this.dataObject.transferEligibilityIcon = 'action:close';

          if (this.dataObject.manualReviewPassCount == '5/5' || this.dataObject.manualReviewPassCount == '-/5') {
            this.dataObject.manualReviewPassCountIcon = 'action:approval';
          } else{
            this.dataObject.manualReviewPassCountIcon = 'action:close';
          }
        }
        if (result[key].UAC_transferMatch__c) {
          this.dataObject.transferEligibility = result[key].UAC_transferMatch__c;
        }
      }
      console.log("point 4");
      if (jsonData['Contact'] !== undefined) {
        var caseNum = jsonData.CaseNumber;
        // var influxListSorted = new Map([...influxList.entries()].sort());

        influxMapTemp[caseNum] = {JSON: influxList};
        manualReviewMapTemp[caseNum] = {JSON: manualReviewListTemp};
        this.dataObject.Name = result[key]['Contact'].Name;
      }
      console.log("point 5");
      this.dataObject.CaseNumber = result[key].CaseNumber;
      this.dataObject.Status = result[key].Status;
      this.dataObject.UAC_aNum__c = result[key].UAC_aNum__c;
      this.dataObject.Id = '/' + result[key].Id;
      this.dataObject.Age = result[key].UAC_age__c;
      this.dataObject.Gender = result[key].UAC_gender__c;
      const lastModDate = new Date(result[key].LastModifiedDate);
      this.dataObject.lastModifiedDate = lastModDate;
      var objResult = new resultData(this.dataObject.CriteriaPassCount,
          this.dataObject.CriteriaPassCountIcon,
          this.dataObject.manualReviewPassCount,
          this.dataObject.manualReviewPassCountIcon,
          this.dataObject.transferEligibility,
          this.dataObject.transferEligibilityIcon,
          this.dataObject.Name,
          this.dataObject.CaseNumber,
          this.dataObject.Status,
          this.dataObject.UAC_aNum__c,
          this.dataObject.Id,
          this.dataObject.lastModifiedDate,
          this.dataObject.hideReviewButton,
          this.dataObject.Age,
          this.dataObject.Gender);


      dataResult.push(objResult);
    }
    console.log("point 6");
    if (noPreScreens == false) {
      this.masterCaseMap = masterCaseMapHelper;
      this.influxMap = influxMapTemp;
      this.manualReviewMap = manualReviewMapTemp;
      // this.data = dataResult;
    }
    console.log("point 7");
    this.data = dataResult;

    this.isLoaded = true;
  }
  connectedCallback() {
    getCaseRecords({strEntityId: this.recordId})
        .then(result => {
          // this.data = result;
          this.processResultList(result);
        })
        .catch(error => {
          this.error = error;
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
          this.isLoaded = true;
        });
  }

  constructor() {
    super();  // Must be called first
  }
  onTransferMatch() {
    this.isLoaded = false;
    this.tableErrors = false;
    this.tableError = '';
    let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
    let requestBody = [];
    for (let key in selectedRows) {
      if (selectedRows[key].manualReviewPassCount && selectedRows[key].CriteriaPassCount
          && selectedRows[key].Id) {
        let boolPass = false;
        if (selectedRows[key].manualReviewPassCount == '19/19'
            && selectedRows[key].CriteriaPassCount == '5/5') {
          boolPass = true;
        }
        let objTransferMatchRequest = {};
        objTransferMatchRequest.boolMatch = boolPass;
        objTransferMatchRequest.caseId = selectedRows[key].Id;
        requestBody.push(objTransferMatchRequest);
      } else {
        this.tableErrors = true;
        this.tableError =
            'Prescreen and fill in manual criteria before trying to set transfer match for these UACs.';
        return;
      }
    }
    if (requestBody.length > 0 && !this.tableErrors) {
      this.saveTransferMatch(requestBody);
    } else {
      this.isLoaded = true;
    }
  }

  saveTransferMatch(requestBody) {
    setTransferMatch({transferMatchResults: requestBody})
        .then(result => {
          if (result.success == true) {
            this.dispatchEvent(new ShowToastEvent(
                {title: 'Successfully saved Transfer Match status', variant: 'success'}));
          } else {
            this.dispatchEvent(
                new ShowToastEvent({title: 'Error', message: result.message, variant: 'error'}));
          }
          this.isLoaded = true;
        })
        .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({title: 'Error', message: error, variant: 'error'}));
          this.isLoaded = true;
        });
  }
  prescreenCases() {

    var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
    var lstOfCaseIds = [];
    for (let key in selectedRows) {
      lstOfCaseIds.push(selectedRows[key].CaseNumber);
    }

    if (lstOfCaseIds.length > 0) {
      this.isLoaded = false;

      getManifestChildCases({lstCaseIds: lstOfCaseIds, strEntityId: this.recordId})
          .then(result => {
            this.processResultList(result);
          })
          .catch(error => {
            this.error = error;
            this.dispatchEvent(new ShowToastEvent(
                {title: 'Error', message: error.body.message, variant: 'error'}));
            this.isLoaded = true;
          });
    }
  }

  closeModal() {
    this.isModalOpen = false;
    this.template.querySelector('[data-target-id="reviewPreScreenCriteria-modal-create"]').hide();
  }

  sortData(fieldName, sortDirection) {
    var sortedData = JSON.parse(JSON.stringify(this.data));
    // function to return the value stored in the field
    let key = (a) => a[fieldName];
    var reverse = sortDirection === 'asc' ? 1 : -1;
    sortedData.sort((a, b) => {
      let valueA = key(a) ? key(a).toLowerCase() : '';
      let valueB = key(b) ? key(b).toLowerCase() : '';
      return reverse * ((valueA > valueB) - (valueB > valueA));
    });

    // set sorted data to data list
    this.data = sortedData;
  }

  updateSortingColumns(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirection = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortedDirection);
  }


  openModal(event) {
    try {
      const row = JSON.parse(JSON.stringify(event.detail.row));
      this.CaseNumber = row.CaseNumber;
      let mapInfluxDetail = this.influxMap[row.CaseNumber];
      let mapManualReviewDetail = this.manualReviewMap[row.CaseNumber];

      let influxList = [];
      let manualList = [];
      let influxListMaster = new Object();
      let manualListMaster = new Object();
      this.profileName = row.Name;
      this.aNum = row.UAC_aNum__c;
      this.entryID = row.CaseNumber;
      this.Status = row.Status;
      this.age = row.Age;
      this.gender = row.Gender;
      this.currentAutoPassCount = row.CriteriaPassCount;
      this.currentManualPassCount = row.manualReviewPassCount;
      for (let key in mapInfluxDetail.JSON) {
        if (!key.includes('CriteraPassCount')) {
          influxListMaster[key] = (mapInfluxDetail.JSON)[key];
          let statusOptionsCheck = mapInfluxDetail.JSON[key];
          if (statusOptionsCheck.Status == 'Pass'
              || statusOptionsCheck.Status == 'Failed (Override)') {
            statusOptionsCheck.statusOptions = this.passStatusOptions;
          } else {
            statusOptionsCheck.statusOptions = this.failStatusOptions;
          }
          influxList.push(statusOptionsCheck);
        }
      }

      for (let manualKey in mapManualReviewDetail.JSON) {
        if (!manualKey.includes('manualCriteraPassCount')) {
          manualList.push((mapManualReviewDetail.JSON)[manualKey]);
          manualListMaster[manualKey] = (mapManualReviewDetail.JSON)[manualKey];
        }
      }
      influxList.sort(function(a, b) {
        return a.Rank - b.Rank;
      });
      manualList.sort(function(a, b) {
        return a.Rank - b.Rank;
      });
      this.manualReviewCriteria = manualList;
      this.autoReviewCriteria = influxList;
      this.manualReviewCriteriaMaster = manualListMaster;
      this.autoReviewCriteriaMaster = influxListMaster;
      // this.isModalOpen = true;
      this.template.querySelector('[data-target-id="reviewPreScreenCriteria-modal-create"]').size =
          'medium';
      this.template.querySelector('[data-target-id="reviewPreScreenCriteria-modal-create"]').show();
    } catch (error) {
      alert(error.message);
    }
  }

  get addModalLabel() {
    return this.label.UAC_preScreenLWCLabel;
  }
  
  onCriteriaStatusChange() {
    let allComboBox = this.template.querySelectorAll('[data-id="combobox"]');
    let allInputComment = this.template.querySelectorAll('[data-id="inputComment"]');

    allComboBox.forEach(function(item, index) {
      if (item.value == 'Passed (Override)' || item.value == 'Failed (Override)') {
        allInputComment[index].required = true;
      } else {
        allInputComment[index].required = false;
      }
    });
  }
  completeManualReview(event) {
    let allManualInputCombobox = this.template.querySelectorAll('[data-id="manualCombobox"]');
    allManualInputCombobox.forEach(function(item) {
      if (item.value == '' || item.value == undefined) {
        alert('Missing Required Fields');
        this.isLoaded = true;
        this.isModalOpen = true;
      }
    });
    this.template.querySelector('[data-target-id="reviewPreScreenCriteria-modal-create"]').hide();
    this.isModalOpen = false;
    this.isLoaded = false;
    updateManualCompletedDate({strCaseNum: this.CaseNumber}).catch(error => {
      alert(error);
      this.isLoaded = true;
    });
    this.handleSave(event);
  }
  handleSave() {
    let mapInfluxDetail = JSON.parse(JSON.stringify(this.influxMap[this.CaseNumber]));
    let mapManualReviewDetail = JSON.parse(JSON.stringify(this.manualReviewMap[this.CaseNumber]));
    let allInputComment = this.template.querySelectorAll('[data-id="inputComment"]');
    let allInputCombobox = this.template.querySelectorAll('[data-id="combobox"]');
    let allManualInputCombobox = this.template.querySelectorAll('[data-id="manualCombobox"]');
    let allManualInputComment = this.template.querySelectorAll('[data-id="manualInputComment"]');
    var CriteraPassCount = new Object();
    var manualCriteraPassCount = new Object();
    var autoriteria = this.autoReviewCriteria;
    var manualCriteria = this.manualReviewCriteria;
    allInputComment.forEach(function(item) {
      if (item.required && (item.value == '' || item.value == undefined)) {
        alert('Missing Required Fields');
        this.isLoaded = true;
        this.isModalOpen = true;
      }
    });
    this.template.querySelector('[data-target-id="reviewPreScreenCriteria-modal-create"]').hide();
    this.isModalOpen = false;
    this.isLoaded = false;
    var autoPassCount = 0;
    var manualPassCount = 0;
    var index = 0;

    for (let key in autoriteria) {
      if (allInputCombobox[index].value == 'Pass'
          || allInputCombobox[index].value == 'Passed (Override)') {
        autoPassCount++;
      }
      autoriteria[key].Status = allInputCombobox[index].value;
      autoriteria[key].Comment = allInputComment[index] = allInputComment[index].value;
      index++;
    }
    index = 0;
    for (let key in manualCriteria) {
      if (allManualInputCombobox[index].value == 'Pass') {
        manualPassCount++;
      }
      manualCriteria[key].Status = allManualInputCombobox[index].value;
      manualCriteria[key].Comment = allManualInputComment[index].value;
      index++;
    }
    this.currentAutoPassCount = autoPassCount;
    this.currentManualPassCount = manualPassCount;
    for (let key in mapInfluxDetail.JSON) {
      if (key.includes('CriteraPassCount')) {
        CriteraPassCount[key] = mapInfluxDetail.JSON[key];
        CriteraPassCount[key].Pass = this.currentAutoPassCount;
      }
    }
    for (let manualKey in mapManualReviewDetail.JSON) {
      if (manualKey.includes('manualCriteraPassCount')) {
        manualCriteraPassCount[manualKey] = mapManualReviewDetail.JSON[manualKey];
        manualCriteraPassCount[manualKey].Pass = this.currentManualPassCount;
      }
    }
    var fullJSON = JSON.stringify(this.autoReviewCriteriaMaster) + ','
        + JSON.stringify(this.manualReviewCriteriaMaster) + ',' + JSON.stringify(CriteraPassCount)
        + ',' + JSON.stringify(manualCriteraPassCount);
    var target = '}},{';
    fullJSON = fullJSON.replace(target, '},');
    fullJSON = fullJSON.replace(target, '},');
    fullJSON = fullJSON.replace(target, '},');
    updateEntryInflux({strCaseNum: this.CaseNumber, strInfluxJSON: fullJSON})
        .then(result => {
          this.processResultList(result);
        })
        .catch(error => {
          alert(error);
          this.isLoaded = true;
        });
  }
}