import { LightningElement, wire } from 'lwc';
import getOpenRequests from '@salesforce/apex/ServiceRequestController.getOpenRequests';

export default class ServiceRequestDashboard extends LightningElement {
    requests;
    error;

    @wire(getOpenRequests)
    wiredRequests({ data, error }) {
        if (data) {
            this.requests = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.requests = undefined;
        }
    }
}