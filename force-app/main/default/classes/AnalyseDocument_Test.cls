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
            
            new HttpMock().post('/api/v1/pdf-extractor', 'extracted Text').mock();

            CompletionApi.Result result = new CompletionApi.Result();
            result.ruleId = r.Id;
            result.status = 'Success';
            result.justification = 'Justification';

            CompletionApi.Results results = new CompletionApi.Results();
            results.results.add(result);
 
            AnalyseDocument.mockedResults = results;

            // Exercise
            Test.startTest();
            
            new Analysis(f, rs).persist();

            Test.stopTest();

            // Verify
            System.assertEquals(1, [SELECT COUNT() FROM Result__c]);
        }
    }
}