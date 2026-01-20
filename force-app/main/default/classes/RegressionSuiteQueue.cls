public with sharing class RegressionSuiteQueue implements Queueable {
    private Id regressionTestId;

    public RegressionSuiteQueue(Id regressionTestId) {
        this.regressionTestId = regressionTestId;
    }

    public void execute(QueueableContext context) {
        try {
            RegressionTest__c regressionTest = [
                SELECT
                    BenchmarkAnalysis__r.Ruleset__c,
                    BenchmarkAnalysis__r.DocumentId__c,
                    BenchmarkAnalysis__r.DocumentName__c,
                    BenchmarkAnalysis__r.SalesforceRecordId__c
                FROM RegressionTest__c
                WHERE Id = :this.regressionTestId
                WITH USER_MODE
            ];

            // add AS USER clause to avoid sharing violation
            insert new Analysis__c(
                Ruleset__c = regressionTest.BenchmarkAnalysis__r.Ruleset__c,
                DocumentId__c = regressionTest.BenchmarkAnalysis__r.DocumentId__c,
                DocumentName__c = regressionTest.BenchmarkAnalysis__r.DocumentName__c,
                SalesforceRecordId__c = regressionTest.BenchmarkAnalysis__r.SalesforceRecordId__c,
                RegressionTest__c = this.regressionTestId
            );
        } catch (Exception e) {
            update as user new RegressionTest__c(Id = this.regressionTestId, Status__c = 'Failed');
        }
    }
}
