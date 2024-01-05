import { LightningElement, api, wire } from 'lwc';
import { COLUMNS } from './config';
import results from '@salesforce/apex/RegressionTestController.results';

export default class RegressionResults extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    data;

    @wire(results, { regressionTestId: '$recordId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.data = data.map((row) => {
                return { ...row, ruleUrl: `/${row.ruleId}` };
            });
        } else if (error) {
            console.error(error);
            this.data = undefined;
        }
    }
}