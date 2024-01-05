public with sharing class Rule extends DomainBuilder {

    public Rule() {
		super(Rule__c.SObjectType);

		name('No Rude Language');
        description('Prevents rude language');
		content('The Document should not use rude words.');
	}

	public Rule(Ruleset s) {
		this();
        new RuleInSet(s, this);
    }

	public Rule name(String value) {
		return (Rule) set(Rule__c.Name, value);
	}

	public Rule description(String value) {
		return (Rule) set(Rule__c.Description__c, value);
	}

	public Rule content(String value) {
		return (Rule) set(Rule__c.Content__c, value);
	}
}