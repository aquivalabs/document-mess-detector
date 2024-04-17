public class RegressionTest extends DomainBuilder {

	// CONSTRUCTORS

	public RegressionTest(Analysis a) {
		super(RegressionTest__c.SObjectType);

        setParent(RegressionTest__c.BenchmarkAnalysis__c, a);
        set(RegressionTest__c.ScheduleCron__c, '0 0 12 ? * MON *');
	}

	public RegressionTest() {
		this(new Analysis());
	}
}