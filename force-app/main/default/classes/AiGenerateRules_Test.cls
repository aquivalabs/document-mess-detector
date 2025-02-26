@IsTest
private class AiGenerateRules_Test {
    
    @IsTest
    private static void happyPath() {

        // Setup & Exercise
        new Ruleset()
                .name('10 Rules to write the perfect loveletter')
                .aiRules()
                .persist();

        // Verify
        System.assertEquals(10, [SELECT Count() FROM Rule__c]);
    }
}