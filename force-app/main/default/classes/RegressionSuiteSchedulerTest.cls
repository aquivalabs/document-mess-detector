@IsTest
private with sharing class RegressionSuiteSchedulerTest {

    @IsTest
    private static void testScheduler() {

        // Setup
        Triggers.skips.add(AnalyseDocument.class);
        Triggers.skips.add(ScheduleRegressionTests.class);

        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion doc = TestDataFactory.createAndInsertContentVersion();
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :doc.Id].ContentDocumentId;
        Ruleset__c ruleset = TestDataFactory.createAndInsertRuleset(null);
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, docId, ruleset.Id);
        RegressionTest__c regressionTest = TestDataFactory.createAndInsertRegressionTest(analysis.Id);

        Integer jobsBefore = [SELECT COUNT() FROM CronTrigger];


        // Exercise
        Test.startTest();
        System.schedule('Regression Suite', '0 0 0 * * ?', new RegressionSuiteScheduler(regressionTest.Id));
        Test.stopTest();

        
        // Verify
        System.assertEquals(jobsBefore + 1, [SELECT COUNT() FROM CronTrigger]);
    }
}
