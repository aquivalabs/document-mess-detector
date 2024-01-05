public class RuleInSet extends DomainBuilder {

	public RuleInSet(Ruleset s, Rule r) {
		super(RuleInSet__c.SObjectType);
		setParent(RuleInSet__c.Ruleset__c, s);
		setParent(RuleInSet__c.Rule__c, r);
	}
}
