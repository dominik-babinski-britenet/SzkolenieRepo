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

  filter: function (component, event, helper) {
    let allData = component.get('v.allData');
    let filter = component.get('v.filter');
    let filteredData = allData.filter(function (item) {
      return item.ProductName.toLowerCase().includes(filter.toLowerCase());
    });
    component.set('v.data', filteredData);
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
