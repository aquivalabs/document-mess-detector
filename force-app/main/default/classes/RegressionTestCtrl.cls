// Suppressed as PMD needs to be updates to check USER_MODE
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class RegressionTestCtrl {

    @AuraEnabled(cacheable=true)
    public static List<RegressionResult> results(Id regressionTestId) {
        try {
            Map<Id, RegressionResult> resultsByRuleId = new Map<Id, RegressionResult>();

            RegressionTest__c regressionTest = [
                SELECT id, BenchmarkAnalysis__c
                FROM RegressionTest__c
                WHERE Id = :regressionTestId
                WITH USER_MODE
            ];

            // get benchmark results
            for (Result__c result : [
                SELECT Status__c, Rule__c, Rule__r.Name
                FROM Result__c
                WHERE Analysis__c = :regressionTest.BenchmarkAnalysis__c
                WITH USER_MODE
            ]) {
                resultsByRuleId.put(result.Rule__c, new RegressionResult(result));
            }

            // get regression results
            for (Result__c result : [
                SELECT Status__c, Rule__c, Rule__r.Name
                FROM Result__c
                WHERE Analysis__r.RegressionTest__c = :regressionTestId
                WITH USER_MODE
            ]) {
                if (resultsByRuleId.containsKey(result.Rule__c)) {
                    resultsByRuleId.get(result.Rule__c).count(result.Status__c);
                }
            }

            return resultsByRuleId.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private class RegressionResult {
        @AuraEnabled
        public String ruleId { get; set; }
        @AuraEnabled
        public String ruleName { get; set; }
        @AuraEnabled
        public String expected { get; set; }
        @AuraEnabled
        public Integer failed { get; set; }
        @AuraEnabled
        public Integer succeeded { get; set; }
        @AuraEnabled
        public Integer unsure { get; set; }
        @AuraEnabled
        public Double accuracy { get; set; }

        private RegressionResult(Result__c benchmarkResult) {
            this.ruleId = benchmarkResult.Rule__c;
            this.ruleName = benchmarkResult.Rule__r.Name;
            this.expected = benchmarkResult.Status__c;
            this.failed = 0;
            this.succeeded = 0;
            this.unsure = 0;
            this.accuracy = 0.0;
        }

        private RegressionResult count(String status) {
            setStatusCount(status);
            setAccuracy();

            return this;
        }

        private void setStatusCount(String status) {
            if (status == Constants.RESULT_FAIL) {
                failed++;
                return;
            }
            if (status == Constants.RESULT_SUCCESS) {
                succeeded++;
                return;
            }
            if (status == Constants.RESULT_UNSURE) {
                unsure++;
                return;
            }
        }

        private void setAccuracy() {
            Double total = failed + succeeded + unsure;
            if (expected == Constants.RESULT_FAIL) {
                accuracy = failed / total;
                return;
            }
            if (expected == Constants.RESULT_SUCCESS) {
                accuracy = succeeded / total;
                return;
            }
            if (expected == Constants.RESULT_UNSURE) {
                accuracy = unsure / total;
                return;
            }
        }
    }
}
