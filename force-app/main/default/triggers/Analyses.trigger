trigger Analyses on Analysis__c(before insert, after insert, after update) {
    Triggers.prepare()
        .beforeInsert()
            .bind(new TidyClonedAnalysis())
        .afterInsert()
            .bind(new AnalyseDocument())
        .afterUpdate()
            .bind(new NotifyUserOnAnalysisChange())
        .execute();
}