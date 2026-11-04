# docker-acestream-engine

A simple container image for Ace Stream Engine. It packages the official Linux release of the engine on a slim Python base, with catatonit as the init process, and is published to `ghcr.io/trexx/docker-acestream-engine`.

## Overview

A simple Ace Stream Engine Docker image. The [Dockerfile](Dockerfile) has two stages:

- `downloader` (`busybox:1-uclibc`) downloads `acestream_<ACE_STREAM_VERSION>.tar.gz` from `download.acestream.media` and unpacks it to `/tmp/acestream`, leaving out the bundled `acestream.conf`. The version is set in `ENV ACE_STREAM_VERSION` (currently `3.2.11_ubuntu_18.04_x86_64_py3.8`).
- The final image is `python:3.8-slim-bookworm`, pinned by digest. It adds [catatonit](https://github.com/openSUSE/catatonit) as `/catatonit`, copies the engine to `/app` (the working directory), sets `LD_LIBRARY_PATH=/app/lib` and installs the engine's `requirements.txt` with pip.

The entrypoint is `/catatonit --` and there is no default command, so the engine binary and its options are given as the container's command. The image sets no `USER`, so the engine runs as root. Both the engine download and catatonit are x86_64 builds.

## Usage

Images are published as `ghcr.io/trexx/docker-acestream-engine:<version>` and `ghcr.io/trexx/docker-acestream-engine:latest`. Release tags combine the Ace Stream version and its Python build, for example `3.2.11-py3.8`.

Run the engine by passing `/app/acestreamengine` and its options as the command:

```sh
docker run --rm -p 6878:6878 ghcr.io/trexx/docker-acestream-engine:latest \
  /app/acestreamengine --client-console --log-stdout --http-port 6878
```

In Kubernetes the same command goes in the container's `args`. The engine keeps its state under `/root/.ACEStream/`, so mount a persistent volume there to keep it across restarts. `/webui/api/service?method=get_version` on the HTTP port answers once the engine is up and works as a readiness or liveness probe.

## Configuration

The bundled `acestream.conf` is not included in the image, so the engine is configured with command-line options after `/app/acestreamengine`. Options in use with this image include `--client-console`, `--disable-sentry`, `--log-stdout`, `--log-stdout-level`, `--http-port`, `--live-cache-type`, `--live-buffer-time`, `--live-mem-cache-size`, `--download-limit`, `--upload-limit`, `--max-peers` and `--stats-report-interval`.

## Development

Build the image locally with:

```sh
docker build .
```

The Dockerfile uses `ADD --chmod` and `COPY --link`, which need BuildKit (the default builder in current Docker).

Dependency updates:

- [Renovate](.github/renovate.json) updates the Python base image digest and the catatonit version, which is tracked through the `# renovate: datasource=github-releases depName=openSUSE/catatonit` comment above `ENV CATATONIT_VERSION`. Updates to build-stage images are disabled.
- `ACE_STREAM_VERSION` has no Renovate comment and is updated by hand.

Workflows in `.github/workflows`:

- `container-check.yml` runs hadolint on the Dockerfile and builds the image without pushing it, on pull requests and pushes to `main`.
- `trivy.yml` scans `ghcr.io/trexx/docker-acestream-engine:latest` daily and uploads the results to the repository's Security tab.

## Releases

Releases are cut with the Release button: Actions → Release → Run workflow ([`.github/workflows/release.yml`](.github/workflows/release.yml), which calls `trexx/actions`' `release-image.yml`). Run it from the default branch.

1. It works out the tag from `ACE_STREAM_VERSION` in the Dockerfile: the Ace Stream version and Python build, so `3.2.11_ubuntu_18.04_x86_64_py3.8` becomes `3.2.11-py3.8`. If that version was released before, it uses `<version>-N` for the rebuild (for example after a base image update). A tag can also be given by hand in the `tag` input.
2. It builds the image and pushes it as that tag and `latest`.
3. It creates the git tag and the GitHub release.

Ticking "dry run" only works out the tag and builds the image; nothing is pushed and no release is created. This repository keeps older image versions in the package (`prune_images: false`).

Pushing a tag by hand (matching `*.*.*`) still works: [`.github/workflows/build.yml`](.github/workflows/build.yml) builds and pushes the image for that tag.
