// Note: One days RegressionTest and Cron related test failed with ORA deadlocks
@IsTest(isParallel=false)
private class NotifyUserOnAnalysisChange_Test {

    @IsTest
    private static void onSuccess() {

        // Setup
        Ruleset s = new Ruleset().add( new Rule() );

        Analysis__c a = (Analysis__c) new Analysis(s)
                                            .persist();

        // Exercise
        a.Status__c = 'Successful';
        update a;


        // Verify
        Notification.Message n = Notification.MESSAGES[0];
        System.assertEquals(n.targetId, a.Id);
        System.assert(n.title.endsWith('passed DMD analysis'), n.title);
    }


    @IsTest
    private static void onFailure() {

        // Setup
        Rule r = new Rule().name('FailedRule');
        Ruleset s = new Ruleset().add(r);

        Analysis__c a = (Analysis__c) new Analysis(s)
                                            .persist();

        // Exercise
        insert new Result__c(Analysis__c = a.Id, Status__c = 'Fail', Rule__c = r.Id);

        a.Status__c = 'Failed';
        update a;


        // Verify
        Notification.Message n = Notification.MESSAGES[0];
        System.assertEquals(n.targetId, a.Id);
        System.assert(n.title.endsWith('failed DMD analysis'), n.title);
        System.assert(n.body.contains('\n- FailedRule'), n.body);
    }
    

    @IsTest
    private static void onError() {

        // Setup
        Analysis__c a = (Analysis__c) new Analysis().persist();
        

        // Exercise
        a.Status__c = 'Error';
        a.FailReason__c = 'Invalid API Key';
        update a;


        // Verify
        Notification.Message n = Notification.MESSAGES[0];
        System.assertEquals(n.targetId, a.Id);
        System.assert(n.title.endsWith('aborted with error'), n.title);
        System.assert(n.body.contains(a.FailReason__c), n.body);
    }
    

    @IsTest
    private static void ignoresRegressionTests() {

        // Setup
        Analysis__c a = (Analysis__c) new Analysis()
                                            .add(new RegressionTest())
                                            .persist();

        // Exercise
        a.Status__c = 'Successful';
        a.RegressionTest__c = [SELECT Id FROM RegressionTest__c LIMIT 1 FOR UPDATE].Id;
        update a;


        // Verify
        System.assertEquals(0, Notification.MESSAGES.size());
    }
}