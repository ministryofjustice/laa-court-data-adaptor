# Large Case Linking

## Quick Start

Prosecution case (defendant):

```bash
bundle exec rake case_links:link_prosecution_case_with_many_offences MAAT_ID USER_NAME DEFENDANT_ID
```

Court application (subject):

```bash
bundle exec rake case_links:link_court_application_with_many_offences MAAT_ID USER_NAME SUBJECT_ID
```

**Examples**:

```bash
bundle exec rake case_links:link_prosecution_case_with_many_offences 1234567 peter 2ecc9feb-9407-482f-b081-d9e5c8ba3ed3
bundle exec rake case_links:link_court_application_with_many_offences 1234567 peter 2ecc9feb-9407-482f-b081-d9e5c8ba3ed3
```

**Expected duration**: ~110 seconds for 110 offences

## Problem

Linking a defendant or court application subject with a very large number of offences (e.g. 110) makes rapid sequential calls to Common Platform (one per offence), which can return HTTP 429 (rate limit exceeded) and leave the case partially linked.

## Solution

Both rake tasks are thin wrappers around the normal linking flow.

### `case_links:link_prosecution_case_with_many_offences`

1. Validates the params with `ProsecutionCaseLaaReferenceContract`, exactly as `Api::Internal::V2::ProsecutionCaseLaaReferencesController#create` does (valid MAAT reference, user name, defendant ID, case can be linked).
2. Calls `ProsecutionCaseMaatLinkCreator` with `offence_delay: 1`.

### `case_links:link_court_application_with_many_offences`

1. Validates the params with `CourtApplicationLaaReferenceContract`, exactly as `Api::Internal::V2::CourtApplicationLaaReferencesController#create` does (valid MAAT reference, user name, subject ID, court application summary exists).
2. Calls `CourtApplicationMaatLinkCreator` with `offence_delay: 1`.

Both reuse the normal behaviour: posting each offence to CP, publishing to the MAAT queue, enqueueing the past hearing results fetch, and marking the reference as linked.

### `offence_delay` option

`ProsecutionCaseMaatLinkCreator.new(defendant_id, user_name, maat_reference, offence_delay: 0)`

`CourtApplicationMaatLinkCreator.new(subject_id, user_name, maat_reference, offence_delay: 0)`

- Waits `offence_delay` seconds after each offence post to CP (including the last one, to space it from any following request).
- All offences are always posted, including on a re-run after a failure. Previously posted offences are deliberately not skipped, so no offence is left unlinked, linked to a previous MAAT ID, or with an incorrect status.

The default (`0`) leaves the normal API flow unchanged.

## Parameters

- `MAAT_ID`: The MAAT reference number (e.g., `1234567`)
- `USER_NAME`: The user performing the linking (max 10 characters, e.g., `peter`)
- `DEFENDANT_ID`: The defendant UUID, as sent by VCD in the normal flow (prosecution cases)
- `SUBJECT_ID`: The court application subject UUID, as sent by VCD in the normal flow (court applications)

## Testing

```bash
bundle exec rspec spec/services/prosecution_case_maat_link_creator_spec.rb spec/services/court_application_maat_link_creator_spec.rb spec/lib/tasks/case_links_spec.rb
```

## Error Handling

```
[ERROR] Missing required arguments. Usage: rake case_links:link_prosecution_case_with_many_offences MAAT_ID USER_NAME DEFENDANT_ID
[ERROR] Missing required arguments. Usage: rake case_links:link_court_application_with_many_offences MAAT_ID USER_NAME SUBJECT_ID
[ERROR - 2026-11-13 08:03:34 +0000] Failed to link defendant: Contract failed with: {...}
[ERROR - 2026-11-13 08:03:34 +0000] Failed to link court application subject: <error details>
```

## See Also

- `ProsecutionCaseMaatLinkCreator`: Normal prosecution case linking service (used by VCD)
- `CourtApplicationMaatLinkCreator`: Normal court application linking service (used by VCD)
- `ProsecutionCaseLaaReferenceContract`, `CourtApplicationLaaReferenceContract`: Input validation
