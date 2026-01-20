public with sharing class Attachment_t extends DomainBuilder {

    public Attachment_t() {
		super(Attachment.SObjectType);

        name('attachment.pdf');
        type('text/json');
        body('content');
	}

    public Attachment_t(DomainBuilder parent) {
		this();

		setParent(Attachment.ParentId, parent);
	}

	public Attachment_t name(String value) {
		return (Attachment_t) set(Attachment.Name, value);
	}

	public Attachment_t type(String value) {
		return (Attachment_t) set(Attachment.ContentType, value);
    }

	public Attachment_t body(String value) {
		return (Attachment_t) set(Attachment.Body, Blob.valueOf(value));
	}
}