import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

const LBL_SAVE = 'Save';

export default class UacFlowNavigationSaveOnly extends LightningElement {

  @api saveButtonLabel = LBL_SAVE;

  handleSaveButtonClick() {
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }
}