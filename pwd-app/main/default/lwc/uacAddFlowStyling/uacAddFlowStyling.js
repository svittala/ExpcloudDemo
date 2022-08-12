import {api, LightningElement} from 'lwc';

export default class UacAddFlowStyling extends LightningElement {
  @api
  targetId;
  @api
  styling;
  renderedCallback() {
    let strSelectorStart = ' {';
    let strSelectorEnd = ' }';
    let elementStyle = document.createElement('style');
    elementStyle.innerText = this.targetId + strSelectorStart + this.styling + strSelectorEnd;
    let target = this.template.querySelector('[data-target-id="add-flow-styling"]');
    if (target) {
      target.appendChild(elementStyle);
    }
  }
}