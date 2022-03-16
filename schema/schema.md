<a name="#resource-defendant"></a>
## Defendants

Stability: `prototype`

Defendants


### Attributes

<details>
  <summary>Details</summary>


| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **[arrest_summons_number](#resource-prosecution_case)** | *string* | The police arrest summons number when the defendant is a person | `"MG25A11223344"` |
| **date_of_birth** | *string* | The person date of birth when the defendant is a person | `"1954-02-23"` |
| **name** | *string* | The full name when the defendant is a person | `"Elaf"` |
| **national_insurance_number** | *string* | National Insurance Number for a person | `"SJ336043A"` |

</details>

<a name="link-GET-defendant-/defendants/{(%23%2Fdefinitions%2Fdefendant%2Fdefinitions%2Fidentity)}"></a>
### Defendants Info

<details>
  <summary>Details</summary>

Info for existing defendant.

```
GET /defendants/{defendant_id}
```


#### Curl Example

```bash
$ curl -n https://dev.court-data-adaptor.service.justice.gov.uk/$DEFENDANT_ID
```


#### Response Example

```
HTTP/1.1 200 OK
```

```json
{
  "type": "defendants",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "attributes": {
    "name": "Elaf",
    "date_of_birth": null,
    "national_insurance_number": null,
    "arrest_summons_number": "MG25A11223344"
  }
}
```

</details>


<a name="#resource-laa_reference"></a>
## LaaReferences

Stability: `prototype`

LaaReferences


### Attributes

<details>
  <summary>Details</summary>


| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **maat_reference** | *number* | The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings<br/> **Range:** `0 <= value <= 999999999` | `314159265` |

</details>

<a name="link-POST-laa_reference-/laa_references"></a>
### LaaReferences Create

<details>
  <summary>Details</summary>

Create a new LaaReference.

```
POST /laa_references
```

#### Optional Parameters

| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **data:attributes:maat_reference** | *number* | The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings<br/> **Range:** `0 <= value <= 999999999` | `314159265` |
| **data:relationships:defendant:data** | *object* |  |  |
| **data:type** | *string* | The laa_references type<br/> **one of:**`"laa_references"` | `"laa_references"` |


#### Curl Example

```bash
$ curl -n -X POST https://dev.court-data-adaptor.service.justice.gov.uk.justice.gov.uk/laa_references \
  -d '{
  "data": {
    "type": "laa_references",
    "attributes": {
      "maat_reference": 314159265
    },
    "relationships": {
      "defendant": {
        "data": [
          {
            "id": "01234567-89ab-cdef-0123-456789abcdef",
            "type": "defendants"
          }
        ]
      }
    }
  }
}' \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer <TOKEN>"
```


#### Response Example

```
HTTP/1.1 202 Accepted
```


</details>


<a name="#resource-oauth"></a>
## OAuth endpoints

Stability: `prototype`

Endpoints for authentication via OAuth

<a name="link-POST-oauth-/oauth/token"></a>
### OAuth endpoints authentication

<details>
  <summary>Details</summary>

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
$ curl -n -X POST https://dev.court-data-adaptor.service.justice.gov.uk/oauth/token \
  -d '{
  "grant_type": "client_credentials",
  "client_id": "b0e2Uw0F_Hn4uVyxcaL6vas7WkYIdCcldv1uCo_vQAY",
  "client_secret": "ezLn2UTPVwqSCVYWPGTeVWcgZdRIPQLmdpQaGMHuCcU"
}' \
  -H "Content-Type: application/json"
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

</details>


<a name="#resource-offence"></a>
## Offences

Stability: `prototype`

Offences


### Attributes

<details>
  <summary>Details</summary>


| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **code** | *string* | The offence code | `"AA06001"` |
| **mode_of_trial** | *string* | Indicates if the offence is either way, indictable only or summary only | `"Indictable-Only Offence"` |
| **order_index** | *integer* | The offence sequence provided by the police<br/> **Range:** `0 <= value` | `0` |
| **title** | *string* | The offence title | `"Fail to wear protective clothing"` |

</details>

<a name="link-GET-offence-/offences/{(%23%2Fdefinitions%2Foffence%2Fdefinitions%2Fidentity)}"></a>
### Offences Info

<details>
  <summary>Details</summary>

Info for existing offence.

```
GET /offences/{offence_id}
```


#### Curl Example

```bash
$ curl -n https://dev.court-data-adaptor.service.justice.gov.uk.justice.gov.uk/offences/$OFFENCE_ID
```


#### Response Example

```
HTTP/1.1 200 OK
```

```json
{
  "type": "offences",
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "attributes": {
    "code": "AA06001",
    "order_index": 0,
    "mode_of_trial": null,
    "title": "Fail to wear protective clothing"
  }
}
```

</details>


<a name="#resource-prosecution_case"></a>
## Prosecution case search results

Stability: `prototype`

Prosecution case search results


### Attributes

<details>
  <summary>Details</summary>


| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **data:attributes:prosecution_case_reference** | *string* | The prosecuting authorities reference for their prosecution case that is layed before court.  For example PTI-URN from police/cps cases | `"05PP1000915"` |
| **data:id** | *uuid* | Unique identifier of prosecution case provided by HMCTS (prosecutionCaseId) | `"01234567-89ab-cdef-0123-456789abcdef"` |
| **data:relationships:defendants:data** | *array* |  | `[{"id":"01234567-89ab-cdef-0123-456789abcdef","type":"defendants"}]` |
| **data:type** | *string* | The prosecution cases type<br/> **one of:**`"prosecution_cases"` | `"prosecution_cases"` |

</details>

<a name="link-GET-prosecution_case-/api/internal/v1/prosecution_cases"></a>
### Prosecution case search results List

<details>
  <summary>Details</summary>

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
$ curl -n https://dev.court-data-adaptor.service.justice.gov.uk/api/internal/v1/prosecution_cases \
 -G \
  -d filter[prosecution_case_reference]=05PP1000915 \
  -H "Content-Type: application/vnd.api+json" \
  -H "Authorization: Bearer <TOKEN>"
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
        "prosecution_case_reference": "05PP1000915"
      },
      "relationships": {
        "defendants": {
          "data": [
            {
              "id": "01234567-89ab-cdef-0123-456789abcdef",
              "type": "defendants"
            }
          ]
        }
      }
    }
  ],
  "included": [
    null
  ]
}
```

</details>


