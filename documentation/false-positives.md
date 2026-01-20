# False Positives

- **Namespace:** `dmd_ai`
- **Package Id:** `00D36000001GDyG`
- **Package Version:** `1.28`

## Salesforce Code Analyzer

### ApexSuggestUsingNamedCred

1. `ConvertAPI.cls` (lines: 59)
ConvertAPI credentials are stored in a secure way in a protected Custom Metadata record and are therefore not accessible by subscribers.

1. `OpenAiHandler.cls` (lines: 31)
OpenAI API credentials are stored in a secure way in a protected Custom Metadata record and are therefore not accessible by subscribers.

### Salesforce Code Analyzer - DFA

No issue was found.

### Checkmarx - Force.com Source Scanner

Found during Security Review by the Salesforce team:

#### TLS/SSL Configuration Vulnerability

in pages\setup.page

The page with the Anchor Link doesn't expose any risk and the referenced OpenAi API is mentioned in other parts of this document. Yes we are using OpenAi but there is no way to get:

- approval from OpenAI for scanning their API
- having them fix any "issues" with their API

We took part in the Einstein GPT Pilot for Dreamforce and heard that many partners that are using this API are struggling with this. Even knowing that Salesforce itsself is using this API.

#### CRUD/FLS Enforcement Vulnerability

RegressionTest__c is an object that could be seen by anybody in the org as it only shows data on the regression of Analysis runs. We nonetheless restricted AppAdministrators to do CRUD on it via a PermissionSet. We decided to not go with as user checks as the recommended Code Analyser didn't work with it. We also did not use the costly Drescribe checks for the above mentioned reasons that the object doesn't contain any sensible information

### OWASP ZAP

Ask Your Document application uses two external services: OpenAI API and ConvertAPI.

1. ConvertAPI

We ran the scan using OWASP ZAP against the ConvertAPI endpoint and included its report along with other documents.

1. OpenAI API

We didn’t run the scan against OpenAI API because of two reasons:
Our request for approval to do so remained unanswered
We assume that OpenAI API was checked and approved by Salesforce as Salesforce uses it in its own products
