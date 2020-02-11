
## <a name="resource-prosecution_case">Prosecution case search results</a>

Stability: `prototype`

Prosecution case search results

### Attributes

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **data:attributes:date_of_birth** | *string* | The person date of birth when the defendant is a person | `"1954-02-23"` |
| **data:attributes:first_name** | *string* | The fore name when the defendant is a person | `"Elaf"` |
| **data:attributes:last_name** | *string* | The last name when the defendant is a person | `"Alvi"` |
| **data:attributes:national_insurance_number** | *string* | National Insurance Number for a person | `"SJ336043A"` |
| **data:attributes:prosecution_case_reference** | *string* | The prosecuting authorities reference for their prosecution case that is layed before court.  For example PTI-URN from police/cps cases | `"05PP1000915"` |
| **data:id** | *uuid* | Unique identifier of prosecution case provided by HMCTS (prosecutionCaseId) | `"01234567-89ab-cdef-0123-456789abcdef"` |
| **data:type** | *string* | The prosecution cases type<br/> **one of:**`"prosecution_cases"` | `"prosecution_cases"` |

### <a name="link-GET-prosecution_case-/api/internal/v1/prosecution_cases">Prosecution case search results List</a>

Search prosecution cases.

```
GET /api/internal/v1/prosecution_cases
```

#### Optional Parameters

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **filter** | *string* |  |  |


#### Curl Example

```bash
$ curl -n https://laa-court-data-adaptor-dev.apps.live-1.cloud-platform.service.justice.gov.uk/api/internal/v1/prosecution_cases \
 -G \
  -d filter[prosecution_case_reference]=05PP1000915 \
  -H "Content-Type: application/vnd.api+json"
```


#### Response Example

```
HTTP/1.1 200 OK
```

```json
{
  "data": [
    {
      "type": "prosecution_cases",
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "attributes": {
        "first_name": "Elaf",
        "last_name": "Alvi",
        "prosecution_case_reference": "05PP1000915",
        "date_of_birth": null,
        "national_insurance_number": null
      }
    }
  ]
}
```


