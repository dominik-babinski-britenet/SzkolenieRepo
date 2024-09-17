({
  loadData: function (component, helper) {
    let action = component.get('c.getProductPrices');
    action.setStorable();
    action.setCallback(this, function (response) {
      console.log(response.state);
      let state = response.getState();
      console.log('Hello');
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
        component.set('v.currentPageNumber', 1);
        console.log(
          `component.get('v.allData'): ${JSON.stringify(component.get('v.allData'))}`
        );
        helper.buildData(component, helper);
      }
    });
    $A.enqueueAction(action);
  },
  /*
   * this function will build table data
   * based on current page selection
   * */
  buildData: function (component, helper) {
    var data = [];
    var pageNumber = component.get('v.currentPageNumber');
    var pageSize = component.get('v.pageSize');
    var allData = component.get('v.allData');
    var x = (pageNumber - 1) * pageSize;

    //creating data-table data
    for (; x < pageNumber * pageSize; x++) {
      if (allData[x]) {
        data.push(allData[x]);
      }
    }
    component.set('v.data', data);
    console.log(`data: ${JSON.stringify(data)}`);

    helper.generatePageList(component, pageNumber);
  },

  /*
   * this function generate page list
   * */
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
