@IsTest
private class ExportImportRulesetCtrl_Test {

    @IsTest
    private static void exportSingleRuleset() {

        // Setup
        Ruleset s = new RuleSet()
                            .name('Ruleset1')

                            .add( new Rule().name('Rule1') )
                            .add( new Rule().name('Rule2') );
        s.persist();

         
        // Exercise
        ExportImportRulesetCtrl ctrl = new ExportImportRulesetCtrl(new Set<Id>{ s.Id });
        ctrl.doExport();


        // Verify
        System.assertEquals(1, ctrl.content.countMatches('Ruleset1'));
        System.assertEquals(1, ctrl.content.countMatches('Rule1'));
        System.assertEquals(1, ctrl.content.countMatches('Rule2'));
    }

    @IsTest
    private static void exportAndImport() {

         // Setup
        Ruleset s = new RuleSet()
                            .name('Ruleset1')
                            
                            .add( new Rule().name('Rule1') )
                            .add( new Rule().name('Rule2') );
        s.persist();

        ExportImportRulesetCtrl ctrl = new ExportImportRulesetCtrl(new Set<Id>{ s.Id });
        ctrl.doExport();


        // Exercise
        ExportImportRulesetCtrl.doImport(ctrl.content);

        // Verify
        System.assertEquals(2, [SELECT Count() FROM Ruleset__c WHERE Name = 'Ruleset1']);
        System.assertEquals(2, [SELECT Count() FROM Rule__c WHERE Name = 'Rule1']);
        System.assertEquals(2, [SELECT Count() FROM Rule__c WHERE Name = 'Rule2']);
    }

    @IsTest
    private static void exportDoesntCrawlSharedRulesets() {

         // Setup
        Rule shared = new Rule().name('Shared');

        new Ruleset().name('ToIgnore').add(shared);

        Ruleset s = new RuleSet().name('ToExport')
                            .add( new Rule().name('Rule') )
                            .add(shared);
        s.persist();

        ExportImportRulesetCtrl ctrl = new ExportImportRulesetCtrl(new Set<Id>{ s.Id });
        ctrl.doExport();


        // Exercise
        ExportImportRulesetCtrl.doImport(ctrl.content);

        // Verify
        System.assertEquals(2, [SELECT Count() FROM Ruleset__c WHERE Name = 'ToExport']);
        System.assertEquals(1, [SELECT Count() FROM Ruleset__c WHERE Name = 'ToIgnore']);
        System.assertEquals(2, [SELECT Count() FROM Rule__c WHERE Name = 'Rule']);
        System.assertEquals(2, [SELECT Count() FROM Rule__c WHERE Name = 'Shared']);
    }

    @IsTest
    private static void sharedRulesAreOnlyExportedOnce() {

         // Setup
        Rule shared = new Rule().name('Shared');

        Ruleset s1 = new Ruleset().add(shared);
        Ruleset s2 = new RuleSet().add(shared);
        shared.persist();

        ExportImportRulesetCtrl ctrl = new ExportImportRulesetCtrl(new Set<Id>{ s1.Id, s2.Id });
        ctrl.doExport();


        // Exercise
        ExportImportRulesetCtrl.doImport(ctrl.content);

        // Verify
        System.assertEquals(4, [SELECT Count() FROM Ruleset__c]);
        System.assertEquals(2, [SELECT Count() FROM Rule__c WHERE Name = 'Shared']);
    }
}