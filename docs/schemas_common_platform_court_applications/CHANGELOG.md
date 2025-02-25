# Changes on the schemas

HMCTS does not provide reliable documentation for changes to the Common Platform (CP) APIs. Instead, schemas and change information are exchanged via email.

The purpose of this document is to record all changes made by HMCTS to the Common Platform APIs.

# Changelog:

Change Date: 21 Feb 2025

File: unifiedsearchquery.laa.cases-v1-schema.json
ID: http://justice.gov.uk/json/schemas/domains/unifiedsearchquery/unifiedsearchquery.laa.cases.json

Old attribute: `applicationType`
New attribute: `applicationTitle`

---

Change Date: 11 Feb 2025

File: unifiedsearchquery.laa.cases-v1-schema.json
ID: http://justice.gov.uk/json/schemas/domains/unifiedsearchquery/unifiedsearchquery.laa.cases.json

The following fields are removed from applicationSummary:

- applicationStatus
- applicationExternalCreatorType
- decisionDate
- dueDate

---
