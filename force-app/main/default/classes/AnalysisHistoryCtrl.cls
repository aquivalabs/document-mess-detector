// Suppressed as PMD needs to be updates to check USER_MODE
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class AnalysisHistoryCtrl {
    
    @AuraEnabled
    public static List<Analysis> history(Id documentId) {
        List<Analysis> result = new List<Analysis>();
        for (Analysis__c analysis : [
            SELECT Name, CreatedBy.Name, CreatedDate, Status__c, Ruleset__c, Ruleset__r.Name
            FROM Analysis__c
            WHERE DocumentId__c = :documentId
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 7
        ]) {
            result.add(new Analysis(analysis));
        }
        return result;
    }

    public class Analysis {
        @AuraEnabled
        public Id analysisId { get; private set; }
        @AuraEnabled
        public String analysisName { get; private set; }
        @AuraEnabled
        public Id rulesetId { get; private set; }
        @AuraEnabled
        public String rulesetName { get; private set; }
        @AuraEnabled
        public Datetime createdDate { get; private set; }
        @AuraEnabled
        public String createdBy { get; private set; }
        @AuraEnabled
        public String status { get; private set; }

        private Analysis(Analysis__c record) {
            this.analysisId = record.Id;
            this.analysisName = record.Name;
            this.rulesetId = record.Ruleset__c;
            this.rulesetName = record.Ruleset__r.Name;
            this.status = record.Status__c;
            this.createdBy = record.CreatedBy.Name;
            this.createdDate = record.CreatedDate;
        }
    }
}