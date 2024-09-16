import { LightningElement, track, wire } from 'lwc';
import getAllDiscounts from '@salesforce/apex/DiscountDataViewController.getAllDiscounts';
import { refreshApex } from '@salesforce/apex';

export default class DiscountDataView extends LightningElement {
  @track gridData;
  @track gridColumns = [
    {
      type: 'url',
      label: 'Name',
      fieldName: 'link',
      initialWidth: 200,
      typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_blank'
      }
    },
    {
      label: 'Discount Value',
      fieldName: 'DiscountValue__c',
      initialWidth: 150
    },
    {
      label: 'Requirement',
      fieldName: 'Discount_Requirement__c',
      initialWidth: 700
    },
    {
      label: 'Active',
      fieldName: 'IsActive__c',
      initialWidth: 75,
      type: 'boolean'
    },
    {
      label: '',
      fieldName: '',
      type: 'button-icon',
      initialWidth: 50,
      typeAttributes: {
        name: 'edit',
        iconName: 'utility:edit',
        title: 'Edit',
        variant: 'border-filled',
        alternativeText: 'Edit'
      },
      cellAttributes: {
        class: { fieldName: 'editButtonClass' }
      }
    },
    {
      label: '',
      fieldName: '',
      type: 'button-icon',
      initialWidth: 50,
      typeAttributes: {
        name: 'delete',
        iconName: 'utility:delete',
        title: 'Delete',
        variant: 'border-filled',
        alternativeText: 'Delete'
      },
      cellAttributes: {
        class: { fieldName: 'deleteButtonClass' }
      }
    }
  ];

  isModalOpen = false;
  isEditModalOpen = false;
  isCreateModalOpen = false;
  selectedRecordId;
  selectedRecordName;

  @wire(getAllDiscounts)
  wiredDiscounts(result) {
    this.wiredDiscountsResult = result;
    const { data, error } = result;
    if (data) {
      this.gridData = data.map((discount) => {
        const accountChildren = discount.AccountDiscounts__r
          ? discount.AccountDiscounts__r.map((account) => ({
              Id: account.Account__r.Id,
              Name: account.Account__r.Name,
              link: `/${account.Account__c}`,
              isChild: true,
              editButtonClass: 'slds-hide',
              deleteButtonClass: 'slds-hide'
            }))
          : [];
        return {
          ...discount,
          _children: accountChildren,
          Discount_Requirement__c: String(
            discount.Discount_Requirement__c
          ).replace(
            '<Requirement_Value>',
            discount.Discount_Requirement_Value__c
          ),
          Name: discount.Name,
          link: `/${discount.Id}`,
          DiscountValue__c: discount.DiscountValue__c.toFixed(2) + '%',
          isChild: false
        };
      });
    } else if (error) {
      console.error(error);
    }
  }

  handleRowAction(event) {
    if (event.detail.action.name === 'delete') {
      const row = event.detail.row;
      this.selectedRecordId = row.Id;
      this.selectedRecordName = row.Name;
      this.isModalOpen = true;
    }
    if (event.detail.action.name === 'edit') {
      const row = event.detail.row;
      this.selectedRecordId = row.Id;
      this.selectedRecordName = row.Name;
      this.isEditModalOpen = true;
    }
  }

  handleCreateButtonClick() {
    this.isCreateModalOpen = true;
  }

  handleModalClose() {
    this.isModalOpen = false;
    this.isEditModalOpen = false;
    this.isCreateModalOpen = false;
  }

  handleCreate() {
    refreshApex(this.wiredDiscountsResult);
    this.isCreateModalOpen = false;
  }

  handleEdit() {
    refreshApex(this.wiredDiscountsResult);
    this.isEditModalOpen = false;
  }

  handleDeleteConfirmed() {
    refreshApex(this.wiredDiscountsResult);
    this.isModalOpen = false;
  }
}
