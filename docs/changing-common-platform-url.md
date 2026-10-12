# Changing Common Platform URL

In some environments (particularly in UAT), you may need to change the Common Platform URL to point to a different
instance (for example, when testing new features).

To do this, you can follow these steps:

## Change the Common Platform URL in your AWS secrets manager

First, [log into the AWS console](https://justice-cloud-platform.eu.auth0.com/samlp/mQev56oEa7mrRCKAZRxSnDSoYt6Y7r5m?connection=github)
and navigate to the AWS Secrets Manager.

Search for the `aws-secrets` secret that matches the environment you want to update - for example,
`laa-court-data-adaptor-uat aws-secrets` for UAT.

Click on the secret, click "Retrieve secret value" and then click the "Edit" button. Update the `common_platform_url`
field with the new URL you want to use, and then click "Save".

## Delete the secret in your Kubernetes cluster

Run the following command (where `$NAMESPACE` is the namespace where your application is deployed):

```
kubectl -n $NAMESPACE delete secret aws-secrets
```

The secret will be recreated automatically, with the new value.

## Restart the pods

Run the following command to restart the pods in your namespace (where `$NAMESPACE` is the namespace where your application is deployed):

```bash
kubectl -n $NAMESPACE rollout restart deployment/laa-court-data-adaptor
```

After a few moments, the pods will restart and the application will start using the new Common Platform URL.
