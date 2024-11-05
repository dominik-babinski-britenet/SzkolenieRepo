import { LightningElement, wire } from 'lwc';
import createJunctions from '@salesforce/apex/ReturnOrdersController.insertJunctionObjects';
import sendItemsViaRest from '@salesforce/apex/ReturnOrdersController.sendExternalItems';
import createCase from '@salesforce/apex/ReturnOrdersController.createCase';
import filterExternalProducts from '@salesforce/apex/ReturnOrdersController.filterExternalItems';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReturnOrder extends LightningElement {
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
      this.subjectVal = `Return order for ${recordId}`;
    }
  }

  async handleFormSubmit(event) {
    try {
      if (!this.checkIfTableIsValid()) {
        this.showToast(
          'error',
          'Invalid data, please ensure you have any products selected and returned quantity is correct for each product.'
        );
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
        this.showToast('success', 'Return request created succesfully.');
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
      this.showToast('success', 'Return request created succesfully.');
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
