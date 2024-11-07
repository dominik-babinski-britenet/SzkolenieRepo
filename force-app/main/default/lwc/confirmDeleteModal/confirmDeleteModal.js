import { LightningElement, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConfirmDeleteModal extends LightningElement {
  @api recordId;
  @api recordName;

  handleClose() {
    this.dispatchEvent(new CustomEvent('close'));
  }

  handleDelete() {
    deleteRecord(this.recordId)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Record deleted',
            variant: 'success'
          })
        );
        this.dispatchEvent(new CustomEvent('delete'));
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: error.body.message,
            variant: 'error'
          })
        );
      });
  }
}
