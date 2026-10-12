# Adding a new certificate thumbprint to the LAA Court Data Adaptor

When Common Platform makes requests to the LAA Court Data Adaptor, it sends a certificate to the adaptor to verify its
identity.

For us to verify that the certificate is the one we expect, we use the external ingress controller to verify the client
certificate is the one we expect. This is done by checking the SHA1 thumbprint of the client certificate in
the [ingress configuration](../helm_deploy/laa-court-data-adaptor/templates/ingress-external.yaml).

This thumbprint is stored as a CircleCI environment variable, and is sent to Helm as a variable on deploy. This will be
used to generate the `nginx.ingress.kubernetes.io/server-snippet` annotation in the ingress configuration.

This certificate has a limited lifespan, and is set to expire after a certain period of time. When HMCTS generates a new
certificate, they will provide a new certificate thumbprint to us. When we receive this, we will need to update the
CircleCI environment variable to the new thumbprint minus the colon characters.

For example, if the new thumbprint is `05:63:B8:63:0D:62:D7:5A:BB:C8:AB:1E:4B:DF:B5:A8:99:B2:4D:43`, we will need to
run the following command in CircleCI:

```bash
circleci envvar set HMCTS_CA_FINGERPRINT 0563b8630d62d75abbc8ab1e4bdfb5a899b24d43
```

We can then redeploy the application via CircleCI to update the ingress configuration with the new thumbprint. This
will allow Common Platform to continue making requests to the LAA Court Data Adaptor using mTLS with the new certificate.
