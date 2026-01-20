public with sharing class ScheduleRegressionTests implements Triggers.Handler, Triggers.AfterInsert, Triggers.AfterUpdate, Triggers.AfterDelete {

    private Triggers.Context context;
    private List<RegressionTest__c> tests;
    private Map<String, CronTrigger> jobs = new Map<String, CronTrigger>();
    

    // PUBLIC 

    public Boolean criteria(Triggers.Context context) {
        return (context.props.isUpdate) 
                    ? context.props.isChanged(RegressionTest__c.ScheduleCron__c)
                    : Triggers.WHEN_ALWAYS;
    }

    public void afterInsert(Triggers.Context ctx) {
        tests = ctx.props.newList;
        execute(ctx);
    }

    public void afterUpdate(Triggers.Context ctx) {
        tests = ctx.props.newList;
        execute(ctx);
    }

    public void afterDelete(Triggers.Context ctx) {
        tests = ctx.props.oldList;
        execute(ctx);
    }

    // PRIVATE

    // Note: App doesn't allow Bulk on Tests
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    private void execute(Triggers.Context ctx) {
        context = ctx;

        queryJobs();

        for (RegressionTest__c test : tests) {
            if(shouldSchedule(test)) {
                System.schedule(test.Name, test.ScheduleCron__c, new RegressionSuiteScheduler(test.Id));
            }
            else if(shouldReschedule(test)) {
                System.abortJob(jobs.get(test.Name).Id);
                System.schedule(test.Name, test.ScheduleCron__c, new RegressionSuiteScheduler(test.Id));
            }
            else if(shouldAbort(test)) {
                System.abortJob(jobs.get(test.Name).Id);
            }
        }
    }

    private void queryJobs() {
        Set<String> testNames = new Set<String>();
        
        for(RegressionTest__c regressionTest : tests) {
            testNames.add(regressionTest.Name);
        }

        for(CronTrigger job : [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name IN :testNames
            WITH USER_MODE
        ]) {
            jobs.put(job.CronJobDetail.Name, job);
        }
    }

    private Boolean shouldSchedule(RegressionTest__c test) {
        return (test.ScheduleCron__c != null && !jobs.containsKey(test.Name));
    }

    private Boolean shouldReschedule(RegressionTest__c test) {
        return (!context.props.isDelete && test.ScheduleCron__c != null && jobs.containsKey(test.Name));
    }

    private Boolean shouldAbort(RegressionTest__c test) {
        return (context.props.isDelete || (test.ScheduleCron__c == null && jobs.containsKey(test.Name)));
    }
}
