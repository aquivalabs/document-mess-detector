@SuppressWarnings('PMD.AvoidHardcodingId')
public class Analysis extends DomainBuilder {

	// CONSTRUCTORS

	public Analysis(File_t f, Ruleset r) {
		super(Analysis__c.SObjectType);

		setParent(Analysis__c.Ruleset__c, r);
		
		Id docId = (f.Id == null) ? '000000000000000AAA' 
								  : [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :f.Id].ContentDocumentId;
		set(Analysis__c.DocumentId__c, docId);
		set(Analysis__c.SalesforceRecordId__c, '000000000000000AAA');
		set(Analysis__c.CompletionApi__c, 'OpenAiApi');
	}

	public Analysis(Ruleset r) {
		this(new File_t(), r);
	}

	public Analysis() {
		this(new Ruleset());
	}

	public Analysis add(RegressionTest r) {
		r.setParent(RegressionTest__c.BenchmarkAnalysis__c, this);
		return this;
	}
}