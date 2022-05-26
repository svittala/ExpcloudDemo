import queryAccounts from "@salesforce/apex/UAC_flowInsertTasksForPrograms.queryAccounts";
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
  api,
  LightningElement,
  track
} from "lwc";

const LST_FIELD = [{
    label: "Program Name",
    fieldName: "Name",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "Program Type",
    fieldName: "Type",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "Stop Placement",
    fieldName: "UAC_stopPlacementTransfer__c",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "VOLAG Grantee?",
    fieldName: "UAC_volagGrantee__c",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "Search Tags",
    fieldName: "UAC_searchTags__c",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 300
  },
  {
    label: "City",
    fieldName: "UAC_city__c",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 150
  },
  {
    label: "State",
    fieldName: "UAC_state__c",
    type: "text",
    sortable: true,
    wrapText: true,
    initialWidth: 100
  },
  {
    label: "Male Beds",
    fieldName: "UAC_bedCountAvailableMale__c",
    type: "number",
    sortable: true,
    wrapText: true,
    initialWidth: 100
  },
  {
    label: "Female Beds",
    fieldName: "UAC_bedCountAvailableFemale__c",
    type: "number",
    sortable: true,
    wrapText: true,
    initialWidth: 100
  },
  {
    label: "Minimum Age",
    fieldName: "UAC_minimumAge__c",
    type: "number",
    sortable: true,
    wrapText: true,
    initialWidth: 100
  },
  {
    label: "Maximum Age",
    fieldName: "UAC_maximumAge__c",
    type: "number",
    sortable: true,
    wrapText: true,
    initialWidth: 100
  }
];
export default class UacProgramSearchTable extends LightningElement {
  @track
  columns = LST_FIELD;
  @track
  showTable = false;
  @track
  searchString;
  @track
  disableSearchBox = false;
  @track
  data;
  @api
  lstSelectedIDs = [];
  @track
  sortedColumn;
  @track
  sortedDirection;
  boolTrue = true;
  lastSearch;
  disconnectedCallback() {
    this.data = [];
    this.showTable = false;
  }
  onSelect() {
    let selectedRows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    let lstIDs = [];
    if (selectedRows) {
      selectedRows.forEach((row) => {
        lstIDs.push(row.Id);
      });
    }
    this.lstSelectedIDs = lstIDs;
  }
  onChangeSearchKey(event) {
    if (event.target.value) {
      this.searchString = event.target.value;
    }
  }
  onBlur() {
    if (this.searchString) {
      this.query();
    }
  }
  onEnterKey(event) {
    if (event.keyCode == 13) {
      this.query();
    }
  }
  query() {
    console.log("I am here");
    if (this.disableSearchBox || this.searchString === this.lastSearch) {
      return;
    }
    this.lastSearch = this.searchString;
    this.disableSearchBox = true;
    this.showTable = false;
    this.data = [];
    queryAccounts({
        searchKey: this.searchString
      })
      .then((result) => {
        this.data = result;
        this.showTable = true;
        this.disableSearchBox = false;
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
      });
  }
  onSort(event) {
    this.sortedColumn = event.detail.fieldName;
    this.sortedDirection = event.detail.sortDirection;
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
  }
  sortData(fieldname, direction) {
    let strDataJson = JSON.parse(JSON.stringify(this.data));
    let keyValue = (a) => {
      return a[fieldname];
    };
    let boolReversed = direction === "asc" ? 1 : -1;
    strDataJson.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : "";
      y = keyValue(y) ? keyValue(y) : "";
      return boolReversed * ((x > y) - (y > x));
    });
    this.data = strDataJson;
  }
  @api
  validate() {
    let errorMessage = "Please select one or more program(s).";
    if (this.lstSelectedIDs === undefined || this.lstSelectedIDs.length == 0) {
      return {
        isValid: false,
        errorMessage: errorMessage
      };
    } else {
      return {
        isValid: true
      };
    }
  }
}