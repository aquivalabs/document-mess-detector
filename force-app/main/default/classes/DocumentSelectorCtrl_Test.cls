@IsTest
private class DocumentSelectorCtrl_Test {

    @IsTest
    static void recordOptionsShowFilesAndAttachments() {

        // Setup
        Account_t a = new Account_t();

        new Attachment_t(a).name('attachment.pdf');
        new Attachment_t(a).name('attachment.UNSUPPORTED');
        a.persist();

        File_t f1 = new File_t().path('file.pdf');
        f1.persist();
        f1.link(a);

        File_t f2 = new File_t().path('file.UNSUPPORTED');
        f2.persist();
        f2.link(a);
        

        // Exercise
        List<SObject> options = DocumentSelectorCtrl.options(a.Id);


        // Verify
        System.assertEquals(2, options.size());
    }

    
    @IsTest
    static void filePageShowsWhenSupported() {

        // Setup
        File_t f = new File_t().path('doc.pdf');
        f.persist();

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :f.Id LIMIT 1].ContentDocumentId;
        

        // Exercise
        List<SObject> options = DocumentSelectorCtrl.options(docId);


        // Verify
        System.assertEquals(1, options.size());
        System.assertEquals('file', ((ContentDocument) options.get(0)).Title);
    }

    
    @IsTest
    static void filePageHiddesWhenUnsupported() {

        // Setup
        File_t f = new File_t().path('file.UNSUPPORTED');
        f.persist();

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :f.Id LIMIT 1].ContentDocumentId;
        

        // Exercise
        List<SObject> options = DocumentSelectorCtrl.options(docId);


        // Verify
        System.assertEquals(0, options.size());
    }
}
