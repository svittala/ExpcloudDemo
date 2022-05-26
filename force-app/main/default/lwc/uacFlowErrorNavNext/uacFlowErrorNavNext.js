import {FlowNavigationNextEvent} from 'lightning/flowSupport';
import {api, LightningElement} from 'lwc';

export default class UacFlowErrorNavNext extends LightningElement {
  @api
  errorMessage;

  get hasErrorMessage() {
    return this.errorMessage !== '' || this.errorMessage !== undefined;
  }

  goNext() {
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }
}