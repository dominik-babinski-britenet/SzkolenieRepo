import { LightningElement, wire, api } from 'lwc';
import getOrderItemsForOrder from '@salesforce/apex/ReturnOrdersController.getOrderItemsForOrder';

export default class ReturnOrderItemChoice extends LightningElement {
  draftValues;
  selectedRows;
  gridData;
  gridColumns = [
    {
      label: 'Product Name',
      fieldName: 'Name'
    },
    {
      label: 'Quantity',
      fieldName: 'Quantity'
    },
    {
      label: 'Returned Quantity',
      fieldName: 'ReturnedQuantity',
      type: 'number',
      editable: true
    },
    {
      label: 'External',
      fieldName: 'External',
      type: 'boolean'
    }
  ];

  @wire(getOrderItemsForOrder, { orderId: '801WU00000QrzHkYAJ' })
  wiredOrderItems(result) {
    this.wiredResult = result;
    const { data, error } = result;

    if (data) {
      this.gridData = data.map((item) => {
        return {
          Id: item.Id,
          Name: item.Product2.Name,
          Quantity: item.Quantity,
          ReturnedQuantity: 0,
          External: item.Product2.External__c
        };
      });
      console.log(`data: ${JSON.stringify(data)}`);
    } else if (error) {
      console.log(`error: ${JSON.stringify(error)}`);
    }
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows.map((row) => row.Id);
  }

  @api //checkValidity
  isDataValid() {
    let selection = this.selectedRows;
    console.log(`selection: ${JSON.stringify(selection)}`);
    let draftValues = this.draftValues;
    console.log(`draftValues: ${JSON.stringify(draftValues)}`);
    let data = this.gridData;
    console.log(`data: ${JSON.stringify(data)}`);

    for (let value of selection) {
      let draftValueForRow = draftValues.find(
        (draftValue) => draftValue.Id === value
      );

      if (draftValueForRow) {
        data.find((item) => item.Id === value).ReturnedQuantity =
          draftValueForRow.ReturnedQuantity;
      }
    }

    this.gridData = data;

    for (let row of this.gridData) {
      const quantity = Number(row.Quantity);
      const returnedQuantity = Number(row.returnedQuantity);

      if (quantity < 0 || returnedQuantity > quantity) {
        return false;
      }
    }

    return true;
  }

  @api
  getSelectedData() {}
}