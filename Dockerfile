FROM busybox:1-uclibc AS downloader

ARG ACE_STREAM_VERSION
ENV ACE_STREAM_VERSION "$ACE_STREAM_VERSION"

RUN mkdir /tmp/acestream
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar -xz -C /tmp/acestream
RUN rm /tmp/acestream/acestream.conf

FROM python:3.8-slim-bookworm
LABEL org.opencontainers.image.source https://github.com/trexx/docker-acestream-engine

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static /tini-static
RUN chmod +x /tini-static

COPY --from=downloader --link /tmp/acestream /app
WORKDIR /app
ENV LD_LIBRARY_PATH "/app/lib"

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp