import { LightningElement, api } from 'lwc';

export default class ShowPdfById extends LightningElement {
    @api fileId;
    @api heightInRem;

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }
    
    get pdfurl() {
        return '/sfc/servlet.shepherd/document/download/' + this.fileId;
    }
}