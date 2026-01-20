@IsTest
private class SetupExtractApi_Test {
        
    @IsTest
    private static void createSettings() {
        
        // Setup
        Test.setCurrentPage(Page.setup);
        SetupExtractApi step = new SetupExtractApi();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Exercise
        step.settings.txt_ExtractApiKey__c = '2134456';
        step.run();
        


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());

        DmdSettings__c settings = [SELECT txt_ExtractApiKey__c FROM DmdSettings__c LIMIT 1];
        System.assertEquals(step.settings.txt_ExtractApiKey__c, settings.txt_ExtractApiKey__c);
    }
        

    @IsTest
    private static void changeSettings() {
        
        // Setup
        insert new DmdSettings__c();

        Test.setCurrentPage(Page.setup);
        SetupExtractApi step = new SetupExtractApi();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        step.settings.txt_ExtractApiKey__c = '2134456';
        step.run();


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());
    }
}