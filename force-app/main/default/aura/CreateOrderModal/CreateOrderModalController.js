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

    helper.loadData(component, helper);
  },

  handleRowSelection: function (component, event) {
    var selectedRows = event.getParam('selectedRows');
    var allSelectedRows = component.get('v.selection') || [];

    // Merge newly selected rows with existing ones
    selectedRows.forEach(function (row) {
      if (!allSelectedRows.some((existingRow) => existingRow.Id === row.Id)) {
        allSelectedRows.push(row);
      }
    });

    // Remove rows that are no longer selected in the visible table
    var data = component.get('v.data');
    var filteredSelectedRows = allSelectedRows.filter(function (row) {
      return data.some((dataRow) => dataRow.Id === row.Id);
    });

    component.set('v.selection', filteredSelectedRows);
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
