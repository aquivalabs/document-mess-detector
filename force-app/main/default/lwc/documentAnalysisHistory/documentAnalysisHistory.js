import { LightningElement, api, wire } from 'lwc';
import { COLUMNS } from './config';
import history from '@salesforce/apex/DocumentAnalysisHistoryController.history';

export default class DocumentAnalysisHistory extends LightningElement {
    @api documentId;
    title = 'Document analysis history';
    noHistoryMessage = 'No analyses for the selected document.';
    columns = COLUMNS;
    data;
    hasHistory;
    @wire(history, { documentId: '$documentId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.hasHistory = data && data.length;
            this.data = data.map((row) => {
                return {
                    ...row,
                    analysisUrl: `/${row.analysisId}`,
                    rulesetUrl: `/${row.rulesetId}`,
                };
            });
        } else if (error) {
            console.error(error);
            this.data = undefined;
        }
    }
}
