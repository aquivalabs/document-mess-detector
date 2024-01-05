public with sharing class ExportImportCtrl {

    private Set<Id> recordIds = new Set<Id>();

    public String content { private set; public get; }


    // CONSTRUCTORS

    public ExportImportCtrl(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public ExportImportCtrl(ApexPages.StandardSetController ctrl) {
        this( new Map<Id, SObject>(ctrl.getSelected()).keySet() );
    }

    public ExportImportCtrl(ApexPages.StandardController ctrl) {
        this( new Set<Id>{ ctrl.getId() } );
    }

    // PUBLIC

    public PageReference doExport() {
        PageReference result = null;

        if(!recordIds.isEmpty()) {
            content = SObjectDataLoader.serialize(recordIds, getSerializeConfig());
        }
        else {
            ApexPages.addMessage( new ApexPages.message(ApexPages.Severity.FATAL,'No Products Found'));
        }
        
        return result;
    }

    @AuraEnabled
    public static void doImport(String jsonContent){
        SObjectDataLoader.deserialize(jsonContent);
    }

	// PRIVATE

	private SObjectDataLoader.SerializeConfig getSerializeConfig() {
		return new SObjectDataLoader.SerializeConfig()
                                            .followChild(RuleInSet__c.Ruleset__c)
											.follow(RuleInSet__c.Rule__c);
	}
}
