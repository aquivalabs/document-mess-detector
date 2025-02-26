@IsTest
// Suppress and soon replace with Domainbuilder Tests
@SuppressWarnings('PMD')
public class TestDataFactory {
    // TODO ask AI to refactor using test domain builder
    private static final String CONVERT_RESPONSE_STRING = '{"conversionCost": 1, "files": [{"fileName": "output.txt", "fileExt": "txt", "fileSize": 15, "fileData": "c29tZSB0ZXh0IHVzZXI="}]}';
    private static final String OPEN_API_RESPONSE = '{ "id": "chatcmpl-7Rjkdh7Yw1xy8RZTmXeBo9c4bR9Cx", "object": "chat.completion", "created": 1686845079, "model": "gpt-4-0613", "choices": [ { "index": 0, "message": { "role": "assistant", "content": {{0}} }, "finish_reason": "stop" } ], "usage": { "prompt_tokens": 3795, "completion_tokens": 311, "total_tokens": 4106 } }';
    private static final String OPEN_API_RESPONSE_NO_MESSAGE = '{"usage":{"total_tokens":143,"prompt_tokens":12,"completion_tokens":131},"model":"gpt-4-0314","id":"chatcmpl-7HS4nHIJ3Ion7QKvw2paZ6K2i3kwG","created":1684393857,"choices":[]}';

    public static Account createAndInsertAccount() {
        Account account = createAccount();
        insert account;
        return account;
    }

    public static Account createAccount() {
        return new Account(Name = 'Test Account');
    }

    public static Attachment createAndInsertAttachment(Id parentId) {
        Attachment attachment = createAttachment(parentId);
        insert attachment;
        return attachment;
    }

    public static Attachment createAttachment(Id parentId) {
        return new Attachment(
            Name = 'TestAttachment',
            ContentType = 'application/pdf',
            Body = Blob.valueOf('Test attachment content'),
            ParentId = parentId
        );
    }

    public static ContentDocumentLink createAndInsertContentDocumentLink(Id contentDocumentId, Id linkedEntityId) {
        ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentDocumentId, linkedEntityId);
        insert contentDocumentLink;
        return contentDocumentLink;
    }

    public static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id linkedEntityId) {
        return new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = linkedEntityId,
            ShareType = 'V'
        );
    }

    public static ContentVersion createAndInsertContentVersion() {
        ContentVersion contentVersion = createContentVersion();
        insert contentVersion;
        return contentVersion;
    }

    public static ContentVersion createContentVersion() {
        return new ContentVersion(
            Title = 'TestDocument',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test document content')
        );
    }

    public static Rule__c createAndInsertRule() {
        Rule__c rule = createRule();
        insert rule;
        return rule;
    }

    public static Rule__c createRule() {
        return new Rule__c(Name = 'TestRule', Description__c = 'Rule description');
    }

    public static Ruleset__c createAndInsertRuleset(String context) {
        Ruleset__c ruleset = createRuleset(context);
        insert ruleset;
        return ruleset;
    }

    public static Ruleset__c createRuleset(String context) {
        return new Ruleset__c(Name = 'TestRuleset', Description__c = 'Ruleset description', Context__c = context);
    }

    public static RuleInSet__c createAndInsertRuleInSet(Id ruleId, Id rulesetId) {
        RuleInSet__c ruleInSet = createRuleInSet(ruleId, rulesetId);
        insert ruleInSet;
        return ruleInSet;
    }

    public static RuleInSet__c createRuleInSet(Id ruleId, Id rulesetId) {
        return new RuleInSet__c(Ruleset__c = ruleSetId, Rule__c = ruleId);
    }

    public static Analysis__c createAndInsertAnalysis(Id salesforceRecordId, Id documentId, Id rulesetId) {
        Analysis__c analysis = createAnalysis(salesforceRecordId, documentId, rulesetId);
        insert analysis;
        return analysis;
    }

    public static Analysis__c createAnalysis(Id salesforceRecordId, Id documentId, Id rulesetId) {
        return new Analysis__c(
            SalesforceRecordId__c = salesforceRecordId,
            DocumentId__c = documentId,
            Ruleset__c = rulesetId
        );
    }

    public static Analysis__c createAndInsertRegressionAnalysis(
        Id salesforceRecordId,
        Id documentId,
        Id rulesetId,
        Id regressionTestId
    ) {
        Analysis__c analysis = createBnchmarkAnalysis(salesforceRecordId, documentId, rulesetId, regressionTestId);
        insert analysis;
        return analysis;
    }

    public static Analysis__c createBnchmarkAnalysis(
        Id salesforceRecordId,
        Id documentId,
        Id rulesetId,
        Id regressionTestId
    ) {
        return new Analysis__c(
            SalesforceRecordId__c = salesforceRecordId,
            DocumentId__c = documentId,
            Ruleset__c = rulesetId,
            RegressionTest__c = regressionTestId
        );
    }

    public static Result__c createAndInsertResult(Id analysisId, Id ruleId, String status) {
        Result__c result = createResult(analysisId, ruleId, status);
        insert result;
        return result;
    }

    public static Result__c createResult(Id analysisId, Id ruleId, String status) {
        return new Result__c(Analysis__c = analysisId, Rule__c = ruleId, Status__c = status);
    }

    public static RegressionTest__c createAndInsertRegressionTest(Id benchmarkAnalysisId) {
        RegressionTest__c regressionTest = createRegressionTest(benchmarkAnalysisId);
        insert regressionTest;
        return regressionTest;
    }

    public static RegressionTest__c createRegressionTest(Id benchmarkAnalysisId) {
        return new RegressionTest__c(
            BenchmarkAnalysis__c = benchmarkAnalysisId,
            ScheduleCron__c = '0 0 0 * * ?'
        );
    }

}
