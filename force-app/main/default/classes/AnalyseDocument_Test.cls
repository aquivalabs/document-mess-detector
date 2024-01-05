// Note: One days RegressionTest and Cron related test failed with ORA deadlocks
@IsTest(isParallel=false)
private class AnalyseDocument_Test {
    
    @TestSetup
    static void setup() {
        insert new DmdSettings__c(txt_ExtractApiKey__c='any');
    }

    @IsTest
    private static void successResponse() {

        // Setup
        Rule r = new Rule();
        Ruleset rs = new Ruleset().add(r);
        File_t f = new File_t();
        Rule__c rule = (Rule__c) r.persist();
        
        new HttpMock()
            .post('/api/v1/pdf-extractor', 'extracted Text')
            .post('/v1/chat/completions', responseFor(rule))
        .mock();

        // Exercise
        Test.startTest();
        new Analysis(f, rs).persist();
        Test.stopTest();

        // Verify
        System.assertEquals(1, [SELECT COUNT() FROM Result__c]);
    }

    @IsTest
    private static void errorResponse() {
        // Setup
        Ruleset r = new Ruleset().add(new Rule());
        File_t f = new File_t();
        r.persist();
        
        new HttpMock()
            .post('/api/v1/pdf-extractor', 'extracted Text')
            .post('/v1/chat/completions', 500)
        .mock();

        // Exercise
        Test.startTest();
        new Analysis(f, r).persist();
        Test.stopTest();

        // Verify
        System.assertEquals(0, [SELECT COUNT() FROM Result__c]);
        System.assertEquals('Error', [SELECT Status__c FROM Analysis__c].Status__c);
    }

    // HELPER

    private static OpenAiHandler.Response responseFor(Rule__c rule) {
        CompletionApi.Result result = new CompletionApi.Result();
        result.ruleId = rule.Id;
        result.status = 'Success';
        result.justification = 'Justification';

        CompletionApi.Results results = new CompletionApi.Results();
        results.results.add(result);

        return new OpenAiHandler.Response()
                                    .withChoice( new OpenAiHandler.Message('assistant', JSON.serialize(results) ));
    }
}