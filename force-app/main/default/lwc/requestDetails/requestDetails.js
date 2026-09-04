import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import REQUEST_SELECTED_CHANNEL from '@salesforce/messageChannel/RequestSelected__c';
import getRequestDetails from '@salesforce/apex/ServiceRequestController.getRequestDetails';

export default class RequestDetails extends LightningElement {
    selectedRecordId;
    requestDetails;
    isLoading = false;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToChannel();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    subscribeToChannel() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            REQUEST_SELECTED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.selectedRecordId = message.recordId;
        this.loadRequestDetails();
    }

    loadRequestDetails() {
        this.isLoading = true;
        getRequestDetails({ requestId: this.selectedRecordId })
            .then((data) => {
                this.requestDetails = data;
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Error loading details:', JSON.stringify(error));
                this.isLoading = false;
            });
    }

    get hasSelection() {
        return this.selectedRecordId != null;
    }
    get employeeName() {
        return this.requestDetails?.Employee__r?.Name || 'Not Assigned';
    }
    get isResolved() {
        return this.requestDetails?.Status__c === 'Resolved';
    }
}