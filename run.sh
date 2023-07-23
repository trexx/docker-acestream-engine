#!/usr/bin/env bash

. "./env"

docker run \
	--publish "6878:6878" \
	--rm \
	--tmpfs "/dev/disk/by-id:noexec,rw,size=4k" \
		"$DOCKER_REPO:$ACE_STREAM_VERSION"