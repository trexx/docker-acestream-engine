FROM busybox:1-uclibc AS downloader

ENV ACE_STREAM_VERSION="3.2.11_ubuntu_22.04_x86_64_py3.10"

RUN mkdir /tmp/acestream
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar --exclude="acestream.conf" -xz -C /tmp/acestream

FROM python:3.10-slim-bookworm@sha256:a02d127ac3e004d100268fcf394e8d673e1f43f2ac84d2f38f7d8345f18890b3
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-acestream-engine"

# renovate: datasource=github-releases depName=openSUSE/catatonit
ENV CATATONIT_VERSION="v0.2.1"
ADD --chmod=+x https://github.com/openSUSE/catatonit/releases/download/${CATATONIT_VERSION}/catatonit.x86_64 /catatonit

COPY --from=downloader --link /tmp/acestream /app
WORKDIR /app
ENV LD_LIBRARY_PATH="/app/lib"

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp
ENTRYPOINT ["/catatonit", "--"]
