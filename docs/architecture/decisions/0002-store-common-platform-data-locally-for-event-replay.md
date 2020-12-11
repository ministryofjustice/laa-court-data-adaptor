# 2. Store Common Platform data locally for event replay

Date: 2020-12-11

## Status

Accepted

## Context

The Court Data Adaptor application relies heavily on CJS Common Platform provided APIs to be able to function. As the Common Platform is owned by a third party organisation, we have limited control over the kind of data sent through to CDA.

## Decision

In order to be able to inspect the data (if needed) for debugging, it has been agreed that we will store each request coming through to CDA in a data store (RDS provided postgres instance).

## Consequences

The Database layer would need to be removed enventually as it could potentially have GDPR implications. The end goal would be CDA being stateless, and reducing/moving out the stateful parts as part of decisions arrived at the [Common Platform NOLASA Equivalent spike](https://dsdmoj.atlassian.net/wiki/spaces/LAACP/pages/2555117584/Early+Applications+for+Common+Platform+Cases+NOLASA+Equivalent+-+Spike+Summary), one of the applications responsible would be the [Court Data Orchestration Service](https://github.com/ministryofjustice/laa-court-data-orchestration-service)
