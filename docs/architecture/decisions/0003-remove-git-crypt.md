# 3. Remove git-crypt

Date: 2026-10-13

## Status

Accepted

## Context

CDA contains a number of config files for the different environments it is deployed to, for use by Helm during the
actual deployment process. The files for dev, test and UAT are all publicly accessible and contain no secrets / sensitive
data, whereas the production file is encrypted with git-crypt as it contains actual endpoints and other sensitive data.

For a developer to be able to make a change to or view any production config, they first need to install git-crypt,
set-up a GPG key on their machine, make the public part of this key available via a key server and then ask a
developer who already has access to the production file to add their public key as trusted by way of re-encrypting the
data with this new key and raising a PR. Only once all of these steps have taken place will the developer now have
access to the single encrypted file. This is a large overhead and a brittle process as it relies on a few people who
have access; if their laptops were to stop working, they would also lose access to their keys if they hadn’t backed
them up and then no-one would be able to access the encrypted data.

## Decision

We have decided to remove `git-crypt` from the repository and instead manage sensitive values outside of the repository.

Most of the secrets that are used by the application at runtime are already managed in AWS Secrets Manager
(see [helm_deploy/laa-court-data-adaptor/templates/_environment.tpl](../../../helm_deploy/laa-court-data-adaptor/templates/_environment.tpl)).
However, some of the secrets that are used by Helm during deployment are still stored in the encrypted production config
file. These secrets will be moved to CircleCI environment variables and passed to the Helm deployment process via the
CircleCI pipeline.

Once this is in place, the production config file can be decrypted and committed to the repository, and `git-crypt` can
be removed.

## Consequences

Developers will be able to view and change production Helm configuration without installing `git-crypt`, managing GPG
keys or relying on another developer to grant access. Production configuration changes will be easier to review, and
deployments will no longer depend on `git-crypt` or individual developers' private keys.

Sensitive values will have a single managed location in AWS Secrets Manager and Circle CI. Access to those values will
remain restricted through infrastructure permissions; removing repository encryption does not grant developers access
to secrets.

Deployment and runtime configuration will depend on the availability of the externally managed secrets and the
permissions required to retrieve them. Missing values must cause an explicit configuration or deployment failure
rather than silently falling back to another environment's values.

Non-production environments will require corresponding secret entries and configuration, increasing the amount of
configuration managed outside the repository. Changes to secret values will follow the relevant secret-management
process rather than being reviewed as values in a source-code pull request.

The migration requires verification of both deployment behaviour and application behaviour before encryption is
removed. Future configuration changes must continue to keep sensitive values out of the repository.
