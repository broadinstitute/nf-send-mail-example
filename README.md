# nf-send-mail-example

Compares how secrets providers behave when values are missing.

## Overview

The workflow reads optional SMTP settings from Nextflow secrets. When those secrets are missing, the behavior is inconsistent across environments:

- On Seqera Cloud with `tw launch`, missing Google Secret Manager entries cause a hard failure while parsing the config.
- With a local `nextflow run`, the same missing values are treated as empty and the workflow continues until it fails later when trying to connect to `localhost:25`.

The workflow reads values from Nextflow secrets for:

- `EMAIL_HOST`
- `EMAIL_PORT`
- `EMAIL_USER`
- `EMAIL_PASSWORD`

The config tries to fall back to default values when a secret is missing:

- host: `localhost`
- port: `25`
- user: `null`
- password: `null`

The behavior when the required secret values are filled in with empty values:

- the workflow logs empty values for `secrets.EMAIL_*`
- the workflow reaches the `sendMail()` step
- the send (likely) fails with a connection error to `localhost:25`

As of August 2026, [the Nextflow secrets documentation](https://web.archive.org/web/20260610161403/https://docs.seqera.io/nextflow/secrets) does not specify the expected behavior for plugins reading missing secrets, except to say:

> Config reloading: If secrets are accessed during configuration and the initial load succeeds, Nextflow will reload the configuration with secrets enabled.

## Throwing exception: `tw launch` on Seqera Cloud with Google Compute

Command:

```shell
tw launch \
https://github.com/broadinstitute/nf-send-mail-example \
--params-file <(
printf \
'{"from":"kshakir@broadinstitute.org",
"to":"kshakir@broadinstitute.org",
"subject":"test",
"text":"test"}'
)
```

<details>

<summary>Expand here for console output...</summary>

```
tee: /.nextflow/cache/nf-51C4bfAYNm8w6Y.txt: No such file or directory
N E X T F L O W  ~  version 26.04.6
Pulling broadinstitute/nf-send-mail-example ...
downloaded from https://github.com/broadinstitute/nf-send-mail-example.git
Downloading plugin nf-schema@2.8.0
ERROR ~ Unable to parse config file: '/.nextflow/assets/.repos/broadinstitute/nf-send-mail-example/clones/13d7c1d201dd0e04bcee2b07edd426d952164d8b/nextflow.config'
  io.grpc.StatusRuntimeException: NOT_FOUND: Secret [projects/[redacted]/secrets/tower-51C4bfAYNm8w6Y-EMAIL_HOST] not found or has no versions.
-- Check '/.nextflow/cache/nf-51C4bfAYNm8w6Y.log' file for details
```

</details>

<details>

<summary>Expand here for error snippet from nextflow logs...</summary>

```
...
Sep-09 01:31:08.259 [main] DEBUG n.secret.LocalSecretsProvider - Secrets store: /.nextflow/secrets/store.json
Sep-09 01:31:08.298 [main] DEBUG nextflow.secret.SecretsLoader - Discovered secrets providers: [nextflow.cloud.google.secrets.GoogleSecretsProvider@4cecc15a, nextflow.secret.LocalSecretsProvider@d969452] - activable => nextflow.cloud.google.secrets.GoogleSecretsProvider@4cecc15a
Sep-09 01:31:08.299 [main] DEBUG nextflow.cli.CmdRun - Config file used secrets -- reloading config with secrets provider
Sep-09 01:31:08.302 [main] DEBUG nextflow.config.ConfigBuilder - Found config base: /.nextflow/assets/.repos/broadinstitute/nf-send-mail-example/clones/13d7c1d201dd0e04bcee2b07edd426d952164d8b/nextflow.config
Sep-09 01:31:08.303 [main] DEBUG nextflow.config.ConfigBuilder - Found config local: /nextflow.config
Sep-09 01:31:08.305 [main] DEBUG nextflow.config.ConfigBuilder - Parsing config file: /.nextflow/assets/.repos/broadinstitute/nf-send-mail-example/clones/13d7c1d201dd0e04bcee2b07edd426d952164d8b/nextflow.config
Sep-09 01:31:08.305 [main] DEBUG nextflow.config.ConfigBuilder - Parsing config file: /nextflow.config
Sep-09 01:31:08.313 [main] DEBUG nextflow.config.ConfigBuilder - Applying config profile: `standard`
Sep-09 01:31:09.857 [main] ERROR nextflow.cli.Launcher - Unable to parse config file: '/.nextflow/assets/.repos/broadinstitute/nf-send-mail-example/clones/13d7c1d201dd0e04bcee2b07edd426d952164d8b/nextflow.config'

  io.grpc.StatusRuntimeException: NOT_FOUND: Secret [projects/[redacted]/secrets/tower-51C4bfAYNm8w6Y-EMAIL_HOST] not found or has no versions.

com.google.api.gax.rpc.NotFoundException: io.grpc.StatusRuntimeException: NOT_FOUND: Secret [projects/[redacted]/secrets/tower-51C4bfAYNm8w6Y-EMAIL_HOST] not found or has no versions.
	at com.google.api.gax.rpc.ApiExceptionFactory.createException(ApiExceptionFactory.java:90)
	at com.google.api.gax.rpc.ApiExceptionFactory.createException(ApiExceptionFactory.java:41)
	at com.google.api.gax.grpc.GrpcApiExceptionFactory.create(GrpcApiExceptionFactory.java:86)
	at com.google.api.gax.grpc.GrpcApiExceptionFactory.create(GrpcApiExceptionFactory.java:66)
	at com.google.api.gax.grpc.GrpcExceptionCallable$ExceptionTransformingFuture.onFailure(GrpcExceptionCallable.java:97)
	at com.google.api.core.ApiFutures$1.onFailure(ApiFutures.java:84)
	at com.google.common.util.concurrent.Futures$CallbackListener.run(Futures.java:1132)
	at com.google.common.util.concurrent.DirectExecutor.execute(DirectExecutor.java:31)
	at com.google.common.util.concurrent.AbstractFuture.executeListener(AbstractFuture.java:1307)
	at com.google.common.util.concurrent.AbstractFuture.complete(AbstractFuture.java:1070)
	at com.google.common.util.concurrent.AbstractFuture.setException(AbstractFuture.java:819)
	at io.grpc.stub.ClientCalls$GrpcFuture.setException(ClientCalls.java:651)
	at io.grpc.stub.ClientCalls$UnaryStreamToFuture.onClose(ClientCalls.java:621)
	at io.grpc.PartialForwardingClientCallListener.onClose(PartialForwardingClientCallListener.java:39)
	at io.grpc.ForwardingClientCallListener.onClose(ForwardingClientCallListener.java:23)
	at io.grpc.ForwardingClientCallListener$SimpleForwardingClientCallListener.onClose(ForwardingClientCallListener.java:40)
	at com.google.api.gax.grpc.ChannelPool$ReleasingClientCall$1.onClose(ChannelPool.java:569)
	at io.grpc.PartialForwardingClientCallListener.onClose(PartialForwardingClientCallListener.java:39)
	at io.grpc.ForwardingClientCallListener.onClose(ForwardingClientCallListener.java:23)
	at io.grpc.ForwardingClientCallListener$SimpleForwardingClientCallListener.onClose(ForwardingClientCallListener.java:40)
	at com.google.api.gax.grpc.GrpcLoggingInterceptor$1$1.onClose(GrpcLoggingInterceptor.java:98)
	at io.grpc.internal.DelayedClientCall$DelayedListener$3.run(DelayedClientCall.java:487)
	at io.grpc.internal.DelayedClientCall$DelayedListener.delayOrExecute(DelayedClientCall.java:451)
	at io.grpc.internal.DelayedClientCall$DelayedListener.onClose(DelayedClientCall.java:484)
	at io.grpc.internal.ClientCallImpl.closeObserver(ClientCallImpl.java:565)
	at io.grpc.internal.ClientCallImpl.access$100(ClientCallImpl.java:72)
	at io.grpc.internal.ClientCallImpl$ClientStreamListenerImpl$1StreamClosed.runInternal(ClientCallImpl.java:733)
	at io.grpc.internal.ClientCallImpl$ClientStreamListenerImpl$1StreamClosed.runInContext(ClientCallImpl.java:714)
	at io.grpc.internal.ContextRunnable.run(ContextRunnable.java:37)
	at io.grpc.internal.SerializingExecutor.run(SerializingExecutor.java:133)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1144)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:642)
	at java.base/java.lang.Thread.run(Thread.java:1583)
	Suppressed: com.google.api.gax.rpc.AsyncTaskException: Asynchronous task failed
		at com.google.api.gax.rpc.ApiExceptions.callAndTranslateApiException(ApiExceptions.java:57)
		at com.google.api.gax.rpc.UnaryCallable.call(UnaryCallable.java:112)
		at com.google.cloud.secretmanager.v1.SecretManagerServiceClient.accessSecretVersion(SecretManagerServiceClient.java:1783)
		at nextflow.cloud.google.secrets.GoogleSecretsProvider.getSecret(GoogleSecretsProvider.groovy:131)
		at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
		at nextflow.secret.SecretsLoader$1.getProperty(SecretsLoader.groovy:71)
		at org.codehaus.groovy.vmplugin.v8.IndyInterface.fromCache(IndyInterface.java:321)
		at _nf_config_310ed294$_run_closure3$_closure4.doCall(_nf_config_310ed294:14)
		at _nf_config_310ed294$_run_closure3$_closure4.doCall(_nf_config_310ed294)
...
```
</details>

## Quietly using an empty value: `nextflow run`

```shell
nextflow run \
https://github.com/broadinstitute/nf-send-mail-example \
--from kshakir@broadinstitute.org \
--to kshakir@broadinstitute.org \
--subject test \
--text test
```

<details>

<summary>Expand here for console output...</summary>

```

 N E X T F L O W   ~  version 26.04.6

WARN: Cannot read project manifest -- Cause:  Cannot get property 'EMAIL_HOST' on null object
Downloading plugin nf-schema@2.8.0
Downloading plugin nf-tower@1.28.2
Launching `https://github.com/broadinstitute/nf-send-mail-example` [determined_cuvier] revision: 13d7c1d201 [main]

WARN: Unrecognized config option 'mail.smtp.auth'
WARN: Unrecognized config option 'mail.smtp.starttls.enable'
WARN: Unrecognized config option 'mail.smtp.starttls.required'
WARN: Unrecognized config option 'mail.smtp.ssl.protocols'
WARN: Unrecognized config option 'mail.smtp.connectiontimeout'
WARN: Unrecognized config option 'mail.smtp.timeout'
WARN: Unrecognized config option 'mail.smtp.writetimeout'
WARN: Static typing is a preview feature -- syntax and behavior may change in future releases
[message:
secrets.EMAIL_HOST: null
secrets.EMAIL_PORT: null
secrets.EMAIL_USER: null
secrets.EMAIL_PASSWORD: null

test]
ERROR ~ Could not connect to SMTP host: localhost, port: 25

 -- Check script '/Users/kshakir/.nextflow/assets/.repos/broadinstitute/nf-send-mail-example/clones/13d7c1d201dd0e04bcee2b07edd426d952164d8b/main.nf' at line: 38 or see '.nextflow.log' file for more details
```

</details>

## Quietly using an empty value: `nextflow run` with nf-google

NOTE: This example doesn't actually run anything on Google, but [nf-google](https://github.com/nextflow-io/nextflow/tree/master/plugins/nf-google) is public source code related to Nextflow and Google. The `sendMail()` still executes on your local host. To try this example, you must provide your own [google.config](https://docs.seqera.io/nextflow/executor/google-batch).

```shell
nextflow run \
-c google.config \
https://github.com/broadinstitute/nf-send-mail-example \
--from kshakir@broadinstitute.org \
--to kshakir@broadinstitute.org \
--subject test \
--text test
```

<details>

<summary>Expand here for console output...</summary>

```

 N E X T F L O W   ~  version 26.04.6

WARN: Cannot read project manifest -- Cause:  Cannot get property 'EMAIL_HOST' on null object
Downloading plugin nf-google@1.27.3
Launching `https://github.com/broadinstitute/nf-send-mail-example` [fervent_davinci] revision: 13d7c1d201 [main]

WARN: Unrecognized config option 'mail.smtp.auth'
WARN: Unrecognized config option 'mail.smtp.starttls.enable'
WARN: Unrecognized config option 'mail.smtp.starttls.required'
WARN: Unrecognized config option 'mail.smtp.ssl.protocols'
WARN: Unrecognized config option 'mail.smtp.connectiontimeout'
WARN: Unrecognized config option 'mail.smtp.timeout'
WARN: Unrecognized config option 'mail.smtp.writetimeout'
WARN: Static typing is a preview feature -- syntax and behavior may change in future releases
[message:
secrets.EMAIL_HOST: null
secrets.EMAIL_PORT: null
secrets.EMAIL_USER: null
secrets.EMAIL_PASSWORD: null

test]
ERROR ~ Could not connect to SMTP host: localhost, port: 25

 -- Check script '/Users/kshakir/.nextflow/assets/.repos/broadinstitute/nf-send-mail-example/clones/13d7c1d201dd0e04bcee2b07edd426d952164d8b/main.nf' at line: 38 or see '.nextflow.log' file for more details
```

</details>
