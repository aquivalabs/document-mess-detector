@IsTest
private with sharing class RegressionTestCtrl_Test {
    
    @IsTest
    private static void results() {
        // Setup
        Triggers.skips.add(AnalyseDocument.class);
        Triggers.skips.add(ScheduleRegressionTests.class);

        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion contentVersion = TestDataFactory.createAndInsertContentVersion();
        Ruleset__c ruleSet = TestDataFactory.createAndInsertRuleset('test');
        Rule__c rule = TestDataFactory.createAndInsertRule();
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id]
        .ContentDocumentId;
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, contentDocumentId, ruleSet.Id);
        TestDataFactory.createAndInsertResult(analysis.Id, rule.Id, 'Success');
        Id reggressionTestId = TestDataFactory.createAndInsertRegressionTest(analysis.Id)
            .Id;
        Analysis__c regressionAnalysis = TestDataFactory.createAndInsertRegressionAnalysis(
            account.Id,
            contentDocumentId,
            ruleSet.Id,
            reggressionTestId
        );
        TestDataFactory.createAndInsertResult(regressionAnalysis.Id, rule.Id, 'Success');
        TestDataFactory.createAndInsertResult(regressionAnalysis.Id, rule.Id, 'Unsure');

        // Exercise
        Test.startTest();
        List<RegressionTestCtrl.RegressionResult> results = RegressionTestCtrl.results(reggressionTestId);
        Test.stopTest();

        // Verify
        System.assert(!results.isEmpty());
    }

    @IsTest
    private static void resultsNoRules() {
        // Setup
        Triggers.skips.add(AnalyseDocument.class);
        Triggers.skips.add(ScheduleRegressionTests.class);

        Account account = TestDataFactory.createAndInsertAccount();
        ContentVersion contentVersion = TestDataFactory.createAndInsertContentVersion();
        Ruleset__c ruleSet = TestDataFactory.createAndInsertRuleset('test');
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id]
        .ContentDocumentId;
        Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, contentDocumentId, ruleSet.Id);
        Id reggressionTestId = TestDataFactory.createAndInsertRegressionTest(analysis.Id)
            .Id;

        // Exercise
        Test.startTest();
        List<RegressionTestCtrl.RegressionResult> results = RegressionTestCtrl.results(reggressionTestId);
        Test.stopTest();

        // Verify
        System.assert(results.isEmpty());
    }
}
