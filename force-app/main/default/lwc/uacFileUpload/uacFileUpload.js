import {
  LightningElement,
  api,
  track
} from 'lwc';
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";

export default class UacFileUpload extends LightningElement {
  @api title;
  @api recordId;

  // List of file types settings info used for displaying/validating file upload
  @track lstFileTypes = [];

  @track isLoading = false;
  @track
  isUploading = false;

  /**
   * @description Method to show the file upload modal
   * @author Sachet Khanal (Deloitte)
   * @param {Object[]} lstFileTypes List of File Type Settings mdt object
   */
  @api show(lstFileTypes) {
    let fileTypeList = [...lstFileTypes];
    // Update list to include custom label for each file types to upload
    for (let fileType of fileTypeList) {
      fileType.uploadLabel = 'Upload ' + fileType.Label;
    }
    this.lstFileTypes = fileTypeList;
    this.template.querySelector('.uac-modal')
      .show();
  }

  /**
   * @description Method to hide the file upload modal
   * @author Sachet Khanal (Deloitte)
   */
  @api hide() {
    this.template.querySelector('.uac-modal')
      .hide();
    this.lstFileTypes = [];
  }

  @api
  setUploading(uploading) {
    this.isUploading = uploading;
  }
  /**
   * @description Method to handle file change when user selects an input file
   * @author Sachet Khanal (Deloitte)
   * @param {Event} event input file element change event
   */
  handleFileChange(event) {
    const index = event.target.dataset.index;
    this.validateFiles(index, event.target.files);
  }

  /**
   * @description Method to handle upload button click
   * @author Sachet Khanal (Deloitte)
   * @param {Event} event button click event
   */
  handleUploadClick(event) {
    const index = event.target.dataset.index;
    this.template.querySelector(`.file-input[data-index="${index}"]`)
      .click();
  }

  /**
   * @description Method to handle confirm button click
   * @author Sachet Khanal (Deloitte)
   * @param {Event} event button click event
   */
  handleConfirmClick() {
    let newFiles = [];
    for (const fileType of this.lstFileTypes) {
      if (fileType.file) {
        newFiles.push(fileType.file);
      } else {
        this.showMessage('Error', `Please select file for ${fileType.Label}.`, 'error');
        return;
      }
    }
    this.dispatchEvent(new CustomEvent('confirm', {
      detail: newFiles
    }));
  }

  /**
   * @description Method to reset file data for specific file type
   * @author Sachet Khanal (Deloitte)
   * @param {Integer} index Index value of file type list to reset file data
   */
  resetFile(index) {
    this.lstFileTypes[index].file = null;
  }

  /**
   * @description Method to validate files before upload
   * @author Sachet Khanal (Deloitte)
   * @param {Integer} index Index value defining the index of file type list to upload file
   * @param {Object[]} files List of input file objects
   */
  validateFiles(index, files) {
    // Check if more than one file is selected
    if (files.length > 1) {
      this.showMessage('Error', 'You can only upload one file.', 'error');
    }
    // Reset file data if user doesn't select any file
    const file = files[0];
    if (!file) {
      this.resetFile(index);
      return;
    }
    // Validate file content type matches supported file types
    if (this.lstFileTypes[index].UAC_supportedFileTypes__c) {
      const isNotSupported = [...this.lstFileTypes[index].UAC_supportedFileTypes__c.split(',')]
        .map(value => value.trim())
        .reduce(
          function (notSupported, value) {
            return notSupported && !file.type.match(value);
          }, true);
      if (isNotSupported) {
        this.resetFile(index);
        this.showMessage('Error', 'File not supported', 'error');
        return;
      }
    }
    // Validate if file size is within limit
    if (this.lstFileTypes[index].UAC_maxSize__c && Math.round(file.size / 1024) > this
      .lstFileTypes[
        index].UAC_maxSize__c) {
      this.resetFile(index);
      this.showMessage('Error',
        `File cannot be larger than ${this.lstFileTypes[index].UAC_maxSize__c/1024} MB.`,
        'error');
      return;
    }
    this.readFile(index, file);
  }

  /**
   * @description Method to read input file data and store it as UAC_FileWrapper object for upload
   * @author Sachet Khanal (Deloitte)
   * @param {Object} file input file object to read
   */
  readFile(index, file) {
    var reader = new FileReader();
    reader.onloadend = () => {
      const dataURL = reader.result;
      const base64data = dataURL.match(/,(.*)$/)[1];
      this.lstFileTypes[index].file = {
        idParent: this.recordId,
        strFileName: file.name,
        strContentType: file.type,
        strBase64Data: base64data,
        strFileType: this.lstFileTypes[index].Label
      };
      this.isLoading = false;
    }
    this.isLoading = true;
    reader.readAsDataURL(file);
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
}