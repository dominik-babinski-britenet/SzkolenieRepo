({
  loadData: function (component, helper) {
    let action = component.get('c.getProductPrices');

    action.setStorable();
    action.setCallback(this, function (response) {
      let discountPercent = component.get('v.discount');
      let state = response.getState();
      if (state === 'SUCCESS') {
        component.set(
          'v.totalPages',
          Math.ceil(
            response.getReturnValue().length / component.get('v.pageSize')
          )
        );

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
        helper.buildData(component, helper);
      }
    });

    $A.enqueueAction(action);
  },
  createOrder: function (component) {
    let data = component.get('v.data');
    console.log(`data: ${JSON.stringify(data)}`);
    let action = component.get('c.createNewOrder');

    action.setParams({
      opportunityId: component.get('v.recordId'),
      priceBookEntries: data.map((item) => item.Id),
      productPrices: data.map((item) => item.UnitPrice),
      quantities: data.map((item) => item.Quantity)
    });

    console.log(
      `data.map((item)=> item.Id): ${JSON.stringify(data.map((item) => item.Id))}`
    );

    action.setCallback(this, function (response) {
      let state = response.getState();
      console.log(state);

      if (state === 'SUCCESS') {
        let toastEvent = $A.get('e.force:showToast');

        toastEvent.setParams({
          title: $A.get('$Label.c.Success'),
          message: $A.get('$Label.c.Order_Created_Toast'),
          type: 'success'
        });

        toastEvent.fire();
        $A.get('e.force:closeQuickAction').fire();
      }
      if (state === 'ERROR') {
        let toastEvent = $A.get('e.force:showToast');

        toastEvent.setParams({
          title: $A.get('$Label.c.Error'),
          message: response.getError()[0].message,
          type: 'error'
        });

        toastEvent.fire();
      }
    });
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
        component.set('v.discount', response.getReturnValue());
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

  insertSelectedData: function (component, helper) {
    let selectedIds = component.get('v.selection');
    let allData = component.get('v.allData');
    let selectedData = allData.filter(function (item) {
      return selectedIds.includes(item.Id);
    });
    selectedData.forEach((item) => (item.Quantity = 0));
    component.set('v.data', selectedData);
  },

  recalculateFilter: function (component, helper) {
    let filteredData = helper.getFilteredData(component);

    component.set(
      'v.totalPages',
      Math.max(1, Math.ceil(filteredData.length / component.get('v.pageSize')))
    );
    component.set('v.currentPageNumber', 1);
    component.set('v.filteredData', filteredData);
    helper.buildData(component, helper);
  },

  getFilteredData: function (component) {
    let allData = component.get('v.allData');
    let filter = component.get('v.filter');
    if (!filter) {
      return allData;
    }
    let filteredData = allData.filter(function (item) {
      return item.ProductName.toLowerCase().includes(filter.toLowerCase());
    });
    return filteredData;
  },

  buildData: function (component, helper) {
    var data = [];
    var pageNumber = component.get('v.currentPageNumber');
    var pageSize = component.get('v.pageSize');
    var allData = component.get('v.filteredData');
    var x = (pageNumber - 1) * pageSize;

    for (; x < pageNumber * pageSize; x++) {
      if (allData[x]) {
        data.push(allData[x]);
      }
    }
    component.set('v.data', data);
    helper.generatePageList(component, pageNumber);
    component.set('v.selection', component.get('v.selection'));
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
  }
});
