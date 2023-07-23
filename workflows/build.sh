#!/usr/bin/env bash

. "../env"

docker build \
	--build-arg "ACE_STREAM_VERSION=$ACE_STREAM_VERSION" \
	--tag "$DOCKER_REPO:$ACE_STREAM_VERSION" \
    "../"