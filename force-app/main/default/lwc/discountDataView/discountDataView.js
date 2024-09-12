import { LightningElement, wire, track } from 'lwc';
import getAllDiscounts from '@salesforce/apex/DiscountDataViewController.getAllDiscounts';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import DISCOUNT_REQUIREMENT_FIELD from '@salesforce/schema/Discount__c.Discount_Requirement__c'; // Import picklist field

export default class DiscountDataView extends LightningElement {
  // Define columns for the tree grid
  gridColumns = [
    { label: 'Name', fieldName: 'Name', initialWidth: 175 },
    {
      label: 'Discount Value',
      fieldName: 'DiscountValue__c',
      initialWidth: 75
    },
    {
      label: 'Discount Requirement',
      fieldName: 'Discount_Requirement__c',
      initialWidth: 500
    },
    {
      label: 'Discount Requirement Value',
      fieldName: 'Discount_Requirement_Value__c',
      initialWidth: 150
    },
    {
      label: 'Is Active',
      fieldName: 'IsActive__c',
      initialWidth: 50,
      type: 'boolean'
    },
    {
      label: 'Delete',
      fieldName: '',
      type: 'button-icon',
      initialWidth: 50,
      typeAttributes: {
        iconName: 'utility:delete',
        title: 'Delete',
        variant: 'border-filled',
        alternativeText: 'Delete',
        disabled: false
      }
    }
  ];

  @track gridData;
  @track error;

  // Object to map picklist API values to UI labels
  picklistValuesMap = {};

  // Fetch picklist values for Discount_Requirement__c
  @wire(getPicklistValues, {
    recordTypeId: '012000000000000AAA',
    fieldApiName: DISCOUNT_REQUIREMENT_FIELD
  })
  wiredPicklistValues({ error, data }) {
    if (data) {
      // Create a map of picklist API values to UI labels
      this.picklistValuesMap = data.values.reduce((map, item) => {
        map[item.value] = item.label;
        return map;
      }, {});
    } else if (error) {
      console.error('Error fetching picklist values:', error);
    }
  }

  // Fetch discount data and map picklist API values to UI labels
  @wire(getAllDiscounts)
  wireGridData({ data, error }) {
    if (data) {
      // Map API values of Discount_Requirement__c to UI labels
      this.gridData = data.map((record) => ({
        ...record,
        Discount_Requirement__c:
          this.picklistValuesMap[record.Discount_Requirement__c] ||
          record.Discount_Requirement__c
      }));
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.gridData = undefined;
      console.error('Error fetching discount data:', error);
    }
  }
}
