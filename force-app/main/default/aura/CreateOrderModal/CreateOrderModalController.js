({
  init: function (component, event, helper) {
    helper.setDefaultSelectionColumns(component);
    helper.getOpportunityDiscount(component, helper);
    helper.loadData(component, helper);
  },

  displaySummary: function (component, event, helper) {
    if (component.get('v.selection').length <= 0) {
      let toastEvent = $A.get('e.force:showToast');

      toastEvent.setParams({
        title: 'Warning',
        message: 'No items are selected.',
        type: 'warning'
      });

      toastEvent.fire();
      return;
    }

    component.set('v.columns', [
      {
        label: $A.get('$Label.c.Product_Name'),
        fieldName: 'ProductName',
        type: 'text'
      },
      {
        label: $A.get('$Label.c.Product_Code'),
        fieldName: 'ProductCode',
        type: 'text'
      },
      {
        label: $A.get('$Label.c.Original_Price'),
        fieldName: 'OriginalPrice',
        type: 'currency'
      },
      {
        label: $A.get('$Label.c.Discounted_Price'),
        fieldName: 'UnitPrice',
        type: 'currency'
      },
      {
        label: $A.get('$Label.c.Quantity'),
        fieldName: 'Quantity',
        type: 'number',
        editable: true
      }
    ]);

    component.set('v.selectionPage', false);
    helper.insertSelectedData(component, helper);
    helper.calculateOrderTotal(component);
  },

  handleSaveEdition: function (component, event, helper) {
    var idQuantityPairs = event.getParam('draftValues');
    var data = component.get('v.data');

    idQuantityPairs.forEach((draftValue) => {
      let recordToUpdate = data.find((record) => record.Id === draftValue.Id);
      if (recordToUpdate) {
        recordToUpdate.Quantity = draftValue.Quantity;
      }
    });

    component.set('v.data', data);
    component.set('v.draftValues', []);
    component.set('v.priceSummary', 'Discount: ${}Total Price: ${} ');
    helper.calculateOrderTotal(component);
  },

  returnToSelection: function (component, event, helper) {
    helper.setDefaultSelectionColumns(component);
    component.set('v.data', component.get('v.allData'));
    helper.recalculateFilter(component, helper);
    component.set('v.selectionPage', true);
  },

  completeOrder: function (component, event, helper) {
    let data = component.get('v.data');

    if (data.some((item) => item.Quantity <= 0)) {
      let toastEvent = $A.get('e.force:showToast');

      toastEvent.setParams({
        title: $A.get('$Label.c.Error'),
        message: $A
          .get('$Label.c.Item_Quantity_Error')
          .replace('${item.ProductName}', item.ProductName),
        type: 'error'
      });

      toastEvent.fire();
      return;
    }

    helper.createOrder(component);
  },

  handleRowSelection: function (component, event) {
    var selectedRows = event.getParam('selectedRows') || [];
    var visibleData = component.get('v.data') || [];
    var currentSelection = component.get('v.selection') || [];

    var selectedRowIds = selectedRows.map((row) => row.Id);
    var visibleDataIds = visibleData.map((row) => row.Id);

    selectedRowIds.forEach(function (id) {
      if (!currentSelection.includes(id)) {
        currentSelection.push(id);
      }
    });

    currentSelection = currentSelection.filter(function (id) {
      return selectedRowIds.includes(id) || !visibleDataIds.includes(id);
    });

    component.set('v.selection', currentSelection);
  },

  filter: function (component, event, helper) {
    helper.recalculateFilter(component, helper);
  },

  onNext: function (component, event, helper) {
    var pageNumber = component.get('v.currentPageNumber');
    component.set('v.currentPageNumber', pageNumber + 1);
    helper.buildData(component, helper);
  },

  onPrev: function (component, event, helper) {
    var pageNumber = component.get('v.currentPageNumber');
    component.set('v.currentPageNumber', pageNumber - 1);
    helper.buildData(component, helper);
  },

  processMe: function (component, event, helper) {
    component.set('v.currentPageNumber', parseInt(event.target.name));
    helper.buildData(component, helper);
  },

  onFirst: function (component, event, helper) {
    component.set('v.currentPageNumber', 1);
    helper.buildData(component, helper);
  },

  onLast: function (component, event, helper) {
    component.set('v.currentPageNumber', component.get('v.totalPages'));
    helper.buildData(component, helper);
  }
});
