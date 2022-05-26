import { LightningElement,api } from 'lwc';
import { FlowNavigationFinishEvent  } from 'lightning/flowSupport';

export default class UacFlowRedirect2Nintex extends LightningElement {
    @api recordId;
    @api docgenFilter;

    HandleButtonClick() {
        console.log(this.recordId);
        window.open("/apex/loop__looplus?&eid=" + this.recordId + "&hidecontact=true&autorun=true&attach=true&filter=" + this.docgenFilter);
        const NavigationFinishEvent = new FlowNavigationFinishEvent();
        this.dispatchEvent(NavigationFinishEvent);
    }
}