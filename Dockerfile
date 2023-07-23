FROM busybox:1-uclibc AS downloader

ARG ACE_STREAM_VERSION
ENV ACE_STREAM_VERSION "$ACE_STREAM_VERSION"
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar -xz -C /tmp

FROM python:3.8-slim-bookworm
LABEL org.opencontainers.image.source https://github.com/trexx/docker-acestream-engine

COPY --from=downloader --link /tmp /app
WORKDIR /app

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp
ENTRYPOINT ["./start-engine"]
CMD ["--client-console"]