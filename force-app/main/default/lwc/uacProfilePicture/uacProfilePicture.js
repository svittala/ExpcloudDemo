import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import UAC_assets from '@salesforce/resourceUrl/UAC_assets';
import getFileTypeSettings from '@salesforce/apex/UAC_profilePictureController.getFileTypeSettings';
import getProfilePicture from '@salesforce/apex/UAC_profilePictureController.getProfilePicture';
import saveProfilePicture from '@salesforce/apex/UAC_profilePictureController.saveProfilePicture';
import { reduceErrors } from 'c/uacUtils';
import getRecordTypeName from '@salesforce/apex/UAC_profilePictureController.getRecordTypeName';
import UAC_UAC from '@salesforce/label/c.UAC_contactRecordTypeApiNameUAC';

// URL for placeholder image
const PLACEHOLDER_PICTURE = UAC_assets + '/images/image-placeholder.png';

export default class UacProfilePicture extends NavigationMixin(LightningElement) {
  @api recordId;
  @api disableEdit = false;

  _objFile;
  lstFileTypeSettings = [];

  contactFlag = true;
  pictureSize;
  recordTypeName;

  /**
   * @description Method to return id of picture file (used for navigating to the attachment record)
   * @author Sachet Khanal (Deloitte)
   */
  get pictureId() {
    return this._objFile.idFile;
  }

  get editable() {
    return !this.disableEdit && this.contactFlag;
  }

  /**
   * @description Method to get the image source to display profile picture
   * @author Sachet Khanal (Deloitte)
   * @param {Object[]} lstFileTypes List of File Type Settings mdt object
   */
  get pictureSrc() {
    if (!this._objFile) {
      return PLACEHOLDER_PICTURE;
    }
    return `data:${this._objFile.strContentType};base64,${this._objFile.strBase64Data}`;
  }

  /**
   * @description Method to navigate to attachment record when the profile picture is clicked
   * @author Sachet Khanal (Deloitte)
   */
  handlePictureClick() {
    if (this.pictureId) {
      this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {pageName: 'filePreview'},
        state: {recordIds: this.pictureId, selectedRecordId: this.pictureId}
      });
    }
  }

  /**
   * @description Method to handle Edit Profile Picture button click
   * @author Sachet Khanal (Deloitte)
   * @param {Event} event button click event
   */
  handleEditClick() {
    this.template.querySelector('.uac-file-upload')
      .show(this.lstFileTypeSettings);
  }

  /**
   * @description Method to handle confirm button click in file upload component
   * @author Sachet Khanal (Deloitte)
   * @param {Event} event confirm event triggered when confirm button is clicked
   */
  handleUploadConfirm(event) {
    this.template.querySelector('.uac-file-upload').setUploading(true);
    this.uploadPicture(event.detail[0]);
  }

  /**
   * @description Method to load picture from the server
   * @author Sachet Khanal (Deloitte)
   */
  getProfilePic() {
    getProfilePicture({
        idContact: this.recordId
      })
      .then(result => {
        if (result != null) {
          this._objFile = result;
        }
      })
      .catch(error => {
        this.showMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  /**
   * @description Method to upload new picture file
   * @author Sachet Khanal (Deloitte)
   * @param {Object} objFile UAC_FileWrapper object to upload
   */
  uploadPicture(objFile) {
    saveProfilePicture({
        strFile: JSON.stringify(objFile)
      })
      .then(result => {
        this._objFile = result;
        this.showMessage('Success', 'Profile photo updated', 'success');
        this.template.querySelector('.uac-file-upload').setUploading(false);
        this.template.querySelector('.uac-file-upload')
          .hide();
      })
      .catch(error => {
        this.template.querySelector('.uac-file-upload').setUploading(false);
        this.showMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
  }

  /**
   * @description Method to show toast messages
   * @author Sachet Khanal (Deloitte)
   * @param {String} title Title of the toast message
   * @param {String} message Text message to display
   * @param {String} variant Variant of the toast message (success, error, warning)
   */
  showMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  /**
   * @description Method called when component is inserted into the document. Calls method to load
   * picture and file type settings list used for file (picture) upload.
   * @author Sachet Khanal (Deloitte)
   */
  async connectedCallback () {
    this.getProfilePic();
    getFileTypeSettings()
      .then(result => {
        this.lstFileTypeSettings = result;
      })
      .catch(error => {
        this.showMessage('Error', reduceErrors(error)
          .join('\n'), 'error');
      });
    this.handleAssessment();
  }

  /**
   * @description Method to handle Assessment changes as per Story 207
   * @author  Abhisek Pati (Deloitte)
   */
  handleAssessment() {
    if (this.recordId.substr(0, 3) !== '003') {
      this.contactFlag = false;
      this.pictureSize = 'profile-picture-assessment';
    } else {
      getRecordTypeName({ idContact: this.recordId })
        .then(result => {
          if (result != null) {
            this.recordTypeName = result;
            if (this.recordTypeName === UAC_UAC) {
              this.pictureSize = 'profile-picture-assessment';
            } else {
              this.pictureSize = 'profile-picture';
            }
          }
        })
        .catch(error => {
          this.showMessage('Error', reduceErrors(error)
            .join('\n'), 'error');
        });
    }
  }

  /**
   * @description Method called when component is removed from the document.
   * Used to reset picture file information.
   * @author Sachet Khanal (Deloitte)
   */
  disconnectedCallback() {
    this._objFile = null;
  }
}