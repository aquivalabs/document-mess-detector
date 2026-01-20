public class Ruleset extends DomainBuilder {

	public Ruleset() {
		super(Ruleset__c.SObjectType);

        name('Language Rules');
        description('A Ruleset for nicer language');
        context('You are a respected book author, known for your elgant and cultivated language.');
	}

	public Ruleset name(String value) {
		return (Ruleset ) set(Ruleset__c.Name, value);
	}

	public Ruleset description(String value) {
		return (Ruleset) set(Ruleset__c.Description__c, value);
	}

	public Ruleset context(String value) {
		return (Ruleset) set(Ruleset__c.Context__c, value);
	}

	public Ruleset aiRules() {
		return (Ruleset) set(Ruleset__c.AiGenerateRules__c, true);
	}

    public Ruleset add(Rule r) {
		new RuleInSet(this, r);
		return this;
	}
}