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

  @api
  isDataValid() {
    let draftValues = this.template.querySelector(
      'lightning-datatable'
    ).draftValues;
    let data = this.gridData;
    console.log(`draftValues: ${JSON.stringify(draftValues)}`);
    console.log(`data: ${JSON.stringify(data)}`);

    for (let selectedRow of this.selectedRows) {
      let draftValueForRow = draftValues.find((row) => row.Id === selectedRow);
      console.log(`draftValueForRow: ${JSON.stringify(draftValueForRow)}`);
      let returnItemQuantity = draftValueForRow
        ? Number(draftValueForRow.ReturnedQuantity)
        : 0;
      console.log(`returnItemQuantity: ${JSON.stringify(returnItemQuantity)}`);
      let gridItem = data.find((item) => item.Id === selectedRow);
      let totalQuantityOfItem = gridItem ? Number(gridItem.Quantity) : 0;

      if (returnItemQuantity > totalQuantityOfItem || returnItemQuantity <= 0) {
        return false;
      }
    }

    return true;
  }

  @api
  getSelectedData() {
    let sentData = [];
    let draftData = this.template.querySelector(
      'lightning-datatable'
    ).draftValues;

    try {
      for (let selectedRow of this.selectedRows) {
        let gridElement = this.gridData.find((row) => row.Id === selectedRow);
        let draftRow = draftData.find((row) => row.Id === selectedRow);
        gridElement.ReturnedQuantity = draftRow ? draftRow.ReturnedQuantity : 0;
        sentData.push(gridElement);
      }
    } catch (e) {
      console.log(e.message);
    }

    return sentData;
  }
}
