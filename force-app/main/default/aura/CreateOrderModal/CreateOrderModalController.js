({
  init: function (component, event, helper) {
    component.set('v.columns', [
      { label: 'Product Name', fieldName: 'ProductName', type: 'text' },
      {
        label: 'Product Code',
        fieldName: 'ProductCode',
        type: 'text'
      },
      { label: 'Description', fieldName: 'Description', type: 'text' },
      { label: 'Price', fieldName: 'UnitPrice', type: 'currency' }
    ]);

    helper.getOpportunityDiscount(component, helper);
    helper.loadData(component, helper);
  },

  handleRowSelection: function (component, event) {
    var selectedRows = event.getParam('selectedRows');
    var allSelectedRows = component.get('v.selection') || [];

    selectedRows.forEach(function (row) {
      if (!allSelectedRows.some((existingRow) => existingRow === row.Id)) {
        allSelectedRows.push(row.Id);
      }
    });

    component.set('v.selection', allSelectedRows);
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
