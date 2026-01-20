public with sharing class File_t extends DomainBuilder {

    public File_t() {
		super(ContentVersion.SObjectType);

        name('file');
        path('/document.pdf');
        body('content');
	}

	public File_t name(String value) {
		return (File_t) set(ContentVersion.Title, value);
	}

	public File_t path(String value) {
		return (File_t) set(ContentVersion.PathOnClient, value);
    }

	public File_t body(String value) {
		return (File_t) set(ContentVersion.VersionData, Blob.valueOf(value));
	}

	// Note: PMD False Positive as CRUD is ignored in Test Builders
	@SuppressWarnings('PMD.ApexCRUDViolation')
	public void link(DomainBuilder parent) {
		// Note: Only works after File has been persisted. Hack to make it work. Ugly!
		insert new ContentDocumentLink(
			ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :record.Id LIMIT 1].ContentDocumentId,
			LinkedEntityId = parent.record.Id,
			ShareType = 'V'
		);
	}
}