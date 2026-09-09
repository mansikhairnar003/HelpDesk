import { LightningElement } from 'lwc';

export default class RequestFilter extends LightningElement {
    searchTerm = '';
    selectedStatus = 'All';
    selectedPriority = 'All';
    selectedCategory = 'All';

    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'New', value: 'New' },
        { label: 'Assigned', value: 'Assigned' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Resolved', value: 'Resolved' }
    ];

    priorityOptions = [
        { label: 'All', value: 'All' },
        { label: 'Critical', value: 'Critical' },
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];

    categoryOptions = [
        { label: 'All', value: 'All' },
        { label: 'Hardware', value: 'Hardware' },
        { label: 'Software', value: 'Software' },
        { label: 'Network', value: 'Network' },
        { label: 'Access', value: 'Access' },
        { label: 'Email', value: 'Email' },
        { label: 'Other', value: 'Other' }
    ];

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.dispatchEvent(new CustomEvent('searchchange', { detail: { value: this.searchTerm } }));
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.dispatchEvent(new CustomEvent('statuschange', { detail: { value: this.selectedStatus } }));
    }

    handlePriorityChange(event) {
        this.selectedPriority = event.detail.value;
        this.dispatchEvent(new CustomEvent('priaoritychange', { detail: { value: this.selectedPriority } }));
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.dispatchEvent(new CustomEvent('categorychange', { detail: { value: this.selectedCategory } }));
    }

    handleRefresh() {
        this.dispatchEvent(new CustomEvent('refresh'));
    }
}