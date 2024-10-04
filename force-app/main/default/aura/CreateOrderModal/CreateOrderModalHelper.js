({
  loadData: function (component, helper) {
    component.set('v.isDataLoading', true);

    let action = component.get('c.getProductPrices');
    action.setStorable();
    action.setParams({ opportunityId: component.get('v.recordId') });

    action.setCallback(this, function (response) {
      let discountPercent = component.get('v.discount');
      let state = response.getState();
      if (state === 'SUCCESS') {
        let pageSize = component.get('v.pageSize');
        let pageCount = Math.ceil(response.getReturnValue().length / pageSize);

        component.set('v.totalPages', pageCount);

        let allData = response.getReturnValue().map((item) => {
          return {
            Id: item.Id,
            ProductName: item.Product2.Name,
            ProductCode: item.Product2.ProductCode,
            Description: item.Product2.Description,
            OriginalPrice: item.UnitPrice,
            UnitPrice: item.UnitPrice * (1 - discountPercent / 100)
          };
        });

        component.set('v.allData', allData);
        component.set('v.filteredData', allData);
        component.set('v.currentPageNumber', 1);
        component.set('v.isDataLoading', false);
        helper.buildData(component, helper);
      }
    });

    $A.enqueueAction(action);
  },

  buildData: function (component, helper) {
    var data = [];
    var pageNumber = component.get('v.currentPageNumber');
    var pageSize = component.get('v.pageSize');
    var filteredData = component.get('v.filteredData');
    var x = (pageNumber - 1) * pageSize;

    for (; x < pageNumber * pageSize; x++) {
      if (filteredData[x]) {
        data.push(filteredData[x]);
      }
    }
    component.set('v.data', data);
    helper.generatePageList(component, pageNumber);
    component.set('v.selection', component.get('v.selection'));
  },

  buildDataForNewFilter: function (component, helper) {
    helper.setFilteredData(component);
    let filteredData = component.get('v.filteredData');

    component.set(
      'v.totalPages',
      Math.max(1, Math.ceil(filteredData.length / component.get('v.pageSize')))
    );
    component.set('v.currentPageNumber', 1);

    helper.buildData(component, helper);
  },

  setFilteredData: function (component) {
    let allData = component.get('v.allData');
    let filter = component.get('v.filter');

    if (!filter) {
      component.set('v.filteredData', allData);
      return;
    }

    let filteredData = allData.filter(function (item) {
      return item.ProductName.toLowerCase().includes(filter.toLowerCase());
    });

    component.set('v.filteredData', filteredData);
  },

  calculateOrderTotal: function (component) {
    let data = component.get('v.data');
    let orderTotal = data.reduce((acc, item) => {
      return acc + item.Quantity * item.UnitPrice;
    }, 0);

    let currencyCode = $A.get('$Locale.currencyCode');
    let formattedCurrency = orderTotal.toFixed(2) + ' ' + currencyCode;

    component.set('v.totalPrice', formattedCurrency);
  },

  createOrder: function (component, helper) {
    let data = component.get('v.data');
    let action = component.get('c.createNewOrder');
    component.set('v.isDataLoading', true);

    action.setParams({
      opportunityId: component.get('v.recordId'),
      priceBookEntries: data.map((item) => item.Id),
      productPrices: data.map((item) => item.UnitPrice),
      quantities: data.map((item) => item.Quantity)
    });

    action.setCallback(this, function (response) {
      let state = response.getState();

      if (state === 'SUCCESS') {
        helper.showToast(
          $A.get('$Label.c.Success'),
          $A.get('$Label.c.Order_Created_Toast'),
          'success'
        );

        $A.get('e.force:closeQuickAction').fire();
      }
      if (state === 'ERROR') {
        helper.showToast(
          $A.get('$Label.c.Error'),
          response.getError()[0].message,
          'error'
        );
      }
      component.set('v.isDataLoading', false);
    });
    $A.enqueueAction(action);
  },

  closeOpportunity: function (component, helper) {
    let action = component.get('c.closeOpportunity');
    action.setParams({ opportunityId: component.get('v.recordId') });
    $A.enqueueAction(action);
  },

  getOpportunityDiscount: function (component, helper) {
    let action = component.get('c.getTotalDiscountForOpportunity');
    let recordId = component.get('v.recordId');

    action.setParams({ opportunityId: recordId });
    action.setStorable();
    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === 'SUCCESS') {
        component.set('v.discount', response.getReturnValue() || 0);
      }
    });

    $A.enqueueAction(action);
  },

  setDefaultSelectionColumns: function (component) {
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
        label: $A.get('$Label.c.Description'),
        fieldName: 'Description',
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
      }
    ]);
  },

  setSummaryColumns: function (component) {
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
  },

  insertSelectedData: function (component, helper) {
    let selectedIds = component.get('v.selection');
    let allData = component.get('v.allData');
    let selectedData = allData.filter(function (item) {
      return selectedIds.includes(item.Id);
    });
    selectedData.forEach((item) => (item.Quantity = 0));
    component.set('v.data', selectedData);
  },

  generatePageList: function (component, pageNumber) {
    pageNumber = parseInt(pageNumber);
    var pageList = [];
    var totalPages = component.get('v.totalPages');
    if (totalPages > 1) {
      if (totalPages <= 10) {
        var counter = 2;
        for (; counter < totalPages; counter++) {
          pageList.push(counter);
        }
      } else {
        if (pageNumber < 5) {
          pageList.push(2, 3, 4, 5, 6);
        } else {
          if (pageNumber > totalPages - 5) {
            pageList.push(
              totalPages - 5,
              totalPages - 4,
              totalPages - 3,
              totalPages - 2,
              totalPages - 1
            );
          } else {
            pageList.push(
              pageNumber - 2,
              pageNumber - 1,
              pageNumber,
              pageNumber + 1,
              pageNumber + 2
            );
          }
        }
      }
    }
    component.set('v.pageList', pageList);
  },

  showToast: function (title, message, type) {
    let toastEvent = $A.get('e.force:showToast');

    toastEvent.setParams({
      title: title,
      message: message,
      type: type
    });

    toastEvent.fire();
  }
});
