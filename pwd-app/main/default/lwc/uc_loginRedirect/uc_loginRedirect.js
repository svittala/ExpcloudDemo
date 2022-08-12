import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class Uc_loginRedirect extends NavigationMixin(LightningElement) {

  handleNavigate() {
    const config = {
        type: 'standard__webPage',
        attributes: {
            url: 'https://uacdev2.apincloud.com/UACMain.aspx'
        }
	};
    this[NavigationMixin.Navigate](config);
  }
}