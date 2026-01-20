public with sharing class RegressionSuiteScheduler implements Schedulable {
    private Id regressionTestId;

    public RegressionSuiteScheduler(Id regressionTestId) {
        this.regressionTestId = regressionTestId;
    }

    public void execute(SchedulableContext context) {
        System.enqueueJob(new RegressionSuiteQueue(regressionTestId));
    }
}
