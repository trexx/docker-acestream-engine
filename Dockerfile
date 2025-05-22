FROM busybox:1-uclibc AS downloader

ENV ACE_STREAM_VERSION="3.2.3_ubuntu_22.04_x86_64_py3.10"

RUN mkdir /tmp/acestream
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar -xz -C /tmp/acestream
RUN rm /tmp/acestream/acestream.conf

FROM python:3.10-slim-bookworm@sha256:727bcea1bca58820e83b67b048f0eafe936fa215a69847e1466bc6312251fe2c
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-acestream-engine"

# renovate: datasource=github-releases depName=openSUSE/catatonit
ENV CATATONIT_VERSION="v0.2.1"
ADD https://github.com/openSUSE/catatonit/releases/download/${CATATONIT_VERSION}/catatonit.x86_64 /catatonit
RUN chmod +x /catatonit

COPY --from=downloader --link /tmp/acestream /app
WORKDIR /app
ENV LD_LIBRARY_PATH="/app/lib"

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp
ENTRYPOINT ["/catatonit", "--"]