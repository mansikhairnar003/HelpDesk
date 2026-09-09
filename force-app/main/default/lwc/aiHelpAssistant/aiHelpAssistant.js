import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import getAISuggestion from '@salesforce/apex/AIAssistService.getAISuggestion';

export default class AiHelpAssistant extends NavigationMixin(LightningElement) {

    issueText = '';
    isLoading = false;

    aiResult;
    hasResult = false;
    errorMessage;

    formSubject = '';
    formDescription = '';
    formCategory = '';

    categoryOptions = [
        { label: 'Hardware', value: 'Hardware' },
        { label: 'Software', value: 'Software' },
        { label: 'Network', value: 'Network' },
        { label: 'Access', value: 'Access' },
        { label: 'Email', value: 'Email' },
        { label: 'Other', value: 'Other' }
    ];

    handleIssueChange(event) {
        this.issueText = event.detail.value;
    }

    get isButtonDisabled() {
        return !this.issueText ||
               this.issueText.trim().length === 0 ||
               this.isLoading;
    }

    get isCreateRequestDisabled() {
        return !this.formSubject ||
               !this.formCategory;
    }

    async handleAskAI() {

        this.isLoading = true;
        this.hasResult = false;
        this.errorMessage = null;

        try {

            const result = await getAISuggestion({
                employeeIssue: this.issueText
            });

            if (result.success) {

                this.aiResult = result;
                this.hasResult = true;

                this.formSubject = this.issueText.length > 80
                    ? this.issueText.substring(0, 80)
                    : this.issueText;
                this.formDescription = this.issueText;

                this.formCategory = result.suggestedCategory;

            } else {

                this.errorMessage = result.responseMessage;

            }

        } catch (error) {

            this.errorMessage =
                'Something went wrong. Please try again or create a request manually.';

            console.error(
                'AI Assist Error:',
                JSON.stringify(error)
            );

        } finally {

            this.isLoading = false;

        }
    }

    handleCreateRequest() {

        const defaultFieldValues = encodeDefaultFieldValues({

            Subject__c: this.formSubject,

            Description__c: this.formDescription,

            Category__c: this.formCategory

        });

        this[NavigationMixin.Navigate]({

            type: 'standard__objectPage',

            attributes: {

                objectApiName: 'Service_Request__c',

                actionName: 'new'

            },

            state: {

                defaultFieldValues: defaultFieldValues

            }

        });
    }

    handleStartOver() {

        this.issueText = '';

        this.hasResult = false;

        this.aiResult = null;

        this.errorMessage = null;

        this.formSubject = '';

        this.formDescription = '';

        this.formCategory = '';
    }
}