import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateDiscountModal extends LightningElement {
  @api recordTypeId;

  handleClose() {
    this.dispatchEvent(new CustomEvent('close'));
  }

  handleSuccess(event) {
    this.dispatchEvent(new CustomEvent('close'));
    this.dispatchEvent(new CustomEvent('create'));
    const evt = new ShowToastEvent({
      title: 'Success',
      message: 'Discount record created with Id: ' + event.detail.id,
      variant: 'success'
    });
    this.dispatchEvent(evt);
  }

  handleError(event) {
    const evt = new ShowToastEvent({
      title: 'Error',
      message: 'Error creating Discount record: ' + event.detail.message,
      variant: 'error'
    });
    this.dispatchEvent(evt);
  }
}
