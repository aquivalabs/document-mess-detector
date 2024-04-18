delete [SELECT Id FROM RegressionTest__c];
delete [SELECT Id FROM Analysis__c];
delete [SELECT Id FROM RuleInSet__c];
delete [SELECT Id FROM Ruleset__c];
delete [SELECT Id FROM Rule__c];

// sf apex run -f scripts/codeLive.apex

Ruleset rs = new Ruleset()
                    .name('Test Ruleset')

                    .add( new Rule() )
                    .add( new Rule().name('Test Rule').content('Say the truth') );

new Analysis(rs).persist();











/*
Analysis benchmark = new Analysis(rs)
                            .add(new Result(r1).pass())
                            .add(new Result(r2).fail());

new RegressionTest().persist();


Analysis

	public Analysis add(Result r) {
		r.setParent(Result__c.Analysis__c, this);
		return this;
	}

Result

public class Result extends DomainBuilder {

	// CONSTRUCTORS

	public Result(Rule r) {
		super(Result__c.SObjectType);

		setParent(Result__c.Rule__c, r);
	}

	// PROPERTIES

    public Result pass() {
        set(Result__c.Status__c, 'Success');
        return this;
    }

    public Result fail() {
        set(Result__c.Status__c, 'Fail');
        return this;
    }
}
*/