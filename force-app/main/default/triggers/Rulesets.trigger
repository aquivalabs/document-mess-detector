trigger Rulesets on Ruleset__c(after insert, after update) {
    Triggers.prepare()
        .afterInsert()
            .bind(new AiGenerateRules())
        .afterUpdate()
            .bind(new AiGenerateRules())
        .execute();
}