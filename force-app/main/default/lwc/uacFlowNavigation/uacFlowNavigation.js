import { LightningElement, api } from "lwc";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class UacFlowNavigation extends LightningElement {
  @api previousButtonLabel = 'Previous';
  @api previousScreen;
  @api nextButtonLabel = 'Next';
  @api nextScreen;
  @api
  get navigateToScreen() {
    return this._navigateToScreen;
  }

  _navigateToScreen;

  handlePreviousButtonClick() {
    this._navigateToScreen = this.previousScreen;
    this.fireFlowNavigateNextEvent();
  }

  handleNextButtonClick() {
    this._navigateToScreen = this.nextScreen;
    this.fireFlowNavigateNextEvent();
  }

  fireFlowNavigateNextEvent() {
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }
}