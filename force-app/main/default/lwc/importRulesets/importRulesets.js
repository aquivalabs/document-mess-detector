import { LightningElement, track } from 'lwc';
import doImport from '@salesforce/apex/ExportImportRulesetCtrl.doImport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ImportRulesets extends LightningElement {

    @track jsonContent;
    acceptedFormats = ['.json'];
    fileName = '';
    fileUrl = '';

    uploadFile(event) {
        if (event.detail.files && event.detail.files.length) {
            const file = event.detail.files[0];
            this.fileName = file.name;
            this.fileUrl = URL.createObjectURL(file);

            const reader = new FileReader();
            reader.onloadend = (() => {
                this.jsonContent = reader.result;
            });

            reader.readAsText(file);
        }
    }

    importFile(event) {
        doImport({jsonContent: this.jsonContent})
            .then(() => {
                this.showToastMessage('Success','Import successful', 'success');
            })
            .catch(error => {
                this.showToastMessage('Error','Error importing file ' + error, 'error');
            });
    }

    showToastMessage(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}