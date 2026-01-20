public with sharing class TidyClonedAnalysis implements Triggers.Handler, Triggers.BeforeInsert {

    private List<Analysis__c> analyses;

    // TRIGGER

    // Note: Default constructor required for Trigger Framework
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public TidyClonedAnalysis() {}

    public Boolean criteria(Triggers.Context context) {
        return Triggers.WHEN_ALWAYS;
    }

    public void beforeInsert(Triggers.Context context) {
        execute(context.props.newList);
    }

    // PRIVATE

    private void execute(List<Analysis__c> potentialClones) {
        Analysis__c defaultRecord = new Analysis__c();

        for(Analysis__c analysis : potentialClones) {
            analysis.Status__c = defaultRecord.Status__c;
            analysis.FailReason__c = defaultRecord.FailReason__c;
        }
    }
}