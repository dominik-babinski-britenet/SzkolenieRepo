({
  init: function (component, event, helper) {
    helper.setDefaultSelectionColumns(component);
    helper.getOpportunityDiscount(component, helper);
    helper.loadData(component, helper);
  },

  returnToSelection: function (component, event, helper) {
    helper.setDefaultSelectionColumns(component);
    component.set('v.data', component.get('v.allData'));
    component.set('v.filter', '');
    helper.buildDataForNewFilter(component, helper);
    component.set('v.selectionPage', true);
  },

  displaySummary: function (component, event, helper) {
    if (component.get('v.selection').length <= 0) {
      helper.showToast(
        $A.get('$Label.c.Error'),
        $A.get('$Label.c.No_Items_Selected'),
        'error'
      );
      return;
    }

    component.set('v.selectionPage', false);
    helper.setSummaryColumns(component);
    helper.insertSelectedData(component, helper);
    helper.calculateOrderTotal(component);
  },

  filter: function (component, event, helper) {
    helper.buildDataForNewFilter(component, helper);
  },

  handleSaveEdition: function (component, event, helper) {
    var draftValues = event.getParam('draftValues');
    var data = component.get('v.data');

    draftValues.forEach(({ Id, Quantity }) => {
      const record = data.find((record) => record.Id === Id);
      if (record) {
        record.Quantity = Quantity;
      }
    });

    component.set('v.data', data);
    component.set('v.draftValues', []);
    helper.calculateOrderTotal(component);
  },

  completeOrder: function (component, event, helper) {
    let data = component.get('v.data');

    if (data.some((item) => item.Quantity <= 0)) {
      helper.showToast(
        $A.get('$Label.c.Error'),
        $A
          .get('$Label.c.Item_Quantity_Error')
          .replace('${item.ProductName}', item.ProductName),
        'error'
      );
      return;
    }

    helper.createOrder(component, helper);
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
