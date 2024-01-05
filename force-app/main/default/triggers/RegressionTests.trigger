trigger RegressionTests on RegressionTest__c(after insert, after update, after delete) {
    Triggers.prepare()
        .afterInsert()
            .bind(new ScheduleRegressionTests())
        .afterUpdate()
            .bind(new ScheduleRegressionTests())
        .afterDelete()
            .bind(new ScheduleRegressionTests())
        .execute();
}
