// Note: Most code taken from https://github.com/Docparser/Docparser-Apex/blob/master/upload_document.apx
public with sharing class DocumentText {

    public static final Set<String> SUPPORTED_TYPES = new Set<String>{ 'pdf'};

    // PUBLIC

    // Note: PMD Ignore see https://salesforce.stackexchange.com/q/406970/256
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public String extractFrom(ContentVersion document) {
        HttpResponse result = null;

        try {
            String boundary = 'A RANDOM STRING';
            String header = '--' + boundary + '\nContent-Disposition: form-data; name="file"; filename="' + document.PathOnClient + '"\nContent-Type: multipart/form-data;'+'\nnon-svg='+True;
            String headerEncoded;
            do {
                header += ' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
            }
            while(headerEncoded.endsWith('='));

            failWhenInsufficientHeapFor(document);

            String footer = '--' + boundary + '--';
            String bodyEncoded = EncodingUtil.base64Encode(document.VersionData);

            if (bodyEncoded.endsWith('==')) {
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-2) + '0K';
            }
            else if(bodyEncoded.endsWith('=')) {
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-1) + 'N';
                footer = '\n' + footer;           
            }
            else {
                footer = '\r\n' + footer;
            }

            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            Blob bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://extractorapi.com/api/v1/pdf-extractor?apikey=' + apiKey());
            request.setMethod('POST');
            request.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            request.setBodyAsBlob(bodyBlob);
            request.setHeader('Content-Length', String.valueOf(request.getBodyAsBlob().size()));
            request.setTimeout(120000);
            
            result = new Http().send(request);
            if(result.getStatusCode() != 200) {
                throw new ApplicationException('Error: ' + result.toString());
            }
        } 
        catch(Exception error) {
            throw new ApplicationException('Error extracting text from document: ', error);
        }

        return result.getBody();
    }


    // PRIVATE

    private static String apiKey() {
        DmdSettings__c result = DmdSettings__c.getOrgDefaults();
        
        if(result == null || result.txt_ExtractApiKey__c == null ) {
            throw new ApplicationException('No Extract API Key found in Settings.');
        }

        return result.txt_ExtractApiKey__c;
    }

    private void failWhenInsufficientHeapFor(ContentVersion document) {
        if(document.ContentSize > availableHeap()) {
            throw new ApplicationException('Insufficient heap to extract text from document');
        }
    }

    private Integer availableHeap() {
        return Limits.getLimitHeapSize() - Limits.getHeapSize();
    }
}
