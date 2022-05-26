import { LightningElement, api } from 'lwc';
import { FlowNavigationBackEvent } from 'lightning/flowSupport';

export default class UacFlowError extends LightningElement {
  @api errorMessage;

  get hasErrorMessage() {
    return this.errorMessage !== '' || this.errorMessage !== undefined;
  }

  goBack() {
    this.dispatchEvent(new FlowNavigationBackEvent());
  }
}