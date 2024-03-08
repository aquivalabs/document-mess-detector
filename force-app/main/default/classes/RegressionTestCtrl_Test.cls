@IsTest
private with sharing class RegressionTestCtrl_Test {
    
    @IsTest
    private static void results() {

        // Setup
        Triggers.skips.add(AnalyseDocument.class);
        Triggers.skips.add(ScheduleRegressionTests.class);

        System.runAs(User_t.standard('AppAdministrator')) {
            Exception unexpected = null;
            try {
                Ruleset r = new Ruleset().add(new Rule());
                File_t f = new File_t();
                Analysis a = new Analysis(f, r);
                RegressionTest t = new RegressionTest(a);
                t.persist();
    
                // Exercise
                Test.startTest();
                t.persist();
                Test.stopTest();
            }
            catch(Exception ex) {
                unexpected = ex;
            }

            // Verify
            System.assertEquals(null, unexpected);
        }
    }
}
