# `google-pubsub-test-support`

Handy-dandy Google PubSub integration testing utility that starts a [local Docker container](https://github.com/marcelcorso/gcloud-pubsub-emulator) running the [Google PubSub emulator](https://cloud.google.com/pubsub/docs/emulator) if you're not running in a CI/CD pipeline.
This allows you to run integration tests locally in a manner similar to how they'd be run in the CI/CD pipeline.
This module does nothing when running in a CI build pipeline, because Google PubSub should be configured as part of the build via something like [`.gitlab-ci.yml`'s `services`](https://docs.gitlab.com/ee/ci/yaml/#services) element.

This package is intended to be installed in your project in `devDependencies`.

Your application must install its desired version of [Google PubSub](https://www.npmjs.com/package/@google-cloud/pubsub).

> NOTE: requires Docker & a Unix-y shell (`/usr/bin/env sh`) to be available.
> This is not designed to run on Windows; PRs/MRs welcome.

See [src/test/integration/google-pubsub/google-pubsub.spec.js] for usage, but it's basically
```javascript
const googlePubSubConnect = require('google-pubsub-test-support')

// one PubSub instance per unique project name will be returned
const pubsubs = await googlePubSubConnect({ projects: ['project1', 'project2']})

// now you can use any of the PubSub instances
const pubsub1 = pubsubs.project1
const pubsub2 = pubsubs.project2
```

## Configuration

The default configuration is pretty conventional, with the sole exception of the default port that Google PubSub will listen on for clients.
Instead of `8661`, which might already be in use on developers' machines when they run integration tests, the default configuration uses `18661`.
It is a `TODO` to search for an available port.

>NOTE: This module detects when it's running in a CI/CD pipeline by seeing if the environment variable `CI` is of nonzero length.

### Environment variables

The following environment variables can be set to configure it:
* GOOGLE_PUBSUB_TEST_SUPPORT_TAG: The tag of the [Google PubSub Emulator Docker image](https://github.com/marcelcorso/gcloud-pubsub-emulator) or custom image to use, default "latest"
* GOOGLE_PUBSUB_TEST_SUPPORT_PORT: visible client port on `localhost` to map to container port, default is content of `google-pubsub/default-google-pubsub-test-port`
* GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER: name of container, default is content of file `google-pubsub/default-google-pubsub-test-container`
* GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_PORT: Google PubSub emulator client port in container, default `8681`
* GOOGLE_PUBSUB_TEST_SUPPORT_IMAGE: docker image name, default `messagebird/gcloud-pubsub-emulator`
