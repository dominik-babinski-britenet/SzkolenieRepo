import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditDiscountModal extends LightningElement {
  @api recordId;

  handleClose() {
    this.dispatchEvent(new CustomEvent('close'));
  }

  handleSuccess() {
    this.dispatchEvent(new CustomEvent('edit'));
    const toastEvent = new ShowToastEvent({
      title: 'Success',
      message: 'Discount record updated successfully!',
      variant: 'success'
    });
    this.dispatchEvent(toastEvent);
    this.dispatchEvent(new CustomEvent('close'));
  }

  handleError(event) {
    const toastEvent = new ShowToastEvent({
      title: 'Error',
      message: event.detail.message,
      variant: 'error'
    });
    this.dispatchEvent(toastEvent);
  }
}
