import { LightningElement, wire, api } from 'lwc';
import getOrderItemsForOrder from '@salesforce/apex/ReturnOrdersController.getOrderItemsForOrder';
import { CurrentPageReference } from 'lightning/navigation';

export default class ReturnOrderItemChoice extends LightningElement {
  recordId;
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

  @wire(CurrentPageReference)
  getPageReference(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.c__recordId;
    }
  }

  @wire(getOrderItemsForOrder, { orderId: '$recordId' })
  wiredOrderItems(result) {
    if (!this.recordId) {
      return;
    }

    this.wiredResult = result;
    const { data, error } = result;

    if (data) {
      this.gridData = data.map((item) => {
        return {
          Id: item.Id,
          Name: item.Product2.Name,
          ProductExternalId: item.Product2.ProductExternalId__c,
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

    if (this.selectedRows.length() <= 0) {
      return false;
    }

    for (let selectedRow of this.selectedRows) {
      let draftValueForRow = draftValues.find((row) => row.Id === selectedRow);
      let returnItemQuantity = draftValueForRow
        ? Number(draftValueForRow.ReturnedQuantity)
        : 0;
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
