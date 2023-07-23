#!/usr/bin/env bash

. "../env"

docker push "$DOCKER_REPO:$ACE_STREAM_VERSION"