#!/bin/bash

CONTAINER="$1"

RUNNING=$(docker inspect --format="{{ .State.Running }}" "$CONTAINER" 2> /dev/null)

if [ $? -eq 1 ]; then
  echo "container '$CONTAINER' does not exist."
else
  docker rm --force "$CONTAINER"
fi
