import { LightningElement } from 'lwc';
import createJunctions from '@salesforce/apex/ReturnOrdersController.insertJunctionObjects';
import sendItemsViaRest from '@salesforce/apex/ReturnOrdersController.sendExternalItems';
import createCase from '@salesforce/apex/ReturnOrdersController.createCase';
import filterExternalProducts from '@salesforce/apex/ReturnOrdersController.filterExternalItems';
import { subscribe, unsubscribe } from 'lightning/empApi';

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
      console.log(
        `table.isDataValid(): ${JSON.stringify(table.isDataValid())}`
      );
      return table.isDataValid();
    } catch (e) {
      console.log('halohalo');
      console.log(e.message);
      return false;
    }
  }

  connectedCallback() {
    //TODO: Throw it out
    //this.subscribeToReturnEvent();
  }

  async handleFormSubmit() {
    if (!this.isTableValid()) {
      return;
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

      if (externalItems.size() > 0) {
        await this.sendExternalItems(caseExternalId);
        this.subscribeToReturnEvent();
      } else {
        this.isLoading = false;
      }
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

  async sendExternalItems(caseExternalId) {
    const data = { caseExternalId: caseExternalId };
    try {
      await sendItemsViaRest(data);
    } catch (error) {
      console.error(error);
    }
  }

  async createCase() {
    const data = {
      caseStatus: this.statusVal,
      caseSubject: this.subjectVal,
      caseDescription: this.descriptionVal
    };

    await createCase(data);
  }

  async createJunctionItems(caseId, caseExternalId) {
    let tableData = this.refs.table.getSelectedData();
    let junctionObjectData = [];

    //TODO: Review created data
    for (let row of tableData) {
      junctionObjectData.push({
        Case__c: caseId,
        Case_External_Id__c: caseExternalId,
        Order_Product__c: row.Id,
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
}
