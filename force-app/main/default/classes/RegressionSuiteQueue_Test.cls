// Note: One days RegressionTest and Cron related test failed with ORA deadlocks
@IsTest(isParallel=false)
private with sharing class RegressionSuiteQueue_Test {

    @IsTest
    private static void jobIsScheduledOnNewTest() {

        // Setup
        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion doc = TestDataFactory.createAndInsertContentVersion();
        Id docId = [SELECT ContentDocumentId FROM ContentVersion].ContentDocumentId;
        Ruleset__c ruleset = TestDataFactory.createAndInsertRuleset(null);
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, docId, ruleset.Id);

        Integer jobsBefore = countJobs();

        // Exercise
        TestDataFactory.createAndInsertRegressionTest(analysis.Id);
        
        // Verify
        System.assertEquals(jobsBefore + 1, countJobs());
        
    }

    @IsTest
    private static void jobIsUpdatedIfCronIsChanged() {
        // Setup
        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion doc = TestDataFactory.createAndInsertContentVersion();
        Id docId = [SELECT ContentDocumentId FROM ContentVersion].ContentDocumentId;
        Ruleset__c ruleset = TestDataFactory.createAndInsertRuleset(null);
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, docId, ruleset.Id);
        RegressionTest__c regressionTest = TestDataFactory.createAndInsertRegressionTest(analysis.Id);
        
        System.assertEquals(0, [SELECT Count() FROM CronTrigger WHERE CronExpression = '2 2 0 * * ?']);

        // Exercise
        regressionTest.ScheduleCron__c = '2 2 0 * * ?';
        update regressionTest;
        
        // Verify
        System.assertEquals(1, [SELECT Count() FROM CronTrigger WHERE CronExpression = '2 2 0 * * ?']);
    }

    @IsTest
    private static void jobIsRemovedWhenCronIsEmpty() {

        // Setup
        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion doc = TestDataFactory.createAndInsertContentVersion();
        Id docId = [SELECT ContentDocumentId FROM ContentVersion].ContentDocumentId;
        
        Ruleset__c ruleset = TestDataFactory.createAndInsertRuleset(null);
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, docId, ruleset.Id);
        RegressionTest__c regressionTest = TestDataFactory.createAndInsertRegressionTest(analysis.Id);

        Integer jobsBefore = countJobs();

        // Exercise
        regressionTest.ScheduleCron__c = null;
        update regressionTest;

        // Verify
        System.assertEquals(jobsBefore - 1  , countJobs());
    }

    @IsTest
    private static void jobIsRemovedWhenTestIsDeleted() {
        
        // Setup
        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion doc = TestDataFactory.createAndInsertContentVersion();
        Id docId = [SELECT ContentDocumentId FROM ContentVersion].ContentDocumentId;
        Ruleset__c ruleset = TestDataFactory.createAndInsertRuleset(null);
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, docId, ruleset.Id);
        RegressionTest__c regressionTest = TestDataFactory.createAndInsertRegressionTest(analysis.Id);

        Integer jobsBefore = countJobs();

        // Exercise
        delete regressionTest;
        
        // Verify
        System.assertEquals(jobsBefore - 1  , countJobs());
    }


    // HELPER

    private static Integer countJobs() {
        return [SELECT Count() FROM CronJobDetail WHERE JobType = '7' AND Name LIKE 'RT-%'];
    }
}