@IsTest
private class DocumentAnalysisHistoryControllerTest {
    
    private static final Integer ANALYSES_SIZE = 7;
    
    @TestSetup
    static void setup() {
        insert new DmdSettings__c(txt_ExtractApiKey__c='any');
    }

    @IsTest
    static void documentWithHistory() {
        // Setup
        Account account = TestDataFactory.createAndInsertAccount();
        Ruleset__c ruleset = TestDataFactory.createAndInsertRuleset('Test Context');
        ContentVersion contentVersion = TestDataFactory.createAndInsertContentVersion();

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id]
        .ContentDocumentId;

        List<Analysis__c> analyses = new List<Analysis__c>();
        for (Integer i = 0; i < ANALYSES_SIZE; i++) {
            Analysis__c analysis = TestDataFactory.createAndInsertAnalysis(account.Id, contentDocumentId, ruleset.Id);
            analyses.add(analysis);
        }

        // Exercise
        List<DocumentAnalysisHistoryController.Analysis> result = DocumentAnalysisHistoryController.history(
            contentDocumentId
        );

        // Verify
        System.assertEquals(ANALYSES_SIZE, result.size());
    }

    @IsTest
    static void documentWithoutHistory() {
        // Setup
        ContentVersion contentVersion = TestDataFactory.createAndInsertContentVersion();

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id]
        .ContentDocumentId;

        // Exercise
        List<DocumentAnalysisHistoryController.Analysis> result = DocumentAnalysisHistoryController.history(
            contentDocumentId
        );

        // Verify
        System.assertEquals(0, result.size());
    }
}