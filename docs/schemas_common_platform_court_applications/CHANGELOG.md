# Changes on the schemas

HMCTS does not provide reliable documentation for changes to the Common Platform (CP) APIs. Instead, schemas and change information are exchanged via email.

The purpose of this document is to record all changes made by HMCTS to the Common Platform APIs.

# Changelog:

Date: 26 Feb 2025

File: lib/schemas/global/apiCourtsDefinitions.json
ID: http://justice.gov.uk/core/courts/external/apiCourtsDefinitions.json


`courtApplicationStatus:type` changed to `string`

Added new attribute
`applicationExternalCreatorType`

```
    "applicationExternalCreatorType": {
      "description": "Describes the generic role of the creator of the application in the HMCTS process (Prosecutor)",
      "type": "string",
      "enum": [
        "PROSECUTOR"
      ]
    }
```

--

Date: 21 Feb 2025

File:
    unifiedsearchquery.laa.cases-v1-schema.json
    Renamed to unifiedsearchquery.laa.cases-v2-schema.json
ID: http://justice.gov.uk/json/schemas/domains/unifiedsearchquery/unifiedsearchquery.laa.cases.json

Old attribute: `applicationType`
New attribute: `applicationTitle`

---

Date: 11 Feb 2025

File: unifiedsearchquery.laa.cases-v1-schema.json
ID: http://justice.gov.uk/json/schemas/domains/unifiedsearchquery/unifiedsearchquery.laa.cases.json

The following fields were removed from applicationSummary:

- applicationStatus
- applicationExternalCreatorType
- decisionDate
- dueDate

---
