@IsTest
private class TidyClonedAnalysis_Test {
    
    @IsTest
    private static void happyPath() {

        // Setup
        Analysis__c original = (Analysis__c) new Analysis().persist();
        original.Status__c = 'Failed';
        original.FailReason__c = 'Exception';
        update original;

        // Exercise
        Analysis__c clone = original.clone();
        insert clone;

        // Verify
        clone = [SELECT Id, Status__c, FailReason__c FROM Analysis__c WHERE Id = :clone.Id];
        System.assertNotEquals(original.Status__c, clone.Status__c);
        System.assertNotEquals(original.FailReason__c, clone.FailReason__c);
    }
}