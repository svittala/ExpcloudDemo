import { LightningElement, api, wire, track } from 'lwc';
import { getRecordCreateDefaults } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/uacUtils';

export default class UacRecordEditForm extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api recordType;
  @api sections = [];
  @api hideError = false;
  @api excludeSections = ['System Information'];
  @api excludeFields = [];
  @api overrideFields = [];

  @api
  get form() {
    return this.layout
  }
  set form(value) {
    this.layout = value;
  }

  @api
  getRecord() {
    let record = {};
    this.template.querySelectorAll('lightning-input-field')
      .forEach(fld => {
        record[fld.dataset.id] = fld.value;
        if (Object.prototype.hasOwnProperty.call(fld, 'checked')) {
          record[fld.dataset.id] = fld.checked;
        }
      });
    this.template.querySelectorAll('c-uac-input')
      .forEach(fld => {
        record[fld.dataset.id] = fld.value;
        if (Object.prototype.hasOwnProperty.call(fld, 'checked')) {
          record[fld.dataset.id] = fld.checked;
        }
      });
    record.RecordTypeId = this.recordTypeId;
    return record;

  }

  @api
  save() {
    this.validateOverrideFields();
    this.template.querySelector('.uac-btn-submit')
      .click();
  }

  @track isLoading = true;
  @track recordTypeId;
  @track layout;
  @track record = {};

  @wire(getObjectInfo, { objectApiName: '$objectApiName' })
  wiredObjectInfo({ data, error }) {
    if (data) {
      if (this.recordType) {
        for (let key of Object.keys(data.recordTypeInfos)) {
          if (data.recordTypeInfos[key].name === this.recordType) {
            this.recordTypeId = data.recordTypeInfos[key].recordTypeId;
          }
        }
      } else {
        this.recordTypeId = data.defaultRecordTypeId;
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  @wire(getRecordCreateDefaults, { objectApiName: '$objectApiName', recordTypeId: '$recordTypeId' })
  wiredRecordCreateDefaults({ data, error }) {
    if (data) {
      if (this.recordTypeId) {
        this.loadLayout(data.layout);
      }
    } else if (error) {
      this.showToastMessage('Error', reduceErrors(error)
        .join('\n'), 'error');
    }
  }

  get layoutLoaded() {
    return !!this.layout;
  }

  loadLayout(layoutData) {
    let layout = JSON.parse(JSON.stringify(layoutData));
    // Filter only allowed sections
    if (this.sections.length > 0) {
      let allowedSections = new Set(this.sections);
      layout.sections = layout.sections.filter((section) => {
        return allowedSections.has(section.heading);
      });
    }
    // Filter out excluded sections
    if (this.excludeSections.length > 0) {
      let excludedSections = new Set(this.excludeSections);
      layout.sections = layout.sections.filter((section) => {
        return !excludedSections.has(section.heading);
      });
    }

    // Filter out excluded fields
    if (this.excludeFields.length > 0) {
      let excludeFields = new Set(this.excludeFields);
      layout.sections.forEach((section) => {
        section.layoutRows.forEach((layoutRow) => {
          layoutRow.layoutItems.forEach((layoutItem) => {
            layoutItem.layoutComponents = layoutItem.layoutComponents.filter((
              layoutComponent) => {
              return layoutComponent.componentType !== 'Field' ||
                !excludeFields.has(layoutComponent.apiName);
            });
          });
        });
      });
    }

    layout.record = {};

    let currentCmp = this;

    // Set additional required attribute for layout sections and components
    layout.sections.forEach((section) => {
      Object.defineProperty(section, "className", {
        get: function () {
          return (this.hide) ? 'slds-hide' : 'slds-show';
        }
      });

      let rowIndex = 0;
      section.layoutRows.forEach((layoutRow) => {
        layoutRow.index = rowIndex;
        rowIndex++;
        layoutRow.layoutItems.forEach((layoutItem) => {
          layoutItem.layoutComponents.forEach((layoutComponent) => {
            Object.defineProperty(layoutComponent, "isField", {
              get: function () {
                return (this.componentType === 'Field');
              }
            });
            Object.defineProperty(layoutComponent, "className", {
              get: function () {
                return (this.hide || this.override) ? 'slds-hide' :
                  'slds-show';
              }
            });
            if (layoutComponent.isField) {
              Object.defineProperty(layoutComponent, "required", {
                get: function () {
                  const field = currentCmp.template.querySelector(
                    `lightning-input-field[data-id="${this.apiName}"]`
                  );
                  return field.required;
                },
                set: function (value) {
                  const field = currentCmp.template.querySelector(
                    `lightning-input-field[data-id="${this.apiName}"]`
                  );
                  field.required = value;
                }
              });
              Object.defineProperty(layoutComponent, "value", {
                get: function () {
                  return layout.record[this.apiName];
                },
                set: function (value) {
                  layout.record[this.apiName] = value;
                  const field = currentCmp.template.querySelector(
                    `lightning-input-field[data-id="${this.apiName}"]`
                  );
                  if(field) {
                    field.value = value;
                  }
                }
              });
              Object.defineProperty(layoutComponent, "override", {
                get: function () {
                  let filteredOverrideFields = currentCmp.overrideFields
                    .filter((fld) => {
                      return fld.name === this.apiName;
                    });
                  return (filteredOverrideFields.length > 0) ?
                    filteredOverrideFields[0] : null;
                }
              });

            }
          });
        });
      });
    });
    layout.record.RecordTypeId = this.recordTypeId;
    this.layout = layout;
  }

  loadRecord() {
    this.layout.sections.forEach((section) => {
      section.layoutRows.forEach((layoutRow) => {
        layoutRow.layoutItems.forEach((layoutItem) => {
          layoutItem.layoutComponents.forEach((layoutComponent) => {
            if (layoutComponent.isField) {
              this.layout.record[layoutComponent.apiName] = this.template.querySelector(
                  `lightning-input-field[data-id="${layoutComponent.apiName}"]`)
                .value;
              layoutComponent.required = layoutItem.required;
            }
          });
        });
      });
    });
  }

  handleLoad() {
    this.loadRecord();
    this.isLoading = false;
    this.dispatchEvent(new CustomEvent('loadcomplete'));
  }

  validateOverrideFields() {
    let isValid = [...this.template.querySelectorAll('c-uac-input')].reduce((validSoFar,
      inputCmp) => {
      let cmpValidity = inputCmp.validate();
      return validSoFar && cmpValidity;
    }, true);
    return isValid;
  }

  handleSubmit(event) {
    if (!this.validateOverrideFields()) {
      event.preventDefault();
    }
  }

  handleError(event) {
    this.dispatchEvent(new CustomEvent('error', {
      detail: event.detail
    }));
  }

  handleFieldChange(event) {
    const fieldName = event.target.dataset.id;
    let value = event.detail.value;
    if (Object.prototype.hasOwnProperty.call(event.detail, 'checked')) {
      value = event.detail.checked;
    }
    this.layout.record[fieldName] = value;
    this.dispatchEvent(new CustomEvent('fieldchange'));
  }

  handleOverrideFieldChange(event) {
    const fieldName = event.target.dataset.id;
    const value = event.detail.value;
    this.template.querySelector(
        `lightning-input-field[data-id="${fieldName}"]`
      )
      .value = value;
  }

  showToastMessage(title, message, variant) {
    this.isLoading = false;
    this.dispatchEvent(new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    }));
  }

}