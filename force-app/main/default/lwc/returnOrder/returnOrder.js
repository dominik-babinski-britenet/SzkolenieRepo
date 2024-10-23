import { LightningElement } from 'lwc';
import createJunctions from '@salesforce/apex/ReturnOrdersController.insertJunctionObjects';
import sendItemsViaRest from '@salesforce/apex/ReturnOrdersController.sendExternalItems';
import { subscribe, unsubscribe } from 'lightning/empApi';

export default class ReturnOrder extends LightningElement {
  statusVal = 'New';
  subjectVal = 'Temporary subject';
  channelName = '/event/Case_Created__e';
  subscription = {};
  isLoading = false;

  isTableValid() {
    try {
      const table = this.refs.table;
      return table.isDataValid();
    } catch (e) {
      return false;
    }
  }

  connectedCallback() {
    //TODO: Throw it out
    this.subscribeToReturnEvent();
  }

  async handleFormSubmit() {
    if (!this.isTableValid()) {
      return;
    }
    //
    this.isLoading = true;
    try {
      const caseId = await this.submitForm();
      await this.createJunctionItems(caseId); //alex powiedzial promise.all oraz allsettled
      //check for external products
      //if external products;
      if (true) {
        await this.sendExternalItems();
        this.subscribeToReturnEvent();
        this.isLoading = false;
      }

      //await platform event
    } catch (error) {
      console.error(error);
    }
  }

  subscribeToReturnEvent() {
    console.log('was executed at all');
    subscribe(
      this.channelName,
      -1,
      this.handleCaseCreatedCallback.bind(this)
    ).then((subscription) => {
      this.subscription = subscription;
      console.log('subscribed to event');
    });
  }

  handleCaseCreatedCallback(response) {
    console.log(`response: ${JSON.stringify(response)}`);
    unsubscribe(this.subscription, (msg) => {
      console.log(`msg: ${JSON.stringify(msg)}`);
    });
    this.isLoading = false;
  }

  submitForm() {
    return new Promise((resolve, reject) => {
      const form = this.template.querySelector('lightning-record-edit-form');

      form.addEventListener('success', (event) => {
        resolve(event.detail.id);
      });

      form.addEventListener('error', (event) => {
        reject(event.detail.error);
      });

      form.submit();
    });
  }

  async sendExternalItems(caseId) {
    const data = { caseId: caseId };
    try {
      await sendItemsViaRest(data);
    } catch (error) {
      console.error(error);
    }
  }

  async createJunctionItems(caseId) {
    let tableData = this.refs.table.getSelectedData();
    let junctionObjectData = [];

    //TODO: Review created data
    for (let row of tableData) {
      junctionObjectData.push({
        Case__c: caseId,
        Order_Product__c: row.Id,
        Returned_Quantity__c: row.ReturnedQuantity,
        Status__c: 'Pending',
        Strategy__c: 'None',
        External__c: row.External
      });
    }

    await createJunctions({ junctionObjectData });
  }
}
