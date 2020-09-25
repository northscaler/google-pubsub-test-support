#!/usr/bin/env sh

# Usage is via env vars:
#   GOOGLE_PUBSUB_TEST_SUPPORT_TAG: docker image tag to use, default "latest"
#   GOOGLE_PUBSUB_TEST_SUPPORT_PORT: visible port to map to container port, default is content of file default-google-pubsub-test-port
#   GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER: name of container, default is content of file default-google-pubsub-test-container
#   GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_PORT: google-pubsub client port in container, default 8681
#   GOOGLE_PUBSUB_TEST_SUPPORT_IMAGE: docker image name, default "messagebird/gcloud-pubsub-emulator"

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"

if [ -n "$CI" ]; then # we're in CI pipeline & not forcing start
  echo 'in CI pipeline; container is assumed to be started'
  exit 0
fi

if [ -z "$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER" ]; then
  GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER="$(cat $THIS_DIR/default-google-pubsub-test-container)"
fi

if [ -z "$GOOGLE_PUBSUB_TEST_SUPPORT_PUBSUB_PORT" ]; then
  GOOGLE_PUBSUB_TEST_SUPPORT_PUBSUB_PORT="$(cat $THIS_DIR/default-google-pubsub-test-port)"
fi

if [ -z "$(docker ps --quiet --filter name=$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER)" ]; then
  "$THIS_DIR/start-google-pubsub-container.sh" $@
fi
