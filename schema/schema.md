
## <a name="resource-oauth">OAuth endpoints</a>

Stability: `prototype`

Endpoints for authentication via OAuth

### <a name="link-POST-oauth-/oauth/token">OAuth endpoints authentication</a>

Request a new access token.

```
POST /oauth/token
```

#### Required Parameters

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **client_id** | *string* | Client id for authentication | `"b0e2Uw0F_Hn4uVyxcaL6vas7WkYIdCcldv1uCo_vQAY"` |
| **client_secret** | *string* | Client secret for authentication | `"ezLn2UTPVwqSCVYWPGTeVWcgZdRIPQLmdpQaGMHuCcU"` |
| **grant_type** | *string* | Grant type for the oauth token request.<br/> **one of:**`"client_credentials"` | `"client_credentials"` |



#### Curl Example

```bash
$ curl -n -X POST https://laa-court-data-adaptor-dev.apps.live-1.cloud-platform.service.justice.gov.uk/oauth/token \
  -d '{
  "grant_type": "client_credentials",
  "client_id": "b0e2Uw0F_Hn4uVyxcaL6vas7WkYIdCcldv1uCo_vQAY",
  "client_secret": "ezLn2UTPVwqSCVYWPGTeVWcgZdRIPQLmdpQaGMHuCcU"
}' \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
```


#### Response Example

```
HTTP/1.1 201 Created
```

```json
{
  "access_token": "lV_-FViUsQE2OrYnXQhVyAlzYgIc8Mal8g5YBFGs3J8",
  "token_type": "Bearer",
  "expires_in": 7200,
  "created_at": "2015-01-01T12:00:00Z"
}
```


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

### <a name="link-GET-prosecution_case-/api/prosecution_cases">Prosecution case search results List</a>

Search prosecution cases.

```
GET /api/prosecution_cases
```

#### Optional Parameters

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **filter** | *string* |  |  |


#### Curl Example

```bash
$ curl -n https://laa-court-data-adaptor-dev.apps.live-1.cloud-platform.service.justice.gov.uk/api/prosecution_cases \
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


