import { LightningElement, api, track } from 'lwc';

export default class UacInput extends LightningElement {
  @api type = 'text'; // Input types
  @api name = '';
  @api label = 'Label';
  @api placeholder = '';
  @api required = false;
  @api disabled = false;
  @api readOnly = false;
  @api isButton = false;
  @api maxLength = 255;
  @api helpText;
  @api min;
  @api max;
  @api
  set defaultValue(value) {
    if (value || value === 0 || typeof (x) === 'boolean') {
      this._defaultValue = value;
    } else {
      this._defaultValue = (this.isCheckbox) ? false : null;
    }
  }
  get defaultValue() {
    return this._defaultValue;
  }
  @api
  set hide(value) {
    this._hide = value;
    this.visibilityChanged = true;
  }
  get hide() {
    return this._hide;
  }
  @api variant = '';
  @api
  set value(value) {
    this._value = (this.isMultiPicklist && value && value!==null) ? [...value.split(';')] : value;
    this.valueChanged = true;
  }
  get value() {
    return this._value;
  }
  @api
  set options(value) {
    this._options = value;
    this.optionChanged = true;
  }
  get options() {
    return this._options;
  }
  @api
  set dependentOptionMap(value) {
    if (value !== undefined && !(value instanceof Map)) {
      value = new Map(Object.entries(value));
    }
    this._dependentOptionMap = value;
    this.getDependentOptions();
  }
  get dependentOptionMap() {
    return this._dependentOptionMap;
  }
  @api
  set controllingValue(value) {
    this._controllingValue = value;
    this.getDependentOptions();
  }
  get controllingValue() {
    return this._controllingValue;
  }

  @api
  setErrors(strError) {
    const cmpInput = this.template.querySelector('.uac-input');
    if (!cmpInput) return;
    cmpInput.setCustomValidity(strError);
    cmpInput.reportValidity();
  }

  @api validate() {
    const cmpInput = this.template.querySelector('.uac-input');
    if (!cmpInput) return true;
    cmpInput.reportValidity();
    return cmpInput.checkValidity();
  }

  @track _hide = false;
  @track _value = null;
  _options = [];
  _controllingValue;
  _dependentOptionMap;
  _defaultValue = null;

  get isPicklistDisabled() {
    return this.disabled || !(this.options && this.options.length > 0);
  }

  get isPicklist() {
    return this.type === 'picklist';
  }

  get isMultiPicklist() {
    return this.type === 'multi-picklist';
  }

  get isRadio() {
    return this.type === 'radio';
  }

  get isTextArea() {
    return this.type === 'textarea';
  }

  get isCheckbox() {
    return this.type === 'checkbox';
  }

  get isDefault() {
    return !this.isPicklist && !this.isRadio && !this.isTextArea && !this.isCheckbox && !this.isMultiPicklist;
  }

  get isReadonly() {
    return !this.isButton && this.readOnly;
  }

  get isInput() {
    return !this.isButton && !this.readOnly;
  }

  get isReadonlyNumber() {
    return this.type === 'number';
  }

  get isReadonlyPhone() {
    return this.type === 'phone';
  }

  get isReadonlyDate() {
    return this.type === 'date';
  }

  get isReadonlyText() {
    return !this.isReadonlyNumber && !this.isReadonlyDate && !this.isReadonlyPhone;
  }

  getDependentOptions() {
    if (this._dependentOptionMap && this._controllingValue && this._dependentOptionMap.has(this
        ._controllingValue)) {
      this._options = this._dependentOptionMap.get(this._controllingValue);
    } else if (this._dependentOptionMap) {
      this._options = [];
    }
    this.optionChanged = true;
  }

  setDefaultValue() {
    if (this._options && this._options.length >= 1 && !this._hide) {
      if(this._options.length===1 && this._value !== this._options[0].value) {
        this._value = this._options[0].value;
        this.notifyValueChange(this._value);
      } else {
        let filteredOptions = this._options.filter(opt => {return this._value === opt.value});
        if(filteredOptions.length>0 && this._value !== filteredOptions[0].value) {
          this._value = filteredOptions[0].value;
          this.notifyValueChange(this._value);
        }
      }
    } else if (this._value !== this._defaultValue && !this.valueChanged) {
      this._value = this._defaultValue;
      this.notifyValueChange(this._value);
    }
  }

  handleChange(event) {
    let value = event.detail.value;
    if (this.type === 'checkbox') {
      value = event.detail.checked;
    }
    if (this._value !== value) {
      this._value = value;
      this.notifyValueChange((this.isMultiPicklist) ? this._value.join(';') : this._value);
    }
  }

  notifyValueChange(value) {
    this.dispatchEvent(new CustomEvent('fieldchange', {
      detail: {
        name: this.name,
        value: value
      }
    }));
  }

  onButtonClick() {
    this.dispatchEvent(new CustomEvent('fieldclick', {
      detail: {
        name: this.name
      }
    }));
  }

  optionChanged = false;
  valueChanged = false;
  visibilityChanged = false;

  renderedCallback() {
    // Set default value if options changed and value is not updated
    if (((this.optionChanged || this.visibilityChanged) && !this.valueChanged) ||
      (this.visibilityChanged && this.valueChanged && this._options)) {
      this.setDefaultValue();
    }
    this.visibilityChanged = false;
    this.optionChanged = false;
    this.valueChanged = false;
  }
}