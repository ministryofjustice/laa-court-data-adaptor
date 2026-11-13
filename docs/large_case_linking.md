# Large Case Linking Solution

## Quick Start

For immediate use, run:

```bash
bundle exec rake case_links:link_large_case MAAT_ID USER_NAME CASE_URN
```

**Example**:

```bash
bundle exec rake case_links:link_large_case 1234567 peter.rabbit 99LD1234567
```

**Expected duration**: ~110 seconds for 110 offences

## Overview

This solution provides a mechanism for manually linking cases with large numbers of offences (100+) to MAAT without hitting Common Platform API rate limits (429 errors).

## Problem

When attempting to link cases with substantial numbers of offences (e.g., 110 offences), the normal linking process makes rapid sequential API calls to Common Platform, causing HTTP 429 (rate limit exceeded) responses. This leaves cases in an inconsistent state where some offences are linked but others are not.

**Example**: Case `99LD1234567` with 110 offences linked to MAAT ID `1234567` by user `peter.rabbit` on 12 Nov 2026.

## Solution

A new Rake task `case_links:link_large_case` that:

- Replicates the normal linking behavior (linking offences to CP, then notifying MAAT)
- Introduces a **1 second delay** between each offence API call to CP
- Prevents rate limiting errors through throttling
- Provides detailed logging of progress

## Components

### 1. New Service: `LinkLargeCaseWithThrottling`

**Location**: `app/services/link_large_case_with_throttling.rb`

**Functionality**:

- Finds the prosecution case by URN
- Identifies the defendant for the case
- Creates an LAA reference record
- Links each offence to Common Platform with 1 second throttling between calls
- Publishes link notification to MAAT queue
- Marks the reference as linked in the database

**Key Features**:

- Configurable delay via `OFFENCE_LINKING_DELAY` constant (default: 1 second)
- Detailed logging at each step
- Comprehensive error handling with Sentry integration
- Graceful handling of already-linked cases

### 2. New Rake Task: `case_links:link_large_case`

**Location**: `lib/tasks/case_links.rake`

**Usage**:

```bash
bundle exec rake case_links:link_large_case MAAT_ID USER_NAME CASE_URN
```

**Example**:

```bash
bundle exec rake case_links:link_large_case 1234567 peter.rabbit 99LD1234567
```

**Parameters**:

- `MAAT_ID`: The MAAT reference number (e.g., `1234567`)
- `USER_NAME`: The user performing the linking (e.g., `peter.rabbit`)
- `CASE_URN`: The prosecution case URN (e.g., `99LD1234567`)

## How It Works

1. **Find Case**: Queries the database for prosecution case matching the provided URN
2. **Get Defendant**: Retrieves the defendant associated with the case
3. **Create LAA Reference**: Creates a new LAA reference record in the database
4. **Link Offences**: For each offence:
   - Calls Common Platform API to record the LAA reference
   - Sleeps for 1 second (except after the last offence)
   - Logs progress
5. **Notify MAAT**: Publishes link notification to SQS queue
6. **Mark Linked**: Updates the LAA reference status to linked

### Timeline Example (110 offences)

- Offence 1: Link to CP → Sleep 1s → Offence 2: Link to CP → Sleep 1s → ... → Offence 110: Link to CP (no sleep)
- **Total time**: ~110 seconds (1m 50s) for 110 offences

## Benefits

✅ **Prevents Rate Limits**: 1 second delay between requests stays well within CP rate limits
✅ **Predictable**: Manual execution allows monitoring and control
✅ **Recoverable**: Detailed logging helps track what succeeded and what failed
✅ **Maintainable**: Service-based design allows easy adjustment of throttling behavior
✅ **Extensible**: Can be exposed through VCD UI in future for caseworker self-service

## Testing

Tests verify:

- Correct linking of 110 offences with proper delays
- Message publication to MAAT queue
- LAA reference marked as linked
- Error handling and Sentry integration
- Graceful error messages for missing cases or defendants

Run tests:

```bash
bundle exec rspec spec/services/link_large_case_with_throttling_spec.rb -v
```

## Error Handling

The task provides clear error messages for common issues:

```
[ERROR] Missing required arguments. Usage: rake case_links:link_large_case MAAT_ID USER_NAME CASE_URN
[ERROR - 2026-11-13 08:03:34 +0000] Prosecution case not found for URN 99LD1234567
[ERROR - 2026-11-13 08:03:34 +0000] No defendants found for case 99LD1234567
[ERROR - 2026-11-13 08:03:34 +0000] Failed to link case: <error details>
```

## Expected Output

When running successfully, you'll see progress logging like:

```
[INFO - 2026-11-13 08:03:34 +0000] Starting large case linking process...
[INFO - 2026-11-13 08:03:34 +0000] MAAT Reference: 1234567, User: peter.rabbit, Case URN: 99LD1234567
[INFO - 2026-11-13 08:03:34 +0000] Linking 110 offences to Common Platform with 1s delay between each...
[INFO - 2026-11-13 08:03:35 +0000] Linked offence 1/110 (ID: offence-123)
[INFO - 2026-11-13 08:03:36 +0000] Linked offence 2/110 (ID: offence-456)
...
[INFO - 2026-11-13 08:05:24 +0000] Successfully linked all 110 offences
[INFO - 2026-11-13 08:05:24 +0000] Publishing link notification to MAAT queue...
[INFO - 2026-11-13 08:05:25 +0000] Published link notification to MAAT queue
[SUCCESS - 2026-11-13 08:05:25 +0000] Case 99LD1234567 successfully linked to MAAT ID 1234567
```

## Future Enhancements

1. **VCD Integration**: Expose task through VCD UI for caseworker self-service
2. **Configurable Delay**: Allow caseworkers to specify throttling delay
3. **Batch Processing**: Support multiple cases in a single run
4. **Dry Run Mode**: Add `--dry-run` flag to preview linking without executing

## Alternative Approaches Considered

1. **Adding sleep to normal flow**: ❌ Would impact performance of all linking operations
2. **Exponential backoff only**: ❌ Insufficient for cases with 100+ offences
3. **Batch API endpoint**: ❌ Common Platform does not provide a batch endpoint for this operation

## See Also

- `ProsecutionCaseMaatLinkCreator`: Normal linking service (used by VCD)
- `LaaReferenceUnlinker`: Complementary unlinking functionality
- `Sqs::MessagePublisher`: Queue publishing mechanism
- Common Platform API: `RecordProsecutionCaseLaaReference`
