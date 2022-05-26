import {
  LightningElement,
  api
} from 'lwc';

const CSS_CLASS = 'modal-hidden';

export default class UacModal extends LightningElement {
  showModal = false;
  @api size;
  @api
  set header(value) {
    this.hasHeaderString = value !== '';
    this._headerPrivate = value;
  }
  get header() {
    return this._headerPrivate;
  }
  @api tagline;

  hasHeaderString = false;
  _headerPrivate;

  @api show() {
    this.showModal = true;
  }

  @api hide() {
    this.showModal = false;
  }

  @api scrollToTop() {
    this.template.querySelector('.slds-modal__content')
      .scrollTop = 0;
  }

  get modalClass() {
    let sizeClass = '';
    switch (this.size) {
    case "small":
      sizeClass = 'slds-modal_small';
      break;
    case "medium":
      sizeClass = 'slds-modal_medium';
      break;
    case "large":
      sizeClass = 'slds-modal_large';
      break;
    default:
      break;
    }
    return 'slds-modal slds-fade-in-open ' + sizeClass;
  }

  handleDialogClose() {
    //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
    const closedialog = new CustomEvent('closedialog');
    this.dispatchEvent(closedialog);
    this.hide();
  }

  handleSlotTaglineChange() {
    const taglineEl = this.template.querySelector('p');
    if (taglineEl) {
      taglineEl.classList.remove(CSS_CLASS);
    }
  }

  handleSlotFooterChange() {
    const footerEl = this.template.querySelector('footer');
    if (footerEl) {
      footerEl.classList.remove(CSS_CLASS);
    }
  }
}