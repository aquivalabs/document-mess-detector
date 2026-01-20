import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import ANALYSYS_OBJECT from '@salesforce/schema/Analysis__c';
import RECORD_ID from '@salesforce/schema/Analysis__c.SalesforceRecordId__c';
import DOCUMENT_ID from '@salesforce/schema/Analysis__c.DocumentId__c';
import DOCUMENT_NAME from '@salesforce/schema/Analysis__c.DocumentName__c';

import options from '@salesforce/apex/DocumentSelectorCtrl.options';

export default class DocumentSelector extends NavigationMixin(LightningElement) {
    @api recordId;
    record;
    loading = false;
    documentId;
    documentName;
    options = [];

    @wire(options, { recordId: '$recordId' })
    documents({ error, data }) {
        this.loading = true;
        if (data) {
            this.options = [
                ...this.options,
                ...data.map((document) => ({ label: document.Title || document.Name, value: document.Id })),
            ];
        } else if (error) {
            console.error(error);
        }
        this.loading = false;
    }

    get isButtonDisabled() {
        return !this.documentId;
    }

    documentSelected(event) {
        this.documentId = event.detail.value;
        this.documentName = this.options.find((opt) => opt.value === this.documentId).label;
    }

    createAnalysis() {
        const defaultValues = encodeDefaultFieldValues({
            [RECORD_ID.fieldApiName]: this.recordId,
            [DOCUMENT_ID.fieldApiName]: this.documentId,
            [DOCUMENT_NAME.fieldApiName]: this.documentName,
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: ANALYSYS_OBJECT.objectApiName,
                actionName: 'new',
            },
            state: {
                defaultFieldValues: defaultValues,
            },
        });
    }
}
