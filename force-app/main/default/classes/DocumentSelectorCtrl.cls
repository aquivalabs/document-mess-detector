// Note: Supress PMD until it understands that USER MODE does CRUD
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class DocumentSelectorCtrl {

    @AuraEnabled(cacheable=true)
    public static List<SObject> options(Id recordId) {
        List<SObject> result = new List<SObject>();

        result.addAll([SELECT Title FROM ContentDocument 
                       WHERE FileExtension IN :DocumentText.SUPPORTED_TYPES 
                       AND (Id = :recordId OR Id IN :documentIdsRelatedTo(recordId))
                       WITH USER_MODE]);
        result.addAll(onlySupported([SELECT Name FROM Attachment
                                     WHERE ParentId = :recordId WITH USER_MODE]));                       
        
        return result;
    }

    // PRIVATE 

    // Note: Not doable with a SOQL subquery
    private static Set<Id> documentIdsRelatedTo(Id recordId) {
        Set<Id> result = new Set<Id>();

        for(ContentDocumentLink link : [SELECT ContentDocumentId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId = :recordId
                                        WITH USER_MODE]) {
            result.add(link.ContentDocumentId);
        }

        return result;
    }
    
    private static List<Attachment> onlySupported(List<Attachment> all) {
        List<Attachment> result = new List<Attachment>();

        for(Attachment file : all) {
            if(DocumentText.SUPPORTED_TYPES.contains(file.Name.toLowerCase().substringAfterLast('.'))) {
                result.add(file);
            }
        }

        return result;
    }
}