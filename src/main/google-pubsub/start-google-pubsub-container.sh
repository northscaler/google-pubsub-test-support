#!/usr/bin/env sh

# Usage is via env vars:
#   GOOGLE_PUBSUB_TEST_SUPPORT_TAG: docker image tag to use, default "latest"
#   GOOGLE_PUBSUB_TEST_SUPPORT_PORT: visible port to map to container port, default is content of file default-google-pubsub-test-port
#   GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER: name of container, default is content of file default-google-pubsub-test-container
#   GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_PORT: google-pubsub client port in container, default 8681
#   GOOGLE_PUBSUB_TEST_SUPPORT_IMAGE: docker image name, default "google-pubsub"

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"

GOOGLE_PUBSUB_TEST_SUPPORT_TAG=${GOOGLE_PUBSUB_TEST_SUPPORT_TAG:-latest}
GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_PORT=${GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_PORT:-8681}
GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_IMAGE=${GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_IMAGE:-messagebird/gcloud-pubsub-emulator}

if [ -z "$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER" ]; then
  GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER="$(cat $THIS_DIR/default-google-pubsub-test-container)"
fi

if [ -z "$GOOGLE_PUBSUB_TEST_SUPPORT_PORT" ]; then
  GOOGLE_PUBSUB_TEST_SUPPORT_PORT="$(cat $THIS_DIR/default-google-pubsub-test-port)"
fi

RUNNING=$(docker inspect --format="{{ .State.Running }}" "$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER" 2> /dev/null)

if [ "$RUNNING" == "true" ]; then
  exit 0
fi

# else container is stopped or unknown - forcefully recreate
echo "container '$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER' is stopped or unknown - recreating"

# make sure it's gone
docker ps -a | \
  grep "$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER" | \
  awk '{ print $1}' | \
  xargs docker rm --force

CMD="docker run --name $GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER -p $GOOGLE_PUBSUB_TEST_SUPPORT_PORT:$GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_PORT -d $GOOGLE_PUBSUB_TEST_SUPPORT_CONTAINER_IMAGE:$GOOGLE_PUBSUB_TEST_SUPPORT_TAG"
echo "$CMD"
$CMD
