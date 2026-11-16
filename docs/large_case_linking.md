# Large Case Linking

## Quick Start

```bash
bundle exec rake case_links:link_large_case MAAT_ID USER_NAME DEFENDANT_ID
```

**Example**:

```bash
bundle exec rake case_links:link_large_case 1234567 peter 2ecc9feb-9407-482f-b081-d9e5c8ba3ed3
```

**Expected duration**: ~110 seconds for 110 offences

## Problem

Linking a defendant with a very large number of offences (e.g. 110) makes rapid sequential calls to Common Platform (one per offence), which can return HTTP 429 (rate limit exceeded) and leave the case partially linked.

## Solution

The `case_links:link_large_case` rake task is a thin wrapper around the normal linking flow. It:

1. Validates the params with `ProsecutionCaseLaaReferenceContract`, exactly as `Api::Internal::V2::ProsecutionCaseLaaReferencesController#create` does (valid MAAT reference, user name, defendant ID, case can be linked).
2. Calls `ProsecutionCaseMaatLinkCreator` with `offence_delay: 1`.

So it reuses the normal behaviour: posting each offence to CP, publishing to the MAAT queue, enqueueing the past hearing results fetch, and marking the reference as linked.

### `offence_delay` option

`ProsecutionCaseMaatLinkCreator.new(defendant_id, user_name, maat_reference, offence_delay: 0)`

- Waits `offence_delay` seconds between offence posts to CP (not after the last one).
- When greater than zero, offences already successfully posted today (`rep_order_status` `AP`, 2xx `response_status`, `status_date` today) are skipped, so the task can be re-run after a failure without re-posting everything.

The default (`0`) leaves the normal API flow unchanged.

## Parameters

- `MAAT_ID`: The MAAT reference number (e.g., `1234567`)
- `USER_NAME`: The user performing the linking (max 10 characters, e.g., `peter`)
- `DEFENDANT_ID`: The defendant UUID, as sent by VCD in the normal flow

## Testing

```bash
bundle exec rspec spec/services/prosecution_case_maat_link_creator_spec.rb spec/lib/tasks/case_links_spec.rb
```

## Error Handling

```
[ERROR] Missing required arguments. Usage: rake case_links:link_large_case MAAT_ID USER_NAME DEFENDANT_ID
[ERROR - 2026-11-13 08:03:34 +0000] Failed to link defendant: Contract failed with: {...}
[ERROR - 2026-11-13 08:03:34 +0000] Failed to link defendant: <error details>
```

## See Also

- `ProsecutionCaseMaatLinkCreator`: Normal linking service (used by VCD)
- `ProsecutionCaseLaaReferenceContract`: Input validation
