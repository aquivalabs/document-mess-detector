@IsTest
private class SetupOpenAi_Test {
        
    @IsTest
    private static void loadAndChange() {
        
        // Setup
        CompletionApi__mdt model = CompletionApi.queryByName('OpenAiApi');
        model.ApiKey__c = null;
        CompletionApi.mocks.add(model);

        Test.setCurrentPage(Page.setup);
        SetupOpenAi step = new SetupOpenAi();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Exercise
        model.ApiKey__c = 'sk-asfsdGZUJHFZJHFVasdfyxdc';
        step = new SetupOpenAi();
        

        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());
    }
}