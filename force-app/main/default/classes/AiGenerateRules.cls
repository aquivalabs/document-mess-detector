public with sharing class AiGenerateRules implements Triggers.Handler, Triggers.AfterInsert, Triggers.AfterUpdate, Queueable, Database.AllowsCallouts {

    private List<Ruleset__c> rulesets;

    // CONSTRUCTORS

    // Note: Default constructor required for Trigger Framework
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public AiGenerateRules() {}

    public AiGenerateRules(List<Ruleset__c> rulesets) {
        this.rulesets = rulesets;
    }


    // PUBLIC

    public Boolean criteria(Triggers.Context ctx) {
        return Triggers.WHEN_ALWAYS;
    }

    public void afterInsert(Triggers.Context ctx) {
        execute(ctx);
    }

    public void afterUpdate(Triggers.Context ctx){
        execute(ctx);
    }

    public void execute(QueueableContext ctx) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ Rule__c.SOBjectType, RuleInSet__c.SObjectType });

        for(Ruleset__c ruleset : rulesets) {
            execute(ruleset, uow);
        }

        uow.commitWork();
    }

    public void execute(Triggers.Context ctx) {
        List<Ruleset__c> relevant = new List<Ruleset__c>();

        for(Ruleset__c ruleset : (List<Ruleset__c>) ctx.props.newList) {
            // Note: When toggled on Insert there is no oldMap yet
            Boolean hasActuallyChanged = (ctx.props.isInsert || !((Ruleset__c) ctx.props.oldMap.get(ruleset.Id)).AiGenerateRules__c);
            
            if(ruleset.AiGenerateRules__c && hasActuallyChanged) {
                relevant.add(ruleset);
            }
        }

        System.enqueueJob( new AiGenerateRules(relevant) );
    }


    // PRIVATE 

    private void execute(Ruleset__c ruleset, fflib_SObjectUnitOfWork uow) {
        Notification message = new Notification(ruleset.OwnerId).target(ruleset.Id).with(ruleset.Name);

        try {
            CompletionApi ai = CompletionApi.get(ruleset.CompletionApi__c);
            CompletionApi.Rules response = ai.generateRules( toObject(ruleset) );

            for(CompletionApi.Rule generated : response.rules) {
                Rule__c rule = new Rule__c(Name = generated.name, Description__c= generated.description, Content__c = generated.content);
                uow.registerNew(rule);

                RuleInSet__c junction = new RuleInSet__c();
                uow.registerNew(junction);
                uow.registerRelationship(junction, RuleInSet__c.Rule__c, rule);
                uow.registerRelationship(junction, RuleInSet__c.Ruleset__c, ruleset);
            }

            message.title('DMD: Rules created successfully')
                .send('DMD has finished drafting rules for the Ruleset "{0}". Click to see them.');
        }
        catch(Exception error) {
            message.title('DMD: Rules creation failed')
                .with(error.getMessage())
                .with(error.getStackTraceString())
                .send(error.getTypeName() + ' occured when generating rules for ruleset "{0}".\n{1}\n{2}');
        }
    }

    private CompletionApi.Ruleset toObject(Ruleset__c record) {
        CompletionApi.Ruleset result = new CompletionApi.Ruleset();
        result.name = record.Name;    
        result.description = record.Description__c;    
        result.context = record.Context__c;   
        return result;
    }
}