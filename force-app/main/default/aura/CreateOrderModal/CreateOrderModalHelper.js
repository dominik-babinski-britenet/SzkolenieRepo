({
  loadData: function (component, helper) {
    let action = component.get('c.getProductPrices');
    action.setStorable();
    action.setCallback(this, function (response) {
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
            UnitPrice: item.UnitPrice
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

  getOpportunityDiscount: function (component, helper) {
    let action = component.get('c.getTotalDiscountForOpportunity');
    let recordId = component.get('v.recordId');

    action.setParams({ recordId: recordId });
    action.setStorable();
    action.setCallback(this, function (response) {
      let state = response.getState();
      console.log(response.getState());
      if (state === 'SUCCESS') {
        console.log(response.getReturnValue());
        component.set('v.discount', response.getReturnValue());
      }
    });

    $A.enqueueAction(action);
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
