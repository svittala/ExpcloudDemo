import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class Uc_loginRedirect extends NavigationMixin(LightningElement) {

  @api strExternalPage;

  connectedCallback() {
    this.navigateToWebPage();
  }

  /*navigateToWebPage() {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
          url: 'https://uacdev2.apincloud.com/UACMain.aspx'
      }
    },
      true // Replaces the current page in your browser history with the URL (doesn't work)
    );
  }*/

  navigateToWebPage() {
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__webPage',
        attributes: {
            url: ''
        }
    }).then(url => {
        window.open("https://uacdev2.apincloud.com/UACMain.aspx", "_self");
    });
  }
}