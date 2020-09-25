# Adding a new certificate to the allow list for mTLS
* The requesting party (Common Platform) needs to provide their client certificate, as well as the root/intermediate certificates from the Certifying Authority (CA). The CA certificates are usually publicly available via the CA's website.
* Verify that the client certificate against the CA's certificate:
  ```
  openssl verify -CAfile ca.crt hmcts.crt
  ```
  Output: `hmcts.crt: OK`
  This will ensure that the client cert can be used successfully for mTLS.

* Bundle all the necessary CA files (not including the client certificate) into a file at prod/ca.crt
      ```
      cat certificate1.crt certificate2.crt > ca.crt
      ```
* Move the certificate to the appropriate directory, eg: helm_deploy/laa-court-data-adaptor/prod/ca.crt
* Find the SHA1 fingerprint of the client certificate.
      ```
      openssl x509 -in client.crt -noout -fingerprint
      ```
The output will be of the form `Fingerprint: 05:63:B8:63:0D:62:D7:5A:BB:C8:AB:1E:4B:DF:B5:A8:99:B2:4D:43`

* In the values for the relevant environment, under `externalAnnotations`, add the certificate to the basic allow list, like so:
  ```
  nginx.ingress.kubernetes.io/server-snippet: |
        set $accept false;

        if ( $ssl_client_fingerprint = '0563b8630d62d75abbc8ab1e4bdfb5a899b24d43') {
          set $accept true;
        }

        if ($accept != true) {
          return 403;
        }
  ```
  This will ensure that only the specified client certificate will be able to make authorised requests to the routes specified in the external ingress.
