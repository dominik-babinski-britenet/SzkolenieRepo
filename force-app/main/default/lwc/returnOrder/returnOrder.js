import { LightningElement, wire } from 'lwc';
import createJunctions from '@salesforce/apex/ReturnOrdersController.insertJunctionObjects';
import sendItemsViaRest from '@salesforce/apex/ReturnOrdersController.sendExternalItems';
import createCase from '@salesforce/apex/ReturnOrdersController.createCase';
import filterExternalProducts from '@salesforce/apex/ReturnOrdersController.filterExternalItems';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RETURN_ORDER_SUBJECT from '@salesforce/label/c.Return_Order_Subject';
import ERROR_INVALID_PRODUCTS from '@salesforce/label/c.Error_Invalid_Return_Products';
import RETURN_REQUEST_SUCCESFULL from '@salesforce/label/c.Success_Return_Request';
import INPUT_STATUS from '@salesforce/label/c.Input_Status';
import INPUT_SUBJECT from '@salesforce/label/c.Input_Subject';
import INPUT_DESCRIPTION from '@salesforce/label/c.Input_Description';
import BUTTON_CREATE from '@salesforce/label/c.Create';
import BUTTON_CANCEL from '@salesforce/label/c.Cancel';

export default class ReturnOrder extends LightningElement {
  inputDescription = INPUT_DESCRIPTION;
  inputSubject = INPUT_SUBJECT;
  inputStatus = INPUT_STATUS;
  buttonCreate = BUTTON_CREATE;
  buttonCancel = BUTTON_CANCEL;

  statusVal = 'New';
  subjectVal = 'Temporary subject';
  channelName = '/event/Case_Created__e';
  caseExternalId = '';
  subscription = {};
  isLoading = false;
  descriptionVal = '';

  checkIfTableIsValid() {
    try {
      const table = this.refs.table;
      return table.isDataValid();
    } catch (e) {
      console.log(e.message);
      return false;
    }
  }

  @wire(CurrentPageReference)
  getPageReference(currentPageReference) {
    if (currentPageReference) {
      let recordId = currentPageReference.state.c__recordId;
      this.subjectVal = RETURN_ORDER_SUBJECT + ` ${recordId}`;
    }
  }

  async handleFormSubmit(event) {
    try {
      if (!this.checkIfTableIsValid()) {
        this.showToast('error', ERROR_INVALID_PRODUCTS);
        return;
      }
    } catch (e) {
      console.log(e.message);
    }
    this.isLoading = true;

    try {
      const resultMap = await this.createCase();
      const caseId = resultMap.caseId;
      const caseExternalId = resultMap.caseExternalId;
      this.caseExternalId = caseExternalId;
      let createdItems = await this.createJunctionItems(caseId, caseExternalId);
      let externalItems = await filterExternalProducts({
        initialItems: createdItems
      });
      if (externalItems.length > 0) {
        await this.sendExternalItems(caseExternalId, externalItems);
        this.subscribeToReturnEvent();
      } else {
        this.isLoading = false;
        this.showToast('success', RETURN_REQUEST_SUCCESFULL);
      }
    } catch (error) {
      this.showToast('error', error.message);
    }
  }

  subscribeToReturnEvent() {
    subscribe(
      this.channelName,
      -1,
      this.handleCaseCreatedCallback.bind(this)
    ).then((subscription) => {
      this.subscription = subscription;
    });
  }

  handleCaseCreatedCallback(response) {
    const payload = response.data.payload;
    const caseId = payload.Case_Identificator__c;

    if (this.caseExternalId !== caseId) {
      return;
    }

    unsubscribe(this.subscription, (msg) => {});
    this.isLoading = false;
  }

  async sendExternalItems(caseExternalId, externalItems) {
    const data = { caseExternalId: caseExternalId, itemsToSend: externalItems };
    try {
      await sendItemsViaRest(data);
      this.showToast('success', RETURN_REQUEST_SUCCESFULL);
    } catch (error) {
      console.error(error);
      this.showToast('error', error.message);
    }
  }

  async createCase() {
    const data = {
      status: this.statusVal,
      subject: this.subjectVal,
      description: this.descriptionVal
    };

    let returnMap = await createCase(data);
    return returnMap;
  }

  async createJunctionItems(caseId, caseExternalId) {
    let tableData = this.refs.table.getSelectedData();
    let junctionObjectData = [];

    for (let row of tableData) {
      junctionObjectData.push({
        Case__c: caseId,
        Case_External_Id__c: caseExternalId,
        Order_Product__c: row.Id,
        Product_External_Id__c: row.ProductExternalId,
        Returned_Quantity__c: row.ReturnedQuantity,
        Status__c: 'Pending',
        Strategy__c: 'None',
        External__c: row.External
      });
    }

    let createdItems = await createJunctions({
      itemsToInsert: junctionObjectData
    });
    return createdItems;
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
