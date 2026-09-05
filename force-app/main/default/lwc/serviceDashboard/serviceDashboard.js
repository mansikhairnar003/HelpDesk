import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getAllRequests from '@salesforce/apex/ServiceRequestController.getAllRequests';
import getRequestCounts from '@salesforce/apex/ServiceRequestController.getRequestCounts';
import getPriorityCounts from '@salesforce/apex/ServiceRequestController.getPriorityCounts';
import getSLARiskCount from '@salesforce/apex/ServiceRequestController.getSLARiskCount';

export default class ServiceDashboard extends NavigationMixin(LightningElement) {

    requests = [];
    filteredRequests = [];
    error;
    isLoading = true;

    requestResult;

    searchTerm = '';
    selectedStatus = 'All';
    selectedPriority = 'All';
    selectedCategory = 'All';

    openCount = 0;
    criticalCount = 0;
    resolvedCount = 0;
    slaRisk = 0;

        @wire(getAllRequests)
    wiredRequests(result) {
        this.requestResult = result;
        const { data, error } = result;

        if (data) {
            this.requests = data;
            this.error = undefined;
            this.isLoading = false;
            this.applyFilters();
        } else if (error) {
            this.requests = [];
            this.filteredRequests = [];
            this.error = error;
            this.isLoading = false;
            console.error('Request error:', JSON.stringify(error));
        }
    }

    connectedCallback() {
        this.loadCounts();
    }

    loadCounts() {
        getRequestCounts()
            .then((data) => {
                let total = 0;
                let resolved = 0;
                for (let status in data) {
                    total += data[status];
                    if (status === 'Resolved') {
                        resolved = data[status];
                    }
                }
                this.openCount = total - resolved;
                this.resolvedCount = resolved;
            })
            .catch((error) => {
                console.error('Count error:', JSON.stringify(error));
            });

        getPriorityCounts()
            .then((data) => {
                this.criticalCount = data['Critical'] || 0;
            })
            .catch((error) => {
                console.error('Priority error:', JSON.stringify(error));
            });

        getSLARiskCount()
            .then((count) => {
                this.slaRisk = count;
            })
            .catch((error) => {
                console.error('SLA Risk error:', JSON.stringify(error));
            });
    }

    handleSearchChange(event) {
        this.searchTerm = event.detail.value;
        this.applyFilters();
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.applyFilters();
    }

    handlePriorityChange(event) {
        this.selectedPriority = event.detail.value;
        this.applyFilters();
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.applyFilters();
    }

    applyFilters() {
        let result = [...this.requests];

        if (this.searchTerm) {
            const search = this.searchTerm.toLowerCase();
            result = result.filter(r =>
                (r.Name && r.Name.toLowerCase().includes(search)) ||
                (r.Subject__c && r.Subject__c.toLowerCase().includes(search))
            );
        }
        if (this.selectedStatus !== 'All') {
            result = result.filter(r => r.Status__c === this.selectedStatus);
        }
        if (this.selectedPriority !== 'All') {
            result = result.filter(r => r.Priority__c === this.selectedPriority);
        }
        if (this.selectedCategory !== 'All') {
            result = result.filter(r => r.Category__c === this.selectedCategory);
        }

        this.filteredRequests = result;
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await refreshApex(this.requestResult);
            this.loadCounts();
            this.showToast('Success', 'Dashboard refreshed successfully.', 'success');
        } catch (err) {
            this.showToast('Error', 'Unable to refresh the dashboard.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleRowSelect(event) {
        const recordId = event.detail.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Service_Request__c',
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
