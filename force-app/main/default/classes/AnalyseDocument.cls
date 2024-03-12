public class AnalyseDocument implements Triggers.Handler, Triggers.AfterInsert, Queueable, Database.AllowsCallouts {

    private List<Analysis__c> analyses;

    // TRIGGER

    // Note: Default constructor required for Trigger Framework
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public AnalyseDocument() {}

    public Boolean criteria(Triggers.Context context) {
        return Triggers.WHEN_ALWAYS;
    }

    public void afterInsert(Triggers.Context context) {
        System.enqueueJob(new AnalyseDocument(context.props.newList));
    }

    // QUEUEABLE

    public AnalyseDocument(List<Analysis__c> analyses) {
        this.analyses = analyses;
    }

    public void execute(QueueableContext ctx) {
        Analysis__c analysis = analyses.get(0);

        try {
            CompletionApi ai = CompletionApi.get(analysis.CompletionApi__c);
            CompletionApi.Results results = ai.getCompletion(toGenericStructure(analysis));
            
            persist(analysis, results);
        } 
        catch(Exception error) {
            persist(analysis, error);
        }
        
        enqueueNext();
    }

    public static CompletionApi.Analysis toGenericStructure(Analysis__c analysis) {
        CompletionApi.Analysis result = new CompletionApi.Analysis();
        result.id = analysis.Id;
        result.document = documentOf(analysis);
        result.ruleset = rulesetOf(analysis);
        return result;
    }

    public static CompletionApi.Document documentOf(Analysis__c analysis) {
        CompletionApi.Document result = new CompletionApi.Document();
        
        ContentVersion file = [SELECT VersionData, PathOnClient, FileExtension, ContentSize FROM ContentVersion
                               WHERE ContentDocumentId = :analysis.DocumentId__c WITH USER_MODE];
        result.text = (file.FileExtension == 'txt') ? file.VersionData.toString()
                                                    : new DocumentText().extractFrom(file);
        return result;
    }

    public static CompletionApi.Ruleset rulesetOf(Analysis__c analysis) {
        Ruleset__c ruleset = [SELECT Context__c FROM Ruleset__c 
                              WHERE Id = :analysis.Ruleset__c WITH USER_MODE];
        
        CompletionApi.Ruleset result = new CompletionApi.Ruleset();
        result.id = ruleset.Id;
        result.context = ruleset.Context__c;                              

        for(Rule__c record : [SELECT Id, Content__c FROM Rule__c
                              WHERE Id IN (SELECT Rule__c FROM RuleInSet__c
                                           WHERE Ruleset__c = : ruleset.Id)
                              WITH USER_MODE]) {
            CompletionApi.Rule rule = new CompletionApi.Rule();
            rule.ruleId = record.Id;
            rule.content = record.Content__c;

            result.rules.add(rule);
        }

        return result;
    }

    // PRIVATE

    private void persist(Analysis__c analysis, Exception error) {
        // Security False Positive: User permset disallows update therfore we need to behave as system user            
        update as system new Analysis__c(Id =analysis.Id, 
                                         Status__c = Constants.ANALYSIS_ERROR,
                                         FailReason__c = format(error));
    }

    private void persist(Analysis__c analysis, CompletionApi.Results results) {
        List<Result__c> records = new List<Result__c>();

        String status = Constants.ANALYSIS_SUCCESS;

        for(CompletionApi.Result result : results.results) {
            records.add( new Result__c(Analysis__c = analysis.Id,
                                        Rule__c = result.ruleId,
                                        Status__c = result.status,
                                        Justification__c = result.justification));
            status = (result.status != Constants.RESULT_SUCCESS) ? Constants.ANALYSIS_FAIL : status;
        }

        insert as system records;

        // Security False Positive: User permset disallows update therfore we need to behave as system user            
        update as system new Analysis__c(Id =analysis.Id, Status__c = status);
    }

    private void enqueueNext() {
        if (!Test.isRunningTest() && analyses.size() > 1) {
            analyses.remove(0);
            System.enqueueJob(new AnalyseDocument(analyses));
        }
    }

    private String format(Exception error) {
        return error.getTypeName() + ' : ' + error.getMessage() + '\n' + error.getStackTraceString();
    }
}