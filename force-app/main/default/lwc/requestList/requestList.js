import { LightningElement, api } from 'lwc';

export default class RequestList extends LightningElement {
    @api requests = [];

    columns = [
        { label: 'Request', fieldName: 'Name', type: 'text' },
        { label: 'Subject', fieldName: 'Subject__c', type: 'text' },
        { label: 'Category', fieldName: 'Category__c', type: 'text' },
        { label: 'Priority', fieldName: 'Priority__c', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Request Date', fieldName: 'Request_Date__c', type: 'date' },
        { label: 'SLA Deadline', fieldName: 'SLA_Deadline__c', type: 'date' },
        {
            type: 'button',
            typeAttributes: { label: 'View', name: 'view', variant: 'base' }
        }
    ];

    get hasData() {
        return this.requests && this.requests.length > 0;
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.dispatchEvent(new CustomEvent('rowselect', {
            detail: { recordId: row.Id }
        }));
    }
}