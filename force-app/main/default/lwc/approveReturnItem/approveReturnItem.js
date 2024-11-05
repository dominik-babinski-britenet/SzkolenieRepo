import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendRecordToApproval from '@salesforce/apex/ApproveReturnItemController.CreateApprovalRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ApproveReturnItem extends LightningElement {
  @api recordId;
  comment = '';

  async handleSave() {
    const strategyField = this.template.querySelector(
      '[data-id="strategyField"]'
    );

    const strategyValue = strategyField.value;

    if (!strategyValue || strategyValue.includes('None')) {
      this.showToast(
        'error',
        'Please select a Return Strategy before sending to approval.'
      );

      return;
    }

    const data = {
      strategy: strategyValue,
      comment: this.comment,
      recordId: this.recordId
    };

    try {
      await sendRecordToApproval(data);
      this.dispatchEvent(new CloseActionScreenEvent());
      this.showToast('success', 'Approval Request sent successfully.');
    } catch (error) {
      this.showToast('error', 'Item already in approval process.');
    }
  }

  showToast(type, message) {
    const event = new ShowToastEvent({
      title: this.getTitle(type),
      message: message,
      variant: type,
      mode: 'dismissable'
    });
    this.dispatchEvent(event);
  }

  getTitle(type) {
    switch (type) {
      case 'success':
        return 'Success';
      case 'error':
        return 'Error';
      case 'warning':
        return 'Warning';
      case 'info':
      default:
        return 'Information';
    }
  }
}
