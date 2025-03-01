@IsTest
private class AiGenerateRules_Test {

    @IsTest
    private static void happyPath() {
    
        // Setup
        CompletionApi.Rule rule = new CompletionApi.Rule();
        rule.content = 'Say you love him/her';
        rule.name = 'Say it';
        rule.description = 'If you skip it you are out!';
    
        CompletionApi.Rules mocked = new CompletionApi.Rules();
        mocked.rules.add(rule);
        
        AiGenerateRules.mockedRules = mocked;
    
        // Exercise
        Test.startTest();

        new Ruleset()
                .name('10 Rules to write the perfect loveletter')
                .aiRules()
                .persist();

        Test.stopTest();
    
        // Verify
        System.assertEquals(rule.content, [SELECT Content__c FROM Rule__c LIMIT 1].Content__c);
    }
}