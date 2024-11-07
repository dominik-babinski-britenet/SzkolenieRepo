import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendRecordToApproval from '@salesforce/apex/ApproveReturnItemController.CreateApprovalRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ERROR_RETURN_STRATEGY from '@salesforce/label/c.Error_Strategy_Selection';
import ERROR_ITEM_ALREADY_PROCESSED from '@salesforce/label/c.Error_Item_Already_In_Process';
import SUCCESS_APPROVAL_REQUEST from '@salesforce/label/c.Success_Approval_Request';
import TITLE_CREATE_APPROVAL from '@salesforce/label/c.Title_Create_Approval';
import LABEL_INPUT_COMMENT from '@salesforce/label/c.Input_Comment';
import BUTTON_SEND_APPROVAL from '@salesforce/label/c.Button_Send_Approval';

export default class ApproveReturnItem extends LightningElement {
  @api recordId;
  comment = '';
  titleCreateApproval = TITLE_CREATE_APPROVAL;
  inputComment = LABEL_INPUT_COMMENT;
  buttonSendApproval = BUTTON_SEND_APPROVAL;

  async handleSave() {
    const strategyField = this.template.querySelector(
      '[data-id="strategyField"]'
    );

    const strategyValue = strategyField.value;

    if (!strategyValue || strategyValue.includes('None')) {
      this.showToast('error', ERROR_RETURN_STRATEGY);

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
      this.showToast('success', SUCCESS_APPROVAL_REQUEST);
    } catch (error) {
      this.showToast('error', ERROR_ITEM_ALREADY_PROCESSED);
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
