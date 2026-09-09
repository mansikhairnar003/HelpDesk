import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import REQUEST_SELECTED_CHANNEL from '@salesforce/messageChannel/RequestSelected__c';

const COLUMNS = [
    { label: 'Request', fieldName: 'Name', type: 'text' },
    { label: 'Subject', fieldName: 'Subject__c', type: 'text' },
    { label: 'Category', fieldName: 'Category__c', type: 'text' },
    { label: 'Priority', fieldName: 'Priority__c', type: 'text' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: 'SLA Deadline', fieldName: 'SLA_Deadline__c', type: 'date' },
    {
        type: 'button',
        typeAttributes: { label: 'View', name: 'view', variant: 'brand' }
    }
];

export default class RequestList extends LightningElement {
    @api requests = [];
    columns = COLUMNS;

    @wire(MessageContext)
    messageContext;

    get hasData() {
        return this.requests && this.requests.length > 0;
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.publishRequestSelected(row.Id);
    }

    publishRequestSelected(recordId) {
        publish(this.messageContext, REQUEST_SELECTED_CHANNEL, { recordId });
    }
}