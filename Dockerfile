FROM busybox:1-uclibc AS downloader

ENV ACE_STREAM_VERSION "3.2.3_ubuntu_22.04_x86_64_py3.10"

RUN mkdir /tmp/acestream
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar -xz -C /tmp/acestream
RUN rm /tmp/acestream/acestream.conf

FROM python:3.10-slim-bookworm@sha256:7de57d5840f51e10462ba0eed4c4e8aa26f28b44cedbf0fc8dd7fd77ea59c7d9
LABEL org.opencontainers.image.source https://github.com/trexx/docker-acestream-engine

# renovate: datasource=github-releases depName=krallin/tini
ENV TINI_VERSION "v0.19.0"
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini-static
RUN chmod +x /tini-static

COPY --from=downloader --link /tmp/acestream /app
WORKDIR /app
ENV LD_LIBRARY_PATH "/app/lib"

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp
