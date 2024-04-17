// Note: One day RegressionTest and Cron related test failed with ORA deadlocks
@IsTest(isParallel=false)
private class AnalyseDocument_Test {
    
    @TestSetup
    static void setup() {
        insert new DmdSettings__c(txt_ExtractApiKey__c='any');
    }

    @IsTest
    private static void successResponse() {

        // Setup
        System.runAs(User_t.standard('DocumentReviewer')) {
            File_t f = new File_t();
            Ruleset rs = new Ruleset();
            Rule__c r = (Rule__c) new Rule(rs).persist();                   
            
            new HttpMock()
                .post('/api/v1/pdf-extractor', 'extracted Text')
                .post('/v1/chat/completions', responseFor(r))
            .mock();
 

            // Exercise
            Test.startTest();
            new Analysis(f, rs).persist();
            Test.stopTest();


            // Verify
            System.assertEquals(1, [SELECT COUNT() FROM Result__c]);
        }
    }

    @IsTest
    private static void errorResponse() {

        // Setup
        File_t f = new File_t();
        Ruleset r = new Ruleset().add(new Rule());
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

    private static OpenAiHandler.Response responseFor(SObject rule) {
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